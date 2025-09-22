-- Chicha Consulting Company Cassandra Database
-- Educational CQL Script
-- Modeling 200 employees with roles, departments, security levels, and emails

-- 1. Create Keyspace
CREATE KEYSPACE IF NOT EXISTS chicha_db
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE chicha_db;

-- 2. Departments Table
-- Stores department information
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

-- 3. Job Roles Table
-- Stores role info and security clearance
CREATE TABLE IF NOT EXISTS job_roles (
    role_id UUID PRIMARY KEY,
    title text,
    clearance_level int -- 1=low, 5=high
);

-- Sample Roles
INSERT INTO job_roles (role_id, title, clearance_level)
VALUES (uuid(), 'Consultant', 2);

INSERT INTO job_roles (role_id, title, clearance_level)
VALUES (uuid(), 'Senior Consultant', 3);

INSERT INTO job_roles (role_id, title, clearance_level)
VALUES (uuid(), 'Manager', 4);

INSERT INTO job_roles (role_id, title, clearance_level)
VALUES (uuid(), 'Director', 5);

-- 4. Employees Table
-- Composite primary key: dept_id + employee_id
-- Partition key: dept_id (group employees by department)
-- Clustering key: employee_id (sort employees in dept)
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

-- Sample Employee Inserts (repeat to simulate 200 employees)
-- Replace <dept_uuid> and <role_uuid> with actual UUIDs
-- Example for one employee:
-- INSERT INTO employees (dept_id, employee_id, first_name, last_name, email, role_id, security_level)
-- VALUES (<dept_uuid>, uuid(), 'Alice', 'Smith', 'alice.smith@chicha.com', <role_uuid>, 2);

-- 5. Queries Examples

-- Get all employees in a department
-- SELECT * FROM employees WHERE dept_id=<dept_uuid>;

-- Get all employees with high security level (manual filtering may be needed)
-- SELECT * FROM employees WHERE dept_id=<dept_uuid> AND security_level >= 4;

-- Join-like queries (not native in Cassandra, denormalize if needed)
-- Example: include role title in employees table if frequently queried

-- 6. Best Practices Notes

-- - Partition by department for efficient department-level queries
-- - Use employee_id as clustering column for unique sorting
-- - Security_level included for access control filtering
-- - Job roles separated into table, but can be denormalized for faster queries
-- - Cassandra is query-driven: design tables for the queries you need most
-- - Use UUIDs for all primary keys for uniqueness