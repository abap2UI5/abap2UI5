---
target: abaplint
title: 'Report database writes, COMMIT, SUBMIT and RFC in FOR TESTING classes'
summary: 'tests that write to the database or commit change shared system data and are flaky; ATC reports them'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report database writes, COMMIT, SUBMIT and RFC in FOR TESTING classes

```abap
METHOD test_save.
  INSERT ztab FROM ls.
  COMMIT WORK.
ENDMETHOD.
```

**Proposal.** In FOR TESTING classes report INSERT/UPDATE/MODIFY/DELETE on database tables, COMMIT WORK, SUBMIT, CALL TRANSACTION, CALL FUNCTION … DESTINATION.

**Not reported.** Classes that set up cl_osql_test_environment or cl_cds_test_environment.

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.
