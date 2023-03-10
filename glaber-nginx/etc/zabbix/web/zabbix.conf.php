<?php
// Zabbix GUI configuration file.
global $DB, $HISTORY;

$DB['TYPE']     = 'MYSQL';
$DB['SERVER']   = '{MYSQL_HOST}';
$DB['PORT']     = '{MYSQL_PORT}';
$DB['DATABASE'] = '{MYSQL_DATABASE}';
$DB['USER']     = '{MYSQL_USER}';
$DB['PASSWORD'] = '{MYSQL_PASSWORD}';

// Schema name. Used for IBM DB2 and PostgreSQL.
//$DB['SCHEMA'] = '{DB_SERVER_SCHEMA}';

$ZBX_SERVER      = '{ZBX_SERVER_NAME}';
$ZBX_SERVER_PORT = '{ZBX_SERVER_PORT}';
$ZBX_SERVER_NAME = '{ZBX_SERVER_NAME}';

$IMAGE_FORMAT_DEFAULT	= IMAGE_FORMAT_PNG;

//should be so, will deprecate soon

$HISTORY['storagetype']='server';

?>
