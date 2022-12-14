docker-compose down
docker-compose build
docker volume rm glaber-docker_data_clickhouse  glaber-docker_data_mysql    
docker-compose up
