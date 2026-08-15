## Failure Recovery

**Applies to:** any step that fails — retry policy, honest failure reporting,
and never papering over a broken step.

**Tier:** core

---

### 1. Rule

When a step fails, stop, diagnose the root cause, and report honestly. Retry
only when the failure is plausibly transient; never paper over a failure with
a fake success.

### 2. Why this matters (long-term cost of getting it wrong)

- Retrying blindly on a deterministic failure burns time and noise while the
  root cause sits untouched; the same failure recurs every run.
- Papering over a failure (reporting success on partial output) ships broken
  state that someone else has to unravel later.
- Repeated transient failures can silently become permanent ones; without
  observation each retry just restarts the same doomed command.

### 3. Decision checklist

- [ ] Is the failure plausibly transient (timeout, rate limit, flaky network)
  or deterministic (logic error, missing dependency, bad input)?
- [ ] Do I know the root cause from the error output, or am I guessing?
- [ ] Does the retry add backoff, or am I hammering the same thing?
- [ ] Have I told the user about the failure and what I found — or is it
  hidden?
- [ ] Is any partial success from the failed step accounted for before
  retrying?

### 4. Default pattern

On a failed step:

1. **Read the error.** Extract the actual cause from the output before
   deciding anything. Do not re-run hoping for a different result.
2. **Classify.**
   - Transient (timeout, 429, connection reset): retry with backoff — up to
     three attempts with increasing delay (e.g. 1s, 2s, 5s), then stop.
   - Deterministic (compile error, logic bug, wrong input): fix the root
     cause first. Do not retry the same command unchanged.
   - Unknown: diagnose further before any retry; guesswork retries are noise.
3. **Account for partial success.** If the failed step partially wrote state
   (a half-applied edit, a partially uploaded artifact), revert or complete
   that state before retrying, so the retry doesn't double-apply.
4. **Report.** Tell the user: what failed, the root cause you found, what you
   fixed, and the retry plan. Never hide a failure to keep the narrative
   clean.
5. **Escalate when stuck.** If the failure resists diagnosis, escalate to the
   user with what you know rather than grinding in circles — see the
   cross-references.

### 5. When the default doesn't apply

- Explicit user scope: the user directs a specific retry strategy ("keep
  retrying until it works", "give it three tries"). Their policy wins.
- Disposable context: a throwaway step can be retried more aggressively
  because partial state doesn't matter; still classify and observe.
- Hard constraint: no diagnosis available (opaque external API). Then the
  policy is limited, classified retries with honest "unknown cause" reporting
  — and the uncertainty is recorded.

### 6. Red flags (stopgap smells specific to this file)

- Re-running the identical failed command with no change and no backoff.
- Reporting a step as successful when its output shows an error.
- Skipping the error output because "I know what's wrong."
- Fixing the symptom, not the cause, then calling it recovered.
- Retrying into a rate limit without backoff, making the failure worse.
- Hiding a failure from the user to keep the summary clean.

### 7. If a shortcut is genuinely necessary

1. Name what's being deferred: the full root-cause diagnosis of the failure.
2. Name the cost: the underlying cause is still live, so the failure recurs —
   and the deferred diagnosis gets harder and more expensive the longer it
   sits.
3. Write it into an ADR or a tracked TODO with an owner and a trigger (e.g.
   "when the failure next appears", "when API docs become available") — and
   say "the step failed for an undiagnosed reason", never imply it succeeded.

### 8. Cross-references

- See also: `core/agent-loop.md` for where failures are first observed.
- See also: `core/verification.md` for confirming the fix actually recovered.
- See also: `core/architecture-decisions.md` for recording a failed-fix debt
  item properly instead of leaving it silent.
