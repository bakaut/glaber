FROM alpine:3.17.0 as builder
COPY schema.sql images.sql data.sql /root/
RUN cat /root/schema.sql > /root/create.sql && \
    cat /root/images.sql >> /root/create.sql && \
    cat /root/data.sql >> /root/create.sql

FROM mysql:8
COPY --from=builder /root/create.sql /docker-entrypoint-initdb.d/
RUN echo '[mysqld]' >> /etc/mysql/conf.d/docker.cnf
RUN echo 'default_authentication_plugin= mysql_native_password' >> /etc/mysql/conf.d/docker.cnf
