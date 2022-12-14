#!/usr/bin/env bash

set -eo pipefail


# Script trace mode
if [ "${DEBUG_MODE}" == "true" ]; then
    set -o xtrace
fi


ZBX_HISTORY_MODULE_URL=${ZBX_HISTORY_MODULE}';{"url":"http://'${ZBX_CH_SERVER}':'${ZBX_CH_PORT}'", "username":"'${ZBX_CH_USER}'", "password":"'${ZBX_CH_PASS}'", "dbname":"'${ZBX_CH_DB}'",  "disable_reads":100, "timeout":10 }'


sed -i -e "s/zabbix-server-name/$ZBX_SERVER_NAME/g" \
       -e "s/# DBHost=localhost/DBHost=$ZBX_MYSQL_HOST/g" \
       -e "s/DBUser=zabbix/DBUser=$ZBX_MYSQL_USER/g" \
       -e "s/# DBPassword=/DBPassword=$ZBX_MYSQL_PASS/g" \
       -e "s/# DBPort=/DBPort=$ZBX_MYSQL_PORT/g" \
       -e "s/DBName=zabbix/DBName=$ZBX_MYSQL_DB/g" \
       -e "s/history_db_type/$ZBX_HISTORY_MODULE/g" \
       -e "s/history_db_dns_name/$ZBX_CH_SERVER/g" \
       -e "s/history_db_port/$ZBX_CH_PORT/g" \
       -e "s/history_db_user/$ZBX_CH_USER/g" \
       -e "s/history_db_pass/$ZBX_CH_PASS/g" \
       -e "s/history_db_name/$ZBX_CH_DB/g" \
       "$ZBX_SERVER_CONF"

touch /var/log/zabbix/zabbix_server.log && \
chown zabbix:zabbix /var/log/zabbix/zabbix_server.log
tail -f /var/log/zabbix/zabbix_server.log &

/usr/sbin/zabbix_server -f -c /etc/zabbix/zabbix_server.conf