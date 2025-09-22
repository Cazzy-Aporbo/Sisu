USE chat_demo;

-- Insert sample messages
INSERT INTO messages_by_team (
  team_id, day, message_id, created_at, sender, channel, content, metadata
) VALUES (
  'team_42',
  '2025-09-22',
  uuid(),
  toTimestamp(now()),
  { sender_id: 'user_1001', sender_email: 'alice@example.com', display_name: 'Alice' },
  'general',
  'First demo message',
  [ { key: 'importance', value: 'high' } ]
);

INSERT INTO messages_by_team (
  team_id, day, message_id, created_at, sender, channel, content, metadata
) VALUES (
  'team_42',
  '2025-09-22',
  uuid(),
  toTimestamp(now()),
  { sender_id: 'user_1002', sender_email: 'bob@example.com', display_name: 'Bob' },
  'random',
  'Hello from Bob',
  [ { key: 'mood', value: 'funny' } ]
);

-- Recent messages for a team
SELECT team_id, created_at, sender.display_name, channel, content
FROM messages_by_team
WHERE team_id = 'team_42' AND day = '2025-09-22'
LIMIT 10;

-- Direct lookup by message_id (assuming you copy the uuid from an insert above)
SELECT * FROM messages_by_id
WHERE message_id = <uuid>;

-- Messages sent by a specific user (from denormalized table)
SELECT created_at, team_id, channel, content
FROM messages_by_user
WHERE sender_id = 'user_1001' AND day = '2025-09-22'
LIMIT 5;

-- Messages in a channel (from materialized view)
SELECT created_at, message_id, content
FROM messages_by_channel
WHERE team_id = 'team_42' AND channel = 'general' AND day = '2025-09-22'
LIMIT 5;

-- Demonstrate TTL: insert a short-lived message (expires in 60 seconds)
INSERT INTO messages_by_team (
  team_id, day, message_id, created_at, sender, channel, content, metadata
) VALUES (
  'team_42',
  '2025-09-22',
  uuid(),
  toTimestamp(now()),
  { sender_id: 'user_1003', sender_email: 'eve@example.com', display_name: 'Eve' },
  'general',
  'This will vanish soon',
  []
) USING TTL 60;

-- Check the short-lived message is present
SELECT created_at, sender.display_name, content
FROM messages_by_team
WHERE team_id = 'team_42' AND day = '2025-09-22'
LIMIT 20;

-- After 60 seconds, the message will automatically disappear from results