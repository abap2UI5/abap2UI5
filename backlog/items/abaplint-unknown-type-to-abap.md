---
target: abaplint
title: 'UnknownType.toABAP( ) throws - and a table type of an unknown row throws through it, with nothing to check first'
summary: 'the type API of the syntax check renders a type as ABAP with toABAP( ); VoidType answers its name, UnknownType throws, and a TableType (or a structure) of an unknown component throws through it - a tool that writes declarations from the types of a program has to wrap every call, since there is containsVoid( ) but no containsUnknown( )'
priority: low
state: open
first_seen: 2026-10-24
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/abap-cloud-gui, report2cloud - hoisting an inline declaration of an event block into an attribute types it with `SyntaxLogic(...).run( )` and `getType( ).toABAP( )`; the 780-report web corpus crashed the converter on one report (kseretis/abap-metrics, a table of a type from a dependency): `Error: unknown, generic: RSEUI_SET not found, lookup` at `UnknownType.toABAP` from `TableType.toABAP`. Fixed in the converter with a try/catch'
  - 'measured 2026-10-24 on @abaplint/core 2.120.75 - `DATA gt_set TYPE STANDARD TABLE OF zunknown_set WITH DEFAULT KEY.` and `DATA gv_one TYPE zunknown_set.` in a program without the type: both `toABAP( )` throw `unknown, generic: ZUNKNOWN_SET not found, lookup`; `unknown_type.js` throws by design, `void_type.js` returns `this.voided`'
---

# UnknownType.toABAP( ) throws

## What happens

`AbstractType.toABAP( )` renders a type as ABAP source - what a refactoring
or a code generator needs to write a declaration for a variable whose type
the syntax check inferred (an inline `DATA( )` moved elsewhere, an extracted
method). Three kinds of type answer differently:

- a known type answers its ABAP;
- `VoidType` (a dependency that is not loaded, but voided by config) answers
  the voided name - `VOIDEDtoABAP` without one;
- `UnknownType` (a name that resolves to nothing) **throws**
  `unknown, generic: <error>`.

A `TableType` or `StructureType` renders its components, so an unknown row
type throws through `TableType.toABAP( )` - from a call on a type that is not
an `UnknownType` itself. The caller cannot ask first: there is
`containsVoid( )`, but nothing that says a type contains an unknown one.

```abap
REPORT zt.
DATA gt_set TYPE STANDARD TABLE OF zunknown_set WITH DEFAULT KEY.
```

```js
const res = new abaplint.SyntaxLogic(reg, obj).run();
const t = res.spaghetti.getTop()...getData().vars["GT_SET"].getType();
t.toABAP();   // throws "unknown, generic: ZUNKNOWN_SET not found, lookup"
```

## The change

Either of:

- `UnknownType.toABAP( )` answers the name it was asked for when it has one
  (`qualifiedName`), as `VoidType` does, or a marker like `toCDS( )`'s
  `abap.TODO_UNKNOWN` - and callers that need to know check `instanceof`;
- or a `containsUnknown( )` beside `containsVoid( )`, so a caller can decide
  before rendering.

## What must not change

`toText( )` and the syntax check's own findings for the unknown type stay as
they are - this is about the rendering API only.
