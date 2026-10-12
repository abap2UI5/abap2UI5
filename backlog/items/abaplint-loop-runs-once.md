---
target: abaplint
title: 'Report loops whose body ends with RETURN, EXIT or RAISE on every path'
summary: 'a loop that always leaves after the first pass is usually a misplaced RETURN'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report loops whose body ends with RETURN, EXIT or RAISE on every path

```abap
LOOP AT lt INTO ls.
  process( ls ).
  RETURN.
ENDLOOP.
```

**Proposal.** Report LOOP/DO/WHILE whose body ends with RETURN/EXIT/RAISE on every path.

**Not reported.** The read-first-row idiom LOOP … EXIT (option).

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** Sonar S1751; ESLint no-unreachable-loop.
