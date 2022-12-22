#!/usr/bin/env bash
set -e

export args=" --build-arg GLABER_BUILD_VERSION=$(cat glaber.version)"

set-passwords() {
  gen-password() {
    < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c12
  }
  make-bcrypt-hash() {
    htpasswd -bnBC 8 "" $1 | grep -oP '\$2[ayb]\$.{56}' | tail -c 54
  }
  if [ ! -f /tmp/files.changed ]; then
    ZBX_CH_PASS=$(gen-password)
    sed -i -e "s/MYSQL_PASSWORD=.*/MYSQL_PASSWORD=$(gen-password)/" \
           -e "s/ZBX_CH_PASS=.*/ZBX_CH_PASS=$ZBX_CH_PASS/" \
           -e "s/MYSQL_ROOT_PASSWORD=.*/MYSQL_ROOT_PASSWORD=$(gen-password)/" \
    .env
    ZBX_WEB_ADMIN_PASS=$(gen-password)
    ZBX_WEB_ADMIN_PASS_HASH=$(make-bcrypt-hash $ZBX_WEB_ADMIN_PASS)
    ZBX_WEB_GUEST_PASS=$(gen-password)
    ZBX_WEB_ADMIN_GUEST_HASH=$(make-bcrypt-hash $ZBX_WEB_GUEST_PASS)
    echo "Zabbix web access http://127.0.1.1 Admin $ZBX_WEB_ADMIN_PASS" > .zbxweb
    sed -i -e "s#admin-pass-hash#$ZBX_WEB_ADMIN_PASS_HASH#" \
           -e "s#guest-pass-hash#$ZBX_WEB_ADMIN_GUEST_HASH#" \
    mysql/data.sql
    source .env
    sed -i -e "s/<password>.*<\/password>/<password>$ZBX_CH_PASS<\/password>/" \
           -e "s/defaultuser/$ZBX_CH_USER/" \
    clickhouse/users.xml
    touch /tmp/files.changed
  fi
}


usage() {
  echo "Usage: $0 <action>"
  echo
  echo "$0 build - Build docker images"
  echo "$0 start - Build docker images and start glaber"
  echo "$0 rerun - Completely remove glaber and start it again"
  echo "$0 prune - Completely remove glaber installation"
  echo "$0 remotebuild - Remote rebuild github glaber images (only admins)"
}

[ $# -ne 1 ] && (usage && exit 1)

# Check whether docker-compose is installed
command -v docker-compose >/dev/null 2>&1 || \
{ echo >&2 "docker-compose is required, please install it and start over. Aborting."; exit 1; }

# Check whether htpasswd is installed
command -v htpasswd >/dev/null 2>&1 || \
{ echo >&2 "htpasswd is required(apache2-utils), please install it and start over. Aborting."; exit 1; }

build() {
  docker-compose build $args 1>/dev/null || echo "docker images build failed"
}
start() {
  docker-compose build $args 1>/dev/null || echo "docker images build failed"
  docker-compose up -d
  cat .zbxweb
}
rerun() {
  docker-compose down
  docker volume rm glaber-docker_data_clickhouse  glaber-docker_data_mysql || true
  rm /tmp/files.changed
  docker-compose build $args 1>/dev/null
  docker-compose up -d
  cat .zbxweb
}
prune() {
  docker-compose down
  docker volume rm glaber-docker_data_clickhouse  glaber-docker_data_mysql || true
  rm /tmp/files.changed
}
remotebuild() {
  read -p "Are you sure than you are this repo admin [y/n] ? " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    tag=$(date '+%Y-%m-%d-%H-%M-%S')
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
  rerun)
    rerun
    ;;
  prune)
    prune
    ;;
  remotebuild)
    echo -n "Pushed to remote build branch"
    echo ""
    remotebuild
    
    ;;
  *)
    echo -n "unknown command"
    ;;
esac
