---
target: open-abap
title: 'cl_abap_tstmp=>add( ) / subtractsecs( ) truncate a TIMESTAMPL to the whole second and answer a short TIMESTAMP - a +60 s / diff round trip gives 59'
summary: open-abap-core's `cl_abap_tstmp=>add( )` is declared `RETURNING VALUE(time) TYPE timestamp` and its kernel line keeps 14 digits (`toISOString( ).slice( 0, 19 )`), so the 7 fraction digits of a `timestampl` input are dropped - on a system the result carries them (the method answers packed with decimals); `subtract( )` returns `i`, whole seconds. `time_get_timestampl( ) + 60` followed by a diff answers 59 for any input whose fraction is not 0, which is most of them
priority: medium
state: filed
filed: https://github.com/open-abap/open-abap-core/pull/1311
checked_upstream: 2026-10-13
first_seen: 2026-10-12
evidence:
  - found 2026-10-12 going through every abap2UI5 unit test that does not run under `npm run unit` - `z2ui5_cl_util` `ltcl_time_ops->add_seconds` and `->diff_seconds` (skipped in `node/setup/abap_transpile.json`, the old note blamed "fractional seconds") do `time_add_seconds( time = time_get_timestampl( ) seconds = 60 )` and assert `time_diff_seconds( ) = 60`
  - measured 2026-10-12 on open-abap-core b2d219d with `@abaplint/runtime` 2.14.3 - `time_get_timestampl( )` answers `20261012193756.7`, `cl_abap_tstmp=>add( tstmp = that secs = 60 )` answers `20261012193856` (no fraction), the diff is 59; the pair passes or fails with the fraction the clock happened to carry, which is why the old note read "off by one"
  - the cause, read in `src/date_time/cl_abap_tstmp.clas.abap` at b2d219d - `add` is `RETURNING VALUE(time) TYPE timestamp` (p LENGTH 8 DECIMALS 0) and ends in `WRITE '@KERNEL time.set(t1.toISOString().slice(0, 19)…'`, `subtract` is `RETURNING VALUE(r_secs) TYPE i` with `r_secs.set((t1 - t2)/1000)`; on a system both methods are typed with the class's packed `tstmp` type and keep the fraction, which is what the abap2UI5 test relies on and has relied on since it was written against a system
  - with `add( )` answering `p LENGTH 11 DECIMALS 7` and carrying the input's fraction (patch below, applied in memory) `add_seconds`, `diff_seconds` and `subtract_seconds` pass
---

# `cl_abap_tstmp=>add( )` loses the fraction of a `timestampl`

## What happens

```abap
DATA lv_from TYPE timestampl.
DATA lv_to   TYPE timestampl.
GET TIME STAMP FIELD lv_from.                              " 20261012193756.7000000
lv_to = cl_abap_tstmp=>add( tstmp = lv_from secs = 60 ).  " system: 20261012193856.7000000
                                                          " open-abap: 20261012193856
cl_abap_tstmp=>subtract( tstmp1 = lv_to tstmp2 = lv_from ). " system: 60 - open-abap: 59
```

Every caller that adds to a long timestamp and compares, orders or diffs the
result against the original is off by up to a second, in the direction of
"earlier" - a timeout computed as `now + n` expires early, a round trip
through `add( )` and `subtract( )` does not give `n` back.

## Where

`src/date_time/cl_abap_tstmp.clas.abap`:

- `add` - `RETURNING VALUE(time) TYPE timestamp`, and
  `WRITE '@KERNEL time.set(t1.toISOString().slice(0, 19).replace(…));'`
  writes 14 digits.
- `subtractsecs` - the same type, through `add`.
- `subtract` - `RETURNING VALUE(r_secs) TYPE i`, so even with a correct
  `add` the difference is whole seconds. (A system answers a packed value
  with decimals here.)

## The fix

Return a packed value with 7 decimals and carry the fraction:

```diff
     CLASS-METHODS add
       IMPORTING
         tstmp       TYPE p
         secs        TYPE numeric
       RETURNING
-        VALUE(time) TYPE timestamp.
+        VALUE(time) TYPE tzntstmpl.
```

and in the body keep what the ISO template split off at the comma:

```abap
METHOD add.
  DATA str      TYPE string.
  DATA lv_frac  TYPE string.
  str = |{ tstmp TIMESTAMP = ISO }|.
  IF str CA ','.
    SPLIT str AT ',' INTO str lv_frac.
  ENDIF.
  WRITE '@KERNEL let t1 = new Date(Date.parse(str.get() + "Z"));'.
  WRITE '@KERNEL t1.setMilliseconds(t1.getMilliseconds() + Math.round(secs.get() * 1000));'.
  WRITE '@KERNEL const iso = t1.toISOString();'.
  WRITE '@KERNEL let digits = iso.slice(0, 19).replace(/-/g, "").replace(/:/g, "").replace("T", "");'.
  WRITE '@KERNEL const frac = secs.get() % 1 === 0 ? lv_frac.get() : (iso.slice(20, 23) + "0000").slice(0, 7);'.
  WRITE '@KERNEL time.set(frac ? digits + "." + frac : digits);'.
ENDMETHOD.
```

A short `timestamp` caller assigns the result to its `p LENGTH 8` target
and loses the fraction as it does on a system. `subtract( )` the same way:
`RETURNING VALUE(r_secs) TYPE tzntstmpl` (or a `p` with decimals) and
`(t1 - t2) / 1000` with the fraction of both inputs added back. Measured
in memory against abap2UI5's transpiled tree (2026-10-12), the `add( )`
half alone makes `add_seconds`, `diff_seconds` and `subtract_seconds` of
`z2ui5_cl_util` pass.

## Repro

```abap
METHOD add_keeps_fraction.
  DATA lv_from TYPE timestampl.
  DATA lv_to   TYPE timestampl.
  lv_from = '20240229235959.5000000'.
  lv_to = cl_abap_tstmp=>add( tstmp = lv_from secs = 60 ).
  cl_abap_unit_assert=>assert_equals( act = lv_to exp = '20240301000059.5000000' ).
ENDMETHOD.
```

## How to file

A PR against open-abap/open-abap-core: the signature and body above, the
same for `subtract( )`, and the test in
`cl_abap_tstmp.clas.testclasses.abap`. Note in the PR that the SAP signature
of both methods is packed with decimals, so this is a conformance fix, not
a feature.

1. Search the open-abap-core tracker first and record the date in
   `checked_upstream:`.
2. Open the PR.
3. Set `state: filed` and `filed: <url>` here, run `npm run backlog`, commit.
4. When it merges, bump the open-abap-core pin in abap2UI5, drop the
   `add_seconds`/`diff_seconds` entries from `node/setup/abap_transpile.json`,
   delete this item.
