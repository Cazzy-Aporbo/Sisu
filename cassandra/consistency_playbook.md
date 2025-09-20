# Consistency Playbook — by Cazzy 

## Replication & CL “fast map”
- **RF=3 per DC** (typical).  
- **Local reads/writes:** `LOCAL_QUORUM` best default (latency + safety).
- **Cross-DC:** let the cluster replicate; avoid `QUORUM` across regions on hot paths.

| Operation            | Recommended CL          | Why |
|----------------------|-------------------------|-----|
| Hot writes           | `LOCAL_QUORUM`          | Fast + safe w/ RF=3 |
| Hot reads            | `LOCAL_QUORUM`          | Fresh enough; avoids stale at ONE |
| Idempotent retry     | Mark statement idempotent| Enables safe speculative retry |
| LWT uniqueness       | `SERIAL` / `LOCAL_SERIAL` + read `LOCAL_QUORUM` | Correctness > latency |
| Analytics scan       | `ONE`/`LOCAL_ONE`       | Cheaper fanout, stale OK |

### Multi-region patterns
- **Dual-home clients**: LB policy keeps reads in-region (token aware + DC aware).
- **Global dashboards**: `LOCAL_QUORUM` per region; aggregate in app.
- **Disaster drills**: can the app switch DC and clear paging state?

### “Smells”
- Secondary indexes for high cardinality = 🚫  
- Unbounded partitions (>100MB) = 🚫  
- `ALLOW FILTERING` in hot path = 🚫  
- Huge logged batches across many partitions = 🚫

### Operational guardrails
- TWCS + TTL for time series; run repairs regularly.  
- Trace occasionally (`cassandra-driver` tracing) and watch virtual tables for read repair/liveness.  
