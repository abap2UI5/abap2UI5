---
target: open-abap
title: 'runtime: CREATE DATA ... TYPE (name) knows the built-in types in upper case only - `TYPE (''utclong'')` raises CX_SY_CREATE_DATA_ERROR'
summary: the runtime's `statements/create_data.js` compares a dynamic type name against `"UTCLONG"`, `"STRING"`, `"I"`, … as written, so `CREATE DATA lr TYPE ('utclong')` - valid on a system, where names are not case-sensitive - raises CX_SY_CREATE_DATA_ERROR; ajson guards its `set_utclong` test with exactly that TRY and skips it under the runtime for no reason
priority: medium
state: filed
filed: https://github.com/abaplint/transpiler/pull/1998
first_seen: 2026-10-12
upstream: abaplint/transpiler
evidence:
  - found 2026-10-12 going through every abap2UI5 unit test that does not run under `npm run unit` - `z2ui5_cl_ajson` `ltcl_writer_test->set_utclong` probes `CREATE DATA lr_utclong TYPE ('utclong')` in a TRY and returns on the exception ("type utclong is not availble in lower releases"), and under the runtime the exception fires although the type exists
  - measured 2026-10-12 on `@abaplint/runtime` 2.14.3 (abap2UI5's pin) - `abap.statements.createData(ref, {name: "utclong"})` throws `cx_sy_create_data_error`, `{name: "UTCLONG"}` assigns a `UTCLong`; with the name upper-cased in the probe (the patch below, applied in memory) the ajson test runs to the end and passes
  - the cause, read in the 2.14.3 package - `build/src/statements/create_data.js` in the `options.name` branch compares `options.name.trimEnd()` against the literals `"ABAP_BOOL"`, `"STRING"`, `"XSTRING"`, `"UTCLONG"`, `"I"`, `"T"`, `"D"`, `"F"`, `"INT8"` without changing the case, while the `=>` branch next to it upper-cases its class name
checked_upstream: 2026-10-13
---

# runtime: `CREATE DATA ... TYPE (name)` with a lower-case built-in type name

## What happens

```abap
DATA lr TYPE REF TO data.
CREATE DATA lr TYPE ('utclong').   " a system: fine - names are not case-sensitive
```

`@abaplint/runtime` 2.14.3 raises `CX_SY_CREATE_DATA_ERROR`. The same statement
with `'UTCLONG'` works. The transpile is green either way: the name is a
string the transpiler cannot check.

## Where

`packages/runtime/src/statements/create_data.ts`, the `options.name` branch:
the DDIC lookup, the `\TYPE=%` prefix and the built-in names (`ABAP_BOOL`,
`STRING`, `XSTRING`, `UTCLONG`, `I`, `T`, `D`, `F`, `INT8`) all compare the
name as written. The `=>` branch right above already does
`options.name.trimEnd().toUpperCase()` for its class name.

## The fix

Normalise once at the top of the branch:

```diff
   } else if (options?.name !== undefined) {
+    options.name = options.name.trimEnd().toUpperCase();
     if (abap.DDIC[options.name.trimEnd()]) {
```

DDIC names and the anonymous `\TYPE=%` names the runtime generates are upper
case already, so nothing else in the branch changes its answer. Measured in
memory against abap2UI5's transpiled tree (2026-10-12): `set_utclong` of
ajson, skipped by its own guard before, passes.

## Repro

```abap
METHOD create_data_lower_case.
  DATA lr TYPE REF TO data.
  CREATE DATA lr TYPE ('utclong').
  cl_abap_unit_assert=>assert_bound( lr ).
ENDMETHOD.
```

## How to file

A PR against abaplint/transpiler: the one line above in
`packages/runtime/src/statements/create_data.ts` and the test in
`test/statements/create_data.ts` (the file has the `TYPE ('STRING')` cases
to copy).

1. Search the abaplint/transpiler tracker first and record the date in
   `checked_upstream:`.
2. Open the PR.
3. Set `state: filed` and `filed: <url>` here, run `npm run backlog`, commit.
4. When it ships, bump the runtime pin in abap2UI5; the guard in ajson is
   upstream code (`src/00/01`, mirrored) and stays as it is. Delete this item.
