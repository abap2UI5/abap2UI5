---
target: abaplint
title: 'Report dynamic SQL clauses built from input without cl_abap_dyn_prg'
summary: 'a dynamic WHERE, table or field list concatenated from an importing parameter or selection-screen input without escape/check is a Code Vulnerability Analyzer finding'
priority: low
state: filed
filed: https://github.com/abaplint/abaplint/issues/167
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'abaplint/abaplint#167 asks for it'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report dynamic SQL clauses built from input without cl_abap_dyn_prg

```abap
lv_where = |name = '{ iv_name }'|.
SELECT * FROM ztab WHERE (lv_where) INTO TABLE @lt.
```

**Proposal.** Report dynamic SQL tokens whose value flows from a parameter or PARAMETERS without cl_abap_dyn_prg=>escape_*/check_*.

**Not reported.** Constants; values from the code itself.

**Where.** a new rule (or an option of the closest existing one). **Effort:** L.

**Source.** Bandit S608; abaplint/abaplint#167.

An upstream request exists (https://github.com/abaplint/abaplint/issues/167); this item collects the case and the scope for a pull request.
