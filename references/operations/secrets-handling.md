## Secrets Handling

**Applies to:** any task where prompts, context, tool output, logs, or files may contain API keys, tokens, passwords, private keys, or other credentials.

**Tier:** reference

---

### 1. Rule

Automatically detect and redact secrets at every boundary — before they enter prompts, context, or logs — and never write, print, or commit a real credential. Work with the secret only via the environment's secret store.

### 2. Why this matters (long-term cost of getting it wrong)

- A secret leaked into a log, a git commit, or a shared context is compromised even if no one exploits it — it must be rotated, and every service it belonged to is now suspect.
- Secrets embedded in code or config become permanent debt: each new environment copies them, and rotation requires touching every copy.
- A leaked credential in a shared AI context or public log is instantly harvestable by scanners and bots; by the time it's noticed, it's been used.
- Redacting "later" fails because the leak is in transit, not in a place you can recall.

### 3. Decision checklist

- [ ] Does this input/context/output contain anything that looks like a credential (key, token, password, private key, connection string)?
- [ ] Am I using a secret store / env-injected variable, or is the value in plain text anywhere I can see it?
- [ ] Will this value appear in any log, prompt, tool output, or committed file?
- [ ] Do I actually need the raw value, or can I use a reference / scoped token?

### 4. Default pattern

```
1. Detect: scan prompts, context, tool output, and logs for
   credential-shaped values — API key formats (e.g. sk-..., aws_...),
   JWTs, private key blocks (-----BEGIN ... PRIVATE KEY-----),
   password/connection-string fields, and high-entropy strings.
2. Redact at the boundary: mask or replace any detected secret before
   it enters prompts or gets written to logs (e.g. [REDACTED],
   prefix + last 4 chars only when needed for reference).
3. Inject, don't write: load real values from the environment's secret
   store at runtime; never paste them into files, commits, or code.
4. Never echo a secret back, log it, or repeat it in a summary —
   including after a successful operation.
```

- Default behavior on an uncertain value is to redact it; false-positive redaction costs far less than a leak.
- When a task requires a credential, prefer a scoped, short-lived, least-privilege token over a long-lived one.

### 5. When the default doesn't apply

- **The user explicitly supplies a secret in the prompt for the task at hand** — but it still gets redacted from logs and never persisted beyond the session's need.
- **A demo/tutorial context with a deliberately fake or public sample credential** — clearly labeled as fake, so it isn't mistaken for real.
- **The secret store is genuinely unavailable** — the value may be used for the task, but must be redacted from everything persistent and the fact logged; this is a hard-constraint exception, not a convenience.

### 6. Red flags (stopgap smells specific to this file)

- Copying a token or key verbatim into a command, file, or chat as part of the work.
- Logging or echoing a value "to debug" before redacting.
- A redaction that happens after a value was already printed or stored.
- Committing `.env` or config files with real values instead of placeholders.
- Hard-coding a credential "just for local testing."

### 7. If a shortcut is genuinely necessary

1. Name what's being deferred: e.g. "using a real credential inline because the store isn't set up."
2. Name the specific cost: the value is at risk of leaking into logs or commits and must be rotated if it does; say when it bites (the first time the value persists anywhere).
3. Write it into an ADR or a tracked TODO with an owner and a trigger (e.g. "wire the secret store and rotate the exposed value; owner = [x], trigger = before next deploy"). No silent exceptions.

### 8. Cross-references

- See also: `monitoring-and-alerting.md` — log redaction is a precondition of observability.
- Escalates to: `core/permission-boundaries.md` when a credential grants sensitive access.
- See also: `sandboxing-and-blast-radius.md` — never hand the sandbox credentials it doesn't need.
- See also: `incident-response.md` when a leak is suspected — treat it as a security event.
