use MYSQL_DATABASE;
update users set passwd=md5('ZBX_WEB_ADMIN_PASS') where username='Admin';
