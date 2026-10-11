---
target: abaplint
title: 'Report an inner LOOP/READ that reuses the work area or field symbol of the enclosing LOOP'
summary: '`LOOP AT lt_a INTO ls. LOOP AT lt_b INTO ls.` overwrites the outer row, and reusing the outer ASSIGNING field symbol redirects it - wrong data, or writes into the wrong table'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report an inner LOOP/READ that reuses the work area or field symbol of the enclosing LOOP

The outer loop body continues with a value the inner statement replaced.

```abap
LOOP AT lt_a INTO ls.
  LOOP AT lt_b INTO ls.
  ENDLOOP.
ENDLOOP.
```

**Proposal.** Report INTO/ASSIGNING targets of a LOOP or READ that equal the target of an enclosing LOOP.

**Not reported.** Targets of a loop that has already ended.

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** Ruff/Pylint PLW2901.
