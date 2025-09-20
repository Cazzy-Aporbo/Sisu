-- ===========================================================
-- 06_safe_views_and_alt_indexes.cql
-- Apache Cassandra MVs exist, but operationally risky if you don't monitor
-- backfills/repairs. Prefer QUERY TABLES + dual writes. This script:
--   1) Shows a minimal MV (for teaching), with guardrails notes
--   2) Gives two stronger alternatives you can actually ship
-- ===========================================================
USE finance;

-- 0) TEACHING-ONLY MV: "latest tx per user_id" (NOT RECOMMENDED IN PROD)
-- Risks:
--  • Backfill & repair cost
--  • Write amplification and coupling
--  • Difficult incident response if MV lags base table
-- If you keep it, restrict scope, monitor regularly.
CREATE MATERIALIZED VIEW IF NOT EXISTS latest_tx_per_user AS
  SELECT user_id, event_time, tx_id, category, amount
  FROM tx_by_user_month
  WHERE user_id IS NOT NULL AND event_time IS NOT NULL AND tx_id IS NOT NULL AND yyyymm IS NOT NULL
  PRIMARY KEY ((user_id), event_time, tx_id)
WITH CLUSTERING ORDER BY (event_time DESC);

-- "Safe-ish" operational notes (run manually, not CQL):
--   nodetool rebuild -- <keyspace> <table>  (MV backfill)
--   nodetool repair  -- validate MV health
--   nodetool status  -- check disk vs base table growth

-- 1) ALTERNATIVE: QUERY TABLE for "latest N per user" (simple, reliable)
CREATE TABLE IF NOT EXISTS tx_by_user_latest (
  user_id    text,
  event_time timestamp,
  tx_id      uuid,
  category   text,
  amount     decimal,
  PRIMARY KEY ((user_id), event_time, tx_id)
) WITH CLUSTERING ORDER BY (event_time DESC);

-- Dual write from app (see python/app_async_ingest.py) keeps it in sync.
-- Read: SELECT * FROM tx_by_user_latest WHERE user_id='u1' LIMIT 50;

-- 2) ALTERNATIVE: INVERTED PARTITION for "top recent by category across users"
CREATE TABLE IF NOT EXISTS recent_by_category (
  category   text,
  event_time timestamp,
  tx_id      uuid,
  user_id    text,
  amount     decimal,
  PRIMARY KEY ((category), event_time, tx_id)
) WITH CLUSTERING ORDER BY (event_time DESC);

-- Read: SELECT * FROM recent_by_category WHERE category='groceries' LIMIT 100;
