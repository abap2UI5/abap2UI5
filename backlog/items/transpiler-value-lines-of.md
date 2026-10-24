---
target: open-abap
title: 'transpiler: `VALUE t( ( LINES OF itab ) )` stops the build - "ValueBodyLineTranspiler, unknown ValueBodyLines"'
summary: 'the line `( LINES OF itab [FROM i] [TO j] )` of a VALUE body appends the lines of another table; the ValueBodyLineTranspiler does not know it and throws, so one such expression anywhere keeps the whole input from transpiling'
priority: low
state: open
first_seen: 2026-10-24
upstream: abaplint/transpiler
evidence:
  - 'found 2026-10-24 by the start measurement of report2cloud (abap2UI5-addons/abap-cloud-gui) - a converted report snippet with `VALUE ty_it_person( ( LINES OF it_person ) )` and `( LINES OF it_person FROM 1 TO n )`; the measurement now leaves such objects out before the build (`UNSUPPORTED` in `tools/report2cloud/lib/start.mjs`)'
  - 'reduced 2026-10-24 with @abaplint/transpiler 2.14.3 - `DATA(lt2) = VALUE ty_t( ( LINES OF lt ) ).` throws "ValueBodyLineTranspiler, unknown ValueBodyLines ( LINES OF lt )"; abaplint reports no syntax error'
---

# transpiler: `( LINES OF )` in a VALUE body stops the build

```abap
DATA(lt2) = VALUE ty_t( ( LINES OF lt ) ).                 " unknown ValueBodyLines
DATA(lt3) = VALUE ty_t( ( LINES OF lt FROM 1 TO 2 ) ( 9 ) ).
```

## The change

In `ValueBodyLineTranspiler`, transpile `LINES OF itab [FROM i] [TO j]` as
the `APPEND LINES OF` the transpiler already writes, into the table being
built, in the order of the body.

## Example

```abap
TYPES ty_t TYPE STANDARD TABLE OF i WITH DEFAULT KEY.
DATA(lt) = VALUE ty_t( ( 1 ) ( 2 ) ( 3 ) ).
cl_abap_unit_assert=>assert_equals( act = VALUE ty_t( ( LINES OF lt FROM 2 ) ( 4 ) ) exp = VALUE ty_t( ( 2 ) ( 3 ) ( 4 ) ) ).
```
