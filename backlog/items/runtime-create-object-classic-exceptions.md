---
target: open-abap
title: 'CREATE OBJECT ... EXCEPTIONS: a classic exception of the constructor is not caught - sy-subrc is not set, the run dies'
summary: 'the transpiled CREATE OBJECT passes the EXPORTING parameters to constructor_( ) and drops the EXCEPTIONS clause, so a RAISE of a classic exception in the constructor escapes as abap.ClassicError where ABAP sets sy-subrc to the number of that exception; CALL METHOD and a functional call do handle it (e.classic)'
priority: medium
state: open
first_seen: 2026-10-24
upstream: abaplint/transpiler
evidence:
  - 'abap2UI5-addons/abap-cloud-gui - the stand-ins of the SAP GUI controls (z2ui5_cl_cgui_gui*) keep the classic constructors of cl_gui_custom_container and cl_gui_textedit, with EXCEPTIONS cntl_error / error_cntl_create; their unit test of the constructor outside of a report (CREATE OBJECT lo EXPORTING ... EXCEPTIONS error_cntl_create = 1) died with ClassicError instead of sy-subrc = 1, and was dropped'
  - 'measured 2026-10-24 with @abaplint/transpiler 2.14.3 (API) and transpiler-cli 2.14.5: CREATE OBJECT lo EXPORTING fail = abap_true EXCEPTIONS failed = 1 is `lo.set(await (new abap.Classes[...]()).constructor_({fail: ...}))` with no try/catch; build/src/statements/create_object.js has no handling of e.classic, build/src/statements/call.js has'
---

# CREATE OBJECT ... EXCEPTIONS: the classic exception escapes

## What happens

```abap
CLASS lcl DEFINITION.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING fail TYPE abap_bool
      EXCEPTIONS failed.
ENDCLASS.

CLASS lcl IMPLEMENTATION.
  METHOD constructor.
    IF fail = abap_true.
      RAISE failed.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

DATA lo TYPE REF TO lcl.
CREATE OBJECT lo
  EXPORTING
    fail   = abap_true
  EXCEPTIONS
    failed = 1.
" ABAP: sy-subrc = 1, lo is initial
" transpiled: abap.ClassicError { classic: 'failed' } - the run dies
```

The transpiled statement is

```js
lo.set(await (new abap.Classes['LCL']()).constructor_({fail: abap.builtin.abap_true}));
```

The EXCEPTIONS clause is gone. A method call with EXCEPTIONS is transpiled with a try/catch that maps `e.classic` to `sy-subrc` (`build/src/statements/call.js`), but `build/src/statements/create_object.js` has no such handling.

## The change

In `create_object.js`, when the statement has an EXCEPTIONS clause, wrap the construction as `call.js` wraps a method call: set `sy-subrc` to 0, catch `abap.ClassicError`, map `e.classic` to the number of the matching exception (or OTHERS), and set `sy-subrc` to it. Leave the target unchanged in that case. `NEW` needs nothing: a constructor expression has no EXCEPTIONS.

## Example

```abap
CREATE OBJECT lo EXPORTING fail = abap_true EXCEPTIONS failed = 1 OTHERS = 2.
cl_abap_unit_assert=>assert_equals( act = sy-subrc exp = 1 ).
cl_abap_unit_assert=>assert_not_bound( lo ).
CREATE OBJECT lo EXPORTING fail = abap_false EXCEPTIONS failed = 1.
cl_abap_unit_assert=>assert_equals( act = sy-subrc exp = 0 ).
```
