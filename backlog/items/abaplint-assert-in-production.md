---
target: abaplint
title: 'Report ASSERT in non-test code (configurable)'
summary: 'ASSERT gives the uncatchable ASSERTION_FAILED dump; `ASSERT sy-subrc = 0` and `ASSERT 1 = 0` under WHEN OTHERS are the shapes users report'
priority: medium
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'about 20 fix commits replace ASSERT by exceptions, e.g. abapGit 0a67f95, 01b8554, ef2b90c, 41b301c; abapOpenChecks 4408fc3, 10d2360; abap2UI5 1e4c2a4 (an ASSERT on the request path bypassed the outer TRY)'
  - 'over 1,000 ASSERTs in non-test code across the corpus - so the rule needs options'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report ASSERT in non-test code (configurable)

```abap
WHEN OTHERS.
  ASSERT 1 = 0.
```

**Proposal.** Options: subrc (ASSERT sy-subrc …), false (ASSERT with a constant false condition), all. Default the narrow ones.

**Not reported.** Test classes; ASSERT ID … (checkpoint groups).

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** abapGit, abapOpenChecks, abap2UI5 fix history.
