# Dockerized [glaber](https://glaber.io/)

Glaber is zabbix server fork.

Versions:
- glaber     - 2.18.0
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
- mysql as the main database backend

## Prerequirements
- docker >=17.12.0 
- docker-compose
- apache2-utils
- clickhouse image version >=20.1
- php and php-fpm version in glaber-nginx image >=7.2 and <8

### Using
```bash
git clone git@github.com:bakaut/glaber.git .
./glaber.sh 
Usage: ./glaber.sh <action>
./glaber.sh build    - Build docker images
./glaber.sh start    - Build docker images and start glaber
./glaber.sh stop     - Stop glaber containers
./glaber.sh recreate - Completely remove glaber and start it again
./glaber.sh remove   - Completely remove glaber installation
./glaber.sh diag     - Collect glaber start logs and some base system info to the file
```

### Default credentials

- Zabbix web. http://127.0.0.1 - Admin,`<random generated>`
- Mysql server. Db,User,Pass   - zabbix,zabbix,`<random generated>`
- Clickhouse. Db,User,Pass     - zabbix,defaultuser,`<random generated>`

### After success  build:
- Zabbix web Admin password located in `.zbxweb` and displayed to stdout
- All passwords variables are updated in `.env`` file
## Default ENV variables

See `.env` file