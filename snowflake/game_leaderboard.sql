-- File: game_leaderboard.cql
-- Track player scores for live leaderboard

CREATE KEYSPACE IF NOT EXISTS leaderboard_db
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE leaderboard_db;

CREATE TABLE IF NOT EXISTS player_scores (
    game_id UUID,
    player_id UUID,
    score int,
    score_time timestamp,
    PRIMARY KEY (game_id, score, player_id)
) WITH CLUSTERING ORDER BY (score DESC);

-- Sample insert
INSERT INTO player_scores (game_id, player_id, score, score_time)
VALUES (uuid(), uuid(), 1500, toTimestamp(now()));

-- Query top 10 scores
-- SELECT * FROM player_scores WHERE game_id=<uuid> LIMIT 10;