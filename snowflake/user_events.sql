-- File: user_events.cql
-- Track user actions for analytics

CREATE KEYSPACE IF NOT EXISTS analytics_db
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE analytics_db;

CREATE TABLE IF NOT EXISTS user_events (
    user_id UUID,
    event_time timestamp,
    event_type text,
    event_data text,
    PRIMARY KEY (user_id, event_time)
) WITH CLUSTERING ORDER BY (event_time DESC);

-- Sample insert
INSERT INTO user_events (user_id, event_time, event_type, event_data)
VALUES (uuid(), toTimestamp(now()), 'login', '{"ip": "192.168.1.10"}');

-- Query last events
-- SELECT * FROM user_events WHERE user_id=<uuid> LIMIT 10;