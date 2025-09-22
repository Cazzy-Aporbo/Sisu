CREATE KEYSPACE IF NOT EXISTS chat_demo
WITH replication = {
  'class': 'SimpleStrategy',
  'replication_factor': 1
};

USE chat_demo;

CREATE TYPE IF NOT EXISTS sender_info (
  sender_id text,
  sender_email text,
  display_name text
);

CREATE TYPE IF NOT EXISTS message_meta (
  key text,
  value text
);

CREATE TABLE IF NOT EXISTS messages_by_team (
  team_id text,
  day text,
  message_id uuid,
  created_at timestamp,
  sender frozen<sender_info>,
  channel text,
  content text,
  metadata list<frozen<message_meta>>,
  PRIMARY KEY ((team_id, day), created_at, message_id)
) WITH CLUSTERING ORDER BY (created_at DESC)
  AND default_time_to_live = 2592000; -- 30 days

CREATE TABLE IF NOT EXISTS messages_by_id (
  message_id uuid PRIMARY KEY,
  team_id text,
  day text,
  created_at timestamp,
  sender frozen<sender_info>,
  channel text,
  content text,
  metadata list<frozen<message_meta>>
) WITH default_time_to_live = 2592000;

CREATE TABLE IF NOT EXISTS messages_by_user (
  sender_id text,
  day text,
  created_at timestamp,
  message_id uuid,
  team_id text,
  channel text,
  content text,
  PRIMARY KEY ((sender_id, day), created_at, message_id)
) WITH CLUSTERING ORDER BY (created_at DESC)
  AND default_time_to_live = 2592000;

CREATE MATERIALIZED VIEW IF NOT EXISTS messages_by_channel AS
  SELECT team_id, channel, day, created_at, message_id, content
  FROM messages_by_team
  WHERE team_id IS NOT NULL AND channel IS NOT NULL AND day IS NOT NULL AND created_at IS NOT NULL AND message_id IS NOT NULL
  PRIMARY KEY ((team_id, channel, day), created_at, message_id)
  WITH CLUSTERING ORDER BY (created_at DESC);