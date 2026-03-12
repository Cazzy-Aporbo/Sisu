-- 09_cdc_and_audit.cql
-- Cassandra CDC (table-level) = write row changes to CDC log dir (node-local).
-- Useful for downstream ETL or integrity checks. This enables CDC on query tables.
-- Also enables FULL QUERY LOGGING (FQL) for short windows when debugging.
USE finance;

-- Enable CDC on your high-value query table(s)
ALTER TABLE tx_by_user_month WITH cdc = true;

-- Ops notes (node.yaml / jvm opts, not CQL):
--   cdc_enabled: true
--   cdc_total_space_in_mb: 4096   # size cap for CDC logs
-- Consume CDC via external tooling/agent (e.g., Spark job) reading the CDC directory.

-- Full Query Logging (server-side, Cassandra 4.x):
--   nodetool enablefullquerylog
--   # reproduce issue ...
--   nodetool disablefullquerylog
-- Logs land under: <data dir>/commitlog/fql/
-- Use for short capture windows only (I/O heavy).
