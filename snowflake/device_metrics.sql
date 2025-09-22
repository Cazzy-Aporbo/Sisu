-- File: device_metrics.cql
-- Track multiple metrics per device & location

CREATE KEYSPACE IF NOT EXISTS metrics_db
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE metrics_db;

CREATE TABLE IF NOT EXISTS device_metrics (
    device_id UUID,
    location_id UUID,
    metric_time timestamp,
    metric_name text,
    metric_value double,
    PRIMARY KEY ((device_id, location_id), metric_time, metric_name)
) WITH CLUSTERING ORDER BY (metric_time DESC, metric_name ASC);

-- Sample insert
INSERT INTO device_metrics (device_id, location_id, metric_time, metric_name, metric_value)
VALUES (uuid(), uuid(), toTimestamp(now()), 'temperature', 23.5);

-- Query: last metrics for device at location
-- SELECT * FROM device_metrics WHERE device_id=<uuid> AND location_id=<uuid> LIMIT 5;