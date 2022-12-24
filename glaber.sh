#!/usr/bin/env bash
set -e

export args=" --build-arg GLABER_BUILD_VERSION=$(cat glaber.version)"
# export ZBX_PORT=8050

git-reset-variables-files () {
    git checkout HEAD -- mysql/data.sql
    git checkout HEAD -- clickhouse/users.xml
    git checkout HEAD -- .env
}

wait () {
  while true;do
  curl -s http://127.0.0.1:${ZBX_PORT:-80} | grep "Username" > /dev/null  && \
  echo "Success" && break || \
  echo "Waiting zabbix to start..." && sleep 10;done
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
  docker-compose build $args 1>/dev/null
}

start() {
  build
  docker-compose up -d
  wait
  cat .zbxweb
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

set-passwords

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
  *)
    echo -n "unknown command"
    ;;
esac
