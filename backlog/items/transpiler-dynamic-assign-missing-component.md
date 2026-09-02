---
target: open-abap
title: 'Runtime: a dynamic ASSIGN through a component that does not exist dies with a TypeError on the next segment instead of sy-subrc 4'
summary: '`ASSIGN (''MO_APP->MT_TABLE->*'') TO <fs>` with an object that has no MT_TABLE reads the attribute as undefined and calls `.dereference()` on it for the `*` segment - a TypeError no CATCH cx_root reaches; a system sets sy-subrc 4'
priority: medium
state: open
first_seen: 2026-09-02
checked_upstream: 2026-09-02
upstream: abaplint/transpiler
evidence:
  - '@abaplint/runtime `build/src/statements/assign.js`, the `->` walk: a missing component yields `input.dynamicSource = source[componentName]` = undefined, and the following `*` segment runs `input.dynamicSource.dereference()` unguarded'
  - 'abap2UI5 resolves every draft attribute by such a name (`z2ui5_cl_ui5_srv_model=>attri_get_val_ref`); a host that swapped its REF TO object sub-app for another class between two roundtrips leaves rows that resolve to nothing (sample 338) - skipped on a system, a crash of the restore in the transpiled backend'
  - 'shimmed locally by node/setup/patch-abaplint-runtime-assign.mjs, applied to the installed runtime before abap_transpile: an undefined source at a `*` segment answers sy-subrc 4'
---

# Runtime: dynamic ASSIGN through a missing component

On a system a dynamic `ASSIGN (name) TO <fs>` whose path cannot be followed
sets `sy-subrc = 4` and leaves the field symbol unassigned - whichever
segment fails. The runtime's `assign` walks the `->`/`-` segments and, for a
component the object does not have, stores `undefined` and goes on; the next
`*` segment then calls `.dereference()` on it and the statement throws a
JavaScript TypeError that no ABAP CATCH sees.

## The shim

`node/setup/patch-abaplint-runtime-assign.mjs` guards the `*` segment: an
undefined (or non-dereferenceable) source answers `sy-subrc 4` and returns.
Idempotent (marker comment), and it fails the transpile when the anchor
moves in a newer runtime.

## Removing this

Bump `@abaplint/runtime` in `package.json` to a version that answers subrc 4
here, delete `node/setup/patch-abaplint-runtime-assign.mjs`, take it out of
`auto_transpile` in `package.json`, and close this item.
