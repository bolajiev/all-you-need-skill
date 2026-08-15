## Refactoring

**Applies to:** any task that restructures existing code — renaming, moving,
extracting, simplifying — without changing its observable behavior.

**Tier:** reference

---

### 1. Rule

Refactor in small, behavior-preserving steps with tests green at every step.
Restructure code only to serve a stated goal; never mix refactoring with
feature work in the same step, and never refactor code with no safety net
(tests) without first adding one.

### 2. Why this matters (long-term cost of getting it wrong)

- A "safe" rename or extract that changes behavior ships a regression that
  tests were supposed to catch — and the bigger the step, the harder it is to
  isolate what broke.
- Mixing refactor and feature in one change means a bug can't be blamed on
  either, reviews can't verify either, and a revert reverts both.
- Refactoring without tests is gambling: behavior changes masquerading as
  cleanups get baked in and are impossible to bisect later.
- Refactoring beyond the stated goal expands blast radius, churns code
  reviewers must re-verify, and produces a diff nobody can confidently merge.

### 3. Decision checklist

- [ ] Is there a stated goal for this refactor (reduced duplication, clearer
      name, smaller module), and is it scoped to that goal?
- [ ] Are tests in place covering the behavior being restructured — and are
      they green before I start?
- [ ] Can this be done in steps small enough to keep the suite green and the
      diff reviewable after each one?
- [ ] Is this change pure refactoring — no behavior or feature change mixed
      in — and is that visible in the diff?
- [ ] Will the tests still be meaningful after the change (they test
      behavior, not private implementation that I'm about to delete)?

### 4. Default pattern

1. **Lock the behavior first**: ensure the relevant tests exist and pass
   before the first change. Add characterization tests for untested legacy
   code before touching it.
2. **Pick one goal and stop when it's done** — "while I'm in here" scope creep
   is how refactors leak.
3. **Move in small steps**, each independently verifiable: rename, extract,
   or move one thing; run the suite; commit. If the suite can't be run at
   each step, shrink the steps.
4. **Keep behavior identical**: prefer mechanical, tool-assisted changes
   (IDE rename, codemod) over hand-rewrites for moves and renames.
5. **Leave the code greener than you found it only within scope**: stop at
   the stated goal; file a TODO for the rest instead of folding it in.
6. **Verify at the end** that the suite is green and the diff contains only
   restructuring — no behavior change, no feature.

```
1. add characterization test -> green      # safety net
2. extract method extractThing(...)        # one small step -> suite -> commit
3. rename callers                          # one small step -> suite -> commit
4. remove now-dead helper                  # one small step -> suite -> commit
# stop. goal reached. diff is all restructuring, behavior unchanged.
```

### 5. When the default doesn't apply

- **Explicit user scope** — user says "clean this up as part of the feature";
  mixing is then authorized, but behavior changes must still be called out
  separately in the description.
- **Real hard constraint** — a codebase with no test infrastructure and no
  budget to add it; then characterize behavior manually (compare outputs)
  and keep steps even smaller, and say the safety net is missing.
- **Disposable/demo context** — throwaway code that will not be maintained
  doesn't need incremental discipline; just don't pretend it was refactored
  safely.

### 6. Red flags (stopgap smells specific to this file)

- Refactoring and a feature/bugfix in the same diff or commit.
- Tests red at any intermediate step that was still called "in progress
  refactor."
- Renames/moves done by hand search-and-replace instead of the toolchain.
- "Small cleanup" commits that change behavior or delete code with no test
  coverage.
- Refactor-without-tests on legacy code, no characterization tests added.
- Scope creep: the diff touches far more than the stated goal.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "deferring full behavior coverage of the
   legacy `LegacyParser`; extracting it without characterization tests."
2. Name the specific cost of not fixing it: e.g. "behavior drift in the
   extract is invisible until an integration test or prod data exposes it, and
   bisecting then spans unrelated work."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: ADR
   entry "LegacyParser: add characterization tests before further extraction,
   owner: [team], trigger: next change touching LegacyParser or the
   integration test for it."

### 8. Cross-references

- See also: `quality/testing-strategy.md` — tests are the refactor safety
  net; characterization tests come from here.
- See also: `core/verification.md` — verify behavior is unchanged after each
  step, not just at the end.
- See also: `references/anti-patterns.md` — refactor-drift and scope-creep
  anti-patterns to avoid.
- See also: `core/scope-discipline.md` — stopping at the stated goal is a
  scope decision.
- See also: `core/architecture-decisions.md` — record when refactoring
  crosses a structural boundary (module split, package move).
