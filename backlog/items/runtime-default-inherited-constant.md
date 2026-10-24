---
target: open-abap
title: 'DEFAULT with a constant of the superclass: `IMPORTING mode TYPE i DEFAULT false` is `$false`, undefined in JavaScript'
summary: 'a parameter default that names a constant the class inherits, unqualified, is transpiled as the bare identifier $<name> - a ReferenceError when the method is called without that parameter; a constant of the class itself or a qualified one (zcl_super=>false) works'
priority: medium
state: open
first_seen: 2026-10-24
upstream: abaplint/transpiler
evidence:
  - 'abap2UI5-addons/abap-cloud-gui - z2ui5_cl_cgui_gui_textedit inherits true / false from z2ui5_cl_cgui_gui, as cl_gui_textedit does from cl_gui_control; its parameters DEFAULT false / DEFAULT true threw ReferenceError: $false is not defined in the transpiled unit run. They are written z2ui5_cl_cgui_gui=>false now'
  - 'measured 2026-10-24 with @abaplint/transpiler 2.14.3 (API) and transpiler-cli 2.14.5: METHODS run IMPORTING mode TYPE i DEFAULT false in a subclass of a class with CONSTANTS false TYPE i VALUE 0 gives `if (INPUT === undefined || INPUT.mode === undefined) {mode = $false;}`'
---

# DEFAULT with a constant of the superclass

## What happens

```abap
CLASS zcl_base DEFINITION PUBLIC ABSTRACT CREATE PUBLIC.
  PUBLIC SECTION.
    CONSTANTS false TYPE i VALUE 0.
ENDCLASS.

CLASS zcl_sub DEFINITION PUBLIC INHERITING FROM zcl_base CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS run
      IMPORTING mode TYPE i DEFAULT false.
ENDCLASS.
```

`NEW zcl_sub( )->run( )` is fine in ABAP: the default is the inherited constant. The transpiled method reads

```js
if (INPUT === undefined || INPUT.mode === undefined) {mode = $false;}
```

`$false` is not defined - the call throws `ReferenceError: $false is not defined`. The default's name is resolved as a local of the method, not as a constant of the superclass.

## The change

Resolve an unqualified name in a DEFAULT against the class and its superclasses, as a name in the method body is resolved, and write it as the reference to that constant (`abap.Classes['ZCL_BASE'].false`, or whatever the body uses).

## Example

```abap
" in zcl_sub
METHOD test_default.
  run( ).   " no ReferenceError
ENDMETHOD.
```
