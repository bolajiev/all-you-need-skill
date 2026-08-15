## Verification

**Applies to:** everything the agent produces — confirm it actually works by
treating your own output with the same scrutiny as a new hire's PR.

**Tier:** core

---

### 1. Rule

Verify your work against the real artifact before reporting done. Trust
nothing you wrote until observed behavior confirms it; review your own output
as harshly as you would review a stranger's PR.

### 2. Why this matters (long-term cost of getting it wrong)

- Unverified output that looks plausible is worse than an honest failure: the
  user deploys or builds on it, and the defect surfaces later at higher cost.
- Writing code you never ran produces a feedback loop in your own head, not
  reality; repeated misses train the user to double-check everything.
- Skipping review of your own diff lets small inconsistencies (naming,
  conventions, dead code) accumulate into unreadable, hard-to-maintain files.

### 3. Decision checklist

- [ ] Did I run the artifact, not just compile it? (server, CLI, test, page)
- [ ] Does the observed output match what the spec says should happen?
- [ ] Did I check the failure path (errors, edge cases), not just the happy
  path?
- [ ] Did I review my own diff — size, naming, conventions, dead code,
  commented-out code, secrets?
- [ ] Is the evidence reproducible by the user, with a recorded command?

### 4. Default pattern

Verify in three passes, in order:

1. **Run it.** Execute the artifact and observe real behavior — a test suite,
   a curl against a running server, a CLI invocation, a rendered page. Read
   the output. A passing build is not a passing behavior.
2. **Exercise the edges.** Hit the error and boundary paths the spec implies:
   missing input, empty result, failure of a dependency, the "no" case — not
   just the green path.
3. **Review your own diff.** Read it as a skeptical reviewer would:
   - Naming and structure match the repo's conventions.
   - No dead code, commented-out code, or leftover debugging output.
   - No secrets or credentials in the diff or logs.
   - Every change traces to a spec line; nothing extra snuck in.

Verification is the final act of the loop in `core/agent-loop.md` and the
evidence step of `core/definition-of-done.md`. When verification fails, do not
patch and re-verify blindly — fix the root cause, then re-run.

### 5. When the default doesn't apply

- Explicit user scope: the user asks for verification limited to a specific
  check ("just lint it"). The stated check is then the verification, and is
  still actually run.
- Disposable/demo context: a throwaway artifact may get a lighter pass
  (compile-only), stated as such.
- Hard constraint: no runtime exists (offline, no test harness). Then static
  verification (lint, typecheck, review) is the pass, and the missing runtime
  check is recorded as a Section 7 item, not dropped.

### 6. Red flags (stopgap smells specific to this file)

- "It should work" with no observed evidence.
- A test that passes but was never actually executed.
- Verifying only the happy path when the spec has obvious failure cases.
- Reading your own code only to confirm your assumption, never to break it.
- Not re-verifying after a fix ("I changed it, it'll be fine").
- Untested code with the comment "tested in my head".

### 7. If a shortcut is genuinely necessary

1. Name what's being deferred: the specific verification pass not completed.
2. Name the cost: the behavior it covers is unproven — a defect ships to the
   user or prod and is found at a later, more expensive point.
3. Write it into an ADR or a tracked TODO with an owner and a trigger (e.g.
   "when the CI harness exists", "when runtime access is restored") — and
   report the task as "done, unverified on X", never as verified.

### 8. Cross-references

- See also: `core/definition-of-done.md` for what counts as done, of which
  this file is the mechanism.
- See also: `core/agent-loop.md` for where observation ends and verification
  begins.
- See also: `core/failure-recovery.md` for when verification reveals a
  failure instead of a pass.
- See also: `references/quality/testing-strategy.md` for the repo's test
  conventions to run as evidence.
