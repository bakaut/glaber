FROM debian:bullseye
ARG GLABER_BUILD_VERSION
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y wget software-properties-common \
            nmap gnupg2 openssl ca-certificates \
            supervisor default-mysql-client \
            lsb-release apt-transport-https && \
    wget -qO - https://glaber.io/repo/key/repo.gpg | apt-key add - && \
    wget -qO - https://nginx.org/keys/nginx_signing.key | apt-key add - && \
    echo "deb [arch=amd64] https://glaber.io/repo/debian $(lsb_release -sc) main" >> /etc/apt/sources.list.d/glaber.list && \
    apt-get update && \
    apt-get install -y glaber-nginx-conf=1:$GLABER_BUILD_VERSION* && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
    apt-get autoremove --yes && \
    apt-get clean autoclean
COPY etc /etc/
RUN mkdir /run/php && chown www-data:www-data /run/php && \ 
    chown www-data:www-data /etc/zabbix/web/zabbix.conf.php && \
    mv /etc/docker-entrypoint.sh /usr/bin
VOLUME ["/etc/ssl/nginx"]
WORKDIR /usr/share/zabbix
EXPOSE 80/TCP 
ENTRYPOINT ["docker-entrypoint.sh"]
