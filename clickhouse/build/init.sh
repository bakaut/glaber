#!/bin/bash
set -e 

ZBX_CH_DB=${ZBX_CH_DB:-"zabbix"}
ZBX_CH_USER=${ZBX_CH_USER:-"default"}
ZBX_CH_PASS=${ZBX_CH_PASS:-"zabbix"}

clickhouse-client --user ${ZBX_CH_USER} --password ${ZBX_CH_PASS} -q "SELECT * FROM ${ZBX_CH_DB}.history limit 1;" || \
clickhouse-client --user ${ZBX_CH_USER} --password ${ZBX_CH_PASS} -n <<-EOSQL
  CREATE DATABASE IF NOT EXISTS ${ZBX_CH_DB};
  CREATE TABLE IF NOT EXISTS ${ZBX_CH_DB}.history ( 
      itemid UInt64,  
      clock DateTime Codec(DoubleDelta, LZ4),  
      ns UInt32, 
      value Int64 Codec(Gorilla, LZ4),  
      value_dbl Float64 Codec(Gorilla, LZ4), 
      value_str LowCardinality(String) Codec(LZ4)
      ) ENGINE = MergeTree() PARTITION BY toYYYYMMDD(clock) ORDER BY (itemid, clock) SETTINGS index_granularity=8192;
    CREATE TABLE IF NOT EXISTS ${ZBX_CH_DB}.history_buffer (day Date,  
                                    itemid UInt64,  
                                    clock DateTime,  
                                    ns UInt32,  
                                    value Int64,  
                                    value_dbl Float64,  
                                    value_str String ) ENGINE = Buffer(${ZBX_CH_DB}, history, 8, 30, 60, 9000, 60000, 256000, 256000000);
EOSQL || \
clickhouse-client --user ${ZBX_CH_USER} --password ${ZBX_CH_PASS} -n <<-EOSQL
    CREATE DATABASE IF NOT EXISTS ${ZBX_CH_DB};
    CREATE TABLE IF NOT EXISTS ${ZBX_CH_DB}.history ( day Date,  
                                    itemid UInt64,  
                                    clock DateTime,  
                                    ns UInt32, 
                                    value Int64,  
                                    value_dbl Float64,  
                                    value_str String 
                                ) ENGINE = MergeTree(day, (itemid, clock), 8192);
    CREATE TABLE IF NOT EXISTS ${ZBX_CH_DB}.history_buffer (day Date,  
                                    itemid UInt64,  
                                    clock DateTime,  
                                    ns UInt32,  
                                    value Int64,  
                                    value_dbl Float64,  
                                    value_str String ) ENGINE = Buffer(${ZBX_CH_DB}, history, 8, 30, 60, 9000, 60000, 256000, 256000000);
EOSQL
