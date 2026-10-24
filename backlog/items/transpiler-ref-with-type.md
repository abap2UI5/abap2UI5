---
target: open-abap
title: 'transpiler: `REF type( dobj )` with a type stops the build - "transpiler: REF # todo1"'
summary: '`REF #( dobj )` transpiles, `REF data( dobj )` or `REF ty_ref( dobj )` with a named type throws, so one such expression anywhere keeps the whole input from transpiling without naming a file - for a data reference the type only decides the static type of the result, the reference itself is the one `REF #( )` makes'
priority: low
state: open
first_seen: 2026-10-24
upstream: abaplint/transpiler
evidence:
  - 'found 2026-10-24 by the start measurement of report2cloud (abap2UI5-addons/abap-cloud-gui) - converted report snippets with `DATA(o_int) = REF data( lv_int ).`; the transpile of the whole set stopped without naming a file, and the measurement now leaves such objects out before the build (`UNSUPPORTED` in `tools/report2cloud/lib/start.mjs`)'
  - 'reduced 2026-10-24 with @abaplint/transpiler 2.14.3 - `REPORT zfoo. DATA lv_int TYPE i. DATA(lo_ref) = REF data( lv_int ).` throws "transpiler: REF # todo1"; abaplint reports no syntax error'
---

# transpiler: `REF type( )` with a type stops the build

```abap
DATA lv_int TYPE i.
DATA(lo_ref) = REF data( lv_int ).   " transpiler: REF # todo1
DATA(lo_ok)  = REF #( lv_int ).      " transpiles
```

The constructor operator `REF` takes `#` or a reference type. With `#` the
transpiler writes the reference of the operand; with a type it throws.

## The change

Transpile `REF type( dobj )` as `REF #( dobj )` - the type gives the
static type of the inline declaration (abaplint already knows it), the
value is the same reference.

## Example

```abap
DATA lv_int TYPE i VALUE 7.
DATA(lo_ref) = REF data( lv_int ).
ASSIGN lo_ref->* TO FIELD-SYMBOL(<lv_any>).
cl_abap_unit_assert=>assert_equals( act = <lv_any> exp = 7 ).
```
