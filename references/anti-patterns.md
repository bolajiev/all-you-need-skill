## Anti-Patterns

**Applies to:** cross-cutting — every file in this skill, at every step of a
task. This catalog is consulted to name a smell when one appears in the
agent's own output or someone else's, and to route each smell to the file
that fully covers it.

**Tier:** reference

---

### 1. Rule

Stop and name any pattern that looks like progress but is actually a shortcut.
The recurring stopgap smells are: hardcoded values instead of config,
silent catch-and-continue, TODO-without-owner, blocking "just this once"
calls, mock-only "verification", plus the family of "I'll just…" workarounds.
When one appears, call it by name and route it to the file that owns it —
never proceed past it silently.

### 2. Why this matters (long-term cost of getting it wrong)

- Each smell is a silent stopgap: it looks done, so nothing tracks it, and
  its cost lands later as a migration, an outage, or a rewrite — attributed
  to nobody.
- An unnamed smell can't be routed: the fix for "hardcoded value" is in a
  different file than "mock-only verification", so the agent must know which
  is which.
- Smells that go unnamed get normalized; once "catch-and-continue" is
  ordinary, the codebase's error handling quietly stops working.
- A TODO with no owner reads as completion — it's the most common way a
  shortcut escapes detection.

### 3. Decision checklist

- [ ] Does this pattern make something *look* done that isn't?
- [ ] Which catalog smell does it match, if any?
- [ ] Does the owning file's Section 7 rule it acceptable or require a
      tracked entry?
- [ ] If a tracked entry is required: does it have an owner and a trigger?
- [ ] Has the smell been named out loud to the user, or did it pass silently?

### 4. Default pattern

Name the smell, cite its owner file, and apply that file's default. The
catalog:

| Smell | Looks like progress because… | Owner file |
|---|---|---|
| Hardcoded values instead of config | value is pinned and works, here | `architecture/data-modeling.md`, `build/environment-setup.md` |
| Silent catch-and-continue | errors don't surface, flow keeps running | `quality/observability.md`, `operations/incident-response.md`, `operations/monitoring-and-alerting.md` |
| TODO-without-owner | debt is "documented" | every file's Section 7; `core/architecture-decisions.md` |
| Blocking "just this once" calls | the task finishes on schedule | `agent-state/escalation-triggers.md`, `core/permission-boundaries.md`, `core/ambiguity-resolution.md` |
| Mock-only "verification" | the test suite is green | `quality/testing-strategy.md`, `core/verification.md`, `quality/self-critique-loop.md` |
| Silently picking the convenient option | no decision friction | `product/tradeoff-communication.md` |
| Silently altering a live contract | no migration overhead | `product/backward-compat-policy.md` |
| Verify in one env, assume the rest | local/staging is green | `product/multi-environment-parity.md` |
| Knowledge lives in the author, not the repo | it works while the author is present | `product/ownership-and-bus-factor.md` |
| Estimate never stated, reported too late | work "just happens" | `product/cost-modeling.md`, `planning/task-decomposition.md` |
| "Just delete it" for a shared thing | cleanup feels productive | `architecture/deprecation.md` |
| Unpinned dependency "because it worked" | builds pass today | `architecture/dependency-selection.md`, `product/multi-environment-parity.md` |
| Approval bypassed "this once" | faster iteration | `core/permission-boundaries.md` |
| Scope added without the user asking | more features, feels generous | `core/scope-discipline.md` |
| Ambiguity guessed instead of asked | no interruption | `core/ambiguity-resolution.md` |
| Screenshot-green but the flow was never walked | UI "verification" passes | `design/usability-testing.md`, `core/verification.md` |
| Design shipped without being critiqued | looks fine at a glance | `design/design-critique.md`, `quality/self-critique-loop.md` |
| Ship it, flag it later (no progressive rollout) | one big release feels decisive | `operations/feature-flags-and-progressive-delivery.md`, `operations/deployment-strategy.md` |
| Strings hardcoded in English | it works for the author's locale | `architecture/internationalization-and-localization.md` |
| Files thrown into a flat folder "for now" | everything is in the repo | `architecture/code-organization-and-naming.md` |
| "Merge and pray" — no CI gate | the merge looks successful | `build/ci-cd-pipeline.md`, `core/definition-of-done.md` |
| Long silent task, status never reported | no interruptions, feels efficient | `agent-state/progress-and-status-communication.md` |

The first five rows are the canonical recurring smells; the rest are their
file-level instances. On matching a smell: name it, apply the owner file's
default, and if the default allows a tracked stopgap, write it with an owner
and a trigger — see the owner file's Section 7.

### 5. When the default doesn't apply

- **Explicit user scope** — the user authorizes the shortcut and its cost in
  advance; it stops being a silent stopgap, but it is still named out loud.
- **Disposable/demo context** — a confirmed short-lifetime artifact where the
  smell's cost cannot outlive the context.
- **Hard constraint** — a genuine platform, budget, or schedule limit; the
  constraint is documented, not just cited.

### 6. Red flags (stopgap smells specific to this file)

- Hardcoded values / inline config instead of a config source.
- A catch block that swallows the error and keeps going, with no log.
- A TODO with no owner and no trigger.
- "Just this once" used to justify a blocking call or an approval bypass.
- A test that only mocks the thing it claims to verify, with no real path
  exercised.
- "I'll just…" anywhere in the plan, followed by no ADR or TODO.
- A smell named and then proceeded past anyway, still untracked.

### 7. If a shortcut is genuinely necessary

Never silent. Required output — identical discipline for every smell in this
catalog:

1. Name what's being deferred: e.g. "hardcoding the API key for this run to
   unblock the demo."
2. Name the specific cost of not fixing it: e.g. "the key is checked into the
   repo and rotated never; when it leaks or expires, the demo and everything
   sharing the key breaks with no rollout path."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: e.g.
   "TODO: move key to secrets manager — owner: [person/team], trigger: before
   this moves to production, or key rotation."

The stopgap may proceed only when the entry exists and the user has seen it.

### 8. Cross-references

- See also: `core/architecture-decisions.md` — the doctrine that makes every
  Section 7 a requirement, and the place to log significant deviations.
- See also: `templates/adr-template.md` — the format for recorded decisions.
- Every file in `core/` and `references/` is the full treatment for its own
  smell; this file is only the index that names and routes them.
- See also: `quality/self-critique-loop.md` — the mechanism that catches these
  smells in the agent's own output before "done" is claimed.
