---
target: open-abap
title: 'transpiler: `NEW ty( comp = VALUE #( ... ) )` for a data type - the inner `VALUE #` is typed as the outer type: a runtime TypeError, and with a table inside the build stops'
summary: 'since abaplint/transpiler#2030 (2.14.12) `NEW ty_s( a = 1 b = 2 )` builds the structure right; a component given as `VALUE #( ... )` still is not: in `NEW ty_box( first = VALUE #( a = 1 ) )` the inner `VALUE #` is applied to `ty_box` itself (a runtime `setField is not a function`), and when that `VALUE #` holds a table `VALUE #( ( ... ) )` the build stops with "TypeNameOrInfer, type not found: #"'
priority: medium
state: open
first_seen: 2026-10-24
upstream: abaplint/transpiler
evidence:
  - 'found 2026-10-24 by the start measurement of report2cloud (abap2UI5-addons/abap-cloud-gui, `report2cloud:web --start`) - a converted report of the open-source web corpus builds `rs_tool-parameters-properties = NEW ty_args_descr( val1 = VALUE #( type = ... description = ... ) oper = VALUE #( ... enum = VALUE #( ( `+` ) ( `-` ) ) ) ... )` with method-local types; the build stops with "TypeNameOrInfer, type not found: #, ... locals_imp.abap line 46" and the report is left out of the measurement'
  - 'reduced 2026-10-24 with @abaplint/transpiler-cli 2.14.5 and @abaplint/runtime 2.14.5 - `result = NEW ty_s( a = 1 b = 2 ).` (TYPES ty_s with two integers, result TYPE REF TO data) transpiles to `r.assign(abap.IntegerFactory.get(1))`, and after the call `result->*` is no structure (`result->a` is undefined)'
  - 'reduced 2026-10-24, same versions - `result = NEW ty_box( first = VALUE #( a = 1 b = `x` ) ).` transpiles to `r.assign(new abap.types.DataReference(<ty_box>).setField("a", ...).setField("b", ...))`, which throws "(intermediate value).setField is not a function" when it runs; `NEW ty_box( first = VALUE #( values = VALUE #( ( `+` ) ) ) )` stops the build with "TypeNameOrInfer, type not found: #". The same component list with `VALUE ty_box( ... )` instead of `NEW` transpiles and runs right'
  - 'read 2026-10-24 in @abaplint/transpiler 2.14.5 `build/src/expressions/new_object.js` - the branch for a type that is no object reference: `const source = node.findFirstExpression(abaplint.Expressions.Source)` and `r.assign(sourceCode)`; the `ParameterListS` the statement parses for the component list is transpiled before as method parameters (`para`) and then unused'
  - 're-measured 2026-10-29 on abaplint/transpiler main ca16f9f (2.14.15) with the repository''s test harness - `NEW ty_s( a = 1 b = 2 )` now gives a ty_s with 1 and 2 (fixed by #2030, "NEW of a data type: a new data object with a copy of the value", merged 2026-10-26); `NEW ty_box( first = VALUE #( a = 1 b = `x` ) )` still throws "(intermediate value).setField is not a function", `NEW ty_box( first = VALUE #( values = VALUE #( ( `+` ) ) ) )` still stops the build with "TypeNameOrInfer, type not found: #". `new_object.ts` still traverses the `ParameterListS` as method parameters before `buildValue( )` sets the components'
---

# transpiler: `NEW ty( comp = VALUE #( ... ) )` for a data type

## What happens

The flat case is fixed upstream since abaplint/transpiler#2030 (2.14.12):
`NEW ty_s( a = 1 b = 2 )` builds a `ty_s` with both components. With a
structured component the inner `VALUE #` is still applied to the outer type:

```abap
result = NEW ty_box( first = VALUE #( a = 1 ) ).
" transpiled: TypeError "(intermediate value).setField is not a function"

result = NEW ty_box( first = VALUE #( values = VALUE #( ( `+` ) ) ) ).
" transpiled: the build stops - "TypeNameOrInfer, type not found: #"
```

For a data type, `NEW` takes the component list of `VALUE`. That is the
usual way to fill a data reference in one expression, for example the
`properties TYPE REF TO data` of a JSON schema.

## Why

`packages/transpiler/src/expressions/new_object.ts` (main ca16f9f): for a
data type, `buildValue( )` sets each `name = source` on the new object -
that is the #2030 change. But before it, `transpile( )` still traverses the
whole `ParameterListS` as method parameters (`para`, used only for a class).
The likely cause (not traced further): a `VALUE #` in there infers its type
from the `NEW` - the outer type, not the component's - which matches both
symptoms.

## The change

For a data type, skip the `para` traversal, and let each component's
`Source` infer from the component's type, as it does inside
`VALUE ty_box( ... )`, which transpiles right today.

## Example

```abap
TYPES: BEGIN OF ty_in, a TYPE i, END OF ty_in.
TYPES: BEGIN OF ty_box, first TYPE ty_in, END OF ty_box.
DATA(ref) = NEW ty_box( first = VALUE #( a = 1 ) ).
cl_abap_unit_assert=>assert_equals( act = ref->first-a exp = 1 ).
```
