#!/bin/bash
set -e 

ZBX_CH_DB=${ZBX_CH_DB:-"glaber"}
ZBX_CH_USER=${ZBX_CH_USER:-"default"}
ZBX_CH_PASS=${ZBX_CH_PASS:-"zabbix"}

if [ ! -f exist.database ]; then
  clickhouse-client \
    --user ${ZBX_CH_USER} --password ${ZBX_CH_PASS} \
    --multiquery < /root/history.sql
  touch exist.database
fi


