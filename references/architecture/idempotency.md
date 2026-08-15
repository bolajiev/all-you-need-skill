## Idempotency

**Applies to:** any operation that has side effects — writes, payments,
enqueueing, external calls, state transitions — that could be retried, called
twice, or replayed. If a duplicate call would cause a duplicate side effect,
idempotency applies.

**Tier:** reference

---

### 1. Rule

Make every side-effecting operation safe to retry: either naturally idempotent
(unique constraints, set-based updates) or protected by an explicit
idempotency key. Assume the caller may retry at any time — including after the
first attempt succeeded.

### 2. Why this matters (long-term cost of getting it wrong)

- A network timeout that retries a charge or an insert produces a duplicate
  charge or a duplicated row — and customers notice money duplicates before
  anything else.
- Retries after partial success (the write landed, the response didn't) create
  corruption that's invisible until someone reconciles.
- Idempotency bolted on later requires schema changes and backfills across
  existing operations, exactly the migration you'd want to avoid.
- Unsafe retries force callers to invent their own dedupe — inconsistent,
  untested, and usually wrong.

### 3. Decision checklist

- [ ] Does this operation have side effects that a retry would duplicate
      (insert, charge, enqueue, external call)?
- [ ] Is the operation naturally idempotent (unique constraint, SET-based
      update), or does it need an explicit idempotency key?
- [ ] Can the caller supply a stable key for each logical request, independent
      of retries?
- [ ] Does a retry after the original succeeded return the original result
      (or a clear "already processed"), not a second execution?
- [ ] Is the idempotency window long enough for realistic retry delays?

### 4. Default pattern

1. **Prefer natural idempotency first** — a UNIQUE constraint on the natural
   business key (`order reference`, `stripe intent id`, `email+event`) makes
   duplicate inserts fail cleanly and retry-safe.
2. **Use an explicit idempotency key when the natural key isn't stable or
   isn't known in advance** — the client sends a key, the server stores
   `(key, request_hash, result)` and replays the result on repeat keys.
3. **Atomic check-and-store** — claim the key with a unique insert/conditional
   write before doing the side effect; don't check-then-act (race window).
4. **Distinguish three outcomes clearly** — success, "duplicate of a prior
   success (replayed result)", and genuine failure (which the caller may retry).
5. **Document the semantics** at the API surface (see
   `architecture/api-design.md`) — callers must know a retry is safe.

```
idempotent write:
  POST /v1/orders { ..., "idempotency_key": "client-abc" }
  server:
    1. SELECT result WHERE key = 'client-abc'
       -> found: return stored result (200, replayed)
       -> not found: go on
    2. INSERT claim (key, hash, status=in_progress)  # unique on key
       -> violates unique: concurrent retry, return in-progress or wait
    3. do the side effect, record result against key, return it
```

### 5. When the default doesn't apply

- **Pure reads** — GETs and queries have no side effects to duplicate; no
  idempotency machinery needed.
- **Naturally idempotent by construction** — a SET-based update (e.g.
  `UPDATE t SET state='x' WHERE id=1`) applied twice is identical; document
  that it's safe instead of adding keys.
- **Disposable/demo context** — a throwaway prototype may skip the key store;
  flag it so it never becomes the payment path by accident.

### 6. Red flags (stopgap smells specific to this file)

- A write endpoint that could be retried with no key and no unique constraint.
- check-then-act dedupe (read, decide, write) that races under two concurrent
  retries.
- "It's fine, the client won't retry" — clients and networks retry whether you
  planned for it or not.
- An idempotency key stored with no expiration, or results that can't be
  replayed.
- Logs or docs that don't say whether a retry is safe.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "shipping the charge endpoint without an
   idempotency key because the payment provider lacks client keys."
2. Name the specific cost of not fixing it: e.g. "a retried request can double
   charge a customer with no server-side way to catch it."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: ADR
   "charge endpoint relies on client-side retry discipline only — owner:
   [team], trigger: first duplicate-charge report or when the provider gains
   key support."

### 8. Cross-references

- See also: `architecture/api-design.md` — idempotency is part of the contract.
- See also: `architecture/data-modeling.md` — the unique constraint is a schema
  decision.
- See also: `architecture/migration-and-versioning.md` — retrofitting keys is a
  migration.
- See also: `core/definition-of-done.md` — "retried once yields one side
  effect" is part of done for writes.
