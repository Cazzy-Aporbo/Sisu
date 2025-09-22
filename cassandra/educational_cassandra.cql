-- Educational Cassandra CQL Script
-- ---------------------------------
-- This file teaches basic Cassandra usage: keyspaces, tables, inserts, queries, updates, and deletes.

-- 1. Create a Keyspace (like a database)
-- 'SimpleStrategy' is for local testing; replication_factor=1
CREATE KEYSPACE IF NOT EXISTS edu_keyspace
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

-- 2. Use the keyspace
USE edu_keyspace;

-- 3. Create a Table
-- Primary key is user_id (UUID)
-- Columns: name, age, email
CREATE TABLE IF NOT EXISTS users (
    user_id UUID PRIMARY KEY,
    name text,
    age int,
    email text
);

-- 4. Insert Data
-- Always provide a unique UUID for primary key
INSERT INTO users (user_id, name, age, email)
VALUES (uuid(), 'Alice', 30, 'alice@example.com');

INSERT INTO users (user_id, name, age, email)
VALUES (uuid(), 'Bob', 25, 'bob@example.com');

-- 5. Query Data
-- Select all rows
SELECT * FROM users;

-- Select specific columns
SELECT name, age FROM users;

-- 6. Update Data
-- Update age for a specific user (replace <uuid> with actual id)
-- Example: UPDATE users SET age = 31 WHERE user_id = <uuid>;

-- 7. Delete Data
-- Delete a user by primary key
-- Example: DELETE FROM users WHERE user_id = <uuid>;

-- 8. Best Practices Notes
-- - Always design your table based on the queries you need (query-first)
-- - Partition key determines data location across nodes
-- - Avoid joins and complex transactions; denormalize if needed
-- - Use UUIDs or unique identifiers for primary keys
-- - Use cqlsh or drivers (Python, Java, Node) for programmatic access