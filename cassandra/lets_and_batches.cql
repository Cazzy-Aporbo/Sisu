-- 03_lwts_and_batches.cql — LWTs (Paxos) and batches
-- Guidance:
--  • LWT (IF ... ) is for correctness (uniqueness, conditional updates), not speed.
--  • Use LOGGED BATCH only when multiple rows share the *same partition key*.
--  • Otherwise prefer UNLOGGED BATCH or, better, multiple single-partition writes.

USE finance;

-- Idempotent upsert without LWT: rely on tx_id uniqueness client-side.
-- INSERT INTO tx_by_user_month (...) VALUES (...);

-- If you need *exactly once semantics* for a generated tx_id, a LIGHTWEIGHT TRANSACTION:
-- (But know it’s ~2–4x cost due to Paxos)
-- INSERT INTO tx_by_user_month (user_id, yyyymm, event_time, tx_id, category, amount, note)
-- VALUES ('u1', 202509, toTimestamp(now()), now(), 'rent', 1200.00, 'Sept rent')
-- IF NOT EXISTS;

-- Mirror into category table inside the same *LOGGED* BATCH only if same partition (not here).
-- Here partitions differ => use UNLOGGED or two independent writes.
-- Example UNLOGGED:
BEGIN UNLOGGED BATCH
  INSERT INTO tx_by_user_month (user_id, yyyymm, event_time, tx_id, category, amount, note)
    VALUES ('u1', 202509, toTimestamp(now()), now(), 'rent', 1200.00, 'Sept rent');
  INSERT INTO tx_by_category_month (category, yyyymm, event_time, tx_id, user_id, amount, note)
    VALUES ('rent', 202509, toTimestamp(now()), now(), 'u1', 1200.00, 'Sept rent');
APPLY BATCH;
