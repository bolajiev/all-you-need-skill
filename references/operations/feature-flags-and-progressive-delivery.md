## Feature Flags and Progressive Delivery

**Applies to:** any task that ships behavior behind a switch — kill switches, staged rollouts, canary/percentage rollout, A/B flags — or that touches existing flags.

**Tier:** reference

---

### 1. Rule

Ship code behind a flag by default when behavior can change user-visible outcomes, and treat every flag as temporary: it has a rollout plan, an evaluation point, and a removal date. A flag that is never cleaned up becomes permanent dead weight.

### 2. Why this matters (long-term cost of getting it wrong)

- Permanent flags accumulate into a config surface nobody can reason about, so "is this code live?" becomes unanswerable and dead branches ship to all users.
- Flags without a kill plan turn a bad rollout into a release-sized revert instead of a one-line toggle, which is the entire reason the flag existed.
- Evaluating flags at the wrong layer (in a shared library, inside a hot loop) leaks config everywhere and makes a kill switch impossible to pull.
- Percentage or staged rollouts without metrics give no signal on whether to proceed — the rollout either runs blind or gets stuck half-finished.

### 3. Decision checklist

- [ ] Does this change alter user-visible behavior (vs. internal refactor with no observable change)?
- [ ] Is there a rollout plan — who/what is the flag's owner, and what's the trigger to reach 100% and then remove the flag?
- [ ] Can the kill switch be pulled without a deploy, in seconds, by a single actor?
- [ ] Is the flag evaluated at the right layer — nearest the user boundary, never deep in shared logic?
- [ ] Is the flag's state observable (logging/metrics) so rollout decisions are data-driven?
- [ ] Was the flag's removal written down before it was shipped?

### 4. Default pattern

- **Flag scope:** only gate user-visible behavior. Internal refactors ship without flags and rely on CI and rollback instead.
- **Evaluation point:** evaluate the flag as close to the user-facing boundary as the codebase allows (route, component, handler) — not inside a shared utility, a hot loop, or a data layer, where one flag fans out across the system.
- **Rollout ladder:** start at a controlled audience (internal, then low percentage), observe the signal, then scale — each step is a deliberate act, not an automatic ramp.
- **Kill switch discipline:** the same toggle that ramps up must be able to ram down instantly, by a named operator, with no deploy required.
- **Hygiene (non-negotiable endgame):** a flag is a rollout mechanism, not a feature. From the moment it ships, it has a removal date and an owner. When rollout hits 100% and the code path is stable, the flag and its dead branch are deleted, not left at `true`.

```
# rollout lifecycle
1. Add flag (owner = [person], removal_date = [date], ticket created NOW)
2. Evaluate at the boundary, not in shared logic
3. Roll out: internal → 10% → 50% → 100% (each step gated on metrics)
4. Kill switch verified: one operator, one toggle, no deploy
5. At removal_date: delete the flag and the dead branch, close the ticket

# evaluation (pseudo)
def render(request):
    if feature_flags.enabled("checkout_v2", request.user):
        return new_checkout(request)   # branch is temporary
    return legacy_checkout(request)    # deleted with the flag
```

### 5. When the default doesn't apply

- **Explicit user scope to keep a flag long-term** (a genuinely permanent A/B experiment or license-gated edition) — legitimate only if the flag has a named owner and a standing review cadence; otherwise it's a hygiene failure wearing a costume.
- **Disposable/demo context** where the flag's entire lifetime is the demo session — no removal plan needed because the code never ships.
- **A real hard constraint** (no feature-flag service available and the org forbids a dependency) — then a minimal in-code flag with an explicit owner and removal ticket is the floor, still not a silent permanent `true`.
- **Instant-revert culture** (environments where a deploy is faster than a flag pull) — rollback may genuinely beat flag toggles; keep flags for staged rollout only and remove them on completion.

### 6. Red flags (stopgap smells specific to this file)

- A flag shipped with no owner, no removal date, and no ticket — it will live forever.
- "The flag is done, rollout at 100%" followed by leaving the branch in — that's permanent dead code with extra config.
- Flag evaluation leaking into shared libraries or data-layer code.
- A "kill switch" that requires a deploy or a rebuild to activate.
- Percentage rollout with no metric attached, so nobody can say whether to continue.
- Turning a bug fix into a flag to avoid releasing — flags are for rollout, not for hiding.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:
1. Name what's being deferred — e.g., "removal of the `checkout_v2` flag and its legacy branch."
2. Name the specific cost — e.g., "the dead branch and config persist, so the next change to checkout must reason around two live code paths and the flag surface grows," — state when it bites (the next feature touching that path, or the next flag audit).
3. Write it into an ADR or a tracked TODO with an owner and a trigger for when it must be revisited — e.g., "owner = [x], trigger = checkout_v2 at 100% stable for one release: delete flag and branch." No silent exceptions.

### 8. Cross-references

- See also: `references/build/ci-cd-pipeline.md` for how flags interact with promotion gates (flag-gated code can pass gates while disabled).
- See also: `references/operations/deployment-strategy.md` for when a flag pull is the rollback and when a real rollback is safer.
- See also: `references/operations/monitoring-and-alerting.md` for the metrics that decide each rollout step.
- See also: `references/product/backward-compat-policy.md` for flagging API-visible behavior changes.
- Escalates to: `core/architecture-decisions.md` when adopting or replacing a feature-flag platform.
