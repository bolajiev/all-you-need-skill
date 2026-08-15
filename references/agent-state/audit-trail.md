## Audit Trail

**Applies to:** any task where the agent takes autonomous actions — non-optional: every action with an effect must be traceable to what ran, when, with what inputs, and what happened.

**Tier:** reference

---

### 1. Rule

Record every autonomous action — what ran, when, with what (redacted) inputs, and what happened — in a durable, append-only trail that a human can review. If an action isn't in the trail, it effectively didn't happen and can't be audited.

### 2. Why this matters (long-term cost of getting it wrong)

- Without a trail, a bad action can't be investigated, attributed, or prevented from recurring — every incident ends in "we can't tell what happened."
- An untraceable autonomous system is unsafe to trust and impossible to defend in any dispute, security review, or compliance audit.
- Gaps in the trail are where the most expensive mistakes hide: an action that "worked" but is unrecorded leaves no evidence for the fix that later needs it.
- The trail is the substrate for everything else in this skill — monitoring, incident response, and escalation all depend on being able to answer "what actually happened?"

### 3. Decision checklist

- [ ] Does this action have an effect (writes, network, money, system calls, external requests)?
- [ ] Is it recorded in the audit trail, with the outcome?
- [ ] Are secrets and sensitive data redacted from the record before it's written?
- [ ] Is the trail append-only and durable — can't be silently edited or lost with the session?
- [ ] Can a human review what happened without asking the agent to remember?

### 4. Default pattern

Write one entry per autonomous action, before or immediately after the action, as close to atomic as the platform allows:

```
{
  "id": "<unique action id>",
  "timestamp": "<ISO-8601 UTC>",
  "session": "<session/task id>",
  "action": "<verb + target, e.g. create_file / api.request / exec>",
  "inputs": "<required inputs, secrets redacted>",
  "outcome": "<success|failure|partial>",
  "result": "<short result or error ref>",
  "actor": "<agent/human who authorized, if known>",
  "checkpoint": "<link to checkpoint state if one was taken>"
}
```

- Prefer the environment's logging/audit facility; the trail must survive the session and be append-only (no in-place edits of past entries).
- Correlate entries with action ids so a human can trace one action end to end.
- Redact before writing, using the same detection as `secrets-handling.md` — the trail is exactly where a leaked secret ends up if redaction happens after the fact.
- Record escalation decisions and their rationale (see `escalation-triggers.md`) so the trail shows *why*, not just *what*.

### 5. When the default doesn't apply

- **Provably side-effect-free actions** (pure local reads/computation) — logging every one adds noise; they still appear when part of a larger recorded action.
- **Disposable/demo context** with no external effects — a lightweight local log may suffice; nothing persistent means nothing to audit later.
- **A real hard constraint** (the environment offers no durable log sink) — then write to whatever persists and say so; an in-session-only trail is not durable and must be flagged.

### 6. Red flags (stopgap smells specific to this file)

- Recording only successful actions, or only the agent's summary of them.
- Writing entries that can be edited after the fact.
- A trail that lives only in the current session's context.
- Logging raw secrets instead of redacted values.
- "I'll reconstruct it from memory" when asked what an action did.
- No unique ids, so actions can't be traced end to end.

### 7. If a shortcut is genuinely necessary

1. Name what's being deferred: e.g. "no durable audit log; recording in the session only."
2. Name the specific cost: if the session ends, what happened is unrecoverable and any incident can't be investigated; say when it bites (the first event that needs an audit).
3. Write it into an ADR or a tracked TODO with an owner and a trigger (e.g. "wire the durable audit sink before any further autonomous actions; owner = [x], trigger = next task run"). No silent exceptions.

### 8. Cross-references

- See also: `monitoring-and-alerting.md` — the trail is the log layer monitoring reads from.
- See also: `secrets-handling.md` — redaction must happen before the trail is written.
- See also: `incident-response.md` — the trail is the primary evidence source.
- Escalates to: `references/agent-state/escalation-triggers.md` when a trail gap blocks investigation.
