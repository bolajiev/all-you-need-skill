## Usability Testing

**Applies to:** any task that builds or changes a flow a real person will
execute — before it ships, and again whenever the flow changes — as the
design-side counterpart to verifying that the code works.

**Tier:** reference

---

### 1. Rule

Verify the design by watching one real person do the real task — never by
staring at the screen and declaring it usable. When you can't observe anyone,
run the task script yourself as a stranger and write down every place the
design had to be helped, then treat that list as the findings.

### 2. Why this matters (long-term cost of getting it wrong)

- A design that "should be obvious" is regularly not; shipping it unverified
  converts every user into the first tester, at your cost — support tickets,
  churned sessions, and abandoned flows.
- Flows that the author can navigate are the worst evidence of usability: the
  author already knows the answers, so the test only proves the build matches
  the spec, not that it works for anyone else.
- Bugs found in usability testing cost a text change or a reorder to fix; the
  same problems found post-launch cost a redesign and a regression window.
- Every flow is touched by the next agent later; a tested flow that ships with
  a written record is stable, while an untested one gets "improved" by guess
  and regressed.

### 3. Decision checklist

- [ ] Is there a named task script (not "click around the app") that a real
      user would actually do?
- [ ] Can I observe at least one real task execution — or, if not, have I run
      the script cold myself and recorded every stumble?
- [ ] Do I have a list of what to watch (find time, hesitation, wrong clicks,
      where the user asks "what does this mean")?
- [ ] Are the findings triaged into fix-before-ship vs. track, and written
      down where the build can see them?
- [ ] Has the flow been retested after its biggest fix, not just tested once?

### 4. Default pattern

1. **Write the task script in user goals, not UI paths.** Three to five
   realistic jobs, each starting from the same blank state a real user starts
   from. Avoid leading language:

```
GOOD: "You need the exact total spent last month. Find it."
BAD : "Click Reports, then the 'Totals' tab, and tell me what it says."
```

2. **Prefer one live observation.** A colleague, a beta user, or a real
   customer walks the script while you watch silently. No steering — you may
   clarify the task, never the UI.
3. **Watch for five signals** and record timestamps or screens:

```
- Find time:    pauses before the target control is located
- Misreads:     wrong interpretation of a label or message
- Wrong click:  tries the wrong control first
- Workarounds:  does something convoluted to reach the goal
- Questions:    "what does this mean / what happens if…" out loud
```

4. **When no human is available, test cold and alone.** Do not read the code,
   do not remember the spec — open the built flow and execute the script.
   Every place you had to pause, guess, or look up is a finding; write it
   down instead of silently solving it.
5. **Triage findings by severity** and merge into the design critique's
   findings list (see `design/design-critique.md`):

```
[BLOCKER] task impossible or wrong result without assistance
[MAJOR ] significant delay or repeated error on a core step
[MINOR ] friction that doesn't block the goal
```

6. **Fix the top blocker, then re-run that one task** before anything ships.
   Record what was tested, what changed, and what's still open.

### 5. When the default doesn't apply

- **Explicit throwaway/demo scope** — the user confirmed a mock that only the
  happy path will be demoed; then skip observation, but state "not
  usability-tested" in the spec.
- **Hard constraint — no user reachable** (internal API, no beta access):
  the cold self-run is mandatory and marked as assumption-level evidence, with
  a revisit trigger, not silently dropped.
- **Agent-only internal UI** — the only "user" is the agent itself; the task
  script is run by the agent, which is both tester and author, and the gap is
  stated.

### 6. Red flags (stopgap smells specific to this file)

- "I tested it by clicking through myself" with no task script and no recorded
  findings — that's smoke-testing, not usability testing.
- A task script written in UI terms ("open the dropdown → click Save") that
  can only pass.
- Concluding "it's fine" because the happy path worked, with zero observation.
- Findings that died in the author's head — nothing written for the build to
  see.
- A flow shipped with a known [MAJOR] or [BLOCKER] finding and no ADR/TODO.
- The same script run by the author immediately after writing it (answers are
  still fresh).

### 7. If a shortcut is genuinely necessary

Never silent. Required output:

1. Name what's being deferred: e.g. "skipping live observation and shipping on
   the cold self-run alone."
2. Name the specific cost of not fixing it: e.g. "without a real observer, the
   assumptions the author is blind to ship untouched, and a wrong primary path
   shows up as support tickets after launch instead of a one-line fix now."
3. Write it into an ADR or a tracked TODO with an owner and a trigger: TODO
   "run live observation of the primary flow — owner: [name], trigger: beta
   access opens or first usage event shows < target completion rate."

### 8. Cross-references

- See also: `design/design-critique.md` — testing confirms or kills critique
  findings with evidence.
- See also: `design/ux-research.md` — the task script descends from the named
  user's job-to-be-done.
- See also: `design/interaction-design.md` — stumbles map to missing states or
  feedback, fixing the flow not just the copy.
- See also: `core/verification.md` — this file is the design-side of verifying
  the code actually works for a person.
- See also: `core/definition-of-done.md` — a flow isn't done until its
  blockers are cleared and recorded.
- See also: `quality/observability.md` — usage events re-validate the same
  assumptions after launch.
