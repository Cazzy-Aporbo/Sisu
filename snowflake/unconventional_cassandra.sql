-- Advanced and Unconventional Cassandra Usage
-- -------------------------------------------
-- Teaching unconventional ways to use Cassandra

-- 1. Keyspace for advanced experimentation
CREATE KEYSPACE IF NOT EXISTS UNCONVENTIONAL_DB
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE UNCONVENTIONAL_DB;

-- 2. Graph-like relationships
-- Example: Employee mentorship (directed graph)
-- Partition key: mentor_id (group all mentees of a mentor together)
-- Clustering key: mentee_id (sorted list)
CREATE TABLE IF NOT EXISTS employee_mentorship (
    mentor_id UUID,
    mentee_id UUID,
    start_date timestamp,
    PRIMARY KEY (mentor_id, mentee_id)
) WITH CLUSTERING ORDER BY (mentee_id ASC);

-- Sample Inserts
INSERT INTO employee_mentorship (mentor_id, mentee_id, start_date)
VALUES (uuid(), uuid(), toTimestamp(now()));

-- Query: All mentees of a mentor
-- SELECT * FROM employee_mentorship WHERE mentor_id=<mentor_uuid>;

-- 3. Versioned data / auditing
-- Track changes to employee roles over time
CREATE TABLE IF NOT EXISTS employee_roles_history (
    employee_id UUID,
    change_time timestamp,
    old_role text,
    new_role text,
    PRIMARY KEY (employee_id, change_time)
) WITH CLUSTERING ORDER BY (change_time DESC);

-- Sample insert: role change
INSERT INTO employee_roles_history (employee_id, change_time, old_role, new_role)
VALUES (uuid(), toTimestamp(now()), 'Consultant', 'Senior Consultant');

-- Query: Last 5 role changes for an employee
-- SELECT * FROM employee_roles_history WHERE employee_id=<uuid> LIMIT 5;

-- 4. Real-time analytics on semi-structured data
-- Store JSON in a text column (Cassandra does not have native JSON type)
CREATE TABLE IF NOT EXISTS sensor_streams (
    sensor_id UUID,
    reading_time timestamp,
    reading_data text, -- store JSON string
    PRIMARY KEY (sensor_id, reading_time)
) WITH CLUSTERING ORDER BY (reading_time DESC);

-- Sample insert: JSON as string
INSERT INTO sensor_streams (sensor_id, reading_time, reading_data)
VALUES (uuid(), toTimestamp(now()), '{"temperature": 22.5, "humidity": 55}');

-- Query last readings
-- SELECT * FROM sensor_streams WHERE sensor_id=<uuid> LIMIT 10;

-- 5. Multi-dimensional time-series
-- Track multiple metrics per device, per location
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
VALUES (uuid(), uuid(), toTimestamp(now()), 'temperature', 22.5);

INSERT INTO device_metrics (device_id, location_id, metric_time, metric_name, metric_value)
VALUES (uuid(), uuid(), toTimestamp(now()), 'humidity', 55.0);

-- Query last 5 metrics for a device at a location
-- SELECT * FROM device_metrics WHERE device_id=<uuid> AND location_id=<uuid> LIMIT 5;

-- ==========================
-- Notes on unconventional usage
-- ==========================
-- 1. Graphs: Use partitioning to model directed relationships efficiently.
-- 2. Versioning: Cassandra's clustering columns are perfect for historical tracking.
-- 3. Semi-structured data: Store JSON as string or use UDTs for flexible schemas.
-- 4. Multi-dimensional time-series: Composite partition keys allow querying by device/location efficiently.
-- 5. Denormalization is okay: Cassandra excels when you design tables for queries, not normalization.