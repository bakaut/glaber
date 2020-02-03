cd mysql 
docker-compose down
cd ../clickhouse
docker-compose down
cd ../zabbix-cluster
docker-compose down
cd ../zabbix-web
docker-compose down
docker volume prune --force
docker network rm zabbix
