---
target: open-abap
title: 'runtime: the built-in function rescale( ) is not implemented - `TypeError: abap.builtin.rescale is not a function`'
summary: the transpiler emits `abap.builtin.rescale({val, dec})` for `rescale( val = … dec = … )`, but `@abaplint/runtime` has no `rescale` in `packages/runtime/src/builtin`, so the statement dies at runtime; `round( )` next to it is complete since 2.13.94 (abaplint/transpiler#1923), and its rounding core is what `rescale` needs. No call in this corpus
priority: low
state: open
first_seen: 2026-10-03
upstream: abaplint/transpiler
evidence:
  - found 2026-10-03 while reproducing the report2cloud runtime TODO "`round( val dec = 2 )` is not implemented in `@abaplint/runtime`" (abap2UI5/abap-cloud-gui, `tools/report2cloud`, corpus report `zr2c_09_localclass`) - that one does not reproduce at the versions abap2UI5 pins; `rescale( )`, checked alongside it, does
  - minimal repro 2026-10-03 (test below; @abaplint/transpiler-cli and runtime 2.13.96 - the version abap2UI5's devDependencies pin and the latest on npm that day - against open-abap-core b2d219d) - `rescale( val = CONV decfloat34( '1.235' ) dec = 2 )` transpiles with the syntax check on and fails with `TypeError: abap.builtin.rescale is not a function`; in the same run `round( )` with `dec = 2`, `dec = -1`, `mode = cl_abap_math=>round_half_even` and `prec = 2` all pass
  - the round( ) half, for the record - on the 2.13.93 runtime the same four round( ) tests fail (`round(), todo, handle decimals` three times, a TypeError for `prec`); 2.13.94 (2026-09-30) ships abaplint/transpiler#1923 "round( ): dec, prec and every rounding mode" (merged 2026-09-29). report2cloud's TODO test comes from the abap2UI5 MCP server's Node backend, which installs `@abaplint/transpiler-cli` 2.13.93 next to `@abap2ui5/node-runtime` 1.146.0 - it clears when that backend moves to 2.13.94 or later, not by a change upstream
  - the cause, read in the 2.13.96 package (`build/src/builtin/` has `round.js` and no `rescale.js`) and unchanged at abaplint/transpiler main 2fae932 (2026-10-03) - the directory listing of `packages/runtime/src/builtin` has `round.ts` and no `rescale.ts`
checked_upstream: 2026-10-03
---

# runtime: rescale( ) is not implemented

## What happens

```abap
DATA lv TYPE decfloat34.
lv = rescale( val = CONV decfloat34( '1.235' ) dec = 2 ).
```

@abaplint/transpiler-cli 2.13.96 emits

```js
lv.set(abap.builtin.rescale({val: new abap.types.DecFloat34().set(abap.CharacterFactory.get(5, '1.235')), dec: abap.IntegerFactory.get(2)}));
```

and `@abaplint/runtime` 2.13.96 has no `rescale` export, so the statement
dies with `TypeError: abap.builtin.rescale is not a function`. The transpile
succeeds, with the syntax check on - abaplint knows the function, the runtime
does not.

## Where it applies

| Call | 2.13.93 | 2.13.94 - 2.13.96 |
|---|---|---|
| `rescale( val = … dec = 2 )` | `TypeError … is not a function` | same |
| `round( val = … dec = 2 )`, `dec = -1` | `round(), todo, handle decimals` | correct |
| `round( val = … dec = 2 mode = cl_abap_math=>round_half_even )` | same | correct |
| `round( val = … prec = 2 )` | `TypeError` | correct |

## A fix

`rescale( val dec|prec [mode] )` is `round( )` plus the scale of the result:
the same arguments, the same seven rounding modes, a `decfloat34` result. The
`round.ts` from abaplint/transpiler#1923 already rounds a decfloat34 exactly
on BigInt digits for `dec`, `prec` and every mode, so a first `rescale.ts`
can call it and return its result. What it cannot express is the scale
itself - `rescale( val = '1.2' dec = 3 )` is `1.200` on a system, and the
runtime's `DecFloat34` keeps a number, not a number of decimals - so a scale
increase stays a no-op until `DecFloat34` carries one. That leaves only the
output of `WRITE` and string templates of such a value different, not its
arithmetic.

## Why it is low priority here

Nothing in abap2UI5, samples, samples-controls or samples-stack calls
`rescale( )` (see the measurement below; the one `round( val = … )` call is
the negative). It bites code written outside this corpus and transpiled
against `@abap2ui5/node-runtime` - a migrated report with decfloat
arithmetic, as report2cloud converts them.

## The repro

A test method in any class with a test include:

```abap
METHOD rescale_dec.
  DATA lv TYPE decfloat34.
  lv = rescale( val = CONV decfloat34( '1.235' ) dec = 2 ).
  cl_abap_unit_assert=>assert_equals( act = lv exp = CONV decfloat34( '1.24' ) ).
ENDMETHOD.

METHOD round_mode.        " passes from 2.13.94 on
  DATA lv TYPE p LENGTH 8 DECIMALS 2.
  lv = round( val = CONV decfloat34( '2.665' ) dec = 2 mode = cl_abap_math=>round_half_even ).
  cl_abap_unit_assert=>assert_equals( act = lv exp = '2.66' ).
ENDMETHOD.
```

`abap_transpile` with `write_unit_tests: true`, `unknownTypes: runtimeError`,
syntax check on, open-abap-core as the lib.

## How to file

An issue against abaplint/transpiler (the runtime is its `packages/runtime`).
A PR is the realistic route: `rescale.ts` next to `round.ts`, an export in
`builtin/index.ts`, and `test/builtin/` has the round tests to copy.

1. Search the abaplint/transpiler tracker first and record the date in
   `checked_upstream:` (2026-10-03: the GitHub issue search for `rescale` in
   abaplint/transpiler and in open-abap/open-abap-core, read through the web
   page because this session has no API access to either repository - 0
   results in both; `round decimals` finds #1923, merged, which is the round( )
   half and does not mention rescale).
2. Open the issue or the PR.
3. Set `state: filed` and `filed: <url>` here, run `npm run backlog`, commit.
4. When it ships, bump the runtime in abap2UI5 and delete this item.

<!-- probe:start — written by `npm run backlog:probe`, do not edit by hand -->

## Measured

`runtime-rescale-not-implemented.probe.mjs` — a call of `rescale( )` - no builtin in @abaplint/runtime; the `round( val = … )` calls as the negative, implemented with dec, prec and mode since 2.13.94.
Run **2026-10-03** against `abap2UI5`, `samples`, `samples-controls`, `samples-stack`.

**Would fire on 0 site(s)** in 0 repositories:

_none_

**Must NOT fire on 1 site(s)** that match the shape and are correct:

| Repository | Where | |
|---|---|---|
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_608.clas.abap`:244 | round( dec ) - implemented |

**Where the detector is an approximation of the rule:**

- A call is recognised by its `val =` argument, which both functions require; a method of the same name (`lo->round( … )`) is not counted.
- The round( ) negatives work on @abaplint/runtime 2.13.94 and later only; up to 2.13.93 any `dec` other than 0 threw `round(), todo, handle decimals`, which is what the MCP server's backend (transpiler-cli 2.13.93) still ships.

<!-- probe:end -->
