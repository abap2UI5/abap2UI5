---
target: abaplint
title: 'SELECT FROM @itab: an unknown column in ORDER BY is not reported'
summary: 'SELECT * FROM @lt_ordim_o AS t ORDER BY lgnum, tanum, tapos - /SCWM/ORDIM_O has no TAPOS; the system refuses "Unknown column name TAPOS", check_syntax accepts it'
priority: medium
state: filed
filed: https://github.com/oblomov-dev/fork-abaplint/pull/5
first_seen: 2026-11-25
checked_upstream: 2026-11-25
upstream: abaplint/abaplint
evidence:
  - 'a downstream app repository, review of 2026-11: an ORDER BY added for select_add_order_by named a column the internal table''s line type (/SCWM/S_ORDIM_O) does not have; activation 2026-11-25: "Unknown column name TAPOS", abaplint 2.120.116 with check_syntax on reported nothing'
  - 'probed 2026-11-25 against abaplint 2.120.113: SELECT * FROM @it_rows AS r ORDER BY mandt, nosuchcol INTO TABLE @DATA(lt_res). on a two-column local line type - no finding'
  - 'upstream search 2026-11-25 (SELECT FROM @ itab unknown column): nothing'
---

# SELECT FROM @itab: an unknown column in ORDER BY is not reported

```abap
SELECT * FROM @lt_ordim_o AS ltak
  WHERE (sel-where_tab)
  ORDER BY lgnum, tanum, tapos      " system: "Unknown column name TAPOS"
  INTO TABLE @DATA(ordim_o).
```

## Proposal

`check_syntax` resolves the columns of a `SELECT ... FROM @itab` against the
table's line type (as it does for a database table) in the field list,
`WHERE`, `GROUP BY` and `ORDER BY`.
