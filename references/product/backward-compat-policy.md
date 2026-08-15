## Backward Compatibility Policy

**Applies to:** any task that changes existing behavior, APIs, formats,
schemas, CLI flags, or any interface that someone else — a caller, a config,
a saved artifact — may already depend on. Applies whenever the answer to
"will this break something already in use?" is "probably."

**Tier:** reference

---

### 1. Rule

Changing code must not break existing consumers. Preserve the behavior,
interface, and contract of anything already in use; when a contract must
change, change it through a versioned, announced migration — never by
silently altering what the old contract means.

### 2. Why this matters (long-term cost of getting it wrong)

- A silently changed contract breaks callers at runtime with no deploy-time
  error — the failure appears in production, attributed to the consumer, not
  the change.
- Existing data, configs, and saved artifacts stop parsing; users hit errors
  they can't fix because they can't see what changed.
- One breaking change teaches consumers to pin versions and fork behavior,
  which makes every future change harder and slower.
- A contract broken "by accident" (a refactor that reorders fields, a
  tightened validation) is the worst kind — there's no migration because no
  one knew there was a break.

### 3. Decision checklist

- [ ] Does anything outside the change itself consume what I'm touching
      (callers, configs, saved data, other environments)?
- [ ] Am I changing an interface's behavior, or only its internals?
- [ ] If behavior changes: is the change additive (new, optional), or does it
      alter the meaning of existing inputs/outputs?
- [ ] If the contract must change: is there a versioned migration with a
      window for consumers to move?
- [ ] Can a consumer detect the change, or will it fail silently at runtime?

### 4. Default pattern

1. **Classify the change.** Additive (new optional field, new endpoint, new
   param with a default) — safe, no migration needed. Altering (existing
   input/output meaning changes) — a compatibility break, requires the
   deprecation process, not an in-place edit. Internal (no external consumer)
   — free to change.
2. **Assume consumers exist.** Even "internal" interfaces get used by other
   teams, tools, or saved state. Verify with a caller/usage search before
   treating anything as safe to break.
3. **For additive changes:** make the addition optional — old callers and old
   saved data keep working unmodified. New fields get defaults or are
   optional in parsing.
4. **For breaking changes:** route through `architecture/deprecation.md` and
   `architecture/migration-and-versioning.md` — announce, version, migrate,
   remove. The old contract stays functional until the migration is complete.
5. **For parsing/format changes:** accept what was previously produced. A
   reader must read everything the previous version wrote; otherwise old
   artifacts break on load.

```
classify first:
  additive   -> ship, keep old behavior intact
  altering   -> version + deprecate, don't edit in place
  internal   -> verify no consumers, then change freely

reader rule:  new reader MUST parse everything the old writer produced.
writer rule: new writer MUST keep producing what the old reader expected,
             unless a version/migration is announced first.
```

6. **Keep tolerance for leniency.** When relaxing constraints (validation,
   input shapes), old data must still load; when tightening, that's a breaking
   change on its own.

### 5. When the default doesn't apply

- **Explicit user scope** — the user authorizes a breaking change to a known,
  enumerated set of consumers they control, with the migration handled as part
  of the change.
- **Pre-release / greenfield** — nothing has shipped to consumers yet; the
  interface is free to change in place (see `architecture/migration-and-versioning.md`
  for when that freedom ends).
- **Hard constraint** — a security fix or platform requirement that forces a
  behavior change; then it still follows deprecation/downtime policy, but the
  schedule is driven by the constraint.

### 6. Red flags (stopgap smells specific to this file)

- A change titled "refactor" that alters the meaning of an existing input or
  output.
- Tightening validation or output shape "as a bug fix" with no announcement.
- "Nobody calls this anymore" with no caller search to back it up.
- Old saved data failing to parse after a format change.
- A breaking change shipped in the same commit as the feature that needed it.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "tightening the API's input validation
   without the announce/version window to meet a deadline."
2. Name the specific cost of not fixing it: e.g. "existing callers break at
   runtime with no migration path, production incidents get attributed to
   consumers, and trust in the interface is damaged for all future changes."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: ADR
   "contract altered without version window; affected callers unknown — owner:
   [team], trigger: first consumer error or next interface change."

### 8. Cross-references

- See also: `architecture/deprecation.md` — the process for removing old
  behavior once a contract must change.
- See also: `architecture/api-design.md` and `architecture/migration-and-versioning.md`
  — versioning policy and migration mechanics.
- See also: `architecture/data-modeling.md` — schema/format changes must not
  break stored data.
- See also: `references/anti-patterns.md` — "silently altering a live contract"
  is the file-level smell this file guards.
