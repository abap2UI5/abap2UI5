---
target: abaplint
title: 'Report method parameters no caller supplies'
summary: 'an OPTIONAL importing parameter no caller in the repository ever supplies, or a RETURNING no caller uses, is dead interface'
priority: low
state: filed
filed: https://github.com/abaplint/abaplint/issues/2066
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'abaplint/abaplint#2066 asks for it'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report method parameters no caller supplies

```abap
METHODS read IMPORTING iv_id TYPE string iv_unused TYPE string OPTIONAL.
```

**Proposal.** Across the repository, report parameters of non-public or non-released methods that no call supplies.

**Not reported.** Public API of released/shared classes (option).

**Where.** a new rule (or an option of the closest existing one). **Effort:** L.

**Source.** abaplint/abaplint#2066.

An upstream request exists (https://github.com/abaplint/abaplint/issues/2066); this item collects the case and the scope for a pull request.
