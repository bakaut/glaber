# Dockerized [glaber](https://glaber.io/)

Glaber is zabbix server fork.

Versions:
- glaber     - 2.16.9
- zabbix     - 5.4.11
- mysql      - percona:8.0.29-21-centos
- clickhouse - clickhouse-server:21.3.20

Used for testing deployment of glaber. 

Main differences from zabbix-server:
- Async zabbix pollers. x100 speed, x10 low CPU and MEMORY
- Clickhouse as history storage backend. 
    - x10 lower system resources for history tables (CPU, MEMORY)
    - x20 lower disk usage.

## Components 

- glaber server
- glaber nginx
- clickhouse as history storage backend
- mysql as main database backend

## Prerequirements
- git
- docker >=17.12.0 
- docker-compose
- clickhouse version >=20.1
- php and php-fpm version in glaber nginx >=7.2 and <8

### Using
```bash
git clone git@github.com:bakaut/glaber.git .
./glaber.sh 
Usage: ./glaber.sh <action>

./glaber.sh build - Build docker images
./glaber.sh start - Build docker images and start glaber
./glaber.sh rerun - Completely remove glaber and start it again
./glaber.sh prune - Completely remove glaber installation
./glaber.sh remotebuild - Remote rebuild github glaber images (only admins)
# wait for a 7 minutes (depends on your system perfomance and internet connection speed) and use it
http://127.0.0.1  Admin,`<random generated password>`
```

### Default credentials

- Zabbix web. http://127.0.0.1. Admin,zabbix,`<random generated>`
- Mysql server. Db,User,Pass - zabbix,zabbix,`<random generated>`
- Clickhouse. Db,User,Pass - zabbix,defaultuser,`<random generated>`

### After success  build:
- Zabbix web Admin password located in `.zbxweb` and displayed to stdout
- All passwords variables updated in `.env` file
## Default ENV variables

See `.env` file