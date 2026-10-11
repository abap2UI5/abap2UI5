---
target: abaplint
title: 'check_syntax: the table a LOOP walks is cleared, sorted or reassigned inside it'
summary: 'inside a class, CLEAR/FREE/REFRESH/SORT/DELETE … WHERE or an assignment to the table of the enclosing LOOP AT is a syntax error when it is known statically, and TABLE_FREE_IN_LOOP at runtime otherwise'
priority: medium
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
  - 'ABAP keyword documentation, LOOP AT itab: the table may not be replaced or freed inside the loop - syntax error in classes when known statically'
---

# check_syntax: the table a LOOP walks is cleared, sorted or reassigned inside it

The loop's table is replaced or freed while the loop walks it. In a class the system refuses the method if the statement is statically known; elsewhere it is the runtime error TABLE_FREE_IN_LOOP.

```abap
LOOP AT mt_rows INTO DATA(ls_row).
  CLEAR mt_rows.          " or SORT mt_rows. / mt_rows = VALUE #( ).
ENDLOOP.
```

**Proposal.** Report CLEAR, FREE, REFRESH, SORT, DELETE … WHERE (without INDEX) and a whole-table assignment to the table named by an enclosing LOOP AT, in class methods as a syntax error.

**Not reported.** DELETE itab (current row) and MODIFY itab inside the loop, which ABAP allows; a different table of the same name in another scope; access through a reference (that is runtime only).

**Where.** an extension of `check_syntax` - the system refuses the code at activation, so it belongs with the syntax check, not in a separate rule. **Effort:** S.

**Source.** ABAP keyword documentation (LOOP AT itab); Java ConcurrentModificationException, Clippy/SpotBugs loop-mutation lints.
