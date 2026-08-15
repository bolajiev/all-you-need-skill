## Incident Response

**Applies to:** any moment during a task or in production where something breaks — an action failed, state is inconsistent, a service is down, or an anomaly is detected that the agent did not cause and cannot fully explain.

**Tier:** reference

---

### 1. Rule

When something breaks, stop changing things first: contain the damage, preserve the evidence, then diagnose. Report to a human before taking any additional irreversible action, and never let the investigation itself grow the blast radius.

### 2. Why this matters (long-term cost of getting it wrong)

- Continuing to act during an incident can turn a small failure into a data-loss or security event, because each new action runs against a system you no longer understand.
- Destroying evidence (overwriting logs, mutating state) while trying to "fix" things makes the root cause permanently undiscoverable.
- A silent self-recovery ("I think it's fine now") robs the human of the decision about whether to trust the system — the next failure gets no context.
- No defined escalation means the agent spends its own retry budget on a problem it was never going to solve, while the user waits.

### 3. Decision checklist

- [ ] Is anything still actively failing or propagating (retries, loops, cascading effects)?
- [ ] Can I contain this without taking an irreversible action (delete, overwrite, rollback that itself could fail)?
- [ ] Have I preserved the evidence (logs, state, action history) as-is?
- [ ] Do I understand the cause, or am I guessing?
- [ ] Does this need a human now, and who is the right escalation target?

### 4. Default pattern

Follow this order; do not skip ahead to "fixing."

```
1. STOP new actions. Pause retries and any pending autonomous work.
2. CONTAIN the damage: freeze the affected path, block further writes
   or requests if needed — prefer reversible containment over fixes.
3. PRESERVE evidence: copy logs, snapshots, and state before touching
   anything. Never edit a log to fix it.
4. ASSESS severity and scope: what is affected, how badly, who/ what
   else depends on it.
5. REPORT: give the human {what broke, current impact, what I've done,
   what I recommend next}. If it's money, credentials, data loss, or
   a security concern, report immediately — don't wait for diagnosis.
6. DIAGNOSE only after containment and reporting, using preserved
   evidence. Propose a fix and get sign-off before running it if the
   fix is irreversible or broad.
7. After resolution, record the timeline in the audit trail and a
   post-incident note (what failed, why, what changed to prevent it).
```

- Timebox diagnosis: if you can't explain the cause within a short window, escalate with what you know instead of guessing.
- Never mark the task "done" or "recovered" based on a self-report; the human confirms recovery.

### 5. When the default doesn't apply

- **The break is contained and provably benign** (a local sandbox failure with no external effects): handle it inline, still log it.
- **A human explicitly told the agent to keep going through the failure** with a defined fallback — explicit user scope overrides the pause, but reporting still happens.
- **The fix is trivial, reversible, and within the task's normal scope** (e.g. a typo in a config the agent just wrote): correct it and note it, rather than opening a full incident.

### 6. Red flags (stopgap smells specific to this file)

- Retrying the same failing action without pausing to understand it.
- Cleaning up / deleting evidence while "tidying up" after a failure.
- Declaring "it recovered" without any human confirmation or evidence.
- A fix that is the first thing that came to mind rather than the one the evidence supports.
- Escalating only after exhausting all guesses, instead of reporting at the containment point.

### 7. If a shortcut is genuinely necessary

1. Name what's being deferred: e.g. "reporting before diagnosis; I will diagnose first."
2. Name the specific cost: a wrong guess may act on an unstable system and destroy evidence; say what breaks (root-cause discovery, trust in the fix).
3. Write it into an ADR or a tracked TODO with an owner and a trigger (e.g. "conduct post-incident review; owner = [x], trigger = incident resolved"). No silent exceptions.

### 8. Cross-references

- See also: `monitoring-and-alerting.md` — the alerts that trigger this file.
- See also: `audit-trail.md` — evidence preservation and the post-incident timeline.
- Escalates to: `references/agent-state/escalation-triggers.md` when a human must take over.
- See also: `core/failure-recovery.md` for resuming after containment.
- See also: `sandboxing-and-blast-radius.md` for why containment options must exist.
