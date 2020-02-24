FROM yandex/clickhouse-server
COPY init.sh /docker-entrypoint-initdb.d/
COPY users.xml  /etc/clickhouse-server/users.xml
COPY metrika.xml /etc/metrika.xml