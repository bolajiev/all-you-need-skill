## Infra and Deploy

**Applies to:** any task that provisions infrastructure, configures
environments, defines deploy targets, adds build/release steps, or changes how
the artifact gets to production.

**Tier:** reference

---

### 1. Rule

Treat infrastructure and deployment as code: declarative, versioned,
environment-differentiated only where truly needed, and reproducible from a
clean checkout. The path to prod must be known, repeatable, and owned — never
"works on my machine" by accident.

### 2. Why this matters (long-term cost of getting it wrong)

- Hand-provisioned infra drifts until nobody can rebuild it; a failed instance
  then requires archaeology instead of redeploy.
- Environment differences that aren't explicit (staging acts differently than
  prod) produce bugs that pass CI and explode in production.
- A deploy that relies on manual steps is skipped or half-run under pressure,
  shipping the wrong thing at the worst moment.
- Secrets wired by hand into instances leak into logs, configs, and repos, and
  can't be rotated uniformly.

### 3. Decision checklist

- [ ] Is everything declarative and versioned, or is any part hand-provisioned
      in the console?
- [ ] Are environments defined as explicit configuration over one codebase,
      not divergent copies?
- [ ] Can the deploy be run reproducibly from a clean checkout, by anyone
      (or any agent), with no undocumented manual step?
- [ ] Are secrets injected via the secret manager / environment, never baked
      into images or source?
- [ ] Is there a rollback path for this change (previous artifact, previous
      state)?

### 4. Default pattern

1. **Declare infra as code** — Terraform/CloudFormation/Pulumi, whatever the
   repo already uses; new resources go in the same IaC, not the console.
2. **One pipeline per environment target** — build once, promote the artifact
   through dev → staging → prod, with the config differing only via declared
   variables.
3. **Secrets via the secret manager** — referenced by name in config; never
   literal values in the repo, image, or env file.
4. **Make the deploy a single repeatable command** — CI does it; local/manual
   deploys are only for disposable contexts.
5. **Ship the rollback before the rollout** — know the previous good artifact
   and how to restore it before pressing go.

```
deploy flow (single artifact, promoted):
  build -> push artifact (immutable tag) -> dev -> staging -> prod
  config per env: only via declared variables, not code forks
  secrets: {secret-manager:ENV/KEY} resolved at deploy, never committed
```

### 5. When the default doesn't apply

- **Explicitly disposable context** — a local dev sandbox or throwaway demo
  that will be torn down can be provisioned by hand; it's explicitly
  temporary, and said so.
- **Hosted platform that owns deployment** — serverless/managed platforms where
  the deploy is defined in platform config already (wrangler, etc.); that
  config is the IaC.
- **Hard constraint on shared provisioner** — if the org uses a specific tool
  the repo doesn't yet, follow it, but still keep it declarative and versioned.

### 6. Red flags (stopgap smells specific to this file)

- "I created the resource in the console" with no IaC.
- A deploy checklist with manual steps only a human remembers.
- Secret values visible in config files, commands, or logs.
- Two environments running different code because "staging was updated by
  hand".
- No answer to "how do we roll this back?"

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "provisioning the queue by hand because
   the IaC module doesn't exist yet."
2. Name the specific cost of not fixing it: e.g. "the queue can't be rebuilt
   if the region fails, and a second environment will silently differ."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: TODO
   "port the queue into Terraform — owner: [team], trigger: before any second
   environment is created or before the next region/config change."

### 8. Cross-references

- See also: `architecture/dependency-selection.md` — the deploy tooling is
  itself a dependency decision.
- See also: `architecture/service-boundaries.md` — each service owns its own
  deploy path.
- See also: `core/definition-of-done.md` — "deploys cleanly" is part of done.
- See also: `core/architecture-decisions.md` — record the chosen deploy
  pipeline there.
