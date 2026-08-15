## Context Management

**Applies to:** any task long enough that the working set (files, conversation, tool output, intermediate results) could grow beyond what the agent can reliably hold and reason about.

**Tier:** reference

---

### 1. Rule

Keep only what the current step needs in context: write the rest to durable storage or a summary, and never let context grow until it degrades judgment — when you can no longer see the shape of the task, you can no longer finish it.

### 2. Why this matters (long-term cost of getting it wrong)

- Context bloat degrades the agent's actual performance: relevant facts get buried and the model starts acting on stale or truncated information.
- Keeping raw artifacts in context instead of summarizing them forces re-reading everything later, wasting the whole budget on retrieval instead of work.
- A bloated context makes verification dishonest — the agent can't tell which parts of the world are current, so it asserts based on memory.
- When a session dies, everything that lived only in context is lost (see `checkpointing.md`), so nothing in context is ever safe.

### 3. Decision checklist

- [ ] Is this item needed in the next few steps, or is it reference material for later?
- [ ] Have I already summarized or persisted this, so keeping the raw copy adds nothing?
- [ ] Is this the authoritative current version, or a stale duplicate I'm now carrying?
- [ ] Would truncation or loss of context now change the outcome of the current step?

### 4. Default pattern

```
1. Per step: hold only the working set — the files, facts, and
   outputs the immediate next action reads. Everything else goes to
   durable storage (files, notes, summaries).
2. Summarize to store: compress long tool output and intermediate
   results into a short, faithful note with a pointer to the source,
   not a copy of it.
3. Prune continuously: drop items that are done, superseded, or
   unchanged-and-unneeded. Replace large raw inputs with their
   conclusions once acted on.
4. Keep one source of truth: don't carry a value in context if it
   also lives in a file — read the file when needed.
5. Before a checkpoint (see `checkpointing.md`), write a compact
   state note so context can be rebuilt without the raw history.
```

- Budget context like any scarce resource: the cost of carrying something is paid on every subsequent step, so ask "what does carrying this cost me each step?" rather than "does it fit?"
- If a task can't fit in context even summarized, split it (see `session-continuity.md` and `core/definition-of-done.md`).

### 5. When the default doesn't apply

- **Very short, single-shot tasks** where the whole working set fits trivially — pruning machinery would cost more than it saves.
- **Interactive debugging of a specific failing path** where you're deliberately holding a chain of related values to trace a bug — held briefly, then summarized and dropped once the bug is fixed.
- **Explicit user scope** — the user wants the raw detail kept visible in the working set for their own review.

### 6. Red flags (stopgap smells specific to this file)

- Re-reading the same large file or output a second time because you didn't note it the first.
- Carrying both an artifact and its summary "just in case."
- A summary so vague ("it worked") it can't rebuild the state later.
- Keeping superseded versions of data in context alongside the new one.
- Context so large the agent can't state the current goal in one sentence.

### 7. If a shortcut is genuinely necessary

1. Name what's being deferred: e.g. "not summarizing tool output, keeping raw in context."
2. Name the specific cost: context degrades and later steps act on stale/truncated information; say when it bites (a step that needs the whole picture at once).
3. Write it into an ADR or a tracked TODO with an owner and a trigger (e.g. "refactor task into sub-steps with per-step notes; owner = [x], trigger = when this task's context next exceeds budget"). No silent exceptions.

### 8. Cross-references

- See also: `checkpointing.md` — what gets persisted so context can be dropped safely.
- See also: `session-continuity.md` — how rebuilt context is reconstructed across sessions.
- Escalates to: `references/agent-state/escalation-triggers.md` when the task can't be reduced to fit the context budget.
