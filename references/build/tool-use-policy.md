## Tool Use Policy

**Applies to:** every command the agent runs on the user's machine — installs, file operations, network calls, process management, and anything with side effects.

**Tier:** reference

---

### 1. Rule

Run only commands that are explicitly allowlisted. Everything else is denied by default and requires user sign-off. The allowlist is a small, explicit set of safe commands — it is never a blocklist of what to avoid.

### 2. Why this matters (long-term cost of getting it wrong)

- A blocklist mentality misses the next novel command, so an unvetted command runs with user's privileges and causes real damage (deleted data, overwritten files, unexpected network egress).
- Silent deviation from the allowlist erodes trust: the user can no longer predict what the agent will do on their machine.
- Scope creep compounds — one "harmless" surprise install leads to another, and un-reproducible environments spread across every project the agent touches.

### 3. Decision checklist

- [ ] Is this exact command (and its flags) on the allowlist?
- [ ] Does it have side effects — writes outside the workspace, network calls, installs, destructive operations?
- [ ] If not allowlisted, have I asked the user for explicit sign-off before running it?
- [ ] Am I using the allowlisted variant (exact command + flags) rather than a creative equivalent?
- [ ] Would I be comfortable running this again, unchanged, in every future session?

### 4. Default pattern

Keep the allowlist in the skill's config and treat anything not listed as a prompt-for-permission action.

Allowlisted (safe, autonomous — read-only or scoped to the working tree):

```
# read-only inspection
ls, find (within workspace), git status, git diff, git log
grep/ripgrep, cat, head, tail   # local reads only
# scoped, reversible operations inside the workspace
mkdir, touch, cp, mv, rm (within the workspace only)
git add, git commit, git checkout (branch/file, non-destructive)
npm/pip/uv tests and linters: npm test, pytest, ruff check
```

Never run autonomously (always prompt):

```
rm -rf /, sudo, chmod -R, chown -R, mkfs, dd, fdisk
curl|bash, pip install --upgrade pip, npm install -g, systemctl
git push --force, git reset --hard on uncommitted work, git clean -fd
any command writing outside the workspace without an explicit path
any network POST/PUT (only allowlisted GETs run free)
```

Sequence: (1) check the list; (2) if absent, pause and describe the command, its effect, and why it's needed; (3) run only after explicit approval; (4) record any one-off approval so the next session knows it was sanctioned.

### 5. When the default doesn't apply

- User explicitly authorizes a specific command for a specific task ("go ahead and install X") — that one approval replaces the default for that run.
- The user pre-authorizes a class of operations in the session scope (e.g., "install any Python deps for this project").
- A read-only command that isn't literally listed but is equivalent in effect (e.g., a new pager) — still prefer the listed command when one exists.

### 6. Red flags (stopgap smells specific to this file)

- "It's probably fine" attached to a command not on the list.
- Reaching for a creative alias to bypass a check instead of asking (e.g., `python -c` to delete files).
- Running a destructive command "carefully" instead of getting sign-off.
- Widening the allowlist to fit this session's convenience instead of this session's need.
- Auto-approving everything to "save time" — that's just a blocklist with nothing on it.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:
1. Name what's being deferred — e.g., "proper permission gate on command class `X`."
2. Name the specific cost — e.g., "an unvetted command runs with the user's privileges; worst case is data loss or credential exposure with no audit trail."
3. Write it into an ADR or a tracked TODO with an owner and a trigger (e.g., "re-review allowlist and log the approval before the next run").

### 8. Cross-references

- See also: `core/permission-boundaries.md` for the authority rules this policy implements.
- See also: `references/operations/secrets-handling.md` for why secret-adjacent commands are never allowlisted.
- See also: `references/build/environment-setup.md` for which setup commands are sanctioned and how to keep them reproducible.
