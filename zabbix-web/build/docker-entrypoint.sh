#!/bin/bash

set -eo pipefail

set +e

# Script trace mode
if [ "${DEBUG_MODE}" == "true" ]; then
    set -o xtrace
fi

ZBX_WEB_CONFIG=${ZBX_WEB_CONFIG:-"/etc/zabbix/web/zabbix.conf.php"}

ZBX_SERVER_NAME=${ZBX_SERVER_NAME:-"Glaber server"}
ZBX_SERVER_PORT=${ZBX_SERVER_PORT:-"10051"}
ZBX_SERVER_HOST=${ZBX_SERVER_HOST:-"zabbix"}

ZBX_MYSQL_HOST=${ZBX_MYSQL_HOST:-"127.0.0.1"}
ZBX_MYSQL_DB=${ZBX_MYSQL_DB:-"zabbix"}
ZBX_MYSQL_USER=${ZBX_MYSQL_USER:-"zabbix"}
ZBX_MYSQL_PASS=${ZBX_MYSQL_PASS:-"zabbix"}
ZBX_MYSQL_PORT=${ZBX_MYSQL_PORT:-"3306"}

ZBX_CH_SERVER=${ZBX_CH_SERVER:-"127.0.0.1"}
ZBX_CH_PORT=${ZBX_CH_PORT:-"8123"}
ZBX_CH_DB=${ZBX_CH_DB:-"zabbix"}
ZBX_CH_USER=${ZBX_CH_USER:-"default"}
ZBX_CH_PASS=${ZBX_CH_PASS:-"zabbix"}

sed -i \
    -e "s/{ZBX_MYSQL_HOST}/${ZBX_MYSQL_HOST}/g" \
    -e "s/{ZBX_MYSQL_PORT}/${ZBX_MYSQL_PORT}/g" \
    -e "s/{ZBX_MYSQL_DB}/${ZBX_MYSQL_DB}/g" \
    -e "s/{ZBX_MYSQL_USER}/${ZBX_MYSQL_USER}/g" \
    -e "s/{ZBX_MYSQL_PASS}/${ZBX_MYSQL_PASS}/g" \
    -e "s/{ZBX_SERVER_HOST}/${ZBX_SERVER_HOST}/g" \
    -e "s/{ZBX_SERVER_PORT}/${ZBX_SERVER_PORT}/g" \
    -e "s/{ZBX_SERVER_NAME}/${ZBX_SERVER_NAME}/g" \
    -e "s/{ZBX_CH_DB}/${ZBX_CH_DB}/g" \
    -e "s/{ZBX_CH_URL}/http\:\/\/${ZBX_CH_SERVER}:${ZBX_CH_PORT}/g" \
    -e "s/{ZBX_CH_USER}}/${ZBX_CH_USER}/g" \
    -e "s/{ZBX_CH_PASS}/${ZBX_CH_PASS}/g" \
"$ZBX_WEB_CONFIG"

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf