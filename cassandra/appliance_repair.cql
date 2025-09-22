-- Appliance Repair Company Cassandra Database
-- Educational CQL Script

-- 1. Create Keyspace
CREATE KEYSPACE IF NOT EXISTS appliance_db
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE appliance_db;

-- 2. Customers Table
-- Stores customer info
CREATE TABLE IF NOT EXISTS customers (
    customer_id UUID PRIMARY KEY,
    name text,
    phone text,
    email text,
    address text
);

-- Sample Inserts
INSERT INTO customers (customer_id, name, phone, email, address)
VALUES (uuid(), 'John Doe', '555-1234', 'john@example.com', '123 Elm St');

INSERT INTO customers (customer_id, name, phone, email, address)
VALUES (uuid(), 'Jane Smith', '555-5678', 'jane@example.com', '456 Oak Ave');

-- 3. Appliances Table
-- Each appliance belongs to a customer
CREATE TABLE IF NOT EXISTS appliances (
    appliance_id UUID PRIMARY KEY,
    customer_id UUID,
    type text,       -- e.g., 'Refrigerator', 'Oven', 'Washer'
    brand text,
    model text,
    purchase_date date
);

-- Sample Insert (replace <customer_uuid> with actual customer IDs)
-- INSERT INTO appliances (appliance_id, customer_id, type, brand, model, purchase_date)
-- VALUES (uuid(), <customer_uuid>, 'Refrigerator', 'Samsung', 'RF28', '2020-06-01');

-- 4. Technicians Table
CREATE TABLE IF NOT EXISTS technicians (
    tech_id UUID PRIMARY KEY,
    name text,
    phone text,
    expertise set<text> -- Set of appliance types they can repair
);

-- Sample Insert
INSERT INTO technicians (tech_id, name, phone, expertise)
VALUES (uuid(), 'Mike Johnson', '555-9876', {'Refrigerator','Oven'});

-- 5. Repair Tickets Table
-- Composite primary key: ticket_id
-- Includes customer, appliance, technician, and status
CREATE TABLE IF NOT EXISTS repair_tickets (
    ticket_id UUID PRIMARY KEY,
    customer_id UUID,
    appliance_id UUID,
    tech_id UUID,
    issue text,
    status text,        -- e.g., 'open', 'in_progress', 'completed'
    created_at timestamp,
    completed_at timestamp
);

-- Sample Insert (replace <uuid> placeholders with actual IDs)
-- INSERT INTO repair_tickets (ticket_id, customer_id, appliance_id, tech_id, issue, status, created_at)
-- VALUES (uuid(), <customer_uuid>, <appliance_uuid>, <tech_uuid>, 'Fridge not cooling', 'open', toTimestamp(now()));

-- 6. Queries Examples

-- Get all customers
-- SELECT * FROM customers;

-- Get all appliances for a customer
-- SELECT * FROM appliances WHERE customer_id=<customer_uuid>;

-- Get all repair tickets for a technician
-- SELECT * FROM repair_tickets WHERE tech_id=<tech_uuid>;

-- Get all open tickets
-- SELECT * FROM repair_tickets WHERE status='open';

-- 7. Best Practices Notes

-- - Partition keys: choose based on query patterns
--   For example, customer_id in appliances for fast customer lookup
-- - Use UUIDs for unique identifiers
-- - Denormalize data for query efficiency
-- - Cassandra is not for joins; pre-join/duplicate data as needed
-- - Use timestamp and clustering columns for time-series or status history