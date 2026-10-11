---
target: abaplint
title: 'Report CATCH of an exception nothing in the TRY can raise'
summary: 'a CATCH for a class no statement in the TRY can raise is dead code and usually a mistaken assumption about the callee'
priority: low
state: filed
filed: https://github.com/abaplint/abaplint/issues/1612
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'abaplint/abaplint#1612 and #3326 ask for it'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report CATCH of an exception nothing in the TRY can raise

```abap
TRY.
    lv = 1 + 1.
  CATCH zcx_not_found.
ENDTRY.
```

**Proposal.** With the RAISING clauses of the called methods, report CATCH classes none of them can raise.

**Not reported.** cx_root, cx_no_check and dynamic calls.

**Where.** a new rule (or an option of the closest existing one). **Effort:** L.

**Source.** abaplint/abaplint#1612, #3326.

An upstream request exists (https://github.com/abaplint/abaplint/issues/1612); this item collects the case and the scope for a pull request.
