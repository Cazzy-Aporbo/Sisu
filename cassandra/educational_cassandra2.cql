-- Advanced Cassandra Educational CQL Script
-- ------------------------------------------
-- This script covers:
-- 1. Composite primary keys
-- 2. Clustering columns
-- 3. Secondary indexes
-- 4. Time-series table design
-- 5. Query examples

-- 1. Create a Keyspace for advanced examples
CREATE KEYSPACE IF NOT EXISTS edu_keyspace_adv
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE edu_keyspace_adv;

-- 2. Composite Primary Key Example
-- Partition key: user_id
-- Clustering column: post_id
-- This ensures all posts for a user are stored together and ordered by post_id
CREATE TABLE IF NOT EXISTS user_posts (
    user_id UUID,
    post_id timeuuid,
    title text,
    content text,
    created_at timestamp,
    PRIMARY KEY (user_id, post_id)
) WITH CLUSTERING ORDER BY (post_id DESC);

-- Insert sample data
INSERT INTO user_posts (user_id, post_id, title, content, created_at)
VALUES (uuid(), now(), 'First Post', 'This is the first post', toTimestamp(now()));

INSERT INTO user_posts (user_id, post_id, title, content, created_at)
VALUES (uuid(), now(), 'Second Post', 'This is the second post', toTimestamp(now()));

-- Query: Get all posts for a specific user
-- Must specify the partition key (user_id)
-- Clustering column ensures newest posts come first
-- Example: replace <uuid> with actual user_id
-- SELECT * FROM user_posts WHERE user_id = <uuid>;

-- 3. Secondary Index Example
-- Allows querying a column that is not part of the primary key
CREATE TABLE IF NOT EXISTS users (
    user_id UUID PRIMARY KEY,
    name text,
    age int,
    email text
);

-- Create index on email for lookup
CREATE INDEX IF NOT EXISTS email_idx ON users (email);

-- Query using secondary index
-- SELECT * FROM users WHERE email='alice@example.com';

-- 4. Time-Series Table Design
-- Example: Sensor readings by device
CREATE TABLE IF NOT EXISTS sensor_readings (
    device_id UUID,
    reading_time timestamp,
    temperature float,
    humidity float,
    PRIMARY KEY (device_id, reading_time)
) WITH CLUSTERING ORDER BY (reading_time DESC);

-- Insert sample sensor data
INSERT INTO sensor_readings (device_id, reading_time, temperature, humidity)
VALUES (uuid(), toTimestamp(now()), 22.5, 55.0);

INSERT INTO sensor_readings (device_id, reading_time, temperature, humidity)
VALUES (uuid(), toTimestamp(now()), 23.0, 53.2);

-- Query: Get latest readings for a device
-- SELECT * FROM sensor_readings WHERE device_id=<uuid> LIMIT 5;

-- 5. Best Practices Summary
-- - Use composite keys to group related data logically
-- - Clustering columns define sort order and improve range queries
-- - Secondary indexes can be useful for small datasets; avoid large-scale use
-- - For time-series, always include a partition key to avoid hot spots
-- - Design tables for queries, not normalization (denormalize if needed)
-- - Use UUIDs or timeuuid for unique identifiers and ordering