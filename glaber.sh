#!/usr/bin/env bash
set -e

export GLABER_BUILD_VERSION=$(cat glaber.version)
export args=" --build-arg GLABER_BUILD_VERSION=$GLABER_BUILD_VERSION"
# export ZBX_PORT=8050

diag () {
  info "Collect glaber logs"
  docker-compose logs --no-color clickhouse > .tmp/diag/clickhouse.log || true
  docker-compose logs --no-color mysql > .tmp/diag/mysql.log || true
  docker-compose logs --no-color glaber-nginx > .tmp/diag/glaber-nginx.log || true
  docker-compose logs --no-color glaber-server > .tmp/diag/glaber-server.log || true
  docker-compose ps > .tmp/diag/ps.log
  info "Collect geneal information about system and docker"
  uname -a > .tmp/diag/uname.log
  git log -1 --stat > .tmp/diag/last-commit.log
  cat /etc/os-release > .tmp/diag/os-release
  free -m > .tmp/diag/mem.log
  df -h   > .tmp/diag/disk.log
  docker-compose -version > .tmp/diag/docker-compose-version.log
  docker --version > .tmp/diag/docker-version.log
  docker info > .tmp/diag/docker-info.log
  info "Add diagnostic information to .tmp/diag/diag.zip"
  zip -r .tmp/diag/diag.zip .tmp/diag/ 1>/dev/null
  info "Fill free to create issue https://github.com/bakaut/glaber/issues/new"
  info "And attach .tmp/diag/diag.zip to it"
}
git-reset-variables-files () {
  git checkout HEAD -- mysql/data.sql
  git checkout HEAD -- clickhouse/users.xml
  git checkout HEAD -- .env
  git checkout HEAD -- glaber.sh
}

info () {
  local message=$1
  echo $(date --rfc-3339=seconds) $message
}
wait () {
  local counter=0
  local timeout=5
  while true
  do
    curl -s http://127.0.0.1:${ZBX_PORT:-80} | grep "Username" > /dev/null && break
    info "Waiting zabbix to start..."
    sleep 60
    counter=$((counter+1))
    if test $counter -gt $timeout;then
      info "Zabbix start failed.Timeout 5 minutes reached"
      info "Please try to open zabbix url with credentials:"
      info "$(cat .zbxweb)"
      info "If not success, please run diagnostics ./glaber.sh diag"
      exit 1
    fi 
  done
  info "Success"
  info "$(cat .zbxweb)"
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
           -e "s/10000000000/$ZBX_CH_CONFIG_MAX_MEMORY_USAGE/" \
           -e "s/defaultuser/$ZBX_CH_USER/" \
    clickhouse/users.xml
    sed -i -e "s/3G/$MYSQL_CONFIG_INNODB_BUFFER_POOL_SIZE/" \
    mysql/etc/my.cnf.d/innodb.conf
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
  echo "$0 remote   - Remote rebuild github glaber images (only admins)"
  echo "$0 diag     - Collect glaber start and some base system info to the file"
}

[ $# -ne 1 ] && (usage && exit 1)

# Check whether docker-compose is installed
command -v docker-compose >/dev/null 2>&1 || \
{ echo >&2 "docker-compose is required, please install it and start over. Aborting."; exit 1; }

# Check whether htpasswd is installed
command -v htpasswd >/dev/null 2>&1 || \
{ echo >&2 "htpasswd is required(apache2-utils), please install it and start over. Aborting."; exit 1; }

build() {
  [ -d "glaber-server/workers_script/" ] || mkdir -p .glaber-server/workers_script
  [ -d ".tmp/diag/" ] || mkdir -p .tmp/diag/
  [ -d ".mysql/mysql_data/" ] || \
  sudo install -d -o 1001 -g 1001 mysql/mysql_data/
  [ -d ".clickhouse/clickhouse_data/" ] || \
  sudo install -d -o 101 -g 103 clickhouse/clickhouse_data
  docker-compose build $args 1>.tmp/diag/docker-build.log
  docker-compose pull 1>.tmp/diag/docker-build.log
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
  read -p "Are you sure to completely remove glaber with database [y/n] ? " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    rm .passwords.created .zbxweb || true
    sudo rm -rf  mysql/mysql_data/ clickhouse/clickhouse_data
    git-reset-variables-files
  fi
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
    tag=$GLABER_BUILD_VERSION-$(date '+%Y-%m-%d-%H-%M')
    VERSION_URL="https://gitlab.com/mikler/glaber/-/raw/master/include/version.h"
    GLABER_REPO_VERSION=$(curl -s $VERSION_URL | grep "GLABER_VERSION" | grep -Po "(\d+\.\d+\.\d+)")
    if [[ "$GLABER_REPO_VERSION" == "$GLABER_BUILD_VERSION" ]]
      then
        info "No glaber build requered. Version equals"
        read -p "Do you want to process [y/n] ? " -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]
          then
          git-reset-variables-files
          git checkout -b build/$tag
          git push --set-upstream origin build/$tag
          echo -n "Pushed to remote build branch"
          echo ""
        fi
      else
        git-reset-variables-files
        git checkout -b build/$tag
        echo $GLABER_REPO_VERSION > glaber.version
        git add glaber.version
        git commit -m "glaber version updated"
        git push --set-upstream origin build/$tag
        echo -n "Pushed to remote build branch"
        echo "" 
    fi
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
    ;;
  diag)
    diag
    ;;
  *)
    echo -n "unknown command"
    ;;
esac
