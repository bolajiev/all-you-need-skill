## Observability

**Applies to:** any code the agent writes or changes that runs on its own — services, workers, jobs, scripts — and any agent action that should leave an auditable trace.

**Tier:** reference

---

### 1. Rule

Make agent and code behavior observable: structured logs with enough context to reconstruct what happened, meaningful error reporting, and metrics where the runtime supports them. A change that cannot be diagnosed in production is not complete.

### 2. Why this matters (long-term cost of getting it wrong)

- Without logs of the real inputs and outcomes, every production issue becomes a "deploy more logging and wait" cycle instead of a diagnosis.
- Error handling that swallows or mislabels failures hides the root cause and turns incidents into archaeology.
- Unobservable agent actions (silent command runs, unexplained file changes) destroy the audit trail the whole skill's permission model depends on.

### 3. Decision checklist

- [ ] Would a reader of the logs be able to reconstruct what happened and why, without asking the agent?
- [ ] Are errors logged at the right level, with enough context, and never swallowed?
- [ ] Does any new runtime code emit structured logs that include an identifier to correlate with other events?
- [ ] Are secrets never logged, and sensitive values redacted?
- [ ] Does the change alter existing instrumentation in a way that would break dashboards or alerting?

### 4. Default pattern

1. Follow the project's existing logging/observability conventions (library, level policy, format) — do not introduce a parallel one.
2. Log at decision points: entry with key inputs (IDs, not payloads), outcome, and every error with its message and the surrounding context.
3. Use structured logging (key=value or JSON) so events are greppable and correlatable; include a request/task ID to tie events together.
4. Log errors at their origin with enough context to act, and let them propagate to a handler rather than catching and ignoring.
5. For agent-side actions, keep the audit trail: what command ran, with what outcome, and which file or system it affected.
6. Add a metric only where a runtime with metric support exists and the behavior is worth trending — otherwise a good log line is the default.

```
# structured, correlatable, no secrets
logger.info("checkout_started", order_id=order.id, total=order.total)
try:
    charge(order)
except ChargeError as e:
    logger.error("charge_failed", order_id=order.id, reason=str(e))
    raise
logger.info("checkout_completed", order_id=order.id)
```

### 5. When the default doesn't apply

- User explicitly scopes a change as throwaway/demo where no one will operate or debug it.
- A genuinely ephemeral context (one-shot local script the user will run interactively) where stdout alone suffices — still log errors, never swallow them.
- A platform that imposes its own observability contract (serverless functions, managed workers) — follow that contract rather than inventing a parallel one.

### 6. Red flags (stopgap smells specific to this file)

- `except: pass` or empty catch blocks that hide failures.
- Logging the result of "the whole thing worked" with no intermediate detail.
- Debugging by adding temporary prints and removing them instead of leaving real logs.
- Logging secrets, tokens, or full payloads because it was convenient.
- Saying "it's just a quick fix" as a reason to add no logs at all.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:
1. Name what's being deferred — e.g., "structured logging on the new worker path."
2. Name the specific cost — e.g., "a future failure in this path is diagnosed by re-deploying with logging, adding delay to every incident involving it."
3. Write it into an ADR or a tracked TODO with an owner and a trigger (e.g., "add the instrumentation before the next release of this service").

### 8. Cross-references

- See also: `references/operations/secrets-handling.md` for what must never appear in logs.
- See also: `references/quality/security-baseline.md` for the redaction requirements folded into logging.
- See also: `references/quality/self-critique-loop.md` for checking your own output's traceability before done.
