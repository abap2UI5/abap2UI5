---
target: abaplint
title: 'downport: a table expression in a short-circuited condition is read before the IF - the guard in front of it no longer protects it'
summary: 'in `IF lv_last > 0 AND lt[ lv_last ] = x.` the downport outlines `lt[ lv_last ]` into a READ TABLE with the CX_SY_ITAB_LINE_NOT_FOUND raise in front of the IF, so it runs even when `lv_last > 0` is false - ABAP evaluates AND and OR left to right and stops early, the downported code does not; with lv_last = 0 the 702 code raises where the original never reads the table, and nothing reports it'
priority: high
state: open
first_seen: 2026-11-03
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/sql-console, 2026-11-03 - `z2ui5_cl_sql_query=>join_order_by( )`: `IF lv_last > 0 AND ( lr_token->* = `ASCENDING` OR ... OR ( lr_token->* = `KEY` AND lt_item[ lv_last ] = `PRIMARY` ) ).` - the first token of every ORDER BY reaches it with lv_last = 0; transpiled from the downported source the unit tests parse_all_clauses and parse_order_by_descending fail with ASSERTION_FAILED (the syfixes form of the raise), and a 7.02 system would dump the same way'
  - 'probed 2026-11-03 with @abaplint/cli 2.120.92 - a single class, syntax v702, rules downport, parser_error, check_syntax, unknown_types; `abaplint --fix` then a lint run: `IF lv_last > 0 AND lt_item[ lv_last ] = iv_text.` becomes `READ TABLE lt_item INDEX lv_last ASSIGNING <temp1>. ... IF sy-subrc <> 0. RAISE EXCEPTION TYPE cx_sy_itab_line_not_found. ENDIF. IF lv_last > 0 AND <temp1> = iv_text.` - 0 issues'
checked_upstream: 2026-11-03
---
# downport: a table expression in a short-circuited condition is read before the IF

ABAP evaluates the operands of `AND` and `OR` left to right and stops as soon
as the result is known, so a condition can guard a table expression:

```abap
DATA(lv_last) = lines( lt_item ).
IF lv_last > 0 AND lt_item[ lv_last ] = iv_text.
  rv_ok = abap_true.
ENDIF.
```

The downport outlines the table expression in front of the statement:

```abap
READ TABLE lt_item INDEX lv_last ASSIGNING <temp1>.
IF sy-subrc <> 0.
  RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
ENDIF.
IF lv_last > 0 AND <temp1> = iv_text.
```

The read now happens unconditionally. With an empty table the original skips
the IF, the downported code raises `CX_SY_ITAB_LINE_NOT_FOUND` - a behaviour
change, not a syntax error, so neither the downport nor the 7.02 lint reports
anything.

**Expected.** A table expression that is not in the first operand of an
`AND` / `OR` chain is read only when the operands before it let the
evaluation reach it - for example by splitting the condition into nested IFs,
or by reading it without the raise (`READ TABLE ... ` and comparing only when
`sy-subrc = 0`), the shape the downport already uses for
`VALUE #( itab[ ... ] OPTIONAL )`.

**Workaround.** `VALUE #( lt_item[ lv_last ] OPTIONAL )` in such a position,
or `line_exists( )` in front of the comparison as a nested IF.

Related: the same outlining applies to the WHILE condition and to `COND` /
`SWITCH` branches; worth checking with the same probe.
