---
target: abaplint
title: 'downport: MOVE-CORRESPONDING between internal tables is not downported'
summary: 'MOVE-CORRESPONDING itab1 TO itab2 (7.40 SP05) stays as it is, and CORRESPONDING #( itab ) is even lowered INTO that statement - check_syntax then reports "MOVE-CORRESPONDING with tables possible from v740sp05"; a loop with MOVE-CORRESPONDING per row is the 7.02 form'
priority: medium
state: filed
filed: https://github.com/abaplint/abaplint/pull/4515
first_seen: 2026-11-02
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/table-maintenance, 2026-11-02 - `z2ui5_cl_tm_001`, four `MOVE-CORRESPONDING <tab> TO <tab_org>` on generic field symbols; replaced by a row-by-row helper so the 702 branch builds (branch claude/addon-repo-namespaces-dnjqev)'
  - 'probed 2026-11-02 with @abaplint/cli 2.120.92 - a single class, syntax v702, rules downport, parser_error, check_syntax, unknown_types; `abaplint --fix` then a lint run: `MOVE-CORRESPONDING lt_a TO lt_b.` with two typed standard tables -> unchanged, check_syntax error; the same with `TYPE STANDARD TABLE` field symbols; `lt_b = CORRESPONDING #( lt_a ).` over the same two tables -> `MOVE-CORRESPONDING lt_a TO lt_b.`, same check_syntax error'
checked_upstream: 2026-11-03
---
# downport: MOVE-CORRESPONDING between internal tables is not downported

```abap
DATA lt_a TYPE STANDARD TABLE OF z2ui5_t_06 WITH DEFAULT KEY.
DATA lt_b TYPE STANDARD TABLE OF ty_b WITH DEFAULT KEY.
MOVE-CORRESPONDING lt_a TO lt_b.
```

stays as it is, and v702 `check_syntax` reports `MOVE-CORRESPONDING with
tables possible from v740sp05`. The same with generic field symbols
(`FIELD-SYMBOLS <a> TYPE STANDARD TABLE`).

**Expected.**

```abap
CLEAR lt_b.
LOOP AT lt_a ASSIGNING <temp1>.
  APPEND INITIAL LINE TO lt_b ASSIGNING <temp2>.
  MOVE-CORRESPONDING <temp1> TO <temp2>.
ENDLOOP.
```

with `<temp1>`/`<temp2>` typed `ANY` (or LIKE LINE OF where the table is
typed). `KEEPING TARGET LINES` drops the CLEAR; `EXPANDING NESTED TABLES` has
no row-wise equivalent and can stay an issue.

**The operator lands in the same place.** `lt_b = CORRESPONDING #( lt_a ).`
over the same two tables is downported to `MOVE-CORRESPONDING lt_a TO lt_b.` -
the statement above, with the same error. So the fix for the statement fixes
both.

abaplint/abaplint#3628 ("Downport: CORRESPONDING # and MOVE-CORRESPONDING with
tables") is closed; in 2.120.92 neither form reaches valid 7.02 code for
tables.
