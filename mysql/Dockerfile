FROM percona:8.0.29-21-centos
COPY create.sql /docker-entrypoint-initdb.d/create.sql
ENTRYPOINT ["/usr/bin/bash", "docker-entrypoint.sh", "--default-authentication-plugin=mysql_native_password","--character-set-server=utf8","--collation-server=utf8_bin"]
