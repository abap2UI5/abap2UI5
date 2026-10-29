---
target: abaplint
title: 'The file information of a class has no exceptions of its methods - `exceptions: [], // todo`'
summary: 'getClassDefinition( ) of a class object (the ABAP file information) lists each method with its parameters but always an empty exceptions list, RAISING and classic EXCEPTIONS alike - the parser marks it todo; the syntax-level MethodDefinition has getRaising( ) and getExceptions( ), but needs the full syntax run'
priority: low
state: open
first_seen: 2026-10-24
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/abap-cloud-gui - report2cloud keeps a table of the methods of z2ui5_cl_cgui_frontend (the stand-in for CL_GUI_FRONTEND_SERVICES) with their parameters and classic exceptions, and a test compares it with the class; the file information gave the parameters but no exceptions, so the test parses the definition text itself'
  - 'measured 2026-10-24 on @abaplint/core 2.120.75 - a class with `CLASS-METHODS up EXCEPTIONS file_open_error not_found.` and `CLASS-METHODS down RAISING cx_static_check.`: `getClassDefinition( ).methods[ ].exceptions` is `[]` for both; `getDefinition( ).getMethodDefinitions( )` answers `getExceptions( )` = file_open_error, not_found and `getRaising( )` = cx_static_check'
  - '`src/abap/4_file_information/abap_file_information_parser.js` line 342 - `exceptions: [], // todo`'
---

# The file information has no exceptions of the methods

## What happens

`ABAPFileInformation` - what `getClassDefinition( )` of a class object answers
without a syntax run - describes each method: name, visibility, parameters,
and `exceptions`. The parser fills that last one with an empty array and a
`// todo`, so a class's methods always look as if they raised nothing:

```abap
CLASS zcl_probe DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS up EXCEPTIONS file_open_error not_found.
    CLASS-METHODS down RAISING cx_static_check.
ENDCLASS.
```

```js
reg.getFirstObject().getClassDefinition().methods
// [ { name: "up", ..., exceptions: [] }, { name: "down", ..., exceptions: [] } ]
```

The syntax-level `MethodDefinition` has both (`getRaising( )`,
`getExceptions( )`), but it needs a syntax run of the object - more than a
tool that reads a class's interface wants.

## The change

Fill `exceptions` in the file information parser from the method definition
statement: the `RAISING` classes, and - as a second list, since they are
different things - the classic `EXCEPTIONS` names (`exceptions` and
`classicExceptions`, say).
