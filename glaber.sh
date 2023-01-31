#!/usr/bin/env bash
set -e

# functions
apitest () {
  info "Install hurl for testing glaber"
  [ -d ".tmp/hurl-$HURL_VERSION" ] || \
  curl -sL https://github.com/Orange-OpenSource/hurl/releases/download/\
$HURL_VERSION/hurl-$HURL_VERSION-x86_64-linux.tar.gz | \
  tar xvz -C .tmp/ 1>/dev/null
  info "Testing that glaber-server is runing"
  .tmp/hurl-$HURL_VERSION/hurl  -o .tmp/hurl.log \
    --variables-file=.github/workflows/test/.hurl \
    --retry --retry-max-count 20 --retry-interval 15000 \
    .github/workflows/test/glaber-runing.hurl
}
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
}
info () {
  local message=$1
  echo $(date --rfc-3339=seconds) $message
}
wait () {
  info "Waiting zabbix to start..."
  apitest && info "Success" && info "$(cat .zbxweb)" || \
  info "Zabbix start failed.Timeout 5 minutes reached" && \
  info "Please try to open zabbix url with credentials:" && \
  info "$(cat .zbxweb)" \
  info "If not success, please run diagnostics ./glaber.sh diag" && \
  exit 1
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
    echo "user=Admin" > .github/workflows/test/.hurl
    echo "pass=$ZBX_WEB_ADMIN_PASS" >> .github/workflows/test/.hurl
    echo "port=${ZBX_PORT:-80}" >> .github/workflows/test/.hurl
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
build() {
  [ -d "glaber-server/workers_script/" ] || mkdir -p glaber-server/workers_script/
  [ -d ".tmp/diag/" ] || mkdir -p .tmp/diag/
  [ -d ".mysql/mysql_data/" ] || \
  sudo install -d -o 1001 -g 1001 mysql/mysql_data/
  [ -d ".clickhouse/clickhouse_data/" ] || \
  sudo install -d -o 101 -g 103 clickhouse/clickhouse_data
  docker-compose pull 1>.tmp/diag/docker-build.log
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
  read -p "Are you sure to completely remove glaber with database [y/n] ? " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    rm .passwords.created .zbxweb .github/workflows/test/.hurl || true
    sudo rm -rf  mysql/mysql_data/ clickhouse/clickhouse_data
    git-reset-variables-files
  fi
}
recreate() {
  remove
  start
}
remote-docker() {
  current_branch=$(git rev-parse --abbrev-ref HEAD)
  tag=$GLABER_BUILD_VERSION-$(date '+%Y-%m-%d-%H-%M')
  git-reset-variables-files
  git add .
  git commit -m "build auto commit"
  git checkout -b build/$tag
  git push --set-upstream origin build/$tag
  git checkout $current_branch
  echo -n "Pushed to remote build branch"
}
remote-packer() {
  current_branch=$(git rev-parse --abbrev-ref HEAD)
  tag=$GLABER_BUILD_VERSION-$(date '+%Y-%m-%d-%H-%M')
  git-reset-variables-files
  git add .
  git commit -m "build auto commit"
  git checkout -b packer/$tag
  git push --set-upstream origin packer/$tag
  git checkout $current_branch
  echo -n "Pushed to remote packer branch"
}

# variables
export GLABER_BUILD_VERSION=$(cat glaber.version)
export args=" --build-arg GLABER_BUILD_VERSION=$GLABER_BUILD_VERSION"
export HURL_VERSION="1.8.0"
# export ZBX_PORT=8050

# main part
[ $# -ne 1 ] && (usage && exit 1)

# Check whether docker-compose is installed
command -v docker-compose >/dev/null 2>&1 || \
{ echo >&2 "docker-compose is required, please install it and start over. Aborting."; exit 1; }

# Check whether htpasswd is installed
command -v htpasswd >/dev/null 2>&1 || \
{ echo >&2 "htpasswd is required(apache2-utils), please install it and start over. Aborting."; exit 1; }

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
  remote-docker)
    remote-docker
    ;;
  remote-packer)
    remote-packer
    ;;
  diag)
    diag
    ;;
  test)
    apitest
    ;;
  *)
    echo -n "unknown command"
    ;;
esac
