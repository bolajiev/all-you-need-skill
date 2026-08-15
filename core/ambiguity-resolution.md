## Ambiguity Resolution

**Applies to:** any task where the request, spec, or environment is ambiguous
and the agent must choose between assuming and asking.

**Tier:** core

---

### 1. Rule

Proceed on a reasonable assumption when the choice is reversible and low-cost;
stop and ask when the choice is costly, irreversible, destructive, or would
touch protected scope or data.

### 2. Why this matters (long-term cost of getting it wrong)

- Assuming on a high-cost question produces work built on the wrong
  foundation — rework that may be larger than the original task.
- Asking on every minor ambiguity burns user time and trains the agent to be
  helpless; users stop answering and the quality of answers degrades.
- A wrong assumption about environment or data can touch production systems,
  delete state, or expose data — cost measured in incidents, not rework.
- Unstated assumptions that later prove wrong erode trust in every subsequent
  deliverable.

### 3. Decision checklist

- [ ] If I assume, what's the worst concrete outcome? (rework? data loss? prod
  impact?)
- [ ] Is the choice reversible? Can I detect and undo the wrong call cheaply?
- [ ] Does the assumption touch prod, credentials, destructive operations, or
  data I'm not authorized to see?
- [ ] Is the ambiguity resolvable from the repo, docs, or config without asking?
- [ ] Is the ambiguity a genuine fork with a real user preference, or just
  detail the user doesn't care about?

### 4. Default pattern

Classify each ambiguity on two axes — cost and reversibility:

- **Low cost, reversible** (naming, formatting, minor defaults): pick the
  reasonable assumption, state it in one line so the user can correct it, and
  proceed. Do not ask.
- **High cost or irreversible** (schema, architecture, scope, API contracts,
  destructive actions): stop and ask, with a concrete question offering
  options, not an open-ended "what do you want?"
- **Protects scope/data**: if the assumption would touch an area outside the
  spec or protected resources, ask first regardless of cost.

When asking, state: what you understand, the options you see, your
recommendation, and the cost of each option. One crisp question, not five.

Before asking, do the cheap homework: search the repo and docs for the answer.
Most "ambiguity" is resolvable locally. When you do resolve it, note where you
found it in your plan (see `core/agent-loop.md`).

### 5. When the default doesn't apply

- Explicit user scope: the user pre-authorizes a class of assumptions ("use
  your judgment on naming", "just pick reasonable defaults").
- Hard deadline pressure the user stated: with time pressure, prefer asking
  the single highest-value question and assuming the rest, naming the
  assumptions.
- Genuinely unknowable preference: when the user themselves must choose and
  the choice affects the deliverable's correctness — asking is the default,
  and this is the one case where even low-cost ambiguity justifies a question.

### 6. Red flags (stopgap smells specific to this file)

- Making an irreversible assumption and only revealing it at the end.
- Asking the user for things already answerable from the repo or config.
- Five-paragraph questions that bury the actual choice.
- Proceeding silently into protected scope or production-shaped resources
  based on an assumption.
- Re-asking the same class of minor question twice in a session.

### 7. If a shortcut is genuinely necessary

1. Name what's being deferred: the explicit user confirmation on an ambiguous
   point.
2. Name the cost: the deliverable may be built on a wrong assumption; if the
   wrong call is irreversible, the cost is rework or, worse, prod/data impact.
3. Write it into a tracked TODO with an owner and a trigger — the assumption
   and its correction-point must be recorded so it is revisited when the
   ambiguity is actually resolvable, not lost.

### 8. Cross-references

- See also: `core/permission-boundaries.md` for which ambiguities are also
  permission questions (scope, data, environment).
- See also: `core/scope-discipline.md` for when an ambiguity is actually a
  scope expansion.
- See also: `core/architecture-decisions.md` for when an assumption is an
  architecturally-significant decision.
