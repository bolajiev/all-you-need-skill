## Testing Strategy

**Applies to:** any code the agent writes or changes — what gets tested, at what level, and what automation is expected before the work counts as done.

**Tier:** reference

---

### 1. Rule

Test behavior the way the project's own test suite does, at the level the change deserves, and run the full relevant suite to green before declaring the task done. Untested behavior is unfinished behavior.

### 2. Why this matters (long-term cost of getting it wrong)

- Untested changes fail loudly later — in review, in integration, in production — and the debug starts from the change, not from a failing test, so it's slower.
- A test suite that only grows around easy paths creates a false sense of coverage; regressions slip through in exactly the behavior nobody checked.
- Tests written against implementation details instead of behavior break on any refactor, so the suite punishes future cleanups.

### 3. Decision checklist

- [ ] Does this change have behavior that can fail? If so, does it have a test?
- [ ] Have I matched the repo's test level and tooling (unit/integration/e2e, framework, conventions)?
- [ ] Does the test assert behavior (input → outcome), not implementation internals?
- [ ] Have I run the full relevant suite — not just the one new test — to green?
- [ ] Have I included a regression test for any bug I fixed?

### 4. Default pattern

1. Match the project: same framework, same directory, same naming and fixtures as neighboring tests — do not introduce a new test stack.
2. Test at the cheapest level that exercises the behavior: unit for pure logic, integration for boundaries (I/O, DB, network), e2e only where the flow spans systems.
3. Prefer behavior over internals: set up inputs, assert on observable outcomes.
4. For a bug fix, add a test that fails on the old code and passes on the new — that test is the regression guard.
5. Run the suite as the project defines it, on top of a passing build, and report the actual command and its result.

```
# add test in the project's convention, e.g. for a bug fix
#   failing before the fix, passing after
def test_rejects_negative_balance():
    assert not allow_negative_balance(-1)   # was True — regression
```

If the project has no test tooling at all, say so and either adopt the smallest idiomatic runner for the language or flag the gap explicitly — do not silently ship untested code.

### 5. When the default doesn't apply

- User explicitly scopes the task as throwaway/demo with no durability ("no tests needed").
- A genuine hard constraint — no runner available, a change so trivial (docs, config formatting) that it has no behavioral surface.
- A read-only or pure-planning task produces no code, so no tests are owed — but verification of the plan itself may still be owed.

### 6. Red flags (stopgap smells specific to this file)

- "The change is too small to need a test."
- Running only the newly added test and calling the suite green.
- Tests that assert the implementation (mocked internals) rather than the behavior.
- Skipping the regression test on a fixed bug.
- Introducing a second test framework because the existing one was awkward.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:
1. Name what's being deferred — e.g., "test coverage for the new `export()` code path."
2. Name the specific cost — e.g., "a regression in export behavior goes undetected until a customer or an integration run hits it, and the debug starts from scratch."
3. Write it into an ADR or a tracked TODO with an owner and a trigger (e.g., "add the missing test before the next release cut").

### 8. Cross-references

- See also: `references/build/build-workflow.md` for running the suite as part of the build.
- See also: `references/quality/code-review-checklist.md` for test-quality checks at review time.
- Escalates to: `core/verification.md` when a suite cannot be run to green.
