---
target: abaplint
title: 'downport: SELECT with WHERE and UP TO n ROWS is left half rewritten'
summary: 'a strict-syntax SELECT with a WHERE clause and UP TO at the end gets its INTO moved but keeps its @ escapes and commas, so the v702 result does not parse - static, dynamic and join forms alike; the dynamic form is rewritten into an order no release parses, which stops the downport of every later statement of the class; an ORDER BY before INTO, or INTO and UP TO ahead of WHERE, makes the same statement downport cleanly'
priority: high
state: open
first_seen: 2026-11-02
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/lock-manager, 2026-11-02 - `z2ui5_cl_lock_app_sm12=>load_suggestions( )`, a SELECT DISTINCT over a join of DD26S and DD25L with `UP TO 500 ROWS`; the 702 branch could not be built until the statement got an ORDER BY (branch claude/addon-repo-namespaces-dnjqev)'
  - 'abap2UI5-addons/se16n and range-filter, 2026-11-02 - the capped read of a dynamic table, `SELECT * FROM (tab) WHERE (where) INTO CORRESPONDING FIELDS OF TABLE @<tab> UP TO @max ROWS`, same failure, same workaround'
  - 'abap-util/abap-util, 2026-11-03 - `zabaputil_cl_util_context=>db_select_by_name( )`, `SELECT * FROM (lv_tab) WHERE (lv_where) INTO TABLE @<tab> UP TO @max_rows ROWS`; on 2.120.92 the 702 downport of the whole context class stopped (543 issues across 94 files, the unit run broken), fixed by writing INTO and UP TO ahead of WHERE (branch claude/addon-repo-namespaces-dnjqev)'
  - 'probed 2026-11-03 with @abaplint/cli 2.120.92, same setup: that SELECT followed by `DATA(lv_x) = xsdbool( ... ).` - the SELECT becomes `... INTO TABLE @<tab> WHERE (iv_text) UP TO 100 ROWS.`, the xsdbool line is outlined once and then left, 2 parser errors; with `INTO TABLE @<tab> UP TO 100 ROWS WHERE (iv_text)` both downport, 0 issues'
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

**Why it blocks the whole class.** For the dynamic form the half rewrite,
`SELECT * FROM (tab) INTO TABLE @<tab> WHERE (where) UP TO 100 ROWS.`, does
not parse at v758 either. The next `--fix` pass re-reads the rewritten source
as the high-version object, finds a parser error there and skips the class
entirely: no further statement of the class is downported, nothing reports
the cause, and what remains is a parser error on every later statement that
still needs a rewrite, plus `check_syntax` noise in every class that uses the
broken one. In abap-util that was one SELECT behind 543 issues.

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

A SELECT with INTO and UP TO ahead of WHERE (no ORDER BY) also downports:

```abap
SELECT * FROM (iv_tab) INTO TABLE @<tab> UP TO @max ROWS WHERE (iv_where).
" -> SELECT * FROM (iv_tab) INTO TABLE <tab> UP TO max ROWS WHERE (iv_where).
```

**Workarounds in use.** An ORDER BY before INTO, which also makes "the first
n rows" well defined, or INTO and UP TO ahead of WHERE where the order of the
rows does not matter.

Related: abaplint/abaplint#2902 (closed, the INTO position) and #2555 (open,
syntax error not reported for the order of UP TO).
