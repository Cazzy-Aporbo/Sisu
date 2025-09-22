import os, uuid, random
from datetime import datetime, timedelta
from cassandra.cluster import Cluster
from faker import Faker

fake = Faker()

host = os.getenv("CASSANDRA_HOST", "127.0.0.1")
keyspace = os.getenv("CASSANDRA_KEYSPACE", "chat_demo")

print(f"Connecting to Cassandra at {host}...")

cluster = Cluster([host])
session = cluster.connect()

# Ensure keyspace + schema is applied
with open("/schema.cql", "r") as f:
    schema_cql = f.read()
for stmt in schema_cql.split(";"):
    if stmt.strip():
        session.execute(stmt)

session.set_keyspace(keyspace)

insert_cql = session.prepare("""
INSERT INTO messages_by_team (
  team_id, day, message_id, created_at, sender, channel, content, metadata
) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
""")

channels = ["general", "random", "dev", "support"]

print("Inserting fake messages...")

for _ in range(200):
    team_id = f"team_{random.randint(1,5)}"
    created_at = fake.date_time_between(start_date="-7d", end_date="now")
    day = created_at.strftime("%Y-%m-%d")
    sender = {
        "sender_id": f"user_{random.randint(1,20)}",
        "sender_email": fake.email(),
        "display_name": fake.first_name()
    }
    channel = random.choice(channels)
    content = fake.sentence(nb_words=10)
    metadata = [{"key": "sentiment", "value": random.choice(["positive", "neutral", "negative"])}]

    session.execute(insert_cql, (team_id, day, uuid.uuid4(), created_at, sender, channel, content, metadata))

print("✅ Inserted 200 fake messages.")
cluster.shutdown()