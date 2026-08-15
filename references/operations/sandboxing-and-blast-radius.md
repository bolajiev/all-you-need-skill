## Sandboxing and Blast Radius

**Applies to:** any task where the agent executes code, runs commands, or performs actions with side effects — especially untrusted input, network access, or anything that could affect systems beyond the immediate task.

**Tier:** reference

---

### 1. Rule

Run anything that can have side effects inside the least-privileged, most-isolated container the environment allows, with network egress limited to what the task actually needs — so a failure or malicious input can only damage the smallest possible surface.

### 2. Why this matters (long-term cost of getting it wrong)

- One unconstrained command with bad input can modify production state, exfiltrate data, or leave a backdoor that is far more expensive to find than to have prevented.
- Network egress without limits is the channel through which stolen credentials and data leave — the sandbox is the last gate before the outside world.
- A failure inside an unrestricted environment corrupts shared state that other work depends on, turning a single bug into a multi-task outage.
- Without isolation, "it works locally" teaches nothing about whether it is safe to run, and every future task inherits the risk.

### 3. Decision checklist

- [ ] Can this action have side effects outside the current task (writes, network, system calls)?
- [ ] Does the action need network access, and is that access limited to the specific hosts/ports it needs?
- [ ] Am I running with the minimum privileges, or with credentials the task doesn't require?
- [ ] Is the execution environment ephemeral, or could it persist state that leaks into other tasks?
- [ ] Is the input trusted, or could it be attacker-controlled (files, URLs, API responses)?

### 4. Default pattern

```
1. Prefer ephemeral containers (e.g. docker run --rm, a fresh sandbox)
   over the host shell for anything with side effects.
2. Drop privileges: least-privilege user, read-only mounts where
   possible, no host-network binding.
3. Enforce network egress policy: default-deny, allowlist only the
   hosts/ports the task needs (e.g. the API being integrated, not the
   whole internet).
4. Treat any untrusted input (downloads, user files, fetched content)
   as potentially malicious: execute it only in isolation, never in
   the main environment.
5. Give the sandbox a bounded lifetime — it must be torn down and its
   state discarded when the task completes.
```

- The blast radius limit is a feature of the environment, not the agent's care: design so that a worst-case failure is contained even if the agent behaves badly.
- For destructive or money-touching actions, sandboxing is necessary but not sufficient — see `monitoring-and-alerting.md` and `core/permission-boundaries.md`.

### 5. When the default doesn't apply

- **The action is provably read-only and side-effect-free** (pure computation, local text processing with no network): direct execution is fine, still under a timeout.
- **The environment itself is already a disposable sandbox** with no shared or external state: additional nesting adds nothing.
- **A real hard constraint** (no container runtime available): then use the most restrictive native equivalent — temp working directory, dedicated user, explicit `--` bounds on commands, timeout, and no host-visible state.

### 6. Red flags (stopgap smells specific to this file)

- Running an untrusted file or downloaded artifact on the host shell.
- Commands without timeouts that can hang or retry forever.
- Opening network access to "whatever it needs" instead of an allowlist.
- Reusing one environment across multiple tasks so state leaks between them.
- Running with admin/root credentials when the task only needs a user.
- "It's just a read" for something that can trigger hooks, webhooks, or auto-run code.

### 7. If a shortcut is genuinely necessary

1. Name what's being deferred: e.g. "running this outside a container because none is available."
2. Name the specific cost: a failure or malicious input can touch host or shared state; say what breaks (the host environment, other tasks, a leak).
3. Write it into an ADR or a tracked TODO with an owner and a trigger (e.g. "run in a container as soon as the runtime exists; owner = [x], trigger = container runtime available"). No silent exceptions.

### 8. Cross-references

- See also: `monitoring-and-alerting.md` — sandboxed actions still get logged and alerted.
- Escalates to: `core/permission-boundaries.md` when the action is destructive, sensitive, or needs privileges.
- See also: `incident-response.md` — containment options come from the sandbox.
- See also: `secrets-handling.md` — never give the sandbox credentials it doesn't need.
