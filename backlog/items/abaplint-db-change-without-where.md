---
target: abaplint
title: 'Report DELETE FROM dbtab and UPDATE dbtab SET without WHERE'
summary: 'a DELETE or UPDATE of a database table without WHERE changes every row of the client'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report DELETE FROM dbtab and UPDATE dbtab SET without WHERE

```abap
DELETE FROM ztab.
UPDATE ztab SET status = 'X'.
```

**Proposal.** Report DELETE FROM / UPDATE … SET on a database table without WHERE.

**Not reported.** DELETE ztab FROM TABLE / FROM wa (key-based); a pseudo comment for deliberate wipes.

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** Sonar S1139/S1496.
