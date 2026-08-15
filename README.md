# all-you-need-skill

An operating doctrine that turns an AI coding agent into a rigorous designer and
engineer. Not a checklist of tools — a set of rules for *how* to think, decide,
and verify, organized so the right guidance loads at the right moment.

## What it does

The skill is a two-tier reference library:

- **Tier 1 — `core/`** — the non-negotiables, loaded on every task: plan before
  acting, no stopgaps, verify instead of assume, know when to stop and ask.
- **Tier 2 — `references/`** — per-concern guidance, pulled in when a concern is
  in play: planning, architecture, design, build, quality, operations,
  agent-state, and product thinking.

Each guidance file follows one consistent 8-section shape
(`templates/skill-file-template.md`): a Rule, the long-term cost of getting it
wrong, a decision checklist, a concrete default pattern, legitimate exceptions,
red flags, a disciplined shortcut path, and cross-references.

## Layout

```
SKILL.md                 entry point + tier routing
core/                    TIER 1 — always loaded
references/
  planning/              spec, research, decomposition, handoff
  architecture/          data, APIs, auth, boundaries, infra, migrations, …
  design/                UX research, interaction, visual, accessibility, …
  build/                 workflow, tool allowlist, git, parallelism
  quality/               testing, review, self-critique, observability, …
  operations/            deploy, monitoring, incidents, sandboxing, secrets, …
  agent-state/           context, checkpoints, escalation, audit trail, …
  product/               tradeoffs, cost, backward compat, ownership, …
  anti-patterns.md       cross-cutting stopgap smell index
templates/               spec, implementation plan, ADR, PR checklist
scripts/                 mechanical enforcement (lint, TODO checking)
```

## The four non-negotiables

1. **Plan before you act.** Structured plan before any file-modifying or
   network command; plan → act → observe → repeat.
2. **No stopgaps.** A shortcut that is never revisited is debt with a time
   bomb. Named, costed, tracked — in an ADR or a TODO with owner + trigger.
3. **Verify, don't assume.** Treat your own output with the same scrutiny as a
   new hire's PR. If you didn't run it, you didn't prove it.
4. **Say when to stop.** Expensive-to-reverse or protected ambiguity (prod,
   credentials, irreversible actions) gets a question, not a guess.

## Usage

Point the agent at `SKILL.md`. For any task it:

1. Loads `core/` (the rules).
2. Routes to the relevant `references/<concern>/` files (the patterns).
3. Produces artifacts from `templates/` (spec → implementation plan → ADR /
   PR checklist).
4. Runs `scripts/lint-architecture.sh` and `scripts/check-todos.sh` before
   calling work done.

## Enforcement

- `scripts/lint-architecture.sh` — validates the tree itself: every file has
  the 8-section structure, Tier/Applies-to headers, no dangling cross-references,
  line budget, ADR fields.
- `scripts/check-todos.sh` — every actionable `TODO:`/`FIXME:`/`XXX:` marker
  must carry an owner and a trigger for revisiting. Bare markers are stopgap
  smells.

## License

MIT
