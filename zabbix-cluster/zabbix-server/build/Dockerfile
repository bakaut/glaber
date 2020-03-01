FROM debian:buster
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install nmap wget gnupg2 lsb-release apt-transport-https -y && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
    apt-get autoremove --yes && \
    apt-get clean autoclean
RUN wget https://glaber.io/repo/key/repo.gpg && \
    apt-key add repo.gpg && rm repo.gpg && \
    echo "deb [arch=amd64] https://glaber.io/repo/debian $(lsb_release -sc) main" >> /etc/apt/sources.list.d/glaber.list && \
    echo "deb [arch=amd64] https://repo.utelecom.com.ua/debian $(lsb_release -sc) main" >> /etc/apt/sources.list.d/glaber.list
RUN apt-get update && \
    apt -y install zabbix-server-mysql=1:$ZBX_BUILD_VERSION-1+glaber~$GLABER_BUILD_VERSION \
    zabbix-agent=1:$ZBX_BUILD_VERSION-1+glaber~$GLABER_BUILD_VERSION && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
    apt-get autoremove --yes && \
    apt-get clean autoclean
COPY etc/zabbix/zabbix_server.conf /etc/zabbix/zabbix_server.conf
RUN mkdir /var/run/zabbix && \
    chown  zabbix:zabbix /var/run/zabbix && \
    chmod +s /usr/bin/nmap

COPY docker-entrypoint.sh /root/docker-entrypoint.sh

CMD ["/bin/bash","/root/docker-entrypoint.sh"]