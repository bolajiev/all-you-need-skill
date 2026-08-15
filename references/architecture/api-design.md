## API Design

**Applies to:** any task that adds or changes an API surface — REST/HTTP
endpoints, RPC methods, internal service contracts, message schemas, function
signatures that cross a boundary, or any interface other code will call.

**Tier:** reference

---

### 1. Rule

Design the API as a stable contract for unknown future callers: consistent
naming and shapes, explicit semantics, and a versioning strategy — then keep
breaking changes behind a version bump, never silent behavior changes.

### 2. Why this matters (long-term cost of getting it wrong)

- Every caller compiles against the contract; changing a shape without
  versioning breaks all of them at once and the fix is coordinated downtime.
- Ambiguous semantics (what does null mean? is this idempotent?) force every
  consumer to guess and then re-guess when they get it wrong.
- Inconsistent naming means every integration is bespoke; the cognitive cost
  multiplies with each caller.
- Reusing a generic endpoint with boolean flags instead of real design
  produces an unreadable API that can't evolve without breaking everything.

### 3. Decision checklist

- [ ] Are the semantics unambiguous — what each field means, what null means,
      is the operation idempotent?
- [ ] Is the shape consistent with the existing API surface (naming, casing,
      error format)?
- [ ] Does every error have a stable machine-readable identity (code) plus a
      human message?
- [ ] Is this a new version of an existing contract, and is the versioning
      strategy explicit?
- [ ] Have I kept a single resource/operation per endpoint instead of
      polymorphic "do what I mean" flags?

### 4. Default pattern

1. **Resource-oriented, noun-based** — `GET /orders/{id}`,
   `POST /orders`; actions become sub-resources or explicit verbs only when
   forced.
2. **Consistent conventions** — plural nouns, kebab-case paths, snake_case or
   camelCase payloads (match the codebase), and one standard error envelope.
3. **Be explicit about idempotency** — document which writes are idempotent and
   provide the mechanism (idempotency key) where retries are expected (see
   `architecture/idempotency.md`).
4. **Version the contract before you need to** — include a version component
   or compatible-extension discipline from day one; additive changes are
   non-breaking, breaking changes bump the version (see
   `architecture/migration-and-versioning.md`).
5. **Define the contract as the source of truth** — write/refresh an OpenAPI
   schema or proto definition in the same change, so the implementation can't
   drift from the contract.

```
POST /v1/orders
{ "customer_id": 42, "items": [...], "idempotency_key": "k-123" }

201 { "order_id": 7, "status": "pending" }

Error envelope:
{ "error": { "code": "validation_failed", "message": "items is required",
             "field": "items" } }
```

### 5. When the default doesn't apply

- **Internal helper functions** — a function used by one caller in the same
  process is not an API; treat it as code, not a contract.
- **Explicitly short-lived interfaces** — a demo/prototype endpoint the user
  has scoped as throwaway; flag it so nobody builds a caller on it.
- **Vendor-imposed shape** — when the API must match a third-party format
  (webhooks, standards), follow the standard and note the constraint.

### 6. Red flags (stopgap smells specific to this file)

- An endpoint that returns 200 with an error inside the payload body.
- Error responses with a human string only, no stable code.
- A field whose meaning changes depending on which other fields are set.
- Silent version changes — same path, different shape, no version bump.
- "We'll clean up the API later" while real callers are already integrating.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "shipping the new field without a version
   bump or documentation update."
2. Name the specific cost of not fixing it: e.g. "existing callers that do
   strict validation will break at runtime, and the docs drift from the
   contract."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: TODO
   "version the `/orders` response change — owner: [team], trigger: second
   external consumer onboards or next API review."

### 8. Cross-references

- See also: `architecture/data-modeling.md` — the API should reflect the model.
- See also: `architecture/idempotency.md` — write semantics must be explicit.
- See also: `architecture/auth-and-permissions.md` — every endpoint's access
  control is defined alongside it.
- See also: `architecture/deprecation.md` — how a contract is retired.
- See also: `core/definition-of-done.md` — contract + implementation + docs
  landing together.
