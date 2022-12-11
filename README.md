# Dockerized [glaber](https://glaber.io/) 2.16.3 version


## What is it?

### Dockrized [glaber](https://glaber.io/) version.

Using for testing deploynemt of glaber. Glaber is zabbix server fork.

Main differences from zabbix-server:
- Async zabbix pollers. x100 speed, x10 low CPU and MEMORY
- Clickhouse as history storage. 
    - x10 lower system resources for history tables (CPU, MEMORY)
    - x20 lower disk usage.
- Native zabbix cluster mode support.

## Components 

- Zabbix cluster. 3 zabbix-server nodes.
- Clickhouse. Standalong mode.
- Mysql. Standalong mode.

## Prerequisite
- git
- Docker >=17.12.0 
- Docker-compose
- Clickhouse image version >=20.1

### Run it
```bash
git clone git@github.com:bakaut/glaber.git .
bash run.sh
# wait for a 7 minutes (depends on your system perfomance and internet connection speed) and use
http://127.0.0.1  Admin,zabbix
```

### Default credentials

- Zabbix web. http://127.0.0.1. Admin,zabbix
- Mysql server. Db,User,Pass - zabbix,zabbix,zabbix
- Clickhouse. Db,User,Pass - zabbix,default,zabbix


### Cleanup
```bash
bash remove.sh
```

## Default ENV variables

zabbix-web

```bash
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
```

zabbix-server
```bash
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
```
