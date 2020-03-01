FROM debian:buster
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install wget curl \
    software-properties-common nmap wget  gnupg2  openssl lsb-release apt-transport-https \
    openssl ca-certificates -y && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
    apt-get autoremove --yes && \
    apt-get clean autoclean
RUN wget https://glaber.io/repo/key/repo.gpg && \
    apt-key add repo.gpg && rm repo.gpg && \
    echo "deb [arch=amd64] https://glaber.io/repo/debian $(lsb_release -sc) main" >> /etc/apt/sources.list.d/glaber.list && \
    echo "deb [arch=amd64] https://repo.utelecom.com.ua/debian $(lsb_release -sc) main" >> /etc/apt/sources.list.d/glaber.list
RUN echo "deb http://nginx.org/packages/debian `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list && \
    curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
RUN apt-get update && apt-get install nginx zabbix-frontend-php=1:${ZBX_BUILD_VERSION}-1+glaber~${GLABER_BUILD_VERSION} \
                   php7.3-bcmath php7.3-curl php7.3-fpm php7.3-gd \
                   php7.3-json php7.3-ldap php7.3-mbstring php7.3-cgi \
                   php7.3-mysql php7.3-odbc php7.3-opcache  \
                   php7.3-snmp php7.3-soap php7.3-xml php7.3-xmlrpc \
                   php7.3-xsl php7.3 supervisor default-mysql-client -y && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
    apt-get autoremove --yes && \
    apt-get clean autoclean
EXPOSE 80/TCP 

WORKDIR /usr/share/zabbix

VOLUME ["/etc/ssl/nginx"]

COPY ["etc/supervisor/", "/etc/supervisor/"]
COPY ["etc/php-fpm/php/7.3/fpm/conf.d/99-zabbix.ini", "/etc/php/7.3/fpm/conf.d/"]
COPY ["etc/php-fpm/php/7.3/fpm/pool.d/zabbix.conf", "/etc/php/7.3/fpm/pool.d/"]

COPY ["etc/nginx/nginx.conf", "/etc/nginx/nginx.conf"]
COPY ["etc/nginx/conf.d/default.conf", "/etc/nginx/conf.d/default.conf"]

COPY ["etc/zabbix/zabbix.conf.php", "/etc/zabbix/web/"]
COPY ["docker-entrypoint.sh", "/usr/bin/"]
RUN useradd zabbix && \
    rm -rf /etc/php/7.3/fpm/pool.d/www.conf && \
    chown www-data:www-data /etc/zabbix/web/zabbix.conf.php && \
    sed -i "s/\/run\/php\/php7.3-fpm.pid/\/var\/run\/php7.3-fpm.sock/g" /etc/php/7.3/fpm/php-fpm.conf && \
    chown www-data:www-data -R  /usr/share/zabbix/ && \
    mkdir /tmp/php7 && chown www-data:www-data -R  /tmp/php7
ENTRYPOINT ["bash","/usr/bin/docker-entrypoint.sh"]
