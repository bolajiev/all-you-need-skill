## Performance Engineering

**Applies to:** any task where a latency or throughput budget exists, where a
hot path is being written or changed, or where performance is raised as a
concern during design or review.

**Tier:** reference

---

### 1. Rule

Meet the stated latency/throughput budget — and profile before you optimize.
Never ship code you know is pathologically slow (obvious N+1, O(n²) in a hot
loop, unbounded work per request), but never guess where the bottleneck is:
measure first, then optimize the measured hot spot.

### 2. Why this matters (long-term cost of getting it wrong)

- Guessing wrong spends the budget on a cold path while the real bottleneck
  stays; the fix is rework plus a budget still blown in production.
- Premature micro-optimization adds complexity and indirection that every
  future change pays for, for zero measured gain.
- Shipping known-slow code to production makes the budget someone else's
  outage: scaling fixes hide the bug, and the root cause gets a perf ticket
  it never deserved.
- No budget and no benchmark means "fast enough" is never defined, so
  performance regressions arrive silently and are only caught by users.

### 3. Decision checklist

- [ ] Is there an explicit latency/throughput budget, and do I know how the
      work will be measured against it?
- [ ] Have I profiled / benchmarked before changing any code for speed?
- [ ] Does the current design have an obvious algorithmic problem (N+1,
      O(n²), unbounded loops) in the hot path?
- [ ] Is the hot path's work bounded and predictable per request (no hidden
      synchronous calls, no unbounded scans)?
- [ ] Is the optimization measured in a benchmark that runs in CI, so the
      win — and future regressions — are visible?

### 4. Default pattern

1. **Measure first.** Identify the hot path, then profile (CPU, allocation,
   I/O) or benchmark before touching implementation. `perf`,
   `flamegraph`, `pprof`, or a benchmark harness — whatever fits the stack.
2. **Fix algorithmic complexity before constant factors.** A query count,
   an O(n²) loop, or a redundant recompute beats hand-tuned loops 100% of
   the time.
3. **Write a regression benchmark for the win.** Prove the change against a
   before/after run and keep it in CI so the budget is enforced going forward.
4. **Look at the data flow, not just the code:** row-by-row work, repeated
   lookups, eager work a caller won't use, and serial round-trips are the
   usual offenders — batch, dedupe, and defer before optimizing arithmetic.
5. **Move cost to the right layer** (cache, index, worker, lazy load) only
   after measurement shows that layer is the bottleneck.

```
hot_path(request):
  # 1. profile first — do NOT guess
  benchmark { feature.run(request) }          # before
  # 2. fix the algorithmic issue you measured
  feature.run(request)   # batched query replaces per-row lookup
  benchmark { feature.run(request) }          # after — record both
  # 3. leave the benchmark as a CI regression guard
```

### 5. When the default doesn't apply

- **Explicit user scope** — user says "don't spend time on perf, this is a
  prototype"; the budget is the user's to waive, but still fix anything
  pathologically slow before it reaches a shared environment.
- **Real hard constraint** — no profiler available on the target (embedded,
  sandboxed) and no budget tooling exists; then reason from first principles
  and mark the measurement gap explicitly.
- **Disposable/demo context** — throwaway code that is never shipped or
  load-tested; no CI benchmark needed.

### 6. Red flags (stopgap smells specific to this file)

- Optimizing code before writing a benchmark or profiler trace.
- "This might be slow" as the sole justification for a change — no numbers.
- A hot-path query that does per-row work (N+1) or an unbounded `SELECT *`.
- Caching or threading added to fix a bottleneck that was never measured.
- A one-off perf fix with no regression benchmark — the "win" is unverifiable
  and silently reversible.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "deferring the CI benchmark and the
   index-based query rewrite on the orders hot path."
2. Name the specific cost of not fixing it: e.g. "the endpoint stays at
   ~8x the p99 budget; the rewrite becomes a separate perf ticket and the
   budget is unprotected against regressions until it lands."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: ADR
   entry "orders listing: benchmark + index rewrite, owner: [team], trigger:
   next perf budget review or the first p99 alert above target."

### 8. Cross-references

- See also: `architecture/database-and-query-design.md` — most hot-path cost
  is query cost; the index and N+1 fixes live there.
- See also: `architecture/caching-strategy.md` — caching is a performance
  tool that must be justified by measurement.
- See also: `architecture/concurrency-and-consistency.md` — parallelism
  changes complexity but adds race surface.
- See also: `quality/testing-strategy.md` — benchmarks belong in CI as
  regression guards.
- See also: `core/architecture-decisions.md` — record measurement-driven
  performance decisions and any budget deviations.
