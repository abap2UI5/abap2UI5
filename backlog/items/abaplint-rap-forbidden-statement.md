---
target: abaplint
title: 'Report COMMIT/ROLLBACK WORK, IN UPDATE TASK and SUBMIT in RAP behavior handlers and savers'
summary: 'these statements in a class inheriting from cl_abap_behavior_handler or cl_abap_behavior_saver are the runtime error BEHAVIOR_ILLEGAL_STATEMENT'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
  - 'relevant for abap2UI5/samples-stack''s RAP parts'
---

# Report COMMIT/ROLLBACK WORK, IN UPDATE TASK and SUBMIT in RAP behavior handlers and savers

```abap
METHOD save.
  COMMIT WORK.
ENDMETHOD.
```

**Proposal.** Report the listed statements in methods of classes inheriting from the two behavior classes.

**Not reported.** Other classes.

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** SAP RAP documentation (transactional contract).
