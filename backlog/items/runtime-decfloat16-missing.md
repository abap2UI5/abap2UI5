---
target: open-abap
title: 'runtime: no DecFloat16 type - a DATA … TYPE decfloat16 transpiles to abap.types.typeTodoDecFloat16Type and fails at load time'
summary: '`transpile_types.ts` maps only `DecFloat34Type`; a `decfloat16` declaration becomes `new abap.types.typeTodoDecFloat16Type()`, a TypeError when the module loads, so every class touching the type is out of the transpiled suite (abap2UI5 tests cover decfloat34 only)'
priority: medium
state: filed
filed: https://github.com/abaplint/transpiler/issues/963
first_seen: 2026-10-22
upstream: abaplint/transpiler
evidence:
  - 'measured 2026-10-22 on abaplint/transpiler main 53a708f (runtime 2.14.10) with `runFiles`: `DATA d TYPE decfloat16. d = ''1.5''. WRITE d.` ends in `TypeError: abap.types.typeTodoDecFloat16Type is not a constructor`'
  - 'the cause, read in the same checkout - `packages/runtime/src/types/` has `decfloat34.ts` and `_decimal.ts` only; `packages/transpiler/src/transpile_types.ts` maps `DecFloat34Type` and lets `DecFloat16Type` fall into the `typeTodo` default'
  - 'abap2UI5 `src/00/03/z2ui5_cl_ui5_util_context.clas.testclasses.abap:945-946` and `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap:4783-4785`: the decfloat16 branches of the JSON and binding conversions stay untested because ''the transpiled runtime has no type for the first'''
  - 'abaplint/transpiler#963 ''add type DecFloat16'' (opened 2022-10-30) is open on 2026-10-22 with no PR - this item is the case and the proposal for it'
checked_upstream: 2026-10-22
---

# runtime: no `decfloat16`

## What happens

```abap
DATA d TYPE decfloat16.
d = '1.5'.
" transpiles to: new abap.types.typeTodoDecFloat16Type()
" at load:       TypeError: abap.types.typeTodoDecFloat16Type is not a constructor
```

`decfloat34` exists (`packages/runtime/src/types/decfloat34.ts`, exact
through `_decimal.ts`); `decfloat16` does not. A class that declares one
anywhere - also in a test double or a structure component - cannot be
loaded, so the whole class pool is out of the transpiled unit suite.
abap2UI5's JSON and binding conversions have `decfloat16` branches that
no test on Node reaches.

## Proposed change

`packages/runtime/src/types/decfloat16.ts` as a copy of `decfloat34.ts`
with 16 significant digits (the rounding in `_decimal.ts` takes the
precision as a parameter already), registered in `types/index.ts`, and
`DecFloat16Type` mapped in `transpile_types.ts` next to `DecFloat34Type`.
The operators' DecFloat34 branch (`isDecFloat34Operand`) widens to both;
the result type of a mixed expression is `decfloat34`, as on a system.

## Test

```abap
DATA d TYPE decfloat16. d = '1.5'. d = d * 3. ASSERT d = '4.5'.
d = '1234567890123456789'. ASSERT |{ d }| = '1.234567890123457E+18'.
```

## How to file

Comment on abaplint/transpiler#963 with this item, or open the PR naming it.

