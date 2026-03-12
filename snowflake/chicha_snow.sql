-- Snowflake Educational Example: Chicha Consulting Company
-- Demonstrates how to:
-- 1. Create a database and schema
-- 2. Create tables
-- 3. Insert sample data
-- 4. Query and join tables
-- 5. Best practices

-- 1. Create Database and Schema
CREATE OR REPLACE DATABASE CHICHA_DB;
USE CHICHA_DB;

CREATE OR REPLACE SCHEMA PUBLIC;
USE SCHEMA PUBLIC;

-- 2. Create Departments Table
CREATE OR REPLACE TABLE DEPARTMENTS (
    DEPT_ID STRING PRIMARY KEY,
    NAME STRING,
    MANAGER_ID STRING
);

-- Sample Insert
INSERT INTO DEPARTMENTS (DEPT_ID, NAME, MANAGER_ID)
VALUES ('D001', 'IT Consulting', 'E001'),
       ('D002', 'Strategy', 'E002'),
       ('D003', 'HR', 'E003');

-- 3. Create Job Roles Table
CREATE OR REPLACE TABLE JOB_ROLES (
    ROLE_ID STRING PRIMARY KEY,
    TITLE STRING,
    CLEARANCE_LEVEL INT
);

-- Sample Roles
INSERT INTO JOB_ROLES (ROLE_ID, TITLE, CLEARANCE_LEVEL)
VALUES ('R001', 'Manager', 5),
       ('R002', 'HR', 3),
       ('R003', 'IT', 4),
       ('R004', 'Domain Expert', 4);

-- 4. Create Employees Table
CREATE OR REPLACE TABLE EMPLOYEES (
    EMPLOYEE_ID STRING PRIMARY KEY,
    FIRST_NAME STRING,
    LAST_NAME STRING,
    EMAIL STRING,
    DEPT_ID STRING,
    ROLE_ID STRING,
    SECURITY_LEVEL INT,
    FOREIGN KEY(DEPT_ID) REFERENCES DEPARTMENTS(DEPT_ID),
    FOREIGN KEY(ROLE_ID) REFERENCES JOB_ROLES(ROLE_ID)
);

-- Sample Employees
INSERT INTO EMPLOYEES (EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, DEPT_ID, ROLE_ID, SECURITY_LEVEL)
VALUES
('E001', 'Alice', 'Manager', 'alice.manager@chicha.com', 'D002', 'R001', 5),
('E002', 'Bob', 'HR', 'bob.hr@chicha.com', 'D003', 'R002', 3),
('E003', 'Charlie', 'IT', 'charlie.it@chicha.com', 'D001', 'R003', 4),
('E004', 'Dana', 'Expert', 'dana.expert@chicha.com', 'D002', 'R004', 4);

-- 5. Queries Examples

-- List all employees
SELECT * FROM EMPLOYEES;

-- List all employees in IT department
SELECT E.FIRST_NAME, E.LAST_NAME, R.TITLE
FROM EMPLOYEES E
JOIN JOB_ROLES R ON E.ROLE_ID = R.ROLE_ID
WHERE DEPT_ID = 'D001';

-- List all Managers
SELECT E.FIRST_NAME, E.LAST_NAME, D.NAME AS DEPT_NAME
FROM EMPLOYEES E
JOIN JOB_ROLES R ON E.ROLE_ID = R.ROLE_ID
JOIN DEPARTMENTS D ON E.DEPT_ID = D.DEPT_ID
WHERE R.TITLE = 'Manager';

-- List all employees with security level >= 4
SELECT * FROM EMPLOYEES
WHERE SECURITY_LEVEL >= 4;

-- 6. Best Practices Notes
-- - Use clear primary keys for employees, departments, and roles
-- - Use foreign keys for referential integrity
-- - Snowflake allows joins, unlike Cassandra, so normalized schema works well
-- - Use descriptive column names and consistent data types
-- - Use views for frequent queries or dashboards
