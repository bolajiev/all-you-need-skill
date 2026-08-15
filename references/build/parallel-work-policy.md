## Parallel Work Policy

**Applies to:** any task that considers fanning out work — subagents, concurrent commands, parallel tool calls — or choosing to serialize instead.

**Tier:** reference

---

### 1. Rule

Parallelize only when the work units are genuinely independent: no shared files, no dependency on each other's outputs, no racing writes. When in doubt, serialize. Each parallel unit must still produce a result that would be valid if it ran alone.

### 2. Why this matters (long-term cost of getting it wrong)

- Parallel work on shared files produces lost updates and corruption that is expensive and non-obvious to repair.
- Dependent tasks launched in parallel waste effort, since half of them operate on stale inputs and must be redone.
- Uncontrolled fan-out multiplies side effects (installs, writes, network calls) far beyond what the allowlist or user approved.

### 3. Decision checklist

- [ ] Do the work units touch disjoint files, directories, or resources?
- [ ] Does either unit depend on the output of the other?
- [ ] Could running them concurrently produce a different result than running them sequentially?
- [ ] Is the aggregate side-effect surface (installs, writes, network) one I'd be comfortable approving?
- [ ] Would combining them into one unit be simpler than coordinating them?

### 4. Default pattern

1. Test the independence test explicitly: if unit A's output could change unit B's behavior, serialize.
2. For read-only exploration or research — parallelize freely (multiple greps, independent file reads, independent searches).
3. For any write — default to serialize unless the writes are provably to disjoint paths.
4. When parallelizing with subagents, give each a fully self-contained brief: its own scope, its own verify step, and a defined deliverable. Do not ask subagents to coordinate with each other — coordinate only through the parent.
5. Bound the fan-out: prefer a small number of parallel units over "everything at once," and gate the fan-out on a completed planning step.

```
parallel:  [ read-only research across disjoint areas ]
  subagent A -> investigate module X (read-only)
  subagent B -> investigate module Y (read-only)
serial:     [ then, single-threaded, apply the plan from A+B ]
  edit X, edit Y, build, test
```

### 5. When the default doesn't apply

- User explicitly asks for parallel execution even at some risk, with the hazard stated back to them.
- The work is bulk processing of many isolated inputs (batch transforms of disjoint files) where the tooling itself guarantees disjointness — verify that guarantee before trusting it.
- Independent read-only research where latency, not correctness, is the only thing parallelism changes.

### 6. Red flags (stopgap smells specific to this file)

- Parallelizing to "save time" without having run the independence test.
- Multiple units writing to the same file, lockfile, or directory.
- A subagent brief that says "coordinate with the other agent" — coordination should flow through the parent.
- Fan-out before the plan exists, so parallel units each guess at scope.
- Results that change meaning when run together vs. apart.

### 7. If a shortcut is genuinely necessary

Never silent. Required output:
1. Name what's being deferred — e.g., "a serialized, ordered execution that guarantees no racing writes."
2. Name the specific cost — e.g., "concurrent writes may corrupt shared state, and re-running the lost work can be more expensive than the time saved."
3. Write it into an ADR or a tracked TODO with an owner and a trigger (e.g., "re-verify the touched files' integrity before the work is merged").

### 8. Cross-references

- See also: `core/agent-loop.md` for how subagent results get collected and validated before continuing.
- See also: `references/build/tool-use-policy.md` for the side-effect budget that parallel fan-out multiplies.
- See also: `references/quality/self-critique-loop.md` for verifying that parallel units stayed independent before declaring done.
