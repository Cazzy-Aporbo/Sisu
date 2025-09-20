-- Run: cqlsh -f schema.cql
CREATE KEYSPACE IF NOT EXISTS finance
WITH replication = {'class':'SimpleStrategy','replication_factor':1};

USE finance;

CREATE TABLE IF NOT EXISTS transactions (
  user_id    text,
  ts         timestamp,
  category   text,
  amount     decimal,
  PRIMARY KEY ((user_id), ts)
) WITH CLUSTERING ORDER BY (ts ASC);
