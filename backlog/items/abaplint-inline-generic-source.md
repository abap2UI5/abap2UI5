---
target: abaplint
title: 'Report DATA( ) declared from a generically typed source'
summary: '`DATA(lv) = iv` with iv TYPE clike/csequence/any makes the system fix the type ("the fixed type STRING is used for the generic type CLIKE") and SLIN reports it'
priority: medium
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'a user''s system reported z2ui5_cl_ui5_util_context=>url_param_get_tab (2026-09-02); abap-check §3'
  - '4 sites in abap2UI5 src'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report DATA( ) declared from a generically typed source

```abap
METHOD m.  " IMPORTING iv TYPE clike
  DATA(lv) = iv.
```

**Proposal.** Report an inline DATA( ) whose source is a parameter or variable of a generic type.

**Not reported.** CONV string( iv ), which fixes the type deliberately.

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** abap2UI5 abap-check §3.
