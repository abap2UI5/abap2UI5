---
target: open-abap
title: 'runtime: LOOP AT … USING KEY on a sorted secondary key whose component is a REF TO data / REF TO object finds nothing, while READ TABLE WITH KEY over the same key finds the row'
summary: 'a secondary sorted key over a reference component is kept in an index the runtime sorts by comparing references; `LOOP AT tab USING KEY k WHERE ref = r` iterates nothing, whereas `READ TABLE tab WITH KEY k COMPONENTS ref = r` answers subrc 0 and the primary-key `LOOP … WHERE ref = r` finds the row - abap2UI5''s binding index does without the secondary key and scans'
priority: medium
state: open
first_seen: 2026-10-22
upstream: abaplint/transpiler
evidence:
  - 'measured 2026-10-22 on abaplint/transpiler main 53a708f (runtime 2.14.10) with `runFiles`: two rows with `ref TYPE REF TO data` (`CREATE DATA`), `WITH NON-UNIQUE SORTED KEY k COMPONENTS ref`: `LOOP AT tab INTO ls USING KEY k WHERE ref = r2` writes nothing; `LOOP AT tab INTO ls WHERE ref = r2` (primary) writes `2`; `READ TABLE tab INTO ls WITH KEY k COMPONENTS ref = r2` answers subrc 0 and id 2. The same with `REF TO lcl` objects: the keyed LOOP writes nothing'
  - 'abap2UI5 `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap:418-425`: `ty_t_ref_idx` has ''NO secondary key on ref, although the binding search scans this'' - on runtime 2.13.91 the first keyed loop died with a ''table, no header line'' error from compare/lt; ''Re-check on the next runtime bump''. On 2.14.10 it no longer throws, it finds nothing, which is worse'
  - 'the shape, read in the same checkout - `packages/runtime/src/statements/loop.ts:190-196` takes `table.getSecondaryIndex(usingKey)` and `determineFromTo( )` narrows by `topEquals`, which compares key values with the sorted-table comparator; references have no order on a system (a sorted key over a reference is allowed and compares identity)'
  - 'prepared 2026-10-22 as `oblomov-dev/fork-transpiler` branch `fix/keyed-loop-ref-component` (b29d7a4) on abaplint/transpiler main 53a708f: the change plus tests, green in the package suites and the transpiler''s integration tests; the fourteen prepared branches merged together transpile open-abap-core main 239b817 and pass its whole unit suite (1172 tests); abap2UI5 itself, downported and transpiled with that stack (`node/setup/abap_transpile.json`, open-abap-core pinned at 9c1271b with the compare_tables correction), passes `npm run unit` in full (1558 tests).'
checked_upstream: 2026-10-22
---

# runtime: a keyed LOOP over a reference component finds nothing

## What happens

```abap
TYPES: BEGIN OF ty, id TYPE i, ref TYPE REF TO data, END OF ty.
DATA tab TYPE STANDARD TABLE OF ty WITH NON-UNIQUE SORTED KEY k COMPONENTS ref.
" … two rows, refs r1 and r2
LOOP AT tab INTO ls USING KEY k WHERE ref = r2.      " system: id 2    runtime 2.14.10: nothing
ENDLOOP.
READ TABLE tab INTO ls WITH KEY k COMPONENTS ref = r2. " both: subrc 0, id 2
LOOP AT tab INTO ls WHERE ref = r2.                   " both: id 2
```

The secondary index is sorted with the generic comparator, and the keyed
`LOOP` narrows its range with it (`determineFromTo` in
`statements/loop.ts`). Two data references are neither `<` nor `>` for
it, so the range is empty. `READ TABLE` takes another path and succeeds,
which is why the gap is silent: a program that works with `READ TABLE`
and switches to the keyed loop stops seeing its rows.

abap2UI5's model keeps its binding index without the secondary key for
that reason and scans.

## Proposed change

Order references by identity in the sorted-key comparator: give every
`DataReference` / `ABAPObject` target a monotonically assigned id on
first use (a `WeakMap<object, number>`), and compare by it. That is what
a system does too - the order is unspecified but stable - and it makes
`determineFromTo` and `READ TABLE` agree.

## Test

`test/statements/loop.ts`: the snippet with `REF TO data` and with
`REF TO object`, both keyed LOOP shapes (`WHERE` and `WITH KEY … =`),
expecting the row.

## How to file

An issue against abaplint/transpiler with the snippet; the fix is in the
comparator used by the secondary index.

