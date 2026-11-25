---
target: abaplint
title: 'strict_sql: BYPASSING BUFFER in front of a trailing INTO is not reported'
summary: 'in the strict form (INTO last) the ABAP options follow INTO; SELECT * FROM (t) BYPASSING BUFFER ORDER BY PRIMARY KEY INTO ... does not activate on a system, strict_sql and check_syntax stay silent'
priority: medium
state: open
first_seen: 2026-11-25
checked_upstream: 2026-11-25
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/table-maintenance d112ba0 (z2ui5_cl_tm_001 get_data and get_db_rows): SELECT * FROM (mv_table) BYPASSING BUFFER ORDER BY PRIMARY KEY INTO CORRESPONDING FIELDS OF TABLE @<table>. - activation on a system (2026-11-25): "The addition BYPASSING BUFFER must only be placed after the INTO/APPENDING clause." (error), the repository lint with strict_sql on reported nothing; fixed in a5e6938 (BYPASSING BUFFER after INTO)'
  - 'probed 2026-11-25 against abaplint 2.120.113, strict_sql + check_syntax + parser_error on, open-abap-core as dependency, syntax v757: the statement above gives no finding while a control SELECT ... INTO ... WHERE in the same class gives "INTO/APPENDING must be last in strict SQL"'
  - 'upstream search 2026-11-25: nothing on the position of the ABAP options; #4683 (open) is another strict-SQL gap (INTO before WHERE with an SQL expression)'
---

# strict_sql: BYPASSING BUFFER in front of a trailing INTO is not reported

```abap
SELECT *
  FROM (iv_table) BYPASSING BUFFER          " system: error - must follow INTO
  ORDER BY PRIMARY KEY
  INTO CORRESPONDING FIELDS OF TABLE @lt_any.

SELECT *
  FROM (iv_table)
  ORDER BY PRIMARY KEY
  INTO CORRESPONDING FIELDS OF TABLE @lt_any
  BYPASSING BUFFER.                         " accepted
```

## Motivation

In the strict form of ABAP SQL - the INTO clause written last - the ABAP
options (`BYPASSING BUFFER`, `CONNECTION`, `UP TO n ROWS` in its old place)
belong behind `INTO` / `APPENDING`. In the old position, directly after the
data source, the statement does not activate. abaplint parses it and
`strict_sql`, which already checks that INTO comes last, does not look at the
options.

## Current behaviour

`strict_sql` reports an INTO that is not last, but not an ABAP option placed
in front of a trailing INTO. `check_syntax` accepts the statement.

## Proposal

`strict_sql` (or `check_syntax` for the strict form) reports `BYPASSING
BUFFER` and the other ABAP options when the statement's INTO is last and the
option is not behind it.
