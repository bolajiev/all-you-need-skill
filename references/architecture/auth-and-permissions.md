## Auth and Permissions

**Applies to:** any task that introduces an endpoint, action, data access path,
or credential handling that should be restricted to specific users, roles,
services, or scopes. Default applies whenever the resource is not explicitly
public.

**Tier:** reference

---

### 1. Rule

Apply least privilege by default: every access path is authenticated and
authorized, with the narrowest scope that works, using existing auth
infrastructure. If you are adding a route, handler, or data read that isn't
public, it must carry explicit auth — never assume "it's internal".

### 2. Why this matters (long-term cost of getting it wrong)

- An unauthenticated path to internal data is a vulnerability, not a code
  smell; it gets found by scanners or attackers, and retrofitting auth after
  the fact is an incident with a deadline.
- Over-broad permissions (any-authenticated-user where ownership is required)
  enable horizontal privilege escalation and are quietly inherited by every
  future caller.
- Rolled-your-own crypto, password storage, or token logic invites subtle
  flaws that are far more expensive to fix than using the vetted stack.
- Hardcoded secrets or over-long-lived tokens widen the blast radius of any
  single leak and are nearly impossible to rotate safely once shipped.

### 3. Decision checklist

- [ ] Is this access path explicitly public, or does it need authentication?
- [ ] Who is allowed — and does the check compare the actor to the resource's
      owner/scope, not just "is logged in"?
- [ ] Am I using the existing auth/z stack (framework middleware, IDP,
      established permission model) rather than inventing one?
- [ ] Are credentials/secrets managed, never committed, and scoped to the
      least privilege?
- [ ] Does the token/session lifetime match the sensitivity, with rotation
      available?

### 4. Default pattern

1. **Authenticate at the boundary** — use the platform/IDP middleware; don't
   hand-parse tokens in handlers.
2. **Authorize per resource** — after authentication, check the actor against
   the specific resource (ownership, role, tenant, scope). The default is an
   explicit allow, not an implicit "authenticated means allowed".
3. **Reuse existing roles/permission primitives** — add a role/scope to the
   established model before creating an ad-hoc flag.
4. **Treat everything as denied by default** — public endpoints are the
   exception and are listed explicitly.
5. **Handle secrets through the secret manager / env-injection**, never in
   source; keep them out of logs, errors, and client payloads.

```
# boundary middleware pattern
POST /v1/orders/{id}/refund
  requires: authenticate()            # from the IDP/stack
            authorize(order.owner == actor.id or actor.role in {admin})
  # explicit allow; everything else 403
```

### 5. When the default doesn't apply

- **Explicitly public resources** — a deliberately open endpoint (docs,
  health, public read) is fine, but it's an explicit decision, named in code.
- **Disposable/demo context** — a local throwaway prototype may skip the full
  IDP integration; note it so it can't be mistaken for prod behavior.
- **Hard platform constraint** — no auth infrastructure exists yet in a
  greenfield and wiring it is a separate task; the interim must still never be
  exposed as if it were protected.

### 6. Red flags (stopgap smells specific to this file)

- A new handler with no auth middleware and no explicit "public" comment.
- Checking `actor.is_authenticated` where the operation needs
  `actor == resource.owner`.
- Credentials or API keys written into code, configs, or READMEs.
- "It's only accessible internally / behind the network" used as the security
  argument.
- Adding a permission check as a comment ("TODO: add auth") rather than code.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "shipping the internal admin endpoint
   without authorization while the role model is being built."
2. Name the specific cost of not fixing it: e.g. "any internal caller can act
   as admin until the role check lands — a live privilege escalation window."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: ADR
   entry + TODO "wire role check for admin endpoints — owner: [team], trigger:
   before the endpoint is reachable outside the dev environment."

### 8. Cross-references

- See also: `architecture/api-design.md` — auth is defined per endpoint.
- See also: `architecture/service-boundaries.md` — trust boundaries decide who
  may call whom.
- See also: `architecture/dependency-selection.md` — the vetted auth stack is
  chosen there.
- See also: `core/architecture-decisions.md` — record security-relevant
  deviations there, never in a comment.
