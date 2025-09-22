-- Snowflake Beginner Tutorial
-- This script teaches you Snowflake from scratch

-- STEP 1: Create a Database
-- A database is like a container for your data
CREATE OR REPLACE DATABASE MY_FIRST_DB;

-- Switch to using this database
USE DATABASE MY_FIRST_DB;

-- STEP 2: Create a Schema
-- Schemas organize tables inside a database
CREATE OR REPLACE SCHEMA MY_FIRST_SCHEMA;
USE SCHEMA MY_FIRST_SCHEMA;

-- STEP 3: Create a Table
-- Example: store simple employee information
CREATE OR REPLACE TABLE EMPLOYEES (
    EMPLOYEE_ID STRING PRIMARY KEY,  -- unique identifier
    FIRST_NAME STRING,
    LAST_NAME STRING,
    EMAIL STRING,
    DEPARTMENT STRING
);

-- STEP 4: Insert Data
-- Add a few example employees
INSERT INTO EMPLOYEES (EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, DEPARTMENT)
VALUES
('E001', 'Alice', 'Smith', 'alice@example.com', 'IT'),
('E002', 'Bob', 'Johnson', 'bob@example.com', 'HR'),
('E003', 'Charlie', 'Lee', 'charlie@example.com', 'Strategy');

-- STEP 5: Query Data
-- Select all rows
SELECT * FROM EMPLOYEES;

-- Select only names and departments
SELECT FIRST_NAME, LAST_NAME, DEPARTMENT FROM EMPLOYEES;

-- STEP 6: Filtering Data
-- Find employees in IT department
SELECT * FROM EMPLOYEES
WHERE DEPARTMENT = 'IT';

-- STEP 7: Updating Data
-- Update an employee's department
UPDATE EMPLOYEES
SET DEPARTMENT = 'Strategy'
WHERE EMPLOYEE_ID = 'E003';

-- STEP 8: Deleting Data
-- Remove an employee
DELETE FROM EMPLOYEES
WHERE EMPLOYEE_ID = 'E002';

-- STEP 9: Creating a Second Table
-- Example: Departments table
CREATE OR REPLACE TABLE DEPARTMENTS (
    DEPT_ID STRING PRIMARY KEY,
    DEPT_NAME STRING,
    MANAGER_NAME STRING
);

-- Insert sample data
INSERT INTO DEPARTMENTS (DEPT_ID, DEPT_NAME, MANAGER_NAME)
VALUES
('D001', 'IT', 'Alice Smith'),
('D002', 'HR', 'Bob Johnson'),
('D003', 'Strategy', 'Charlie Lee');

-- STEP 10: Joining Tables
-- Show employees with their department manager
SELECT E.FIRST_NAME, E.LAST_NAME, E.DEPARTMENT, D.MANAGER_NAME
FROM EMPLOYEES E
JOIN DEPARTMENTS D
  ON E.DEPARTMENT = D.DEPT_NAME;

-- STEP 11: Best Practices Notes
-- 1. Always define primary keys to uniquely identify rows
-- 2. Use descriptive names for tables and columns
-- 3. Use schemas to organize tables logically
-- 4. Use warehouses to control compute resources for queries
-- 5. Snowflake supports semi-structured data (JSON, PARQUET)