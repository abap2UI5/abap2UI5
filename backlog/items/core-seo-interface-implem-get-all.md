---
target: open-abap
title: 'no way to find the classes implementing an interface - SEO_INTERFACE_IMPLEM_GET_ALL is not in open-abap-core, and CL_OO_* has no stand-in either'
summary: abap2UI5 looks its user exit and its roundtrip monitor up by interface (`z2ui5_cl_ui5_util_context=>rtti_get_classes_intf_std`, the function module `SEO_INTERFACE_IMPLEM_GET_ALL` on standard ABAP, XCO on cloud); open-abap-core has neither, so the dynamic CALL FUNCTION raises `cx_sy_dyn_call_illegal_func` and every lookup-found branch of both services stays cold under `npm run unit` - a function module over `abap.Classes` (every transpiled class lists its `IMPLEMENTED_INTERFACES`) would answer it
priority: medium
state: filed
filed: https://github.com/open-abap/open-abap-core/pull/1327
first_seen: 2026-10-13
evidence:
  - found 2026-10-13 writing the tests of `z2ui5_cl_ui5_srv_monitor` - `monitor_class_lookup( )` raises `cx_sy_dyn_call_illegal_func` out of `z2ui5_cl_ui5_util_context=>rtti_get_classes_intf_std` under `@abaplint/runtime` 2.14.3 / open-abap-core b2d219d; the service catches it (fail open), so the branches that instantiate and latch a found class never run, and `npm run coverage` reports the class at 62% with the switch, latch and fail-open tested
  - the same read is `z2ui5_cl_ui5_user_exit=>exit_class_lookup( )` - the branches that find an exit class, prefer it over the shipped default and fall back to the superseded `z2ui5_if_exit` are cold for the same reason (user_exit at 87%)
  - open-abap-core b2d219d has no `seo_interface_implem_get_all.fugr`, no `cl_oo_interface` and nothing in `src/oo/` that lists the implementers of an interface; the runtime knows them - every transpiled class carries `static IMPLEMENTED_INTERFACES = [...]` and `abap.Classes` holds every loaded class
  - 'prepared 2026-10-23 as `oblomov-dev/fork-open-abap-core` branch `feat/seo-interface-implem-get-all` (dbfa2ef) on open-abap-core main fde8095: the function module in the OPENABAP group over abap.Classes (IMPLEMENTED_INTERFACES), with SEOCLSKEY / SEOR_IMPLEMENTING_KEYS stand-ins, exceptions NOT_EXISTING and IS_CLASS, five tests; core suite 1177 green, abaplint clean; abap2UI5''s transpiled suite with it in the pinned core: 1558 green. Global classes only, local test classes are registered under prefixed names and skipped, as on a system'
  - 'filed 2026-10-23 as open-abap/open-abap-core#1327, open, awaiting review'
  - 'review on open-abap/open-abap-core#1327 (larshp, 2026-10-23): add to open-abap/open-abap-seo instead - ported there as `oblomov-dev/fork-open-abap-seo` branch `feat/seo-interface-implem-get-all` (5dbe945): function group SEO, the two missing DDIC types, test class, and the abap_transpile.json that repository lacked; transpile plus unit 5 of 5 green, abaplint 0 issues'
checked_upstream: 2026-10-23
---

# Finding the implementers of an interface in the runtime

## What happens

```abap
DATA lt_impl TYPE STANDARD TABLE OF seo_relkeys.   " or any table of clsname
CALL FUNCTION 'SEO_INTERFACE_IMPLEM_GET_ALL'
  EXPORTING
    intkey       = ls_intkey      " clsname = 'Z2UI5_IF_UI5_MONITOR'
  IMPORTING
    impkeys      = lt_impl
  EXCEPTIONS
    not_existing = 1
    OTHERS       = 2.
```

open-abap-core b2d219d: `cx_sy_dyn_call_illegal_func` from the dynamic
`CALL FUNCTION` - the function module does not exist. abap2UI5 catches it
and runs without an exit class and without a monitor, which is correct
behaviour for "no repository" and leaves both lookups untestable in the
runtime.

## Where

abap2UI5 `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`,
`rtti_get_classes_intf_std` (standard ABAP) and `rtti_get_classes_intf_cloud`
(XCO). The callers: `z2ui5_cl_ui5_user_exit=>exit_class_lookup`,
`z2ui5_cl_ui5_srv_monitor=>monitor_class_lookup`.

## The fix

A function group `seo_interface_implem_get_all` in open-abap-core whose
one module walks `abap.Classes` in a `@KERNEL` block and returns every class
whose `IMPLEMENTED_INTERFACES` names the interface, as `seo_relkeys` rows
(`clsname`, `refclsname`). Interfaces of a superclass count on a system;
`STATIC_SUPER` gives the chain here. The `not_existing` exception when the
interface itself is not in `abap.Classes`.

## Repro

```abap
METHOD implementers.
  DATA ls_key  TYPE seoclskey.
  DATA lt_impl TYPE seor_implementing_keys.
  ls_key-clsname = `IF_SERIALIZABLE_OBJECT`.
  CALL FUNCTION 'SEO_INTERFACE_IMPLEM_GET_ALL'
    EXPORTING intkey = ls_key
    IMPORTING impkeys = lt_impl
    EXCEPTIONS not_existing = 1 OTHERS = 2.
  cl_abap_unit_assert=>assert_subrc( ).
ENDMETHOD.
```

## How to file

An issue against open-abap/open-abap-core with the repro; a PR with the
function group if wanted - `src/oo/` is where `reposrc.tabl.xml` and the
other repository stand-ins live.

1. Search the open-abap-core tracker first and record the date in
   `checked_upstream:`.
2. Open the issue or the PR.
3. Set `state: filed` and `filed: <url>` here, run `npm run backlog`, commit.
4. When it merges, bump the open-abap-core pin in abap2UI5; the monitor and
   exit tests then run their lookup-found branches by themselves. Delete
   this item.
