## Git Workflow

**Applies to:** every interaction with version control — branches, commits, pushes, PRs, merges, and resolving history.

**Tier:** reference

---

### 1. Rule

Follow the repository's existing git conventions: same branch model, same commit granularity and message style, same PR/review process. Commit only when the change is complete and coherent, and never force-push or rewrite shared history.

### 2. Why this matters (long-term cost of getting it wrong)

- Divergent history conventions make the repo harder to read, bisect, and review, and raise the cost of every future change.
- Committing broken or half-finished work pollutes history; bad commits get cherry-picked and reverted downstream.
- Rewriting pushed history breaks everyone else's branches and forces manual reconciliation.

### 3. Decision checklist

- [ ] Have I checked `git status` and `git log --oneline` to read the repo's actual conventions before committing?
- [ ] Is the change complete and coherent — does each commit stand alone and pass the build?
- [ ] Does my commit message match the repo's style and explain the "why"?
- [ ] Have I staged only intended files (no secrets, no stray artifacts)?
- [ ] Am I committing only because the task is done, or because I was asked to?

### 4. Default pattern

1. Read before writing: `git status`, `git diff`, `git log --oneline -10`, and any `CONTRIBUTING.md` — mirror the observed conventions.
2. Create a feature branch off the current integration branch, named for the change (`fix/login-timeout`, `feat/export-csv`).
3. Commit small, coherent units: one logical change per commit, conventional message of the repo's style, body explaining the "why" when it isn't obvious.
4. Stage explicitly — inspect the diff and never use `git add -A` blindly.
5. Before pushing or opening a PR, re-run the relevant lint/build/test so the commit is green.
6. Never force-push shared branches; if history must change, say so and coordinate rather than rewriting silently.

```
git status && git diff          # what changed
git checkout -b fix/login-timeout
git add <explicit files>
git commit -m "fix: clear login timeout on session refresh"
git push -u origin fix/login-timeout
# open PR against the integration branch, reference the issue
```

### 5. When the default doesn't apply

- User explicitly requests a specific workflow (e.g., "commit directly to main" in a scratch repo, or "don't commit yet — just make the edits").
- Disposable/scratch context where branch hygiene adds no value and the user says so.
- A genuine hard constraint, such as a repo that only accepts commits to one branch or a fork-based flow the user directs — follow the user's direction and note the deviation.

### 6. Red flags (stopgap smells specific to this file)

- Committing "to make progress" before the change is verified or complete.
- A commit message that restates the diff instead of the intent.
- `git add -A` / `git add .` without inspecting what gets staged.
- Rebasing or force-pushing branches others may have based on work.
- Silently committing secrets or generated artifacts because they were in the working tree.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:
1. Name what's being deferred — e.g., "a clean commit history with one logically-scoped commit per change."
2. Name the specific cost — e.g., "muddled history makes bisects and reviews harder, and a forced history rewrite later becomes a coordination burden."
3. Write it into an ADR or a tracked TODO with an owner and a trigger (e.g., "squash/clean up this branch's history before it is merged").

### 8. Cross-references

- See also: `references/quality/code-review-checklist.md` for what a mergeable commit must satisfy.
- See also: `references/build/build-workflow.md` for the verification step before committing.
- Escalates to: `core/permission-boundaries.md` when a push, force-push, or merge requires authority beyond the agent's defaults.
