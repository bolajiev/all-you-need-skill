## Planning

**Applies to:** any task that involves more than a single trivial edit — any
time the agent is about to start writing code without a clear picture of the
steps involved.

**Tier:** reference

---

### 1. Rule

Plan before you execute: produce a written, ordered list of steps with a
stated end goal before the first edit, and keep the plan visible as you work.
Never start editing files from a "vibe" — if you can't write the plan in under
a minute, the task needs decomposition first.

### 2. Why this matters (long-term cost of getting it wrong)

- You burn the whole budget on the first plausible approach, then discover the
  real constraint at the end and have to redo work you already "finished".
- Unplanned work produces commits that mix unrelated concerns, making the
  change unreviewable and the blame history useless.
- Without a written plan there is no artifact to review against, so a wrong
  assumption propagates silently through every later step.
- Skipping the plan hides the risky step that should have been de-risked first;
  the thing you're least sure about is exactly what you should do earliest.

### 3. Decision checklist

- [ ] Can I state the end goal (the definition of done) in one sentence?
- [ ] Have I identified the single riskiest / least-known step, and is it
      scheduled early?
- [ ] Does every step have a way to verify it completed (build, test, manual
      check)?
- [ ] Is the plan the smallest set of steps that reaches the goal — no
      speculative additions?
- [ ] Have I written it down somewhere the user can see (message or file),
      not just in my head?

### 4. Default pattern

1. **State the goal** — one sentence describing the finished state.
2. **List the steps in dependency order** — the step that unblocks the most
   unknowns goes first.
3. **Mark each step with its verification** — `./step produces green build`,
   `test passes`, `manual curl returns 200`.
4. **Write it down** — for 3+ steps, put it in the working file
   `templates/implementation-plan.md`; for smaller tasks, a short ordered list
   in the conversation is enough.
5. **Re-plan when reality disagrees** — a plan is a commitment to the goal, not
   to the steps; when a step turns out wrong, update the plan and say so, don't
   quietly improvise.

```
Plan shape:
  Goal:   <one sentence>
  1. <step>            -> verified by <check>
  2. <step>            -> verified by <check>
  ...
  Risk:   <the unknown> is attacked in step <n>, early
```

### 5. When the default doesn't apply

- **A single obvious edit** (fix a typo, rename one symbol, one-line change) —
  a formal plan adds friction with zero value; the goal and the step are the
  same thing.
- **Explicit user scope** — the user says "just do X, don't plan" for a
  throwaway/demo task; honor the request but keep the one-sentence goal.
- **Exploration/research tasks** — when the task *is* to find out what the plan
  should be (see `planning/research.md`), the deliverable is the research, not
  an execution plan.

### 6. Red flags (stopgap smells specific to this file)

- The first tool call is an edit, with no statement of the goal first.
- Steps are discovered one at a time as failures occur, mid-execution.
- The plan lists steps but no verification for any of them.
- "I'll just try it and see" appears instead of a plan.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "I'm starting edits without a written plan
   for this 6-step change."
2. Name the specific cost of not fixing it: e.g. "if step 3's assumption is
   wrong, steps 4–6 will need rework and I won't have a checklist to catch it."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: a
   one-line TODO "re-plan/recheck once step 3 result is known, owner:
   [agent/user]" that fires before step 4 begins.

### 8. Cross-references

- See also: `planning/research.md` — run research before planning when the
  problem space is unknown.
- See also: `planning/task-decomposition.md` — how a plan becomes discrete,
  verifiable tasks.
- See also: `core/definition-of-done.md` — the goal line of the plan must be
  the definition of done.
- See also: `templates/implementation-plan.md` — the artifact to write the plan
  into for non-trivial tasks.
