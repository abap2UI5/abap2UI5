---
target: open-abap
title: 'core: cl_abap_unit_assert=>compare_tables assigns a hashed table to a TYPE INDEX TABLE field symbol - a system refuses it with ASSIGN_TYPE_CONFLICT, the runtime only accepts it because ASSIGN does not check the table kind'
summary: '`compare_tables` declares `<tab1>`/`<tab2>` as `TYPE INDEX TABLE` and does `ASSIGN act TO <tab1>` for every table kind, hashed included; on a system that ASSIGN dumps, and once the runtime checks the kind (runtime-assign-type-conflict-subrc) every `assert_equals` of two hashed tables dies in the assert class - `TYPE ANY TABLE` is the two-line fix'
priority: high
state: filed
filed: https://github.com/open-abap/open-abap-core/pull/1326
first_seen: 2026-10-22
upstream: open-abap/open-abap-core
evidence:
  - 'measured 2026-10-22: open-abap-core main 239b817 transpiled with the prepared ASSIGN fix (`oblomov-dev/fork-transpiler` branch `fix/assign-type-conflict`) - the unit suite dies in `ltcl_test->equals_hashed` with `Error: ASSIGN_TYPE_CONFLICT at cl_abap_unit_assert.compare_tables`; with lines 189 and 191 of `src/unit/cl_abap_unit_assert.clas.abap` changed to `TYPE ANY TABLE` the whole suite (1172 tests) passes'
  - 'read in the same checkout - `src/unit/cl_abap_unit_assert.clas.abap:189-201`: `FIELD-SYMBOLS <tab1> TYPE INDEX TABLE.` … `ASSIGN act TO <tab1>.` with `act TYPE any`; the method then branches on `tablekind_hashed` itself, so it expects hashed input'
  - 'the runtime fix merged upstream on 2026-10-23 as abaplint/transpiler#2018 while open-abap-core main (d8c68eb, 2026-10-23) still has TYPE INDEX TABLE at lines 189 and 191 - the next @abaplint/runtime release breaks open-abap-core''s own equals_hashed and every consumer''s assert_equals of two hashed tables until this lands; no PR exists in open-abap/open-abap-core on 2026-10-23'
  - 'prepared 2026-10-23 as `oblomov-dev/fork-open-abap-core` branch `fix/compare-tables-any-table` (0e816e3) on open-abap-core main d8c68eb'
  - 'filed 2026-10-23 as open-abap/open-abap-core#1326, open, awaiting review'
checked_upstream: 2026-10-23
---

# core: `compare_tables` must take `TYPE ANY TABLE`

## What happens

```abap
" cl_abap_unit_assert.clas.abap, compare_tables
FIELD-SYMBOLS <tab1> TYPE INDEX TABLE.
ASSIGN act TO <tab1>.        " act is a HASHED TABLE: a system dumps, ASSIGN_TYPE_CONFLICT
```

A hashed table is not an index table. The method works in the transpiled
runtime only because its `ASSIGN` never compared table kinds; it even
branches on `tablekind_hashed` a few lines later, so the hashed case is
intended. With the runtime fix that refuses the assignment
(abaplint/transpiler, branch `fix/assign-type-conflict`), every
`assert_equals( act = hashed exp = hashed )` in every consumer's suite
dies inside the assert class.

## The fix

`TYPE ANY TABLE` for `<tab1>` and `<tab2>` (lines 189 and 191). The
`LOOP AT … ASSIGNING` and the `READ TABLE … INDEX` below stay valid: the
index path is only taken for non-hashed tables, and `READ TABLE … INDEX`
on an `ANY TABLE` field symbol is allowed syntactically (it dumps at
runtime for a hashed table, which that branch never sees).

## How to file

A two-line PR against open-abap/open-abap-core, to merge before the
runtime fix is released.
