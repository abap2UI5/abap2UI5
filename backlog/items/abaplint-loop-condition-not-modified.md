---
target: abaplint
title: 'Report WHILE loops whose condition variables are never written in the body'
summary: 'a WHILE condition that nothing in the body changes, and no EXIT/RETURN/RAISE, is an endless loop - TIME_OUT'
priority: medium
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5/abap2UI5 c4e9ac8 (''Fix endless LOOP'')'
  - 'abap2xlsx/abap2xlsx 11b47ec (#1044)'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report WHILE loops whose condition variables are never written in the body

```abap
WHILE lv_i < 10.
  lv_j = lv_j + 1.
ENDWHILE.
```

**Proposal.** Report WHILE (and DO without TIMES) whose condition variables are not written in the body and that has no EXIT, RETURN or RAISE.

**Not reported.** sy-subrc conditions set by statements in the body; method calls that may change attributes (option).

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** abap2UI5, abap2xlsx fix history; Clippy while_immutable_condition.
