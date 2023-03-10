#!/usr/bin/env bash

set -eo pipefail

# change zabbix web config
sed -i \
    -e "s/{MYSQL_HOST}/${MYSQL_HOST}/g" \
    -e "s/{MYSQL_PORT}/${MYSQL_PORT}/g" \
    -e "s/{MYSQL_DATABASE}/${MYSQL_DATABASE}/g" \
    -e "s/{MYSQL_USER}/${MYSQL_USER}/g" \
    -e "s/{MYSQL_PASSWORD}/${MYSQL_PASSWORD}/g" \
    -e "s/{ZBX_SERVER_PORT}/${ZBX_SERVER_PORT}/g" \
    -e "s/{ZBX_SERVER_NAME}/${ZBX_SERVER_NAME}/g" \
"$ZBX_WEB_CONFIG"

# set default time zone for php-fpm
# sed -i "s/{MYSQL_HOST}/${MYSQL_HOST}/g" \
# sed ; php_value[date.timezone] = Europe/Riga
# ; php_value[date.timezone] = Europe/Moscow /etc/php/7.4/fpm/pool.d/zabbix-php-fpm.conf

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf