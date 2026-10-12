---
target: abaplint
title: 'Report AT NEW/END OF/FIRST/LAST inside LOOP … WHERE or FROM/TO'
summary: 'control levels are computed over all rows without the WHERE/FROM/TO restriction, so group breaks and totals in a restricted loop are wrong'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
  - 'ABAP keyword documentation, AT itab: group levels are determined without evaluating restricting conditions'
---

# Report AT NEW/END OF/FIRST/LAST inside LOOP … WHERE or FROM/TO

```abap
LOOP AT lt INTO ls WHERE b > 1.
  AT NEW a.
  ENDAT.
ENDLOOP.
```

**Proposal.** Report AT NEW/END OF/FIRST/LAST in a LOOP with WHERE, FROM or TO.

**Not reported.** Unrestricted loops.

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** ABAP keyword documentation.
