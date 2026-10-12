---
target: abaplint
title: 'Report SQL wildcards in CP/NP and ABAP wildcards in SQL LIKE'
summary: '`IF lv CP ''ABC%''` never matches, and `WHERE name LIKE ''A*''` matches a literal asterisk - the wildcard of the other language'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report SQL wildcards in CP/NP and ABAP wildcards in SQL LIKE

CP knows * and +, SQL LIKE knows % and _.

```abap
IF lv CP 'ABC%'.
SELECT * FROM t INTO TABLE @lt WHERE name LIKE 'A*'.
```

**Proposal.** Report % or _ in a CP/NP literal and * or + in a LIKE literal.

**Not reported.** Escaped characters; dynamic patterns.

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.
