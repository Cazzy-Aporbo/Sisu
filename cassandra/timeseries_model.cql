-- 01_timeseries_model.cql — Time-series modeling (finance)
-- Key ideas:
--  • Wide rows partitioned by (user_id, yyyymm bucket) to keep partitions healthy
--  • Z-order clustering by event_time for natural range scans
--  • STATIC columns for per-partition metadata (e.g., monthly budget)
--  • Query patterns: by month, by day range, last N events (paging)
--  • Prepared INSERTs with IF NOT EXISTS for idempotence (optionally)

CREATE KEYSPACE IF NOT EXISTS finance
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE finance;

-- Bucketing helper: yyyymm integer (e.g., 202509 for Sept 2025)
CREATE TABLE IF NOT EXISTS tx_by_user_month (
  user_id    text,
  yyyymm     int,
  event_time timestamp,
  tx_id      uuid,
  category   text,
  amount     decimal,
  note       text,
  -- Partition on (user_id, month bucket), cluster by time then tx_id for uniqueness
  PRIMARY KEY ((user_id, yyyymm), event_time, tx_id)
) WITH CLUSTERING ORDER BY (event_time DESC)
  AND comment = 'Time-series by user-month; DESC for "latest first" queries';

-- Optional: monthly metadata (STATIC) to avoid another table
ALTER TABLE tx_by_user_month ADD monthly_budget decimal STATIC;

-- A materialized view is tempting; but prefer query tables.
-- If you *must* demo MV, include notes about backfill/repair cost:
-- (Commented out intentionally; better to create a second table for category queries.)
-- CREATE MATERIALIZED VIEW tx_by_category AS
--   SELECT * FROM tx_by_user_month
--   WHERE category IS NOT NULL AND user_id IS NOT NULL AND yyyymm IS NOT NULL AND event_time IS NOT NULL AND tx_id IS NOT NULL
--   PRIMARY KEY ((category, yyyymm), event_time, tx_id);

-- Better: dedicated query table for category + month (writes == reads is the Cassandra law)
CREATE TABLE IF NOT EXISTS tx_by_category_month (
  category   text,
  yyyymm     int,
  event_time timestamp,
  tx_id      uuid,
  user_id    text,
  amount     decimal,
  note       text,
  PRIMARY KEY ((category, yyyymm), event_time, tx_id)
) WITH CLUSTERING ORDER BY (event_time DESC);

-- Read examples:
-- 1) Last N for a user this month (use driver paging to cap N):
-- SELECT * FROM tx_by_user_month WHERE user_id = 'u1' AND yyyymm = 202509 LIMIT 50;

-- 2) Range scan for a day window inside month (server filters cluster range):
-- SELECT * FROM tx_by_user_month
-- WHERE user_id='u1' AND yyyymm=202509 AND event_time >= '2025-09-10' AND event_time < '2025-09-12';

-- 3) Category hot list:
-- SELECT * FROM tx_by_category_month WHERE category='groceries' AND yyyymm=202509 LIMIT 100;

-- Write path (dual write into both tables; make it idempotent in the driver)
