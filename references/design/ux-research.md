## UX Research

**Applies to:** any task that builds or changes UI that a real person will
use — a screen, a flow, a form, a report, a notification — before the first
layout is drawn.

**Tier:** reference

---

### 1. Rule

Design from evidence about the actual user and their task, not from opinion
about what a screen should look like. Name the user, the job they're trying to
do, and the flow they'll walk before writing a single component.

### 2. Why this matters (long-term cost of getting it wrong)

- Building on an assumed user means the wrong problem gets solved well; the UI
  ships, nobody uses it, and the rework is a redesign of the whole flow, not a
  patch.
- Guessing the task ("they probably want a dashboard") produces surface
  features that miss the real job, so the screen is visited once and abandoned.
- Every screen built without a named user becomes a target for the next agent
  to "improve" with their own guesses — the design churns with each author.
- Evidence gathered late (post-launch analytics, angry support tickets) is
  dramatically more expensive than the ten minutes it takes to state the user
  and task up front.

### 3. Decision checklist

- [ ] Can I name the primary user in one sentence — role, context, goal?
- [ ] What is the one job-to-be-done this screen exists to complete, and how do
      I know that's true (observed, asked, or assumed)?
- [ ] What does the user's flow look like before and after this screen — where
      do they enter from, what do they do next?
- [ ] What would this look like if the user already knows the answer, and if
      they don't?
- [ ] Have I written the persona and task down where the build will see them,
      rather than keeping them in my head?

### 4. Default pattern

1. **Name the user and the job** before opening a code editor. One sentence
   each: "primary user = ops lead triaging nightly alerts; job = classify each
   alert as real or noise in under 10 seconds."
2. **Write the primary flow as a numbered sequence** of user steps, from the
   trigger to the outcome — no UI artifacts yet, just actions:
   `opens alert list → scans titles → opens one → reads context → marks
   real/noise → returns to list at same scroll position`.
3. **Do a two-minute reality check** — ask the user (or, if impossible, write
   the assumption and mark it as unverified) one targeted question about the
   core step, e.g. "do you triage by list or get pushed alerts?"
4. **Record the output** as a short note — persona, job, flow — in the spec or
   ADR so the build references it (see `core/scope-discipline.md` for where
   the scope boundary sits).
5. **Design the UI to match the flow** — order controls by the task steps, not
   by what's easy to render (hand off to `design/interaction-design.md`).
6. **Collect evidence on what ships** — a basic usage event for the primary
   action lets the next iteration correct the assumption (see
   `quality/observability.md`).

```
persona  : ops lead, 15 alerts/hour, hostile to clicks
job      : classify alert as real/noise in < 10s
flow     : open list -> scan -> open -> read context -> mark -> back
assumption (UNVERIFIED): users open items, they don't triage inline
```

### 5. When the default doesn't apply

- **Explicit demo or throwaway scope** — the user says "mock something
  presentable for the pitch; the real UX comes later"; then a plausible
  persona sketch is enough, marked as such.
- **Hard constraint — no user access** — building against an internal API with
  no real end user reachable; then the user and job are stated as explicit
  assumptions with a revisit trigger, not silently skipped.
- **Pure infrastructure UI** — a settings screen whose only user is the agent
  itself; the "user" is the operator, name them, and move on.

### 6. Red flags (stopgap smells specific to this file)

- UI work starting with "I'll just put X on the screen" with no stated user or
  job.
- A persona that is a demographic (age, job title) with no task attached.
- A flow described as screens ("homepage → dashboard → settings") instead of
  user actions.
- "We know what the user wants" with no source for that knowledge.
- Feature lists written before the primary job-to-be-done is named.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "skipping the user interview and building
   from the persona's assumed workflow."
2. Name the specific cost of not fixing it: e.g. "if the triage flow is wrong,
   the screen gets one revision cycle after launch before the flow is rebuilt,
   a full redesign of the interaction layer."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: TODO
   "validate the assumed triage flow against a real ops lead — owner: [name],
   trigger: first usage event showing < 30% of alerts get a classification."

### 8. Cross-references

- See also: `design/interaction-design.md` — turns the user flow into concrete
  UI states and transitions.
- See also: `planning/spec-to-agent-handoff.md` — where the persona and flow
  notes land.
- See also: `quality/observability.md` — the events that validate the
  assumptions after launch.
- Escalates to: `core/ambiguity-resolution.md` when the user is reachable but
  the core task assumption is unverifiable and expensive to get wrong.
