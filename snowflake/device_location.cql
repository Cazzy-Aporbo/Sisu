-- File: device_location.cql
-- Track device locations over time

CREATE KEYSPACE IF NOT EXISTS geo_db
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE geo_db;

CREATE TABLE IF NOT EXISTS device_locations (
    device_id UUID,
    location_time timestamp,
    latitude double,
    longitude double,
    PRIMARY KEY (device_id, location_time)
) WITH CLUSTERING ORDER BY (location_time DESC);

-- Sample insert
INSERT INTO device_locations (device_id, location_time, latitude, longitude)
VALUES (uuid(), toTimestamp(now()), 37.7749, -122.4194);

-- Query last 5 locations for a device
-- SELECT * FROM device_locations WHERE device_id=<uuid> LIMIT 5;