## Caching Strategy

**Applies to:** any task considering a cache, adding a cache layer, or
extending an existing cache — from in-process memoization to CDN and read
replicas.

**Tier:** reference

---

### 1. Rule

Cache only after measurement shows the cache pays for its invalidation cost.
Every cache must have a defined key, an explicit TTL or invalidation trigger,
and a documented staleness tolerance — a cache with unclear invalidation is a
second source of truth that eventually serves wrong data.

### 2. Why this matters (long-term cost of getting it wrong)

- A cache with no invalidation plan serves stale or poisoned data after every
  write, and the bug is intermittent and user-visible — worse than the slow
  query it was meant to fix.
- Caching without a measured win adds latency, memory, and a failure domain
  (cache node down, eviction storm) to a path that didn't need it.
- Cache keys that don't capture all relevant inputs serve one caller's answer
  to another caller, silently.
- Hot-key and thundering-herd problems surface only at peak load, turning a
  "helpful" cache into the outage it was meant to prevent.

### 3. Decision checklist

- [ ] Is the cache justified by measured read heat / cost — is the read path
      actually hot, or would a better query or index suffice?
- [ ] Does the cache key capture every input that changes the result?
- [ ] Is staleness tolerance stated, and does the TTL / invalidation enforce
      it?
- [ ] Is there a defined write path that invalidates or updates the cache
      (write-through vs invalidate-on-write vs TTL-only)?
- [ ] Is cache failure handled — miss and cache-down degrade to the source of
      truth, not to an error?

### 4. Default pattern

1. **Cache only the expensive, stable, and hot.** Measure read amplification
   first (see `architecture/performance-engineering.md`); a cache is a perf
   tool, not a default.
2. **Prefer invalidate-on-write over TTL-only** for data that users write:
   on any successful write, evict the affected keys in the same unit of work
   as the write where possible.
3. **Keep keys deterministic and complete** — include every input that
   affects the value (ids, filters, versions). Version the cache format
   (`v1:users:42:profile`) so a format change can't serve old shapes.
4. **Use short TTLs as a backstop**, not the primary mechanism, unless
   staleness is genuinely tolerable (e.g. a trending list).
5. **Degrade to the source of truth on miss and on failure** — the cache is
   an accelerator, never a correctness gate.
6. **Guard against herd effects** on hot keys: single-flight the miss,
   stagger TTLs, or refresh-on-read with a short revalidate window.

```
get_profile(user_id):
  key = f"v1:user:{user_id}:profile"
  hit = cache.get(key);  if hit: return hit          # backstop TTL still applies
  val = source_of_truth.fetch(user_id)               # measured expensive
  cache.set(key, val, ttl=60)                        # backstop
  return val

# write path invalidates, same transaction scope where possible:
write_profile(user_id, data):
  db.update(...)
  cache.delete(f"v1:user:{user_id}:profile")
```

### 5. When the default doesn't apply

- **Explicit user scope** — user accepts staleness for a feature (e.g. "the
  leaderboard can be 5 minutes behind"); then a TTL-only cache is correct.
- **Real hard constraint** — the source of truth is slow or rate-limited and
  the caller cannot tolerate its latency at all; the cache is then a
  correctness-of-availability decision, which must be recorded.
- **Disposable/demo context** — throwaway memoization in a script with no
  writers doesn't need an invalidation strategy.

### 6. Red flags (stopgap smells specific to this file)

- "We can invalidate later" or "just add a cache" with no measured need.
- Cache keys that omit a filter or parameter that changes the result.
- Writing to the cache but never deleting/updating on writes.
- No TTL and no invalidation — a cache that only grows and can only be fixed
  by flushing.
- Reading from cache with no fallback, so a cache failure takes the service
  down.
- Caching per-request data (sessions, one-shot queries) where the cost
  exceeds the benefit.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "deferring write-through invalidation on
   the profile cache; TTL-only for now."
2. Name the specific cost of not fixing it: e.g. "users can see stale profiles
   for up to the TTL after editing; support complaints until invalidation is
   wired."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: ADR
   entry "profile cache: add invalidate-on-write, owner: [team], trigger:
   first stale-profile report or the feature's first external user."

### 8. Cross-references

- See also: `architecture/performance-engineering.md` — caching must be
  justified by measurement, and wins need benchmarks.
- See also: `architecture/concurrency-and-consistency.md` — caches add
  staleness; the consistency model must cover cache reads.
- See also: `architecture/database-and-query-design.md` — a better query or
  index often removes the need for a cache.
- See also: `references/operations/monitoring-and-alerting.md` — hit ratio,
  evictions, and staleness need metrics.
- See also: `core/architecture-decisions.md` — cache ownership and
  invalidation strategy are recorded decisions.
