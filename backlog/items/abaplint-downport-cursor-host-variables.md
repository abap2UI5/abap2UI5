---
target: abaplint
title: 'downport: OPEN CURSOR / FETCH NEXT CURSOR / CLOSE CURSOR keep their @ escapes'
summary: 'the escape removal the downport applies to SELECT, INSERT, MODIFY and DELETE does not reach the cursor statements - `OPEN CURSOR @lv_c FOR SELECT ...`, `FETCH NEXT CURSOR @lv_c INTO TABLE @lt` and `CLOSE CURSOR @lv_c` stay and do not parse at v702'
priority: low
state: open
first_seen: 2026-11-02
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/range-filter, 2026-11-02 - a cursor with PACKAGE SIZE tried as the replacement of a SELECT ... UP TO in `z2ui5_cl_sel_sample_01`; the escaped cursor statements broke the whole class on the 702 branch and were dropped again (branch claude/addon-repo-namespaces-dnjqev)'
  - 'probed 2026-11-02 with @abaplint/cli 2.120.92 - a single class, syntax v702, rules downport, parser_error, check_syntax, unknown_types; `abaplint --fix` then a lint run: the three statements below -> unchanged, three parser_errors'
checked_upstream: 2026-11-02
---
# downport: the cursor statements keep their @ escapes

```abap
DATA lv_cursor TYPE cursor.
OPEN CURSOR @lv_cursor FOR
  SELECT * FROM z2ui5_t_06
    WHERE name = @iv_text.
FETCH NEXT CURSOR @lv_cursor INTO TABLE @lt_rows PACKAGE SIZE 100.
CLOSE CURSOR @lv_cursor.
```

stays as it is: three `parser_error`s at v702. The strict syntax with escapes
is valid from 7.40 SP05 and is what the rule `sql_escape_host_variables` asks
for, so code that follows the rule cannot be downported.

**Expected.** The escapes removed, as for SELECT:

```abap
OPEN CURSOR lv_cursor FOR
  SELECT * FROM z2ui5_t_06
    WHERE name = iv_text.
FETCH NEXT CURSOR lv_cursor INTO TABLE lt_rows PACKAGE SIZE 100.
CLOSE CURSOR lv_cursor.
```

(and `OPEN CURSOR @DATA(lv_c)` declared as `TYPE cursor`).
