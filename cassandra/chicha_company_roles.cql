-- Chicha Consulting Company Cassandra Database
-- Updated with specific roles: Manager, HR, IT, Domain Expert

-- 1. Create Keyspace
CREATE KEYSPACE IF NOT EXISTS chicha_db
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE chicha_db;

-- 2. Departments Table
CREATE TABLE IF NOT EXISTS departments (
    dept_id UUID PRIMARY KEY,
    name text,
    manager_id UUID
);

-- Sample Departments
INSERT INTO departments (dept_id, name, manager_id)
VALUES (uuid(), 'IT Consulting', uuid());

INSERT INTO departments (dept_id, name, manager_id)
VALUES (uuid(), 'Strategy', uuid());

INSERT INTO departments (dept_id, name, manager_id)
VALUES (uuid(), 'HR', uuid());

-- 3. Job Roles Table with Specific Roles
CREATE TABLE IF NOT EXISTS job_roles (
    role_id UUID PRIMARY KEY,
    title text,
    clearance_level int -- 1=low, 5=high
);

-- Define roles
INSERT INTO job_roles (role_id, title, clearance_level) VALUES (uuid(), 'Manager', 5);
INSERT INTO job_roles (role_id, title, clearance_level) VALUES (uuid(), 'HR', 3);
INSERT INTO job_roles (role_id, title, clearance_level) VALUES (uuid(), 'IT', 4);
INSERT INTO job_roles (role_id, title, clearance_level) VALUES (uuid(), 'Domain Expert', 4);

-- 4. Employees Table
-- Partition by department, clustering by employee_id
CREATE TABLE IF NOT EXISTS employees (
    dept_id UUID,
    employee_id UUID,
    first_name text,
    last_name text,
    email text,
    role_id UUID,
    security_level int,
    PRIMARY KEY (dept_id, employee_id)
) WITH CLUSTERING ORDER BY (employee_id ASC);

-- Example Employee Inserts
-- Replace <dept_uuid> and <role_uuid> with actual UUIDs from departments and job_roles

-- Manager in Strategy
-- INSERT INTO employees (dept_id, employee_id, first_name, last_name, email, role_id, security_level)
-- VALUES (<strategy_dept_uuid>, uuid(), 'Alice', 'Manager', 'alice.manager@chicha.com', <manager_role_uuid>, 5);

-- HR in HR Department
-- INSERT INTO employees (dept_id, employee_id, first_name, last_name, email, role_id, security_level)
-- VALUES (<hr_dept_uuid>, uuid(), 'Bob', 'HR', 'bob.hr@chicha.com', <hr_role_uuid>, 3);

-- IT in IT Department
-- INSERT INTO employees (dept_id, employee_id, first_name, last_name, email, role_id, security_level)
-- VALUES (<it_dept_uuid>, uuid(), 'Charlie', 'IT', 'charlie.it@chicha.com', <it_role_uuid>, 4);

-- Domain Expert in Strategy
-- INSERT INTO employees (dept_id, employee_id, first_name, last_name, email, role_id, security_level)
-- VALUES (<strategy_dept_uuid>, uuid(), 'Dana', 'Expert', 'dana.expert@chicha.com', <domain_role_uuid>, 4);

-- 5. Queries Examples

-- Get all employees in IT department
-- SELECT * FROM employees WHERE dept_id=<it_dept_uuid>;

-- Get all Managers
-- Use job_roles table and join manually if needed, or denormalize role title in employees table
-- SELECT * FROM employees WHERE role_id=<manager_role_uuid>;

-- Get all HR employees
-- SELECT * FROM employees WHERE role_id=<hr_role_uuid>;

-- 6. Best Practices Notes

-- - Partition employees by department for fast department-level queries
-- - Clustering by employee_id ensures sorted listing within each department
-- - Security_level allows filtering for sensitive info
-- - Denormalize role titles if you frequently query by role
-- - Use UUIDs for all keys for uniqueness and distributed storage
-- - Cassandra is query-first: design tables for expected queries