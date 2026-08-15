## Documentation

**Applies to:** any task that changes behavior, an API or function signature, a configuration or env var, an operational runbook, or a decision — anything a future reader will need to understand the change after the author is gone.

**Tier:** reference

---

### 1. Rule

Treat documentation as part of the deliverable, not an afterthought: update the README, API docs, runbooks, and decision records to match every behavior-bearing change, and document what you learned so the next agent does not re-derive it from scratch. If the docs would be wrong after your change, the task is not done.

### 2. Why this matters (long-term cost of getting it wrong)

- Documentation that lags the code becomes actively wrong, and a wrong doc is worse than no doc: it makes the next person trust a lie and debug from a false premise.
- Knowledge that lives only in the author's head evaporates with them; the next agent re-derives setup, gotchas, and decisions at full cost, or worse, silently repeats the mistake.
- A missing runbook turns an incident into an extended outage while someone reverse-engineers the recovery steps under pressure.
- An undocumented decision gets re-litigated (or silently reversed) because no one can tell whether it was deliberate.

### 3. Decision checklist

- [ ] Does this change alter any public or observable surface (CLI, API, config, env var, output format)?
- [ ] Are the README / API docs / runbook / ADRs accurate after this change, or do they need edits?
- [ ] Did I learn something during this task (a gotcha, a constraint, a fix) that no one else knows yet — and did I write it down where the next person will find it?
- [ ] Is there an on-call/runbook step my change affects?
- [ ] Have I written documentation from the reader's needs, not from the code I just wrote?

### 4. Default pattern

1. **Update the docs the change touches, in the same change** — the README, the docstring/API reference, the config sample, the runbook — so docs and code never disagree in a commit.
2. **Document the "why" alongside the "what"** — a decision record (`templates/adr-template.md`) for anything irreversible or precedent-setting; a comment/README note for a local gotcha.
3. **Write for the reader who doesn't have your context** — include setup steps, prerequisites, failure modes, and a "known issues / gotchas" section rather than assuming prior knowledge.
4. **Keep runbooks executable** — exact commands, expected outputs, and a recover-from-failure step; verify them by running them.
5. **Keep docs honest and small** — prefer a correct short note to a long stale page; delete or rewrite content that is no longer true rather than leaving it to mislead.

```
change package -> check these are updated in the same commit:
  README / package docs       # usage, install, examples
  docstrings / API reference  # signatures, params, return values
  config / env samples        # new vars, defaults, behavior
  runbooks                    # deploy, recover, operate
  ADR (if decision)           # context, options, chosen, consequences
```

### 5. When the default doesn't apply

- **Explicit user scope**: the user scopes a change as throwaway/demo and says no docs are owed — honor the scope, but still leave a one-line note on anything non-obvious.
- **A change with no observable surface** — a pure internal refactor with identical behavior and no config surface; docstrings may still warrant a touch.
- **A real hard constraint** — e.g., no documentation system or repo exists at all; then the minimum is a note in the change description or a tracked TODO for the missing doc.

### 6. Red flags (stopgap smells specific to this file)

- "I'll update the README later" — and later never arrives.
- The commit message says "also updated docs" but the diff contains no doc changes.
- The docs still describe the old behavior after the code changed.
- A gotcha discovered during the task that you keep to yourself because "it's obvious to me now."
- Rewriting a page from scratch instead of fixing the one wrong sentence (drafting, not maintaining).

### 7. If a shortcut is genuinely necessary

Never silent. Required output:
1. Name what's being deferred — e.g., "the README section on the new `--format` flag and the env var table."
2. Name the specific cost — e.g., "the next user or agent will invoke the flag with the old, undocumented default and misread configs until they diff the source."
3. Write it into an ADR or a tracked TODO with an owner and a trigger (e.g., "update README + config sample before this lands in any shared branch").

### 8. Cross-references

- See also: `core/definition-of-done.md` — docs kept current is part of done.
- See also: `templates/adr-template.md` for recording decisions so they survive the author.
- See also: `references/product/ownership-and-bus-factor.md` for why documentation is the anti-bus-factor tool.
- See also: `references/quality/code-review-checklist.md` for checking "docs updated" at review time.
- See also: `references/operations/incident-response.md` — runbooks referenced here are what keeps an incident short.
