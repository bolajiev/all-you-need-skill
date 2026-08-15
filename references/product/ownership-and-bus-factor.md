## Ownership and Bus Factor

**Applies to:** any system, service, script, data pipeline, or piece of shared
state that someone will need to change, debug, or understand after the person
who built it is gone — including this agent, which can be replaced at any time.

**Tier:** reference

---

### 1. Rule

Every system has a named owner, and knowledge must be recoverable without
access to the person who wrote it. A system whose behavior lives only in one
person's head — or one agent's context — has a bus factor of one and is not
done.

### 2. Why this matters (long-term cost of getting it wrong)

- When the sole person or agent is unavailable, a single question ("why does
  this do that?") becomes a full reverse-engineering session; the cost of
  every change multiplies.
- Knowledge concentrated in one place silently becomes load-bearing: the
  artifact is "owned" by nobody, so nobody notices when it breaks or when it
  drifts out of date.
- An ownerless system has no one to veto or review changes — maintenance
  decisions get made reactively, in incidents, instead of deliberately.
- For agent work specifically: an agent's context is ephemeral. Anything that
  only exists in the conversation disappears when the session ends.

### 3. Decision checklist

- [ ] Does this system have a named owner — a person or team accountable for
      it, not "the person who wrote it last"?
- [ ] Could someone else pick this up from the repo/docs alone, with no access
      to the author?
- [ ] Are the non-obvious decisions (why X, why not Y) written down, not just
      encoded in the code?
- [ ] If ownership is assigned to a person: do they know they own it, and is
      there a backup owner?
- [ ] If this is agent-produced work: has the durable knowledge been written
      to a file that outlives the session?

### 4. Default pattern

1. **Assign ownership at creation.** When a system is created — or inherited —
   record a named owner (person or team) plus a backup. "The team" or "the
   last editor" is not an owner.
2. **Make the knowledge explicit in the repo.** The non-obvious decisions go
   in the architecture record: why this design, what constraints, what was
   rejected. If a future agent or engineer can't answer "why is this here?"
   from the repo, the bus factor is still one.
3. **Document runnable truth, not just structure.** The owner, the entry
   points, the deploy/run commands, the known failure modes, and the
   escalation path must be findable without asking anyone.
4. **For agent-produced work: write it down before the session ends.** If a
   future session needs to continue this work, the checkpoint and the
   decision trail must exist in files — the agent's context window is not
   durable storage. See `agent-state/session-continuity.md`.
5. **Re-check ownership on handoff.** When the responsible person or agent
   changes, the new owner is named explicitly, and the knowledge is confirmed
   to live in the repo, not in the departing context.

```
ownership record (goes in the repo, near the system):
  owner:        [person/team]
  backup owner: [person/team]
  entry points: [how to run / deploy / debug]
  decisions:    [why X, not Y — or pointer to the ADR]
  known failure modes: [what breaks and how to tell]
  escalation:   [who to call when the owner is unavailable]
```

### 5. When the default doesn't apply

- **Explicit user scope** — the user says a thing is throwaway and names
  nobody responsible; then it's a disposable artifact and the default is
  relaxed by the user's own framing.
- **Disposable/demo context** — one-off scripts and demo code with a confirmed
  short lifetime need a named owner but no full knowledge base.
- **Hard constraint** — a system that truly can't have a second owner (single
  specialist); then the knowledge transfer is still mandatory, and the
  single-owner risk is documented as a debt item.

### 6. Red flags (stopgap smells specific to this file)

- "Ask [person/agent] — they built it" as the way to learn anything.
- The repo answers nothing; all understanding is conversational.
- A system with no owner recorded and no place the owner would be recorded.
- Agent work that exists only in the conversation — no checkpoint, no written
  summary — and would be unrecoverable if the session ended.
- "Everyone knows how this works" with no written evidence that anyone does.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "not writing the decision trail to the
   repo to save time, relying on the author still being around."
2. Name the specific cost of not fixing it: e.g. "the next change to this
   system becomes a reverse-engineering effort the moment the author is
   unavailable, and the accumulated 'everyone knows' knowledge vanishes with
   them."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: e.g.
   "TODO: document design decisions + owner for [system] — owner: [current
   author], trigger: next change to the system or author handoff."

### 8. Cross-references

- See also: `agent-state/session-continuity.md` and `agent-state/checkpointing.md`
  — how agent-produced knowledge is made durable.
- See also: `agent-state/escalation-triggers.md` — what to do when the owner
  is unavailable.
- See also: `core/architecture-decisions.md` — the ADR record is a core part
  of making knowledge survive the author.
- See also: `references/anti-patterns.md` — "knowledge lives in the author,
  not the repo" is the file-level smell this file guards.
