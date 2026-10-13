---
target: open-abap
title: 'runtime: ASSIGN COMPONENT with a dash in the name is read as a path - a RAP `%ELEMENT-<field>` component built at runtime is never found'
summary: the runtime's `statements/assign.js` splits every component name at `-` and walks it as a path (`a-b` → component `a`, then its component `b`); a component whose NAME carries a dash, as `cl_abap_structdescr=>create( )` accepts for a RAP-shaped `%ELEMENT-CUSTOMERID` row, is never looked up as one name, and `result?.get()` on the way dies with `TypeError: Cannot read properties of undefined` instead of sy-subrc 4
priority: medium
state: filed
filed: https://github.com/abaplint/transpiler/pull/1996
checked_upstream: 2026-10-13
first_seen: 2026-10-12
upstream: abaplint/transpiler
evidence:
  - found 2026-10-12 going through every abap2UI5 unit test that does not run under `npm run unit` - `z2ui5_cl_util_msg` `ltcl_unit_test_msg_mapper->test_rap_element` builds a RAP `failed` row with `cl_abap_structdescr=>create( )` from components named `%FAIL`, `%ELEMENT-CUSTOMERID`, `%OP-%ACTION-DEDUCTDISCOUNT`, `%PID`, `%CID`, `%TKY` and then `ASSIGN COMPONENT '%ELEMENT-CUSTOMERID' OF STRUCTURE <row>`; the test used to be behind a `sy-sysid = 'ABC'` guard, which is the runtime's fixed system id
  - measured 2026-10-12 on `@abaplint/runtime` 2.14.3 (abap2UI5's pin) - the ASSIGN dies with `TypeError: Cannot read properties of undefined (reading 'get')` in `build/src/statements/assign.js` line 150, the loop over the split name; with the lookup below applied in memory the test passes
  - the cause, read in the 2.14.3 package - `assign.js`, the `input.component` branch for a string component, is `component.toLowerCase().trimEnd().split("-")` followed by `for (const s of split) result = result.get()[s]` - no attempt to find the whole name first, and no guard when an intermediate step is undefined
---

# runtime: `ASSIGN COMPONENT 'A-B' OF STRUCTURE` is only ever a path

## What happens

A structure built at runtime may carry a component whose name has a dash in
it - RAP's `%element-<field>` and `%op-%action-<name>` rows are the common
case, and `cl_abap_structdescr=>create( )` takes such a name:

```abap
lo_row = cl_abap_structdescr=>create( VALUE #(
  ( name = `%FAIL`                type = lo_fail )
  ( name = `%ELEMENT-CUSTOMERID`  type = lo_c1 ) ) ).
CREATE DATA lr TYPE HANDLE lo_row.
ASSIGN lr->* TO <row>.
ASSIGN COMPONENT `%ELEMENT-CUSTOMERID` OF STRUCTURE <row> TO <el>.   " sy-subrc 0 on a system
```

`@abaplint/runtime` 2.14.3 reads the name as the path `%element` →
`customerid`, finds no `%element`, and the next step dereferences
`undefined`:

```
TypeError: Cannot read properties of undefined (reading 'get')
    at assign (@abaplint/runtime/build/src/statements/assign.js:150:33)
```

A JS `TypeError` is not an ABAP exception, so no `CATCH` sees it.

## Where

`packages/runtime/src/statements/assign.ts`, the string-component branch:

```ts
const split = component.toLowerCase().trimEnd().split("-");
result = input.source;
for (const s of split) {
  result = result.get()[s];
}
```

## The fix

The whole name first, the path second, and a missing step on the path is
`sy-subrc 4`, not a TypeError:

```diff
-      const split = component.toLowerCase().trimEnd().split("-");
-      result = input.source;
-      for (const s of split) {
-        result = result.get()[s];
-      }
+      const name = component.toLowerCase().trimEnd();
+      result = input.source.get()[name];
+      if (result === undefined && name.includes("-")) {
+        result = input.source;
+        for (const s of name.split("-")) {
+          result = result?.get()[s];
+        }
+      }
```

`ASSIGN COMPONENT 'A-B'` with a nested structure `A` keeps working (the
whole name misses, the path hits). Measured in memory against abap2UI5's
transpiled tree (2026-10-12): `test_rap_element` passes.

## Repro

```abap
METHOD assign_component_dash.
  DATA lo_row TYPE REF TO cl_abap_structdescr.
  DATA lr     TYPE REF TO data.
  FIELD-SYMBOLS <row> TYPE any.
  FIELD-SYMBOLS <el>  TYPE any.
  lo_row = cl_abap_structdescr=>create( VALUE #(
    ( name = `%ELEMENT-CUSTOMERID` type = cl_abap_elemdescr=>get_c( p_length = 1 ) ) ) ).
  CREATE DATA lr TYPE HANDLE lo_row.
  ASSIGN lr->* TO <row>.
  ASSIGN COMPONENT `%ELEMENT-CUSTOMERID` OF STRUCTURE <row> TO <el>.
  cl_abap_unit_assert=>assert_subrc( exp = 0 ).
ENDMETHOD.
```

## How to file

A PR against abaplint/transpiler: the hunk above in
`packages/runtime/src/statements/assign.ts` and a test in
`test/statements/assign.ts` next to the existing `ASSIGN COMPONENT` cases
(one with the dash as a name, one with the dash as a path, one missing).

1. Search the abaplint/transpiler tracker first and record the date in
   `checked_upstream:`.
2. Open the PR.
3. Set `state: filed` and `filed: <url>` here, run `npm run backlog`, commit.
4. When it ships, bump the runtime pin in abap2UI5, drop the
   `test_rap_element` entry from `node/setup/abap_transpile.json`, delete
   this item.
