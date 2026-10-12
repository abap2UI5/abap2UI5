---
target: open-abap
title: 'cl_abap_refdescr=>create( ) leaves kind and type_kind initial - CREATE DATA ... TYPE HANDLE on a table of REF TO <class> dies with CONVT_NO_NUMBER'
summary: open-abap-core's `cl_abap_refdescr=>create( p_referenced_type )` only stores the referenced type; `kind` stays blank instead of `kind_ref` and `type_kind` blank instead of `typekind_oref`/`typekind_dref`, so `kernel_create_data_handle=>call( )` falls through its CASE on `kind` into `ASSERT 1 = 'todo'`, which the runtime reports as `CONVT_NO_NUMBER` - a `TABLE OF REF TO cx_root` built from such a descriptor cannot be created
priority: medium
state: open
first_seen: 2026-10-12
evidence:
  - found 2026-10-12 going through every abap2UI5 unit test that does not run under `npm run unit` - `z2ui5_cl_util_msg` `ltcl_unit_test_msg_mapper->test_rap_other` stands in for RAP's `reported-%other` with `cl_abap_tabledescr=>create( cl_abap_refdescr=>create( CAST cl_abap_classdescr( cl_abap_typedescr=>describe_by_name( 'CX_ROOT' ) ) ) )` inside a structure and `CREATE DATA lr TYPE HANDLE lo_top`; it used to sit behind a `sy-sysid = 'ABC'` guard, which is the runtime's fixed system id
  - measured 2026-10-12 on open-abap-core b2d219d with `@abaplint/runtime` 2.14.3 - `Error: CONVT_NO_NUMBER at toInteger … at kernel_create_data_handle.call (kernel_create_data_handle.clas.mjs:60)`, which is the transpiled `ASSERT 1 = 'todo'` of the `WHEN OTHERS` branch; with `create( )` setting `kind` and `type_kind` (patch below, applied in memory) the test passes
  - the cause, read in `src/rtti/cl_abap_refdescr.clas.abap` at b2d219d - `METHOD create. CREATE OBJECT p_result. p_result->referenced = p_referenced_type. ENDMETHOD.` and nothing else; `cl_abap_typedescr=>describe_by_data( )` sets `kind_ref` and `typekind_dref`/`typekind_oref` for a reference it describes (lines 474-489), `create( )` does not
---

# `cl_abap_refdescr=>create( )` does not describe what it creates

## What happens

```abap
DATA lo_ref TYPE REF TO cl_abap_refdescr.
DATA lo_tab TYPE REF TO cl_abap_tabledescr.
DATA lr     TYPE REF TO data.
lo_ref = cl_abap_refdescr=>create(
  CAST cl_abap_classdescr( cl_abap_typedescr=>describe_by_name( `CX_ROOT` ) ) ).
lo_tab = cl_abap_tabledescr=>create( lo_ref ).
CREATE DATA lr TYPE HANDLE lo_tab.      " a system: a standard table of REF TO cx_root
```

open-abap-core b2d219d:

```
Error: CONVT_NO_NUMBER
    at kernel_create_data_handle.call   (the ASSERT 1 = 'todo' of WHEN OTHERS)
    at kernel_create_data_handle.table
```

`kind` of the descriptor `create( )` returned is blank, so the `CASE
handle->kind` in `kernel_create_data_handle=>call( )` matches none of
`kind_elem`/`kind_struct`/`kind_table`/`kind_ref`. The same descriptor from
`describe_by_data( lr_any )` carries `kind_ref`, and `kernel_create_data_handle=>ref( )`
already handles both `typekind_oref` (an object reference) and the data
reference case.

## Where

`src/rtti/cl_abap_refdescr.clas.abap`:

```abap
METHOD create.
  CREATE OBJECT p_result.
  p_result->referenced = p_referenced_type.
ENDMETHOD.
```

## The fix

```diff
 METHOD create.
   CREATE OBJECT p_result.
   p_result->referenced = p_referenced_type.
+  p_result->kind = cl_abap_typedescr=>kind_ref.
+  IF p_referenced_type->kind = cl_abap_typedescr=>kind_class
+      OR p_referenced_type->kind = cl_abap_typedescr=>kind_intf.
+    p_result->type_kind = cl_abap_typedescr=>typekind_oref.
+  ELSE.
+    p_result->type_kind = cl_abap_typedescr=>typekind_dref.
+  ENDIF.
 ENDMETHOD.
```

(`absolute_name`/`length` could follow what `describe_by_data` sets, but
`kernel_create_data_handle` does not read them.) Measured in memory against
abap2UI5's transpiled tree (2026-10-12): `test_rap_other` passes.

## Repro

The statement block above as a test method, then
`cl_abap_unit_assert=>assert_bound( lr )`. Its sibling: the same with
`cl_abap_elemdescr=>get_string( )` as the referenced type and a
`CREATE DATA` that answers a `REF TO string` row.

## How to file

A PR against open-abap/open-abap-core: the hunk above and a test in
`cl_abap_refdescr.clas.testclasses.abap` (`create( )` of a class reference
and of a data reference, asserted on `kind` and `type_kind`, then
`CREATE DATA … TYPE HANDLE` on a table of each).

1. Search the open-abap-core tracker first and record the date in
   `checked_upstream:`.
2. Open the PR.
3. Set `state: filed` and `filed: <url>` here, run `npm run backlog`, commit.
4. When it merges, bump the open-abap-core pin in abap2UI5, drop the
   `test_rap_other` entry from `node/setup/abap_transpile.json`, delete this
   item.
