"""
app_consistency_explorer.py — Try different CLs & see latency/traces (by Cazzy 💙)

Run:
  python app_consistency_explorer.py LOCAL_ONE 10
  python app_consistency_explorer.py LOCAL_QUORUM 10
"""

import sys, time, os
from cassandra.cluster import Cluster, ExecutionProfile, EXEC_PROFILE_DEFAULT
from cassandra import ConsistencyLevel
from cassandra.query import SimpleStatement

CL_MAP = {
    "ONE": ConsistencyLevel.ONE,
    "LOCAL_ONE": ConsistencyLevel.LOCAL_ONE,
    "QUORUM": ConsistencyLevel.QUORUM,
    "LOCAL_QUORUM": ConsistencyLevel.LOCAL_QUORUM,
}

CONTACT_POINTS = os.getenv("CASS_CONTACT_POINTS", "127.0.0.1").split(",")
KEYSPACE = os.getenv("CASS_KEYSPACE", "finance")

def run(cl_name="LOCAL_QUORUM", iters=10):
    profile = ExecutionProfile(request_timeout=8.0, consistency_level=CL_MAP[cl_name])
    cluster = Cluster(CONTACT_POINTS, execution_profiles={EXEC_PROFILE_DEFAULT: profile})
    s = cluster.connect(KEYSPACE)

    q = SimpleStatement(
        "SELECT event_time, category, amount FROM tx_by_user_latest WHERE user_id=%s LIMIT 50",
        fetch_size=25
    )
    user = "u_demo"
    lat = []
    for i in range(iters):
        t0 = time.time()
        rs = s.execute(q, (user,), trace=True)
        cnt = sum(1 for _ in rs)  # exhaust iterator (paging)
        lat.append(time.time()-t0)
        tr = rs.get_query_trace()
        print(f"iter {i+1:02d}  rows={cnt}  latency={lat[-1]*1000:.1f}ms  coordinator={tr.coordinator}")
    cluster.shutdown()
    print(f"\nCL={cl_name}  avg={sum(lat)/len(lat)*1000:.1f}ms  p95={sorted(lat)[int(0.95*(len(lat)-1))]*1000:.1f}ms")

if __name__ == "__main__":
    cl = sys.argv[1] if len(sys.argv)>1 else "LOCAL_QUORUM"
    it = int(sys.argv[2]) if len(sys.argv)>2 else 8
    run(cl, it)
