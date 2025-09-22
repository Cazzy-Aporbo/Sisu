-- File: employee_roles_history.cql
-- Track changes to roles over time

CREATE KEYSPACE IF NOT EXISTS audit_db
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE audit_db;

CREATE TABLE IF NOT EXISTS employee_roles_history (
    employee_id UUID,
    change_time timestamp,
    old_role text,
    new_role text,
    PRIMARY KEY (employee_id, change_time)
) WITH CLUSTERING ORDER BY (change_time DESC);

-- Sample insert
INSERT INTO employee_roles_history (employee_id, change_time, old_role, new_role)
VALUES (uuid(), toTimestamp(now()), 'Junior', 'Mid');

-- Query last 5 role changes
-- SELECT * FROM employee_roles_history WHERE employee_id=<uuid> LIMIT 5;