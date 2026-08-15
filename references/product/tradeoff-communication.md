## Tradeoff Communication

**Applies to:** any task where the agent has to pick between options with
different costs — time vs. correctness, scope vs. quality, speed vs. safety —
or where the chosen path carries a price the user should have seen before it
was paid.

**Tier:** reference

---

### 1. Rule

Surface every meaningful tradeoff to the user before committing to it — what
was weighed, what was picked, and what that choice costs — in plain language,
before the cost is paid. Never let a decision with a price slip through
uncharacterized.

### 2. Why this matters (long-term cost of getting it wrong)

- The user discovers the cost after the fact and must redo or un-pick work
  they thought was done; retraction is always more expensive than forewarning.
- A choice made for the user without their input silently changes the
  deliverable's scope or quality — the user approves something they didn't
  actually ask for.
- Repeated undisclosed tradeoffs erode trust: the user stops believing the
  agent's progress reports, because "done" no longer means "done as asked."
- A tradeoff made without an alternative being named leaves no recovery path —
  the user can't say "use the other option" because they never knew one existed.

### 3. Decision checklist

- [ ] Does the chosen path have a cost the user would care about (time,
      money, risk, scope, quality)?
- [ ] Has that cost been communicated before the work was done, not after?
- [ ] Were the alternatives named, with at least the rejected ones and why
      they lost?
- [ ] Is the tradeoff reversible, and does the user know how to reverse it?
- [ ] If a tradeoff recurs, was it captured so the next decision doesn't
      re-litigate it?

### 4. Default pattern

1. **When you see a fork, name it.** Two or more viable options with different
   costs — don't silently pick. Say: "Option A is faster but leaves a
   migration; Option B is slower now and removes the need for one."
2. **State the cost, not just the choice.** Attach a concrete cost to each
   option: extra hours, extra spend, deferred correctness, narrower scope.
   Vague "a bit more work" is not a cost.
3. **Let the user pick when the tradeoff is significant** (affects schedule,
   budget, or behavior others depend on). For small reversible choices, pick
   the default and report it in the summary line.
4. **Prefer the reversible choice** when the user is not available to decide —
   a reversible option that's slightly worse beats an irreversible one that's
   slightly better.
5. **Report the decision in one line** in the final summary, including what
   was deferred and its trigger (see Section 7).

```
decision shape in a response:
  choice:      [what was picked]
  cost:        [concrete cost — time/money/risk/scope]
  rejected:    [alternative 1 — why; alternative 2 — why]
  reversible:  [yes/how, or no — this is load-bearing]
  deferral:    [if any, what + owner + trigger]
```

### 5. When the default doesn't apply

- **Explicit user delegation** — the user says "you decide" or "use your
  judgment"; then still state the choice and its cost in the report, but
  without blocking on approval.
- **Trivial reversible choices** — naming every micro-decision (naming a
  variable, picking a default port) drowns the signal; report these in one
  aggregate line instead.
- **Disposable/demo context** — the user confirmed nothing durable depends on
  the choice, so the tradeoff's cost is bounded and self-evident.

### 6. Red flags (stopgap smells specific to this file)

- A summary that says what was built but never says what was given up.
- The cost is discovered only during review — "wait, this rewrites the DB?"
- A choice framed as the only option when a second one existed.
- "I assumed that was fine" as a post-hoc justification.
- A tradeoff named in the middle of a long report, buried, with no explicit
  "this costs X" line.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "proceeding with the fast path without
   surfacing the migration cost, because the user is unreachable and the
   deadline is firm."
2. Name the specific cost of not fixing it: e.g. "the user will approve a
   deliverable that silently commits them to a migration they never saw, and
   the reversal window closes once data exists."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: e.g.
   "TODO: inform user of migration cost before data ships — owner: agent
   session, trigger: next user contact, before any irreversible write."

### 8. Cross-references

- See also: `product/cost-modeling.md` for putting a number on the cost side
  of the tradeoff.
- See also: `core/ambiguity-resolution.md` for when the options themselves are
  unclear and need asking, not choosing.
- See also: `core/architecture-decisions.md` for when a tradeoff is
  significant enough to become an ADR.
- See also: `references/anti-patterns.md` — "silently picking the convenient
  option" is the file-level smell this file guards.
