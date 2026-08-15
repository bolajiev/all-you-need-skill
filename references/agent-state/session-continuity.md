## Session Continuity

**Applies to:** any task that spans multiple sessions, resumes after an interruption, or hands off between agent runs — anything where the next session cannot assume the current context still exists.

**Tier:** reference

---

### 1. Rule

At every boundary where a session might end, persist everything needed to resume — the goal, the state, the next action, and how to verify progress — so a fresh session can continue with no loss and no ambiguity.

### 2. Why this matters (long-term cost of getting it wrong)

- A session that dies with its plan only in context forces a rebuild from raw memory, which silently rewrites the task's actual intent and decisions.
- Ambiguous persisted notes ("did the migration?" / "mostly done") get interpreted differently by the next session, undoing or duplicating work.
- Without a recorded next action, the resuming session starts by guessing, and guesswork at resume is where mistakes get made.
- An invisible boundary is the classic place decisions get re-litigated — the new session re-decides things the previous one already settled.

### 3. Decision checklist

- [ ] Could this session end right now, and could a fresh session continue from the persisted state alone?
- [ ] Does the persisted state record the goal, the decisions made, and the current position — not just raw files?
- [ ] Is the next concrete action stated, with the condition that triggers it?
- [ ] Can the next session verify where the work actually stands, independent of my summary?

### 4. Default pattern

At each checkpoint (see `checkpointing.md`) and at any point where the session might end, write a resume note covering:

```
1. Goal — what the task is, in one or two sentences, and the user's
   acceptance criteria.
2. Decisions — what was decided and why (point to an ADR when one
   exists), so the next session doesn't re-litigate.
3. Position — what has been done, what is in flight, what is blocked.
4. Next action — the single next step and the condition that triggers
   it, with the exact command/verification for it.
5. Verification — how the next session confirms actual progress (the
   canonical check, e.g. a test run, a state query, a file hash), not
   trust in the summary.
6. Pointers — paths to the durable artifacts (files, checkpoints,
   logs) rather than copies in the note.
```

- Write the resume note as if the reader knows nothing of this session — that is the actual condition at resume.
- Re-read the resume note at the start of any resumed session before acting; verify position before taking the next action.

### 5. When the default doesn't apply

- **Single-session tasks completed within one run** — no boundary is crossed, so no resume note is needed (but a checkpoint may still be).
- **Disposable/demo context** — work intentionally thrown away at session end: the note is unnecessary because nothing needs resuming.
- **The next session is the same agent explicitly instructed to redo the task from scratch** — the user's stated intent replaces continuity.

### 6. Red flags (stopgap smells specific to this file)

- A resume note that only lists files, with no goal or next action.
- "Mostly done" / "just needs finishing" with no verification step.
- Decisions recorded nowhere, so the next session can change them silently.
- Trusting the prior summary instead of verifying the actual state before continuing.
- A fresh session re-deciding something the note already settled.

### 7. If a shortcut is genuinely necessary

1. Name what's being deferred: e.g. "no resume note; continuing in this same live session only."
2. Name the specific cost: if the session dies, the task must be rebuilt from memory and prior decisions are lost; say when it bites (any interruption before completion).
3. Write it into an ADR or a tracked TODO with an owner and a trigger (e.g. "write the resume note at the next natural checkpoint; owner = [x], trigger = before any pause in the task"). No silent exceptions.

### 8. Cross-references

- See also: `checkpointing.md` — the state snapshots the resume note points to.
- See also: `context-management.md` — what to drop from context because the resume note holds it.
- Escalates to: `core/definition-of-done.md` when resuming must confirm what "done" means.
- Escalates to: `references/agent-state/escalation-triggers.md` when the persisted state is too ambiguous to resume safely.
