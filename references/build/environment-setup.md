## Environment Setup

**Applies to:** any task that needs a working local, dev, or test environment — dependencies, toolchains, services, or containerized runtimes — before code can run.

**Tier:** reference

---

### 1. Rule

Set up environments through the repository's declared, reproducible path (lockfiles, manifests, container images, provision scripts) — never by improvisation. A fresh machine or a fresh agent must reach the same working state from the same commands.

### 2. Why this matters (long-term cost of getting it wrong)

- Ad-hoc installs produce "works on my machine" environments; the next agent or CI can't reproduce them, and every future debug is poisoned by the difference.
- Version drift between environments turns green-local into red-CI with no source-level cause.
- Long setup cycles become a standing tax: each new contributor or agent re-pays the cost of guessing at the setup path.

### 3. Decision checklist

- [ ] Is there a declared setup path (lockfile, `pyproject.toml`, `Dockerfile`, `nix`, Makefile target)?
- [ ] Is the toolchain version pinned (`.nvmrc`, `engines`, `go.mod`, toolchain file)?
- [ ] Does the environment include any local services (DB, cache, message queue) and are they declared?
- [ ] Is the setup idempotent — re-running it leaves the same state?
- [ ] Will the exact commands I run work on a clean machine?

### 4. Default pattern

1. Prefer containerized/provisioned setups when the repo offers them (`docker compose up -d`, `devcontainer`, `Makefile dev-setup`) — they self-document.
2. Otherwise install from the lockfile with the pinned toolchain, in this order: toolchain → dependencies → local services → seed/sample data.
3. Use the project's scripts (`make install`, `npm ci`, `poetry install`) over raw commands, because the scripts carry the project's decisions.
4. Record any manual step that the repo does not script into your output, so it can be folded back into the declared path.
5. Sanity-check the environment with the project's own smoke command before starting work.

```
# example: node workspace with local postgres
nvm use                        # pinned node (reads .nvmrc)
npm ci                         # install from lockfile, not package.json
docker compose up -d db        # declared local service
cp .env.example .env           # only if the repo instructs this
npm run db:migrate && npm run db:seed
npm run dev:smoke              # confirm the environment is live
```

If no declared setup path exists, make the minimal setup reproducible yourself and flag the gap — a setup you improvised and didn't write down is a setup you'll have to redo.

### 5. When the default doesn't apply

- User explicitly scopes the task as disposable/demo ("just get something running in /tmp") — the disposable context doesn't need to be reproducible.
- A genuine hard constraint (no network to fetch images, platform-specific packages unavailable) with user sign-off to approximate the environment — still document the divergence.
- The environment already exists and is verified working — no re-setup is needed, only confirmation.

### 6. Red flags (stopgap smells specific to this file)

- Installing with `--no-lockfile`/`--force` to make an install "just work."
- Editing global config (`.bashrc`, global pip/npm) to fix a local problem.
- Skipping the smoke check because "the install finished."
- Environment only works because of state from a previous session.
- Setup steps exist only in the agent's memory, not in any script or doc.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:
1. Name what's being deferred — e.g., "a fully reproducible, containerized dev environment."
2. Name the specific cost — e.g., "environment drift will produce local/CI divergence and one-off debugging for every future session."
3. Write it into an ADR or a tracked TODO with an owner and a trigger (e.g., "provision the declared environment before the next long-running task in this repo").

### 8. Cross-references

- See also: `references/build/build-workflow.md` for verifying the environment once it's up.
- See also: `references/build/tool-use-policy.md` for which setup commands are allowlisted vs. require sign-off.
- See also: `references/operations/secrets-handling.md` for handling `.env` and credentials during setup.
- Escalates to: `core/architecture-decisions.md` when the repo has no declared setup path and one must be adopted.
