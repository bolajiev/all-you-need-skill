## Design Systems

**Applies to:** any task that adds a UI component, color, spacing value, type
style, or interaction pattern that a future screen will likely reuse — before
hand-writing another one-off version of something that already exists.

**Tier:** reference

---

### 1. Rule

Extend the shared system before building bespoke: use existing components and
tokens, and when something genuinely new is needed, add it to the system as a
reusable, documented component — never silently grow a one-off.

### 2. Why this matters (long-term cost of getting it wrong)

- Every one-off UI ("just for this screen") becomes a second source of truth;
  the next screen copies whichever is nearest, and drift compounds with each
  new screen until the system is unidentifiable.
- Token drift is a silent breaking change: an inline color that "looks the
  same" today diverges tomorrow, and the divergence is only discovered when a
  themed/brand change has to touch every file by hand.
- Components built without a defined API (props, variants, states) can't be
  reused safely, so the same control gets reimplemented repeatedly with
  subtly different behavior.
- A system nobody documents is a system nobody trusts; unreviewed "helpers"
  accumulate and the next agent can't tell the sanctioned from the accidental.

### 3. Decision checklist

- [ ] Does a component or token already exist that covers this need, in the
      system this project has declared?
- [ ] If nothing fits, is this truly new, or a variant of something that
      exists (which should be extended instead)?
- [ ] Have I defined the new component's API — props, variants, states,
      accessibility behavior — rather than a one-off markup blob?
- [ ] Are color/spacing/type values from the token scale, never literal new
      values?
- [ ] Is the new addition documented where the next agent will look for it?

### 4. Default pattern

1. **Search before you build.** Check the project's declared system and the
   skill's `design/visual-design.md` scales for an existing fit. If it exists,
   use it as-is — including for edge cases, even if a tweak feels tempting.
2. **Only build new when the need is real and recurring.** A pattern used in
   one screen is a candidate, not a component; a pattern used or predicted in
   two or more screens is a component.
3. **Add components as tokens + a component, not as isolated markup.** Define
   the design tokens first (color, spacing, type from the scales), then the
   component's API — props for variants, defined states (default/hover/focus/
   disabled/loading/error), and the accessibility behavior (see
   `design/accessibility.md`).
4. **Make the component API the contract.** One way to express a variant; if
   two screens need different markup for the "same" button, that's a signal
   the component's API is incomplete, fix the API.
5. **Consume the system, don't fork it.** Screens import the component; they
   don't restyle it per-screen. A per-screen override for a real reason becomes
   a variant on the component, not a local style.
6. **Land documentation with the component.** Name, props, variants, and an
   example in the place the next agent looks (`references/design/`),
   so the component is discoverable and the default becomes "use it."

```
// tokens (from design/visual-design.md)
color.primary      = accent-600
spacing.control    = 8px
radius.control     = 6px

// component API — one way per variant
<Button variant="primary|secondary|danger" size="md" disabled loading>
  {label}
</Button>

// never — two bespoke flavors of the same thing
<button class="buy-btn">Buy</button>   <button class="checkout-btn">Buy</button>
```

### 5. When the default doesn't apply

- **Explicit demo/throwaway scope** — a pitch mock the user confirmed won't
  ship; inline values are fine, but keep them close to the tokens so the real
  build starts clean.
- **Hard constraint — no system declared** — the project genuinely has no
  component system and the user scoped this screen as standalone; then start
  the token discipline here (extract to the system in `design/visual-design.md`
  style) instead of inventing it silently.
- **Externally imposed system** — the user brings an existing design system
  (brand library, shadcn, MUI); adopt it, and this file's guidance becomes how
  you extend that system, not a replacement.

### 6. Red flags (stopgap smells specific to this file)

- A component duplicated in two files with slightly different classes.
- Literal color/px values inline where a token exists.
- "It's just for this screen" attached to something a future screen obviously
  needs.
- A new component with no props/variant/state API, just markup.
- A screen restyling a shared component locally instead of extending it.
- Copy-paste "extend" that adds a flag with no documentation.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "building this screen's input as inline
   markup instead of adding it to the system."
2. Name the specific cost of not fixing it: e.g. "the next form copies the
   inline version, so the input exists in two places and fixing a focus bug
   means fixing it twice — or missing one."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: TODO
   "extract the input into a system component with API + tokens — owner:
   [name], trigger: a second screen needs the same input or the component is
   reviewed."

### 8. Cross-references

- See also: `design/visual-design.md` — the token scales this file builds on.
- See also: `design/accessibility.md` — components carry the accessible
  behavior so screens inherit it.
- See also: `design/interaction-design.md` — component states must cover the
  UI state machine.
- See also: `design/design-to-code-handoff.md` — component decisions become
  part of the implementable spec.
- Escalates to: `core/architecture-decisions.md` when a component is new and
  architecturally significant (sets precedent across many screens).
