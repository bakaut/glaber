# Login to glaber web
POST http://127.0.1.1:{{port}}/index.php
User-Agent: Mozilla/5.0 
Content-Type: application/x-www-form-urlencoded
[FormParams]
name: {{user}}
password: {{pass}}
enter: Sign+in
HTTP/1.1 302

# Check glaber-server is runing
POST http://127.0.1.1:{{port}}/jsrpc.php?output=json-rpc
User-Agent: Mozilla/5.0 
Content-Type: application/json-rpc
Accept: */*
```
{"jsonrpc":"2.0","method":"zabbix.status","params":{"nocache":true},"id":3}
```
HTTP/1.1 200
[Asserts]
jsonpath "$.result.result" == true

