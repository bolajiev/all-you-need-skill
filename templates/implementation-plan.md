# Implementation Plan Template

Use when a spec (templates/spec-template.md) is ready to become executable work.
The plan's job is to be complete enough that execution needs no further
decisions — every choice is made here, in writing, before any file is touched.

---

## 1. Task list

Numbered, each task = one atomic, verifiable unit of work. For each:
- What is being changed (file/component level).
- What observable result proves it works.
- Ordering / dependencies (must X land before Y?).

| # | Task | Change | Proof of done | Depends on |
|---|------|--------|---------------|------------|
| 1 | ... | ... | ... | — |

## 2. Sequence

The concrete execution order as a list of steps. This is the plan the agent
outputs BEFORE any file-modifying or network command (core/agent-loop.md).

```
1. ...
2. ...
3. ...
```

## 3. Verification plan

How each task gets verified — the exact commands, test names, or manual checks.
Maps to references/quality/testing-strategy.md. No "it should work" entries.

## 4. Rollback / reversal plan

What to do if a step fails partway. For data migrations or deploys this is
mandatory (references/operations/deployment-strategy.md).

## 5. Estimated cost

Time, compute, and money estimates in the user's unit
(references/product/cost-modeling.md). State the estimate range and the bound
at which you stop and check in.

## 6. Risks carried over from the spec

Only items that are still open after planning. If empty, say so.

## 7. Debt entries (if any)

Per core/architecture-decisions.md and templates/adr-template.md: name the
deferred item, the cost of not fixing it, the owner, and the trigger that forces
revisiting. A plan with debt but no trigger is a plan that hides its debt.

---

## Notes

- Parallelizable work must be flagged (references/build/parallel-work-policy.md).
- Handoff rules from a written plan to execution: references/planning/planning.md.
