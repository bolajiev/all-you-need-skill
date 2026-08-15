## Code Organization and Naming

**Applies to:** any task that creates files, modules, packages, or directories inside a repo — or that needs to read and navigate an existing one.

**Tier:** reference

---

### 1. Rule

Organize code so that a future reader can find any behavior from its name alone: one responsibility per file, packages named for what they contain (never "utils"), and naming that says what a thing is. Confusing structure is a maintenance tax that compounds on every future touch.

### 2. Why this matters (long-term cost of getting it wrong)

- A `utils/` or `helpers/` grab-bag forces readers to open every file to find anything, and every new utility lands there, growing the mess without a decision.
- Files named for their type rather than their job (`manager.py`, `handlers.go`) collide with each other and give no signal about what any of them does, so navigation is guesswork.
- Mixed granularity (a 3-line helper next to a 900-line orchestrator) means the reader's mental model of "one file = one thing" fails on every other file.
- Renaming or moving a misnamed module is avoided because it touches imports everywhere, so the wrong name hardens into the codebase and keeps misleading readers forever.

### 3. Decision checklist

- [ ] Does every file have exactly one responsibility, and does its name state that responsibility?
- [ ] Would a reader find this code from its name alone, without opening it or searching the repo?
- [ ] Is there a `utils`/`helpers`/`misc` bag anywhere, or a new file about to land in one?
- [ ] Does this module's public surface (exports, entry points) match its stated purpose, with internals private?
- [ ] Is granularity consistent with the surrounding tree (same-sized files, same abstraction level)?
- [ ] Does the placement respect the existing package/tier structure rather than inventing a parallel one?

### 4. Default pattern

- **One responsibility per file**, named for what it does — behavior names, not type names: `checkout.ts` not `manager.ts`, `priceCalculator.go` not `helpers.go`.
- **Package/module boundaries** group related behavior; a package's name is its purpose, and its public API is deliberate. Anything not part of that API is internal/private and unexported.
- **No grab-bags.** Name-by-purpose is the alternative to `utils/`: `string_helpers/` or `formatting/` or `http_client/` each describe one job. If a file can't be named for a single purpose, it's a grab-bag in disguise — split it.
- **Match the tree's existing rhythm** — read sibling files and place the new one beside its peers; follow the repo's established tiering (e.g. feature modules, shared libs, infra) instead of inventing a parallel structure.
- **Naming is a contract:** names that lie cost more than names that are merely long. Prefer precise over clever; when a file's true name drifts from what it does, rename it now, while the cost is one diff.

```
# structure by behavior, not by type
src/features/checkout/          # one package = one behavior
  checkout.ts                   # entry: what checkout is
  price-calculator.ts           # helper with a named job
  validation.ts
src/shared/formatting/          # purpose-named, not "utils/"
  dates.ts
  money.ts

# module surface
export { checkout };            # public API is intentional
// internals stay unexported/private
```

### 5. When the default doesn't apply

- **Disposable/demo or scratch context** (throwaway scripts, a single exploratory file the user scoped as temporary) — one-file or `utils.py` is fine when nothing will outlive the session.
- **A codebase that already has an established convention** that contradicts the default (e.g. the repo is deliberately type-first, or single-file modules) — consistency with the existing repo beats applying the default cold; flag the conflict in review.
- **The language/framework enforces a shape** (e.g. framework controllers all under one directory) — a real hard constraint the tooling is built around; the naming-within-that-shape still follows the default.
- **A real hard constraint** (a package manager or build step that forbids nested packages) — flatten the structure but keep the purpose-based naming and clear file responsibilities.

### 6. Red flags (stopgap smells specific to this file)

- Creating or adding to a `utils/`, `helpers/`, `misc/`, or `common/` directory.
- A filename that names the type or layer instead of the job (`manager.go`, `handlers.py`, `service.ts` with no qualifier).
- Two files whose names give no way to tell which is which (`data.go` next to `data.js`).
- "I'll just put it in the existing file because creating a new one is work" — that's the grab-bag start.
- A function or class exported only because another module "might" need it — that's an accidental API.
- Adding a file without reading its neighbors to match the tree's rhythm.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:
1. Name what's being deferred — e.g., "splitting the new helper into a purpose-named module instead of landing it in `utils/`, and renaming `handlers.py` to state its job."
2. Name the specific cost — e.g., "the next reader pays a per-lookup tax opening `utils/` to find anything, and the misleading name keeps forcing navigation errors on every future task touching that module."
3. Write it into an ADR or a tracked TODO with an owner and a trigger for when it must be revisited — e.g., "owner = [x], trigger = next refactor touching `handlers.py` or when `utils/` grows past N files: split and rename." No silent exceptions.

### 8. Cross-references

- See also: `references/architecture/service-boundaries.md` for the system-level split this file's module-level rules operate inside of.
- See also: `references/architecture/refactoring.md` for how to move and rename modules safely.
- See also: `references/build/repository-discovery.md` for orienting in a repo before placing new code.
- See also: `references/architecture/api-design.md` for keeping a module's public surface intentional.
- Escalates to: `core/architecture-decisions.md` when the repo's overall structure convention itself is being introduced or changed.
