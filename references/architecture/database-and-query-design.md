## Database and Query Design

**Applies to:** any task that writes a query, designs an index, models
schema-to-query fit, or touches a read or write path against a database.

**Tier:** reference

---

### 1. Rule

Shape the schema for the queries it must serve, index what is actually queried,
and prove query efficiency — no N+1, no full scans on hot paths — before
calling it done. Query and write design is part of the data model, not an
afterthought.

### 2. Why this matters (long-term cost of getting it wrong)

- An N+1 pattern turns a one-query operation into a request-per-row that
  blows up latency and DB load at real scale, and it is invisible at small
  data sizes.
- A missing index on a hot query path causes a full scan that degrades
  quadratically with data growth and only surfaces as an alert months later.
- A schema that doesn't fit its queries forces heavy joins and app-side
  reshaping; every caller re-derives the shape, and the work is redone for
  each new feature.
- Denormalization without a stated trade-off creates two sources of truth
  that drift, and the drift is a data-correctness bug, not a style issue.

### 3. Decision checklist

- [ ] Have I listed the queries this schema must serve, and does the schema
      support them directly rather than through heavy joins or app-side
      reshaping?
- [ ] Is there an index for each hot-path filter/join/order column, and have
      I checked the query plan (EXPLAIN) rather than assuming?
- [ ] Are reads free of N+1 — batched/joined correctly for the data shapes?
- [ ] If denormalized/cached columns exist, is there a stated write path that
      keeps them consistent?
- [ ] Are read-path and write-path costs considered separately — is this
      optimized for reads at write-path expense, or vice versa, and is that
      the right call?

### 4. Default pattern

1. **Write the query shape first, then check the schema against it.** For
   each feature's read path, list the WHERE/JOIN/ORDER columns, and make sure
   they are indexed and that the shape avoids expensive multi-join reshaping.
2. **Index the queried paths, and verify with the plan** — inspect
   `EXPLAIN ANALYZE` and confirm index usage on hot queries; add a composite
   index when a single column won't serve the filter+order pair.
3. **Eliminate N+1 at the access layer**: batch queries (IN-lists,
   `id IN (...)`), use a single query with the right join, or fetch a
   relation in one call — never a loop issuing per-row queries.
4. **Denormalize only with an owner**: derived/cached columns are acceptable
   when a write path updates them (trigger, transaction, or job) and a
   documented staleness window exists; otherwise keep the data derived in the
   query.
5. **Measure the write path too**: index writes, constraint checks, and
   trigger cost are part of the design — don't over-index columns that are
   only written.

```
-- N+1:  for each order: SELECT * FROM items WHERE order_id = ?
-- fix:
SELECT * FROM orders WHERE id IN ($1, $2, ...)        -- one round trip
SELECT * FROM items  WHERE order_id = ANY($1, ...);

-- verify, don't assume:
EXPLAIN (ANALYZE, BUFFERS)
SELECT ... FROM orders o JOIN customers c ON c.id = o.customer_id
WHERE o.status = 'open' ORDER BY o.created_at DESC;
-- -> confirm index on (status, created_at), join uses PK index
```

### 5. When the default doesn't apply

- **Explicit user scope** — user says "single table, denormalized, don't
  bother with the write path"; the user owns the trade-off, but the drift
  risk must be stated.
- **Real hard constraint** — the DB is third-party/legacy and the schema
  cannot change; then optimize within it (query shaping, covering indexes,
  materialized views) and record the constraint.
- **Disposable/demo context** — scratch or demo data with trivial volume
  doesn't need index verification, but hot paths it shares must still be
  sane before promotion.

### 6. Red flags (stopgap smells specific to this file)

- Per-row queries in a loop over a collection (N+1) — "it's fine for now."
- Writing a query and never checking the plan on a table that will grow.
- A hot filter column with no index, or an index that the plan never uses.
- Denormalized columns with no trigger/job/transaction keeping them in sync.
- Heavy joins doing app-side reshaping that a better schema or view would
  serve directly.
- "We'll add the index when it's slow" on a path users are already on.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "deferring the composite index on
   (status, created_at) and the N+1 batch fix on the orders listing."
2. Name the specific cost of not fixing it: e.g. "order listing does a full
   scan plus per-order item queries; p99 latency and DB load degrade with
   every order until the index and batching land."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: ADR
   entry "orders listing: add (status, created_at) index + batch items fetch,
   owner: [team], trigger: next DB load review or when order volume
   doubles."

### 8. Cross-references

- See also: `architecture/data-modeling.md` — schema shape is decided before
  query design; the two must be reconciled.
- See also: `architecture/performance-engineering.md` — query cost is the
  dominant hot-path cost; measure and benchmark it.
- See also: `architecture/migration-and-versioning.md` — index and schema
  changes are versioned migrations.
- See also: `architecture/concurrency-and-consistency.md` — atomic writes
  and read-consistency expectations live here.
- See also: `architecture/caching-strategy.md` — a better query often
  replaces a cache, and vice versa.
- See also: `references/operations/monitoring-and-alerting.md` — slow-query
  and plan regressions need alerting.
- See also: `core/architecture-decisions.md` — denormalization trade-offs
  are recorded decisions.
