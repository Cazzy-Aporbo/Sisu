-- Cassandra Full Team and Employee Chat Example
-- Shows advanced data retrieval for teams and employee to employee chats

-- Keyspace for chat data
CREATE KEYSPACE IF NOT EXISTS employee_chat_db
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE employee_chat_db;

-- Table for team chats
-- Partition key team_id Clustering key message_time DESC
CREATE TABLE IF NOT EXISTS team_chats (
    team_id UUID,
    message_time timestamp,
    sender_id UUID,
    message_text text,
    PRIMARY KEY (team_id, message_time)
) WITH CLUSTERING ORDER BY (message_time DESC);

-- Table for direct employee to employee chats
-- Partition key user_pair Clustering key message_time DESC
CREATE TABLE IF NOT EXISTS employee_chats (
    user_pair text,
    message_time timestamp,
    sender_id UUID,
    message_text text,
    PRIMARY KEY (user_pair, message_time)
) WITH CLUSTERING ORDER BY (message_time DESC);

-- Sample Inserts

-- Insert a team chat message
INSERT INTO team_chats (team_id, message_time, sender_id, message_text)
VALUES (uuid(), toTimestamp(now()), uuid(), 'Project kickoff meeting at 10 AM');

-- Insert another team chat message
INSERT INTO team_chats (team_id, message_time, sender_id, message_text)
VALUES (uuid(), toTimestamp(now()), uuid(), 'Please review the design doc');

-- Insert a direct employee chat message
-- Example user1 id uuid1 user2 id uuid2 user_pair "uuid1:uuid2"
INSERT INTO employee_chats (user_pair, message_time, sender_id, message_text)
VALUES ('123e4567e89b12d3a456426614174000:123e4567e89b12d3a456426614174001',
        toTimestamp(now()),
        uuid(),
        'Can you review the report by today');

-- Insert another direct employee chat message
INSERT INTO employee_chats (user_pair, message_time, sender_id, message_text)
VALUES ('123e4567e89b12d3a456426614174000:123e4567e89b12d3a456426614174001',
        toTimestamp(now()),
        uuid(),
        'Sure I will check it after lunch');

-- Queries Unconventional Retrieval Methods

-- Retrieve last 10 messages for a specific team
SELECT * 
FROM team_chats 
WHERE team_id = <team_uuid> 
LIMIT 10;

-- Retrieve last 10 messages between two employees
-- Ensure user_pair is sorted smaller_uuid:larger_uuid
SELECT * 
FROM employee_chats 
WHERE user_pair = '<user1_uuid>:<user2_uuid>' 
LIMIT 10;

-- Retrieve all messages for multiple teams using multiple SELECTs or IN clause
SELECT * 
FROM team_chats 
WHERE team_id IN (<team_uuid1>, <team_uuid2>) 
LIMIT 20;

-- Retrieve recent messages across multiple employee pairs using multiple queries
SELECT * 
FROM employee_chats 
WHERE user_pair = '<user1_uuid>:<user2_uuid>' 
LIMIT 5;
SELECT * 
FROM employee_chats 
WHERE user_pair = '<user3_uuid>:<user4_uuid>' 
LIMIT 5;

-- Best Practices Demonstrated

-- Partition by team_id or user_pair for efficient query patterns
-- Use clustering by message_time DESC to get latest messages first
-- Store bi directional chats using sorted user_pair
-- Design queries first tables second for unconventional but effective retrieval
-- Ethical access only retrieve data you have permission to query