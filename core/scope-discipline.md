## Scope Discipline

**Applies to:** every task — stay inside the stated spec and flag creep
loudly instead of absorbing it silently.

**Tier:** core

---

### 1. Rule

Implement exactly what the spec asks for and nothing more. When the task
grows beyond its stated bounds, stop, flag it, and get a decision before
expanding — don't absorb extra work quietly.

### 2. Why this matters (long-term cost of getting it wrong)

- Scope creep inflates every deliverable: the diff grows, review slows, and
  the unrequested changes are the least-tested and most likely to break.
- Features added beyond the spec complicate the things the spec did ask for,
  making the requested behavior harder to reason about and maintain.
- Silently out-of-scope work trains the user to expect it, so the next task
  drifts further; and unrequested changes to shared or prod systems carry
  permission risk (see `core/permission-boundaries.md`).

### 3. Decision checklist

- [ ] Does every change I'm making trace to a line in the spec?
- [ ] Am I about to touch a file, system, or feature the task didn't name?
- [ ] Have I discovered work that is genuinely needed but outside the spec?
- [ ] Did I flag the extra work to the user, or am I folding it in silently?
- [ ] Is the extra work a blocker for the requested task, or just adjacent?

### 4. Default pattern

1. At task start, write the spec's boundary in one line: what's in, what's
   out.
2. During work, every change must trace to that boundary. "While I'm here"
   improvements are out unless the user asked.
3. When you discover adjacent work that is genuinely needed:
   - If it blocks the requested task → flag it to the user with the reason
     and the options; proceed only with direction.
   - If it's needed for correctness of the requested change → say so and get
     sign-off before adding it.
   - If it's merely nice → note it for the user as a follow-up candidate;
     do not implement it.
4. If a defect unrelated to the task surfaces, report it — don't fix it
   unless the user approves, and don't hide it either.
5. Record the boundary and any flagged follow-ups in the plan and the final
   report, so "done" (`core/definition-of-done.md`) can be checked against
   the exact spec.

### 5. When the default doesn't apply

- Explicit user scope: the user expands the spec, or pre-authorizes
  discretion ("fix anything you find broken"). Then the expanded boundary is
  the spec.
- Disposable/demo context: a throwaway artifact where the user confirmed only
  rough equivalence to the spec matters; stated as such.
- Hard constraint: the requested task is impossible without a minimally
  adjacent change (a missing import, a required permission) — that change is
  made, named in the report, and justified.

### 6. Red flags (stopgap smells specific to this file)

- "While I was in there, I also fixed..." in a completion report.
- A diff with hunks that no spec line explains.
- Silently renaming or restructuring things the task never mentioned.
- Absorbing an adjacent bug fix because it was "too small to mention."
- Unrequested writes to files or systems outside the workspace.

### 7. If a shortcut is genuinely necessary

1. Name what's being deferred: the explicit user decision on the scope
   expansion.
2. Name the cost: out-of-scope work is untested against the spec, unapproved
   against permission boundaries, and raises the review and maintenance cost
   of everything it touches.
3. Write it into an ADR or a tracked TODO with an owner and a trigger (e.g.
   "when the spec is next reviewed"), and report it as "in scope" vs "flagged
   out of scope" so the boundary stays auditable.

### 8. Cross-references

- See also: `core/definition-of-done.md` — "done" is measured against the
  spec boundary defined here.
- See also: `core/permission-boundaries.md` for out-of-scope actions that
  also cross a permission line.
- See also: `core/ambiguity-resolution.md` for when "is this in scope?" is an
  ambiguity you must not assume away.
