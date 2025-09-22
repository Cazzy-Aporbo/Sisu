from cassandra.cluster import Cluster
from cassandra.query import SimpleStatement
import uuid
from datetime import datetime, timedelta

# Connect to Cassandra cluster
cluster = Cluster(['127.0.0.1'])
session = cluster.connect()

# Create keyspace if it does not exist
session.execute("""
CREATE KEYSPACE IF NOT EXISTS employee_chat_db
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1}
""")
session.set_keyspace('employee_chat_db')

# Create team chats table
session.execute("""
CREATE TABLE IF NOT EXISTS team_chats (
    team_id UUID,
    message_time timestamp,
    sender_id UUID,
    message_text text,
    PRIMARY KEY (team_id, message_time)
) WITH CLUSTERING ORDER BY (message_time DESC)
""")

# Create employee to employee chats table
session.execute("""
CREATE TABLE IF NOT EXISTS employee_chats (
    user_pair text,
    message_time timestamp,
    sender_id UUID,
    message_text text,
    PRIMARY KEY (user_pair, message_time)
) WITH CLUSTERING ORDER BY (message_time DESC)
""")

# Insert sample team chat messages
team_id = uuid.uuid4()
session.execute("""
INSERT INTO team_chats (team_id, message_time, sender_id, message_text)
VALUES (%s, %s, %s, %s)
""", (team_id, datetime.now(), uuid.uuid4(), 'Project kickoff meeting at 10 AM'))

session.execute("""
INSERT INTO team_chats (team_id, message_time, sender_id, message_text)
VALUES (%s, %s, %s, %s)
""", (team_id, datetime.now(), uuid.uuid4(), 'Please review the design doc'))

# Insert sample employee to employee chat messages
user1 = uuid.uuid4()
user2 = uuid.uuid4()
user_pair = f"{min(user1, user2)}:{max(user1, user2)}"

session.execute("""
INSERT INTO employee_chats (user_pair, message_time, sender_id, message_text)
VALUES (%s, %s, %s, %s)
""", (user_pair, datetime.now(), user1, 'Can you review the report by today'))

session.execute("""
INSERT INTO employee_chats (user_pair, message_time, sender_id, message_text)
VALUES (%s, %s, %s, %s)
""", (user_pair, datetime.now(), user2, 'Sure I will check it after lunch'))

# Function to retrieve last n team messages
def get_team_messages(team_id, limit=10):
    query = "SELECT * FROM team_chats WHERE team_id = %s LIMIT %s"
    rows = session.execute(query, (team_id, limit))
    for row in rows:
        print(f"Team {row.team_id} Message: {row.message_text} Time: {row.message_time} Sender: {row.sender_id}")

# Function to retrieve last n employee to employee messages
def get_employee_messages(user_pair, limit=10):
    query = "SELECT * FROM employee_chats WHERE user_pair = %s LIMIT %s"
    rows = session.execute(query, (user_pair, limit))
    for row in rows:
        print(f"Chat {row.user_pair} Message: {row.message_text} Time: {row.message_time} Sender: {row.sender_id}")

# Retrieve messages
print("Last team messages")
get_team_messages(team_id, limit=5)

print("\nLast employee messages")
get_employee_messages(user_pair, limit=5)