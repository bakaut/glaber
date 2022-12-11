#!/bin/bash

set -eo pipefail

set +e

# Script trace mode
if [ "${DEBUG_MODE}" == "true" ]; then
    set -o xtrace
fi


ZBX_SERVER_CONF=${ZBX_SERVER_CONF:-"/etc/zabbix/zabbix_server.conf"}
ZBX_SERVER_NAME=${ZBX_SERVER_NAME:-"zabbix-server"}
ZBX_SERVER_PORT=${ZBX_SERVER_PORT:-"10051"}

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

ZBX_HISTORY_MODULE=${ZBX_HISTORY_MODULE:-"clickhouse"}
ZBX_HISTORY_MODULE_URL=${ZBX_HISTORY_MODULE}';{"url":"http://'${ZBX_CH_SERVER}':'${ZBX_CH_PORT}'", "username":"'${ZBX_CH_USER}'", "password":"'${ZBX_CH_PASS}'", "dbname":"'${ZBX_CH_DB}'",  "disable_reads":100, "timeout":10 }'


sed -i "s/zabbix-server-name/$ZBX_SERVER_NAME/g" "$ZBX_SERVER_CONF"
sed -i "s/# DBHost=localhost/DBHost=$ZBX_MYSQL_HOST/g" "$ZBX_SERVER_CONF"
sed -i "s/DBUser=zabbix/DBUser=$ZBX_MYSQL_USER/g" "$ZBX_SERVER_CONF"
sed -i "s/# DBPassword=/DBPassword=$ZBX_MYSQL_PASS/g" "$ZBX_SERVER_CONF"
sed -i "s/# DBPort=/DBPort=$ZBX_MYSQL_PORT/g" "$ZBX_SERVER_CONF"
sed -i "s/DBName=zabbix/DBName=$ZBX_MYSQL_DB/g" "$ZBX_SERVER_CONF"

sed -i "s/history_db_type/$ZBX_HISTORY_MODULE/g" "$ZBX_SERVER_CONF"
sed -i "s/history_db_dns_name/$ZBX_CH_SERVER/g" "$ZBX_SERVER_CONF"
sed -i "s/history_db_port/$ZBX_CH_PORT/g" "$ZBX_SERVER_CONF"
sed -i "s/history_db_user/$ZBX_CH_USER/g" "$ZBX_SERVER_CONF"
sed -i "s/history_db_pass/$ZBX_CH_PASS/g" "$ZBX_SERVER_CONF"
sed -i "s/history_db_name/$ZBX_CH_DB/g" "$ZBX_SERVER_CONF"

touch /var/log/zabbix/zabbix_server.log && \
chown zabbix:zabbix /var/log/zabbix/zabbix_server.log
tail -f /var/log/zabbix/zabbix_server.log &

/usr/sbin/zabbix_server -f -c /etc/zabbix/zabbix_server.conf