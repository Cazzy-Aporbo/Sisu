CREATE KEYSPACE IF NOT EXISTS gmp_demo
WITH replication = {'class':'SimpleStrategy', 'replication_factor' : 1};

USE gmp_demo;

CREATE TYPE IF NOT EXISTS signer_info (
  user_id text,
  display_name text,
  role text,
  signed_at timestamp
);

CREATE TYPE IF NOT EXISTS quiz_question (
  qid uuid,
  prompt text,
  choices list<text>,
  correct_choice_index int,
  max_score int
);

-- Table 1: Documents (SOPs)
CREATE TABLE IF NOT EXISTS documents (
  doc_id text PRIMARY KEY,
  title text,
  department text,
  versions list<frozen<signer_info>>,
  lifecycle_state text,  -- draft | pending | approved | retired
  owner text
);

-- Table 2: Training Modules
CREATE TABLE IF NOT EXISTS modules (
  module_id uuid PRIMARY KEY,
  title text,
  description text,
  doc_refs list<text>,
  questions list<frozen<quiz_question>>,
  owner text,
  created_at timestamp
);

-- Table 3: Training Records
CREATE TABLE IF NOT EXISTS training_records (
  trainee_id text,
  record_day text,
  record_id uuid,
  module_id uuid,
  completed_at timestamp,
  score int,
  pass boolean,
  PRIMARY KEY ((trainee_id, record_day), completed_at, record_id)
) WITH CLUSTERING ORDER BY (completed_at DESC);

-- Table 4: Audit Log
CREATE TABLE IF NOT EXISTS audit_log (
  audit_id timeuuid PRIMARY KEY,
  entity_type text,
  entity_id text,
  action text,
  performed_by text,
  performed_at timestamp,
  details text
);

-- Example inserts
INSERT INTO documents (doc_id, title, department, versions, lifecycle_state, owner) VALUES (
  'SOP-001',
  'Cleanroom Entry',
  'Manufacturing',
  [],
  'draft',
  'quality_owner'
);

INSERT INTO modules (module_id, title, description, doc_refs, questions, owner, created_at) VALUES (
  uuid(),
  'GMP Basics',
  'Intro to Good Manufacturing and Documentation Practices',
  ['SOP-001'],
  [],
  'user_trainer',
  toTimestamp(now())
);

INSERT INTO training_records (trainee_id, record_day, record_id, module_id, completed_at, score, pass) VALUES (
  'user_jane',
  '2025-09-22',
  uuid(),
  uuid(),
  toTimestamp(now()),
  2,
  true
);

INSERT INTO audit_log (audit_id, entity_type, entity_id, action, performed_by, performed_at, details) VALUES (
  now(),
  'document',
  'SOP-001',
  'create',
  'user_trainer',
  toTimestamp(now()),
  'Document created as draft'
);