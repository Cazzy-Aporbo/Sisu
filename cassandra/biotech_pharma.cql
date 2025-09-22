-- Biotech/Pharmaceutical Cassandra Database Example
-- Educational CQL Script

-- 1. Create Keyspace for biotech company
CREATE KEYSPACE IF NOT EXISTS biotech_db
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE biotech_db;

-- 2. Patients Table
-- Stores basic patient info
-- Primary key: patient_id (UUID)
CREATE TABLE IF NOT EXISTS patients (
    patient_id UUID PRIMARY KEY,
    name text,
    dob date,
    gender text,
    email text
);

-- Sample Insert
INSERT INTO patients (patient_id, name, dob, gender, email)
VALUES (uuid(), 'Alice Smith', '1980-05-12', 'F', 'alice.smith@example.com');

INSERT INTO patients (patient_id, name, dob, gender, email)
VALUES (uuid(), 'Bob Johnson', '1975-09-22', 'M', 'bob.johnson@example.com');

-- 3. Drug Compounds Table
-- Primary key: compound_id
-- Stores info about experimental drug compounds
CREATE TABLE IF NOT EXISTS drug_compounds (
    compound_id UUID PRIMARY KEY,
    name text,
    formula text,
    status text, -- e.g., 'preclinical', 'phase1', 'approved'
    created_at timestamp
);

INSERT INTO drug_compounds (compound_id, name, formula, status, created_at)
VALUES (uuid(), 'PharmaX', 'C20H25N3O', 'phase1', toTimestamp(now()));

-- 4. Clinical Trials Table
-- Composite primary key: trial_id + patient_id
-- Partition key: trial_id (group patients in same trial)
-- Clustering key: patient_id (sort patients in trial)
CREATE TABLE IF NOT EXISTS clinical_trials (
    trial_id UUID,
    patient_id UUID,
    compound_id UUID,
    start_date date,
    end_date date,
    outcome text,
    PRIMARY KEY (trial_id, patient_id)
) WITH CLUSTERING ORDER BY (patient_id ASC);

-- Sample Insert (replace UUIDs with actual ones from patients/drugs)
-- Example:
-- INSERT INTO clinical_trials (trial_id, patient_id, compound_id, start_date, end_date, outcome)
-- VALUES (uuid(), <patient_uuid>, <compound_uuid>, '2025-01-01', '2025-06-01', 'pending');

-- 5. Lab Results Table
-- Time-series style: partitioned by patient_id, ordered by test_date
CREATE TABLE IF NOT EXISTS lab_results (
    patient_id UUID,
    test_date timestamp,
    test_name text,
    result text,
    PRIMARY KEY (patient_id, test_date)
) WITH CLUSTERING ORDER BY (test_date DESC);

-- Sample Insert
-- INSERT INTO lab_results (patient_id, test_date, test_name, result)
-- VALUES (<patient_uuid>, toTimestamp(now()), 'Blood Pressure', '120/80');

-- 6. Queries Examples

-- Get all patients
-- SELECT * FROM patients;

-- Get all clinical trial participants for a trial
-- SELECT * FROM clinical_trials WHERE trial_id=<trial_uuid>;

-- Get latest lab results for a patient
-- SELECT * FROM lab_results WHERE patient_id=<patient_uuid> LIMIT 5;

-- 7. Best Practices Notes

-- - Always choose primary and clustering keys based on query patterns
-- - Use UUIDs for unique identifiers
-- - Denormalize data for fast queries
-- - Time-series data (lab_results) should use clustering columns to order by date
-- - Avoid joins; design queries first and model tables accordingly