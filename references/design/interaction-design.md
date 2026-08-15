## Interaction Design

**Applies to:** any task that defines how a user moves through a UI — flows,
transitions, states, feedback, affordances, keyboard navigation, and what
happens when something loads, fails, or has no data.

**Tier:** reference

---

### 1. Rule

Every user action must produce a visible, truthful response, and every screen
must handle the four core states — empty, loading, error, partial — before it
is called done. Design the flow as a sequence of states, not as static frames.

### 2. Why this matters (long-term cost of getting it wrong)

- A missing state handling (blank list with no empty message, an unhandled
  error path) reads as broken even when the happy path is fine; users report
  the whole app as buggy and trust drops.
- Actions with no feedback (a save button that does nothing visible) make users
  double-submit, which corrupts data or charges twice.
- Flows designed as disconnected screens force users to re-derive context each
  step; the support cost and abandonment rate both climb.
- Affordances guessed wrong ("is this a button or a label?") are fixed only by
  a redesign or by support tickets telling you what users clicked by accident.

### 3. Decision checklist

- [ ] Can I draw this flow as states (empty → loading → error → content) for
      every view that can be in more than one of them?
- [ ] Does every user action have immediate, truthful feedback — disabled
      state while processing, then success or failure?
- [ ] Is destructive or irreversible action protected (confirmation, undo)
      rather than one click from happening?
- [ ] Can every interaction be completed with the keyboard alone, and is focus
      visible at each step?
- [ ] Have I handled the partial/failure states (retry paths) or only the happy
      path?
- [ ] Is the interaction pattern one the user has seen elsewhere (standard
      controls) rather than novel?

### 4. Default pattern

1. **Model the flow as a state machine per view.** Name each state, the
   trigger that moves between them, and what each renders:

```
state empty    : "No alerts yet" + primary action (Create/Refresh)
state loading  : skeleton or spinner, keep layout stable (no layout shift)
state error    : what failed, why in one line, retry button, stays on same URL
state content  : the data, with the primary action reachable above the fold
```

2. **Every action responds in under 300 ms with visible feedback.** Disable the
   button, show a pending state, then a definitive success or error result —
   never a silent "did it work?" (see `quality/observability.md` for wiring
   the result to a user-visible outcome).
3. **Give every element one job and one affordance.** Buttons look pressable,
   links look clickable, static text never looks interactive. If it's not
   interactive, it doesn't get hover/pointer styles.
4. **Protect the irreversible.** Confirmation dialog or undo with a visible
   timer for deletes, destructive bulk actions, and anything that costs money.
5. **Keep context while transitioning.** Returning from a detail view restores
   list position and filters; progressive disclosure (reveal advanced options
   on demand) hides complexity without removing it.
6. **Keyboard first, then mouse.** Tab order matches visual order, focus is
   visible at all times, common shortcuts documented (see
   `design/accessibility.md`).
7. **Use standard patterns the user already knows** — if you must invent an
   interaction, it needs a stated reason in the spec, because users won't
   learn novel gestures without coaching.

### 5. When the default doesn't apply

- **Explicit demo/dead-end scope** — a throwaway prototype where the user
  confirmed only the happy path will be shown; then states can be stubbed, but
  the omission is stated in the spec.
- **Internal tool with a single expert operator** — the agent itself or one
  named power user; keyboard-only, terse feedback is acceptable if the user
  asked for it explicitly.
- **Hard constraint — legacy framework** — the platform can't support skeleton
  states or focus management cleanly; then implement the states that are
  possible and record the gap, rather than skipping all of them.

### 6. Red flags (stopgap smells specific to this file)

- Screens built happy-path-only, with no empty or error state drawn.
- A button that does nothing visible while processing, or no disabled state.
- "The API never fails" as a reason to skip the error state.
- Novel interactions (drag-drop, gestures) added without a stated reason.
- Focus not visible during keyboard navigation, or tab order that jumps.
- No affordance difference between a button and a label that navigates.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "shipping the empty and error states as
   plain text until the data layer is finalized."
2. Name the specific cost of not fixing it: e.g. "users hitting an unhandled
   failure see a frozen screen and file a bug, and the empty state has no
   guided first-run, so onboarding stalls."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: TODO
   "replace text-only empty/error states with guided states — owner: [name],
   trigger: data layer ships or first user hits the error path."

### 8. Cross-references

- See also: `design/ux-research.md` — the user flow this interaction design
  must match.
- See also: `design/accessibility.md` — keyboard, focus, and states are part
  of the same build, not a later pass.
- See also: `design/design-to-code-handoff.md` — states and transitions become
  the implementable spec.
- See also: `quality/observability.md` — user-visible outcomes are wired so
  failures surface, not papered over.
- See also: `architecture/api-design.md` — the API shapes the error data the
  UI has to render.
