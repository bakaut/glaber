#!/bin/bash
set -e 

clickhouse-client --user default --password zabbix -q "SELECT * FROM zabbix.history limit 1;" || \
clickhouse-client --user default --password zabbix -n <<-EOSQL
  CREATE DATABASE zabbix;
  CREATE TABLE zabbix.history ( 
      itemid UInt64,  
      clock DateTime Codec(DoubleDelta, LZ4),  
      ns UInt32, 
      value Int64 Codec(Gorilla, LZ4),  
      value_dbl Float64 Codec(Gorilla, LZ4), 
      value_str LowCardinality(String) Codec(LZ4)
      ) ENGINE = MergeTree() PARTITION BY toYYYYMMDD(clock) ORDER BY (itemid, clock) SETTINGS index_granularity=8192;
    CREATE TABLE zabbix.history_buffer (day Date,  
                                    itemid UInt64,  
                                    clock DateTime,  
                                    ns UInt32,  
                                    value Int64,  
                                    value_dbl Float64,  
                                    value_str String ) ENGINE = Buffer(zabbix, history, 8, 30, 60, 9000, 60000, 256000, 256000000);
EOSQL