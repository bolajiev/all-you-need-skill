## Progress and Status Communication

**Applies to:** any long-running, multi-step task — anything that will take more
than a few tool calls, involve waiting, or produce intermediate results the user
should not have to guess at. About cadence and status, not decisions or costs
(those live in `references/product/tradeoff-communication.md`).

**Tier:** reference

---

### 1. Rule

Report progress at a predictable cadence, always say what you are doing right
now, pause for a check-in before an irreversible or high-cost step, and report
failure honestly and immediately — never let a task end ambiguous about whether
it succeeded. If the user is not watching the screen, you still write the update
so the record exists in the audit trail.

### 2. Why this matters (long-term cost of getting it wrong)

- Silent progress is indistinguishable from a hang; the user cannot tell whether
  to intervene or wait, so they either interrupt mid-operation (corrupting state)
  or wait on something already failed.
- A final "done" message that omits a partial failure leaves the user believing
  a step completed; the defect surfaces later as data loss or an unexplained bug
  with no blame-free record of how it happened.
- Checking in only at the end forces costly rework — an expensive, opinionated
  step executed on the wrong assumption could have been reversed in seconds if
  the check-in had come earlier.
- Inconsistent cadence teaches the user that your updates carry no signal; they
  stop reading them, so real warnings get ignored at exactly the moment that
  matters.

### 3. Decision checklist

- [ ] Does this task take long enough that the user could reasonably wonder
      what I'm doing right now? (If yes, pick a cadence now, not on the fly.)
- [ ] Is there an upcoming step that is irreversible or high-cost — an
      external side effect, a destructive change, a purchase/commit? (If yes,
      pause and check in before it.)
- [ ] Do I know, right now, the single most useful thing to report to the
      user about where I am?
- [ ] Have I hit a failure? If so, have I said so in this update, with the
      cause and the impact — not buried it under "progress"?
- [ ] Is my next communication going to be a checkpoint, a check-in, or a
      completion report? (Decide deliberately; don't let cadence drift.)

### 4. Default pattern

Three distinct message types. Never mix their purposes silently.

**1. Checkpoint (inform, no decision needed)** — emit at a regular cadence.
Default cadence: after every 2–4 tool calls, or every ~30–60 seconds of real
work, whichever comes first, and always at a step boundary. Shape:

```
Status: <in progress | blocked | awaiting input> — <one-line what I'm doing now>
Progress: <what's done>, <what's next>
Blocked on: <thing> (if blocked) | nothing
```

Keep each checkpoint to 2–3 lines. No ask, no decision, no apology — it is a
heartbeat, not a plea.

**2. Check-in (pause, decision required)** — before any irreversible or
high-cost step, or when two reasonable paths have materially different
outcomes. Stop and wait for a reply; do not proceed on the default silently.
Check-in triggers include: first external side effect of a task, destructive
operations, anything consuming real money or quota, scope-expanding work the
user did not ask for, or results that contradict what the user stated.

```
I'm about to <action>. This will <consequence>. Proceed, or adjust?
```

**3. Completion report (final)** — one structured block, never just "done":

```
Result: <success | partial | failed>
What happened: <2–4 lines, the honest summary>
Key outputs: <paths, IDs, links>
Unresolved: <what's incomplete, with owner/trigger or TODO link, if anything>
```

Report partial failure explicitly in the first word — `Result: partial`, not
`Result: success` with caveats in a footnote.

Failure reporting rules, for all three types:

- Lead with the failure. "Step 3 of 5 failed: X" beats "Completed steps 1–2,
  continuing...".
- Say the cause, the impact, and what you did next (retry, rollback, asked,
  stopped). Do not soften; do not self-critique — state facts.
- Never present a retry as new work without saying it is a retry.
- When blocked, say exactly what you need from the user to unblock, or the
  wait-and-revisit time if it is time-based.

Cadence defaults: use the 2–4-tool-call checkpoint cadence for anything
multi-step; tighten to per-call updates while a failure is being investigated;
use check-ins only where the checklist in section 3 flags them — checking in on
every step is its own failure mode.

### 5. When the default doesn't apply

- Explicit user scope: the user says "don't update me, just finish" — then
  suppress checkpoints but still send a completion report and still pause on
  irreversible steps. Silent-by-request never waives the failure report.
- Trivially short tasks: a single fetch that returns in one tool call needs no
  checkpoint, just the final result. The cadence only kicks in past a few calls.
- Disposable/demo context: throwaway scripts or one-off verification where the
  user is watching interactively and every step is visible — steady checkpoints
  become noise. Keep the completion report.

### 6. Red flags (stopgap smells specific to this file)

- The task has run several tool calls and the user has seen no update at all.
- A message says "continuing" or "working on it" but doesn't say what step or
  what it's doing right now.
- A completion report says "done" while a step silently failed or was skipped.
- The same update describes a step both as "done" and "will verify later" — if
  verification hasn't happened, say it's pending.
- A check-in is phrased so the user can only say yes — no real option, no
  consequence stated.
- Cadence is driven by the user asking "how's it going?" more than once in one
  task; that is the user compensating for a missing heartbeat.

### 7. If a shortcut is genuinely necessary

No shortcut is acceptable here — the default is a few lines per checkpoint and
the cost of skipping it is the user acting on wrong or stale status. If a
downstream dependency (e.g., a tool that cannot be run non-interactively) makes
a check-in impossible, do not proceed silently: name the deferred check-in,
name the cost (an irreversible step may run on an unvalidated assumption), and
record it in the ADR or a tracked TODO with an owner and the trigger (the next
time that task shape runs, or before any dependent side effect fires).

### 8. Cross-references

- See also: `references/product/tradeoff-communication.md` for what to say when
  a decision involves cost/benefit — this file covers cadence and status only.
- See also: `references/agent-state/audit-trail.md` — progress updates are
  written even when the user isn't watching, so the record persists.
- See also: `references/agent-state/checkpointing.md` for how work state is
  persisted between checkpoints (vs. the messages here that report on it).
- Escalates to: `references/agent-state/escalation-triggers.md` when the user
  stops responding to check-ins or a failure needs human intervention.
- Depends on: `core/definition-of-done.md` for what counts as "done" in a
  completion report; `core/architecture-decisions.md` for the ADR path used in
  section 7.
