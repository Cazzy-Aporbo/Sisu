-- Snowflake Full Beginner-to-Advanced Tutorial
-- --------------------------------------------
-- Learn Snowflake step by step, from basics to intermediate analytics
-- Each section is annotated with explanations

-- ===============================
-- STEP 1: Create Database and Schema
-- ===============================
-- Database: container for all your data
CREATE OR REPLACE DATABASE SNOWFLAKE_LEARNING;
USE DATABASE SNOWFLAKE_LEARNING;

-- Schema: organize tables inside the database
CREATE OR REPLACE SCHEMA LEARNING_SCHEMA;
USE SCHEMA LEARNING_SCHEMA;

-- ===============================
-- STEP 2: Create Basic Tables
-- ===============================

-- Employees Table
-- Stores basic employee information
CREATE OR REPLACE TABLE EMPLOYEES (
    EMPLOYEE_ID STRING PRIMARY KEY,
    FIRST_NAME STRING,
    LAST_NAME STRING,
    EMAIL STRING,
    DEPARTMENT STRING,
    SALARY NUMBER
);

-- Departments Table
CREATE OR REPLACE TABLE DEPARTMENTS (
    DEPT_ID STRING PRIMARY KEY,
    DEPT_NAME STRING,
    MANAGER_NAME STRING
);

-- ===============================
-- STEP 3: Insert Sample Data
-- ===============================

-- Insert Departments
INSERT INTO DEPARTMENTS (DEPT_ID, DEPT_NAME, MANAGER_NAME)
VALUES 
('D001', 'IT', 'Alice Smith'),
('D002', 'HR', 'Bob Johnson'),
('D003', 'Strategy', 'Charlie Lee');

-- Insert Employees
INSERT INTO EMPLOYEES (EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, DEPARTMENT, SALARY)
VALUES
('E001', 'Alice', 'Smith', 'alice@company.com', 'IT', 120000),
('E002', 'Bob', 'Johnson', 'bob@company.com', 'HR', 90000),
('E003', 'Charlie', 'Lee', 'charlie@company.com', 'Strategy', 110000),
('E004', 'Dana', 'Kim', 'dana@company.com', 'IT', 95000);

-- ===============================
-- STEP 4: Querying Basics
-- ===============================

-- Select all employees
SELECT * FROM EMPLOYEES;

-- Select specific columns
SELECT FIRST_NAME, LAST_NAME, DEPARTMENT FROM EMPLOYEES;

-- Filter by department
SELECT * FROM EMPLOYEES WHERE DEPARTMENT = 'IT';

-- Order by salary descending
SELECT * FROM EMPLOYEES ORDER BY SALARY DESC;

-- ===============================
-- STEP 5: Joins
-- ===============================

-- List employees with their department manager
SELECT E.FIRST_NAME, E.LAST_NAME, E.DEPARTMENT, D.MANAGER_NAME
FROM EMPLOYEES E
JOIN DEPARTMENTS D
  ON E.DEPARTMENT = D.DEPT_NAME;

-- ===============================
-- STEP 6: Aggregations
-- ===============================

-- Average salary per department
SELECT DEPARTMENT, AVG(SALARY) AS AVG_SALARY
FROM EMPLOYEES
GROUP BY DEPARTMENT;

-- Total employees per department
SELECT DEPARTMENT, COUNT(*) AS NUM_EMPLOYEES
FROM EMPLOYEES
GROUP BY DEPARTMENT;

-- ===============================
-- STEP 7: Advanced Table (JSON Example)
-- ===============================

-- Snowflake supports semi-structured data
CREATE OR REPLACE TABLE PROJECTS (
    PROJECT_ID STRING PRIMARY KEY,
    PROJECT_NAME STRING,
    DETAILS VARIANT  -- stores JSON
);

-- Insert JSON data
INSERT INTO PROJECTS (PROJECT_ID, PROJECT_NAME, DETAILS)
VALUES ('P001', 'Project Alpha', PARSE_JSON('{"budget": 50000, "deadline": "2025-12-31"}'));

-- Query JSON data
SELECT PROJECT_NAME, DETAILS:budget AS BUDGET, DETAILS:deadline AS DEADLINE
FROM PROJECTS;

-- ===============================
-- STEP 8: Views
-- ===============================

-- Create a view for high-paying IT employees
CREATE OR REPLACE VIEW HIGH_IT_EMPLOYEES AS
SELECT FIRST_NAME, LAST_NAME, SALARY
FROM EMPLOYEES
WHERE DEPARTMENT = 'IT' AND SALARY > 100000;

-- Query the view
SELECT * FROM HIGH_IT_EMPLOYEES;

-- ===============================
-- STEP 9: Best Practices
-- ===============================

-- 1. Always use descriptive names for databases, schemas, tables, columns, and views.
-- 2. Use primary keys to uniquely identify rows.
-- 3. Use schemas to organize your data logically.
-- 4. For large datasets, consider clustering keys to optimize query performance.
-- 5. Use VARIANT type to store semi-structured data like JSON or XML.
-- 6. Views help organize frequently used queries.
-- 7. Snowflake separates compute and storage; choose warehouses wisely to optimize costs.

-- ===============================
-- END OF TUTORIAL
-- ===============================