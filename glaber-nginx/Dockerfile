FROM debian:buster
ENV ZBX_BUILD_VERSION=4.0.4
ENV GLABER_BUILD_VERSION=2.16.3
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y wget software-properties-common \
            nmap gnupg2 openssl ca-certificates \
            lsb-release apt-transport-https && \
    wget -qO - https://glaber.io/repo/key/repo.gpg | apt-key add - && \
    wget -qO - https://nginx.org/keys/nginx_signing.key | apt-key add - && \
    wget -qO - https://packages.sury.org/php/apt.gpg | apt-key add - && \
    echo "deb [arch=amd64] https://glaber.io/repo/debian $(lsb_release -sc) main" >> /etc/apt/sources.list.d/glaber.list && \
    echo "deb [arch=amd64] https://packages.sury.org/php/ $(lsb_release -sc) main" >> /etc/apt/sources.list.d/sury.list && \
    echo "deb [arch=amd64] http://nginx.org/packages/debian $(lsb_release -sc) nginx" >> /etc/apt/sources.list.d/nginx.list && \
    apt-get update && \
    apt-get install -y glaber-nginx-conf=1:$GLABER_BUILD_VERSION* \                    
            zabbix-agent=1:$ZBX_BUILD_VERSION* \
            php7.4-bcmath php7.4-curl php7.4-fpm php7.4-gd \
            php7.4-json php7.4-ldap php7.4-mbstring php7.4-cgi \
            php7.4-mysql php7.4-odbc php7.4-opcache  \
            php7.4-snmp php7.4-soap php7.4-xml php7.4-xmlrpc \
            php7.4-xsl php7.4 supervisor default-mysql-client && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
    apt-get autoremove --yes && \
    apt-get clean autoclean
EXPOSE 80/TCP 

WORKDIR /usr/share/zabbix

VOLUME ["/etc/ssl/nginx"]

COPY ["etc/supervisor/", "/etc/supervisor/"]
COPY ["etc/php-fpm/php/7.4/fpm/conf.d/99-zabbix.ini", "/etc/php/7.4/fpm/conf.d/"]
COPY ["etc/php-fpm/php/7.4/fpm/pool.d/zabbix.conf", "/etc/php/7.4/fpm/pool.d/"]

COPY ["etc/nginx/nginx.conf", "/etc/nginx/nginx.conf"]
COPY ["etc/nginx/conf.d/default.conf", "/etc/nginx/conf.d/default.conf"]

COPY ["etc/zabbix/zabbix.conf.php", "/etc/zabbix/web/"]
COPY ["docker-entrypoint.sh", "/usr/bin/"]
RUN rm -rf /etc/php/7.4/fpm/pool.d/www.conf && \
    chown www-data:www-data /etc/zabbix/web/zabbix.conf.php && \
    sed -i "s/\/run\/php\/php7.4-fpm.pid/\/var\/run\/php7.4-fpm.sock/g" /etc/php/7.4/fpm/php-fpm.conf && \
    chown www-data:www-data -R  /usr/share/zabbix/ && \
    mkdir /tmp/php7 && chown www-data:www-data -R  /tmp/php7
ENTRYPOINT ["bash","/usr/bin/docker-entrypoint.sh"]
