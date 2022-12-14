#!/usr/bin/env bash
set -e -x

# Script trace mode
if [ "${DEBUG_MODE}" == "true" ]; then
    set -o xtrace
fi

sed -i -e "s/glaber/${ZBX_CH_DB:-"glaber"}/g" \
       -e "s/6 MONTH/${ZBX_CH_RETENTION:-"30 DAY"}/g" \
       /root/history.sql

sed -i "s/>zabbix</>${ZBX_CH_PASS:-"zabbix"}</g" /etc/clickhouse-server/users.xml

if [ ! -f exist.database ]; then
  clickhouse-client \
    --user ${ZBX_CH_USER} --password ${ZBX_CH_PASS} \
    --multiquery < /root/history.sql
  touch exist.database
fi


