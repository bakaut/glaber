FROM yandex/clickhouse-server:21.3.20
COPY history.sql users.xml init.sh /tmp/glaber/
RUN mv /tmp/glaber/history.sql /root/history.sql && \
    mv /tmp/glaber/users.xml /etc/clickhouse-server/users.xml && \
    mv /tmp/glaber/init.sh /docker-entrypoint-initdb.d/init.sh
COPY conf.d/* /etc/clickhouse-server/config.d/