---
target: open-abap
title: 'IMPORTING by reference: a typed parameter is copied when the type name of the actual differs - `REF #( )` of it is not the actual'
summary: 'the transpiled method copies a non-generic IMPORTING parameter passed by reference when the qualified name of the actual is not the one of the formal - a `c LENGTH 1` passed to `TYPE abap_bool` arrives as a copy, so a reference to the parameter (`client->_bind( val )`, `REF #( val )`) points to the copy, where ABAP passes the actual itself because the two types are compatible'
priority: medium
state: open
first_seen: 2026-10-24
upstream: abaplint/transpiler
evidence:
  - 'abap2UI5-addons/abap-cloud-gui - the runtime test of a converted dynpro: `screen->checkbox( val = gv_window )` with `DATA gv_window TYPE c LENGTH 1` and `checkbox( IMPORTING val TYPE abap_bool )`; the selection-screen builder binds `client->_bind( val )`, and the transpiled backend answered BINDING_ERROR "No class attribute for binding found". The converter now declares such fields `TYPE abap_bool`'
  - 'read 2026-10-24 in @abaplint/transpiler 2.14.5 (bundled in transpiler-cli) - `build/src/statements/method_implementation.js`: for an IMPORTING parameter without default, not optional, not by value and not generic it writes `if (val?.getQualifiedName === undefined || val.getQualifiedName() !== "ABAP_BOOL") { val = undefined; }` and then `if (val === undefined) { val = new abap.types.Character(1, ...).set(INPUT.val); }`'
  - 're-measured 2026-10-29 on abaplint/transpiler main ca16f9f (2.14.15) with the repository''s test harness - unchanged, the repro in the evidence above still fails the same way'
---

# IMPORTING by reference: a copy when the type name differs

## What happens

```abap
CLASS lcl DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS same
      IMPORTING val           TYPE abap_bool
                ref           TYPE REF TO data
      RETURNING VALUE(result) TYPE abap_bool.
ENDCLASS.

CLASS lcl IMPLEMENTATION.
  METHOD same.
    result = xsdbool( REF #( val ) = ref ).
  ENDMETHOD.
ENDCLASS.

DATA flag TYPE c LENGTH 1.
" ABAP: abap_true - val is flag itself
" transpiled: abap_false - val is a copy of flag
DATA(is_same) = lcl=>same( val = flag
                           ref = REF #( flag ) ).
```

An IMPORTING parameter without VALUE( ) is passed by reference. A typed
formal parameter needs an actual of a compatible type, and `c LENGTH 1`
is compatible with `abap_bool` (both are `c` of length 1). ABAP then hands
the actual itself to the method. The transpiled method compares the
*qualified name* of the actual's type with the formal's (`ABAP_BOOL`). When
they differ (an anonymous `c LENGTH 1`, `char1`, `flag`, `xfeld`) it creates
a new `Character(1)` and sets it from the actual. Values read the same, but
everything that works with the parameter's address does not: `REF #( val )`,
`GET REFERENCE OF val`, and in abap2UI5 `client->_bind( val )`, which finds
the attribute of the app by its reference.

## The change

In `method_implementation.js`, copy only when the actual is not compatible
with the formal by its technical type (the class, the length and the
decimals for the elementary types), not when only the qualified name
differs. Keep the copy for a conversion a real system would also refuse or
convert, such as a literal or a type of another length.

## Example

```abap
cl_abap_unit_assert=>assert_true( lcl=>same( val = flag
                                             ref = REF #( flag ) ) ).
```
