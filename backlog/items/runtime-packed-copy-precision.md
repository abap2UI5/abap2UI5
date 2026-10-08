---
target: open-abap
title: 'runtime: a packed field assigned to another packed field goes through a JS double - a TIMESTAMPL 20240229235959 arrives as 20240229235958.9986304'
summary: '`Packed.set( )` has no branch for a `Packed` source and falls through to `this.set(value.get())`; `get( )` answers `Number(this.value) / 10 ** decimals`, so every packed-to-packed assignment of more than 15 significant digits loses its last ones - a `timestampl` (21 digits) set from a string is exact, its copy is not, and ajson''s `to_timestamp` then refuses the value as carrying a fraction'
priority: medium
state: open
first_seen: 2026-10-08
upstream: abaplint/transpiler
evidence:
  - found 2026-10-08 while writing the date round trip of `z2ui5_cl_ui5_srv_model`'s test class (`whole_dates_round_trip`) - a `TIMESTAMP` column holding `20240229235959` came back refused under `npm run unit`; the test uses a whole hour since, with a comment naming the runtime
  - measured 2026-10-08 on the transpiled ajson (abap2UI5 `node/output`, `@abaplint/runtime` 2.13.99) - `get_timestampl( )` of `2024-02-29T23:59:59Z` formats as `20240229235958.9986304` in a string template, and `get_timestamp( )` answers 0 for `23:59:59`, `23:59:58` and `00:00:01`, the right value for `12:00:00`
  - measured 2026-10-08 on `@abaplint/runtime` 2.13.99 and 2.14.0, calling the type directly - `Packed({length: 11, decimals: 7})` set from the string `20240229235959` formats as `20240229235959.0000000`; a second one set from the first formats as `20240229235958.9986304`, `20240229123000` as `20240229122999.9988736`, `20240229235959.1234567` as `20240229235959.1264256`. A `p LENGTH 8 DECIMALS 0` copy (14 digits) stays exact
  - the cause, read in the 2.14.0 package - `build/src/types/packed.js` `set( )` tests `number`, `string`, `Integer8`, `Float`/`DecFloat34` and ends with `this.set(value.get())`; `get( )` is `Number(this.value) / Math.pow(10, this.decimals)` and `numberToScaled( )` multiplies the double back, while the value itself is kept as a scaled `BigInt` and the same file already has an exact `rescale(mag, fromScale, toScale)`
checked_upstream: 2026-10-08
---

# runtime: a packed field assigned to another packed field goes through a JS double

## What happens

```abap
DATA lv_a TYPE timestampl.
DATA lv_b TYPE timestampl.
lv_a = '20240229235959'.
lv_b = lv_a.
" system:                    20240229235959.0000000
" @abaplint/runtime 2.14.0:  20240229235958.9986304
```

A packed field keeps its value as a scaled `BigInt`, so a value set from a
string or a literal is exact at any length. The assignment of one packed
field to another is not: it goes through a JS `Number`, which holds about 15
to 17 significant digits. A `timestampl` has 21, so the copy keeps only the
values a double happens to hold exactly - a whole hour among them - and
shifts the rest by a few hundred nanoseconds.

| Source (`p LENGTH 11 DECIMALS 7`) | After `lv_b = lv_a.` |
|---|---|
| `20240229120000` | `20240229120000.0000000` |
| `20240229123000` | `20240229122999.9988736` |
| `20240229235959` | `20240229235958.9986304` |
| `20240229235959.1234567` | `20240229235959.1264256` |

A `p LENGTH 8 DECIMALS 0` (14 digits) copies exactly.

The visible damage is in ajson: `to_timestampl( )` returns its result by such
a copy, and `to_timestamp( )` splits `|{ lv_timestampl }|` at the dot and
refuses any fraction (*Unexpected timestamp format*). So `get_timestamp( )`
answers 0 for `2024-02-29T23:59:59Z`, and `to_abap( )` of a structure or a
table with a `TIMESTAMP` component holding such an instant raises - the
whole bound table is refused in the transpiled build, while a system takes it.

## Why

`packages/runtime/src/types/packed.ts`, `set( )`: the branches cover
`number`, `string`, `Integer8` and `Float`/`DecFloat34`, then

```ts
} else {
  this.set(value.get());
}
```

and `Packed.get( )` is `Number(this.value) / Math.pow(10, this.decimals)`,
which `numberToScaled( )` multiplies back up as a double.

## A fix

One branch before the fall-through, with the rescale the same file already
uses for `toFixed( )`:

```ts
} else if (value instanceof Packed) {
  const negative = value.value < 0n;
  const mag = rescale(negative ? -value.value : value.value, value.getDecimals(), this.decimals);
  this.value = negative ? -mag : mag;
}
```

`rescale( )` rounds half up when the target has fewer decimals, which is
what ABAP does for a p-to-p assignment. An overflow of the target's length is
out of scope here, as it is today.

## The repro

```abap
METHOD packed_copy_exact.
  DATA lv_a TYPE timestampl.
  DATA lv_b TYPE timestampl.
  lv_a = '20240229235959'.
  lv_b = lv_a.
  cl_abap_unit_assert=>assert_equals( act = |{ lv_b }|
                                      exp = `20240229235959.0000000` ).
ENDMETHOD.

METHOD packed_copy_rounds.        " fewer decimals: commercial rounding
  DATA lv_a TYPE p LENGTH 11 DECIMALS 7 VALUE '1.0000005'.
  DATA lv_b TYPE p LENGTH 8 DECIMALS 6.
  lv_b = lv_a.
  cl_abap_unit_assert=>assert_equals( act = |{ lv_b }|
                                      exp = `1.000001` ).
ENDMETHOD.
```

On 2.14.0 the first answers `20240229235958.9986304`.

## Where it bites here

`z2ui5_cl_ui5_srv_model` reads a `TIMESTAMPL`/`TIMESTAMP` of a row delta
through ajson's `get_timestampl( )` and the whole-attribute path through
`to_abap( )`; both are right on a system and lose the second in the
transpiled backend - `npm run unit`, the node runtime of
`@abap2ui5/node-runtime` and every host built on it. The unit tests use a
whole hour for that reason.

## How to file

A PR against abaplint/transpiler: the branch above, a runtime test next to
the existing packed tests, and the ABAP repro in the transpiler's own suite.

1. Search the abaplint/transpiler tracker first and record the date in
   `checked_upstream:` (2026-10-08: the 2.14.0 package still has the
   fall-through; the tracker itself was not reachable from the session that
   wrote this item - search it before filing).
2. Open the PR or the issue.
3. Set `state: filed` and `filed: <url>` here, run `npm run backlog`, commit.
4. When it ships, bump the runtime in abap2UI5 and delete this item.
