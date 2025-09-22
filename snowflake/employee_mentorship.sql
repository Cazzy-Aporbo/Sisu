-- File: employee_mentorship.cql
-- Model a mentorship network as a directed graph

CREATE KEYSPACE IF NOT EXISTS mentorship_db
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE mentorship_db;

CREATE TABLE IF NOT EXISTS employee_mentorship (
    mentor_id UUID,
    mentee_id UUID,
    start_date timestamp,
    PRIMARY KEY (mentor_id, mentee_id)
) WITH CLUSTERING ORDER BY (mentee_id ASC);

-- Sample inserts
INSERT INTO employee_mentorship (mentor_id, mentee_id, start_date)
VALUES (uuid(), uuid(), toTimestamp(now()));

-- Query: find all mentees of a mentor
-- SELECT * FROM employee_mentorship WHERE mentor_id=<mentor_uuid>;