---
target: abaplint
title: 'Report the LOOP''s field symbol or work area read after ENDLOOP'
summary: 'after the loop <fs> is unassigned when the table was empty (GETWA_NOT_ASSIGNED) and points to the last row otherwise - silently changing it'
priority: medium
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'abapGit/abapGit d68e4e6 (#2157, dump)'
  - '15 sites in current trees, one a real risk: abap2xlsx src/not_cloud/zcl_excel_converter.clas.abap:1470 reads <fs_sfcat>-totals_function after its loop'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report the LOOP's field symbol or work area read after ENDLOOP

```abap
LOOP AT lt ASSIGNING FIELD-SYMBOL(<r>).
ENDLOOP.
<r>-flag = abap_true.
```

**Proposal.** Report a read of the LOOP's ASSIGNING field symbol (or INTO work area) after ENDLOOP before it is reassigned or guarded by IS ASSIGNED.

**Not reported.** Use guarded by a flag set inside the loop (option).

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** abapGit fix history; Pylint W0631.
