#!/usr/bin/env bash

set -eo pipefail

# change zabbix web config
sed -i \
    -e "s/{MYSQL_HOST}/${MYSQL_HOST}/g" \
    -e "s/{MYSQL_PORT}/${MYSQL_PORT}/g" \
    -e "s/{MYSQL_DATABASE}/${MYSQL_DATABASE}/g" \
    -e "s/{MYSQL_USER}/${MYSQL_USER}/g" \
    -e "s/{MYSQL_PASSWORD}/${MYSQL_PASSWORD}/g" \
    -e "s/{ZBX_SERVER_PORT}/${ZBX_SERVER_PORT}/g" \
    -e "s/{ZBX_SERVER_NAME}/${ZBX_SERVER_NAME}/g" \
    -e "s/{ZBX_CH_DB}/${ZBX_CH_DB}/g" \
    -e "s/{ZBX_CH_URL}/http\:\/\/${ZBX_CH_SERVER}:${ZBX_CH_PORT}/g" \
    -e "s/{ZBX_CH_USER}/${ZBX_CH_USER}/g" \
    -e "s/{ZBX_CH_PASS}/${ZBX_CH_PASS}/g" \
    -e "s/{ZBX_HISTORY_MODULE}/${ZBX_HISTORY_MODULE}/g" \
"$ZBX_WEB_CONFIG"

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf