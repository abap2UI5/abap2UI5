---
target: abaplint
title: 'Report an index read itab[ 1 ] / itab[ lines( itab ) ] on a table filled by SPLIT, without a guard'
summary: 'SPLIT of an empty string gives an empty table, so lt[ 1 ] directly after it raises CX_SY_ITAB_LINE_NOT_FOUND on empty input - three such fixes in one week, after READ TABLE was replaced by table expressions across the repositories'
priority: low
state: open
first_seen: 2026-11-27
upstream: abaplint/abaplint
evidence:
  - 'abap-util/abap-util 3235c85, 2026-11: itab_get_itab_by_csv "failed on an empty input" - SPLIT val AT newline INTO TABLE DATA(lt_rows). SPLIT lt_rows[ 1 ] AT `;` INTO TABLE DATA(lt_cols).; file_get_mimetype "on an empty name" - SPLIT lv_name AT `.` INTO TABLE DATA(lt_parts). DATA(lv_ext) = lt_parts[ lines( lt_parts ) ].'
  - 'abap2UI5/samples-stack 7538290, 2026-11: an IF t_result IS INITIAL guard was added in front of t_result[ 1 ] when READ TABLE was replaced'
  - 'abaplint rules folder 2026-11-27: invalid_table_index reports the constant index 0 only, uncaught_exception handles static exceptions only'
---

# An index read on a table that can be empty

```abap
SPLIT val AT cl_abap_char_utilities=>newline INTO TABLE DATA(lt_rows).
SPLIT lt_rows[ 1 ] AT `;` INTO TABLE DATA(lt_cols).     " empty val: dump
```

A table expression raises `CX_SY_ITAB_LINE_NOT_FOUND` where
`READ TABLE ... INDEX 1` set sy-subrc. After `SPLIT ... INTO TABLE` the table
is empty exactly when the input was - the case nobody tests.

## Proposal (first step)

Report a table expression with a numeric index (`[ 1 ]`,
`[ lines( itab ) ]`) on a local table filled by `SPLIT ... INTO TABLE`, when
nothing between the two statements shows the table is not empty.

## Must not report

`OPTIONAL` / `DEFAULT`; the expression inside `line_exists( )` or
`line_index( )`; `ASSIGN itab[ ... ] TO`; inside a `TRY` that catches
`cx_sy_itab_line_not_found` or a superclass; after `IF itab IS [NOT] INITIAL`,
`lines( itab ) > 0` or `line_exists( )` on the same table; inside
`LOOP AT` that table.

The guard detection decides whether the rule is usable - a probe over the
abap2UI5 repositories should come before the pull request.
