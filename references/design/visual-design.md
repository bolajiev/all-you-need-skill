## Visual Design

**Applies to:** any task that renders UI — layout, spacing, typography, color,
alignment — the visual decisions that make a screen readable, scannable, and
trustworthy before a single style choice is made.

**Tier:** reference

---

### 1. Rule

Build visual hierarchy first, decoration last: use spacing, type, and contrast
to make the most important content the most visually prominent, and never
ship a screen whose layout or colors read as broken or careless.

### 2. Why this matters (long-term cost of getting it wrong)

- Without an intentional hierarchy, every element competes equally and the
  user cannot find the primary action; adoption and task completion drop and
  the fix is a full layout rework.
- Inconsistent spacing and alignment make a working app look unfinished; users
  transfer "this looks amateur" to "this can't be trusted with my data."
- Random colors and type sizes per screen become the de-facto system; the next
  agent matches the mess, and unifying it later is a cross-screen rewrite (see
  `design/design-systems.md`).
- Low-contrast or misaligned text fails accessibility checks, which the build
  then has to retrofit at higher cost than building correctly.

### 3. Decision checklist

- [ ] Is there a clear visual hierarchy — can I tell in two seconds what the
      primary content and primary action are?
- [ ] Are spacing and alignment consistent (one scale, one grid), not ad hoc
      pixel values?
- [ ] Is the type hierarchy defined (sizes/weights for title, body, caption)
      and used consistently?
- [ ] Do all colors come from a defined palette, with contrast verified for
      text on every background?
- [ ] Have I used spacing/typography to convey importance instead of relying
      only on color, bold, or animation?

### 4. Default pattern

1. **Establish the scale before building anything.** One spacing unit (e.g. 4px)
   and only multiples of it; one type scale (e.g. 12/14/16/20/28); one grid
   (e.g. 8-column at mobile, 12-column at desktop). Every value on screen
   comes from these (see `design/design-systems.md`).
2. **Define hierarchy as "size + weight + spacing", then color.** Headline
   bigger than body; more whitespace above a section than between items in it;
   primary action stronger than secondary. Apply color last to reinforce, not
   to carry, the distinction.
3. **Design the empty/loading/error/content states to the same visual
   standard**, so the app looks finished in every state (see
   `design/interaction-design.md`).
4. **Compose with alignment and rhythm, not decoration.** Everything aligns to
   the grid; repeated elements share consistent margins; one accent color used
   sparingly rather than many colors competing.
5. **Verify with the browser, not the code.** Render the screen and check: text
   contrast on all backgrounds (see `design/accessibility.md`), no overflow or
   truncation at the minimum supported width, and spacing that reads clean at
   both desktop and mobile before calling the visual done.
6. **Reuse before restyle.** If a visual exists, extend it; if one doesn't,
   design the reusable token, not a one-off value (see
   `design/design-systems.md`).

```
spacing : 4 / 8 / 12 / 16 / 24 / 32 / 48
type    : caption 12 · body 14 · subhead 16 · title 20 · display 28
grid    : 12-col desktop, 8-col mobile, 16px gutters
palette : bg-100, surface-200, border-300, text-700, text-900, accent-600
check   : contrast >= 4.5:1 body text, no text below 12px, no color-only emphasis
```

### 5. When the default doesn't apply

- **Explicit demo/throwaway scope** — a mock the user said won't ship; then a
  single coherent style pass is enough, but consistency still applies so it
  reads as intentional.
- **Hard constraint — locked design language** — the user provides an existing
  brand spec or design system; adopt it wholesale instead of inventing a new
  one.
- **Severe asset limitation** — no font or icon assets available offline; then
  use system fonts and the sharpest geometric spacing available, and record
  the constraint.

### 6. Red flags (stopgap smells specific to this file)

- Pixel values pulled from nowhere (17px margin, 23px gap) instead of the scale.
- Importance conveyed only by color, or by making everything bold.
- Title and body text that are the same size and weight.
- A screen that looks different in every state (content polished, error state
  obviously raw).
- Text that fails contrast or overlaps at the minimum supported width.
- Decorative flourishes (shadows, gradients) added before hierarchy is solid.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "using inline one-off colors and sizes for
   this screen instead of extracting the palette into tokens."
2. Name the specific cost of not fixing it: e.g. "the next screen copies these
   values, so unifying into a token system becomes a cross-screen retrofit
   that touches every file."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: TODO
   "extract this screen's values into `design/design-systems.md` tokens —
   owner: [name], trigger: a second screen needs the same value or the design
   is reviewed."

### 8. Cross-references

- See also: `design/design-systems.md` — where the scales and tokens live.
- See also: `design/accessibility.md` — contrast and readability are a
  checklist, not a nice-to-have.
- See also: `design/interaction-design.md` — hierarchy must survive every UI
  state.
- See also: `design/design-to-code-handoff.md` — visual decisions become
  values an implementer can copy.
- See also: `core/verification.md` — render and check the visual, don't assume
  it from the code.
