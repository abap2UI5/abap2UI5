---
target: abaplint
title: 'downport: CREATE DATA ... TYPE STANDARD TABLE OF (name) WITH EMPTY KEY is not downported'
summary: 'WITH EMPTY KEY is lowered to WITH DEFAULT KEY in TYPES and DATA (abaplint/abaplint#1479), but not in a CREATE DATA with a dynamic line type - the statement stays and does not parse at v702'
priority: low
state: open
first_seen: 2026-11-02
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/table-content-loader, 2026-11-02 - `z2ui5_cl_tcl_app_01`, `CREATE DATA mt_tab TYPE STANDARD TABLE OF (ms_app-db_table) WITH EMPTY KEY.`; changed to DEFAULT KEY in the source (branch claude/addon-repo-namespaces-dnjqev)'
  - 'probed 2026-11-02 with @abaplint/cli 2.120.92 - a single class, syntax v702, rules downport, parser_error, check_syntax, unknown_types; `abaplint --fix` then a lint run: `CREATE DATA lr TYPE STANDARD TABLE OF (iv_text) WITH EMPTY KEY.` -> unchanged, parser_error'
checked_upstream: 2026-11-02
---
# downport: CREATE DATA ... WITH EMPTY KEY is not downported

```abap
DATA lr TYPE REF TO data.
CREATE DATA lr TYPE STANDARD TABLE OF (iv_text) WITH EMPTY KEY.
```

stays as it is: `parser_error` at v702. abaplint/abaplint#1479 lowered
`WITH EMPTY KEY` to `WITH DEFAULT KEY` for TYPES and DATA; CREATE DATA was not
part of it.

**Expected.** `CREATE DATA lr TYPE STANDARD TABLE OF (iv_text) WITH DEFAULT
KEY.` - the same replacement, with the same caveat as in TYPES (a standard
table's key only matters for keyed access and SORT without BY).
