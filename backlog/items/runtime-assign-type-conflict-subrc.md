---
target: open-abap
title: 'runtime: ASSIGN of a sorted table to a STANDARD TABLE field symbol, and of a string dref to an i field symbol, answer sy-subrc 0 - a system dumps with ASSIGN_TYPE_CONFLICT / ASSIGN_CAST_ILLEGAL_CAST'
summary: '`statements/assign.ts` checks only table-vs-non-table, so an `ASSIGN` whose source and target types conflict succeeds (subrc 0) where a system raises an uncatchable type conflict; a test that expects the subrc or the dump passes in Node and fails on a system, and abap2UI5 checks the table kind by RTTI before every such ASSIGN'
priority: medium
state: open
first_seen: 2026-10-22
upstream: abaplint/transpiler
evidence:
  - 'measured 2026-10-22 on abaplint/transpiler main 53a708f (runtime 2.14.10) with `runFiles`: `DATA st TYPE SORTED TABLE OF i WITH UNIQUE KEY table_line. FIELD-SYMBOLS <t> TYPE STANDARD TABLE. ASSIGN st TO <t>. WRITE sy-subrc.` writes `0`; `CREATE DATA r TYPE string. FIELD-SYMBOLS <i> TYPE i. ASSIGN r->* TO <i>. WRITE sy-subrc.` writes `0` - a system refuses both with a runtime error'
  - 'the cause, read in the same checkout - `packages/runtime/src/statements/assign.ts:191-196`: `ASSIGN_TYPE_CONFLICT` is thrown only when the target is a `Table` and the source is neither `Table` nor `HashedTable`; the table kind, the key and the elementary type are never compared'
  - 'abap2UI5 `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap:2076-2080` and `:2100-2104` (`check_table_standard` before the ASSIGN): ''the transpiler answers a type conflict with the subrc''; the test `test_skip_sorted_table` was wrongly green under `npm run unit` and a user''s system found the dump on 2026-09-02 (`.claude/skills/abap-check/SKILL.md`, section 4)'
  - 'abap2UI5 `.claude/skills/abap-check/SKILL.md` section 4 lists `ASSIGN dref->* TO <typed fs>` giving subrc 4 instead of the dump as an open gap; measured today it is subrc 0'
  - 'prepared 2026-10-22 as `oblomov-dev/fork-transpiler` branch `fix/assign-type-conflict` (386de0d) on abaplint/transpiler main 53a708f: the change plus tests, green in the package suites and the transpiler''s integration tests; the fourteen prepared branches merged together transpile open-abap-core main 239b817 and pass its whole unit suite (1172 tests); abap2UI5 itself, downported and transpiled with that stack (`node/setup/abap_transpile.json`, open-abap-core pinned at 9c1271b with the compare_tables correction), passes `npm run unit` in full (1558 tests). abaplint types every `FIELD-SYMBOLS … TABLE` alike, so the transpiler now writes the declared kind into the field symbol''s type and the runtime compares kinds; the elementary check is limited to the types no generic maps to (i, int8, string, xstring, f, decfloat34, d, t). Fallout: open-abap-core''s `cl_abap_unit_assert=>compare_tables` assigns hashed tables to `TYPE INDEX TABLE` field symbols, which a system refuses too - see core-unit-assert-compare-tables-index-table'
checked_upstream: 2026-10-22
---

# runtime: an ASSIGN with a type conflict succeeds

## What happens

```abap
DATA st TYPE SORTED TABLE OF i WITH UNIQUE KEY table_line.
FIELD-SYMBOLS <t> TYPE STANDARD TABLE.
ASSIGN st TO <t>.          " system: ASSIGN_TYPE_CONFLICT (dump)   runtime: sy-subrc 0

DATA r TYPE REF TO data.
FIELD-SYMBOLS <i> TYPE i.
CREATE DATA r TYPE string.
ASSIGN r->* TO <i>.        " system: ASSIGN_CAST_ILLEGAL_CAST       runtime: sy-subrc 0
```

`packages/runtime/src/statements/assign.ts` throws `ASSIGN_TYPE_CONFLICT`
only for a table target with a non-table source. A sorted or hashed
source into a `STANDARD TABLE` field symbol, or an elementary type into a
differently typed field symbol, is accepted; from then on the code runs
against a table of the wrong kind (an `APPEND` to a sorted table) or
reads a string as an integer.

abap2UI5's model service decides the table kind by RTTI before the
ASSIGN because of it (`check_table_standard`), and the transpiled suite
kept a test green that a user's system dumped on.

## Proposed change

In `assign.ts`, when the target field symbol has a declared type
(`getType()` is not `any`/generic):

- table target: compare the table kind (`STANDARD`/`SORTED`/`HASHED`) of
  source and target, and the key when the target names one; a mismatch
  throws `ASSIGN_TYPE_CONFLICT`;
- elementary target: a source of another type (constructor and, for
  `c`/`n`/`x`/`p`, the length and decimals) throws
  `ASSIGN_CAST_ILLEGAL_CAST` unless `CASTING` is given.

Both are uncatchable runtime errors on a system, so a plain `throw new
Error("ASSIGN_TYPE_CONFLICT")` is the right shape.

## Test

The two snippets above, expecting the throw; and the negative cases:
`TYPE ANY TABLE`, `TYPE INDEX TABLE` with a sorted source, `TYPE any`,
`CASTING`.

## How to file

An issue against abaplint/transpiler with the snippets.

