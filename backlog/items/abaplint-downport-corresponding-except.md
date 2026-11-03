---
target: abaplint
title: 'downport: CORRESPONDING #( ... EXCEPT ... ) becomes MOVE-CORRESPONDING ... EXCEPT'
summary: 'the EXCEPT addition of the CORRESPONDING operator is carried over into the MOVE-CORRESPONDING the downport writes, and MOVE-CORRESPONDING has no EXCEPT - the result does not parse at v702'
priority: medium
state: open
first_seen: 2026-11-02
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/sql-console, 2026-11-02 - `z2ui5_cl_sql_app_01=>history_db_read( )`, `CORRESPONDING #( lr_history->* EXCEPT result_data )`; rewritten as an assignment plus CLEAR so the 702 branch builds (branch claude/addon-repo-namespaces-dnjqev)'
  - 'probed 2026-11-02 with @abaplint/cli 2.120.92 - a single class, syntax v702, rules downport, parser_error, check_syntax, unknown_types; `abaplint --fix` then a lint run: `ls_b = CORRESPONDING #( ls_a EXCEPT value ).` -> `MOVE-CORRESPONDING ls_a EXCEPT value TO temp1.`, parser_error'
checked_upstream: 2026-11-02
---
# downport: CORRESPONDING #( ... EXCEPT ... ) writes an invalid MOVE-CORRESPONDING

```abap
ls_b = CORRESPONDING #( ls_a EXCEPT value ).
```

becomes

```abap
DATA temp1 TYPE z2ui5_t_06.
CLEAR temp1.
MOVE-CORRESPONDING ls_a EXCEPT value TO temp1.
ls_b = temp1.
```

`MOVE-CORRESPONDING` has no `EXCEPT`: `parser_error` at v702.

**Expected.** Move everything, then restore the excepted components of the
target. For a fresh temporary the excepted ones are simply initial:

```abap
MOVE-CORRESPONDING ls_a TO temp1.
CLEAR temp1-value.
```

With a `BASE` the excepted components take the base value instead
(`temp1-value = base-value`). `EXCEPT *` combined with a MAPPING is the case
that needs per-component assignments.
