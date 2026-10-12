---
target: abaplint
title: 'check_syntax: a write to a key component of a sorted or hashed line through a field symbol'
summary: 'the key components of a line of a sorted or hashed table are write-protected; `<line>-key = …` after LOOP/READ … ASSIGNING is a syntax error when known statically - the direct-write sibling of changing_sorted_line'
priority: medium
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
  - 'ABAP keyword documentation: key fields of sorted/hashed tables are read-only; abaplint/abaplint#4420 (changing_sorted_line) covers the CHANGING-parameter form only'
---

# check_syntax: a write to a key component of a sorted or hashed line through a field symbol

Writing a key field would break the table's order or hash.

```abap
LOOP AT lt_sorted ASSIGNING FIELD-SYMBOL(<ls>).
  <ls>-id = 'X'.        " id is the primary key
ENDLOOP.
```

**Proposal.** Report an assignment, CLEAR or CHANGING argument whose target is a primary-key component reached through a field symbol or data reference bound to a line of a statically sorted or hashed table.

**Not reported.** Non-key components; standard tables; generic tables.

**Where.** an extension of `check_syntax` - the system refuses the code at activation, so it belongs with the syntax check, not in a separate rule. **Effort:** M.

**Source.** ABAP keyword documentation; extends abaplint/abaplint#4420.
