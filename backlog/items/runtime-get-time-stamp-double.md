---
target: open-abap
title: 'runtime: GET TIME STAMP FIELD into a TIMESTAMPL adds the milliseconds through a JS double - at a whole minute the stamp reads 10:33:99,999 and cl_abap_tstmp=>add( ) dies with a JS RangeError'
summary: '`getTime( )` in `statements/get_time.ts` fills a `p LENGTH 11 DECIMALS 7` target as `stamp.set(stamp.get() + decimals)` - a 21-digit value through a `Number` that holds 15 to 17 - so the last digits are noise; when the clock is on a whole second with a millisecond of 0 or 1 the noise goes below the second (`20261014053400` becomes `20261014053399.9984128`), the ISO rendering is `05:33:99`, and `cl_abap_tstmp=>add( )` ends in `RangeError: Invalid time value` from `toISOString( )`, which no CATCH sees. The release job of abap2UI5 1.147.0 hit it: `npm run unit` ran `zcl_serializer_live`''s `test_sweep_expiry` at 05:34:00 UTC'
priority: medium
state: filed
filed: https://github.com/abaplint/transpiler/issues/2002
first_seen: 2026-10-14
upstream: abaplint/transpiler
checked_upstream: 2026-10-22
evidence:
  - 'the release of abap2UI5 1.147.0 (2026-10-14): backend-prebuilt run 38517095016, job `attach`, step "The transpiled backend runs its unit suite" - `ZCL_SERIALIZER_LIVE: running ltcl_test->test_sweep_expiry` then `RangeError: Invalid time value at Date.toISOString at cl_abap_tstmp.add (open-abap-core/cl_abap_tstmp.clas.mjs:156) at cl_abap_tstmp.subtractsecs at z2ui5_cl_ui5_util_context.time_subtract_seconds at zcl_serializer_live.sweep`; the step ended at 05:34:00 UTC. The same tree was green under `npm run verify` on two machines minutes before and after (the clock was on another second), and green on the re-run of the job at 06:12'
  - 'measured 2026-10-14 on `@abaplint/runtime` 2.14.3 (`node/output` of abap2UI5 at d771abad): a `Packed({length: 11, decimals: 7})` set to `20261014103400` and then, as `getTime( )` does, `set(get() + 0.000)` formats as `2026-10-14T10:33:99,9990784`; set to `20261014053100` plus `0.000` or `0.001` as `05:30:99,9984128`; `20261013235959` plus `0.999` as `23:59:60,0013312`. Every value whose seconds are `00` and whose millisecond part is 0 or 1 goes below the second; the rest keep noise inside their own second (`053357.1234567` becomes `053357.1229…`), which is invisible until a comparison or a diff'
  - 'the cause, read in the 2.14.3 package - `build/src/statements/get_time.js`: `options.stamp.set(date + time)` (exact, a string) and then `options.stamp.set(options.stamp.get() + decimals)` with the comment "parsing to float will make it imprecise, ie. filling the nanoseconds part with garbage, which is what we want"; `Packed.get( )` is `Number(this.value) / 10 ** decimals` and `numberToScaled( )` is `BigInt(Math.round(value * factor))` - 20261014053400 * 1e7 is 2.03e20, past 2^53'
  - 'the second half of the chain is `runtime-packed-copy-precision` (abaplint/transpiler#1962, open on 2026-10-14): the short `timestamp` that `cl_abap_tstmp=>add( )` answers goes into the caller''s `timestampl` through the same double, so a `20261014103400` the test computed as "five hours later" arrives as `10:33:99` by that path even with `getTime( )` fixed. Both fixes are needed for the chain above to be safe at every second of the day'
  - 'the same chain is production code on the node runtime, not only the test: `zcl_serializer_live=>sweep( )` and `z2ui5_cl_ui5_http_handler`''s draft cleanup both do `time_get_timestampl( )` then `time_subtract_seconds( )`, so the draft sweep timer of `@abap2ui5/node-runtime` (`initialize({ draftSweepMs })`, every five minutes) dies with the same `RangeError` when it fires on a `:00.000` or `:00.001` clock - about two in sixty thousand sweeps'
  - 'filed 2026-10-14 as abaplint/transpiler#2002 (issue, body as below, names #1962 as the companion); re-read 2026-10-22 - open, no comment, no linked branch or PR, `get_time.ts` unchanged at abaplint/transpiler main 53a708f (2.14.10). The PR is prepared on that main: the three-line change plus a deterministic runtime test (`packages/runtime/test/statements/get_time.ts`, the clock fixed per case) that fails on main with the four values above and passes with the fix; the runtime suite, the transpiled-ABAP GET TIME tests and eslint are green; pushed 2026-10-22 as `oblomov-dev/fork-transpiler` branch `fix/get-time-stamp-exact` (8807232)'
  - 'prepared 2026-10-22 as `oblomov-dev/fork-transpiler` branch `fix/get-time-stamp-exact` (8807232) on abaplint/transpiler main 53a708f: the change plus tests, green in the package suites and the transpiler''s integration tests; the fourteen prepared branches merged together transpile open-abap-core main 239b817 and pass its whole unit suite (1172 tests).'
---

# `GET TIME STAMP FIELD` into a `timestampl` goes through a JS double

## What happens

```abap
DATA lv_now TYPE timestampl.
GET TIME STAMP FIELD lv_now.            " the clock reads 2026-10-14 10:34:00.000 UTC
" system:                    20261014103400.0000000
" @abaplint/runtime 2.14.3:  20261014103399.9990784

DATA(lv_ago) = cl_abap_tstmp=>subtractsecs( tstmp = lv_now secs = 3600 ).
" system:  20261014093400
" runtime: RangeError: Invalid time value  (a JS error - CATCH cx_root does not see it)
```

`getTime( )` writes the 14 date-and-time digits as a string, which is exact,
and then adds the milliseconds as a `Number`:

```ts
options.stamp.set(date + time);
if (options.stamp instanceof Packed && options.stamp.getDecimals() === 7) {
  const str = (d.getUTCMilliseconds() + "").padStart(3, "0") + "0000";
  // note: parsing to float will make it imprecise,
  // ie. filling the nanoseconds part with garbage, which is what we want
  const decimals = Number.parseFloat("0." + str);
  options.stamp.set(options.stamp.get() + decimals);
}
```

A `timestampl` scaled to its 7 decimals has 21 digits. `get( )` turns the
scaled `BigInt` into a double (`Number(value) / 1e7`), the addition happens
there, and `numberToScaled( )` multiplies back (`Math.round(value * 1e7)`):
a 2e20 product is far past 2^53, so the last four to five digits are
whatever the double held. The comment intends noise *in the nanoseconds*;
what arrives is noise in the **milliseconds**, and it has a sign:

| clock (UTC) | ms | `\|{ lv_now TIMESTAMP = ISO }\|` on 2.14.3 |
|---|---|---|
| 10:34:00 | 000 | `2026-10-14T10:33:99,9990784` |
| 05:31:00 | 001 | `2026-10-14T05:30:99,9984128` |
| 05:33:57 | 123 | `2026-10-14T05:33:57,1229…` |
| 23:59:59 | 999 | `2026-10-13T23:59:60,0013312` |

Inside the second the noise is harmless until something compares or
subtracts two stamps. Across the second it is a stamp no parser takes:
open-abap-core's `cl_abap_tstmp=>add( )` renders the ISO text, splits off
the fraction and hands `2026-10-14T10:33:99Z` to `Date.parse( )`, and the
`toISOString( )` on the resulting invalid `Date` throws `RangeError` - a
JS error, not an ABAP exception.

## Where it bit

abap2UI5's release 1.147.0 (2026-10-14). `backend-prebuilt.yaml` runs the
transpiled unit suite on the tag before it packs `@abap2ui5/node-runtime`;
the suite reached `zcl_serializer_live`'s `test_sweep_expiry` at 05:34:00
UTC, `GET TIME STAMP` answered `…053399.998…`, and the job died in
`cl_abap_tstmp.add` with the stack above. The same commit was green under
`npm run verify` minutes before on another machine and green on the re-run
of the job at 06:12. About one run in sixty lands on a `:00` second.

The production shape is the same: `zcl_serializer_live=>sweep( )` and the
draft cleanup of `z2ui5_cl_ui5_http_handler` both take `time_get_timestampl( )`
and subtract the expiry, so the draft sweep timer of `@abap2ui5/node-runtime`
dies the same way when it fires on a `:00.000` clock.

## The fix

Set the stamp once, from the digits, which `Packed.set( )` parses exactly:

```ts
if (options.stamp instanceof Packed && options.stamp.getDecimals() === 7) {
  const ms = (d.getUTCMilliseconds() + "").padStart(3, "0");
  options.stamp.set(date + time + "." + ms + "0000");
} else {
  options.stamp.set(date + time);
}
```

`stringToScaled( )` keeps every digit, so `20261014103400.0000000` stays
what the clock said, and the nanoseconds are zeros instead of noise - which
is what a system answers for the digits its clock does not have.

The other half, the short-to-long assignment in `cl_abap_tstmp=>add( )`'s
caller, is abaplint/transpiler#1962 (`runtime-packed-copy-precision`).
With both, the chain `GET TIME STAMP` → `subtractsecs( )` → compare is exact
at every second of the day.

## Repro

```abap
METHOD get_time_stamp_exact.
  DATA lv_now TYPE timestampl.
  DATA lv_txt TYPE string.
  DO 2000 TIMES.                       " spans a whole second at any clock
    GET TIME STAMP FIELD lv_now.
    lv_txt = |{ lv_now TIMESTAMP = ISO }|.
    cl_abap_unit_assert=>assert_true( xsdbool( lv_txt+17(2) BETWEEN '00' AND '59' ) ).
  ENDDO.
ENDMETHOD.
```

and, deterministic, the runtime test: set a `Packed({length: 11, decimals: 7})`
the way `getTime( )` does for `20261014103400` and 0 ms, expect
`20261014103400.0000000`.

## How to file

Filed as abaplint/transpiler#2002 on 2026-10-14 (issue, body as above).
The PR is prepared: the three lines in
`packages/runtime/src/statements/get_time.ts` plus the runtime test
`packages/runtime/test/statements/get_time.ts` (clock fixed per case, the
four values of the table), named "Closes #2002", with
abaplint/transpiler#1962 as the companion.

1. Open the PR from `oblomov-dev/fork-transpiler`, branch `fix/get-time-stamp-exact`
   (commit 8807232 on abaplint/transpiler main 53a708f): title and body are
   the commit message.
2. Set `filed:` here to the PR, run `npm run backlog`, commit.
3. When it ships, bump `@abaplint/runtime` in abap2UI5 and delete this item.
