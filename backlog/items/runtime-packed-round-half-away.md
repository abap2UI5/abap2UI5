---
target: open-abap
title: 'runtime: a number assigned to a packed field rounds a negative half towards zero - `p = -10 + -5 / 10` (DECIMALS 0) is -10, not -11'
summary: '`Packed.numberToScaled( )` of @abaplint/runtime scales a JS number with `Math.round( )`, which rounds a half towards +infinity; ABAP rounds half away from zero, so every calculation that lands on -n.5 and is assigned to a packed field is one unit too high - the integer path had the same fault and was fixed in abaplint/transpiler#1864, the packed one was not'
priority: medium
state: open
first_seen: 2026-11-11
upstream: abaplint/transpiler
evidence:
  - 'abap2UI5/samples z2ui5_cl_smp_app_503 (Basics VI, the unit-test lesson): `gross_amount( net = -10 percent = 5 )` computes `gross_p = net + net * percent / 100` into `TYPE p LENGTH 16 DECIMALS 0` and must answer -11; its own ABAP Unit test `test_negative_half_away` fails in the abap2UI5 playground (@abaplint/runtime 2.14.15) with "Expected ''-11'', got ''-10''". The three positive cases of the same class pass, 10.5 included'
  - 'read 2026-11-11 in @abaplint/runtime 2.14.15 - `build/src/types/packed.js` `numberToScaled( value )`: `BigInt(Math.round(value * factor))`; `Math.round(-10.5)` is -10 and `Math.round(10.5)` is 11. The same file''s `rescale( )`, used for strings and packed sources, already rounds half away from zero on the magnitude - only the number path does not'
  - 'abap2UI5/playground tests/onboarding.spec.js marks the Basics VI exercise as failing for this reason (test.fail), so a runtime bump that fixes it turns that test red'
checked_upstream: 2026-11-11
---

# runtime: a number assigned to a packed field rounds a negative half towards zero

## What happens

```abap
DATA p TYPE p LENGTH 16 DECIMALS 0.
DATA net TYPE i VALUE -10.
DATA percent TYPE i VALUE 5.

p = net + net * percent / 100.
" system:                    -11   (-10.5, rounded half away from zero)
" @abaplint/runtime 2.14.15: -10

p = 10 + 10 * percent / 100.
" system and runtime agree:  11
```

The calculation reaches the packed target as a JS number (-10.5).
`Packed.set( )` hands a number to `numberToScaled( )` in
`packages/runtime/src/types/packed.ts`:

```js
numberToScaled(value) {
  const factor = Math.pow(10, this.decimals);
  return BigInt(Math.round(value * factor));
}
```

`Math.round( )` rounds a half towards positive infinity: 10.5 becomes 11, but
-10.5 becomes -10. ABAP rounds half away from zero in both directions. The
same file's `rescale( )`, which strings and packed sources go through,
already rounds the magnitude half away from zero - only a number source
takes the other path.

The integer target had the same fault and was fixed in
abaplint/transpiler#1864 ("A negative half moved to an integer rounds away
from zero", for #1861). Searched 2026-11-11 for the packed case - issues and
pull requests for packed round, Math.round, rounding negative,
numberToScaled, half away from zero - nothing reports it. Related, not the
same: #1962 (open) computes typed packed assignments exactly, #2013 (open)
packed arithmetic, #1866 (open) integer division rounding.

## The change

Round the magnitude and put the sign back, as #1864 does for integers:

```js
numberToScaled(value) {
  const scaled = value * Math.pow(10, this.decimals);
  return BigInt(Math.sign(scaled) * Math.round(Math.abs(scaled)));
}
```

`Math.round(Math.abs(x))` still meets the double's own representation of
`x.5` (as `Math.round` does now); a value that is exactly a half in decimal
but not in binary is a separate question, and #1962's exact path is the
answer to it.

## Example

A test for `packages/runtime` beside the existing packed tests:

```abap
DATA p TYPE p LENGTH 16 DECIMALS 0.
DATA f TYPE f.
f = '-10.5'.
p = f.
ASSERT p = -11.
f = '10.5'.
p = f.
ASSERT p = 11.
DATA q TYPE p LENGTH 8 DECIMALS 1.
f = '-0.25'.
q = f.
ASSERT q = '-0.3'.
```
