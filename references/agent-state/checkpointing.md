## Checkpointing

**Applies to:** any multi-step task where a failure, interruption, or context loss partway through would otherwise force a restart or a loss of work.

**Tier:** reference

---

### 1. Rule

Save a recoverable snapshot of state at every meaningful boundary — at least before any irreversible or expensive step — so work can always resume from a known-good point instead of from the beginning or from a guess.

### 2. Why this matters (long-term cost of getting it wrong)

- Without checkpoints, a single failure near the end of a long task costs the entire run; the failure rate compounds with task length.
- "Resume from memory" is not a checkpoint — it recreates state incorrectly and silently, which is worse than restarting because it looks like progress.
- Irreversible steps (deletes, writes, deploys) executed without a prior snapshot leave no known-good point to return to when they go wrong.
- The absence of checkpoints forces the agent to keep everything in context defensively, which is exactly the bloat `context-management.md` warns about.

### 3. Decision checklist

- [ ] Is there an irreversible or expensive step ahead that needs a snapshot first?
- [ ] Is the checkpoint restorable — can a later run actually return to it, or is it just a note?
- [ ] Does it capture both the state (files, data, env) and the position (what was done, what's next)?
- [ ] Is the checkpoint stored outside the live context, somewhere that survives a session end?

### 4. Default pattern

```
1. Frequency: checkpoint at natural boundaries — task start, after
   each completed phase, and always immediately before an
   irreversible or high-cost step.
2. Contents: the durable state (files, config, data, env) plus a
   state note {what's done, what's next, decisions, how to verify}
   that also satisfies the resume-note shape in
   `session-continuity.md`.
3. Storage: in the task's durable workspace (a checkpoints/ dir, the
   VCS state, the platform's snapshot feature) — never only in
   context.
4. Restore: to resume, restore the snapshot, verify it with the
   note's check, then take the next action. Don't rebuild from memory.
```

- Prefer the environment's native snapshot/versioning when it exists over a hand-rolled copy.
- A checkpoint costs little to write and saves a full restart; when in doubt, write one.

### 5. When the default doesn't apply

- **Short, low-risk, single-step tasks** — the cost of a checkpoint exceeds the expected cost of a restart.
- **Disposable/demo context** — intentionally throwaway work needs no recovery point.
- **A real hard constraint** (no durable storage available in the environment) — then at minimum keep a state note in whatever persists, and say so in the audit trail.

### 6. Red flags (stopgap smells specific to this file)

- Calling a summary in context a "checkpoint" when nothing durable was written.
- Only checkpointing once at the start of a long task, so most of the run is unrecoverable.
- Skipping the snapshot before a destructive step "because this should work."
- Checkpoints that capture files but not position, so a restore can't tell what's next.
- A restore path that has never been exercised.

### 7. If a shortcut is genuinely necessary

1. Name what's being deferred: e.g. "no checkpoint before this irreversible step."
2. Name the specific cost: if the step fails, there is no known-good point and the run restarts or guesses; say when it bites (the moment that step actually fails).
3. Write it into an ADR or a tracked TODO with an owner and a trigger (e.g. "add checkpointing before any further destructive steps; owner = [x], trigger = next irreversible operation"). No silent exceptions.

### 8. Cross-references

- See also: `session-continuity.md` — the state note that makes a checkpoint resumable.
- See also: `context-management.md` — checkpoints are why context can be dropped safely.
- See also: `core/failure-recovery.md` — restoring to a known-good point is the recovery path.
- Escalates to: `references/agent-state/escalation-triggers.md` when no known-good point exists to resume from.
