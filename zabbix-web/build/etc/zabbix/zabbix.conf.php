<?php
// Zabbix GUI configuration file.
global $DB, $HISTORY;

$DB['TYPE']     = 'MYSQL';
$DB['SERVER']   = '{ZBX_MYSQL_HOST}';
$DB['PORT']     = '{ZBX_MYSQL_PORT}';
$DB['DATABASE'] = '{ZBX_MYSQL_DB}';
$DB['USER']     = '{ZBX_MYSQL_USER}';
$DB['PASSWORD'] = '{ZBX_MYSQL_PASS}';

// Schema name. Used for IBM DB2 and PostgreSQL.
//$DB['SCHEMA'] = '{DB_SERVER_SCHEMA}';

$ZBX_SERVER      = '{ZBX_SERVER_HOST}';
$ZBX_SERVER_PORT = '{ZBX_SERVER_PORT}';
$ZBX_SERVER_NAME = '{ZBX_SERVER_NAME}';

$IMAGE_FORMAT_DEFAULT	= IMAGE_FORMAT_PNG;

// Clickhouse url (can be string if same url is used for all types).

$HISTORY['storagetype']='clickhouse';
$HISTORY['url']   = '{ZBX_CH_URL}';
$HISTORY['types'] = ['uint', 'dbl','str','text'];
$HISTORY['dbname'] = '{ZBX_CH_DB}';
$HISTORY['username'] = '{ZBX_CH_USER}';
$HISTORY['password'] = '{ZBX_CH_PASS}';






