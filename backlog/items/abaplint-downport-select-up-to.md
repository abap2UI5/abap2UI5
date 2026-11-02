---
target: abaplint
title: 'downport: SELECT with WHERE and UP TO n ROWS is left half rewritten'
summary: 'a strict-syntax SELECT with a WHERE clause and UP TO at the end gets its INTO moved but keeps its @ escapes and commas, so the v702 result does not parse - static, dynamic and join forms alike; an ORDER BY before INTO makes the same statement downport cleanly'
priority: high
state: open
first_seen: 2026-11-02
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/lock-manager, 2026-11-02 - `z2ui5_cl_app_sm12=>load_suggestions( )`, a SELECT DISTINCT over a join of DD26S and DD25L with `UP TO 500 ROWS`; the 702 branch could not be built until the statement got an ORDER BY (branch claude/addon-repo-namespaces-dnjqev)'
  - 'abap2UI5-addons/se16n and range-filter, 2026-11-02 - the capped read of a dynamic table, `SELECT * FROM (tab) WHERE (where) INTO CORRESPONDING FIELDS OF TABLE @<tab> UP TO @max ROWS`, same failure, same workaround'
  - 'probed 2026-11-02 with @abaplint/cli 2.120.92 - a single class, syntax v702, rules downport, parser_error, check_syntax, unknown_types; `abaplint --fix` then a lint run: all three shapes below fail; adding ORDER BY (PRIMARY KEY or columns) to each makes all three downport with 0 issues'
checked_upstream: 2026-11-02
---
# downport: SELECT with WHERE and UP TO n ROWS is left half rewritten

A strict-syntax SELECT that has a WHERE clause and ends with `UP TO n ROWS`
is only partly downported. The rule moves `INTO` behind the source, then
stops: the `@` escapes and the commas of the field list stay, and the v702
parser rejects the statement.

```abap
SELECT req_id, name FROM z2ui5_t_06
  WHERE name = @iv_text
  INTO TABLE @DATA(lt_rows)
  UP TO 10 ROWS.
```

becomes

```abap
DATA lt_rows TYPE STANDARD TABLE OF temp1 WITH DEFAULT KEY.
SELECT req_id, name FROM z2ui5_t_06 INTO TABLE @lt_rows
  WHERE name = @iv_text
  UP TO 10 ROWS.
```

`parser_error: Statement does not exist in the configured ABAP version`.
The same happens with a dynamic source and WHERE
(`SELECT * FROM (iv_tab) WHERE (iv_where) INTO CORRESPONDING FIELDS OF TABLE
@<tab> UP TO 100 ROWS`) and with a `SELECT DISTINCT` over a join.

**Expected.** The classic form, with UP TO in front of INTO and no escapes:

```abap
SELECT req_id name FROM z2ui5_t_06 UP TO 10 ROWS INTO TABLE lt_rows
  WHERE name = iv_text.
```

**What already works.** With an ORDER BY in front of INTO the same three
statements downport cleanly, so the gap is the WHERE-without-ORDER-BY
position of UP TO:

```abap
SELECT * FROM (iv_tab) WHERE (iv_where) ORDER BY PRIMARY KEY
  INTO CORRESPONDING FIELDS OF TABLE @<tab> UP TO 100 ROWS.
" -> SELECT * FROM (iv_tab) INTO CORRESPONDING FIELDS OF TABLE <tab>
"    WHERE (iv_where) ORDER BY PRIMARY KEY UP TO 100 ROWS.
```

A SELECT with UP TO and no WHERE (`SELECT bname FROM usr02 INTO TABLE
@lt_users UP TO 200 ROWS`) also downports.

**Workaround in use.** An ORDER BY before INTO, which also makes "the first
n rows" well defined.

Related: abaplint/abaplint#2902 (closed, the INTO position) and #2555 (open,
syntax error not reported for the order of UP TO).
