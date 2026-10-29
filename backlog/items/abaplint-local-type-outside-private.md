---
target: abaplint
title: 'A local type of the class pool used outside the PRIVATE SECTION of the global class'
summary: 'the types, classes and interfaces of a class pool''s local definitions (locals_def, the CCDEF include) may only type components of the PRIVATE SECTION of the global class - a PUBLIC or PROTECTED attribute, parameter or type built on one is a syntax error on the system, and check_syntax reports nothing'
priority: medium
state: open
first_seen: 2026-10-24
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/abap-cloud-gui, report2cloud (tools/report2cloud/lib/convert.mjs, planLocalTypes( )) - a converted report''s globals typed with its local classes became PUBLIC attributes typed with a type of locals_def; every gate (v750, ABAP Cloud, 7.02, the transpiled ABAP Unit run) was green. The converter now moves such globals into the PRIVATE SECTION, which the gates cannot check either'
  - 'measured 2026-10-24 on abaplint 2.120.75, v750 and ABAP Cloud configs of abap-cloud-gui, an isolated class pool: PUBLIC `DATA mt_row TYPE ty_t_row.` and `DATA mo_helper TYPE REF TO lcl_helper.`, PROTECTED `DATA mv_row TYPE ty_s_row.` - all three types from the class''s locals_def - produce no finding but unused_variables'
---

# A local type of the class pool used outside the PRIVATE SECTION

## What happens

The local definitions of a class pool - the include abapGit writes as
`<class>.clas.locals_def.abap` (CCDEF, "class-relevant local types") - are
read before the definition of the global class, so its components may use
them. But only its **private** components: the public and protected parts of
a global class are visible to other programs, which cannot see the local
types of the pool. The ABAP keyword documentation, *Class Pools*: the local
types of the include for class-relevant local definitions can be referenced
in the private visibility section of the global class.

```abap
" zcl_x.clas.locals_def.abap
TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.
CLASS lcl_helper DEFINITION.
ENDCLASS.

" zcl_x.clas.abap
CLASS zcl_x DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    DATA mt_row    TYPE ty_t_row.               " syntax error on the system
    DATA mo_helper TYPE REF TO lcl_helper.      " syntax error on the system
  PROTECTED SECTION.
    DATA mv_row    TYPE ty_s_row.               " syntax error on the system
  PRIVATE SECTION.
    DATA mv_ok     TYPE ty_s_row.               " fine
ENDCLASS.
```

`check_syntax` resolves the three types and reports nothing, so a class pool
the system does not activate passes every abaplint gate - and the transpiler
makes every member a JS property, so a transpiled unit run is green as well.

## The change

In `check_syntax` (or a rule of its own), report a component of the PUBLIC or
PROTECTED SECTION of a global class - `DATA`, `CLASS-DATA`, `CONSTANTS`,
`TYPES`, a method parameter or its `RAISING` - whose type is, or is built
on, a type, class or interface defined in the class pool's local
definitions.

## What it must NOT report

- The same types in the PRIVATE SECTION, and anywhere in the implementation
  (locals_imp, the method bodies, the test classes).
- Types of the global class itself (`TYPES` of its public section) used in
  locals_def - the other direction is legal.
- A local class or interface that is only `DEFINITION DEFERRED` in locals_def
  and used in the PRIVATE SECTION.
- Types of other global classes or interfaces, and DDIC types, wherever they
  stand.

## Example

```abap
" bad - PUBLIC SECTION
DATA mo_helper TYPE REF TO lcl_helper.

" good - PRIVATE SECTION, or a type the global class declares itself
PRIVATE SECTION.
  DATA mo_helper TYPE REF TO lcl_helper.
```
