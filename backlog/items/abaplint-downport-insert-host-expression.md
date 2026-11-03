---
target: abaplint
title: 'downport: INSERT dbtab FROM @( VALUE #( ... ) ) writes code that does not compile'
summary: 'a host expression with VALUE #( ) as the work area of INSERT is downported into `DATA temp1 LIKE DATA(temp1).` followed by a second `DATA temp1 LIKE temp1.` and `temp1 = temp1.` - an invalid declaration and a duplicate name, so the v702 result has syntax errors'
priority: high
state: open
first_seen: 2026-11-02
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/lock-manager, 2026-11-02 - `z2ui5_cl_lock_manager=>write_request( )`, `INSERT z2ui5_t_06 FROM @( VALUE #( req_id = ... name = to_upper( ... ) ... ) )` in a LOOP; v702 reported "Type error, invalid field length" for the generated temporaries; rewritten with a declared work area (branch claude/addon-repo-namespaces-dnjqev)'
  - 'probed 2026-11-02 with @abaplint/cli 2.120.92 - a single class, syntax v702, rules downport, parser_error, check_syntax, unknown_types; `abaplint --fix` then a lint run: the shape below -> `DATA temp1 LIKE DATA(temp1).` ... `DATA temp1 LIKE temp1.` `temp1 = temp1.`, check_syntax "Variable name temp1 already defined" and unknown_types'
checked_upstream: 2026-11-02
---
# downport: INSERT dbtab FROM @( VALUE #( ... ) ) writes code that does not compile

```abap
LOOP AT lt_p INTO DATA(ls_p).
  INSERT z2ui5_t_06 FROM @( VALUE #(
    req_id = iv_text
    name   = to_upper( ls_p )
    value  = ls_p
  ) ).
ENDLOOP.
```

becomes

```abap
LOOP AT lt_p INTO ls_p.
  DATA temp1 LIKE DATA(temp1).
  CLEAR temp1.
  temp1-req_id = iv_text.
  temp1-name = to_upper( ls_p ).
  temp1-value = ls_p.
  DATA temp1 LIKE temp1.
  temp1 = temp1.
INSERT z2ui5_t_06 FROM temp1.
ENDLOOP.
```

Two temporaries got the same name, and the first is declared `LIKE DATA(temp1)`
- the inline declaration the second step was meant to replace. v702 reports
`Variable name "temp1" already defined` and `Type error, invalid field length`.
This is worse than a statement left untouched: the output looks downported.

**Expected.** The work area typed by the database table:

```abap
DATA temp1 TYPE z2ui5_t_06.
CLEAR temp1.
temp1-req_id = iv_text.
...
INSERT z2ui5_t_06 FROM temp1.
```

MODIFY, UPDATE and DELETE `FROM @( ... )` probably share the path.
