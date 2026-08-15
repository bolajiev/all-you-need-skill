## UX Writing

**Applies to:** any task that produces words a user reads — button labels,
form fields and validation, error and empty states, loading text, confirmation
dialogs, notifications, onboarding copy, and every placeholder string.

**Tier:** reference

---

### 1. Rule

Write like a user guides themself, not like a manual explains a system: state
what happened, why it matters to them, and the one next step — in that order,
in the fewest words that are still unambiguous. Every string must be able to
answer "what do I do now?" on its own, with no other context.

### 2. Why this matters (long-term cost of getting it wrong)

- Ambiguous or jargon-heavy copy sends users to support for things the UI
  already answered; each preventable ticket is a permanent cost center, not a
  launch-day blip.
- A vague action label ("Submit", "OK") is a trap users learn the hard way —
  click it and discover it was destructive; one expensive mistake destroys more
  trust than the feature ever builds.
- Error text that names the failure but not the fix ("Request failed") makes
  the retry rate collapse and turns recoverable moments into dead ends.
- Every placeholder, toast, and button string is written once but read by
  thousands of users thousands of times; the cheap-looking pass on copy is the
  most-read code you'll ever write.

### 3. Decision checklist

- [ ] Does every string tell the user what happened, why it matters, and the
      one next step — no manual required?
- [ ] Does every button/link label say exactly what the action does ("Delete
      project" not "OK"), and is it unique from other labels on the screen?
- [ ] Are errors actionable: what went wrong, why (in one line), and the fix?
- [ ] Is the tone consistent — one voice across empty, error, and success
      states, never a blend of formal and casual?
- [ ] Are numbers, dates, and technical terms formatted the way the user
      already says them, not the way the API does?
- [ ] Are empty/loading/confirmation states written, not left as the default
      "…" placeholder?

### 4. Default pattern

1. **Name the verbs like a command to the user, at reading level.** Prefer
   "Send report", "Resume billing", "Remove card" over "Submit", "Confirm",
   "OK". If a label needs a sentence, it's not a button — it's a page.
2. **Build the error state from the user's next step**, not the system's
   failure:

```
BAD : "Error 500. An unexpected error occurred."
GOOD: "Your report wasn't sent. Check the file size (max 5 MB) and try again."
```

3. **Empty states get three beats** — what's here now, what it's for, one
   action: "No saved filters yet. Saved filters let you re-run a search in one
   click." + [Create filter].
4. **Confirmation dialogs name the irreversible thing and the consequence**:
   "Delete this project? It can't be undone and all exported reports are
   removed with it." + [Cancel] [Delete project].
5. **Tone = calm, specific, and brief.** Same voice in loading ("Syncing your
   3 drafts") and errors ("We couldn't sync — check your connection and try
   again"). No jokes, no all-caps, no apology loops that stall the next step.
6. **Numbers and dates in the user's units** — what the user sees, not the
   ISO string or epoch. Format once at the edge, never in business logic.
7. **Keep copy with the feature it describes.** Strings live next to the code
   that renders them, reviewed in the same diff, not in a separate doc that
   drifts (see `design/design-to-code-handoff.md`).

### 5. When the default doesn't apply

- **Explicitly technical audience, explicitly requested** — an agent-facing or
  API-tool surface where the user asked for exact system terms; then precision
  beats plain language, but labels must still name the action.
- **Demo/throwaway scope** — the user confirmed the copy is placeholder for a
  mock; then a consistent placeholder is fine, but it's stated as placeholder
  and replaced before anything real ships.
- **Hard constraint — legal or compliance strings** — regulated text that can't
  be rewritten (e.g. "By continuing, you agree to…"): use it verbatim, then
  wrap the surrounding UI copy in the plain-language voice.

### 6. Red flags (stopgap smells specific to this file)

- Button labels that are verbs the user doesn't own ("Submit", "Validate",
  "Execute") or generic "OK"/"Yes".
- Error strings that report the code or the symptom but no next step.
- Empty states left as the default "No data" with no action.
- Copy that mixes two tones in the same flow (one screen "please enter…",
  next screen "You got this!").
- Placeholders (lorem ipsum, "…", "TODO") committed for anything a user can
  reach.
- Success text that says "completed" when the user still has another required
  step to do.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "shipping the error and empty states with
   generic system-level copy until the failure modes are finalized."
2. Name the specific cost of not fixing it: e.g. "users hitting the generic
   error can't self-recover, so every such moment becomes a support ticket and
   a lost session."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: TODO
   "rewrite error/empty strings from real failure data — owner: [name],
   trigger: first 10 production error events logged or the data layer freezes."

### 8. Cross-references

- See also: `design/interaction-design.md` — the four states this copy fills
  in (empty/loading/error/content).
- See also: `design/accessibility.md` — copy must be clear out loud too
  (screen readers, color-independent wording).
- See also: `design/design-to-code-handoff.md` — strings hand off with the
  component, not separately.
- See also: `quality/observability.md` — error copy should mirror what the
  event log actually knows.
- See also: `core/architecture-decisions.md` — why the voice and tone choice
  is decided once, not per-screen.
