FROM debian:bullseye
ARG GLABER_BUILD_VERSION
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN apt-get update && \
    apt-get install -y wget software-properties-common \
            nmap gnupg2 openssl ca-certificates \
            supervisor default-mysql-client \
            lsb-release apt-transport-https locales && \
    wget -qO - https://glaber.io/repo-testing/key/repo.gpg | apt-key add - && \
    wget -qO - https://nginx.org/keys/nginx_signing.key | apt-key add - && \
    echo "deb [arch=amd64] https://glaber.io/repo-testing/debian $(lsb_release -sc) main" >> /etc/apt/sources.list.d/glaber.list && \
    apt-get update && \
    apt-cache show glaber-nginx-conf && \
    apt-get install -y glaber-nginx-conf=1:$GLABER_BUILD_VERSION* && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
    apt-get autoremove --yes && \
    apt-get clean autoclean && \
    sed -i -e '/en_US.UTF-8/s/^# //g' \
           -e '/ru_RU.UTF-8/s/^# //g' \
    /etc/locale.gen && \
    locale-gen
COPY etc /etc/
RUN mkdir /run/php && chown www-data:www-data /run/php && \ 
    chown www-data:www-data /etc/zabbix/web/zabbix.conf.php && \
    mv /etc/docker-entrypoint.sh /usr/bin && \
    sed -i -e "s/#        listen          80;/    listen          80;/g" \
           -e "s/#        server_name     example.com;/    server_name     _;/g" \
    /etc/nginx/conf.d/zabbix.conf
VOLUME ["/etc/ssl/nginx"]
WORKDIR /usr/share/zabbix
EXPOSE 80/TCP 
ENTRYPOINT ["docker-entrypoint.sh"]
