#!/usr/bin/env bash

set -eo pipefail


ZBX_HISTORY_MODULE_URL=${ZBX_HISTORY_MODULE}';{"url":"http://'${ZBX_CH_SERVER}':'${ZBX_CH_PORT}'", "username":"'${ZBX_CH_USER}'", "password":"'${ZBX_CH_PASS}'", "dbname":"'${ZBX_CH_DB}'",  "disable_reads":'${ZBX_HISTORY_MODULE_DISABLE_READS}', "timeout":'${ZBX_HISTORY_MODULE_TIMEOUT}' }'


sed -i  -e "s/zabbix-server-name/$ZBX_SERVER_NAME/g" \
        -e "s/# DBHost=localhost/DBHost=$MYSQL_HOST/g" \
        -e "s/DBUser=zabbix/DBUser=$MYSQL_USER/g" \
        -e "s/# DBPassword=/DBPassword=$MYSQL_PASSWORD/g" \
        -e "s/# DBPort=/DBPort=$MYSQL_PORT/g" \
        -e "s/DBName=zabbix/DBName=$MYSQL_DATABASE/g" \
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