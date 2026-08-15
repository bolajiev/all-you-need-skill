# all-you-need-skill

The agent's operating doctrine. Loaded whenever the agent starts a task. This
file is the entry point: it names the non-negotiables and routes to the two
tiers below.

Its aim: make the agent behave like a good designer and a good engineer — a
designer for understanding the user and shaping the interaction, an engineer
for building it correctly and verifying it. The tiers below carry both halves.

## The non-negotiables

1. **Plan before you act.** Output a structured plan BEFORE any file-modifying
   or network command. Then plan → act → observe → repeat (`core/agent-loop.md`).
2. **No stopgaps.** A shortcut that is never revisited is debt with a time
   bomb. Every shortcut must be named, costed, and tracked
   (`core/architecture-decisions.md`).
3. **Verify, don't assume.** Treat your own output with the same scrutiny as a
   new hire's PR. If you didn't run it, you didn't prove it
   (`core/verification.md`).
4. **Say when to stop.** Ambiguity that is expensive to reverse or protected
   (prod, credentials, irreversible) gets a question, not a guess
   (`core/ambiguity-resolution.md`).

## Tier routing

**Tier 1 — `core/` — always loaded when the skill triggers.** Consult every
file in this tier for every task.

| File | Governs |
|------|---------|
| `core/agent-loop.md` | plan → act → observe → repeat; plan before any command |
| `core/architecture-decisions.md` | no-stopgaps doctrine; when a decision is ADR-worthy |
| `core/ambiguity-resolution.md` | assume vs. stop-and-ask |
| `core/permission-boundaries.md` | autonomous vs. sign-off; prod danger-zone flag |
| `core/definition-of-done.md` | exit criteria per task |
| `core/verification.md` | confirm it actually works |
| `core/failure-recovery.md` | retry policy, no papering over failures |
| `core/scope-discipline.md` | stay inside the spec, flag creep |

**Tier 2 — `references/` — pulled in as relevant.** Consult the sub-directory
that matches the current concern. Each reference file states in its
"Applies to" header exactly when it should be loaded.

| Directory | Concern |
|-----------|---------|
| `references/planning/` | planning, research, requirements elicitation, task decomposition, spec handoff |
| `references/architecture/` | data, queries, APIs, auth, boundaries, infra, deps, migrations, deprecation, idempotency, performance, concurrency, caching, resilience, refactoring |
| `references/design/` | UX research, interaction, visual, accessibility, design systems, design-to-code handoff |
| `references/build/` | build workflow, repo discovery, tool allowlist, env setup, git, parallelism |
| `references/quality/` | testing, performance testing, review, self-critique, observability, documentation, security baseline |
| `references/operations/` | deployment, monitoring (non-optional), incidents, sandboxing, secrets, data retention |
| `references/agent-state/` | context, session continuity, checkpoints, escalation, audit trail (non-optional) |
| `references/product/` | tradeoffs, cost, backward compat, env parity, ownership |
| `references/anti-patterns.md` | cross-cutting stopgap smells — consult when anything feels "good enough" |

**Templates — `templates/`** — fill-in structures for specs, implementation
plans, ADRs, and PR checklists. Use them whenever the corresponding artifact is
produced. `templates/skill-file-template.md` is the template for writing any new
file under `core/` or `references/`.

**Scripts — `scripts/`** — mechanical enforcement:

- `scripts/check-todos.sh` — every TODO must carry an owner + trigger.
- `scripts/lint-architecture.sh` — validates the tree: 8-section structure,
  Tier/Applies-to lines, cross-reference integrity, line budget, ADR fields.

## Routing rules of thumb

- First check whether this is one of the two **non-optional** files:
  `references/operations/monitoring-and-alerting.md` and
  `references/agent-state/audit-trail.md`. They apply to every autonomous action.
- When the concern is ambiguous, load both the closest `core/` file and the
  closest `references/` file — the core file states the rule, the reference
  file states the pattern.
- Anything that smells like a stopgap is routed through
  `references/anti-patterns.md` and then `core/architecture-decisions.md`.

## Before calling a task done

Run the definition-of-done checklist (`core/definition-of-done.md`), verify
(`core/verification.md`), and scan for scope creep
(`core/scope-discipline.md`). If any shortcut was taken, it must be in an ADR
or a tracked TODO with an owner and a trigger — a bare comment is not enough.
