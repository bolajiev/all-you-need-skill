## Multi-Environment Parity

**Applies to:** any task that touches configuration, deployments, dependencies,
or any code that must behave differently across dev, staging, and production.
Applies when the question is "will this work the same in prod as it does
here?"

**Tier:** reference

---

### 1. Rule

Keep environments as close to identical as possible. The code, config,
dependencies, and data shape that runs in dev and staging must be the same as
what runs in production, with only secrets and capacity differing. An
environment that behaves differently is not a preview — it's a trap.

### 2. Why this matters (long-term cost of getting it wrong)

- Work that passes in a divergent dev/staging environment fails in prod with
  errors that are unreproducible locally — each one costs a full debug cycle
  with no replay.
- "Works on my machine" becomes "works in staging, breaks in prod" with no
  mechanism to tell which difference caused it, since multiple things differ
  at once.
- Environment-specific config drift accumulates silently — flags set in one
  place and forgotten, versions updated in dev but not staging — until prod
  is the only place running the truth.
- A data shape or feature that only exists in staging gets load-bearing in
  prod later, with no parity to test against.

### 3. Decision checklist

- [ ] Does the behavior of this change depend on environment at all, or is it
      environment-agnostic by construction?
- [ ] If it must differ: is the difference limited to secrets and capacity,
      the only allowed axes?
- [ ] Are dependencies and versions pinned the same way across all
      environments?
- [ ] Can a config change be promoted through the same path as a code change,
      or does it bypass review?
- [ ] If prod is behind: is the drift tracked as a debt item, not just known?

### 4. Default pattern

1. **One artifact, many targets.** Build once and promote the same artifact
   through dev → staging → prod. The code that deploys is identical; only the
   runtime config differs.
2. **Keep the differences to two axes: secrets and capacity.** Everything else
   — versions, feature flags, timeouts, feature sets — should be identical.
   Feature flags belong in code/config that is itself promoted, not flipped
   per-environment in an untracked way.
3. **Eliminate "if env == prod" branching** in code. If behavior must differ,
   express it as config that lives in the same promoted artifact, with a
   default that matches production.
4. **Pin dependencies** — lockfiles and pinned container images everywhere.
   An unpinned version in staging means staging tests a version prod won't run.
5. **Make config promotion go through the same review path as code.** A config
   change is a deploy; it should not be a hand-edited change only in prod.
6. **Track drift explicitly.** When prod is necessarily behind (a manual step,
   a delayed rollout), record it as a debt item with an owner and a trigger —
   parity is restored, or the drift is eliminated, on a defined schedule.

```
parity checklist per change:
  [ ] same artifact promoted, not rebuilt per env
  [ ] only secrets + capacity differ
  [ ] deps pinned identically (lockfile / pinned image)
  [ ] no env == prod branching added
  [ ] any forced difference tracked with owner + trigger
```

### 5. When the default doesn't apply

- **Hard constraint** — a platform where environments genuinely can't match
  (proprietary services, capacity limits, licensing); then the difference is
  enumerated and documented, and the risk it creates is tracked.
- **Explicit user scope** — the user runs a deliberately asymmetric setup
  (prod-only experiment, staged rollout) and owns the difference explicitly.
- **Disposable/demo context** — a throwaway staging instance with no production
  counterpart; parity is moot because nothing promotes.

### 6. Red flags (stopgap smells specific to this file)

- `if environment == "prod":` appearing in shared code.
- "It works in my env" used as the only verification.
- A dependency version updated in one environment's lockfile but not another's.
- Prod configuration edited by hand, outside the promoted artifact.
- "It's fine, we'll fix it in prod" — fixing in prod means it was never tested
  in a like environment.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "shipping a change verified only in dev,
   because the staging environment is down."
2. Name the specific cost of not fixing it: e.g. "a config or dependency
   difference will surface in prod as an unreproducible failure, with no
   environment left that matches production to debug it in."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: e.g.
   "TODO: re-verify change in staging once it is restored — owner: [team],
   trigger: staging recovery, before the next prod deploy."

### 8. Cross-references

- See also: `architecture/infra-and-deploy.md` and `operations/deployment-strategy.md`
  — how environments are built and promoted.
- See also: `build/environment-setup.md` — local setup must match the promoted
  artifact.
- See also: `operations/monitoring-and-alerting.md` — parity is how
  environment-specific anomalies are detected.
- See also: `references/anti-patterns.md` — "verify in one env, assume the
  rest" is the file-level smell this file guards.
