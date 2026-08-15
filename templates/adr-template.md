# ADR Template (Architecture Decision Record)

Use for architecturally-significant decisions only — see
core/architecture-decisions.md for what qualifies. An ADR records a decision
that is expensive to reverse or that future work depends on. If you would delete
the file within a week, it is not an ADR.

---

# ADR-<NNN>: <Short Decision Title>

- **Status:** Proposed | Accepted | Deprecated | Superseded by ADR-<NNN>
- **Date:** YYYY-MM-DD
- **Decision maker / owner:** <name>

## Context

The situation that forces this decision. Facts, constraints, and the problem,
without the solution. If you cannot write context without mentioning your chosen
solution, you have not separated the two.

## Decision

What is being done, stated clearly and specifically enough that someone could
implement it without asking. Include the "what" and the "shape", not the full
implementation.

## Options considered

The alternatives that were actually evaluated, and why each was rejected.
One line per option is usually enough: name, why it lost.

- Option A — rejected because ...
- Option B — rejected because ...
- Option C — chosen (see Decision).

## Why NOT <the tempting option>

For each plausible shortcut or tempting alternative, name specifically why it
was NOT taken. This is where a no-stopgaps review lives: if the tempting option
was rejected only for "we should do this right", that is not a reason — say what
breaks concretely.

## Consequences

- Positive: what gets easier or cheaper now.
- Negative: what this decision costs or forecloses.
- Follow-ups: what future work this decision forces (migrations, cleanups,
  removals).

## Deliberate Debt

Explicit field. Fill it ONLY when this decision knowingly accepts debt.

- **Debt:** <one sentence: what is being deferred>
- **Cost if unpaid:** <what breaks, and when>
- **Repayment trigger:** <the concrete event/date at which this MUST be revisited>
- **Owner:** <who is accountable>

If there is no deliberate debt, write "None — this ADR accepts no debt."

## Alternatives revisited on

<The date or trigger at which this decision should be re-examined, or "never —
revisit only if the context changes".>

---

## Notes

- Keep under one page. If it grows, the decision is too big — split it.
- Record the decision, not the debate. History lives in the repo.
- Escalation paths: references/agent-state/escalation-triggers.md.
