# Spec Template

Use for every feature, fix, or change that gets handed to an agent. A spec is
done when every section below can be answered from written artifacts, not from
memory. Delete any section that does not apply — do not leave placeholders.

---

## 1. Goal

What outcome does the user actually want? One or two sentences, in user terms,
free of implementation detail.

## 2. Non-goals

What this task will explicitly NOT do. Protects scope. If this list is empty,
say so — an empty non-goals list is a smell that the scope was never examined.

## 3. Context

- Current behavior (with file/line references when possible).
- Why the current behavior is wrong or insufficient.
- Any constraints discovered so far (deadlines, budgets, environment limits).

## 4. Requirements

Numbered, each one testable. Write as "the system MUST ..." statements.
- 4.1 ...
- 4.2 ...

## 5. Acceptance criteria

The observable checks that prove each requirement. Each maps to a requirement
number. If it cannot be observed, it is not an acceptance criterion.

- AC-4.1: ...
- AC-4.2: ...

## 6. Out of scope / explicitly deferred

Named deferred items must carry: what is deferred, the cost of deferring, and
the owner + trigger for revisiting (per core/architecture-decisions.md).

## 7. Interfaces affected

APIs, schemas, config surfaces, CLI flags — anything with an external contract.
Note which are additive vs. breaking (see references/architecture/api-design.md
and references/product/backward-compat-policy.md).

## 8. Risks

Each risk gets: what could go wrong, likelihood, impact, and a mitigation.
Include the worst thing that could happen if this task ships wrong.

## 9. Definition of done (sourced from core/definition-of-done.md)

- [ ] All acceptance criteria pass with evidence.
- [ ] Verification performed, not assumed (core/verification.md).
- [ ] No scope creep introduced (core/scope-discipline.md).
- [ ] ADR written if this is architecturally significant (core/architecture-decisions.md).
- [ ] Debt recorded with owner + trigger if any shortcut was necessary.

## 10. Open questions

Anything that blocks writing the implementation plan. Each question names who
answers it and by when. An open question here means the spec is NOT ready to
hand off — resolve before planning.

---

## Notes

- Spec → implementation plan handoff is covered in
  references/planning/spec-to-agent-handoff.md.
- If you find yourself writing "and then" repeatedly in the Goal, split the
  spec into multiple specs.
