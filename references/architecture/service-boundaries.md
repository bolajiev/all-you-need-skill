## Service Boundaries

**Applies to:** any task where the question arises of where functionality
lives — new service vs. existing service, splitting a module, deciding data
ownership between components, or defining who owns a domain/table/feature.

**Tier:** reference

---

### 1. Rule

Draw boundaries around domains, not tech: one component owns each
domain/entity and is the only one that can change its schema and semantics.
When unsure where a thing belongs, default to the existing component that owns
the domain — adding a new service is a decision to justify, not a reflex.

### 2. Why this matters (long-term cost of getting it wrong)

- Two services owning the same entity produces dual-write drift: each one
  changes "their" copy and they disagree with no single fix.
- A new service created for a feature that fits an existing domain adds
  cross-service calls, auth surface, and deploy coordination for zero benefit.
- One god-service owning everything becomes impossible to reason about, deploy,
  or scale independently — and "split it later" is a multi-month project, not
  a refactor.
- Hidden dependencies (one service quietly reading another's database) couple
  deploy schedules and break the owning team's ability to evolve the schema.

### 3. Decision checklist

- [ ] Which domain does this belong to, and which component is the declared
      owner of that domain?
- [ ] Is this a new domain that genuinely doesn't fit any existing component,
      or is it a new feature on an existing domain?
- [ ] Does any other component need to read/write this data — and is that
      mediated through the owner's API, not its DB?
- [ ] What would break (deploy order, ownership, latency) if this lived in the
      existing component instead?
- [ ] Are the failure and latency characteristics of the new boundary actually
      different enough to matter?

### 4. Default pattern

1. **Find the domain owner first** — grep the schema and code for the entity;
   whatever owns it owns the new change.
2. **Add to the owning component unless there's a concrete reason not to** —
   a new service is only justified by a real isolation requirement (scale,
   security, independent deploy, team ownership), not by tidiness.
3. **Access data through the owner's API, never its database** — cross-service
   DB reads are a boundary violation; they create hidden coupling.
4. **Record the ownership decision** — a one-line entry in
   `core/architecture-decisions.md` naming the domain owner and why.
5. **When splitting, extract a whole domain** — never a "helper module" that
   still reaches back into the old service's data.

```
Before adding a service, ask: "who owns <entity> today?"
  existing owner exists  -> extend the owner
  genuinely new domain   -> new service, documented ownership, API-only access
  crossing an owner      -> that is a NEW boundary decision, raise it, don't
                            route around it silently
```

### 5. When the default doesn't apply

- **Explicit architectural direction** — the user/architecture has already
  decided on a new service or a split; the task is execution, not re-litigating.
- **Proven isolation need** — real scale, security, compliance, or independent
  deploy cadence requirements that the current component cannot meet; these are
  hard constraints, not preferences.
- **Disposable/prototype context** — a spike can live anywhere; just don't
  present it as the final boundary.

### 6. Red flags (stopgap smells specific to this file)

- A new service created "to keep the code clean" with no isolation reason.
- Service A importing/reading Service B's tables directly.
- Two components both writing to the same table with no declared single owner.
- The phrase "we'll just duplicate the model" — drift guaranteed.
- A boundary drawn to match a team's org chart rather than a domain.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "putting order-fulfillment logic in the
   payments service to save standing up a new one."
2. Name the specific cost of not fixing it: e.g. "payments now owns a second
   domain, so its schema changes can break fulfillment, and the split later
   is a big-bang migration."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: ADR
   "fulfillment deferred inside payments; split when scale/team need it —
   owner: [team], trigger: second fulfillment feature or first cross-team
   requirement."

### 8. Cross-references

- See also: `architecture/data-modeling.md` — the owner decides the schema.
- See also: `architecture/api-design.md` — the boundary is expressed as an API.
- See also: `architecture/auth-and-permissions.md` — boundaries define trust
  domains.
- See also: `core/architecture-decisions.md` — every boundary call is
  recorded there.
