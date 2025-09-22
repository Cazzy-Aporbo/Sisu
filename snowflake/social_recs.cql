-- File: social_recommendations.cql
-- Recommend friends or connections based on interactions

CREATE KEYSPACE IF NOT EXISTS social_db
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE social_db;

CREATE TABLE IF NOT EXISTS user_connections (
    user_id UUID,
    connected_user_id UUID,
    interaction_score int,
    PRIMARY KEY (user_id, connected_user_id)
);

-- Sample insert
INSERT INTO user_connections (user_id, connected_user_id, interaction_score)
VALUES (uuid(), uuid(), 50);

-- Query top connections for a user
-- SELECT * FROM user_connections WHERE user_id=<uuid> ORDER BY interaction_score DESC;