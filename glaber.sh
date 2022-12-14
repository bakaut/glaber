#!/usr/bin/env bash
set -e

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
  docker-compose build
}
start() {
  docker-compose build
  docker-compose up -d
}
rerun() {
  docker-compose down
  docker volume rm glaber-docker_data_clickhouse  glaber-docker_data_mysql
  docker-compose build
  docker-compose up -d
}
prune() {
  docker-compose down
  docker volume rm glaber-docker_data_clickhouse  glaber-docker_data_mysql
}
remotebuild() {
  read -p "Are you sure than you are this repo admin [y/n] ? " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    git checkout -b build/$(date '+%Y-%m-%d')
    git push   
  fi
}

case $1 in
  build)
    echo -n "Build docker images and start glaber"
    build
    ;;
  start)
    echo -n "Build docker images and start glaber"
    start
    ;;
  rerun)
    echo -n "Completely remove glaber and start it again"
    rerun
    ;;
  prune)
    echo -n "Completely remove glaber installation"
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
