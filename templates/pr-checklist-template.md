# PR Checklist Template

Use before any change is merged — including changes the agent made on its own.
Treat the checklist like a new hire's PR review (core/verification.md): nothing
is checked because "it probably works".

---

## Scope

- [ ] Every change in this PR is traceable to a spec item or stated requirement
      (core/scope-discipline.md). No drive-by edits.
- [ ] No unrelated refactors, formatting churn, or bundled scope creep.

## Correctness

- [ ] Change actually works: run it, don't assume it (core/verification.md).
- [ ] Edge cases exercised: empty input, failure paths, boundaries, concurrency.
- [ ] No silent catch-and-continue; errors are handled or explicitly surfaced.
- [ ] Idempotent where retries are possible (references/architecture/idempotency.md).

## Compatibility

- [ ] No breaking change to public contracts unless versioned + deprecation
      path exists (references/product/backward-compat-policy.md,
      references/architecture/deprecation.md).
- [ ] Database/schema changes have a migration and a rollback plan
      (references/architecture/migration-and-versioning.md).

## Quality

- [ ] Tests added or updated for the change; they pass and were actually run.
- [ ] Lint/typecheck/format pass — using the project's real commands.
- [ ] No secrets, keys, or personal data in the diff
      (references/operations/secrets-handling.md).

## Documentation & observability

- [ ] Behavior that will surprise the next reader is documented.
- [ ] Logging/metrics added where the change affects runtime behavior
      (references/quality/observability.md).

## Debt

- [ ] No stopgap introduced silently. If any shortcut was taken, it is recorded
      with owner + trigger (core/architecture-decisions.md, templates/adr-template.md).
- [ ] No bare TODO-without-owner added.

---

## For the reviewer

- Check the smallest thing that would break if this shipped to prod.
- If you cannot verify a checkbox, mark it unverified — never guess it green.
- Return with specific, actionable feedback, not "looks good".
