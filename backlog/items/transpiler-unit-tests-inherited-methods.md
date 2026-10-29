---
target: open-abap
title: 'transpiler: FOR TESTING methods inherited from a local test base class are not listed - a subclass with no methods of its own never runs'
summary: '`getSortedTests( )` in `unit_test.ts` reads `def.methods` of the test class only, so a test class that inherits its `FOR TESTING` methods from a local abstract base (a common pattern for a suite that runs the same tests against two implementations) runs nothing; the playground walks the superclass chain itself'
priority: low
state: filed
filed: https://github.com/abaplint/transpiler/pull/2025
first_seen: 2026-10-22
upstream: abaplint/transpiler
evidence:
  - 'abap2UI5/playground `src/editor/transpile-core.mjs:134-144` (2026-10): ''Listed off the class alone, the subclass had none and never ran'' - the playground collects methods through `superClassName` up to 20 hops'
  - 'read 2026-10-22 in abaplint/transpiler main 53a708f - `packages/transpiler/src/unit_test.ts` `getSortedTests( )` uses the class definition''s own method list'
  - 'prepared 2026-10-22 as `oblomov-dev/fork-transpiler` branch `fix/inherited-test-methods` (7c83a80) on abaplint/transpiler main 53a708f: the change plus tests, green in the package suites and the transpiler''s integration tests; the fourteen prepared branches merged together transpile open-abap-core main 239b817 and pass its whole unit suite (1172 tests); abap2UI5 itself, downported and transpiled with that stack (`node/setup/abap_transpile.json`, open-abap-core pinned at 9c1271b with the compare_tables correction), passes `npm run unit` in full (1558 tests).'
  - 'filed 2026-10-23 as abaplint/transpiler#2025, open, awaiting review'
checked_upstream: 2026-10-29
---

# transpiler: list inherited test methods

## The problem

```abap
CLASS ltc_base DEFINITION ABSTRACT FOR TESTING.
  PROTECTED SECTION. METHODS create ABSTRACT RETURNING VALUE(r) TYPE REF TO zif_x.
  PRIVATE SECTION.   METHODS it_works FOR TESTING.
ENDCLASS.
CLASS ltc_impl_a DEFINITION INHERITING FROM ltc_base FOR TESTING.
  PROTECTED SECTION. METHODS create REDEFINITION.
ENDCLASS.
```

A system runs `it_works` for `ltc_impl_a`. The generated runner lists
the methods of each concrete test class from its own definition
(`unit_test.ts`, `getSortedTests`), so `ltc_impl_a` has none and the
suite is silently empty. The playground re-implements the lookup
through the superclass chain.

## Proposed change

In `getSortedTests( )`, walk `getSuperClass( )` through the local and
global class definitions and collect `FOR TESTING` methods of every
ancestor (a redefinition replaces the ancestor's entry); skip classes
declared `ABSTRACT`. Same in `unitTestScriptOpen`.

## Test

`test/unit.ts`: the snippet above, expecting one test run for
`ltc_impl_a` and none for `ltc_base`.

## How to file

A small PR against abaplint/transpiler.

