---
target: open-abap
title: 'transpiler: a method parameter typed with the generic `TYPE p` is declared as `new abap.types.typeTodoPGenericType()` - TypeError on the call, and RTTI on the class fails'
summary: `TranspileTypes.toType` has no branch for abaplint's `PGenericType`, so a method parameter `TYPE p` (no LENGTH, no DECIMALS) falls through to `"typeTodo" + type.constructor.name` - every CHANGING parameter, optional IMPORTING default, unreceived EXPORTING parameter and the class's METHODS metadata construct a type that does not exist; calling the method or describing the class dies with `TypeError: abap.types.typeTodoPGenericType is not a constructor`. FORM parameters `TYPE p` and `TYPE numeric` are fine; none in this corpus
priority: low
state: open
first_seen: 2026-10-03
upstream: abaplint/transpiler
evidence:
  - found 2026-10-03 by the report2cloud runtime tests (abap2UI5/abap-cloud-gui, `tools/report2cloud`) - a report whose `FORM total USING iv_discount TYPE p CHANGING cv_net TYPE p` became a private method kept the generic `TYPE p`, and the converted app failed on the transpiled runtime when its class was described; report2cloud now types such a parameter `LIKE` the data object every `PERFORM` passes and keeps a TODO when the actuals differ (its README, mapping table row "a FORM parameter `TYPE p` (generic)")
  - minimal repro 2026-10-03 (class below; @abaplint/transpiler-cli and runtime 2.13.96 - the version abap2UI5's devDependencies pin and the latest on npm that day - against open-abap-core b2d219d), each test in its own process - 8 tests; 4 fail with `TypeError: abap.types.typeTodoPGenericType is not a constructor` - CHANGING `TYPE p` called with a p DECIMALS 2 and with a p DECIMALS 0 actual, `cl_abap_typedescr=>describe_by_name( 'ZCL_PREPRO' )`, and `cl_abap_objectdescr=>describe_by_object_ref( )` inside `TRY … CATCH cx_root` (the TypeError is no ABAP exception, so the CATCH does not see it); IMPORTING-only `TYPE p`, EXPORTING `TYPE p` with the actual supplied, the same method with `TYPE numeric`, and `FIELD-SYMBOLS <f> TYPE p` pass
  - the same parameters on a FORM (`FORM calc USING iv_in TYPE p CHANGING cv_out TYPE p`, transpiled as a PROG) work - the FORM transpiler takes `INPUT.cv_out` as it is and declares nothing, so the gap is the method path only
  - the cause, read in the 2.13.96 bundle and unchanged in `packages/transpiler/src/transpile_types.ts` at abaplint/transpiler main 2fae932 (2026-10-03) - `toType` maps `NumericGenericType` to `Packed` with `{length: 8, decimals: 2}` and `CGenericType`/`XGenericType` to `Character`/`Hex`, but `PGenericType` (`BasicTypes.PGenericType` in @abaplint/core, what `TYPE p` on a parameter resolves to) is not listed and reaches the final `resolved = "typeTodo" + type.constructor.name`
checked_upstream: 2026-10-03
---

# transpiler: a method parameter typed with the generic `TYPE p` breaks the class

## What happens

`TYPE p` without `LENGTH` and `DECIMALS` is a generic type on a parameter: it
takes a packed number of any length and any number of decimals. The
transpiler has no JS type for it:

```abap
CLASS zcl_prepro DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS double
      IMPORTING iv TYPE p
      CHANGING  cv TYPE p.
ENDCLASS.

CLASS zcl_prepro IMPLEMENTATION.
  METHOD double.
    cv = iv * 2.
  ENDMETHOD.
ENDCLASS.
```

@abaplint/transpiler-cli 2.13.96 emits:

```js
static METHODS = {"DOUBLE": {"visibility": "U", "parameters": {
  "IV": {"type": () => {return new abap.types.typeTodoPGenericType();}, …, "type_name": "PGenericType"},
  "CV": {"type": () => {return new abap.types.typeTodoPGenericType();}, …}}}};
…
static async double(INPUT) {
  let iv = INPUT?.iv;
  let cv = new abap.types.typeTodoPGenericType();
  if (INPUT && INPUT.cv) {cv = INPUT.cv;}
  cv.set(abap.operators.multiply(iv,abap.IntegerFactory.get(2)));
}
```

`abap.types.typeTodoPGenericType` does not exist, so the call dies on its
first line with `TypeError: abap.types.typeTodoPGenericType is not a
constructor` - before the actual is even looked at. The transpile succeeds,
with the syntax check on.

The METHODS metadata is worse, because it does not need a call: open-abap's
`cl_abap_objectdescr=>_construct` runs `parameters[p].type()` for every
parameter of every method, so describing the class fails too - by name or by
object reference. The `TypeError` is no ABAP exception, so a
`CATCH cx_root` around the describe does not catch it. abap2UI5 reads every
app's attributes that way (`z2ui5_cl_ui5_srv_model` →
`z2ui5_cl_ui5_util_context=>rtti_get_t_attri_by_oref`), so an app class with
such a method, even a private one, fails on its first roundtrip. (And
`cl_abap_objectdescr` caches the half-built descriptor before the methods
loop throws, so a second describe in the same process "succeeds" with an
incomplete method list.)

## Where it applies

| Parameter | 2.13.96 |
|---|---|
| `CHANGING cv TYPE p` - actual p DECIMALS 2, actual p DECIMALS 0 | `TypeError … is not a constructor` |
| `describe_by_name( )` / `describe_by_object_ref( )` of the class | same, whatever the parameter kind |
| `IMPORTING iv TYPE p` (not optional, by reference) | the call works - the actual is taken as it is |
| `EXPORTING ev TYPE p` | works when the caller receives it (`INPUT?.ev \|\| new …typeTodo…`), fails when not |
| `IMPORTING iv TYPE p OPTIONAL`, `IMPORTING iv TYPE p DEFAULT 1` | works when supplied; the `\|\|` fallback constructs the typeTodo when not |
| `IMPORTING VALUE(iv) TYPE p` | the call works - the actual is taken as it is |
| `TYPE numeric` in the same places | correct - `Packed({length: 8, decimals: 2})` |
| `FORM f USING iv TYPE p CHANGING cv TYPE p` | correct - the FORM transpiler declares nothing |
| `FIELD-SYMBOLS <f> TYPE p` | correct - abaplint gives it p LENGTH 8 DECIMALS 0 |

## Cause

`TranspileTypes.toType` (`packages/transpiler/src/transpile_types.ts`):

```js
} else if (type instanceof abaplint.BasicTypes.PackedType) {
  resolved = "Packed";
  …
} else if (type instanceof abaplint.BasicTypes.NumericGenericType) {
  resolved = "Packed";
  extra = "{length: 8, decimals: 2}";
} …
} else {
  resolved = "typeTodo" + type.constructor.name;
}
```

`CGenericType`, `XGenericType`, `NumericGenericType` and the generic object
reference each have a branch; `PGenericType`, the fifth generic class in
`@abaplint/core`, has none.

## A fix

Map `PGenericType` the way `NumericGenericType` already is - a `Packed`
placeholder - in `toType`, and give it the same `Character` conversion
`MethodImplementationTranspiler` does for a `NumericGenericType` IMPORTING
parameter. The placeholder only matters where no actual is passed; a
CHANGING or by-reference IMPORTING parameter is replaced by the actual, which
keeps its own decimals. open-abap's `cl_abap_objectdescr` then wants a
`type_name = 'PGenericType'` branch next to `NumericGenericType`, so RTTI
answers `typekind_packed` with no length instead of the placeholder's
`decimals: 2` - that half belongs to open-abap/open-abap-core.

## Why it is low priority here

No method in abap2UI5, samples, samples-controls or samples-stack has a
parameter typed `TYPE p` (see the measurement below; the one generic numeric
parameter in the corpus is `TYPE numeric`, which works). It bites code
written outside this corpus and transpiled against `@abap2ui5/node-runtime` -
a classic report converted to a class, as report2cloud does, keeps the
`TYPE p` its FORMs had.

## The repro

`zcl_prepro`, the class above plus:

```abap
CLASS-METHODS importing_only
  IMPORTING iv            TYPE p
  RETURNING VALUE(result) TYPE string.
CLASS-METHODS double_exporting
  IMPORTING iv TYPE p
  EXPORTING ev TYPE p.
CLASS-METHODS double_numeric
  IMPORTING iv TYPE numeric
  CHANGING  cv TYPE numeric.
```

Its test class, one method per row:

```abap
METHOD p_changing_dec2.
  DATA lv_in TYPE p LENGTH 8 DECIMALS 2 VALUE '1.25'.
  DATA lv_out TYPE p LENGTH 8 DECIMALS 2.
  zcl_prepro=>double( EXPORTING iv = lv_in CHANGING cv = lv_out ).
  cl_abap_unit_assert=>assert_equals( act = lv_out exp = '2.50' ).
ENDMETHOD.

METHOD p_changing_dec0.
  DATA lv_in TYPE p LENGTH 8 DECIMALS 0 VALUE 7.
  DATA lv_out TYPE p LENGTH 8 DECIMALS 0.
  zcl_prepro=>double( EXPORTING iv = lv_in CHANGING cv = lv_out ).
  cl_abap_unit_assert=>assert_equals( act = lv_out exp = 14 ).
ENDMETHOD.

METHOD p_describe_catch.
  DATA lo_app TYPE REF TO zcl_prepro.
  DATA lv_ok TYPE abap_bool.
  CREATE OBJECT lo_app.
  TRY.
      cl_abap_objectdescr=>describe_by_object_ref( lo_app ).
      lv_ok = abap_true.
    CATCH cx_root.
      lv_ok = abap_false.
  ENDTRY.
  cl_abap_unit_assert=>assert_true( lv_ok ).
ENDMETHOD.

METHOD p_importing_only.        " passes
  DATA lv_in TYPE p LENGTH 8 DECIMALS 2 VALUE '1.25'.
  cl_abap_unit_assert=>assert_equals( act = zcl_prepro=>importing_only( lv_in ) exp = `1.25` ).
ENDMETHOD.
```

`abap_transpile` with `write_unit_tests: true`, `unknownTypes: runtimeError`,
syntax check on, open-abap-core as the lib. Run each test in a process of its
own - the describe cache above makes the second describe pass.

## How to file

An issue with this body against abaplint/transpiler; the RTTI half as a
follow-up against open-abap/open-abap-core once the transpiler emits a type.
A PR is possible as well: the change is one branch in `transpile_types.ts`,
and the transpiler's tests run ABAP snippets end to end.

1. Search the abaplint/transpiler tracker first and record the date in
   `checked_upstream:` (2026-10-03: the GitHub issue search for
   `PGenericType`, `typeTodo`, `generic packed` and `"TYPE p"` in
   abaplint/transpiler, read through the web page because this session has no
   API access to the repository - 0, 1 (#316, typeTodoDataReference, closed
   2021), 0 and 15 results, none about a generic `TYPE p` parameter).
2. Open the issue.
3. Set `state: filed` and `filed: <url>` here, run `npm run backlog`, commit.
4. When it ships, bump the transpiler in abap2UI5, tell report2cloud it can
   keep `TYPE p` as written, and delete this item.

<!-- probe:start — written by `npm run backlog:probe`, do not edit by hand -->

## Measured

`transpiler-generic-packed-parameter.probe.mjs` — a METHODS / CLASS-METHODS parameter typed `TYPE p` without LENGTH or DECIMALS - the transpiler emits `typeTodoPGenericType`; FORM parameters `TYPE p` and method parameters `TYPE numeric` as the negative.
Run **2026-10-03** against `abap2UI5`, `samples`, `samples-controls`, `samples-stack`.

**Would fire on 0 site(s)** in 0 repositories:

_none_

**Must NOT fire on 1 site(s)** that match the shape and are correct:

| Repository | Where | |
|---|---|---|
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:771 | CLASS-METHODS parameter TYPE numeric - the transpiler falls back to Packed({length: 8, decimals: 2}), transpiled correctly |

**Where the detector is an approximation of the rule:**

- Only parameters are counted: `DATA`, `FIELD-SYMBOLS` and `STATICS` with `TYPE p` are not generic (abaplint gives them p LENGTH 8 DECIMALS 0) and transpile correctly. 1 method parameter(s) `TYPE numeric` and 0 FORM parameter(s) `TYPE p` found.
- An IMPORTING parameter without OPTIONAL and DEFAULT, by reference or VALUE( ), is the one shape that survives a call (the transpiler takes the actual as it is) - but the METHODS metadata still holds the typeTodo, so RTTI on the class fails. Every site counts.
- EVENTS parameters `TYPE p` would hit the same branch and are not counted; none is expected in this corpus.

<!-- probe:end -->
