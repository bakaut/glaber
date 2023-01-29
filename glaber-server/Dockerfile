FROM debian:bullseye
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ARG GLABER_BUILD_VERSION
RUN apt-get update && \
    apt-get install -y nmap wget gnupg2 lsb-release apt-transport-https locales && \
    wget -qO - https://glaber.io/repo-testing/key/repo.gpg | apt-key add - && \
    echo "deb [arch=amd64] https://glaber.io/repo-testing/debian $(lsb_release -sc) main" >> /etc/apt/sources.list.d/glaber.list && \
    apt-get update && \
    apt-cache show glaber-server-mysql && \
    apt-get install -y glaber-server-mysql=*$GLABER_BUILD_VERSION* && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
    apt-get autoremove --yes && \
    apt-get clean autoclean && \
    sed -i -e '/en_US.UTF-8/s/^# //g' \
           -e '/ru_RU.UTF-8/s/^# //g' \
    /etc/locale.gen && \
    locale-gen 
COPY etc/zabbix/zabbix_server.conf /etc/zabbix/zabbix_server.conf
RUN mkdir -p /var/lib/mysql/vcdump/ /run/zabbix && \
    chown zabbix:zabbix /run/zabbix /var/lib/mysql/vcdump/ && \
    chmod +s /usr/bin/nmap && \
    chmod +s /usr/sbin/glbmap

COPY docker-entrypoint.sh /root/docker-entrypoint.sh

CMD ["/bin/bash","/root/docker-entrypoint.sh"]