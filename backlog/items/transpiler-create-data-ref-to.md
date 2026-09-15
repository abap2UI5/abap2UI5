---
target: open-abap
title: '`CREATE DATA ... TYPE REF TO <x>` fails when the type is written statically, and fails uncatchably'
summary: 'only the dynamic `TYPE REF TO (name)` spelling is handled; the static `TYPE REF TO data` and `TYPE REF TO <class>` fall through createData''s typeName switch and die in a plain `throw new Error`, which no `CATCH cx_root` can absorb'
priority: medium
state: open
first_seen: 2026-09-15
checked_upstream: 2026-09-15
patch: backlog/patches/transpiler-create-data-ref-to.patch
upstream: abaplint/transpiler
evidence:
  - 'measured 2026-09-15 against transpiler 7a1f20b with open-abap-core c4bb873, one class, four statements: `CREATE DATA lr TYPE REF TO (name)` works; `CREATE DATA lr TYPE REF TO data` gives `Error: CREATE DATA, unknown type DATA`; `CREATE DATA lr TYPE REF TO cl_abap_typedescr` gives `Error: CREATE DATA, unknown type CL_ABAP_TYPEDESCR`'
  - 'the codegen is not at fault - packages/transpiler emits `{"typeName": "DATA", "refTo": true}` for the static form. packages/runtime/src/statements/create_data.ts reads `refTo` only in its `options.name` branch; the `options.typeName` switch has no such case, so every static spelling reaches `default:` and its final `throw new Error("CREATE DATA, unknown type " + options.typeName)`'
  - 'that throw is a plain JS Error, not `throwError("CX_SY_CREATE_DATA_ERROR")` - wrapped in `TRY ... CATCH cx_root` the statement still takes the process down, where the dynamic branch beside it raises the catchable exception for a name it cannot resolve'
  - 'costs abap2UI5 a skipped test today: `Z2UI5_CL_UI5_SRV_MODEL` / `ltcl_05_draft` / `dref_chain_survives` is in the `skip` list of node/setup/abap_transpile.json with the note "CREATE DATA ... TYPE REF TO data is not supported in the NodeJS runtime (unknown type DATA)"'
  - 'patch attached and verified: 1034 tests pass across every non-database spec, eslint clean, and the four statements above answer 42 / ok / ok / cx_sy_create_data_error raised'
---

# `CREATE DATA ... TYPE REF TO <x>` written statically

## What happens

```abap
DATA lr TYPE REF TO data.
DATA name TYPE string.

name = 'CL_ABAP_TYPEDESCR'.
CREATE DATA lr TYPE REF TO (name).             " ok
CREATE DATA lr TYPE REF TO data.               " Error: CREATE DATA, unknown type DATA
CREATE DATA lr TYPE REF TO cl_abap_typedescr.  " Error: CREATE DATA, unknown type CL_ABAP_TYPEDESCR
```

The dynamic spelling works and the two static ones do not, which is the wrong
way round for how often each is written.

## Current behaviour

`packages/transpiler` emits the right thing either way — the static form is
`{"typeName": "DATA", "refTo": true}`. The gap is one level down, in
`packages/runtime/src/statements/create_data.ts`: `refTo` is read **only** in
the `options.name` branch (the dynamic one). The `options.typeName` switch has
no `refTo` case, so a static `TYPE REF TO` falls past every `case` into

```ts
} else {
  throw new Error("CREATE DATA, unknown type " + options.typeName);
}
```

Two defects, worth separating:

1. the statement does not work; and
2. it fails **uncatchably**. That is a plain `throw new Error`, not
   `throwError("CX_SY_CREATE_DATA_ERROR")`, so a `TRY … CATCH cx_root` around
   it cannot absorb it and the whole run goes down — where the dynamic branch
   next to it raises the catchable exception for a name it cannot resolve.
   Even "this cannot be supported" should come out as `CX_SY_CREATE_DATA_ERROR`.

## Proposed change

Lift the `refTo` handling into one small `createDataRefTo()` that both branches
call, so the static and the dynamic spelling answer the same.

`REF TO data` is the generic case and was handled in neither branch before: the
created data object is *itself* an unbound data reference, so the target points
at a `DataReference` — the same nesting `GET REFERENCE OF` a `REF TO data`
variable already produces, and it needs `get_reference`'s cast for the same
reason (the declared `PointerType` does not model a reference to a reference).
Anything else names a class, which is what the dynamic branch already did,
unchanged.

## The patch

[`backlog/patches/transpiler-create-data-ref-to.patch`](../patches/transpiler-create-data-ref-to.patch),
against `abaplint/transpiler` `7a1f20b`. It is ~20 lines of runtime plus two
tests, and it was measured rather than reasoned about:

- `npx mocha` over every non-database spec: **1034 passing, 0 failing**
  (the database specs need `npm run docker:start`, which this checkout has not);
- `npx eslint` clean on both changed files;
- end-to-end against open-abap-core `c4bb873`, the four statements above now
  answer `42` (the value reached through two dereferences), `ok`, `ok`, and
  `cx_sy_create_data_error raised`.

A branch `improve-create-data` exists upstream for it; this session has no push
access to `abaplint/transpiler`, so the diff is carried here instead.

## When it lands

Delete this item, and drop the `dref_chain_survives` entry from the `skip` list
in `node/setup/abap_transpile.json` — that test then runs.
