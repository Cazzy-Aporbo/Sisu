from cassandra.cluster import Cluster
from cassandra.query import SimpleStatement
import uuid
from datetime import datetime, timedelta
import json
import random

# ------------------------------
# Connect to Cassandra
# ------------------------------
cluster = Cluster(['127.0.0.1'])  # replace with your Cassandra host
session = cluster.connect()

# ------------------------------
# Create Keyspace
# ------------------------------
session.execute("""
CREATE KEYSPACE IF NOT EXISTS playground
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1}
""")
session.set_keyspace('playground')

# ------------------------------
# Create Tables
# ------------------------------

# 1. Employee Mentorship
session.execute("""
CREATE TABLE IF NOT EXISTS employee_mentorship (
    mentor_id UUID,
    mentee_id UUID,
    start_date timestamp,
    PRIMARY KEY (mentor_id, mentee_id)
) WITH CLUSTERING ORDER BY (mentee_id ASC)
""")

# 2. Employee Roles History
session.execute("""
CREATE TABLE IF NOT EXISTS employee_roles_history (
    employee_id UUID,
    change_time timestamp,
    old_role text,
    new_role text,
    PRIMARY KEY (employee_id, change_time)
) WITH CLUSTERING ORDER BY (change_time DESC)
""")

# 3. Sensor Streams (JSON)
session.execute("""
CREATE TABLE IF NOT EXISTS sensor_streams (
    sensor_id UUID,
    reading_time timestamp,
    reading_data text,
    PRIMARY KEY (sensor_id, reading_time)
) WITH CLUSTERING ORDER BY (reading_time DESC)
""")

# 4. Device Metrics (Multi-dimensional Time Series)
session.execute("""
CREATE TABLE IF NOT EXISTS device_metrics (
    device_id UUID,
    location_id UUID,
    metric_time timestamp,
    metric_name text,
    metric_value double,
    PRIMARY KEY ((device_id, location_id), metric_time, metric_name)
) WITH CLUSTERING ORDER BY (metric_time DESC, metric_name ASC)
""")

# ------------------------------
# Insert Sample Data
# ------------------------------

# Create some UUIDs for employees, mentors, sensors, devices
employees = [uuid.uuid4() for _ in range(5)]
mentors = employees[:2]
mentees = employees[2:]

sensors = [uuid.uuid4() for _ in range(3)]
devices = [uuid.uuid4() for _ in range(2)]
locations = [uuid.uuid4() for _ in range(2)]

# Employee Mentorship
for mentor in mentors:
    for mentee in mentees:
        session.execute("""
        INSERT INTO employee_mentorship (mentor_id, mentee_id, start_date)
        VALUES (%s, %s, %s)
        """, (mentor, mentee, datetime.now() - timedelta(days=random.randint(1, 100))))

# Employee Roles History
roles = ['Junior', 'Mid', 'Senior', 'Lead']
for emp in employees:
    for i in range(3):
        old = roles[random.randint(0, 2)]
        new = roles[random.randint(1, 3)]
        session.execute("""
        INSERT INTO employee_roles_history (employee_id, change_time, old_role, new_role)
        VALUES (%s, %s, %s, %s)
        """, (emp, datetime.now() - timedelta(days=i*30), old, new))

# Sensor Streams (JSON)
for sensor in sensors:
    for i in range(5):
        data = json.dumps({
            "temperature": random.uniform(20, 30),
            "humidity": random.uniform(40, 60)
        })
        session.execute("""
        INSERT INTO sensor_streams (sensor_id, reading_time, reading_data)
        VALUES (%s, %s, %s)
        """, (sensor, datetime.now() - timedelta(minutes=i*10), data))

# Device Metrics
metric_names = ['temperature', 'humidity', 'vibration']
for device in devices:
    for location in locations:
        for i in range(5):
            for metric in metric_names:
                session.execute("""
                INSERT INTO device_metrics (device_id, location_id, metric_time, metric_name, metric_value)
                VALUES (%s, %s, %s, %s, %s)
                """, (device, location, datetime.now() - timedelta(hours=i), metric, random.uniform(10, 100)))

# ------------------------------
# Queries: Interactive Examples
# ------------------------------

print("=== Mentorships ===")
rows = session.execute("SELECT * FROM employee_mentorship LIMIT 10")
for row in rows:
    print(row)

print("\n=== Role History for Employee 1 ===")
rows = session.execute(f"SELECT * FROM employee_roles_history WHERE employee_id={employees[0]}")
for row in rows:
    print(row)

print("\n=== Last 3 Sensor Readings ===")
rows = session.execute(f"SELECT * FROM sensor_streams WHERE sensor_id={sensors[0]} LIMIT 3")
for row in rows:
    print(row)

print("\n=== Last Metrics for Device 1 at Location 1 ===")
rows = session.execute(f"SELECT * FROM device_metrics WHERE device_id={devices[0]} AND location_id={locations[0]} LIMIT 5")
for row in rows:
    print(row)