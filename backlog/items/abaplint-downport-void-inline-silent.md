---
target: abaplint
title: 'downport: an inline declaration of a void type stays as it is, without an issue'
summary: 'when the type of an inline declaration resolves to a void type (STRING_TABLE without a dependency that defines it) the downport leaves `READ TABLE lt INTO DATA(x)` or `t_arg = VALUE #( ... )` unchanged and reports nothing - at v702 `INTO DATA(x)` then parses as an offset/length access on a field DATA, and check_syntax only says `"DATA" not found`'
priority: medium
state: open
first_seen: 2026-11-02
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/config-management, 2026-11-02 - `z2ui5_cl_config_service`, `READ TABLE lt_parts INTO DATA(lv_part1) INDEX 1.` with lt_parts TYPE string_table, and two `follow_up_action( ... t_arg = VALUE #( ( ... ) ) )`; the 702 lint said `"DATA" not found, Target` and `parser_error` while the downport rule itself reported 0 issues (branch claude/addon-repo-namespaces-dnjqev)'
  - 'probed 2026-11-02 with @abaplint/cli 2.120.92 - a single class, syntax v702, rules downport, parser_error, check_syntax, unknown_types; `abaplint --fix` then a lint run: `DATA lt_parts TYPE string_table. READ TABLE lt_parts INTO DATA(lv_part1) INDEX 1.` with errorNamespace ^Z and abaplint/deps as the only dependency (it ships no DDIC types) -> unchanged, `"DATA" not found`; the same with a local `TYPES ty_t TYPE STANDARD TABLE OF string` -> downported. A LOOP AT ... INTO DATA(x) over the void-typed table IS downported (`DATA x LIKE LINE OF lt`)'
checked_upstream: 2026-11-02
---
# downport: an inline declaration of a void type stays without an issue

With a void type - here STRING_TABLE, which abaplint/deps does not define,
under `errorNamespace: "^Z"` - the downport cannot write a declaration and
leaves the statement as it is:

```abap
DATA lt_parts TYPE string_table.
READ TABLE lt_parts INTO DATA(lv_part1) INDEX 1.
```

The `downport` rule reports **0 issues** for it. At v702 the statement still
parses - `DATA(lv_part1)` reads as an offset/length access on a field called
`DATA` - so the only message is `check_syntax: "DATA" not found, Target`, which
does not point at the cause. The same silence for `t_arg = VALUE #( ( `A` ) )`
when the parameter is typed with a void table type (there it is a
`parser_error` on the whole statement).

**Inconsistent within the rule.** `LOOP AT lt_parts INTO DATA(lv)` over the
same void-typed table is downported, to `DATA lv LIKE LINE OF lt_parts`. READ
TABLE could take the same `LIKE LINE OF`.

**Expected.**
1. READ TABLE ... INTO DATA( ) uses `LIKE LINE OF <table>` like LOOP does.
2. Where no declaration can be written, the downport rule reports an issue on
   the statement ("cannot downport, type of lv_part1 is void") instead of
   none, so the failure is named where it happens.

**Workaround in use.** Explicit declarations in the source.
