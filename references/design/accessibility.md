## Accessibility

**Applies to:** any task that renders HTML or any UI — semantic structure,
screen-reader support, focus management, contrast, target sizes — before the
UI is considered complete. WCAG 2.2 AA is the baseline, not a stretch goal.

**Tier:** reference

---

### 1. Rule

Build accessible by default: use semantic HTML, keep focus visible and
ordered, meet WCAG 2.2 AA contrast, and never communicate meaning with color
alone. Accessibility is part of the build, not a pass that happens later.

### 2. Why this matters (long-term cost of getting it wrong)

- Retrofit costs multiply: an inaccessible modal or keyboard trap found in
  review requires rebuilding the interaction, not tweaking a style.
- Keyboard users and assistive-tech users are blocked outright by focus traps
  and missing labels — they hit a wall, not a bug, and the failure is silent
  (no error, no ticket, just abandonment).
- Low contrast and tiny targets are cumulative: they fail automated checks
  that block CI later, or ship and quietly exclude a large share of users.
- Color-only indicators (red = failed) are meaningless to the color-blind and
  to users of high-contrast themes, and they often carry no semantic role for
  assistive tech either.

### 3. Decision checklist

- [ ] Is the structure semantic (native `<button>`, `<a>`, `<nav>`, headings in
      order) rather than `div` + click handler?
- [ ] Can the entire flow be completed with the keyboard alone, with a visible
      focus indicator at every step?
- [ ] Does every control have an accessible name (visible label, `aria-label`,
      or associated text)?
- [ ] Is body text contrast >= 4.5:1 and large text >= 3:1 on every background,
      and is no meaning conveyed only by color?
- [ ] Are target sizes at least 24×24 px (44×44 px preferred)?
- [ ] Have I verified with an automated check plus a screen-reader or
      manual keyboard pass, not assumed it works?

### 4. Default pattern

1. **Use semantic HTML first; ARIA only to fix what HTML can't express.** A
   native button gives you focus, activation, and announcements for free.
   Reaching for `role` before native elements is a smell.
2. **Manage focus deliberately.** Tab order matches visual order; focus moves
   into a dialog on open and returns to the trigger on close; focus is never
   lost to the body behind a modal. No focus trap without an escape path
   (`Escape` closes the dialog).
3. **Name every control.** A visible label, or `aria-label` when a visible
   label is impossible. Icon-only buttons must have an accessible name.
   Status changes announce via `role="status"`/`aria-live` where the user
   didn't trigger the update.
4. **Contrast by default.** Check body text at 4.5:1, large text at 3:1, and
   non-text UI (borders, focus rings, icons) at 3:1. Use the color-pair
   verification in `design/visual-design.md`'s palette.
5. **Never color-only.** Every status shown with color also carries text, an
   icon, or both (error message under the field, not just a red border).
6. **Meet WCAG 2.2 AA as the floor** — target size (24×24 px minimum), focus
   not obscured, and consistent focus appearance included in the default pass.
7. **Verify before done** — run an automated check (e.g. axe) and a keyboard
   walkthrough of every flow; fix failures in the same change, per
   `core/verification.md`.

```
<button type="button" aria-label="Close dialog" onclick="...">✕</button>

<form>
  <label for="email">Email</label>
  <input id="email" type="email" required aria-describedby="email-hint">
  <p id="email-hint" role="status">Check your inbox for the confirmation.</p>
</form>
```

### 5. When the default doesn't apply

- **Explicit non-UI scope** — an API-only change with no rendered output; this
  file doesn't engage until a UI surface exists.
- **Hard constraint — platform without keyboard events** — a video or touch-only
  kiosk where the user confirmed keyboard access isn't applicable; note the
  constraint, don't silently skip.
- **Explicitly scoped internal tool** — a single-power-user automation where
  the user waived screen-reader support in writing; still keep labels and
  contrast, they're nearly free.

### 6. Red flags (stopgap smells specific to this file)

- `div onClick` where a `<button>` would do, or unlabeled icon buttons.
- Focus invisible, or lost entirely during keyboard navigation.
- Error/status shown only as color (red border, red text) with no text or icon.
- A modal with no focus trap or no Escape handler.
- "We'll run the accessibility pass later" with no accessibility pass scheduled.
- Arbitrary `tabindex` reordering of a page's natural flow.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "shipping the custom dropdown as a styled
   `div` without ARIA roles or keyboard support."
2. Name the specific cost of not fixing it: e.g. "keyboard and screen-reader
   users cannot operate it at all, and the fix is a rewrite of the control's
   interaction layer, not a style change."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: TODO
   "replace the `div` dropdown with an accessible pattern — owner: [name],
   trigger: the control ships or the next accessibility check runs."

### 8. Cross-references

- See also: `design/interaction-design.md` — states, keyboard flow, and focus
  are designed here, before this file verifies them.
- See also: `design/visual-design.md` — the palette must include verified
  accessible color pairs.
- See also: `design/design-systems.md` — accessible components belong in the
  system so they don't get rebuilt wrong.
- See also: `quality/code-review-checklist.md` — accessibility is a review
  gate, not an afterthought.
- Escalates to: `core/verification.md` when a screen can't be keyboard-verified
  before it ships.
