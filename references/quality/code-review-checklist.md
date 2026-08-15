## Code Review Checklist

**Applies to:** reviewing any code — the agent's own work before declaring done, or another contributor's code handed to it for review.

**Tier:** reference

---

### 1. Rule

Review for correctness and intent, not just style: does the code do what it claims, fail safely, fit the existing design, and ship with tests and no regressions? A review that only checks formatting is not a review.

### 2. Why this matters (long-term cost of getting it wrong)

- A style-only review passes bugs and design mismatches that the next person inherits as mystifying failures.
- Reviews that rubber-stamp their own work let the same blind spots through every gate, so defects compound across the codebase.
- Uncaught security or correctness issues surface in production, where they cost orders of magnitude more than in review.

### 3. Decision checklist

- [ ] Does the code satisfy the actual requirement, not just the literal task text?
- [ ] Are there edge cases, failure paths, and error handling — and are they tested?
- [ ] Does it fit the existing architecture, naming, and conventions of the file and project?
- [ ] Does the diff stay in scope, with no unrelated or generated-file edits?
- [ ] Are security and privacy basics intact (see `security-baseline.md`)?
- [ ] Is the change verified: build, tests, and any required docs updated?

### 4. Default pattern

1. Read the diff in full first; then read the surrounding code the change touches, so the review is grounded in context, not the patch alone.
2. Check intent: compare against the requirement/issue, not just "does it compile."
3. Walk failure modes deliberately: invalid input, empty state, concurrency, timeout, missing resources — confirm each is handled or impossible.
4. Confirm design fit: does it reuse existing patterns instead of reinventing, and avoid growing the surface area unnecessarily?
5. Check the package: tests for new behavior, a regression test for fixes, docs/config updated, no secrets or stray artifacts in the diff.
6. Report findings as a ranked list — blocking issues (correctness/security/scope) before nits — and don't block on preference alone.

```
order of attack:
  1. correctness & intent      -> blocking if wrong
  2. security & secrets        -> blocking if violated
  3. scope / unrelated edits   -> blocking if stray
  4. tests for the behavior    -> blocking if missing
  5. design fit & conventions  -> fix if simple, flag if deep
  6. style nits                -> suggest only
```

### 5. When the default doesn't apply

- User explicitly asks for a light/style-only pass ("just check it compiles and looks consistent") — deliver exactly that scope.
- A throwaway/demo change the user has scoped as non-shipping doesn't warrant the full failure-mode walk.
- Reviewing generated or vendored code — apply the checklist to the generator, not the output.

### 6. Red flags (stopgap smells specific to this file)

- Approving your own change without re-reading the diff after writing it.
- Findings list that is all nits and no correctness questions.
- "It builds" as the sole verification of a behavior-bearing change.
- Missing tests waved through as "we'll add them later."
- Noting a security gap but merging anyway "since it's a small risk."

### 7. If a shortcut is genuinely necessary

Never silent. Required output:
1. Name what's being deferred — e.g., "a full failure-path review of the new endpoint."
2. Name the specific cost — e.g., "an unhandled error path may surface as a production incident whose cause takes hours to localize."
3. Write it into an ADR or a tracked TODO with an owner and a trigger (e.g., "complete the failure-mode review before the change ships to production").

### 8. Cross-references

- See also: `references/quality/testing-strategy.md` for judging whether test coverage is sufficient.
- See also: `references/quality/security-baseline.md` for the security checks folded into this checklist.
- See also: `references/build/git-workflow.md` for reviewability of the commit itself.
- Escalates to: `core/verification.md` when a blocking finding cannot be resolved before merge.
