---
target: abaplint
title: 'Report identical code blocks (copy-paste detection)'
summary: 'abapOpenChecks finds repeated sequences of statements across methods; copies drift apart and get fixed in one place only'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'abapOpenChecks check 024 (larshp/abapOpenChecks docs/_checks/24.md)'
  - 'checked 2026-10-12 against the rule sources of abaplint main after v2.120.75 (an XML or cross-object check, not probed with a snippet): no rule decides it'
---

# Report identical code blocks (copy-paste detection)

```abap
the same 15 statements in two methods
```

**Proposal.** Report token-identical (after normalising names, option) sequences of at least N statements across the repository.

**Not reported.** Generated code; test classes (option).

**Where.** a new rule (or an option of the closest existing one). **Effort:** L.

**Source.** abapOpenChecks check 024.
