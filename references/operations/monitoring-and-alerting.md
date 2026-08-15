## Monitoring and Alerting

**Applies to:** any task where the agent takes autonomous actions that produce state, side effects, or external requests that nobody explicitly inspected — non-optional, not a nice-to-have.

**Tier:** reference

---

### 1. Rule

Anything the agent does autonomously must be observable: instrument the action, and surface unexpected outcomes to a human with an alert — do not rely on the agent to notice its own mistakes. If you cannot monitor it, you do not have permission to do it.

### 2. Why this matters (long-term cost of getting it wrong)

- An unmonitored autonomous action can fail, loop, or fan out for hours before anyone notices; the blast radius grows with every silent retry.
- "It worked in the test" is not observability — a live-system failure with no alert is indistinguishable from no failure at all, so the problem compounds unnoticed.
- Missing alerting on writes, funds, or destructive operations turns a single bad action into an expensive, hard-to-audit event (see `audit-trail.md`).
- Without monitoring, the team can't tell a regression the agent caused from one the deploy caused — every incident becomes a blame hunt.

### 3. Decision checklist

- [ ] Does this action have side effects outside the sandbox (external requests, writes, money, data deletion)?
- [ ] Can I observe the outcome independently of the agent's own report (logs, status codes, state diff)?
- [ ] Is there a threshold or condition that must trigger a human alert, and is it wired?
- [ ] Would a silent failure of this action be caught by anything besides me?

### 4. Default pattern

Instrument every autonomous action with three layers, and wire an alert for anything whose failure a human would want to know about within minutes.

```
Layer 1 — Log: every action writes {action, inputs (redacted), outcome,
  timestamps} to the audit trail.
Layer 2 — Metric/health: any action with external effects exposes a
  success/failure counter and a recent-outcome probe.
Layer 3 — Alert: on failure, timeout, retry-loop, or out-of-contract
  behavior, page/notify a human with the action id and the redacted
  inputs needed to investigate.

Trigger alerting for: repeated failures (N in a row), anomalous
  retry counts, out-of-range results, and anything touching money,
  credentials, or irreversible operations.
```

- Prefer the environment's existing observability tooling (platform dashboards, error tracking, logging sinks) over bespoke alerting.
- Redact secrets from every log line before it is written (see `secrets-handling.md`).
- Alert thresholds default to conservative (fail fast, alert early); tighten them only on evidence of noise, never to avoid the alert.

### 5. When the default doesn't apply

- **Disposable/demo context** — a throwaway sandbox where nothing persistent exists: logging alone may suffice, and the cost of a missed alert is close to zero.
- **The action's outcome is verified synchronously and atomically** — where the agent checks the result before continuing and can abort on failure, a full alert pipeline may be unnecessary; still log.
- **A real hard constraint** (the environment genuinely exposes no monitoring hooks) — then at minimum log everything and make the audit trail the monitoring surface.

### 6. Red flags (stopgap smells specific to this file)

- "It's fine, I verified it in my head" with no logged evidence.
- Silent retry loops with no backoff and no alert after N attempts.
- Outcome recorded only in the agent's summary, not in a system log.
- Turning alerts off or leaving them unconfigured "because they were noisy."
- No way to tell, after the fact, which actions ran and what they did.

### 7. If a shortcut is genuinely necessary

1. Name what's being deferred: e.g. "no alert wired for this autonomous action, log-only."
2. Name the specific cost: a silent failure is caught by nobody until a human happens to look; say when that is unacceptable (the first unattended run with external effects).
3. Write it into an ADR or a tracked TODO with an owner and a trigger (e.g. "add alerting before the next unattended run; owner = [x], trigger = next deployment"). No silent exceptions.

### 8. Cross-references

- See also: `audit-trail.md` — the log layer this file depends on.
- See also: `secrets-handling.md` for redaction before anything is logged.
- Escalates to: `incident-response.md` when an alert fires.
- See also: `core/verification.md` for verifying outcomes independently.
- Escalates to: `core/architecture-decisions.md` when the monitoring stance for the skill changes.
