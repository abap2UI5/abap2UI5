---
target: abaplint
title: 'check_syntax: LOOP … USING KEY <sorted secondary key> WHERE with a key component under OR or CP'
summary: 'a key component of a sorted secondary key inside OR or CP (or with an extra NOT … IS INITIAL) in LOOP … USING KEY … WHERE is a syntax error on 7.54; the merged top-level-OR check (#4353) does not reach the nested shapes'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'abapGit/abapGit b45a496 (#7172, two sites)'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
  - 'which connective the system refuses exactly still has to be measured on a system before filing'
---

# check_syntax: LOOP … USING KEY <sorted secondary key> WHERE with a key component under OR or CP

The secondary key has to be usable for the WHERE; the system refuses conditions on its components that it cannot turn into a key access.

```abap
LOOP AT lt USING KEY by_name INTO DATA(ls) WHERE ( name = 'A' OR name = 'B' ) AND flag = abap_true.
```

**Proposal.** Report a component of the used sorted secondary key that appears under OR, with CP, or negated, in the WHERE.

**Not reported.** Non-key components; hashed secondary keys (different rule).

**Where.** an extension of `check_syntax` - the system refuses the code at activation, so it belongs with the syntax check, not in a separate rule. **Effort:** M.

**Source.** abapGit fix history; extends abaplint/abaplint#4353.
