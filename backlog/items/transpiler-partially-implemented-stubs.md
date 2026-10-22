---
target: open-abap
title: 'transpiler: INTERFACES … PARTIALLY IMPLEMENTED generates no stubs - the first call of an unimplemented interface method is a JS TypeError, where a system answers initial'
summary: 'a test double that declares an interface `PARTIALLY IMPLEMENTED` and implements only the methods it needs works on a system (the missing methods exist and return initial values); the transpiler emits nothing for them, so `lo->b( )` dies with `TypeError: lo.get(...).lif$b is not a function` - every test double in abap2UI5 and the app-template implements every interface method by hand because of it'
priority: medium
state: open
first_seen: 2026-10-22
upstream: abaplint/transpiler
evidence:
  - 'measured 2026-10-22 on abaplint/transpiler main 53a708f with `runFiles`: `INTERFACE lif. METHODS a. METHODS b RETURNING VALUE(r) TYPE i. ENDINTERFACE. CLASS lcl DEFINITION FOR TESTING. PUBLIC SECTION. INTERFACES lif PARTIALLY IMPLEMENTED. ENDCLASS.` implementing only `lif~a`, then `v = lo->b( )` → `TypeError: lo.get(...).lif$b is not a function`; a system answers `v = 0`'
  - 'read in the same checkout: no handling of the `PARTIALLY IMPLEMENTED` flag anywhere under `packages/transpiler/src` (grep -i partially: nothing); `statements/class_implementation.ts` emits only the methods the implementation has'
  - 'abap2UI5 `src/01/01/z2ui5_cl_ui5_srv_draft.clas.testclasses.abap:1-3` (''the transpiled runtime generates no stubs for a PARTIALLY IMPLEMENTED interface''), `src/01/05/z2ui5_cl_ui5_llm_guide.clas.abap:866`, `docs/agents/building-apps.md:830`; found 2026-09-19 in the app-template''s `ltd_client` (`.claude/skills/abap-check/SKILL.md`, section 4); the vscode-extension writes the warning into every generated `check.yml` (`src/scaffold.ts:503-509`) and the mcp-server README (`:540-543`) repeats it'
checked_upstream: 2026-10-22
---

# transpiler: `PARTIALLY IMPLEMENTED` gets no method stubs

## What happens

```abap
INTERFACE lif.
  METHODS a.
  METHODS b RETURNING VALUE(r) TYPE i.
ENDINTERFACE.
CLASS ltd DEFINITION FOR TESTING.
  PUBLIC SECTION.
    INTERFACES lif PARTIALLY IMPLEMENTED.
ENDCLASS.
CLASS ltd IMPLEMENTATION.
  METHOD lif~a. ENDMETHOD.
ENDCLASS.

DATA lo TYPE REF TO lif.
CREATE OBJECT lo TYPE ltd.
DATA(v) = lo->b( ).
" system: v = 0
" transpiler main 53a708f: TypeError: lo.get(...).lif$b is not a function
```

`PARTIALLY IMPLEMENTED` is the ABAP Unit way to write a test double: a
system generates the missing methods as empty. The transpiler emits only
the implemented ones, so the double works until the code under test
calls a method the test did not care about - and then dies with a JS
error no `CATCH` sees, in a place that has nothing to do with the test.
Every abap2UI5 test double implements every method of
`z2ui5_if_client` by hand (30+ methods) because of it, and three
abap2UI5 tool repositories document the trap for their users.

## Proposed change

In `statements/class_implementation.ts` (or the method builder in
`traversal.ts`): for a class whose definition has an `INTERFACES … PARTIALLY
IMPLEMENTED`, emit for every interface method without an implementation
an async method of the alias name that sets its RETURNING/EXPORTING
parameters to initial and returns - the same shape the transpiler emits
for an empty `METHOD … ENDMETHOD`. abaplint's `IInterfaceDefinition`
gives the method list; the flag is on the `InterfaceDef` statement
(`PARTIALLY IMPLEMENTED` token).

## Test

The snippet above in `test/statements/` or `test/unit.ts`, expecting `0`
and no error; and the negative: without `PARTIALLY IMPLEMENTED` abaplint
reports the missing method, as today.

## How to file

An issue against abaplint/transpiler; the PR touches one generator.

