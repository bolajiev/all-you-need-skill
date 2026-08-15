# TEMPLATE — how to write every file in this skill

Use this structure for every file under `core/` and `references/`. Delete this
comment block before writing the real file. Keep each file focused on ONE
concern — if you need "and" to describe what a file covers, split it.

---

## [File Title — e.g. "Data Modeling"]

**Applies to:** [when does this file get consulted? e.g. "any task that creates
or changes a schema, table, or persisted data shape"]

**Tier:** [core | reference] — core = always loaded when skill triggers,
reference = pulled in only when this specific concern is in play.

---

### 1. Rule

One or two sentences. The non-negotiable default for this concern, stated as
an instruction, not a discussion. This is the line the agent follows unless
explicitly told otherwise.

> Example: "Model the domain as it actually is, not as the current UI needs
> it. A shortcut here is expensive to reverse once real data exists."

### 2. Why this matters (long-term cost of getting it wrong)

2–4 bullets. Name the concrete failure mode if this is skipped or shortcut —
not "technical debt" vaguely, but the specific thing that breaks later
(a migration, a rewrite, data loss, a breaking change, an outage).

- [failure mode 1]
- [failure mode 2]

### 3. Decision checklist

The concrete questions the agent asks itself before proceeding. Written as
yes/no or short-answer questions, ordered from most to least important.

- [ ] [question 1]
- [ ] [question 2]
- [ ] [question 3]

### 4. Default pattern

The actual "do it this way" guidance — concrete enough to act on without
further clarification. Code shape, folder structure, naming convention,
sequence of steps, whatever is appropriate to this file's concern. This is
the meat of the file.

```
[example structure / pseudocode / command sequence if relevant]
```

### 5. When the default doesn't apply

Name the legitimate exceptions — cases where deviating from the default is
correct, not a shortcut. Be specific about what makes it legitimate (explicit
user scope, disposable/demo context, a real hard constraint) so this section
can't be used to rationalize an ordinary stopgap.

- [legitimate exception 1] — why it's legitimate, not a shortcut
- [legitimate exception 2]

### 6. Red flags (stopgap smells specific to this file)

Concrete tells that a shortcut is being taken here specifically — phrases,
patterns, or actions the agent should catch in its own output before calling
something done.

- [red flag 1]
- [red flag 2]

### 7. If a shortcut is genuinely necessary

Never silent. State the required output:
1. Name what's being deferred, in one sentence.
2. Name the specific cost of not fixing it (what breaks, when).
3. Write it into an ADR or a tracked TODO with an owner and a trigger for
   when it must be revisited — not a bare comment in code.

### 8. Cross-references

Which other files in this skill this one hands off to or depends on.

- See also: `[other-file.md]` for [reason]
- Escalates to: `[references/agent-state/escalation-triggers.md]` when [condition]

---

## Notes for the agent generating these files

- Keep each file under ~150 lines. If it's growing past that, it's covering
  more than one concern — split it.
- Section 4 (Default pattern) is the only section allowed to be long/detailed.
  Everything else should be scannable in a few seconds.
- Every file must have a Section 7. A file with no legitimate shortcut path
  should say so explicitly ("no shortcut is acceptable here — see Rule") not
  omit the section.
- Write Section 1 (Rule) first, always. If you can't state the rule in one or
  two sentences, the file's scope is still too broad.
- Don't restate the SKILL.md philosophy in every file — link to
  `core/architecture-decisions.md` instead of re-explaining "why we avoid
  stopgaps" each time.
