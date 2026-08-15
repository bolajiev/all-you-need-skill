## Self-Critique Loop

**Applies to:** the moment before any task is declared done — the agent's own pass to catch the mistakes no reviewer or test will see because it thinks the work is finished.

**Tier:** reference

---

### 1. Rule

Before declaring done, re-examine your own output as an adversary: run the change, re-read the diff against the requirement, and check the failure modes the happy path hides. Done means critiqued, not just written.

### 2. Why this matters (long-term cost of getting it wrong)

- An uncritiqued "done" hands the next gate (review, integration, production) a defect the agent is blind to because it authored it — and each gate becomes a fresh debug session.
- Confirmation bias is strongest right after writing; skipping the loop means the most obviously-wrong-for-certain-reasons mistakes survive.
- Small slips that self-critique would catch in seconds (wrong copy, missing edge case, scope creep) grow into visible rework when they ship.

### 3. Decision checklist

- [ ] Have I re-read my actual output (diff, files, commands) rather than my memory of writing it?
- [ ] Does it satisfy the requirement as stated, including edge cases and the not-literal interpretation?
- [ ] Have I run it — the build, the tests, the command — rather than assuming?
- [ ] Did I check the failure modes for this specific change (see its reference file's red flags)?
- [ ] Would I accept this as a reviewer who did not write it?

### 4. Default pattern

1. Step back before the final summary: stop "making it work" and switch to "trying to break it."
2. Re-read the actual artifacts — the diff, the changed files, the produced output — not the plan.
3. Run the verification the task's reference files prescribe: build, tests, smoke command, allowlist check.
4. Cross-check against the requirement and the relevant decision checklists; hunt specifically for the red flags listed in the files you touched.
5. Reconcile one concrete weakness found and fixed before "done" — if you found nothing at all, your critique wasn't adversarial enough.

```
before declaring done:
  diff --stat          # did I touch more or less than intended?
  re-run build+test    # does it still work as actually written?
  grep red-flags       # check this file's Section 6 against my output
  "would I accept this from someone else?"  -> if no, fix now
```

### 5. When the default doesn't apply

- User explicitly wants an unpolished, exploratory result ("just try it, don't polish") — the loop shrinks to "did it run."
- A read-only research/answer task whose deliverable is information, not artifacts — critique applies to accuracy of the answer, not code, and is still owed.
- Nothing: there is no task so trivial that re-reading your own output before claiming it's done is wasted.

### 6. Red flags (stopgap smells specific to this file)

- Declaring done from memory: "I wrote X, so X works."
- "I can't think of any edge cases" without having looked for them.
- Re-running nothing because "I was careful."
- Presenting the plan as the result without showing the verified output.
- The critic voice and the author voice sounding identical — no actual distance taken.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:
1. Name what's being deferred — e.g., "a full adversarial re-check of the shipped diff."
2. Name the specific cost — e.g., "an uncaught mistake ships to the next gate, turning a seconds-long self-fix into a review or production incident."
3. Write it into an ADR or a tracked TODO with an owner and a trigger (e.g., "perform the deferred critique before the work is merged or deployed").

### 8. Cross-references

- See also: `references/quality/code-review-checklist.md` for the checklist to run in the critic role.
- See also: `core/verification.md` for the verification steps that make the critique concrete.
- See also: `references/build/parallel-work-policy.md` for critiquing subagent results the same way as your own.
- See also: `core/agent-loop.md` for where in the loop this pass sits.
