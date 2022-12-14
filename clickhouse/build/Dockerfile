FROM yandex/clickhouse-server:21.3.20
COPY history.sql /root/history.sql
COPY users.xml  /etc/clickhouse-server/users.xml
COPY metrika.xml /etc/metrika.xml
COPY init.sh /docker-entrypoint-initdb.d/
