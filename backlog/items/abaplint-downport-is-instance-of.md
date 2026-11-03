---
target: abaplint
title: 'downport: IS INSTANCE OF is not downported, and the whole class is left untouched'
summary: '`IF lo IS INSTANCE OF zcl_x.` (7.50) has no downport; the statement does not parse at v702, the structure of the method breaks, and no other statement of the file is downported either'
priority: high
state: open
first_seen: 2026-11-02
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/se16n and table-content-loader, 2026-11-02 - four `IS INSTANCE OF` / `IS NOT INSTANCE OF` checks on the app that returned from a popup; each class reported `structure: Expected ENDMETHOD` and stayed modern until the checks were rewritten as casts in a TRY (branch claude/addon-repo-namespaces-dnjqev)'
  - 'probed 2026-11-02 with @abaplint/cli 2.120.92 - a single class, syntax v702, rules downport, parser_error, check_syntax, unknown_types; `abaplint --fix` then a lint run: `IF lo_obj IS INSTANCE OF zcl_case.` -> unchanged, `Expected ENDMETHOD (structure)` and parser_error'
checked_upstream: 2026-11-02
---
# downport: IS INSTANCE OF is not downported

```abap
DATA lo_obj TYPE REF TO object.
CREATE OBJECT lo_obj TYPE zcl_case.
IF lo_obj IS INSTANCE OF zcl_case.
  rv_ok = abap_true.
ENDIF.
```

stays as it is. At v702 the IF does not parse, the method has no valid
structure (`Expected ENDMETHOD`), and the rest of the file is not downported
either - one predicate blocks a whole class.

**Expected.** A cast in a TRY, with the result in a helper variable:

```abap
DATA temp1 TYPE REF TO zcl_case.
DATA temp2 TYPE abap_bool.
TRY.
    temp1 ?= lo_obj.
    temp2 = abap_true.
  CATCH cx_sy_move_cast_error.
    temp2 = abap_false.
ENDTRY.
IF temp2 = abap_true.
```

`IS NOT INSTANCE OF` and the CASE TYPE OF form need the same. A cast is
equivalent: `IS INSTANCE OF` is true exactly when `?=` succeeds, and an
initial reference fails both.

**Workaround in use.** The cast written in the source.
