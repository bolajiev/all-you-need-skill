## Cost Modeling

**Applies to:** any task where the agent estimates or tracks the cost of doing
work — time, compute, or money — before starting, during execution, and after
completion. Applies to "how long will this take", "how much will this cost",
and "did we stay in budget".

**Tier:** reference

---

### 1. Rule

Estimate the cost of the work up front in the same units the user pays in,
track it against the estimate as you go, and report the variance at the end.
An unquantified task has no way to detect that it's overrunning.

### 2. Why this matters (long-term cost of getting it wrong)

- An unbounded task silently consumes time or budget past the point where the
  user could have redirected it — "why didn't anyone say it was going to cost
  this much" becomes an incident.
- An estimate stated in the wrong unit (hours when the user pays in money,
  abstract "effort" when they pay in wall-clock) is unverifiable and
  uncontestable.
- With no baseline, "done" has no cost attached, so future estimates have no
  calibration data and repeat the same miss.
- Underestimating compute or spend on a repeated job (cron, batch, API) turns
  a one-time rounding error into a recurring overrun.

### 3. Decision checklist

- [ ] Can I state the expected cost in the user's unit (time, compute,
      money) before starting?
- [ ] What drives this cost, and which driver dominates (hours, requests,
      data volume, retries)?
- [ ] Is the estimate bounded — a range or a cap, not a single optimistic
      number?
- [ ] Can I detect overrun mid-task, or only at the end?
- [ ] Was the final cost reported against the estimate, with the variance
      explained?

### 4. Default pattern

1. **Estimate before starting.** Break the task into its dominant cost
   drivers and give a range. Prefer the user's unit: hours for interactive
   work, compute/requests/bytes for batch or API work, money for anything
   that spends.
2. **Bound the estimate.** A range ("2–4 hours") or a hard cap ("stop and
   report if this exceeds X"). A single number reads as a promise.
3. **Track against the estimate as you go.** Re-check at each natural
   checkpoint (task decomposition, first build, first verification pass).
   If actuals diverge from the range, say so immediately — an overrun
   discovered late is the failure, not the overrun itself.
4. **Report variance at the end.** One line: estimated vs. actual, and the
   one-line reason for the difference. This line is the calibration data for
   the next estimate.

```
estimate shape:
  unit:     hours | requests | compute-credits | money
  estimate: [low]–[high] (or capped at [cap])
  driver:   [the dominant cost driver]
  check:    [the checkpoint where overrun will first show]
  result:   [actual] vs [estimate] — [one-line variance reason]
```

5. **For recurring work (cron, batch, API polling),** model the per-run cost
   and multiply by expected frequency; flag it if the recurring cost exceeds
   the one-time build cost.

### 5. When the default doesn't apply

- **Explicit user scope** — the user says "don't track, just do it" or caps
  the budget themselves; then report the final cost once, no running tracking.
- **Disposable/demo context** — throwaway work where the cost is bounded by
  the disposable context and nothing depends on the estimate.
- **Hard constraint** — a pre-set budget or SLA that replaces the estimate;
  then the constraint becomes the estimate and overrun reporting still applies.

### 6. Red flags (stopgap smells specific to this file)

- "It'll be quick" with no number attached.
- An estimate in one unit and a report in another (estimated in hours,
  billed in money).
- A single optimistic number where a range was possible.
- "It's done — it just took longer than expected" with no variance line.
- Cost discovered at the end that would have changed the approach at the start.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "skipping the up-front estimate to start
   work immediately under deadline pressure."
2. Name the specific cost of not fixing it: e.g. "the task can overrun with no
   detection point, the user has no chance to redirect, and the next estimate
   repeats the miss because there's no baseline to calibrate against."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: e.g.
   "TODO: produce estimate + post-hoc variance once work completes — owner:
   agent session, trigger: first checkpoint, report before continuing past
   it."

### 8. Cross-references

- See also: `product/tradeoff-communication.md` — the cost number produced here
  is the currency of tradeoff conversations.
- See also: `planning/task-decomposition.md` — decomposition is where the cost
  drivers get enumerated.
- See also: `quality/testing-strategy.md` — test scope is a cost driver that
  must appear in the estimate.
- See also: `references/anti-patterns.md` — "running unbounded and reporting at
  the end" is the file-level smell this file guards.
