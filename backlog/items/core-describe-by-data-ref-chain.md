---
target: open-abap
title: 'cl_abap_typedescr=>describe_by_data_ref( ) dies on a reference to a reference - `TypeError: Cannot read properties of undefined (reading ''constructor'')`'
summary: open-abap-core's `describe_by_data_ref( )` dereferences once and calls `describe_by_data( <ref> )`; when the value behind the reference is itself a `REF TO data` (`CREATE DATA mr TYPE REF TO data`, then `CREATE DATA mr->* TYPE string`), `describe_by_data( )` reaches into the inner `DataReference` and reads `.constructor` of a pointer that is not an ABAP type - a JS TypeError no CATCH sees. A system answers a `cl_abap_refdescr` whose referenced type is the inner reference
priority: medium
state: filed
filed: https://github.com/open-abap/open-abap-core/pull/1312
checked_upstream: 2026-10-13
first_seen: 2026-10-12
evidence:
  - the test abap2UI5 skips for it - `z2ui5_cl_ui5_srv_model` `ltcl_05_draft->dref_chain_survives` (`node/setup/abap_transpile.json`) builds `mr_ref_ref TYPE REF TO data`, `CREATE DATA mr_ref_ref TYPE REF TO data`, assigns `mr_ref_ref->*` and `CREATE DATA <inner> TYPE string`, then binds the inner reference; the framework's `rtti_get_typedescr_by_data_ref( )` describes it on the way
  - re-verified 2026-10-12 on open-abap-core b2d219d with `@abaplint/runtime` 2.14.3 - `TypeError: Cannot read properties of undefined (reading 'constructor') at cl_abap_typedescr.describe_by_data (cl_abap_typedescr.clas.mjs:441) … at cl_abap_typedescr.describe_by_data_ref (:321) at z2ui5_cl_ui5_util_context.rtti_get_typedescr_by_data_ref`; the first stop of that test, `CREATE DATA … TYPE REF TO data` itself, was fixed by abaplint/transpiler#1852 (re-checked 2026-09-25 on 2.13.91)
  - the cause, read in `src/rtti/cl_abap_typedescr.clas.abap` at b2d219d - `describe_by_data_ref` is `ASSIGN p_data_ref->* TO <ref>. type = describe_by_data( <ref> ).`; `describe_by_data` recognises a `DataReference` value by `@KERNEL` inspection of the pointer's constructor and, for a reference whose pointer is a `DataReference` again, reads `getPointer().constructor` of a pointer that is `undefined` while the inner reference is unbound, and of the wrong level once it is bound
---

# `describe_by_data_ref( )` on a `REF TO REF TO data`

## What happens

```abap
DATA mr_ref_ref TYPE REF TO data.
FIELD-SYMBOLS <inner> TYPE REF TO data.
FIELD-SYMBOLS <elem>  TYPE any.

CREATE DATA mr_ref_ref TYPE REF TO data.   " since abaplint/transpiler#1852: fine
ASSIGN mr_ref_ref->* TO <inner>.
CREATE DATA <inner> TYPE string.
ASSIGN <inner>->* TO <elem>.
<elem> = `ref-ref`.

DATA(lo_descr) = cl_abap_typedescr=>describe_by_data_ref( mr_ref_ref ).
" system: a cl_abap_refdescr, get_referenced_type( ) a cl_abap_refdescr, whose referenced type is string
```

open-abap-core b2d219d:

```
TypeError: Cannot read properties of undefined (reading 'constructor')
    at cl_abap_typedescr.describe_by_data (cl_abap_typedescr.clas.mjs:441)
    at cl_abap_typedescr.describe_by_data_ref
```

A JS `TypeError` is no ABAP exception; abap2UI5's `CATCH cx_root` around
the call does not see it and the roundtrip dies.

## Where

`src/rtti/cl_abap_typedescr.clas.abap`:

- `describe_by_data_ref` dereferences once and hands the value to
  `describe_by_data`.
- `describe_by_data`, the `DataReference` branch (around line 460-490):
  it builds the `cl_abap_refdescr` for the reference and describes the
  referenced value by its pointer's constructor name. When that value is a
  `DataReference` again, the `@KERNEL` line reads `getPointer().constructor`
  of the inner reference's pointer - `undefined` while unbound - instead of
  describing the inner reference as a `kind_ref`/`typekind_dref` type.

## The fix

In the `DataReference` branch of `describe_by_data`: when the referenced
value is a `DataReference` itself, answer a `cl_abap_refdescr` with
`kind_ref`, `type_kind = typekind_dref` and, as its referenced type, the
descriptor of the generic `data` (`cl_abap_refdescr=>get_ref_to_data( )`
answers that shape), without touching the inner pointer. Recursion into the
inner value is what a system does not do either: `describe_by_data_ref( )`
of a `REF TO REF TO data` is a refdescr of a refdescr of `data`, and the
inner reference's current target is not part of the type.

## Repro

The statement block above as a test, then

```abap
DATA lo_ref TYPE REF TO cl_abap_refdescr.
lo_ref ?= cl_abap_typedescr=>describe_by_data_ref( mr_ref_ref ).
cl_abap_unit_assert=>assert_equals( act = lo_ref->kind exp = cl_abap_typedescr=>kind_ref ).
lo_ref ?= lo_ref->get_referenced_type( ).
cl_abap_unit_assert=>assert_equals( act = lo_ref->kind exp = cl_abap_typedescr=>kind_ref ).
```

## How to file

An issue against open-abap/open-abap-core with the repro; a PR if the
`describe_by_data` branch turns out as small as the sketch above (the
`@KERNEL` line and the two constants). Mention abaplint/transpiler#1852 as
the first half, already merged.

1. Search the open-abap-core tracker first and record the date in
   `checked_upstream:`.
2. Open the issue or the PR.
3. Set `state: filed` and `filed: <url>` here, run `npm run backlog`, commit.
4. When it merges, bump the open-abap-core pin in abap2UI5, drop the
   `dref_chain_survives` entry from `node/setup/abap_transpile.json`, delete
   this item.
