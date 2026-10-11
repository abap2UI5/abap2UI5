---
target: abaplint
title: 'check_syntax: APPEND to a hashed table'
summary: 'APPEND to a HASHED table is a syntax error; check_syntax reports INSERT/MODIFY/DELETE … INDEX and LOOP FROM on hashed tables but not APPEND (5_syntax/statements/append.ts does not look at the table kind)'
priority: medium
state: filed
filed: https://github.com/abaplint/abaplint/issues/3041
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
  - 'abaplint/abaplint#3041 asks for the sorted/hashed misuses; the APPEND case is the one check_syntax still lets through'
---

# check_syntax: APPEND to a hashed table

A hashed table has no index, so APPEND - which adds at the end - does not exist for it.

```abap
DATA lt_map TYPE HASHED TABLE OF ty_s WITH UNIQUE KEY id.
APPEND ls TO lt_map.
```

**Proposal.** Report APPEND whose target is statically a HASHED table.

**Not reported.** Generic tables (ANY TABLE, INDEX TABLE is fine), SORTED tables (APPEND there is legal, the order check is runtime).

**Where.** an extension of `check_syntax` - the system refuses the code at activation, so it belongs with the syntax check, not in a separate rule. **Effort:** S.

**Source.** found while probing the other-linter list; abaplint/abaplint#3041.

An upstream request exists (https://github.com/abaplint/abaplint/issues/3041); this item collects the case and the scope for a pull request.
