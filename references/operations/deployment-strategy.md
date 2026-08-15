## Deployment Strategy

**Applies to:** any task that ships code or configuration to a shared, persistent, or user-visible environment (production, staging, a deployed bot, a live API).

**Tier:** reference

---

### 1. Rule

Deploy small, verifiable increments through the default pipeline using the team's existing release mechanism — never hand-craft a deploy or bypass the pipeline to "save time." Every deploy must be reversible before it is considered done.

### 2. Why this matters (long-term cost of getting it wrong)

- A hand-rolled deploy bypasses the pipeline's guards (CI, migrations, approvals), so a problem that would have failed checks reaches users and can only be fixed by a second risky deploy.
- Irreversible changes (schema drops, destructive data jobs, hard-coded secrets) turn a normal rollback into data loss or a credential rotation.
- Reinventing release tooling in a task produces a parallel, unmaintained release path that the team now has to audit and trust.
- No defined rollback plan turns every incident into a firefight while users are already affected.

### 3. Decision checklist

- [ ] Is this going to a shared or user-visible environment (vs. a disposable local sandbox)?
- [ ] Does the change pass the project's existing build, test, and migration checks in the default pipeline?
- [ ] Is there a known-good previous version I can return to, and is the rollback path documented?
- [ ] Does this deploy need a migration, a feature flag, or a coordinated order of steps (config before code, etc.)?
- [ ] Is anyone else deploying to the same environment right now, and is the pipeline serialized against it?

### 4. Default pattern

Use the environment's existing release mechanism — the CI/CD pipeline, the platform's deploy command, the configured release process — and treat it as the only path.

```
# Typical sequence
1. Merge the smallest releasable unit to the integration branch.
2. Let CI run build + tests + migrations in the pipeline (no skipping).
3. Trigger the platform/team deploy command (e.g. `wrangler deploy`,
   `git push`, the org's release tool) — not a bespoke script.
4. Verify against the environment's own health checks and one
   smoke path a real user would hit.
5. Record what shipped (version/commit, timestamp) in the audit trail.
6. Confirm the rollback target: the previous artifact is tagged and
   restorable in one command.
```

Order-sensitive changes ship in the pipeline's declared order: run reversible migrations first, enable flags before the code that depends on them, and never couple a deploy to a manual one-off step.

### 5. When the default doesn't apply

- **Explicit user instruction to deploy to a specific non-standard target** — the pipeline may not target that environment; user scope overrides the default, and the deviation goes in the audit trail.
- **Disposable/demo context** (throwaway branch, local preview, ephemeral review environment) — a full rollback story is unnecessary because nothing persistent is created.
- **The project has no pipeline at all and the user asked to stand one up as the deliverable** — building the release mechanism is the task, not a bypass.
- **A real hard constraint** (the platform genuinely has no pipeline and no one-off deploy is possible) — then a scripted, repeatable deploy with an explicit rollback step is the minimal correct tool, still not a silent improvisation.

### 6. Red flags (stopgap smells specific to this file)

- Writing a bespoke "deploy" script instead of invoking the existing pipeline.
- Skipping CI/tests/migrations with a reason like "it's a small change."
- Shipping config and code in a way that can't be replayed in the correct order.
- No answer to "what's the one command to undo this?"
- Leaving the deploy unrecorded in the audit trail.
- Committing directly to a shared branch to bypass review.

### 7. If a shortcut is genuinely necessary

1. Name what's being deferred: e.g. "deploying via a one-off command instead of the pipeline."
2. Name the specific cost: checks are skipped, so a regression reaches production and rollback is slower — state when that bites (next user-visible incident).
3. Write it into an ADR or a tracked TODO with an owner and a trigger (e.g. "return to the pipeline at the next deploy; owner = [x], trigger = pipeline restored"). No silent exceptions.

### 8. Cross-references

- See also: `monitoring-and-alerting.md` for verifying a deploy didn't break the environment.
- See also: `incident-response.md` for when the deploy goes wrong.
- Escalates to: `core/architecture-decisions.md` when a permanent change to the release mechanism is needed.
