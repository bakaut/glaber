docker network create zabbix
cd mysql 
docker-compose build
docker-compose up -d
cd ../clickhouse
docker-compose build
docker-compose up -d
cd ../zabbix-cluster
docker-compose build
docker-compose up -d
cd ../zabbix-web
docker-compose build
docker-compose up -d