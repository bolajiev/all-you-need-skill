## Error Handling and Resilience

**Applies to:** any code that calls external systems (network, DB, queue,
third-party APIs), any public entry point, and any worker or async job that
must survive failures.

**Tier:** reference

---

### 1. Rule

Design for failure at the code level: bound every external call with a
timeout, retry only idempotent operations with backoff and jitter, use
circuit breakers at dependency boundaries, and fail by degrading gracefully —
never hang, never crash, never retry without bound.

### 2. Why this matters (long-term cost of getting it wrong)

- A missing timeout turns a slow dependency into a hung service that exhausts
  its own concurrency; one dependency outage becomes a full-site outage.
- Unbounded or no-backoff retries are a thundering herd: a recovering
  dependency gets hammered, retries collide with the next outage, and
  cascading failure is the result.
- Non-idempotent retries duplicate side effects (double charges, double
  sends) unless guarded by idempotency.
- Failure handling that only lives in a try/catch means upstream callers get
  no signal, retries pile up on the same broken path, and the "handle it
  elsewhere" assumption leaves every layer doing nothing.

### 3. Decision checklist

- [ ] Does every external call have a timeout, and is the timeout smaller than
      the caller's own budget?
- [ ] Are retries present only for idempotent operations, with exponential
      backoff + jitter and a hard max?
- [ ] Is there a circuit breaker (or equivalent) at dependency boundaries so
      a failing dependency stops being hammered?
- [ ] Is there a defined fallback / degraded behavior for each failing
      dependency — and is the failure surfaced to logs/metrics, not swallowed?
- [ ] Are queues and worker pools bounded, so backpressure is real and doesn't
      grow unbounded in memory?

### 4. Default pattern

1. **Every external call gets a timeout** sized under the caller's budget,
   defaulting to the call's own contract (e.g. 10s hard cap, often less).
2. **Retry only the idempotent**: exponential backoff with jitter
   (`min(2^n * base, cap) + jitter`), a small max (2–3), and retry only on
   retryable errors (5xx, timeouts, network) — never on 4xx.
3. **Circuit break at dependency boundaries**: open after N consecutive
   failures, half-open after a cooldown, so a down dependency is probed
   instead of hammered.
4. **Degrade gracefully**: every dependency has a fallback (cached value,
   degraded response, clear error to the caller) and the failure path emits a
   log + metric, never `except: pass`.
5. **Bound everything concurrent**: bounded queues and worker pools; when the
   queue is full, apply backpressure or fail fast — do not buffer unboundedly.
6. **Handle async jobs the same way**: timeouts, bounded retries with
   backoff, and dead-letter routes so a poison message stops blocking the
   queue.

```
async call_with_resilience(dep):
  for attempt in range(0, MAX_RETRIES):           # idempotent only
    try:
      with timeout(TIMEOUT_S):
        return await dep.request()
    except (TimeoutError, TransientError) as e:
      if not circuit.allows():                    # open circuit -> degrade now
        break
      await asyncio.sleep(backoff(attempt) + jitter())
  # degrade, never crash, never silently swallow:
  logger.error("dep degraded", extra={...}); metric("dep.failed").inc()
  return FALLBACK_VALUE if use_fallback() else raise DegradedError(...)
```

### 5. When the default doesn't apply

- **Explicit user scope** — user says "this call may block or fail silently
  in the prototype"; waiving is the user's call, but production paths still
  follow the pattern.
- **Real hard constraint** — a dependency offers no timeout or retry
  controls (e.g. a blocking SDK); then put the timeout/retry at the layer
  you control and document it.
- **Disposable/demo context** — local scripts with a single caller don't need
  circuit breakers, but should not be copied into service code as-is.

### 6. Red flags (stopgap smells specific to this file)

- `except: pass` / swallowed errors with no log, metric, or fallback.
- Retrying POSTs or other non-idempotent operations without idempotency keys.
- No timeout on any external call, or a timeout larger than the caller's
  budget.
- Fixed 0ms retries or `while True:` retry loops.
- Unbounded in-memory queues or worker pools.
- Circuit breaker that retries so fast it never recovers, or so slow the
  dependency's outage is silently hidden.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "deferring the circuit breaker on the
   report-export dependency; bounded retries only."
2. Name the specific cost of not fixing it: e.g. "when exports go down, every
   job retries against a dead service for minutes, delaying the queue and
   masking the outage until alerts fire."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: ADR
   entry "export dependency: add circuit breaker, owner: [team], trigger:
   first export outage or when dependency error rate exceeds 5% for 10 min."

### 8. Cross-references

- See also: `architecture/idempotency.md` — retries are only safe when the
  operation is idempotent.
- See also: `architecture/concurrency-and-consistency.md` — bounded queues
  and worker pools are concurrency decisions.
- See also: `references/quality/observability.md` — failures must be
  logged and metriced, not swallowed.
- See also: `references/operations/monitoring-and-alerting.md` — timeouts,
  retries, and circuit state need alerting.
- See also: `references/operations/sandboxing-and-blast-radius.md` — resilience
  is how one dependency's failure is kept inside its blast radius.
- See also: `core/failure-recovery.md` — how the agent recovers its own
  work; same discipline applies to the code it writes.
- See also: `core/architecture-decisions.md` — resilience strategies are
  recorded decisions.
