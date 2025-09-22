-- File: chat_messages.cql
-- Store messages for a real-time chat app

CREATE KEYSPACE IF NOT EXISTS chat_db
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE chat_db;

CREATE TABLE IF NOT EXISTS messages (
    chat_id UUID,
    message_time timestamp,
    sender_id UUID,
    message_text text,
    PRIMARY KEY (chat_id, message_time)
) WITH CLUSTERING ORDER BY (message_time DESC);

-- Sample insert
INSERT INTO messages (chat_id, message_time, sender_id, message_text)
VALUES (uuid(), toTimestamp(now()), uuid(), 'Hello, world!');

-- Query last 10 messages in a chat
-- SELECT * FROM messages WHERE chat_id=<uuid> LIMIT 10;