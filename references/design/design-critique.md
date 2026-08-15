## Design Critique

**Applies to:** any task where a design decision — a layout, a flow, a
component, a full screen, or a visual choice — is about to be built or
shipped, and needs to be evaluated against principles before it costs anything
to change.

**Tier:** reference

---

### 1. Rule

Critique a design as designed, before build, using named principles and
heuristics — not taste ("I don't like it") and not after the fact. Every
design, including your own, gets a structured pass against usability,
hierarchy, consistency, and goal-fit before it's called done.

### 2. Why this matters (long-term cost of getting it wrong)

- An uncritiqued design ships its mistakes into code; the fix is a rebuild
  plus the regression risk of touching a screen users already depend on.
- Critique-as-opinion ("this looks off") produces directionless churn — the
  next reviewer reverses the last reviewer's taste, and the design drifts with
  whoever complained loudest.
- Hierarchy and goal-fit problems are cheapest to catch on a static screen and
  most expensive after launch analytics prove the wrong thing is prominent.
- A team that never critiques its own work repeats the same known failure
  (unlabeled buttons, buried primary actions) in every new feature.

### 3. Decision checklist

- [ ] What is the single goal of this screen, and does the design's strongest
      visual element serve that goal?
- [ ] Is the visual hierarchy truthful — does the most important thing look
      most important?
- [ ] Does the design break the app's established patterns, and if so, is the
      break justified in the spec?
- [ ] Are all four states (empty/loading/error/content) at least accounted
      for, not just the happy path?
- [ ] Can a first-time user and a returning user both find the primary action
      in under five seconds?
- [ ] Have I critiqued with named heuristics and written findings, or only
      said "looks good"?

### 4. Default pattern

1. **Critique before build, in three passes.** Do them in order; each pass
   catches what the previous one misses.

```
Pass 1 — Goal-fit: does every element earn its place for THIS screen's job?
          Cut anything that serves another screen's goal.
Pass 2 — Heuristics (Nielsen-style scan): visibility of state, match to real
          world terms, user control (undo/escape), consistency, error
          prevention, recognition over recall.
Pass 3 — Hierarchy & consistency: visual weight order, alignment, spacing
          rhythm, and match against existing components in the design system.
```

2. **Write findings as severity-tagged, principle-backed items**, not taste:

```
[BLOCKER] Primary action "Save" is visually quieter than "Cancel" —
          hierarchy false, violates goal-fit.
[MAJOR ] Destructive "Delete" has no confirmation — error prevention.
[MINOR ] Label "File" vs "Document" differs from onboarding copy — consistency.
```

3. **For your own design, play both critic and author.** Rest, then re-read
   the screen as a stranger with the goal stated in one sentence (see
   `design/ux-research.md` for naming the goal).
4. **Fix or formally defer every finding before build.** A finding that stays
   open is a shortcut — it goes through Section 7, not into the code silently.
5. **Keep the critique record** next to the design (in the spec or ADR) so
   later changes don't reintroduce the same blocker.

### 5. When the default doesn't apply

- **Explicit throwaway/demo scope** — the user said "quick mock for the pitch,
  don't overthink it"; then a single goal-fit pass is enough, and the demo-only
  status is stated in the spec.
- **Hard constraint — time-boxed fix on a shipped screen** — a small change to
  a live screen with real usage; then critique only the delta against the
  existing pattern, not the whole screen.
- **Designer/decision-owner overrides a finding** — a human explicitly accepts
  a trade-off (e.g. brand wants a louder hero); record the decision in an ADR
  and move on — that's a decision, not a shortcut.

### 6. Red flags (stopgap smells specific to this file)

- "Looks good" as the whole critique, with no named principle.
- Criticism expressed as taste ("it feels off") with no fix or severity.
- A blocker found in critique shipped anyway "to save time" with no record.
- Only the happy path critiqued; error/empty/loading states never mentioned.
- A screen that contradicts the design system because "this case is special"
  with no rationale.
- Critique done after build ("let's see how it feels once it's running") as
  the first pass.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "shipping the primary action with equal
   visual weight to its neighbors, known to hurt task completion."
2. Name the specific cost of not fixing it: e.g. "users hesitate or miss the
   main action, measurable as lower completion on the core task, and the
   hierarchy fix later becomes a visual rework of the screen."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: TODO
   "restore hierarchy on primary action — owner: [name], trigger: next
   usability pass or first completion-rate event below target."

### 8. Cross-references

- See also: `design/ux-research.md` — the goal-fit pass needs the stated
  user/job this design must serve.
- See also: `design/interaction-design.md` — state coverage is critiqued
  against the flow's states.
- See also: `design/visual-design.md` — the named principles for hierarchy and
  consistency.
- See also: `design/usability-testing.md` — a finding can be confirmed or
  killed by watching a real task, instead of opinion.
- See also: `quality/self-critique-loop.md` — the same discipline applied to
  code and results.
- See also: `core/architecture-decisions.md` — recorded decisions (including
  accepted findings) live here.
