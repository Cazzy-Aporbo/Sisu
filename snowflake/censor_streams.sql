-- File: sensor_streams.cql
-- Store JSON-like sensor readings

CREATE KEYSPACE IF NOT EXISTS iot_db
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE iot_db;

CREATE TABLE IF NOT EXISTS sensor_streams (
    sensor_id UUID,
    reading_time timestamp,
    reading_data text, -- JSON stored as string
    PRIMARY KEY (sensor_id, reading_time)
) WITH CLUSTERING ORDER BY (reading_time DESC);

-- Sample insert
INSERT INTO sensor_streams (sensor_id, reading_time, reading_data)
VALUES (uuid(), toTimestamp(now()), '{"temperature": 25.3, "humidity": 55}');

-- Query last readings
-- SELECT * FROM sensor_streams WHERE sensor_id=<uuid> LIMIT 10;