---
target: open-abap
title: 'transpiler: `super->constructor( )` in a class without a superclass fails at runtime - "(intermediate value).constructor_ is not a function"'
summary: 'a class that inherits from nothing but OBJECT and calls `super->constructor( )` in its constructor is transpiled to `await super.constructor_()` in a JS class that extends nothing, where `super.constructor_` is undefined - every CREATE OBJECT of the class throws, where the ABAP call does nothing'
priority: low
state: open
first_seen: 2026-10-24
upstream: abaplint/transpiler
evidence:
  - 'found 2026-10-24 by the start measurement of report2cloud (abap2UI5-addons/abap-cloud-gui, `report2cloud:web --start`) - a report of the open-source web corpus defines `CLASS lcl_range DEFINITION.` (no INHERITING FROM, INTERFACES if_serializable_object) whose constructor begins with `super->constructor( ).`; the converted report fails at its first screen with HTTP 500 "TypeError: (intermediate value).constructor_ is not a function at lcl_range.constructor_"'
  - 'reduced 2026-10-24 with @abaplint/transpiler-cli 2.14.5 and @abaplint/runtime 2.14.5 - `CLASS zcl_tr_super DEFINITION PUBLIC FINAL CREATE PUBLIC.` with `METHODS constructor.` and the body `super->constructor( ). mv = 1.`: abaplint reports no issue, the output holds `class zcl_tr_super {` and `await super.constructor_();`, and `constructor_( )` throws "(intermediate value).constructor_ is not a function"'
  - 'read 2026-10-24 in @abaplint/transpiler 2.14.5 `build/src/statements/call.js` - `if (chainCode.startsWith("await super.constructor(")) chainCode = chainCode.replace("await super.constructor(", "await super.constructor_(");`, with no look at whether the class has a superclass'
---

# transpiler: `super->constructor( )` in a root class fails at runtime

## What happens

```abap
CLASS lcl_range DEFINITION.
  PUBLIC SECTION.
    METHODS constructor.
ENDCLASS.

CLASS lcl_range IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
  ENDMETHOD.
ENDCLASS.

DATA(range) = NEW lcl_range( ).
" transpiled: TypeError "(intermediate value).constructor_ is not a function"
```

Every class inherits from OBJECT. Written code calls `super->constructor( )`
out of habit or after a superclass was removed, and abaplint accepts it.
The transpiled class extends nothing, so `super.constructor_` does not
exist, and every instantiation throws.

## Why

`build/src/statements/call.js` rewrites the call for the JS constructor
convention:

```js
if (chainCode.startsWith("await super.constructor(")) {
  chainCode = chainCode.replace("await super.constructor(", "await super.constructor_(");
}
```

It does not check whether the class has a superclass.

## The change

When the class of the method has no superclass (`getSuperClass( )` of its
definition is undefined), emit nothing for `super->constructor( )`.
OBJECT's constructor has no parameters and does nothing.

## Example

```abap
DATA(range) = NEW lcl_range( ).
cl_abap_unit_assert=>assert_bound( range ).
```
