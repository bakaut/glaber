#!/usr/bin/env bash
set -e -x

export args=" --build-arg GLABER_BUILD_VERSION=$(cat glaber.version)"
export ZBX_PORT=8050

diag () {
  docker-compose logs --no-color clickhouse > .tmp/diag/clickhouse.log
  docker-compose logs --no-color mysql > .tmp/diag/mysql.log
  docker-compose logs --no-color glaber-nginx > .tmp/diag/glaber-nginx.log
  docker-compose logs --no-color glaber-server > .tmp/diag/glaber-server.log
  docker-compose ps > .tmp/diag/ps.log
  git status > .tmp/diag/gitstatus.log
  uname -a > .tmp/diag/uname.log
  cat /etc/os-release > .tmp/diag/os-release 
  zip -r .tmp/diag/diag.zip .tmp/diag/
}
git-reset-variables-files () {
  git checkout HEAD -- mysql/data.sql
  git checkout HEAD -- clickhouse/users.xml
  git checkout HEAD -- .env
}

info () {
  local message=$1
  echo $(date --rfc-3339=seconds) $message
}
wait () {
  while true
  local counter=0
  local timeout=5
  do
    curl -s http://127.0.0.1:${ZBX_PORT:-80} | grep "Username" > /dev/null && break
    info "Waiting zabbix to start..."
    sleep 60
    counter=$((counter+1))
    if test $counter -gt $timeout;then
      info "Zabbix start failed.Timeout 5 minute reached"
      info "Please try to open zabbix url with credentials $(cat .zbxweb)"
      info "If not success, please run diagnostics ./glaber.sh diag"
      exit 1
    fi 
  done
  info "Success $(cat .zbxweb)"
}

set-passwords() {
  gen-password() {
    < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c12
  }
  make-bcrypt-hash() {
    htpasswd -bnBC 8 "" $1 | tail -c 55
  }
  if [ ! -f .passwords.created ]; then
    git-reset-variables-files
    ZBX_CH_PASS=$(gen-password)
    sed -i -e "s/MYSQL_PASSWORD=.*/MYSQL_PASSWORD=$(gen-password)/" \
           -e "s/ZBX_CH_PASS=.*/ZBX_CH_PASS=$ZBX_CH_PASS/" \
           -e "s/MYSQL_ROOT_PASSWORD=.*/MYSQL_ROOT_PASSWORD=$(gen-password)/" \
    .env
    ZBX_WEB_ADMIN_PASS=$(gen-password)
    ZBX_WEB_ADMIN_PASS_HASH=$(make-bcrypt-hash $ZBX_WEB_ADMIN_PASS)
    ZBX_WEB_GUEST_PASS=$(gen-password)
    ZBX_WEB_ADMIN_GUEST_HASH=$(make-bcrypt-hash $ZBX_WEB_GUEST_PASS)
    echo "Zabbix web access http://127.0.1.1:${ZBX_PORT:-80} Admin $ZBX_WEB_ADMIN_PASS" > .zbxweb
    sed -i -e "6s#admin-pass-hash#$ZBX_WEB_ADMIN_PASS_HASH#" \
           -e  "7s#guest-pass-hash#$ZBX_WEB_ADMIN_GUEST_HASH#" \
    mysql/data.sql
    source .env
    sed -i -e "s/<password>.*<\/password>/<password>$ZBX_CH_PASS<\/password>/" \
           -e "s/defaultuser/$ZBX_CH_USER/" \
    clickhouse/users.xml
    touch .passwords.created
  fi
}


usage() {
  echo "Usage: $0 <action>"
  echo
  echo "$0 build    - Build docker images"
  echo "$0 start    - Build docker images and start glaber"
  echo "$0 stop     - Stop glaber containers"
  echo "$0 recreate - Completely remove glaber and start it again"
  echo "$0 remove   - Completely remove glaber installation"
  echo "$0 remote   - Remote rebuild github glaber images (only admins)"
}

[ $# -ne 1 ] && (usage && exit 1)

# Check whether docker-compose is installed
command -v docker-compose >/dev/null 2>&1 || \
{ echo >&2 "docker-compose is required, please install it and start over. Aborting."; exit 1; }

# Check whether htpasswd is installed
command -v htpasswd >/dev/null 2>&1 || \
{ echo >&2 "htpasswd is required(apache2-utils), please install it and start over. Aborting."; exit 1; }

build() {
  docker-compose build $args 1>.tmp/diag/docker-build.log
}

start() {
  set-passwords
  build
  docker-compose up -d
  wait
}

stop() {
  docker-compose down
}

remove() {
  docker-compose down
  docker volume rm glaber-docker_data_clickhouse  glaber-docker_data_mysql || true
  rm .passwords.created
}

recreate() {
  remove
  start
}

remote() {
  read -p "Are you sure than you are this repo admin [y/n] ? " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    tag=$(date '+%Y-%m-%d-%H-%M-%S')
    git-reset-variables-files
    git checkout -b build/$tag
    git push --set-upstream origin build/$tag
  fi
}


case $1 in
  build)
    build
    ;;
  start)
    start
    ;;
  stop)
    stop
    ;;
  recreate)
    recreate
    ;;
  remove)
    remove
    ;;
  remote)
    remote
    echo -n "Pushed to remote build branch"
    echo ""    
    ;;
  diag)
    diag
    ;;
  *)
    echo -n "unknown command"
    ;;
esac
