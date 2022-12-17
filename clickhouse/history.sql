CREATE DATABASE glaber;
CREATE TABLE glaber.history_dbl (   day Date,  
                                itemid UInt64,  
                                clock DateTime,  
                                hostname String,
                                itemname String,
                                ns UInt32, 
                                value Float64
                            ) ENGINE = MergeTree()
PARTITION BY toYYYYMM(day)
ORDER BY (itemid, clock) 
TTL day + INTERVAL 6 MONTH;

--                            
CREATE TABLE glaber.history_uint (   day Date,  
                                itemid UInt64,  
                                clock DateTime,  
                                hostname String,
                                itemname String,
                                ns UInt32, 
                                value UInt64  
                            ) ENGINE = MergeTree()
PARTITION BY toYYYYMM(day)
ORDER BY (itemid, clock) 
TTL day + INTERVAL 6 MONTH;

CREATE TABLE glaber.history_str (   day Date,  
                                itemid UInt64,  
                                clock DateTime,  
                                hostname String,
                                itemname String,
                                ns UInt32, 
                                value String  
                            ) ENGINE = MergeTree()
PARTITION BY toYYYYMM(day)
ORDER BY (itemid, clock) 
TTL day + INTERVAL 6 MONTH;

--
CREATE TABLE glaber.history_log (   day Date,  
                                itemid UInt64,  
                                clock DateTime,  
                                logeventid UInt64,
                                source  String,
                                severity UInt8,
                                hostname String,
                                itemname String,
                                ns UInt32, 
                                value String
                            ) ENGINE = MergeTree()
PARTITION BY toYYYYMM(day)
ORDER BY (itemid, clock) 
TTL day + INTERVAL 6 MONTH;

--
CREATE TABLE glaber.trends_dbl
(
    day Date,
    itemid UInt64,
    clock DateTime,
    value_min Float64,
    value_max Float64,
    value_avg Float64,
    count UInt32,
    hostname String,
    itemname String
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(day)
ORDER BY (itemid, clock)
TTL day + toIntervalMonth(24)
SETTINGS index_granularity = 8192;

--
CREATE TABLE glaber.trends_uint
(
    day Date,
    itemid UInt64,
    clock DateTime,
    value_min Int64,  
    value_max Int64,
    value_avg Int64,
    count UInt32,
    hostname String,
    itemname String
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(day)
ORDER BY (itemid, clock)
TTL day + toIntervalMonth(24)
SETTINGS index_granularity = 8192;

-- some stats guide
-- https://gist.github.com/sanchezzzhak/511fd140e8809857f8f1d84ddb937015
-- to submit all CREATE TABLE queries at once, run "clickhouse-client" with the "--multiquery" param
