---
target: open-abap
title: 'transpiler: `NEW ty( comp = ... )` for a data type assigns the first value to the whole object - the component assignments are lost, and a nested `VALUE #` of a table fails the build'
summary: 'for a data type, `NewObjectTranspiler` takes the first `Source` below the expression as the value of the new object - in `NEW ty_s( a = 1 b = 2 )` that is `1`, and the reference ends up pointing to an integer; in `NEW ty_box( first = VALUE #( ... ) )` the inner `VALUE #` is applied to `ty_box` itself (a runtime `setField is not a function`), and when that `VALUE #` holds a table `VALUE #( ( ... ) )` the build stops with "TypeNameOrInfer, type not found: #"'
priority: medium
state: open
first_seen: 2026-10-24
upstream: abaplint/transpiler
evidence:
  - 'found 2026-10-24 by the start measurement of report2cloud (abap2UI5-addons/abap-cloud-gui, `report2cloud:web --start`) - a converted report of the open-source web corpus builds `rs_tool-parameters-properties = NEW ty_args_descr( val1 = VALUE #( type = ... description = ... ) oper = VALUE #( ... enum = VALUE #( ( `+` ) ( `-` ) ) ) ... )` with method-local types; the build stops with "TypeNameOrInfer, type not found: #, ... locals_imp.abap line 46" and the report is left out of the measurement'
  - 'reduced 2026-10-24 with @abaplint/transpiler-cli 2.14.5 and @abaplint/runtime 2.14.5 - `result = NEW ty_s( a = 1 b = 2 ).` (TYPES ty_s with two integers, result TYPE REF TO data) transpiles to `r.assign(abap.IntegerFactory.get(1))`, and after the call `result->*` is no structure (`result->a` is undefined)'
  - 'reduced 2026-10-24, same versions - `result = NEW ty_box( first = VALUE #( a = 1 b = `x` ) ).` transpiles to `r.assign(new abap.types.DataReference(<ty_box>).setField("a", ...).setField("b", ...))`, which throws "(intermediate value).setField is not a function" when it runs; `NEW ty_box( first = VALUE #( values = VALUE #( ( `+` ) ) ) )` stops the build with "TypeNameOrInfer, type not found: #". The same component list with `VALUE ty_box( ... )` instead of `NEW` transpiles and runs right'
  - 'read 2026-10-24 in @abaplint/transpiler 2.14.5 `build/src/expressions/new_object.js` - the branch for a type that is no object reference: `const source = node.findFirstExpression(abaplint.Expressions.Source)` and `r.assign(sourceCode)`; the `ParameterListS` the statement parses for the component list is transpiled before as method parameters (`para`) and then unused'
---

# transpiler: `NEW ty( comp = ... )` for a data type loses its components

## What happens

```abap
TYPES: BEGIN OF ty_s, a TYPE i, b TYPE i, END OF ty_s.
DATA result TYPE REF TO data.

result = NEW ty_s( a = 1 b = 2 ).
" system:     result->* is a ty_s with a = 1, b = 2
" transpiled: result points to the integer 1
```

With a structured component the inner `VALUE #` is applied to the outer type:

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

`build/src/expressions/new_object.js`, the branch for a type that is no
object reference:

```js
const source = node.findFirstExpression(abaplint.Expressions.Source);
const sourceCode = source === undefined ? typeCode : traversal.traverse(source).getCode();
ret.appendString("((() => {const r = new abap.types.DataReference(" + typeCode + "); r.assign(" + sourceCode + "); return r; })())");
```

The first `Source` below the expression is the value of the first
component, not the value of the object. The component list is parsed as a
`ParameterListS`, the same expression `NEW zcl( p = 1 )` gives a constructor.
It is transpiled into `para` as method parameters, and then not used.

## The change

When the type is no object reference and there is a `ParameterListS`, build
the value the way `VALUE ty( ... )` does: a new data object of the type with
each `name = source` set on it. Assign that value, not the first source. Only a
single unnamed `Source` (`NEW i( 5 )`) keeps today's `r.assign(source)`.
The inner `VALUE #` then infers the component's type, as it does inside
`VALUE ty_box( ... )`, which transpiles right today.

## Example

```abap
TYPES: BEGIN OF ty_s, a TYPE i, b TYPE i, END OF ty_s.
DATA(ref) = NEW ty_s( a = 1 b = 2 ).
cl_abap_unit_assert=>assert_equals( act = ref->b exp = 2 ).
```
