-- File: content_tags.cql
-- Store tags for content and allow faceted search

CREATE KEYSPACE IF NOT EXISTS tags_db
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE tags_db;

CREATE TABLE IF NOT EXISTS content_tags (
    content_id UUID,
    tag text,
    PRIMARY KEY (content_id, tag)
);

-- Sample insert
INSERT INTO content_tags (content_id, tag)
VALUES (uuid(), 'education');

INSERT INTO content_tags (content_id, tag)
VALUES (uuid(), 'AI');

-- Query all tags for a content item
-- SELECT * FROM content_tags WHERE content_id=<uuid>;