## Spec-to-Agent Handoff

**Applies to:** any time an agent picks up work described by a written spec,
ticket, issue, PR description, or a user message that contains a goal but not
instructions. The handoff is the contract between the writer of the intent and
the executor — if it's ambiguous, the executor's output will be too.

**Tier:** reference

---

### 1. Rule

Before executing from any spec or ticket, turn it into an actionable handoff:
extract the goal, the scope boundaries, the acceptance criteria, and the
constraints into explicit instructions the agent can verify against. If the
spec lacks any of these, surface the gap to the user rather than guessing.

### 2. Why this matters (long-term cost of getting it wrong)

- An ambiguous spec is executed against the executor's best guess, which is
  the cheapest interpretation — usually the wrong one, discovered only at
  review time.
- Unstated scope lets the agent build adjacent things nobody asked for,
  inflating the change and its review cost.
- Missing acceptance criteria means "done" is negotiable forever and the
  deliverable is unverifiable.
- Constraint omissions (versions, environments, "no new deps") cause rework or
  hard failures late, exactly when they're most expensive.

### 3. Decision checklist

- [ ] Can I state the goal in one sentence, and did it come from the spec —
      not from my assumptions?
- [ ] Are the scope boundaries explicit — what is in, and what is explicitly
      out?
- [ ] Are the acceptance criteria written as verifiable checks, not vibes?
- [ ] Are constraints present (versions, environments, no-new-deps, external
      behavior to preserve)?
- [ ] Have I listed the open questions the spec doesn't answer, and are they
      blocking or deferrable?

### 4. Default pattern

1. **Parse the spec into five fields** — Goal, Scope (in/out), Acceptance
   criteria, Constraints, Open questions. If a field is missing, it is an open
   question, not something to assume.
2. **Confirm blocking gaps with the user first** — if Goal or Acceptance
   criteria is missing, ask; executing on a guessed goal is a stopgap.
3. **Decompose** (see `planning/task-decomposition.md`) once the fields are
   set.
4. **Write the handoff down** — for any task beyond trivial, produce the
   working note in `templates/implementation-plan.md` so the executor's
   contract is reviewable.
5. **Execute against the handoff, not the original ticket** — re-read your
   handoff before finishing, and check off acceptance criteria one by one.

```
Handoff shape:
  Goal:        <one sentence>
  In scope:    <list>
  Out of scope: <list>
  Acceptance:  <verifiable checks, one per criterion>
  Constraints: <versions, envs, "no new deps", preserved behavior>
  Open:        <questions>  (blocking? yes/no)
```

### 5. When the default doesn't apply

- **Spec already is a handoff** — a well-formed ticket with goal, scope,
  acceptance, and constraints can be executed directly; the parse just
  confirms it.
- **Trivial change** — a one-line instruction with an obvious goal needs no
  handoff artifact; act on it.
- **Explicit user override** — the user says "just implement it, I'll review
  the diff" for a demo/disposable task; record the most important open question
  in one line, then proceed.

### 6. Red flags (stopgap smells specific to this file)

- Starting to code with only "implement this feature" and no extracted goal.
- Accepting criteria the agent wrote itself ("I think it should…") as if it
  came from the spec.
- Guessing a constraint (e.g. target environment) and not noting it as an
  assumption.
- Returning "done" without mapping the work back to the acceptance criteria.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "proceeding without confirmed acceptance
   criteria because the user asked me to start immediately."
2. Name the specific cost of not fixing it: e.g. "done will be judged against
   criteria I invented; if they differ from intent, the work is redo."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: TODO
   "confirm acceptance criteria with user — owner: user, trigger: before first
   delivery review / when the diff is ready."

### 8. Cross-references

- See also: `planning/task-decomposition.md` — the handoff feeds
  decomposition.
- See also: `planning/planning.md` — the handoff's goal is the plan's goal.
- See also: `core/definition-of-done.md` — acceptance criteria are the
  definition of done for the task.
- See also: `core/architecture-decisions.md` — record any constraint or
  assumption the spec forces into the architecture.
