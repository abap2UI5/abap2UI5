---
target: abaplint
title: 'Report RAISE EXCEPTION inside CATCH … INTO x that does not pass previous = x'
summary: 'the root cause is dropped from the exception chain and production errors become hard to trace'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report RAISE EXCEPTION inside CATCH … INTO x that does not pass previous = x

```abap
CATCH cx_sy_conversion_error INTO DATA(lx).
  RAISE EXCEPTION NEW zcx_error( ).
```

**Proposal.** Report RAISE EXCEPTION/NEW in a CATCH … INTO block that does not supply previous with the caught variable.

**Not reported.** Re-raising the caught object itself (catch_and_raise).

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** Pylint raise-missing-from (W0707).
