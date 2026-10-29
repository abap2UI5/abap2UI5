---
target: open-abap
title: 'runtime: `SYST` is no type by name - `CREATE DATA ... TYPE (''SYST'')` and `describe_by_name( ''SYST'' )` fail although `sy` is there'
summary: 'the dynamic type lookup of `CREATE DATA` knows the DDIC entries and a short list of built-in names (`ABAP_BOOL`, `STRING`, `I`, ...), and `SYST` is neither - `abap.DDIC` has no entry for it and open-abap-core ships no TABL - so `CREATE DATA` raises `cx_sy_create_data_error` and `cl_abap_typedescr=>describe_by_name( ''SYST'' )`, which goes through it, raises `type_not_found`, while the structure itself exists as `abap.builtin.sy`'
priority: medium
state: open
first_seen: 2026-10-22
upstream: abaplint/transpiler
evidence:
  - 'abap2UI5/samples - `Z2UI5_CL_SMP_APP_061` builds its runtime table from `CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_name( `SYST` ) )` since it stopped typing it from the framework draft table (2026-10-22). Its first start in the e2e smoke answers HTTP 500 "Error at cl_abap_typedescr.describe_by_name": on 2026-10-22 against abap2UI5 2dd4363 (@abaplint/runtime 2.13.99, run 39853610987 of the samples e2e workflow) and on 2026-10-24 against 52976a7 (@abaplint/runtime 2.14.5). The samples e2e records it in `e2e/expected.mjs`'
  - 'measured 2026-10-24 on the transpiled abap2UI5 (`node/output`, @abaplint/runtime 2.14.5) - `"SYST" in abap.DDIC` is false, `abap.builtin.sy` holds the 30 fields; `abap.statements.createData( ref, { name: "SYST" } )` raises `cx_sy_create_data_error`, the same call with `ABAP_BOOL` and `ABAP_BOOLEAN` succeeds'
  - 'read 2026-10-24 in @abaplint/runtime 2.14.5 - `build/src/statements/create_data.js`, the `options.name` branch: `abap.DDIC[name]`, then `=>` names, `\TYPE=%` names, then `ABAP_BOOL`, `STRING`, `XSTRING`, `UTCLONG`, `I`, `T`, `D`, `F`, `INT8`, then a class name. No branch for `SYST`. 2.13.99 has none of the built-in names in that function. open-abap-core has no `syst.tabl.xml` at b2d219d nor at 9c1271b (the pins of abap2UI5 before and after 2026-10-23)'
  - 'open-abap-core `cl_abap_typedescr.clas.abap` `describe_by_name( )`: for a name that is no class or interface it runs `CREATE DATA ref TYPE (p_name)` and turns `cx_sy_create_data_error` into `type_not_found` - so the RTTI half fails through the same lookup'
  - 'measured 2026-10-24 with the change below patched into @abaplint/runtime 2.14.5 `create_data.js` (and taken out again) - `cl_abap_typedescr=>describe_by_name( ''SYST'' )` on the transpiled abap2UI5 answers kind `S` with 30 components, `ABCDE`, `DATLO`, `DATUM` first'
  - 're-measured 2026-10-29 on abaplint/transpiler main ca16f9f (2.14.15) with the repository''s test harness - unchanged, the repro in the evidence above still fails the same way'
---

# runtime: `SYST` is no type by name

## What happens

```abap
DATA(type) = cl_abap_typedescr=>describe_by_name( `SYST` ).
" system:     a cl_abap_structdescr with the components of sy
" transpiled: exception type_not_found

DATA ref TYPE REF TO data.
CREATE DATA ref TYPE (`SYST`).
" system:     a data object of the structure SYST
" transpiled: cx_sy_create_data_error
```

`SYST` is the DDIC structure behind `sy`, present on every release, ABAP
Cloud included. That makes it the obvious structure to build a runtime
type or a sample table from when an app must not depend on a table of its
own. The transpiled runtime has the structure (`abap.builtin.sy`), but not
under its name.

## Why

`CREATE DATA ... TYPE (name)` resolves the name in
`build/src/statements/create_data.js`: a DDIC entry first (`abap.DDIC`, filled
from the TABL/DTEL objects of the transpiled input and of open-abap-core),
then a short list of built-in names. `SYST` is neither: open-abap-core
ships no `syst.tabl.xml`, and the list has no `SYST`. `describe_by_name( )`
in open-abap-core creates the data object the same way and reports the
failure as `type_not_found`.

## The change

In `create_data.js`, resolve `SYST` to a copy of the structure the runtime
already has, next to the other built-in names:

```js
else if (name === "SYST") {
  target.assign(abap.builtin.sy.clone());
}
```

`describe_by_name( 'SYST' )` then answers a `cl_abap_structdescr` with the
components of `sy`, like a system. The other way, a `syst.tabl.xml` in
open-abap-core, would describe the structure a second time next to the one
the runtime defines, and the two could drift.

## Example

```abap
DATA(struct) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_name( `SYST` ) ).
cl_abap_unit_assert=>assert_not_initial( struct->get_components( ) ).
```
