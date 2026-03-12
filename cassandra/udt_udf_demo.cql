-- 05_udt_udf_demo.cql — UDT for structured notes; UDF (if enabled) for tiny transforms
-- Warning: UDFs require enabling (security & perf considerations). Prefer app-side logic.

USE finance;

-- UDT to store structured merchant info
CREATE TYPE IF NOT EXISTS merchant_info (
  name text,
  city text,
  mcc  text
);

ALTER TABLE tx_by_user_month ADD merchant frozen<merchant_info>;

-- Insert example:
-- UPDATE tx_by_user_month
-- SET merchant = {name:'Fresh Market', city:'Portland', mcc:'5411'}
-- WHERE user_id='u1' AND yyyymm=202509 AND event_time=... AND tx_id=...;

-- Optional UDF (requires enable_user_defined_functions: true)
-- CREATE OR REPLACE FUNCTION finance.abs_amount(input decimal)
-- RETURNS NULL ON NULL INPUT RETURNS decimal LANGUAGE java AS
-- 'return input.abs();';
--
-- SELECT finance.abs_amount(amount) FROM tx_by_user_month LIMIT 3;
