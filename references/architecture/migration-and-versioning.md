## Migration and Versioning

**Applies to:** any task that changes a schema (DB tables, config formats,
persisted structures) or the versioning of any artifact (DB, API, package,
data format) that other code or data depends on.

**Tier:** reference

---

### 1. Rule

Every schema change is a forward-only, versioned migration; every
breaking change to a shared contract is a version bump, not an edit. Migrations
are additive-first and reversible enough that a failed rollout can back out
without data loss.

### 2. Why this matters (long-term cost of getting it wrong)

- Editing a table in place (or hand-ALTERing prod) leaves no history: you
  can't tell how the schema became what it is, and fresh environments can't be
  rebuilt.
- A destructive migration (drop/retype column) with no back-out path can lose
  production data irrecoverably on a bad rollout.
- Changing a shared contract in place silently breaks every consumer that
  compiles against the old shape — coordinated downtime, not a bump.
- Versioned artifacts without a policy for additive vs. breaking changes
  forces every consumer to recompile on every release.

### 3. Decision checklist

- [ ] Is this change represented as a versioned migration in the migration
      system, not an ad-hoc ALTER?
- [ ] Is the change additive (safe to deploy before/with code) or breaking
      (requires version bump / coordinated rollout)?
- [ ] Does the migration have a back-out path — can a failed rollout be
      reverted without data loss?
- [ ] Does the new version explicitly exist alongside the old during rollout
      (expand/migrate/contract), or are we editing in place?
- [ ] Have downstream consumers been identified before the change is applied?

### 4. Default pattern

1. **Forward-only versioned migrations** — one file per change, ordered and
   immutable once applied; never edit a shipped migration.
2. **Classify the change** — additive (new column/endpoint, backfill in code)
   vs. breaking (retype/rename/drop, contract change).
3. **Prefer expand–migrate–contract** for big changes:
   - **Expand**: add the new column/version while old still works.
   - **Migrate**: backfill / dual-write in code.
   - **Contract**: drop the old column/version in a later, separate migration.
4. **Back-out plan before apply** — the reverse migration (or the "deploy old
   artifact against new schema" check) is written and tested first.
5. **Version shared contracts explicitly** — bump the version for breaking
   changes, additive-only for non-breaking (see `architecture/api-design.md`).

```
expand:  ALTER TABLE orders ADD COLUMN total_cents BIGINT;
migrate: backfill total_cents in app code, dual-write on new rows
contract: ALTER TABLE orders DROP COLUMN total;      # later, separate change

back-out for each step: reverse migration exists and is tested before rollout
```

### 5. When the default doesn't apply

- **Disposable environment** — scratch/dev databases with no external
  consumers can be rebuilt from scratch; migrations still apply but the
  back-out rigor can be relaxed.
- **Greenfield pre-release** — before any real data or consumers exist, a
  squashed/rewritten migration history is legitimate; that freedom is
  explicitly revoked once anything is released.
- **Explicit user scope** — user approves a one-shot in-place change for a
  throwaway artifact, owning the trade-off.

### 6. Red flags (stopgap smells specific to this file)

- Editing a migration that already ran in any environment.
- An ALTER run by hand "just to fix it quickly" with no migration file.
- Dropping a column/table in the same migration that adds it back later.
- A breaking change to a shared endpoint/data shape with no version bump.
- No back-out path written before the rollout starts.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "applying a destructive column change
   without a reverse migration to meet the deploy window."
2. Name the specific cost of not fixing it: e.g. "if the rollout fails,
   restoring the column means a restore-from-backup, with data loss in the
   window between."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: ADR
   entry "no reverse migration for change X; restore-from-backup is the plan —
   owner: [team], trigger: any prod rollout touching X or the next DR test."

### 8. Cross-references

- See also: `architecture/data-modeling.md` — the schema is designed before the
  migration is written.
- See also: `architecture/api-design.md` — contract versioning policy for APIs.
- See also: `architecture/deprecation.md` — retiring old versions follows that
  file.
- See also: `core/architecture-decisions.md` — record migration strategy
  decisions.
