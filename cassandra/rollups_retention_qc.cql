-- 07_rollups_retention_qc.cql
-- Goals:
--  • Roll up raw tx ➝ daily + monthly aggregates for cheap reads
--  • TTL policy by tier (raw short, rollups medium, KPIs long)
--  • QC-inspired guard columns for quick anomaly screens (z-score-like)
USE finance;

-- Daily rollups per user/category
CREATE TABLE IF NOT EXISTS daily_rollup_by_user_cat (
  user_id   text,
  day       date,
  category  text,
  tx_count  int,
  amt_sum   decimal,
  amt_min   decimal,
  amt_max   decimal,
  amt_avg   decimal,
  z_hint    decimal,   -- "quick z" vs rolling avg (app populated)
  PRIMARY KEY ((user_id, day), category)
);

-- Monthly rollups per user
CREATE TABLE IF NOT EXISTS monthly_rollup_by_user (
  user_id    text,
  yyyymm     int,
  tx_count   int,
  amt_sum    decimal,
  avg_ticket decimal,
  p95_ticket decimal,  -- app-side approximate quantile
  qc_band    text,     -- "OK" | "MARGINAL" | "OUT-OF-CONTROL" (app populated)
  PRIMARY KEY ((user_id), yyyymm)
);

-- TTL strategy (set per-insert in app):
--   raw tx_by_user_month            -> TTL 12-18 months
--   daily_rollup_by_user_cat        -> TTL 24-36 months
--   monthly_rollup_by_user          -> TTL 48+ months
-- rationale: rollups outlive raw; budget ops cost predictably

-- Example reads:
--  • Month summary: SELECT * FROM monthly_rollup_by_user WHERE user_id='u1' LIMIT 36;
--  • Daily category trend: SELECT * FROM daily_rollup_by_user_cat WHERE user_id='u1' AND day='2025-09-15';
