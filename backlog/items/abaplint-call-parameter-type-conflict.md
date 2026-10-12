---
target: abaplint
title: 'Report actual parameters incompatible with a function module''s formal parameter'
summary: 'string passed to a CHAR formal, the wrong length - CALL_FUNCTION_CONFLICT_TYPE / CX_SY_DYN_CALL_ILLEGAL_TYPE at runtime'
priority: medium
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'abapGit/abapGit 7ecea07 (#5906, 702), 68ec17a (#3686), 9a85ff4 (#6272), 18cf907 (#7162); abap2UI5/abap2UI5 04958e0 (#1083)'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report actual parameters incompatible with a function module's formal parameter

```abap
CALL FUNCTION 'Z_SET' EXPORTING iv_name = lv_string.   " formal TYPE char30
```

**Proposal.** With function module signatures from the DDIC dependencies, report incompatible actual parameters.

**Not reported.** Generic formals.

**Where.** a new rule (or an option of the closest existing one). **Effort:** L.

**Source.** abapGit, abap2UI5 fix history.
