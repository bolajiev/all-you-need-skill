## Security Baseline

**Applies to:** any code the agent writes or changes, plus the agent's own actions — the minimum security bar below which work must not ship or be committed.

**Tier:** reference

---

### 1. Rule

Never ship or commit code that leaks secrets, trusts untrusted input, or uses unsafe patterns the project doesn't already accept. The default is: least privilege, input validation, secret isolation, and no security debt in the diff.

### 2. Why this matters (long-term cost of getting it wrong)

- A committed secret is exposed forever — rotation, revocation, and incident response, and the window between commit and cleanup is a live attack surface.
- Unsanitized input and unsafe deserialization become exploitable entry points (injection, RCE, data theft) whose fixes are invasive once real data and traffic exist.
- Re-implementing security primitives instead of using the platform's vetted ones repeats known-vulnerable patterns under a fresh name.

### 3. Decision checklist

- [ ] Does this code handle any secret (token, key, password, credential)? Is it injected from the environment/secret store and never hardcoded or logged?
- [ ] Does it process any input from a user, request, file, or external system — and is that input validated and handled safely?
- [ ] Does it use the project's/platform's established libraries and primitives instead of hand-rolled crypto, hashing, or parsing?
- [ ] Does the change raise any privileges or expand any default permissions?
- [ ] Have I checked the diff itself for accidentally committed secrets or keys?

### 4. Default pattern

1. Secrets come from the environment or a secret store via the project's mechanism — never inline, never in the diff, never in logs or error messages.
2. Treat all external input as hostile: validate on entry, escape on use, and use parameterized/prepared statements for any query.
3. Use established primitives (language standard lib, platform SDK) for crypto, auth, hashing, and parsing — no bespoke implementations.
4. Apply least privilege: the code's permissions should be exactly what it needs, nothing more.
5. Scan your own diff for secrets before commit and grep your logs for secrets before shipping.

```
# secret handling
API_KEY = os.environ["API_KEY"]          # injected, not hardcoded
# input handling
user_id = sanitize_input(request.form["id"])
result = db.execute("SELECT * FROM t WHERE id = ?", (user_id,))  # parameterized
```

### 5. When the default doesn't apply

- A local, isolated demo/scratch context the user explicitly scoped as "not shipping, no real data" — the bar drops, but secrets still don't get hardcoded; that habit must not start anywhere.
- User explicitly directs a specific risky pattern for a specific case — follow the direction and record the deviation, but still flag the risk.
- A real hard constraint (platform limits validation options) — mitigate with the next-best available control and document it.

### 6. Red flags (stopgap smells specific to this file)

- A secret in the diff, an env default, a comment, or a log line.
- String-concatenated SQL or shell commands from user input.
- Hand-rolled crypto, hashing, or auth "because it's simple."
- Disabling validation or TLS to "make it work locally."
- `--force`/`--ignore-checks` used to push past a security check.
- "It's fine, this input is internal" — the codebase doesn't get to assume that.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:
1. Name what's being deferred — e.g., "input validation on the new upload endpoint."
2. Name the specific cost — e.g., "the endpoint is an unvalidated entry point for injection or malformed data, requiring an invasive retrofit once it has real traffic."
3. Write it into an ADR or a tracked TODO with an owner and a trigger (e.g., "harden the endpoint before it is exposed beyond the internal network").

### 8. Cross-references

- See also: `references/operations/secrets-handling.md` for the full secret lifecycle (store, rotation, redaction).
- See also: `references/quality/observability.md` for the logging redaction requirements that pair with this baseline.
- See also: `references/quality/code-review-checklist.md` for the security checks enforced at review time.
- Escalates to: `core/permission-boundaries.md` when a security fix would require privileges the agent doesn't hold.
