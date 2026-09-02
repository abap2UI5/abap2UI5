---
target: open-abap
title: 'cl_abap_typedescr=>describe_by_name does not resolve an absolute type name (\TYPE=STRING, \TYPE-POOL=ABAP\TYPE=ABAP_BOOL)'
summary: 'A system answers describe_by_name( ''\TYPE=STRING'' ) with the string descriptor; the runtime hands the absolute name to CREATE DATA and raises type_not_found - so S-RTTI cannot rebuild a serialized type whose components came from a named structure, and no draft carrying a TYPE HANDLE table restores in the transpiled backend'
priority: medium
state: open
first_seen: 2026-09-02
checked_upstream: 2026-09-02
upstream: open-abap/open-abap-core
evidence:
  - 'S-RTTI (`z2ui5_cl_srt_typedescr=>get_rtti`, mirrored from sandraros/S-RTTI) calls `cl_abap_typedescr=>describe_by_name( absolute_name )` for every component whose absolute name is not anonymous (`\TYPE=%_T...`); the components of a NAMED structure carry `\TYPE=STRING`, `\TYPE=I`, `\TYPE-POOL=ABAP\TYPE=ABAP_BOOL` in the runtime as well'
  - 'probed in node/output: describe_by_name( `STRING` ), ( `I` ), ( `ABAP_BOOL` ), ( `CHAR1` ) resolve; the same names spelled `\TYPE=STRING`, `\TYPE=I`, `\TYPE=ABAP_BOOL`, `\TYPE=CHAR1` raise type_not_found'
  - 'ltcl_test_app_root4->test_tab_ref_gen (z2ui5_cl_ui5_srv_model) was skipped in node/setup/abap_transpile.json for exactly this, and the attribute-shape catalogue (ltcl_test_shapes) hits it on every TYPE HANDLE table built from a named row'
  - 'shimmed locally by node/setup/patch-open-abap-rtti.mjs, applied to the pinned checkout before abap_transpile: a `\TYPE=...` name that is not anonymous is re-entered with the part after the last `\TYPE=`'
---

# cl_abap_typedescr=>describe_by_name and absolute type names

On a system `cl_abap_typedescr=>describe_by_name( )` accepts both spellings
of a type name - the relative one (`STRING`, `ABAP_BOOL`) and the absolute
one RTTI itself hands out in `absolute_name` (`\TYPE=STRING`,
`\TYPE-POOL=ABAP\TYPE=ABAP_BOOL`). The runtime's implementation
(`src/rtti/cl_abap_typedescr.clas.abap`, `describe_by_name`) knows classes
and interfaces by name and otherwise passes the name to `CREATE DATA ... TYPE
(name)`, which understands the relative spelling only.

The absolute spelling is what a serialized descriptor carries: S-RTTI writes
`absolute_name` for every elementary component and resolves it by name when
it rebuilds the type, unless the name is anonymous (`\TYPE=%_T...`). A
TYPE HANDLE table whose line type was built from the components of a named
structure - the shape of every runtime-typed abap2UI5 sample - therefore
serializes fine and cannot be read back in the transpiled backend.

## The shim

`node/setup/patch-open-abap-rtti.mjs` inserts, at the top of
`describe_by_name`, a re-entry with the relative part of an absolute name:

```abap
    IF lv_absolute CP '\TYPE*' AND lv_absolute NA '%'.
      FIND FIRST OCCURRENCE OF '\TYPE=' IN lv_absolute MATCH OFFSET lv_offset.
      IF sy-subrc = 0.
        lv_offset = lv_offset + 6.
        lv_absolute = lv_absolute+lv_offset.
        type = describe_by_name( lv_absolute ).
        RETURN.
      ENDIF.
    ENDIF.
```

`\TYPE-POOL=ABAP\TYPE=ABAP_BOOL` has its first `\TYPE=` after the pool
segment, so the same FIND serves both spellings. The patch is idempotent
(marker comment) and fails loudly when the anchor line moves upstream.

## Removing this

Bump the open-abap-core pin in `node/setup/fetch-deps.mjs` to a SHA that
resolves the absolute spelling, delete `node/setup/patch-open-abap-rtti.mjs`,
take it out of `auto_transpile` in `package.json`, and close this item.
