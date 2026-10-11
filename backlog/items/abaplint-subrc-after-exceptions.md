---
target: abaplint
title: 'Report CALL FUNCTION/METHOD with EXCEPTIONS whose sy-subrc is not read'
summary: 'the EXCEPTIONS mapping is only useful if sy-subrc is evaluated before the next statement that sets it; otherwise the error is swallowed (SLIN reports it)'
priority: low
state: filed
filed: https://github.com/abaplint/abaplint/issues/391
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'abaplint/abaplint#391 (''todo: CALL FUNCTION'' for check_subrc)'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report CALL FUNCTION/METHOD with EXCEPTIONS whose sy-subrc is not read

```abap
CALL FUNCTION 'Z_X' EXCEPTIONS not_found = 1 OTHERS = 2.
lv = 1.
```

**Proposal.** Option of check_subrc: report CALL FUNCTION / CALL METHOD with EXCEPTIONS not followed by a sy-subrc read.

**Not reported.** Calls whose EXCEPTIONS map everything to 0 (separate item).

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** abapOpenChecks 40; Sonar S1511.

An upstream request exists (https://github.com/abaplint/abaplint/issues/391); this item collects the case and the scope for a pull request.
