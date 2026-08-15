## Deprecation

**Applies to:** any task that retires or removes a feature, endpoint, field,
parameter, dependency, environment, or behavior that someone might still be
using. Also applies when the question is "should we just delete this?"

**Tier:** reference

---

### 1. Rule

Never delete a shared thing in one step. Deprecation is a planned process —
announce, mark, migrate users, remove — with the removal as the final,
separate change. Deleting code that has live callers is an incident, not a
cleanup.

### 2. Why this matters (long-term cost of getting it wrong)

- Deleting an endpoint/field in use breaks callers you didn't know existed;
  "we thought nobody used it" is how prod outages start.
- Sudden removal gives consumers no time to migrate, forcing them to fork the
  old behavior or the old version forever.
- A removal with no migration guidance strands users on the old version and
  makes the "deprecate" promise meaningless next time.
- Silently keeping deprecated things forever (unannounced, undocumented)
  means nobody migrates, and the thing becomes load-bearing anyway.

### 3. Decision checklist

- [ ] Do I know who currently uses this, and can I prove it (usage analytics,
      callers in repo, public docs)?
- [ ] Is there a migration path for every known user — what they should use
      instead?
- [ ] Is the deprecation announced and marked (warning headers, log warnings,
      docs badge) before removal?
- [ ] Is the timeline explicit — announced date, sunset date, removal change?
- [ ] Is removal a distinct change, separable from any other work?

### 4. Default pattern

1. **Identify users** — analytics, repo callers, published docs. If users
   can't be identified, the removal is still a deprecation, not a delete.
2. **Announce and mark** — emit deprecation warnings in responses/logs, add a
   deprecation badge to docs, note the sunset date. This is a mergeable change
   by itself.
3. **Provide the replacement** — the migration path ships and is documented
   before the old path is gone.
4. **Hold the timeline** — minimum announced window (matches the ecosystem's
   convention), then remove in a standalone change with the removal in the
   changelog and the old name mapping to the replacement in any fallback docs.
5. **Keep a migration shim only when forced** — a temporary map from old→new
   is fine, but it has its own deprecation and sunset, tracked like any other
   feature.

```
deprecation sequence (each a separate change):
  1. warn: add deprecation headers/logging + docs badge   -> merge
  2. replace: ship + document the new path                -> merge
  3. sunset: delete old, changelog entry, point docs old->new -> merge
timeline is stated in step 1 and honored in step 3.
```

### 5. When the default doesn't apply

- **Definitively internal/private code** — a symbol no external or cross-module
  consumer can see (repo-private helper, private function) can be deleted
  directly; verify with a caller search first.
- **Explicit user scope** — the user authorizes a hard delete of a known,
  enumerated set of callers, having confirmed the users themselves.
- **Pre-release** — anything never released or only in the same greenfield
  release can be removed in-place (see `architecture/migration-and-versioning.md`
  for when that freedom ends).

### 6. Red flags (stopgap smells specific to this file)

- Deleting a shared endpoint/field in a change whose title says "refactor".
- "Nobody uses this, just remove it" with no caller or usage evidence.
- Removing the old thing in the same change that adds the new one.
- Keeping a deprecated thing with no announcement, no docs badge, and no date.
- A migration shim with no sunset that's treated as permanent.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "removing the legacy endpoint without the
   announce/mark phase to hit a cleanup deadline."
2. Name the specific cost of not fixing it: e.g. "unknown callers break on the
   next deploy with no warning window, and trust in future deprecations is
   damaged."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: ADR
   "legacy endpoint removed without warning phase; impact unknown — owner:
   [team], trigger: first incident report or next deprecation."

### 8. Cross-references

- See also: `architecture/api-design.md` — deprecation of a contract follows
  its versioning policy.
- See also: `architecture/migration-and-versioning.md` — removal is the final
  step of a migration.
- See also: `architecture/dependency-selection.md` — removing a dependency is
  a deprecation event.
- See also: `core/architecture-decisions.md` — record what was deprecated and
  why.
