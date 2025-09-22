-- File: iot_network.cql
-- Simulate IoT devices sending readings to Cassandra

CREATE KEYSPACE IF NOT EXISTS iot_network_db
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE iot_network_db;

CREATE TABLE IF NOT EXISTS network_readings (
    device_id UUID,
    reading_time timestamp,
    metric_name text,
    metric_value double,
    PRIMARY KEY ((device_id), reading_time, metric_name)
) WITH CLUSTERING ORDER BY (reading_time DESC, metric_name ASC);

-- Sample insert
INSERT INTO network_readings (device_id, reading_time, metric_name, metric_value)
VALUES (uuid(), toTimestamp(now()), 'temperature', 23.5);

-- Query last readings per device
-- SELECT * FROM network_readings WHERE device_id=<uuid> LIMIT 5;