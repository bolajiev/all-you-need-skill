## Requirements Elicitation

**Applies to:** the start of any task where the goal is not fully pinned down — before planning begins, whenever the agent is about to build against an assumption about what the user wants.

**Tier:** reference

---

### 1. Rule

Ask before you assume: clarify what the user actually needs, distinguish needs from wants, and state every assumption you make out loud before it drives a design decision. A requirement you never confirmed is a requirement you made up.

### 2. Why this matters (long-term cost of getting it wrong)

- Building against an unconfirmed assumption is the most expensive failure available: the whole design, not just a line of code, is built on the wrong foundation.
- Missing one clarifying question up front means a rework later that costs an order of magnitude more — the cheaper the question, the costlier the silence.
- Confusing wants with needs produces overbuilt features the user never asked for, which then have to be maintained or removed.
- Unstated assumptions become hidden scope: the user approves the plan you wrote, not the plan you silently invented.

### 3. Decision checklist

- [ ] Do I understand the actual problem the user is trying to solve — the outcome, not the stated mechanism?
- [ ] Have I distinguished must-have needs from nice-to-have wants, and do I know which is which?
- [ ] Have I confirmed the non-obvious details: scale, environment, constraints, existing behavior to preserve, and the boundary of what's out of scope?
- [ ] Have I written down every assumption I'm making and stated it to the user before it drives a design decision?
- [ ] For anything ambiguous, have I picked the smallest confirming question rather than the largest guess?

### 4. Default pattern

1. **Restate the problem in one sentence and confirm it** — "you want X because of Y" — before any planning. If the user can't confirm it, the problem isn't understood yet.
2. **Ask open questions first, specific ones second** — start with the outcome and the pain, then pin down scale, constraints, and edge cases (volume, concurrency, users, environments, backwards compatibility, deadlines).
3. **Distinguish needs from wants explicitly** — mark each stated requirement as must / should / nice-to-have and check the marking with the user; wants get a cost estimate, not silent inclusion.
4. **State assumptions as assumptions, not facts** — a list prefixed "I'm assuming: ..." shown to the user, especially any that affect design choices.
5. **Write the confirmed requirements into the spec** (`templates/spec-template.md`) before planning, so the plan is built on a shared artifact, not on memory.

```
# before writing a line of the plan
Q: "What outcome does this need to produce?"      -> problem
Q: "What's in scope? What's explicitly out?"      -> boundary
Q: "How many users / how much data / how fast?"   -> scale
Q: "What must not change?"                        -> constraint
A: "I'm assuming <X> because <reason>. Correct?"  -> assumption, stated
```

### 5. When the default doesn't apply

- **Explicit user scope**: the user has already written a detailed spec, PRD, or issue and says "implement this as written" — then the elicitation job is confirming you read it correctly, not re-interrogating.
- **A trivially clear task** — a one-line fix with no ambiguity, where a clarifying question would be noise; still state any assumption you made.
- **Exploration/research tasks** — when the deliverable *is* the requirements themselves (see `planning/research.md`), elicitation from the user is only the starting point.

### 6. Red flags (stopgap smells specific to this file)

- Starting to plan or edit while unsure of the goal, without asking first.
- "The user probably means ..." without confirming it.
- Treating the user's first proposed solution as the requirement, instead of the need behind it.
- An assumption discovered mid-build that was never stated — especially one that changes the design.
- Including every nice-to-have in the plan because it was mentioned, with no cost/priority discussion.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:
1. Name what's being deferred — e.g., "confirmation of the exact user-count scale this feature must handle."
2. Name the specific cost — e.g., "if the real scale is 100x larger, the schema and query design will need rework, and the migration hits real data."
3. Write it into an ADR or a tracked TODO with an owner and a trigger (e.g., "confirm scale target before the schema is finalized", owner: user, trigger: end of the design spike).

### 8. Cross-references

- See also: `references/planning/planning.md` — elicitation finishes where the plan begins; never plan against unconfirmed requirements.
- See also: `references/planning/research.md` — use research when the requirements themselves are the unknown.
- See also: `references/planning/spec-to-agent-handoff.md` — confirmed requirements become the spec handed to the build.
- See also: `templates/spec-template.md` — the artifact the confirmed requirements are written into.
- Escalates to: `core/ambiguity-resolution.md` when the user's answers contradict each other or the requirement stays unresolvable.
- See also: `core/architecture-decisions.md` for recording any assumption that becomes an architectural decision.
