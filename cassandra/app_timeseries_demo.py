"""
app_timeseries_demo.py — Advanced Cassandra driver patterns by Cazzy 

Highlights:
• Prepared statements + bound parameters
• Idempotent writes and retry policies
• Dual-write to query tables (user-month + category-month)
• Paging through results (fetch_size)
• Query tracing for perf debug
• LWT demo (opt-in)
"""

from cassandra.cluster import Cluster, ExecutionProfile, EXEC_PROFILE_DEFAULT
from cassandra.policies import WhiteListRoundRobinPolicy, RetryPolicy
from cassandra.query import SimpleStatement, PreparedStatement, BatchStatement, BatchType
from cassandra import ConsistencyLevel
from datetime import datetime
from dateutil.relativedelta import relativedelta
import uuid, os, itertools

CONTACT_POINTS = os.getenv("CASS_CONTACT_POINTS", "127.0.0.1").split(",")
KEYSPACE = os.getenv("CASS_KEYSPACE", "finance")

# --- Execution profile: paging + sensible consistency ---
profile = ExecutionProfile(
    request_timeout=10.0,
    consistency_level=ConsistencyLevel.LOCAL_QUORUM
)

cluster = Cluster(
    CONTACT_POINTS,
    execution_profiles={EXEC_PROFILE_DEFAULT: profile},
    load_balancing_policy=WhiteListRoundRobinPolicy(CONTACT_POINTS),
    protocol_version=4
)
session = cluster.connect(KEYSPACE)

# --- Prepared statements ---
ins_user = session.prepare("""
INSERT INTO tx_by_user_month (user_id, yyyymm, event_time, tx_id, category, amount, note, monthly_budget, is_deleted)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) USING TTL ?
""")
ins_user.is_idempotent = True  # safe for retries if tx_id is unique and TTL constant

ins_cat = session.prepare("""
INSERT INTO tx_by_category_month (category, yyyymm, event_time, tx_id, user_id, amount, note)
VALUES (?, ?, ?, ?, ?, ?, ?) USING TTL ?
""")
ins_cat.is_idempotent = True

# Optional LWT for uniqueness (use sparingly)
ins_user_lwt = session.prepare("""
INSERT INTO tx_by_user_month (user_id, yyyymm, event_time, tx_id, category, amount, note)
VALUES (?, ?, ?, ?, ?, ?, ?) IF NOT EXISTS
""")
ins_user_lwt.is_idempotent = False  # LWT is not idempotent by default due to Paxos side effects

def yyyymm(dt: datetime) -> int:
    return dt.year * 100 + dt.month

def dual_write(user_id: str, dt: datetime, category: str, amount: float, note: str,
               monthly_budget=None, ttl_seconds=18*30*24*3600, use_lwt=False):
    """Write a transaction to both query tables. Idempotent if tx_id is constant per call."""
    ym = yyyymm(dt)
    tx_id = uuid.uuid4()  # ensure caller reuses for retries to stay idempotent, or pass in
    args_user = (user_id, ym, dt, tx_id, category, amount, note, monthly_budget, False, ttl_seconds)
    args_cat  = (category, ym, dt, tx_id, user_id, amount, note, ttl_seconds)

    if use_lwt:
        # Do LWT to user table, then best-effort mirror. Consider compensating write if LWT success.
        result = session.execute(ins_user_lwt, (user_id, ym, dt, tx_id, category, amount, note))
        applied = getattr(result.one(), "applied", False)
        if applied:
            session.execute(ins_cat, args_cat)
        return applied, tx_id

    # Preferred: UNLOGGED dual write (fast), rely on idempotence of tx_id and retries.
    batch = BatchStatement(BatchType.UNLOGGED)
    batch.add(ins_user, args_user)
    batch.add(ins_cat, args_cat)
    session.execute(batch)
    return True, tx_id

def seed_demo(user="u_demo", months=3, per_month=5):
    """Seed a few months of transactions for demo."""
    now = datetime.utcnow().replace(day=15, hour=12, minute=0, second=0, microsecond=0)
    cats = ["groceries","rent","utilities","coffee","salary"]
    for m in range(months):
        dt0 = now - relativedelta(months=m)
        for k in range(per_month):
            dt = dt0.replace(day=min(25, 3 + k*4))
            cat = cats[(m + k) % len(cats)]
            amt = 200.0 if cat=="groceries" else (1200.0 if cat=="rent" else (80.0 if cat=="utilities" else (5.0 if cat=="coffee" else 3000.0)))
            note = f"{cat} seed"
            dual_write(user, dt, cat, amt, note, monthly_budget=2500.0, ttl_seconds=3600*24*365)  # 1yr TTL

def page_last_n(user="u_demo", yearmonth=None, page_size=5, max_pages=3, trace=False):
    """Page through last events for a user-month."""
    if yearmonth is None:
        dt = datetime.utcnow()
        yearmonth = yyyymm(dt)

    q = SimpleStatement(
        "SELECT event_time, tx_id, category, amount FROM tx_by_user_month WHERE user_id=%s AND yyyymm=%s",
        fetch_size=page_size
    )
    rs = session.execute(q, (user, yearmonth), trace=trace)
    page = 0
    for row in rs:
        print(f"{row.event_time}  {row.category:10s}  {row.amount}")
        # handle page boundaries
        if rs.current_rows is not None and rs.remaining_in_page == 0:
            page += 1
            print(f"--- page {page} complete ---")
            if page >= max_pages:
                break
            rs = session.execute(q, (user, yearmonth), paging_state=rs.paging_state)

    if trace and hasattr(rs, "get_query_trace"):
        tr = rs.get_query_trace()
        print("Trace coordinator:", tr.coordinator)
        for ev in tr.events:
            print(f"{ev.source_elapsed}μs {ev.description}")

if __name__ == "__main__":
    # 1) seed
    seed_demo()

    # 2) page results
    print("\n== Paged results ==")
    page_last_n(page_size=4, max_pages=2, trace=False)

    # 3) LWT example
    print("\n== LWT uniqueness demo ==")
    ok, tx = dual_write("u_demo", datetime.utcnow(), "rent", 1200.0, "lwt test", use_lwt=True)
    print("LWT applied:", ok, "tx_id:", tx)

    cluster.shutdown()
