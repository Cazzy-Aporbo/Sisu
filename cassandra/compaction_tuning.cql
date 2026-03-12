-- 02_compaction_tuning.cql
-- Use STCS (SizeTiered) default or TWCS (TimeWindowCompactionStrategy) for time-series.
-- TWCS helps expire old data by TTL per window; fewer overlapping SSTables.

USE finance;

-- If data is mostly recent and TTLed, TWCS is great:
ALTER TABLE tx_by_user_month WITH compaction = {
  'class': 'TimeWindowCompactionStrategy',
  'compaction_window_unit': 'DAYS',
  'compaction_window_size': '7'   -- 1-week windows
} AND default_time_to_live = 0;    -- set per-row TTL via app if desired

-- Tombstone hygiene:
-- • Avoid massive deletes; prefer TTL at insert.
-- • Keep clustering columns minimal to limit deletions fan-out.
-- • Run nodetool repairs regularly; TWCS + windowed TTLs simplify compaction.
