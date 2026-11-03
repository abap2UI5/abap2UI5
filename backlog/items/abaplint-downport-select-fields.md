---
target: abaplint
title: 'downport: SELECT SINGLE FROM ... FIELDS * becomes SELECT * SINGLE'
summary: 'the FROM-first form `SELECT SINGLE FROM tab FIELDS * WHERE ... INTO @s` is downported to `SELECT * SINGLE FROM tab ...`, which does not parse at v702 - the SINGLE has to stay in front of the field list'
priority: medium
state: open
first_seen: 2026-11-02
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/range-filter, 2026-11-02 - `z2ui5_cl_sel_var_db`, three `SELECT SINGLE FROM z2ui5_t_13 FIELDS * ...`; rewritten to `SELECT SINGLE * FROM ...` on main so the 702 branch builds (branch claude/addon-repo-namespaces-dnjqev). The same FIELDS form was in se16n, sql-console and table-content-loader'
  - 'probed 2026-11-02 with @abaplint/cli 2.120.92 - a single class, syntax v702, rules downport, parser_error, check_syntax, unknown_types; `abaplint --fix` then a lint run: `SELECT SINGLE FROM z2ui5_t_06 FIELDS * WHERE name = @iv_text INTO @ls_row.` -> `SELECT * SINGLE FROM z2ui5_t_06 WHERE name = iv_text INTO ls_row.`, parser_error'
checked_upstream: 2026-11-02
---
# downport: SELECT SINGLE FROM ... FIELDS * becomes SELECT * SINGLE

The FROM-first form of a SELECT (7.50) is downported by moving the FIELDS list
in front of FROM - but behind `SINGLE`'s position:

```abap
SELECT SINGLE FROM z2ui5_t_06
  FIELDS
   *
  WHERE name = @iv_text
  INTO @ls_row.
```

becomes

```abap
SELECT * SINGLE FROM z2ui5_t_06
  WHERE name = iv_text
  INTO ls_row.
```

`parser_error` at v702: `SINGLE` belongs in front of the field list.

**Expected.** `SELECT SINGLE * FROM z2ui5_t_06 WHERE name = iv_text INTO
ls_row.` (or `INTO` in front of WHERE).

**Not affected.** The same form without SINGLE (`SELECT FROM t FIELDS * WHERE
... INTO TABLE @lt`) and a named field list.

**Workaround in use.** Write `SELECT SINGLE * FROM ...` in the source.
