-- File: product_recommendations.cql
-- Store user-product interactions for recommendations

CREATE KEYSPACE IF NOT EXISTS rec_db
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE rec_db;

CREATE TABLE IF NOT EXISTS user_product_interactions (
    user_id UUID,
    product_id UUID,
    interaction_time timestamp,
    interaction_type text, -- view, buy, like
    PRIMARY KEY (user_id, interaction_time, product_id)
) WITH CLUSTERING ORDER BY (interaction_time DESC);

-- Sample insert
INSERT INTO user_product_interactions (user_id, product_id, interaction_time, interaction_type)
VALUES (uuid(), uuid(), toTimestamp(now()), 'view');

-- Query last 5 interactions for a user
-- SELECT * FROM user_product_interactions WHERE user_id=<uuid> LIMIT 5;