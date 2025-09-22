CREATE KEYSPACE IF NOT EXISTS gmp_demo
WITH replication = {'class':'SimpleStrategy', 'replication_factor' : 1};

USE gmp_demo;

CREATE TYPE IF NOT EXISTS signer_info (
  user_id text,
  display_name text,
  role text,
  signed_at timestamp,
  signature_hash text
);

CREATE TYPE IF NOT EXISTS doc_version (
  version_id uuid,
  title text,
  summary text,
  body text,
  created_at timestamp,
  created_by text,
  effective_date date,
  retention_years int,
  approvals list<frozen<signer_info>>
);

CREATE TYPE IF NOT EXISTS quiz_question (
  qid uuid,
  prompt text,
  choices list<text>,
  correct_choice_index int,
  max_score int
);

CREATE TYPE IF NOT EXISTS training_module (
  module_id uuid,
  title text,
  description text,
  doc_refs list<text>,         -- list of document IDs or version IDs referenced
  questions list<frozen<quiz_question>>
);

CREATE TYPE IF NOT EXISTS training_record (
  record_id uuid,
  trainee_id text,
  module_id uuid,
  started_at timestamp,
  completed_at timestamp,
  score int,
  pass boolean,
  evidence map<text,text>      -- e.g., {"proof_url": "...", "remarks": "..."}
);

CREATE TABLE IF NOT EXISTS documents (
  doc_id text,
  department text,
  current_version_id uuid,
  versions list<frozen<doc_version>>,
  owner text,
  lifecycle_state text,        -- draft | pending_approval | approved | superseded | retired
  PRIMARY KEY (doc_id)
);

CREATE TABLE IF NOT EXISTS documents_by_department (
  department text,
  doc_id text,
  title text,
  current_version_id uuid,
  lifecycle_state text,
  PRIMARY KEY ((department), doc_id)
) WITH CLUSTERING ORDER BY (doc_id ASC);

CREATE MATERIALIZED VIEW IF NOT EXISTS documents_by_lifecycle AS
  SELECT doc_id, department, lifecycle_state, current_version_id
  FROM documents
  WHERE doc_id IS NOT NULL AND lifecycle_state IS NOT NULL
  PRIMARY KEY ((lifecycle_state), doc_id)
  WITH CLUSTERING ORDER BY (doc_id ASC);

CREATE TABLE IF NOT EXISTS modules (
  module_id uuid PRIMARY KEY,
  title text,
  description text,
  doc_refs list<text>,
  questions list<frozen<quiz_question>>,
  owner text,
  created_at timestamp
);

CREATE TABLE IF NOT EXISTS training_records_by_trainee (
  trainee_id text,
  record_day text,             -- YYYY-MM-DD to bucket records
  record_id uuid,
  module_id uuid,
  started_at timestamp,
  completed_at timestamp,
  score int,
  pass boolean,
  evidence map<text,text>,
  PRIMARY KEY ((trainee_id, record_day), completed_at, record_id)
) WITH CLUSTERING ORDER BY (completed_at DESC);

CREATE TABLE IF NOT EXISTS training_records_by_module (
  module_id uuid,
  completed_day text,
  record_id uuid,
  trainee_id text,
  completed_at timestamp,
  score int,
  pass boolean,
  PRIMARY KEY ((module_id, completed_day), completed_at, record_id)
) WITH CLUSTERING ORDER BY (completed_at DESC);

CREATE TABLE IF NOT EXISTS audit_log (
  audit_id timeuuid PRIMARY KEY,
  entity_type text,            -- document | module | training | user | system
  entity_id text,
  action text,                 -- create | update | approve | revoke | complete | delete
  performed_by text,
  performed_at timestamp,
  details text
);

CREATE TABLE IF NOT EXISTS users (
  user_id text PRIMARY KEY,
  display_name text,
  email text,
  department text,
  role text,                   -- e.g., trainee, trainer, approver, auditor, admin
  active boolean,
  created_at timestamp
);

-- Roles (placeholders: set real passwords and manage externally in production)
CREATE ROLE IF NOT EXISTS admin WITH PASSWORD = 'CHANGE_ME_ADMIN' AND LOGIN = true;
CREATE ROLE IF NOT EXISTS trainer WITH PASSWORD = 'CHANGE_ME_TRAINER' AND LOGIN = true;
CREATE ROLE IF NOT EXISTS trainee WITH PASSWORD = 'CHANGE_ME_TRAINEE' AND LOGIN = true;
CREATE ROLE IF NOT EXISTS auditor WITH PASSWORD = 'CHANGE_ME_AUDITOR' AND LOGIN = true;

-- Example inserts: documents and versions
INSERT INTO documents (
  doc_id, department, current_version_id, versions, owner, lifecycle_state
) VALUES (
  'SOP-001',
  'Manufacturing',
  uuid(),
  [
    {
      version_id: uuid(),
      title: 'SOP-001: Cleanroom Entry',
      summary: 'Steps to gown and enter ISO 7 cleanroom safely.',
      body: '1. Wash hands... 2. Don gown... 3. Log entry... (full text here)',
      created_at: toTimestamp(now()),
      created_by: 'user_admin',
      effective_date: '2025-01-15',
      retention_years: 15,
      approvals: []
    }
  ],
  'quality_owner',
  'draft'
);

-- Insert a second document with an approval example
INSERT INTO documents (doc_id, department, current_version_id, versions, owner, lifecycle_state) VALUES (
  'SOP-002',
  'Quality',
  uuid(),
  [
    {
      version_id: uuid(),
      title: 'SOP-002: Equipment Calibration',
      summary: 'Calibration frequency and recordkeeping for critical equipment.',
      body: 'Calibration interval: 6 months. Steps ...',
      created_at: toTimestamp(now()),
      created_by: 'user_trainer',
      effective_date: '2025-02-01',
      retention_years: 10,
      approvals: [
        { user_id: 'user_qapprover1', display_name: 'Q. Approver', role: 'approver', signed_at: toTimestamp(now()), signature_hash: 'sha256:abc123' }
      ]
    }
  ],
  'quality_owner',
  'approved'
);

-- Example module with quiz
INSERT INTO modules (module_id, title, description, doc_refs, questions, owner, created_at) VALUES (
  uuid(),
  'GMP Fundamentals',
  'Introductory training on Good Manufacturing Practices and Good Documentation Practices.',
  ['SOP-001','SOP-002'],
  [
    {
      qid: uuid(),
      prompt: 'When entering the cleanroom, which of the following is required first?',
      choices: ['Don gloves', 'Wash hands', 'Put on shoe covers', 'Sign the log'],
      correct_choice_index: 1,
      max_score: 1
    },
    {
      qid: uuid(),
      prompt: 'How long must calibration records be retained according to SOP-002?',
      choices: ['1 year', '5 years', '10 years', 'Indefinitely'],
      correct_choice_index: 2,
      max_score: 1
    }
  ],
  'user_trainer',
  toTimestamp(now())
);

-- Example user
INSERT INTO users (user_id, display_name, email, department, role, active, created_at) VALUES (
  'user_jane',
  'Jane Doe',
  'jane.doe@example.com',
  'Manufacturing',
  'trainee',
  true,
  toTimestamp(now())
);

-- Example training record: denormalize into both record tables
INSERT INTO training_records_by_trainee (
  trainee_id, record_day, record_id, module_id, started_at, completed_at, score, pass, evidence
) VALUES (
  'user_jane',
  dateOf(now())::text,
  uuid(),
  (SELECT module_id FROM modules LIMIT 1),
  toTimestamp(now()),
  toTimestamp(now()),
  2,
  true,
  {'remarks': 'Completed online; 100%'}
);

-- Note: above subselect used illustratively; in practice resolve module_id in client then insert.

-- Example audit entries
INSERT INTO audit_log (audit_id, entity_type, entity_id, action, performed_by, performed_at, details)
VALUES (now(), 'document', 'SOP-002', 'approve', 'user_qapprover1', toTimestamp(now()), 'Approved for circulation; signatures stored');

INSERT INTO audit_log (audit_id, entity_type, entity_id, action, performed_by, performed_at, details)
VALUES (now(), 'training', 'module', 'complete', 'user_jane', toTimestamp(now()), 'GMP Fundamentals module completed; score=2; pass=true');

-- Example queries you can run interactively:
-- SELECT * FROM documents WHERE doc_id = 'SOP-002';
-- SELECT * FROM modules LIMIT 5;
-- SELECT * FROM training_records_by_trainee WHERE trainee_id = 'user_jane' AND record_day = '2025-09-22' LIMIT 10;
-- SELECT * FROM audit_log LIMIT 20;

-- Example of updating document: append a new version and change lifecycle_state to pending_approval
UPDATE documents
SET versions = versions + [
  {
    version_id: uuid(),
    title: 'SOP-002: Equipment Calibration v2',
    summary: 'Updated calibration intervals based on risk assessment.',
    body: 'New calibration interval: 3 months for instrument X. Steps ...',
    created_at: toTimestamp(now()),
    created_by: 'user_trainer',
    effective_date: '2025-09-01',
    retention_years: 10,
    approvals: []
  }
],
current_version_id = uuid(),
lifecycle_state = 'pending_approval'
WHERE doc_id = 'SOP-002';

-- Append audit entry for the update
INSERT INTO audit_log (audit_id, entity_type, entity_id, action, performed_by, performed_at, details)
VALUES (now(), 'document', 'SOP-002', 'update', 'user_trainer', toTimestamp(now()), 'Submitted v2 for approval');