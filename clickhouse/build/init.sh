#!/usr/bin/env bash
set -e -x

if [ ! -f exist.database ]; then

  sed -i -e "s/glaber/${ZBX_CH_DB}/g" \
         -e "s/6 MONTH/${ZBX_CH_RETENTION}/g" \
         /root/history.sql
  
#  sed -i -e "s/zabbixpassword/${ZBX_CH_PASS}s/g" \
#         -e "s/defaultuser/${ZBX_CH_USER}/g" \
#         /etc/clickhouse-server/users.xml
# Need to create zabbix user and password.
# File users.xml should be defined before init.sh script
# Redefine with .env file not work for now
# Used user defined in users.xml
# May be use bitnami image https://hub.docker.com/r/bitnami/clickhouse/

  clickhouse-client \
    --user ${ZBX_CH_USER} --password ${ZBX_CH_PASS} \
    --multiquery < /root/history.sql

  touch exist.database
fi

# tail -f /var/log/clickhouse-server/clickhouse-server.log &
# tail -f /var/log/clickhouse-server/clickhouse-server.err.log &
