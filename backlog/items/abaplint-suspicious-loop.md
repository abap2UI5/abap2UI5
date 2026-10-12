---
target: abaplint
title: 'Suspicious loops: a body that always leaves, a WHILE condition the body never changes'
summary: 'a loop whose body ends with RETURN/EXIT/RAISE on every path runs once, and a WHILE whose condition variables the body never writes runs zero times or forever - both are loops that do not loop'
priority: medium
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
  - 'abap2UI5/abap2UI5 c4e9ac8 (''Fix endless LOOP'')'
  - 'abap2xlsx/abap2xlsx 11b47ec (#1044)'
---

# Suspicious loops: a body that always leaves, a WHILE condition the body never changes

Both look at a loop body as a whole; one rule, one option per check.

Merged on 2026-10-12 from the items `abaplint-loop-runs-once`, `abaplint-loop-condition-not-modified`.

## Report loops whose body ends with RETURN, EXIT or RAISE on every path

```abap
LOOP AT lt INTO ls.
  process( ls ).
  RETURN.
ENDLOOP.
```

**Proposal.** Report LOOP/DO/WHILE whose body ends with RETURN/EXIT/RAISE on every path.

**Not reported.** The read-first-row idiom LOOP … EXIT (option).

**Source.** Sonar S1751; ESLint no-unreachable-loop.

## Report WHILE loops whose condition variables are never written in the body

```abap
WHILE lv_i < 10.
  lv_j = lv_j + 1.
ENDWHILE.
```

**Proposal.** Report WHILE (and DO without TIMES) whose condition variables are not written in the body and that has no EXIT, RETURN or RAISE.

**Not reported.** sy-subrc conditions set by statements in the body; method calls that may change attributes (option).

**Source.** abap2UI5, abap2xlsx fix history; Clippy while_immutable_condition.

**Where.** a new rule, one option per check. **Effort:** M.
