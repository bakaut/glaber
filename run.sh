cd mysql 
docker-compose up -d
cd ../clickhouse
docker-compose up -d
cd ../zabbix-cluster
docker-compose up -d
cd ../zabbix-web
docker-compose up -d