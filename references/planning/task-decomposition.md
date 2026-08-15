## Task Decomposition

**Applies to:** any plan with more than ~3 steps, or any task whose result
can't be verified with a single check. Breaking the work into discrete,
independently verifiable units is what turns a plan into something an agent (or
any executor) can actually run.

**Tier:** reference

---

### 1. Rule

Decompose every non-trivial plan into tasks that are discrete (one concern
each), independently verifiable (each has a pass/fail check), and sequentially
ordered so earlier tasks de-risk later ones. If a task can't be verified on its
own, split it until it can.

### 2. Why this matters (long-term cost of getting it wrong)

- A task with no verification can silently "complete" while broken, and the
  breakage surfaces at the very end where it's hardest to attribute.
- Coarse tasks hide ordering dependencies, so the executor discovers the 
  hard part last instead of first.
- Big-blob tasks can't be parallelized or partially delivered, so a single
  failure blocks everything.
- Tasks that mix concerns (schema change + endpoint + UI) produce a change
  that can't be reverted or reviewed cleanly.

### 3. Decision checklist

- [ ] Can I verify completion of this task with a specific check (command,
      test, manual observation)?
- [ ] Does this task depend on another's output, and is that dependency
      explicit?
- [ ] Does each task touch one concern (data, api, UI, config) — no mixed
      concerns?
- [ ] Is the riskiest/most uncertain task earliest in the sequence?
- [ ] Is the whole set the minimum needed, with nothing speculative added?

### 4. Default pattern

1. **One concern per task.** If a task says "and", split it.
2. **Give each task a verb + a verifiable result** — "add `POST /orders`
   handler returning 201 with location header; verified by integration test
   `test_create_order`".
3. **Order by dependency, then risk** — a task that could invalidate the others
   goes first so it fails early and cheaply.
4. **Keep tasks small enough to land alone** — each task should be a state the
   repo could ship in, even if you don't ship every intermediate.
5. **Cross-check against the plan** — the union of tasks must cover the whole
   plan with no gaps and no duplicates.

```
Example decomposition (adding a payment field):
  T1: migrate `orders` table + `payments` table   -> migration runs clean on clean DB
  T2: model + repository methods                   -> unit tests green
  T3: POST /orders accepts payment payload         -> integration test green
  T4: POST /orders idempotency key handling        -> retry test green
  T5: confirm page renders stored payment data     -> manual check / e2e test
```

### 5. When the default doesn't apply

- **A single trivial edit** — one concern, one check; decomposition is the
  task itself.
- **Explicit user scope** — user asks for a single coarse deliverable in a
  disposable/demo context where intermediate verifiability adds no value.
- **Exploration tasks** — the research task's deliverable is findings; it
  decomposes by question, not by verifiable build step (see
  `planning/research.md`).

### 6. Red flags (stopgap smells specific to this file)

- A task whose "verification" is "looks right" rather than a command/test.
- A list where one task says "and then", "also", or covers two files in
  different domains.
- All the risk concentrated in the last task.
- Tasks that could never be partially landed — implying they're too big.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "decomposing the migration + API change
   into one combined task to save a step."
2. Name the specific cost of not fixing it: e.g. "if the migration is wrong,
   the API task can't be verified independently and the failure mode is
   ambiguous."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: TODO
   "split T3 once it compiles — do before first merge, owner: [agent/user],
   trigger: T3's first green build."

### 8. Cross-references

- See also: `planning/planning.md` — decomposition is applied to the plan.
- See also: `planning/spec-to-agent-handoff.md` — a handoff must arrive
  pre-decomposed or decomposed in the first pass.
- See also: `core/definition-of-done.md` — each task's verification should be
  its own mini definition of done.
- See also: `templates/implementation-plan.md` — the decomposition's home.
