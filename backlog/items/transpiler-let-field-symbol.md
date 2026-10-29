---
target: open-abap
title: 'transpiler: `LET <fs> = ...` stops the build - "LetTranspiler, Expected Field"'
summary: 'a `LET` expression may declare a field symbol (`LET <fs> = itab[ ... ] IN ...`); the LetTranspiler looks for a Field in every InlineFieldDefinition and throws for the field symbol, so one such expression anywhere keeps the whole input from transpiling without naming a file'
priority: low
state: open
first_seen: 2026-10-24
upstream: abaplint/transpiler
evidence:
  - 'found 2026-10-24 by the start measurement of report2cloud (abap2UI5-addons/abap-cloud-gui) - a converted report snippet with `LET <c> = it_carr[ carrid = p_carrid ] IN ...`; the transpile of 257 objects stopped with "Error: LetTranspiler, Expected Field" (@abaplint/transpiler-cli 2.14.5) and no file name, and the measurement now leaves such objects out before the build (`UNSUPPORTED` in `tools/report2cloud/lib/start.mjs`)'
  - 'reduced 2026-10-24 with @abaplint/transpiler 2.14.3 - `DATA(lv) = CONV i( LET <c> = lt[ 1 ] IN <c> + 1 ).` throws "LetTranspiler, Expected Field"; abaplint reports no syntax error'
  - 'read 2026-10-24 in @abaplint/transpiler 2.14.3 `build/src/expressions/let.js` - `def.findDirectExpression(Expressions.Field)` is undefined for a field symbol and the loop throws'
---

# transpiler: `LET` with a field symbol stops the build

```abap
DATA(lv) = CONV i( LET <c> = lt[ 1 ] IN <c> + 1 ).   " LetTranspiler, Expected Field
DATA(lv2) = CONV i( LET c = lt[ 1 ] IN c + 1 ).      " transpiles
```

## The change

In `LetTranspiler`, take the name from the `FieldSymbol` expression of the
definition when there is no `Field`, declare it as the transpiler declares
an inline field symbol, and assign the source to it (a field symbol of a
`LET` points to the source, it is no copy).

## Example

```abap
TYPES ty_t TYPE STANDARD TABLE OF i WITH DEFAULT KEY.
DATA(lt) = VALUE ty_t( ( 1 ) ( 2 ) ).
cl_abap_unit_assert=>assert_equals( act = CONV i( LET <c> = lt[ 2 ] IN <c> + 1 ) exp = 3 ).
```
