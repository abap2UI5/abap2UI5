---
target: open-abap
title: 'no way to read a method''s source at runtime - neither XCO_CP_ABAP nor CL_OO_FACTORY exist, and REPOSRC is empty'
summary: abap2UI5's `z2ui5_cl_util_ext=>source_get_method( )` reads a method's source through `XCO_CP_ABAP=>CLASS( )` (cloud) with `CL_OO_FACTORY=>CREATE_INSTANCE( )->CREATE_CLIF_SOURCE( )` (on-prem) as the fallback; open-abap-core has neither class, and the transpiler can populate `REPOSRC` but abap2UI5 switches it off (`populateTables.reposrc: false`). A stub of `CL_OO_FACTORY` / `IF_OO_CLIF_SOURCE` over `REPOSRC` would make the source readable in the runtime
priority: low
state: open
first_seen: 2026-10-12
evidence:
  - the test abap2UI5 skips for it - `z2ui5_cl_util_ext` `ltcl_source_ops->source_get_method_basic` (`node/setup/abap_transpile.json`), which reads `Z2UI5_CL_UTIL=>C_TRIM`
  - measured 2026-10-12 on open-abap-core b2d219d with `@abaplint/runtime` 2.14.3 - `cx_sy_dyn_call_illegal_method` out of `dynamicCallLookup` for `XCO_CP_ABAP`, then the same for `CL_OO_FACTORY` in the CATCH
  - open-abap-core b2d219d has `src/oo/reposrc.tabl.xml` (the table) and no `cl_oo_factory`, `if_oo_clif_source` or `xco_cp_abap`; `@abaplint/transpiler` fills `REPOSRC` with every transpiled class's source when `populateTables.reposrc` is on
---

# Reading a method's source in the runtime

## What happens

```abap
DATA(lt_source) = z2ui5_cl_util_ext=>source_get_method(
    iv_classname  = `Z2UI5_CL_UTIL`
    iv_methodname = `C_TRIM` ).
```

`cx_sy_dyn_call_illegal_method` for `XCO_CP_ABAP`, then for `CL_OO_FACTORY`.
The runtime has neither API, and the only table a source could come from,
`REPOSRC`, is empty in abap2UI5's transpile (the option is off because
every class's source in the SQLite database costs boot time).

## The fix, if one is wanted

A stub in open-abap-core: `cl_oo_factory=>create_instance( )` answering an
object whose `if_oo_clif_source_factory~create_clif_source( clif_name )`
reads `REPOSRC` for the class pool's includes and whose
`if_oo_clif_source~get_source( )` returns the lines. `REPOSRC` holds the
rows when the transpile populates it, so the stub needs no new storage.
abap2UI5 would switch `populateTables.reposrc` on for the unit suite only
if that stub exists.

## Why it is low priority here

One utility of the frozen `src/99` package, and one test. Nothing in the
engine reads source at runtime.

## How to file

An issue against open-abap/open-abap-core, as a request: the two interfaces
and the factory, with the repro above. A PR only after agreement that the
API belongs there.

1. Search the open-abap-core tracker first and record the date in
   `checked_upstream:`.
2. Open the issue.
3. Set `state: filed` and `filed: <url>` here, run `npm run backlog`, commit.
4. When it ships, switch `populateTables.reposrc` on in
   `node/setup/abap_transpile.json`, drop the skip, delete this item.
