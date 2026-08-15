## Build Workflow

**Applies to:** any task that produces, runs, or verifies executable output — code, containers, binaries, packages, or deployables — from source.

**Tier:** reference

---

### 1. Rule

Build from the repository's canonical entry point using the toolchain it declares, and verify the artifact with the project's own build/test commands before treating the work as done. Never ship or hand off code whose build you have not run yourself.

### 2. Why this matters (long-term cost of getting it wrong)

- A build that only worked in your head breaks for the next agent and for CI, forcing a debug cycle after the work was "done."
- Skipping the declared build step means stale or unbuilt artifacts get promoted, and the mismatch only surfaces at deploy time.
- Hand-rolling steps instead of using the project's scripts diverges from the reproducible path, so CI and local produce different results.

### 3. Decision checklist

- [ ] Is there a declared build/lint/test entry point (package.json, Makefile, pyproject.toml, justfile, etc.)?
- [ ] Have I run the build on a clean checkout, not just incrementally on my own changes?
- [ ] Does the build artifact match what CI and deployment expect (paths, versions, registries)?
- [ ] Are all generated/locked artifacts (lockfiles, dist/) updated and consistent with source?
- [ ] Is there any step of the build I'm assuming works that I have not executed?

### 4. Default pattern

1. Discover the entry point first — read the README and the toolchain manifests, never guess.
2. Follow the documented sequence exactly: `install → build → lint → test`, using the project's own scripts over ad-hoc commands.
3. Run on a clean state (fresh clone or `git clean`-equivalent scope) so incremental caches can't mask a broken build.
4. Use the same tool versions the project declares (`.nvmrc`, `engines`, `go.mod`, `lockfile`); prefer the project's pinned toolchain.
5. Confirm the produced artifact lands where the project expects it, and that any generated files are checked in or gitignored consistently.

```
# always prefer the project's own scripts
make build && make lint && make test
# or, for npm-style projects, in order:
npm ci            # reproducible install from lockfile
npm run build
npm run lint
npm run test
```

If the project has no build entry point at all, say so in your report and pick the smallest safe command that produces and verifies the artifact — do not silently skip verification.

### 5. When the default doesn't apply

- Disposable/demo or throwaway scratch context the user explicitly scoped as "don't bother building" — the artifact's only consumer is immediate exploration.
- A genuine hard constraint (missing dependency, no network, platform-specific tooling unavailable) where the user has explicitly authorized a static/read-through review instead of a full build — still say what was not run.
- Read-only or planning tasks that never produce an artifact — the build rule only binds when output is being made or shipped.

### 6. Red flags (stopgap smells specific to this file)

- "The build probably works" or "it compiles in my head" — verification was skipped.
- Running one-off commands that drift from the declared scripts (e.g., hand-assembling a jar instead of `gradle build`).
- Skipping lint/test because "the build passed."
- Editing a generated file or artifact by hand instead of regenerating it.
- Assuming a toolchain version instead of reading the pinned one.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:
1. Name what's being deferred — e.g., "full clean build and test run for the changed module."
2. Name the specific cost — e.g., "the artifact is unverified; CI is the first place a broken build will surface, costing a review round-trip or a failed deploy."
3. Write it into an ADR or a tracked TODO with an owner and a trigger for when it must be revisited (e.g., "re-run full build on the next PR or before release cut").

### 8. Cross-references

- See also: `references/build/repository-discovery.md` for finding the right entry point and project structure.
- See also: `references/build/tool-use-policy.md` for which build/verify commands are allowlisted.
- See also: `references/quality/testing-strategy.md` for what "verified" means beyond a successful compile.
- Escalates to: `core/verification.md` when a build result cannot be confirmed.
