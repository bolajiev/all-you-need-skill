## Architecture Decisions

**Applies to:** the foundational philosophy of this skill — every decision
about whether to stop, follow the default, or take a shortcut.

**Tier:** core

---

### 1. Rule

Never accept a stopgap silently. Follow the skill's defaults unless a
documented reason exists, and record only architecturally-significant
decisions as ADRs — not every choice you make.

### 2. Why this matters (long-term cost of getting it wrong)

- Silent stopgaps are the root of every downstream cost: an undone shortcut
  becomes a migration, a rewrite, a data loss, a breaking change, or an
  outage — discovered by someone who doesn't know why it exists.
- ADR sprawl is its own failure: if every small decision gets a document, the
  signal is drowned out and the important decisions stop being read.
- Undocumented deviations make the skill's defaults unreliable; a future agent
  can't tell whether a choice was deliberate or accidental.

### 3. Decision checklist

- [ ] Am I deviating from the default pattern in this file's concern?
- [ ] If yes, is the deviation architecturally significant (irreversible,
  cross-cutting, costly to change, or sets a precedent)?
- [ ] If significant: has it been recorded in an ADR using
  `templates/adr-template.md`?
- [ ] If not significant: does a tracked TODO exist, or is the default simply
  being followed?
- [ ] Is the user aware of the deviation, or was it made silently?

### 4. Default pattern

Apply in this order:

1. Follow the default pattern of the relevant file (`core/*.md`). Most work
   never needs an exception.
2. If a deviation is needed, first check the file's "When the default doesn't
   apply" section — the legitimate exceptions are already there.
3. Classify the deviation:
   - **Architecturally significant** → write an ADR now (use
     `templates/adr-template.md`), regardless of deadline pressure.
   - **Small but real stopgap** → never silent: name it, cost it, and log it
     as a tracked TODO with an owner and a trigger (see Section 7 of the
     relevant file).
4. Only a stopgap that is both justified and small may proceed; anything
   larger goes back to the user for a decision first.

An ADR is a decision, not a record. It states: the context, the options
considered, the chosen option, why, and the consequences — including what to
revisit and when.

### 5. When the default doesn't apply

- Explicit user scope: the user authorizes the shortcut and its cost in
  advance — then it's no longer a silent stopgap, and may not need an ADR.
- Disposable/demo context: code with an explicit short lifetime where the
  user confirmed nothing durable depends on it.
- Hard constraint: a platform, budget, or schedule limit that genuinely rules
  out the default; the constraint is documented in the ADR/TODO.

### 6. Red flags (stopgap smells specific to this file)

- "I'll just" followed by any workaround without an ADR or TODO.
- A TODO with no owner and no trigger — it's a wish, not a debt item.
- An ADR for trivia (every small choice documented) — noise that buries the
  real decisions.
- A deviation made silently and discovered only during review.
- "We can fix it later" with no later defined in writing.

### 7. If a shortcut is genuinely necessary

1. Name what's being deferred, in one sentence — the exact shortcut taken.
2. Name the specific cost of not fixing it — what breaks, and when (a
   migration, an outage, a security hole, a rewrite).
3. Write it into an ADR or a tracked TODO with an owner and a trigger for when
   it must be revisited. The user must see the entry before the work proceeds.

No other form of a shortcut is acceptable in this skill — see the Rule.

### 8. Cross-references

- See also: `templates/adr-template.md` for the exact ADR format.
- Every other `core/*.md` file's Section 7 implements this doctrine for its
  own concern.
- See also: `core/scope-discipline.md` for why the deviation must stay inside
  the spec.
