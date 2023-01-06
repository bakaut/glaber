#!/usr/bin/env bash

set -eo pipefail


ZBX_HISTORY_MODULE_URL=${ZBX_HISTORY_MODULE}';{"url":"http://'${ZBX_CH_SERVER}':'${ZBX_CH_PORT}'", "username":"'${ZBX_CH_USER}'", "password":"'${ZBX_CH_PASS}'", "dbname":"'${ZBX_CH_DB}'",  "disable_reads":'${ZBX_HISTORY_MODULE_DISABLE_READS}', "timeout":'${ZBX_HISTORY_MODULE_TIMEOUT}' }'

sed -i  -e "s/DBHost=localhost/DBHost=$MYSQL_HOST/g" \
        -e "s/DBUser=glaber/DBUser=$MYSQL_USER/g" \
        -e "s/DBPassword=<DB_PASSWORD>/DBPassword=$MYSQL_PASSWORD/g" \
        -e "s/DBName=glaber/DBName=$MYSQL_DATABASE/g" \
        -e "s/clickhouse;/$ZBX_HISTORY_MODULE;/g" \
        -e "s/127.0.0.1/$ZBX_CH_SERVER/g" \
        -e "s/8123/$ZBX_CH_PORT/g" \
        -e "s/\"default\"/\"$ZBX_CH_USER\"/g" \
        -e "s/\"password\"\,/\"$ZBX_CH_PASS\"\,/g" \
        -e "s/\"glaber\"/\"$ZBX_CH_DB\"/g" \
        -e "s/DebugLevel=3/DebugLevel=$ZBX_SERVER_DEBUG_LEVEL/g" \
    "$ZBX_SERVER_CONF"

echo "CacheSize=$ZBX_SERVER_CACHE_SIZE" >> $ZBX_SERVER_CONF

touch /var/log/zabbix/zabbix_server.log && \
chown zabbix:zabbix /var/log/zabbix/zabbix_server.log
tail -f /var/log/zabbix/zabbix_server.log &

/usr/sbin/zabbix_server -f -c /etc/zabbix/zabbix_server.conf