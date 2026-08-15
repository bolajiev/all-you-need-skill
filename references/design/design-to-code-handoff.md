## Design-to-Code Handoff

**Applies to:** any task that turns a design decision into implementation —
before the first line of UI code — the moment where intent must become a
specific, verifiable spec the build (and its review) can check against.

**Tier:** reference

---

### 1. Rule

Capture the design as an implementable spec before building: the user and
flow, every state, the tokens and components, and the verification steps. If a
build decision can't be stated in the spec, it's still a guess, not a design.

### 2. Why this matters (long-term cost of getting it wrong)

- Design kept in the head or in a loose sentence produces a build that misses
  the intent; the review cycle of "that's not what I meant" repeats until
  someone rewrites the screen.
- A spec that names screens but not states yields happy-path-only UIs and
  rework for every empty/error path (see `design/interaction-design.md`).
- Ambiguity in the handoff gets resolved by whoever implements, by habit —
  which is exactly the opinion-driven design `design/ux-research.md` forbids.
- A spec with no verification steps can't be checked; "done" becomes
  "the agent says it's done," and the design intent decays on every iteration.

### 3. Decision checklist

- [ ] Does the spec name the user, the job, and the primary flow, or only
      describe a screen?
- [ ] Does it enumerate all states (empty/loading/error/partial) and what each
      renders?
- [ ] Are every component, token, and interaction pattern referenced by name
      (from `design/design-systems.md`), not described anew?
- [ ] Can an implementer copy concrete values — spacing, type, palette — from
      the spec without asking?
- [ ] Does the spec include how to verify the outcome (what "matches the
      design" looks like when rendered)?
- [ ] Have ambiguities been resolved with the user or marked as explicit
      assumptions, per `core/ambiguity-resolution.md`?

### 4. Default pattern

1. **Write the spec from the design files, in one pass.** Assemble the pieces:
   persona + flow from `design/ux-research.md`, states from
   `design/interaction-design.md`, tokens/scales from
   `design/visual-design.md`, components from `design/design-systems.md`,
   accessibility gates from `design/accessibility.md`. The spec is the merged
   output, not a new invention.
2. **Structure it so each build step has a checkable target** (use
   `templates/spec-template.md`):
   - **Intent** — user, job, flow (one paragraph).
   - **States** — the state machine: each state, trigger, and rendered content.
   - **Components** — by name, with the props/variants used, from the system.
   - **Tokens** — concrete spacing/type/color values from the scales.
   - **Accessibility** — the specific gates (contrast pairs, keyboard flow,
     focus, targets).
   - **Verification** — the exact check: render at min width, keyboard walk of
     every flow, contrast audit, states exercised.
3. **Resolve ambiguity before building.** Any step that can't be stated
   concretely goes back to the user or is written as an explicit assumption
   with a revisit trigger — never resolved by the implementer's taste.
4. **Hand the spec to the build as the source of truth.** The implementer
   checks their work against the spec, and the review compares output to the
   spec, not to the original vague request (see `core/definition-of-done.md`).

```
SPEC — Alert triage list
intent      : ops lead classifies alerts real/noise in < 10s
states      : empty ("No alerts" + Refresh) · loading (skeleton rows) ·
              error (reason + Retry, same URL) · content (rows + action)
components  : AlertRow (variant: unread/read), Button (variant: primary/size md)
tokens      : spacing 8/16 · type body 14, title 20 · palette text-900, accent-600
accessibility : body text on surface-200 >= 4.5:1 · keyboard: list then row action
verify      : render at 320px no overflow · keyboard to every row action ·
              trigger error via network block · empty via zero rows
```

### 5. When the default doesn't apply

- **Explicit demo/throwaway scope** — a mock the user confirmed won't ship;
  then a lighter spec (intent + one layout) is fine, still written down so the
  next real build starts from evidence.
- **User provides the spec** — a written design doc or ticket with concrete
  states and values already exists; adopt and verify it rather than rewriting.
- **Hard constraint — timeboxed spike** — an hour to answer "is this feasible";
  then capture intent + verification goal only, and record what wasn't
  specced for the real build.

### 6. Red flags (stopgap smells specific to this file)

- A spec that says "a dashboard with the alerts" and nothing about states.
- "You know what I mean" as the resolution mechanism for ambiguity.
- Components referenced without names, or tokens described as "similar to".
- A spec that can't be verified because it names no checks.
- The implementer inventing a layout or interaction the spec didn't state.
- Skipping the spec entirely and building from a sentence.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "building from a written intent without
   enumerating the empty/error states in the spec."
2. Name the specific cost of not fixing it: e.g. "the states get designed by
   the implementer by habit, so the shipped screen mismatches intent and the
   review cycle burns a full revision."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: TODO
   "complete the state and verification section of the spec — owner: [name],
   trigger: first UI review of the built screen."

### 8. Cross-references

- See also: `design/ux-research.md` — supplies the user, job, and flow.
- See also: `design/interaction-design.md` — supplies the states and transitions.
- See also: `design/visual-design.md` and `design/design-systems.md` — supply
  the tokens, scales, and components.
- See also: `design/accessibility.md` — the verification gates the spec must
  name.
- See also: `templates/spec-template.md` — the structure to fill in.
- Escalates to: `core/ambiguity-resolution.md` when a spec step can't be made
  concrete and getting it wrong is costly.
