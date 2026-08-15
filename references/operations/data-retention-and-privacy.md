## Data Retention and Privacy

**Applies to:** any task that collects, stores, transmits, or deletes user data — or that runs in a context subject to privacy obligations (GDPR and equivalents, PII, contractual data handling).

**Tier:** reference

---

### 1. Rule

Store only what the task actually needs, for only as long as it needs it, and treat any personally identifiable information (PII) as private by default: encrypted in transit and at rest, access-limited, and deleted on a documented schedule.

### 2. Why this matters (long-term cost of getting it wrong)

- Holding data longer than needed multiplies the blast radius of any breach and the cost of every deletion request — you can only protect data you no longer have.
- Collecting more than necessary (unrequested PII) creates obligations (storage, consent, erasure) that were never part of the task and can't be trivially unwound.
- A GDPR/privacy violation or a mishandled erasure request is a legal/compliance event, not a technical bug — it outlives any code fix.
- Data kept "just in case" is a standing target for every future attacker and every future audit.

### 3. Decision checklist

- [ ] Do I need to persist this data at all, or is it transient to the task?
- [ ] Does it contain PII or regulated data, and is that justified by the task?
- [ ] Do I have a defined retention period and a scheduled deletion mechanism for it?
- [ ] Is it encrypted in transit and at rest, and is access limited to the minimum?
- [ ] Can I honor a user's deletion/erasure request against this data?

### 4. Default pattern

```
1. Minimize: collect and persist only the fields the task's contract
   requires; drop or avoid anything else, especially PII.
2. Classify: mark stored data as transient vs. retained, and note
   whether it contains PII / regulated fields.
3. Protect: encrypt in transit (TLS) and at rest; scope access to the
   minimum role/credential set; no world-readable blobs.
4. Bound lifetime: attach a retention period to every write and wire
   the deletion mechanism (TTL, scheduled purge) before the data
   exists — retention is a property of the write, not an afterthought.
5. Support erasure: keep data structured so a deletion/erasure
   request can be fulfilled fully and demonstrably (this includes
   backups and derived copies).
```

- Prefer the environment's managed storage and lifecycle features over hand-rolled retention.
- Privacy obligations that the environment must satisfy (GDPR/EU data residency, DPA terms) are constraints of the platform you deploy to — choose the location/region accordingly and record the choice.

### 5. When the default doesn't apply

- **Explicit user scope** — the user asks to store data for a purpose with a named duration; the retention period is then user-defined, and that scope is recorded in the audit trail.
- **Disposable/demo context** — throwaway environments holding only fake/synthetic data: deletion-on-teardown can replace the full retention schedule.
- **A legal or product requirement for longer retention** (e.g. invoicing/audit law, the product's own policy) — documented as such, not as a convenience.

### 6. Red flags (stopgap smells specific to this file)

- Collecting fields "in case they're useful later."
- No answer to "when does this get deleted, and by what?"
- PII stored with no encryption, or in a location readable beyond the minimum.
- "We only keep it for testing" with no teardown that actually removes it.
- Retention defined only in prose, with no mechanism enforcing it.
- Copying data into backups or derived stores with no propagation of the deletion schedule.

### 7. If a shortcut is genuinely necessary

1. Name what's being deferred: e.g. "retention schedule not yet enforced; data has no TTL."
2. Name the specific cost: data persists indefinitely, so a breach or erasure request covers stale data you promised not to keep; say when it bites (the first audit or deletion request).
3. Write it into an ADR or a tracked TODO with an owner and a trigger (e.g. "enforce TTL before the data set grows past [size]; owner = [x], trigger = first production write"). No silent exceptions.

### 8. Cross-references

- See also: `secrets-handling.md` — credentials are data too and get the same minimization treatment.
- See also: `audit-trail.md` — what gets recorded about data handling and why.
- Escalates to: `incident-response.md` when a breach or exposure is suspected.
- Escalates to: `references/agent-state/escalation-triggers.md` when the task hits a legal/privacy decision the agent must not make.
