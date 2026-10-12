---
target: abaplint
title: 'Use FINAL( ) for inline declarations that are never changed'
summary: 'an inline declaration that is assigned once can be FINAL( ) from 7.57 on; abaplint has no finding for it'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on: no rule reports it'
---

# Use FINAL( ) for inline declarations that are never changed

```abap
DATA(lv_name) = to_upper( iv_name ).
rv = lv_name.
```

Instead:

```abap
FINAL(lv_name) = to_upper( iv_name ).
```

**Proposal.** From v757 on, report DATA( ) inline declarations whose variable is not written again in the method; quick fix to FINAL( ).

**Not reported.** Below v757; variables passed as CHANGING/EXPORTING or to field-symbol assignments.

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.
