FROM yandex/clickhouse-server:21.3.20
ENV ZBX_CH_DB="zabbix"
ENV ZBX_CH_RETENTION="30 DAY"
ENV ZBX_CH_PASS="zabbix"
COPY history.sql /root/history.sql
RUN  sed -i "s/glaber/${ZBX_CH_DB}/g" /root/history.sql
RUN  sed -i "s/6 MONTH/${ZBX_CH_RETENTION}/g" /root/history.sql
COPY users.xml  /etc/clickhouse-server/users.xml
RUN  sed -i "s/>zabbix</>${ZBX_CH_PASS}</g" /etc/clickhouse-server/users.xml
COPY metrika.xml /etc/metrika.xml
COPY init.sh /docker-entrypoint-initdb.d/
