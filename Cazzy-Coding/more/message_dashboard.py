import imaplib
import email
from email.header import decode_header
from cassandra.cluster import Cluster
from datetime import datetime
import uuid

# -----------------------
# Cassandra Setup
# -----------------------
cluster = Cluster(['127.0.0.1'])
session = cluster.connect()

# Create keyspace and tables if not exist
session.execute("""
CREATE KEYSPACE IF NOT EXISTS employee_chat_db
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1}
""")
session.set_keyspace('employee_chat_db')

session.execute("""
CREATE TABLE IF NOT EXISTS team_chats (
    team_id UUID,
    message_time timestamp,
    sender_id UUID,
    message_text text,
    PRIMARY KEY (team_id, message_time)
) WITH CLUSTERING ORDER BY (message_time DESC)
""")

session.execute("""
CREATE TABLE IF NOT EXISTS employee_chats (
    user_pair text,
    message_time timestamp,
    sender_id UUID,
    message_text text,
    PRIMARY KEY (user_pair, message_time)
) WITH CLUSTERING ORDER BY (message_time DESC)
""")

# Sample insert for demonstration
team_id = uuid.uuid4()
user1 = uuid.uuid4()
user2 = uuid.uuid4()
user_pair = f"{min(user1, user2)}:{max(user1, user2)}"

session.execute("""
INSERT INTO team_chats (team_id, message_time, sender_id, message_text)
VALUES (%s, %s, %s, %s)
""", (team_id, datetime.now(), user1, 'Team meeting at 2 PM'))

session.execute("""
INSERT INTO employee_chats (user_pair, message_time, sender_id, message_text)
VALUES (%s, %s, %s, %s)
""", (user_pair, datetime.now(), user2, 'Can you review my code?'))

# -----------------------
# Cassandra Retrieval
# -----------------------
def get_team_messages(team_id, limit=5):
    rows = session.execute(
        "SELECT * FROM team_chats WHERE team_id = %s LIMIT %s", (team_id, limit)
    )
    print("Team Messages")
    for row in rows:
        print(f"{row.message_time} | Sender: {row.sender_id} | {row.message_text}")
    print()

def get_employee_messages(user_pair, limit=5):
    rows = session.execute(
        "SELECT * FROM employee_chats WHERE user_pair = %s LIMIT %s", (user_pair, limit)
    )
    print("Employee Messages")
    for row in rows:
        print(f"{row.message_time} | Sender: {row.sender_id} | {row.message_text}")
    print()

# -----------------------
# Email Retrieval Setup
# -----------------------
EMAIL_USER = "your_email@example.com"
EMAIL_PASS = "your_app_password"
IMAP_SERVER = "imap.gmail.com"

def get_last_emails(limit=5):
    imap = imaplib.IMAP4_SSL(IMAP_SERVER)
    imap.login(EMAIL_USER, EMAIL_PASS)
    imap.select("INBOX")
    status, messages = imap.search(None, "ALL")
    email_ids = messages[0].split()[-limit:]
    print("Recent Emails")
    for i in email_ids:
        res, msg = imap.fetch(i, "(RFC822)")
        for response in msg:
            if isinstance(response, tuple):
                msg_obj = email.message_from_bytes(response[1])
                subject, encoding = decode_header(msg_obj["Subject"])[0]
                if isinstance(subject, bytes):
                    subject = subject.decode(encoding if encoding else "utf-8")
                from_ = msg_obj.get("From")
                print(f"{from_} | {subject}")
    imap.logout()
    print()

# -----------------------
# Dashboard Display
# -----------------------
get_team_messages(team_id)
get_employee_messages(user_pair)
get_last_emails()