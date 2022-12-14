FROM debian:bullseye
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y nmap wget gnupg2 lsb-release apt-transport-https && \
    wget -qO - https://glaber.io/repo/key/repo.gpg | apt-key add - && \
    echo "deb [arch=amd64] https://glaber.io/repo/debian $(lsb_release -sc) main" >> /etc/apt/sources.list.d/glaber.list && \
    apt-get update && \
    apt-get install -y glaber-server-mysql=1:$GLABER_BUILD_VERSION* zabbix-agent && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
    apt-get autoremove --yes && \
    apt-get clean autoclean
COPY etc/zabbix/zabbix_server.conf /etc/zabbix/zabbix_server.conf
RUN mkdir -p /var/lib/mysql/vcdump/ /run/zabbix && \
    chown zabbix:zabbix /run/zabbix /var/lib/mysql/vcdump/ && \
    chmod +s /usr/bin/nmap && \
    chmod +s /usr/sbin/glbmap

COPY docker-entrypoint.sh /root/docker-entrypoint.sh

CMD ["/bin/bash","/root/docker-entrypoint.sh"]