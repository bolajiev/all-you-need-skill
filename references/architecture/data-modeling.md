## Data Modeling

**Applies to:** any task that creates or changes a schema, table, entity,
persisted data shape, cache key structure, or any data format that will outlive
a single request.

**Tier:** reference

---

### 1. Rule

Model the domain as it actually is, not as the current UI or one caller needs
it. A schema is a contract with the future; once real data exists, reshaping it
is a migration with production risk, so get the shape right at design time.

### 2. Why this matters (long-term cost of getting it wrong)

- A table modeled around one screen's needs forces other features to reshape
  or duplicate data, and every duplicate drifts out of sync.
- Missing a uniqueness constraint now means dedupe code scattered through the
  app forever — and the corruption it guards against grows on its own.
- Wrong types (string for money, int for id) propagate into every consumer
  and break queries, joins, and migrations later.
- Renaming a poorly-named field is a migration + a code sweep across every
  reader; naming cost compounds linearly, renaming cost compounds
  quadratically.

### 3. Decision checklist

- [ ] Does the shape model the real entity, independent of the current call
      sites?
- [ ] Are uniqueness, nullability, and integrity constraints explicit — not
      enforced only in app code?
- [ ] Are the field names and types precise (IDs are ids, money is
      decimal/cent-int, time is a defined tz)?
- [ ] Is there a stated plan for how the shape will evolve (see
      `architecture/migration-and-versioning.md`)?
- [ ] Have I checked the existing schema for an equivalent that should be
      reused instead of duplicated?

### 4. Default pattern

1. **Name the entity and its fields from the domain language**, not from
   screens or endpoint params.
2. **Use the strongest integrity primitive available** — DB constraints,
   NOT NULL, UNIQUE, FK, CHECK over app-layer checks; app checks are
   fine-to-have, DB constraints are must-have.
3. **Pick types that match the domain** — money as integer minor units or
   DECIMAL (never float); booleans as bool, not flags strings; timestamps with
   an explicit timezone; status as a constrained enum not free text.
4. **Add timestamps and soft-delete fields only when the domain needs them** —
   not defensively; a column nobody writes to is noise that future readers
   trust.
5. **Write the schema change as a versioned migration** immediately (see
   `architecture/migration-and-versioning.md`).

```
CREATE TABLE orders (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id BIGINT NOT NULL REFERENCES customers(id),
  status      order_status NOT NULL DEFAULT 'pending',
  amount_cents BIGINT NOT NULL CHECK (amount_cents > 0),
  created_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (customer_id, reference)
);
```

### 5. When the default doesn't apply

- **Disposable/demo data** — ephemeral scratch tables or a demo fixture don't
  need forward-looking modeling; just don't let them leak into prod schemas.
- **Explicit user scope** — user says "one-off table for a single feature,
  reshape later"; legitimate only when the user owns the trade-off.
- **Strict third-party schema** — when persisting a vendor API's response
  shape verbatim is the requirement; note it as a constraint, don't fight it.

### 6. Red flags (stopgap smells specific to this file)

- Column names mirror UI labels or endpoint names instead of domain terms.
- Uniqueness or NOT NULL only enforced in the application layer.
- Money or counts stored as `float`/`double`.
- "We can add the constraint later" — on a schema that will receive real data.
- Copy-pasting a table block "because it's similar" to another feature's.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "omitting the UNIQUE constraint on
   `reference` because of an existing duplicate row."
2. Name the specific cost of not fixing it: e.g. "duplicate references can
   enter prod and every order lookup must dedupe in code until fixed."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: ADR
   entry "add UNIQUE(customer_id, reference) after dedup backfill, owner:
   [team], trigger: next release window / before the table's first cross-team
   consumer."

### 8. Cross-references

- See also: `architecture/migration-and-versioning.md` — every model change is
  a versioned migration.
- See also: `architecture/api-design.md` — the API should expose the model,
  not reshape it.
- See also: `architecture/service-boundaries.md` — whose model owns a field is
  decided there, before the table is written.
- See also: `core/architecture-decisions.md` — record significant modeling
  decisions, especially deviations.
