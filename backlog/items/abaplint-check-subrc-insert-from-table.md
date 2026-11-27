---
target: abaplint
title: 'check_subrc asks for a sy-subrc check after INSERT dbtab FROM TABLE, which raises on a duplicate key'
summary: 'INSERT dbtab FROM TABLE itab without ACCEPTING DUPLICATE KEYS raises CX_SY_OPEN_SQL_DB on a duplicate instead of setting sy-subrc 4 - the IF sy-subrc <> 0 the rule asks for is dead code, and was the bug in one addon'
priority: medium
state: open
first_seen: 2026-11-27
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/layout-management f6baf2a, 2026-11 ("copy_layouts: a failed insert rolls back and keeps its cause"): "INSERT ... FROM TABLE raises cx_sy_open_sql_db on a duplicate key instead of setting sy-subrc, so the ROLLBACK branch never ran"; the code is now TRY. INSERT z2ui5_t_11 FROM TABLE @result ##SUBRC_OK. CATCH cx_sy_open_sql_db ..., and the repository carries six ##SUBRC_OK on such inserts to silence the rule'
  - 'probed 2026-11-27 against abaplint main after 2.120.122: INSERT ztab FROM TABLE @lt. reports "Check sy-subrc"; adding IF sy-subrc <> 0. ROLLBACK WORK. ENDIF. makes it green'
  - 'the sy-subrc behaviour is taken from the ABAP keyword documentation as remembered and from the finding of that repository - not re-verified on a system for this item; verify before filing'
---

# `check_subrc` after `INSERT dbtab FROM TABLE`

```abap
INSERT ztab FROM TABLE @lt_rows.
IF sy-subrc <> 0.          " asked for by check_subrc - never true
  ROLLBACK WORK.
ENDIF.
```

Without `ACCEPTING DUPLICATE KEYS` the statement does not set sy-subrc to 4
when a row exists: it raises `CX_SY_OPEN_SQL_DB`. The check the rule asks
for cannot fail, and the error handling that was meant never runs.

## Proposal

`check_subrc`: do not ask for a sy-subrc check on `INSERT dbtab FROM TABLE`
without `ACCEPTING DUPLICATE KEYS`. As a second step, report an
`IF sy-subrc <> 0` directly after it as unreachable, pointing at
`CATCH cx_sy_open_sql_db`.

## Must keep reporting

`INSERT dbtab FROM wa` / `VALUES` (a single row sets 4),
`FROM TABLE ... ACCEPTING DUPLICATE KEYS`, the subquery form, and
`UPDATE` / `MODIFY` / `DELETE ... FROM TABLE`. A check of sy-dbcnt stays
valid everywhere.
