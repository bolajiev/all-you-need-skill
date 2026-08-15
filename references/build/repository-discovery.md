## Repository Discovery

**Applies to:** the start of any task that touches code — before the first edit, establish which repository, workspace, and sub-project are in scope and how they're laid out.

**Tier:** reference

---

### 1. Rule

Locate and understand the repository structure before editing anything: which repo, which module/workspace, and how the code is organized. If you cannot point to the exact file you will change, you are not ready to change it.

### 2. Why this matters (long-term cost of getting it wrong)

- Editing in the wrong repo or wrong package means changes are committed to a place they were never meant to go, breaking isolation and reviews.
- Monorepos hide dependencies between packages; editing one without seeing the others produces integration breakage that surfaces late.
- Misreading the layout (source vs. generated, app vs. test tree) puts changes in the wrong tree and pollutes the diff.

### 3. Decision checklist

- [ ] Which repository (URL, remote, or local path) contains this work — and is there a second repo that also does?
- [ ] Is this a monorepo/workspace, and if so, which package/module am I targeting?
- [ ] Where are the entry points, build config, and tests for that module?
- [ ] Are the files I plan to touch hand-written source, or generated/checked-out output?
- [ ] What does the repo's README and directory layout say about conventions I must follow?

### 4. Default pattern

1. Start with the repo root: find it by locating the top-level manifest (`.git/`, `package.json` at root, `Cargo.toml`, `go.work`, etc.) — never assume the current directory is the root.
2. Read the top-level README and the manifests that define scope: workspaces, `packages/*`, `services/*`, `apps/*`, module paths.
3. Trace the code path you'll touch: find the file, then confirm its dependencies live in the same module or are imported from elsewhere.
4. Identify generated vs. source: if the file is under `dist/`, `build/`, or produced by a generator, plan to change the generator, not the output.
5. State the target explicitly before editing: "I will change `X` in module `Y` of repo `Z`."

```
# cheap orientation
ls <repo-root>
cat <repo-root>/README*
# monorepo workspace map (examples)
cat package.json | jq '.workspaces'        # pnpm/yarn/npm
cat go.work                               # go workspaces
ls services apps packages                 # conventional layout
```

If the expected repo or file does not exist where the task implies, stop and confirm the location with the user rather than guessing — a wrong-location edit is worse than a short delay.

### 5. When the default doesn't apply

- Explicit user scope that names a single file or snippet ("just change `foo.py`") — the discovery depth shrinks to reading that file and its immediate imports.
- A brand-new repo the agent itself is scaffolding — discovery is replaced by creation, and the layout rules come from the scaffold's own conventions.
- A read-only review or planning task where full repo layout isn't needed to answer the question — still confirm which repo you're talking about.

### 6. Red flags (stopgap smells specific to this file)

- Editing without being able to state the repo root.
- Grepping across an entire monorepo and editing the first match instead of checking which package it belongs to.
- Treating a monorepo as one flat project, or a single-package repo as a monorepo.
- Hand-editing generated output instead of the generator.
- "There's probably a file for this" — discovering the shape as you edit.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:
1. Name what's being deferred — e.g., "full module/dependency mapping for the target package."
2. Name the specific cost — e.g., "a change may land in the wrong package, breaking workspace isolation and requiring a follow-up fix or review rejection."
3. Write it into an ADR or a tracked TODO with an owner and a trigger (e.g., "verify package boundaries before the next edit touching imports in this area").

### 8. Cross-references

- See also: `references/build/build-workflow.md` for what to do once the repo and entry point are identified.
- See also: `references/quality/code-review-checklist.md` for catching misplaced changes at review time.
- Escalates to: `core/permission-boundaries.md` when the intended edit crosses repo or workspace boundaries.
