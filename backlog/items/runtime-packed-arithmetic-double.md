---
target: open-abap
title: 'runtime: + - * DIV MOD on a packed field go through a JS double - a TIMESTAMPL + ''0.0000001'' answers .1235968, p MOD 100 answers 0'
summary: '`operators/add.ts` (and mul, div, DIV, MOD) have branches for Integer, Integer8, Float and DecFloat34 but none for `Packed`, so a packed operand falls through to `new Float().set(parse(left) + parse(right))` - a 21-digit `timestampl` loses its last six digits in every arithmetic statement, not only in the copy that abaplint/transpiler#1962 fixes; `20261014103400.1234567 + ''0.0000001''` answers `.1235968`, `p MOD 100` answers `0.0000000`, `p * 1` changes the value'
priority: high
state: open
first_seen: 2026-10-22
upstream: abaplint/transpiler
evidence:
  - 'measured 2026-10-22 on abaplint/transpiler main 53a708f (runtime 2.14.10) through the repository''s own test harness (`runFiles`): `DATA p TYPE p LENGTH 11 DECIMALS 7. p = ''20261014103400.1234567''. p = p + ''0.0000001''.` writes `20261014103400,1235968`; `p * 1` writes the same wrong value; with `p = ''20261003101500.3500000''`, `p MOD 100` writes `0,0000000` (a system: `0.35`) and `p DIV 100` writes `202610031015,0000128` (a system: `202610031015`)'
  - 'the cause, read in the same checkout - `packages/runtime/src/operators/add.ts`: branches for `Integer`, `Integer8`, `Float`, `DecFloat34` (through `_decimal.ts`), then `const ret = new Float().set(parse(left) + parse(right))` for everything else, `Packed` included; `mul.ts`, `div.ts`, `div_int.ts` and `mod.ts` have the same shape. `Packed.set(number)` then rounds through `numberToScaled( )`, `BigInt(Math.round(value * 1e7))`, past 2^53'
  - 'abap2UI5 `src/00/03/z2ui5_cl_ui5_util_context.clas.abap:1889-1893` (`time_get_seconds`): DIV/MOD on a 14-digit timestamp is worth about 4 ms of resolution, `20261003101500.35` is `20261003101500.34765625` there - the method reads the digits from the string form instead'
  - 'abap2UI5 `node/setup/abap_transpile.json` skips `Z2UI5_CL_AJSON ltcl_abap_to_json->set_value_timestampl` because `lv_timestampl + ''0.1234567''` answers `.1245184` - an addition, attributed so far to the copy item runtime-packed-copy-precision (#1962), which does not cover it'
  - 'abaplint/transpiler#1962 (open on 2026-10-22) adds the `Packed`-to-`Packed` copy branch in `Packed.set( )` and rescales typed assignments; the operators are untouched by it. Searched the tracker 2026-10-22 for packed arithmetic / DIV / MOD: nothing'
checked_upstream: 2026-10-22
---

# runtime: arithmetic on a packed field goes through a JS double

## What happens

```abap
DATA p TYPE p LENGTH 11 DECIMALS 7.       " a timestampl
p = '20261014103400.1234567'.
p = p + '0.0000001'.
" system:                   20261014103400.1234568
" @abaplint/runtime 2.14.10: 20261014103400.1235968

p = '20261003101500.3500000'.
DATA q TYPE p LENGTH 11 DECIMALS 7.
q = p MOD 100.     " system 0.3500000      runtime 0.0000000
q = p DIV 100.     " system 202610031015   runtime 202610031015.0000128
q = p * 1.         " system p              runtime 20261014103400.1235968
```

A packed field holds its value as a scaled `BigInt`, so a literal or a
string is exact at any length. Every arithmetic operator loses that: in
`packages/runtime/src/operators/add.ts` (and `mul.ts`, `div.ts`,
`div_int.ts`, `mod.ts`) the branches cover `Integer`, `Integer8`, `Float`
and `DecFloat34` - the last one exactly, through `_decimal.ts` - and a
`Packed` operand falls through to
`new Float().set(parse(left) + parse(right))`. A double holds 15 to 17
significant digits; a `timestampl` has 21.

abaplint/transpiler#1962 fixes the *copy* (`Packed.set(Packed)`), and
#2002 the `GET TIME STAMP`; with both merged, `lv_now + 1` or
`lv_now MOD 100` still answers noise. abap2UI5's `time_get_seconds( )`
reads the digits from the string form for that reason, and the ajson test
`set_value_timestampl` is skipped in its transpiled suite.

## Proposed change

In each operator, a branch for a `Packed` operand (either side) before the
Float fallback: convert both sides to decimal through the existing
`toDecimal( )` of `_decfloat.ts` (`Packed.toFixed(decimals)` is exact),
compute with `_decimal.ts`, and return a `Packed` whose length and
decimals come from the packed operand (the target's `set( )` then rescales
exactly through `stringToScaled( )`). `DIV` and `MOD` on the decimal
value, as the DecFloat34 branch already does.

## Test

```ts
const p = new Packed({length: 11, decimals: 7}).set("20261014103400.1234567");
expect(add(p, "0.0000001").toFixed(7)).to.equal("20261014103400.1234568");
expect(mod(new Packed({length: 11, decimals: 7}).set("20261003101500.35"), 100).toFixed(7)).to.equal("0.3500000");
```

## How to file

An issue or a PR against abaplint/transpiler, naming #1962 and #2002 as
the two companions. Then unskip `set_value_timestampl` in abap2UI5's
`abap_transpile.json` and drop the digit arithmetic in `time_get_seconds`.

