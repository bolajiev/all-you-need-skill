## Internationalization and Localization

**Applies to:** any task that builds or changes user-facing strings, or software that will reach users in more than one language, locale, or culture.

**Tier:** reference

---

### 1. Rule

Never hard-code user-facing text: externalize every string, localize every value that formats differently by locale (dates, numbers, currencies), and design layout to survive text expansion and RTL. Internationalization is done up front in the code shape; localization is a data problem, not a rewrite.

### 2. Why this matters (long-term cost of getting it wrong)

- Hard-coded strings mean adding a language is a code-diff-and-review project per string, so translation becomes so expensive it never happens well.
- Date/number/currency formatting by hand ("$" prefix, "MM/DD/YYYY") produces wrong output per locale — wrong dates, wrong separators, wrong currency symbol position — that reads as a bug to every non-default user.
- Ignoring text expansion breaks layout silently: a button that fit "Send" in English overflows on the German "Senden"-adjacent long labels, clipping text or wrecking the grid.
- Ignoring RTL means the product is permanently broken for a class of users, and retrofitting RTL into a left-biased layout is a rewrite, not an edit.

### 3. Decision checklist

- [ ] Is every user-visible string externalized (message catalog), including errors, alt-text, placeholders, and accessibility labels?
- [ ] Are dates, times, numbers, and currencies formatted through a locale-aware API, never by string assembly?
- [ ] Do pluralization and gender-sensitive rules use the platform's ICU/message syntax, not string concatenation?
- [ ] Will the layout still hold at ~30–50% longer strings, and is there RTL support if any target locale is RTL?
- [ ] Is there a canonical locale (default/source language) defined, and is locale stored/passed through requests and persistence?

### 4. Default pattern

- **Externalize everything user-facing.** Strings live in message catalogs keyed by semantic ID, resolved by the platform's i18n mechanism — never literal text in components or error handlers.
- **Format by locale, not by hand.** Use the platform's locale-aware formatters (Intl/ICU, `i18n` frameworks) for dates, numbers, currencies, and units. Never hand-build "MM/DD/YYYY" or "$1,000" — the locale owns those rules.
- **Pluralization via message syntax** (ICU plural/select), not `if (count === 1)` string assembly — languages have 1, 2, 6, or no plural forms.
- **Text expansion budget:** design and test against ~30–50% longer strings; use flexible containers, truncation or wrapping rules, and never absolute-width buttons sized to the source text.
- **RTL:** use logical layout properties (start/end, not left/right) from the start if any target locale is RTL, and set `dir` correctly on the document. Retrofitting is the expensive path, so decide RTL support before layout is built.
- **Locale plumbing:** define the canonical locale, resolve the user's locale explicitly, and thread it through the request and persistence layer — never let it be an ambient accident.

```
// Strings: externalized, keyed, never inline
messages: { "checkout.confirm": "Place order" }
<button>{ t("checkout.confirm") }</button>

// Values: formatted by the platform, not by hand
tokens:  date = formatDate(user.date, locale)        // not "MM/DD/YYYY"
         price = formatCurrency(total, currency, locale) // not "$" + total
// Pluralization: message syntax, not count-checking
messages: { "cart.items": "{count, plural, one {# item} other {# items}}" }

// Layout: logical, expansion-tolerant
flex-basis: auto; min-width: 0; text-wrap: balance; /* start/end, not left/right */
```

### 5. When the default doesn't apply

- **Explicit user scope** that the product is single-locale and single-language by contract — then a full catalog is YAGNI, but locale-aware formatting still costs nothing to use and stays the default.
- **Disposable/demo context** — throwaway output where no user-facing text is a deliverable; the rule binds when the output will be seen.
- **A real hard constraint** (string keys are impossible in a fixed system, e.g., a data migration keyed on literal text) — the externalized layer still wraps it at the boundary so the constraint doesn't leak.
- **Generated/internally-auditable text** (log messages, CLI internals, metrics) that no user will see — these can stay inline, but never render them into user-facing UI.

### 6. Red flags (stopgap smells specific to this file)

- A `"$"` or `"MM/DD/YYYY"` or `"1,000"` hand-assembled anywhere in code.
- `count === 1` string branching for plurals.
- A button, cell, or banner sized to the exact source-language text with a fixed width.
- CSS using `left`/`right` for layout instead of logical `start`/`end` when RTL is in scope.
- "We only support English so it doesn't matter" used to justify hard-coded user-visible text.
- A translation key that contains the English text (e.g. `"Place order"` as the key) — that's hard-coding wearing a catalog.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:
1. Name what's being deferred — e.g., "externalizing the new checkout strings and locale-aware date formatting in the order receipt."
2. Name the specific cost — e.g., "adding any second locale becomes a per-string code change, and the receipt renders wrong date/currency for non-default users as soon as one is introduced" — state when it bites (the first localization request or the first non-default-locale user).
3. Write it into an ADR or a tracked TODO with an owner and a trigger for when it must be revisited — e.g., "owner = [x], trigger = next locale request or the next feature touching checkout: externalize and format by locale." No silent exceptions.

### 8. Cross-references

- See also: `references/architecture/api-design.md` for keeping locale/currency parameters in API contracts, not ambient state.
- See also: `references/architecture/data-modeling.md` for storing locale-tagged content correctly.
- See also: `references/architecture/code-organization-and-naming.md` for where catalogs and locale helpers live in the repo.
- See also: `references/quality/testing-strategy.md` for test coverage of expansion and non-default locales.
- Escalates to: `core/architecture-decisions.md` when the i18n framework or the canonical-locale policy changes.
