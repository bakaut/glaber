# https://hub.docker.com/_/percona
FROM percona:8.0.29-21-centos
COPY schema.sql images.sql data.sql /tmp/
RUN cat /tmp/schema.sql > /docker-entrypoint-initdb.d/create.sql && \
    cat /tmp/images.sql >> /docker-entrypoint-initdb.d/create.sql && \
    cat /tmp/data.sql >> /docker-entrypoint-initdb.d/create.sql
