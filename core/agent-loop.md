## Agent Loop

**Applies to:** every task, before any file-modifying or network command is
executed — the mandatory plan → act → observe → repeat cycle.

**Tier:** core

---

### 1. Rule

Emit a structured plan before any file-modifying or network command, then
execute it one step at a time, observing the result of each step before
starting the next. Never batch actions you haven't planned.

### 2. Why this matters (long-term cost of getting it wrong)

- Unplanned commands mutate files in an order you didn't reason about, and a
  failed step leaves partial state (half-applied edits, orphaned files) that
  is hard to untangle later.
- Skipping observation means you compound errors: step 3 was built on a false
  assumption from step 1, and the whole chain is wrong.
- Without a visible plan the user can't intercept a bad trajectory early; you
  discover the mistake only after irreversible damage (a destructive command,
  a network call to the wrong environment).

### 3. Decision checklist

- [ ] Have I stated a plan before the first file-modifying or network command?
- [ ] Does the plan name the exact files and commands, not just a goal?
- [ ] Have I broken the work into steps small enough to observe after each one?
- [ ] Did I observe the actual output of the last step before proceeding?
- [ ] Does the observed result match what the plan predicted?

### 4. Default pattern

Every task runs as a loop; make the phases explicit:

```
1. PLAN      — write a short structured plan (goal, ordered steps, commands/files).
2. ACT       — execute exactly one step.
3. OBSERVE   — read the output / exit code / filesystem state of that step.
4. RECONCILE — if output matches prediction, advance. If not, stop and re-plan.
5. Repeat until the plan is complete, then verify (core/verification.md).
```

Concrete rules for the loop:

- The plan comes first, in the message, before the first command. It can be a
  short list; it must name files and commands, not just outcomes.
- One act per iteration when the step is file-modifying or hits the network.
  Read-only inspection may be batched.
- Observation is mandatory, not optional: check exit codes, read the file you
  just wrote, look at the actual HTTP response.
- When observation contradicts prediction, stop and re-plan. Do not "push
  through" and observe again later.
- If the plan itself was wrong, update the plan and tell the user — don't
  silently improvise off-plan.

### 5. When the default doesn't apply

- Explicit user scope: the user asks you to "just do it" with no plan. Still
  emit a one-line plan first so the intent is captured, then proceed fast.
- Purely read-only work (searching, reading files, answering a question): the
  act step may batch multiple reads, since nothing mutates.
- A single trivial mutation the user named precisely (e.g. "delete file X"):
  still state the action before running it, but a one-liner suffices.

### 6. Red flags (stopgap smells specific to this file)

- Running a file-modifying or network command with no plan stated first.
- Chaining multiple mutating commands with `&&` without observing between them.
- Saying "I assume that worked" without reading the output.
- A plan that states the goal but no concrete commands or files.
- Proceeding to the next step after a failed exit code without re-planning.

### 7. If a shortcut is genuinely necessary

Skipping a plan/observe step is not a normal state — but if it's forced (e.g.
a timeout-sensitive retry loop where re-observation is wasteful):

1. Name what's deferred: the explicit observe step between a batch of commands.
2. Name the cost: an early failure is not detected until the batch finishes,
   so a wrong assumption propagates through every command in the chain.
3. Write it down: record the batching decision and its trigger (e.g. the
   timed-out operation that made it necessary) in the task notes or a tracked
   TODO with an owner, so the full loop resumes once the constraint lifts.

### 8. Cross-references

- See also: `core/verification.md` for how the loop ends (confirming it works).
- See also: `core/failure-recovery.md` for what to do when observation shows
  a failed step.
- Escalates to: `core/permission-boundaries.md` when a planned action needs
  sign-off before it enters the act phase.
