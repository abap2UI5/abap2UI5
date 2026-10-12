---
target: abaplint
title: 'Report append-structure fields without ZZ/YY prefix'
summary: 'fields of an append to an SAP table should be named ZZ*/YY* so they never collide with fields SAP adds later'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'abapOpenChecks check 033 (larshp/abapOpenChecks docs/_checks/33.md)'
  - 'checked 2026-10-12 against the rule sources of abaplint main after v2.120.75 (an XML or cross-object check, not probed with a snippet): no rule decides it'
---

# Report append-structure fields without ZZ/YY prefix

```abap
APPEND structure ZAMARA on MARA with field MYFIELD
```

**Proposal.** Report TABL objects of type append (APPEND structure in the XML) whose field names do not start with ZZ or YY (configurable).

**Not reported.** Customer tables; includes.

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** abapOpenChecks check 033.
