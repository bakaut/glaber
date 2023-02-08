#!/usr/bin/env bash
set -e

if [ ! -f database.exist ]; then

  wget -q https://gitlab.com/mikler/glaber/-/raw/${GLABER_BRANCH}/database/clickhouse/history.sql

  sed -i -e "s/glaber/${ZBX_CH_DB}/g" \
         -e "s/6 MONTH/${ZBX_CH_RETENTION}/g" \
         history.sql
  
# File users.xml should be defined before init.sh script
# Redefine with .env file works with .glaber.sh script at prebuild stage
# May be use bitnami image https://hub.docker.com/r/bitnami/clickhouse/

  clickhouse-client \
    --user ${ZBX_CH_USER} --password ${ZBX_CH_PASS} \
    --multiquery < history.sql

  touch database.exist
fi

## for debug
# tail -f /var/log/clickhouse-server/clickhouse-server.log &
# tail -f /var/log/clickhouse-server/clickhouse-server.err.log &
