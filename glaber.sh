#!/usr/bin/env bash
set -e 

export args=" --build-arg GLABER_BUILD_VERSION=$(cat glaber.version)"

get-password() {
 base64 < /dev/urandom | head -c12 | tr -d \\ |  tr -d \/
}

set-password() {
  if [ ! -f /tmp/passwords.changed ]; then
    ZBX_CH_PASS=$(get-password)
    sed -i -e "s/MYSQL_PASSWORD.*/MYSQL_PASSWORD=$(get-password)/" \
           -e "s/ZBX_CH_PASS.*/ZBX_CH_PASS=$ZBX_CH_PASS/" \
           -e "s/MYSQL_ROOT_PASSWORD.*/MYSQL_ROOT_PASSWORD=$(get-password)/" \
    .env
    sed -i "s/></>$ZBX_CH_PASS</" clickhouse/users.xml
    touch /tmp/passwords.changed
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

build() {
  set-password
  docker-compose build $args
}
start() {
  docker-compose build $args
  docker-compose up -d
}
rerun() {
  docker-compose down
  docker volume rm glaber-docker_data_clickhouse  glaber-docker_data_mysql || true
  docker-compose build $args
  docker-compose up -d
}
prune() {
  docker-compose down
  docker volume rm glaber-docker_data_clickhouse  glaber-docker_data_mysql || true
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
