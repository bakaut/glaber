FROM debian:buster as builder
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install nmap wget gnupg2 lsb-release apt-transport-https -y 
RUN wget https://glaber.io/repo/key/repo.gpg && \
    apt-key add repo.gpg && rm repo.gpg && \
    echo "deb [arch=amd64] https://glaber.io/repo/debian $(lsb_release -sc) main" >> /etc/apt/sources.list.d/glaber.list && \
    echo "deb [arch=amd64] https://repo.utelecom.com.ua/debian $(lsb_release -sc) main" >> /etc/apt/sources.list.d/glaber.list
RUN DEBIAN_FRONTEND=noninteractive  && apt-get update && \
    apt -y install zabbix-server-mysql zabbix-agent 

FROM mysql:8
COPY --from=builder /usr/share/doc/zabbix-server-mysql/create.sql.gz /docker-entrypoint-initdb.d/
RUN echo 'default_authentication_plugin= mysql_native_password' >> /etc/mysql/conf.d/docker.cnf
