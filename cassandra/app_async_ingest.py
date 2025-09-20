"""
app_async_ingest.py — Async dual-write + rollup writer by Cazzy

Teaches:
• Prepared statements, idempotent flags, unlogged batches
• Async futures with bounded in-flight requests (backpressure)
• Per-row TTL strategy (raw vs rollups)
• Optional LWT path for uniqueness
• Simple rollup writer (daily & monthly)
"""

from cassandra.cluster import Cluster, ExecutionProfile, EXEC_PROFILE_DEFAULT
from cassandra.query import BatchStatement, BatchType
from cassandra import ConsistencyLevel
from datetime import datetime, date
from dateutil.relativedelta import relativedelta
import uuid, os, time, random
from collections import defaultdict, deque

CONTACT_POINTS = os.getenv("CASS_CONTACT_POINTS", "127.0.0.1").split(",")
KEYSPACE = os.getenv("CASS_KEYSPACE", "finance")

profile = ExecutionProfile(
    request_timeout=12.0,
    consistency_level=ConsistencyLevel.LOCAL_QUORUM
)
cluster = Cluster(CONTACT_POINTS, execution_profiles={EXEC_PROFILE_DEFAULT: profile})
session = cluster.connect(KEYSPACE)

ins_user = session.prepare("""
INSERT INTO tx_by_user_month (user_id, yyyymm, event_time, tx_id, category, amount, note, monthly_budget, is_deleted)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) USING TTL ?
"""); ins_user.is_idempotent = True

ins_cat  = session.prepare("""
INSERT INTO tx_by_category_month (category, yyyymm, event_time, tx_id, user_id, amount, note)
VALUES (?, ?, ?, ?, ?, ?, ?) USING TTL ?
"""); ins_cat.is_idempotent = True

ins_latest = session.prepare("""
INSERT INTO tx_by_user_latest (user_id, event_time, tx_id, category, amount) VALUES (?, ?, ?, ?, ?) USING TTL ?
"""); ins_latest.is_idempotent = True

# rollups
upd_daily = session.prepare("""
UPDATE daily_rollup_by_user_cat
SET tx_count = coalesce(tx_count,0) + 1,
    amt_sum  = coalesce(amt_sum,0) + ?,
    amt_min  = CASE WHEN amt_min IS NULL OR ? < amt_min THEN ? ELSE amt_min END,
    amt_max  = CASE WHEN amt_max IS NULL OR ? > amt_max THEN ? ELSE amt_max END
WHERE user_id=? AND day=? AND category=?;
""")  # avg & z hints computed in app

upd_month = session.prepare("""
UPDATE monthly_rollup_by_user
SET tx_count = coalesce(tx_count,0) + 1,
    amt_sum  = coalesce(amt_sum,0) + ?,
    avg_ticket = (coalesce(amt_sum,0) + ?) / (coalesce(tx_count,0) + 1)
WHERE user_id=? AND yyyymm=?;
""")

def ym(dt: datetime) -> int: return dt.year*100 + dt.month

def seed_stream(n=5000, users=50):
    cats = ["groceries","rent","utilities","coffee","salary"]
    for i in range(n):
        u = f"u{1 + (i % users)}"
        cat = random.choice(cats)
        amt = {"groceries": 40+random.random()*120, "rent": 1200.0,
               "utilities": 60+random.random()*40, "coffee": 3+random.random()*4,
               "salary": 2800+random.random()*500}[cat]
        ts = datetime.utcnow() - relativedelta(days=random.randint(0, 60))
        note = f"{cat} #{i}"
        yield u, ts, cat, amt, note

MAX_IN_FLIGHT = 128
in_flight = deque()

def drain():
    while len(in_flight) >= MAX_IN_FLIGHT:
        fut = in_flight.popleft()
        fut.result()  # bubble failures

def write_event(u: str, ts: datetime, cat: str, amt: float, note: str):
    yymm = ym(ts); tx = uuid.uuid4()
    # TTL policy
    ttl_raw   = 3600*24*365     # 12 months
    ttl_index = 3600*24*540     # 18 months (category/latest indexes)
    # raw + query tables
    b = BatchStatement(BatchType.UNLOGGED)
    b.add(ins_user,   (u, yymm, ts, tx, cat, amt, note, 2500.0, False, ttl_raw))
    b.add(ins_cat,    (cat, yymm, ts, tx, u, amt, note, ttl_index))
    b.add(ins_latest, (u, ts, tx, cat, amt, ttl_index))
    fut = session.execute_async(b)
    in_flight.append(fut)

    # rollups (cheap, small writes)
    day = date(ts.year, ts.month, ts.day)
    in_flight.append(session.execute_async(upd_daily, (amt, amt, amt, amt, amt, u, day, cat)))
    in_flight.append(session.execute_async(upd_month, (amt, amt, u, yymm)))

if __name__ == "__main__":
    t0 = time.time()
    for u, ts, cat, amt, note in seed_stream():
        drain()
        write_event(u, ts, cat, amt, note)

    # finish
    while in_flight:
        in_flight.popleft().result()
    print(f"ingest complete in {time.time()-t0:.2f}s")
    cluster.shutdown()
