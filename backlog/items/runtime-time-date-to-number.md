---
target: open-abap
title: 'runtime: a time or date assigned to a number keeps its digits - `i = t` gives 235930 instead of the seconds since midnight'
summary: '`Integer`, `Integer8`, `Packed` and `Float` have no branch for `Time` and `Date` in `set( )`, so they fall through to `this.set(value.get())` and parse the character value - `i = ''235930''(t)` is 235930, not 86370, and `i = d` is 20261008, not a day count; the runtime''s own `Time.getNumeric( )` / `Date.getNumeric( )`, which arithmetic already uses, are not called. The reverse direction (`t = i`, `d = i`) is correct'
priority: medium
state: open
first_seen: 2026-10-08
upstream: abaplint/transpiler
evidence:
  - found 2026-10-08 in abap2UI5-addons/admin-cockpit - a unit test of `z2ui5_cl_cockpit_session=>seconds_between` (23:59:30 to 00:00:40 the next day) answered -149490 instead of 70 under `npm run unit`; the method converted the time of day with `lv_secs = lv_time.` (`lv_time TYPE t`, `lv_secs TYPE i`), correct on a system. Worked around by computing `lv_time(2) * 3600 + lv_time+2(2) * 60 + lv_time+4(2)`
  - the same repository's `z2ui5_cl_cockpit_setup=>ts_minus_seconds` still writes `lv_time_secs = lv_time.` - right on a system, wrong in the transpiled runtime, where its test across midnight only passes because the wrong value happens to be large enough
  - measured 2026-10-08 on `@abaplint/runtime` 2.13.99 (the version abap2UI5's unit build installs that day), calling the types directly - `Integer`, `Integer8` and `Packed` set from `Time '235930'` all answer 235930, `Float` 2.3593E+05; set from `Date '20261008'` they answer 20261008. `Time` and `Date` set from an `Integer` (86370, 739897) answer `235930` and `20261007` - that direction converts
  - the cause, read at abaplint/transpiler main 65b3da1 - `packages/runtime/src/types/integer.ts` `set( )` tests `Integer`, `Character`, `String`, `Integer8`, `Float`/`DecFloat34` and the hex types, and ends with `this.set(value.get())` (line 108); `Time.get( )` is the string `"235930"`, which the string branch parses. `integer8.ts`, `packed.ts` and `float.ts` end the same way. `time.ts` and `date.ts` each have a `getNumeric( )` (seconds since midnight, days) that the arithmetic operators use - `lv_date_to - lv_date_from` is right in the same run
checked_upstream: 2026-10-08
---

# runtime: a time or date assigned to a number keeps its digits

## What happens

```abap
DATA lv_time TYPE t VALUE '235930'.
DATA lv_secs TYPE i.
lv_secs = lv_time.
" system: 86370 - the seconds since midnight
" @abaplint/runtime 2.13.99: 235930
```

ABAP converts a `t` source into a numeric target as the number of seconds
since midnight, and a `d` source as the number of days since 01.01.0001.
The runtime copies the digits instead:

| Target | Source `t '235930'` | Source `d '20261008'` |
|---|---|---|
| `i` | 235930 (system: 86370) | 20261008 (system: a day count) |
| `int8` | 235930 | 20261008 |
| `p LENGTH 8 DECIMALS 0` | 235930 | 20261008 |
| `f` | 2.3593E+05 | 2.0261008E+07 |

The other direction is right: `t = 86370` is `235930`, `d = 739897` is a
date. So is arithmetic - `lv_date_to - lv_date_from` and `lv_time + 60` go
through `getNumeric( )`. Only the plain assignment (and with it a parameter
passed by value, `CONV i( lv_time )`, and a `MOVE`) is wrong, which makes
code that is right on a system fail in the transpiled build, or pass for the
wrong reason when the inflated number happens to lie on the right side of a
comparison.

## Why

`packages/runtime/src/types/integer.ts`, `set( )`: the branches cover
`Integer`, `Character`, `String`, `Integer8`, `Float`/`DecFloat34` and the
hex types, then

```ts
} else {
  this.set(value.get());
}
```

`Time.get( )` and `Date.get( )` answer the character value (`"235930"`,
`"20261008"`), and the string branch parses it as a number. `integer8.ts`,
`packed.ts` and `float.ts` end the same way. Both types already have the
conversion: `Time.getNumeric( )` returns `hours * 3600 + minutes * 60 +
seconds`, and `Date.getNumeric( )` the day count that `d = i` reverses
(739898 for 2026-10-08).

## A fix

One branch in each of the four numeric types, before the fall-through:

```ts
} else if (value instanceof Time || value instanceof Date) {
  this.set(value.getNumeric());
}
```

`Packed` and `Float` take the number as is; `Integer` and `Integer8` round
it, which changes nothing for whole seconds and days. A `t` with invalid
content (`'2a0000'`) is a conversion error on a system - out of scope here,
`getNumeric( )` decides what it gives.

## The repro

```abap
METHOD time_to_integer.
  DATA lv_time TYPE t VALUE '235930'.
  DATA lv_secs TYPE i.
  lv_secs = lv_time.
  cl_abap_unit_assert=>assert_equals( act = lv_secs
                                      exp = 86370 ).
ENDMETHOD.

METHOD time_to_packed.
  DATA lv_time TYPE t VALUE '000101'.
  DATA lv_p TYPE p LENGTH 8 DECIMALS 0.
  lv_p = lv_time.
  cl_abap_unit_assert=>assert_equals( act = lv_p
                                      exp = 61 ).
ENDMETHOD.

METHOD date_round_trip.            " d -> i -> d gives the same date
  DATA lv_date TYPE d VALUE '20261008'.
  DATA lv_days TYPE i.
  DATA lv_back TYPE d.
  lv_days = lv_date.
  lv_back = lv_days.
  cl_abap_unit_assert=>assert_equals( act = lv_back
                                      exp = lv_date ).
ENDMETHOD.
```

On 2.13.99 the first answers 235930, the second 101, and the round trip
answers `00000000`: 20261008 days lie past the last date `d` can hold.

## Where it bites here

Nothing in abap2UI5 itself converts a time or date to a number by
assignment. abap2UI5-addons/admin-cockpit did, twice (see the evidence); one
is worked around, one is right on a system and wrong under `npm run unit`.
Any app with time arithmetic written as `lv_secs = lv_time.` - a common way
to write it - behaves the same in the transpiled backend.

## How to file

A PR against abaplint/transpiler is the realistic route: the four branches
above, tests next to the existing conversion tests in
`packages/runtime/test/`, and an ABAP-level test in the transpiler's own
suite.

1. Search the abaplint/transpiler tracker first and record the date in
   `checked_upstream:` (2026-10-08: the issue search for "time to integer
   conversion seconds since midnight" and "date assigned to integer days"
   found #691 "Time-numeric conversion issue" - closed 2022, about `WRITE`
   of an offset of a `t`, not this - and nothing else).
2. Open the PR or the issue.
3. Set `state: filed` and `filed: <url>` here, run `npm run backlog`, commit.
4. When it ships, bump the runtime in abap2UI5 and delete this item.
