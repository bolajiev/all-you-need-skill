## Research

**Applies to:** any task where the agent is about to build something and does
not already know the codebase, the relevant docs, the existing APIs, or the
prior art around the problem. Research ends when the unknowns needed for a plan
are answered — not when you've read everything.

**Tier:** reference

---

### 1. Rule

Research before you build, but time-box it: gather just enough to write a plan
and answer the specific unknowns, from primary sources (docs, code, upstream
repos) before secondary sources (blog posts, your own memory). Research is done
when the planning checklist can be answered, not when curiosity is satisfied.

### 2. Why this matters (long-term cost of getting it wrong)

- Building from a wrong assumption about an existing API or data shape means
  reworking code that "worked" in isolation but can't integrate.
- Duplicating something that already exists in the codebase (a helper, an
  endpoint, a table) produces two divergent implementations that both drift.
- Skipping upstream-doc checks makes you reinvent an API that already exists,
  then maintain your worse version forever.
- Unbounded research never ends and produces nothing shipped; it's a different
  failure but just as expensive.

### 3. Decision checklist

- [ ] What are the 2–3 specific unknowns I must resolve before I can write a
      plan?
- [ ] Does the answer live in this codebase (search first) or outside it
      (docs/upstream)?
- [ ] Have I confirmed my assumption against a primary source, or am I relying
      on memory/guessing?
- [ ] Can I state, in a few lines, what I found and what I'm going to build
      against it?
- [ ] Have I been at this long enough that I should stop and state what I know
      instead of searching more?

### 4. Default pattern

1. **Search the codebase first** — the answer is usually already there: grep
   for the concept, read the nearest working example, look for existing
   wrappers/handlers before assuming one is needed.
2. **Then check primary external sources** — official docs, the upstream repo,
   package README, changelog for the exact version in use.
3. **Verify against the actual installed version** — docs describe the latest;
   check what's pinned in `package.json`/`requirements.txt`/lockfile.
4. **State findings as a short decision note** — "X exists at path Y and does
   Z; I'll reuse it / build against version V / add endpoint E."
5. **Stop when the plan is writable** — if the research didn't change the plan,
   it was excess; if you still can't write the plan, name the one missing
   unknown and target exactly that.

```
Research loop:
  unknown -> search codebase -> found? -> build against it
                          \-> not found -> check upstream docs for pinned
                              version -> still unknown -> one targeted
                              question to user, then STOP
```

### 5. When the default doesn't apply

- **Explicit user direction** — the user names the exact library/approach and
  says not to re-research; accept the constraint and skip straight to the plan.
- **Pure exploration task** — when research *is* the deliverable (a spike, a
  feasibility check), the loop above is the whole task; "when is it done" is
  defined by the question asked, not by a build step.
- **Demo/disposable context** — a throwaway prototype doesn't warrant deep
  codebase archaeology; the cheapest correct-enough answer is fine.

### 6. Red flags (stopgap smells specific to this file)

- Writing code that calls an API, class, or endpoint that was never verified to
  exist.
- Quoting an API from memory instead of the docs or the pinned version.
- "I'll just add my own X" when a search for X in the repo was never done.
- Hours spent reading when the plan could have been written after the first
  answer.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "building against a guessed API shape
   without verifying the installed version's docs."
2. Name the specific cost of not fixing it: e.g. "integration will fail at
   first runtime call and the fix is unknown until the real shape is read."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: TODO
   "verify `X` signature against installed version before step 5 lands, owner:
   [agent/user], trigger: first successful compile" — not a bare comment.

### 8. Cross-references

- See also: `planning/planning.md` — research feeds the plan; the plan tells
  you when research is done.
- See also: `architecture/dependency-selection.md` — research on third-party
  choices follows that file's process.
- See also: `core/architecture-decisions.md` — significant research conclusions
  should be recorded, not held in the agent's head.
