## CI/CD Pipeline

**Applies to:** any task that touches the automated pipeline running between a merge and a release — CI stages, build/test/lint gates, artifact promotion, environment progression, and who/what is allowed to pass each gate.

**Tier:** reference

---

### 1. Rule

The pipeline is the only path from merge to release: every stage is defined in code, every gate blocks promotion until its checks pass, and no human or agent bypasses a gate. Artifacts are built once and promoted immutably — never rebuilt per environment.

### 2. Why this matters (long-term cost of getting it wrong)

- A gate that can be waved through silently becomes a gate that always is, so the regression it existed to catch ships and needs a hotfix cycle.
- Rebuilding the artifact per environment produces "works in staging, broken in prod" because each build is a different binary that was never tested.
- Hand-run deploy steps outside the pipeline create a parallel, undocumented release path that skips migration and approval checks and can't be replayed in an incident.
- Missing serialization (two promotions at once, or a deploy racing a migration) produces an environment state nobody can reconstruct later.

### 3. Decision checklist

- [ ] Is every stage of the pipeline defined as code (CI config, not a wiki page or a human's memory)?
- [ ] Does every gate block promotion until its checks pass — and is "passing" enforced by the pipeline, not by assertion?
- [ ] Is the artifact built once and promoted unchanged through every environment?
- [ ] Does each environment's promotion have an explicit, documented gate (who or what triggers it)?
- [ ] Are environment progressions serialized so two changes can't collide mid-deploy?
- [ ] Can the whole pipeline be replayed from a single commit?

### 4. Default pattern

Keep the pipeline as one linear, declarative definition. Promote a single immutable artifact; environments are checkpoints, not rebuild points.

```
# One artifact, N environments — promote, never rebuild
build → [lint] → [unit test] → package+tag(commit) ─┐
                                                    │ promote
review/staging gate (approval or automated)  ←──────┤
                                                    │ promote
staging → smoke tests (integration + a real user path)
                                                    │ promote (gated: approval + health check)
production → deploy → verify (health + rollback ready)
```

- **Stages:** lint → test → build → package → promote. Run fast feedback first (lint, unit) so failures cost seconds, not minutes.
- **Gates:** each promotion requires a distinct gate. Automation gates (tests green, security scan clean) are the default; a human approval gate is the norm for production promotion.
- **Artifact promotion:** build once, record the commit hash and checksum, tag it, and promote that exact artifact. Versioning comes from the tag/commit, never from a timestamp or "latest."
- **Environment progression:** keep a fixed order (review → staging → production). Never skip an environment to save time; never promote straight to production from a pull-request build.
- **Serialization:** one pipeline run per target environment at a time; fail loudly if a second promotion starts while one is in flight.
- **Failure:** a failed stage stops the run — no auto-continue, no retry that silently skips the failed step.

```
# minimal GitHub Actions shape for the pattern
jobs:
  lint: ...
  test: ...
  build: { needs: [lint, test], upload-artifact: app }
  promote-staging:
    needs: [build]
    environment: staging
    deploy: { artifact: app }
  promote-prod:
    needs: [promote-staging]
    environment: production
    environment-url: ...   # health check is part of the job
```

### 5. When the default doesn't apply

- **Disposable/demo or review environments** (throwaway preview deploys of a PR) — they are not checkpoints on the release path and don't need the full gate ladder.
- **The task's deliverable is the pipeline itself** (building or fixing CI is the work) — the file being written is the default, so its own rules bind the code, not a non-existent prior pipeline.
- **A real hard constraint** (the platform has no promotion concept, no artifact registry) — then the minimal correct substitute is a scripted promote-and-tag step in the same config, still defined in code and still gated.
- **Explicit user scope** to change the gate ladder (e.g. "make production promote on green only, no approval") — a deliberate policy change, recorded in the ADR.

### 6. Red flags (stopgap smells specific to this file)

- A "deploy to production" job with no environment gate or approval requirement.
- Skipping a stage "just for this run" — that is a hand-crafted promotion.
- `docker build` / `npm run build` re-run inside a deployment step instead of reusing the packaged artifact.
- Pipeline behavior that only exists in a chat message or README, not in CI config.
- "It passed locally" used as a reason to skip the pipeline — the pipeline is the authority.
- Two environments deploying in parallel with no serialization.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:
1. Name what's being deferred — e.g., "the production approval gate for this promotion, or the staging checkpoint."
2. Name the specific cost — e.g., "a regression that staging would have caught reaches production, and the next user-visible incident starts with an un-reviewed promote."
3. Write it into an ADR or a tracked TODO with an owner and a trigger for when it must be revisited — e.g., "owner = [x], trigger = next release cut: restore the gate and replay the skipped environment." No silent exceptions.

### 8. Cross-references

- See also: `references/build/build-workflow.md` for the local build/lint/test sequence the pipeline stages mirror.
- See also: `references/build/git-workflow.md` for what triggers a pipeline run (merge, tag, PR).
- See also: `references/operations/deployment-strategy.md` for the deploy-side of promotion and rollback.
- See also: `references/operations/monitoring-and-alerting.md` for the health checks that gate the final promote.
- Escalates to: `core/architecture-decisions.md` when the gate ladder or promotion model itself changes.
