## Performance Testing

**Applies to:** any change that makes a performance claim ("fast enough", "handles N users"), touches a hot path (code on a request, loop, or critical-call route), or introduces load-sensitive behavior such as new queries, polling, or background jobs.

**Tier:** reference

---

### 1. Rule

Verify performance claims with measurement — a profile, a load test, or a benchmark — before shipping the change. Do not accept "it feels fast" or "it should be fine" as evidence, and do not merge anything that makes an existing behavior measurably worse without a recorded decision.

### 2. Why this matters (long-term cost of getting it wrong)

- An unmeasured performance claim is a guess, and the first person who hits the wrongness is a user under real load — at the point where it's most expensive to fix and hardest to profile.
- Regressions slip silently: a change that adds one query to a hot path is invisible in review, then becomes the reason requests time out at a traffic level nobody anticipated.
- Without a baseline and a budget, nobody can tell whether a later change is "better" or just "different"; every decision becomes a re-argument.
- Perf work without a regression test gets re-broken by the next refactor, because nothing stops the drift.

### 3. Decision checklist

- [ ] Am I making a performance claim? If yes, do I have a measurement for it?
- [ ] Does this change touch a hot path (per-request, per-loop, per-cell, on a critical-call route)?
- [ ] Is there an existing perf baseline or budget for this behavior? Am I violating it?
- [ ] Have I profiled before optimizing — do I know what is actually slow, not just what I suspect?
- [ ] Is there a regression test that fails if this performance characteristic regresses?
- [ ] Have I checked the loaded case, not just the single-user happy path?

### 4. Default pattern

1. **Profile before optimizing** — find the real bottleneck first; don't optimize from suspicion.
2. **Measure on a representative setup** — similar data volume, similar environment, not a trivially empty dataset that hides N+1 or full-scan behavior.
3. **Establish the baseline and budget** — record current numbers and the accepted threshold before making the change, so the claim is "X is ≤ N ms at M concurrent requests", not "faster than before".
4. **Add a regression test that guards the budget** — a load test or benchmark wired into CI that fails when the budget is exceeded or a trend crosses the threshold.
5. **For load-sensitive changes, run a load/stress test** — determine the request rate or concurrency the change survives, and state the number.

```
# typical sequence for a hot-path change
1. profile the current path         # e.g. pprof / --perf / cProfile
2. note baseline: latency + throughput on a realistic dataset
3. make the change
4. re-measure with the same method
5. if worse: decide (revert, optimize, or record the budget change)
6. add a CI perf test that fails above the budget
#   e.g. a threshold-based benchmark or an autocannon/k6 smoke load
```

### 5. When the default doesn't apply

- **Explicit user scope**: the user says this is a demo/throwaway path with no traffic, and names the perf expectations or says none are owed.
- **The change provably cannot affect performance** — a pure comment, formatting, or a read-only doc edit; no code on any hot path changed.
- **A real hard constraint**: no load-testing tooling available in the environment at all — then the profile (even a coarse one) is still owed as the fallback evidence, and the gap is flagged.

### 6. Red flags (stopgap smells specific to this file)

- "It feels fast" or "should be fine" as the whole justification for a perf claim.
- Optimizing a path you haven't profiled.
- Measuring on a 10-row dataset when production has a million rows.
- A regression that shows up only under load being merged "because tests pass" (the tests just never ran under load).
- Removing or weakening an existing perf test to make CI green.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:
1. Name what's being deferred — e.g., "a load test for the new batch-import endpoint; I only ran a single-user timing."
2. Name the specific cost — e.g., "import may exhaust memory or time out under concurrent use, and the failure only shows in production at peak."
3. Write it into an ADR or a tracked TODO with an owner and a trigger (e.g., "run a load test before this endpoint is exposed to more than a handful of users").

### 8. Cross-references

- See also: `references/quality/testing-strategy.md` for how perf tests slot into the overall test levels and suite.
- See also: `references/quality/observability.md` for the runtime metrics (latency, throughput, saturation) that back up or contradict perf claims.
- See also: `references/architecture/performance-engineering.md` for techniques when profiling reveals a real bottleneck.
- Escalates to: `core/definition-of-done.md` when a perf claim is part of the task's done criteria and cannot be measured.
- Escalates to: `core/architecture-decisions.md` when the budget itself must change.
