-- ===========================================================
-- 04_counters_and_ttl.cql — counters & TTLs
-- Notes:
--  • Counters must live in dedicated counter tables (no non-counter mix except PK).
--  • They are eventually consistent; use idempotent increment patterns in app.
--  • TTL on base tables is safer than issuing deletes later (tombstones).
-- ===========================================================

USE finance;

-- Counter table: monthly category spend count per user
CREATE TABLE IF NOT EXISTS monthly_category_counts (
  user_id  text,
  yyyymm   int,
  category text,
  cnt      counter,
  PRIMARY KEY ((user_id, yyyymm), category)
);

-- Increment on write (in app): UPDATE ... SET cnt = cnt + 1 ...

-- TTL pattern: set TTL on raw tx rows (e.g., 18 months retention)
-- INSERT INTO tx_by_user_month (...) VALUES (...) USING TTL 47174400;  -- 18 months in seconds

-- Soft delete pattern: add a boolean flag and filter in app (avoid massive deletes)
ALTER TABLE tx_by_user_month ADD is_deleted boolean;
-- UPDATE tx_by_user_month SET is_deleted = true WHERE ...;
