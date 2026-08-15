## Dependency Selection

**Applies to:** any task that adds, upgrades, replaces, or removes a
third-party library, framework, plugin, or tool — or that reaches for a helper
that probably already exists as a dependency.

**Tier:** reference

---

### 1. Rule

Prefer the smallest set of vetted, maintained dependencies, chosen on evidence
(maturity, maintenance, license, security, fit), and always re-check what is
already available before adding anything. A new dependency is a liability you
are choosing to own.

### 2. Why this matters (long-term cost of getting it wrong)

- An abandoned or unmaintained library is a security and bug sink you inherit;
  replacing it later means rewriting the code that wrapped it.
- A one-function dependency that should have been a few lines of code adds a
  supply-chain surface and version-rot burden for no value.
- A license or security conflict discovered after integration forces a
  re-architecture under deadline pressure.
- Adding a library that duplicates existing functionality creates two
  implementations to keep consistent, and you now maintain both.

### 3. Decision checklist

- [ ] Does this problem already have a solution in the repo's current
      dependencies or standard library?
- [ ] Is the library actively maintained (recent releases, responsive), and is
      it on a maintained release line?
- [ ] Is the license compatible with the project, and are there known
      vulnerabilities (advisory check)?
- [ ] Is the dependency small and well-scoped, or does it drag in a large
      transitive tree for a sliver of value?
- [ ] Does the decision get recorded (why this, why now), so it can be
      revisited?

### 4. Default pattern

1. **Search first** — grep for existing usage, check the standard library, read
   the lockfile. The answer is often already installed.
2. **Research the candidate** (see `planning/research.md`) — repo activity,
   release cadence, license, security advisories, maintenance status.
3. **Pick the minimal, standard choice** — prefer widely-adopted, API-stable
   libraries over niche ones; prefer the framework's official extension over a
   third-party alternative.
4. **Pin to a concrete version** and let the lockfile record the transitive
   tree; upgrade deliberately and re-verify.
5. **Record the decision** in `core/architecture-decisions.md`: the need, the
   candidates, the choice, the reason.

```
add-dependency checklist:
  needed?       -> can the existing stack do it?            (no = proceed)
  candidate?    -> maintained, licensed, no known CVE?      (yes = proceed)
  size?         -> small surface, small transitive tree?    (yes = proceed)
  recorded?     -> ADR entry with rationale?                (yes = done)
```

### 5. When the default doesn't apply

- **Explicit user direction** — the user names a specific library to use;
  that's the scope, don't re-litigate the choice, but still check the pinned
  version.
- **Demo/prototype** — a throwaway may pull a quick library to prove a concept;
  flag that it must be re-evaluated before production.
- **Hard ecosystem constraint** — a language/framework with a de-facto standard
  library (e.g. the framework's blessed package) is the default even if it's
  imperfect.

### 6. Red flags (stopgap smells specific to this file)

- Adding a dependency without checking the lockfile for an existing equivalent.
- Installing the "hot new" package when the framework's built-in covers it.
- No record of why the dependency exists.
- A dependency pinned to an ancient version "because it works" with no
  maintenance check.
- Copy-pasting a `requirements.txt`/`package.json` line from a random example.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "using an unmaintained parsing library
   because the maintained one needs a language bump we can't do now."
2. Name the specific cost of not fixing it: e.g. "unpatched CVEs in that
   library are ours to own until we replace it."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: ADR +
   TODO "replace lib X after language bump — owner: [team], trigger: the
   language bump merges or the first security advisory."

### 8. Cross-references

- See also: `planning/research.md` — the research process for evaluating
  candidates.
- See also: `architecture/deprecation.md` — removing a dependency is a
  deprecation event.
- See also: `core/architecture-decisions.md` — every dependency decision is
  recorded there.
