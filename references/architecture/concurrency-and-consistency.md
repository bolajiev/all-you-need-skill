## Concurrency and Consistency

**Applies to:** any task that involves shared mutable state, multiple threads,
multiple processes, async tasks, queues, or distributed systems where ordering
or atomicity guarantees must be explicit.

**Tier:** reference

---

### 1. Rule

Name the consistency model before writing any concurrent code: choose strong
consistency where correctness is user-visible, eventual where the domain
tolerates it — and make every shared-state access, ordering guarantee, and
locks-with-held bound explicit and reviewable.

### 2. Why this matters (long-term cost of getting it wrong)

- A race that only fires under load is the most expensive bug class there is:
  it survives review, passes tests, and corrupts data in production with no
  repro.
- Unbounded or unheld locks deadlock under contention, and a deadlock/race
  root-caused months later has no "fix"; it has a rewrite.
- Mixed consistency without a written contract means different components
  disagree about read-your-writes, and the disagreement surfaces as
  "impossible" bugs in distributed systems.
- Every assumed ordering (thread A before thread B, at-least-once, no
  duplicates) that isn't stated is a guarantee the system will eventually
  break.

### 3. Decision checklist

- [ ] Have I stated the consistency model (strong vs eventual) and the
      ordering/atomicity guarantees this component must provide?
- [ ] Is all shared mutable state guarded, and is the guard type (lock,
      atomic, transaction, queue) correct for the access pattern?
- [ ] Are lock scopes and durations bounded — no lock held across I/O or
      another lock acquisition?
- [ ] Does the code assume an ordering or a read-your-writes guarantee that
      nothing actually enforces?
- [ ] For distributed/async flows, is exactly-once vs at-least-once stated,
      and is idempotency handled at the consumer (see
      `architecture/idempotency.md`)?

### 4. Default pattern

1. **Default to strong consistency for state a user relies on** (balances,
   accounts, orders) — use transactions/DB constraints, not check-then-write
   in app code.
2. **Minimize shared mutable state.** Prefer immutable data, pure
   functions, and single-writer ownership; only the few genuine coordination
   points get locks.
3. **Choose the smallest correct primitive**: atomic counter over a mutex;
   a queue/actor over shared buffers; a DB `UPDATE ... WHERE` over
   read-modify-write.
4. **Keep locks small and explicit** — never hold a lock across network I/O
   or user code that can block; use try-lock/timeout so contention fails
   loud instead of deadlocking.
5. **State ordering guarantees in comments and ADRs**: is message delivery
   per-key ordered? Is the cache stale-tolerant? Write it down.

```
// single-writer pattern for a counter without a mutex:
func (c *Counter) Inc() { atomic.AddInt64(&c.v, 1) }

// check-then-write MUST be a transaction, not two calls:
//   bad: if row.available: spend(row)            -- race
//   ok:  UPDATE accounts SET bal=bal-? WHERE id=? AND bal>=?
//        -- affected rows == 0 means insufficient, atomically
```

### 5. When the default doesn't apply

- **Explicit user scope** — user says "this dashboard read can be
  eventually consistent / stale is fine"; the user owns the trade-off.
- **Real hard constraint** — the backing store offers only eventual
  consistency (e.g. a CDN or a leaderless KV); then design reads and
  conflicts for that model explicitly rather than pretending otherwise.
- **Disposable/demo context** — throwaway scripts or demos with no
  concurrent users don't need lock discipline, but must not be promoted to
  shared environments as-is.

### 6. Red flags (stopgap smells specific to this file)

- Reading a field, computing, then writing it back without a transaction,
  lock, or atomic (check-then-act).
- A lock acquired and released in different methods, or held across I/O.
- "This is fine, it's single-threaded" on code that runs in workers, async
  callbacks, or multiple pods.
- Eventual consistency chosen with no written conflict-resolution strategy.
- Silent retries that can double-apply without idempotency keys.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "deferring the idempotency key on the
   worker retry path and allowing at-least-once delivery for now."
2. Name the specific cost of not fixing it: e.g. "a retried job can create
   duplicate side effects; reconcile scripts are needed until the key is
   added."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: ADR
   entry "worker queue: add consumer idempotency keys, owner: [team],
   trigger: first duplicate detected in prod or the queue's first cross-team
   consumer."

### 8. Cross-references

- See also: `architecture/idempotency.md` — at-least-once delivery is only
  safe when consumers are idempotent.
- See also: `architecture/database-and-query-design.md` — transactions and
  atomic `UPDATE ... WHERE` are the strong-consistency workhorses.
- See also: `architecture/caching-strategy.md` — caches introduce staleness
  and write-behind consistency questions.
- See also: `architecture/performance-engineering.md` — concurrency is a
  perf tool; measure before you parallelize.
- See also: `references/operations/monitoring-and-alerting.md` — contention,
  deadlock, and consistency lag need metrics to be caught.
- See also: `core/architecture-decisions.md` — the chosen consistency model
  is a decision that must be recorded.
