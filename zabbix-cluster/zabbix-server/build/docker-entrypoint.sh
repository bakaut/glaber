#!/bin/bash

set -eo pipefail

set +e

# Script trace mode
if [ "${DEBUG_MODE}" == "true" ]; then
    set -o xtrace
fi

ZBX_USE_ASYNC_POLLER=${ZBX_CH_PORT:-"NO"}
ZBX_USE_CH=${ZBX_USE_CH:-"NO"}
ZBX_USE_NMAP=${ZBX_USE_NMAP:-"NO"}
ZBX_USE_CH_PRELOAD=${ZBX_USE_CH_PRELOAD:-"NO"}
ZBX_USE_CH_WARM_UP_CACHE=${ZBX_USE_CH_WARM_UP_CACHE:-"NO"}


ZBX_SERVER_CONF=${ZBX_SERVER_CONF:-"/etc/zabbix/zabbix_server.conf"}
ZBX_SERVER_NAME=${ZBX_SERVER_NAME:-"zabbix-server"}
ZBX_SERVER_ID=${ZBX_SERVER_ID:-"1"}
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
ZBX_CH_DISABLE_NS=${ZBX_CH_DISABLE_NS:-"NO"}


ZBX_ASYNC_SNMP=${ZBX_ASYNC_SNMP:-"5"}
ZBX_ASYNC_POLLER=${ZBX_ASYNC_SNMP:-"5"}

ZBX_CH_PRELOAD_VALUES=${ZBX_CH_PRELOAD_VALUES:-"8"}

ZBX_WARM_UP_CACHE_SEC=${ZBX_WARM_UP_CACHE_SEC:-"300"}


sed -i "s/zabbix-server-name/$ZBX_SERVER_NAME/g" "$ZBX_SERVER_CONF"
sed -i "s/ServerID=1/ServerID=$ZBX_SERVER_ID/g" "$ZBX_SERVER_CONF"
sed -i "s/# DBHost=localhost/DBHost=$ZBX_MYSQL_HOST/g" "$ZBX_SERVER_CONF"

if [[ "$ZBX_USE_CH_WARM_UP_CACHE" != "NO" ]]; then
	sed -i "s/#ClickHouseCacheFillTime=300/ClickHouseCacheFillTime=$ZBX_WARM_UP_CACHE_SEC/g" "$ZBX_SERVER_CONF"

fi

if [[ "$ZBX_USE_ASYNC_POLLER" != "NO" ]]; then
	sed -i "s/#StartPollersAsyncSNMP=10/StartPollersAsyncSNMP=$ZBX_ASYNC_SNMP/g" "$ZBX_SERVER_CONF"
    sed -i "s/#StartPollersAsyncAGENT=10/#StartPollersAsyncAGENT=$ZBX_ASYNC_POLLER/g" "$ZBX_SERVER_CONF"
fi

if [[ "$ZBX_USE_NMAP" != "NO" ]]; then
	sed -i "s/#NmapParams=/NmapParams=/g" "$ZBX_SERVER_CONF"
fi


if [[ "$ZBX_USE_CH" != "NO" ]]; then
    sed -i "s/#HistoryStorageType=clickhouse/HistoryStorageType=clickhouse/g" "$ZBX_SERVER_CONF"
    sed -i "s/#HistoryStorageURL=http\:\/\/127.0.0.1:8123/HistoryStorageURL=http\:\/\/$ZBX_CH_SERVER:$ZBX_CH_PORT/g" "$ZBX_SERVER_CONF"
    sed -i "s/#HistoryStorageDBName=zabbix/HistoryStorageDBName=$ZBX_CH_DB/g" "$ZBX_SERVER_CONF"
    sed -i "s/#HistoryStorageTypes=/HistoryStorageTypes=/g" "$ZBX_SERVER_CONF"

    sed -i "s/#ClickHouseUsername=default/ClickHouseUsername=$ZBX_CH_USER/g" "$ZBX_SERVER_CONF"
    sed -i "s/#ClickHousePassword=123456/ClickHousePassword=$ZBX_CH_PASS/g" "$ZBX_SERVER_CONF"

    if [[ "$ZBX_CH_DISABLE_NS" != "NO" ]]; then
        sed -i "s/#ClickHouseDisableNanoseconds=1/ClickHouseDisableNanoseconds=1/g" "$ZBX_SERVER_CONF"
    fi
fi

if [[ "$ZBX_USE_CH_PRELOAD" != "NO" ]]; then
    sed -i "s/#ClickHousePreloadValues=8/ClickHousePreloadValues=$ZBX_CH_PRELOAD_VALUES/g" "$ZBX_SERVER_CONF"
fi


sed -i "s/DBUser=zabbix/DBUser=$ZBX_MYSQL_USER/g" "$ZBX_SERVER_CONF"
sed -i "s/# DBPassword=/DBPassword=$ZBX_MYSQL_PASS/g" "$ZBX_SERVER_CONF"
sed -i "s/# DBPort=/DBPort=$ZBX_MYSQL_PORT/g" "$ZBX_SERVER_CONF"
sed -i "s/DBName=zabbix/DBName=$ZBX_MYSQL_DB/g" "$ZBX_SERVER_CONF"

touch /var/log/zabbix/zabbix_server.log && \
chown zabbix:zabbix /var/log/zabbix/zabbix_server.log
tail -f /var/log/zabbix/zabbix_server.log &

/usr/sbin/zabbix_server -f -c /etc/zabbix/zabbix_server.conf

