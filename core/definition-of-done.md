## Definition of Done

**Applies to:** every task — the explicit exit criteria that must hold before
the work is reported complete.

**Tier:** core

---

### 1. Rule

A task is done only when its stated exit criteria all pass — implemented,
verifiable, and confirmed — not when the code compiles and the agent is tired
of it.

### 2. Why this matters (long-term cost of getting it wrong)

- Reporting done before verification passes ships broken behavior that the
  user has to catch and re-open — a trust tax on every future interaction.
- "It builds, so it's done" misses behavioral errors that only runtime
  evidence exposes, and those escape to the user or to prod.
- Vague completion lets scope creep and half-finished edges hide behind a
  claimed "done"; each undone edge is a new defect later.

### 3. Decision checklist

- [ ] Do the exit criteria exist in writing, from the task spec and the
  relevant file's Section 4, before I start?
- [ ] Has every criterion been demonstrated by actual evidence (tests run,
  output observed), not by reasoning?
- [ ] Did verification (`core/verification.md`) pass against the real
  artifacts, not just against my intention?
- [ ] Is everything within the spec done, and everything outside it flagged
  rather than half-done (`core/scope-discipline.md`)?
- [ ] Have I stated the concrete criteria I'm asserting done against?

### 4. Default pattern

Before acting, derive the exit criteria for the task:

1. Write the criteria as observable statements: "endpoint returns 200 and the
   row appears in table X" — not "endpoint works".
2. For each criterion, name the evidence that will prove it: a test, a curl,
   a file diff, a log line, a rendered page.
3. Execute the task (see `core/agent-loop.md`).
4. Run the evidence. Do not count "it should work" as a pass.
5. Only then report done, and report against the criteria:
   `Done. Criteria: [X] verified by [evidence], [Y] verified by [evidence].`

Default exit criteria for a code task (apply unless the task narrows them):

- The change is implemented exactly per spec (no unrequested changes).
- Lint and typecheck pass (whatever the repo defines them to be).
- Relevant tests pass, including a new test for the change where the repo has
  a test framework.
- The change was verified against the running artifact, not just a compile.
- No silent stopgaps: any deviation is in an ADR or a tracked TODO
  (`core/architecture-decisions.md`).
- The diff is readable and the code follows the repo's conventions.

### 5. When the default doesn't apply

- Explicit user scope: the user narrows done for a task ("just the happy
  path, no tests"). The written criteria then match that scope and are still
  verified.
- Disposable/demo context: a throwaway deliverable may skip the full exit
  criteria; state that the lighter criteria apply and why.
- Hard constraint: no runtime available (e.g. offline). Then the criteria are
  adjusted to "static analysis passes" and the missing runtime verification
  is recorded, not ignored.

### 6. Red flags (stopgap smells specific to this file)

- Saying "done" with no criteria stated anywhere.
- "It compiles" as the only evidence.
- Claiming verification that wasn't run (no command, no output).
- Counting a half-implemented edge as done and "flagging it for later".
- Reporting done while a Section 7 shortcut is unlogged.
- Tests written but not run, or run against a stale artifact.

### 7. If a shortcut is genuinely necessary

1. Name what's being deferred: the specific exit criterion not met.
2. Name the cost: the behavior it covers is unproven — if it's wrong it
   reaches the user or prod as a defect, and the fix is more expensive later.
3. Write it into a tracked TODO with an owner and a trigger (e.g. "when a
   runtime environment is available", "when the CI pipeline exists"), and
   state "done, except X" — never "done".

### 8. Cross-references

- See also: `core/verification.md` — the mechanism that produces the evidence
  DoD requires.
- See also: `core/scope-discipline.md` — for ensuring "done" covers exactly
  the spec, nothing else.
- See also: `references/quality/testing-strategy.md` for what tests count as
  evidence in this repo.
