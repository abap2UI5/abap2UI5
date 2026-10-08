---
target: open-abap
title: 'runtime: substring_after( ) and substring_before( ) ignore occ, len and case - occ = -1 cuts at the first match'
summary: '`packages/runtime/src/builtin/substring_after.ts` and `substring_before.ts` build one regex `sub(.*)` / `(.*?)sub` from `sub`/`regex`/`pcre` and never read `occ`, `len` or `case`; `substring_after( val = ''a-b-c'' sub = ''-'' occ = -1 )` is `b-c` instead of `c` - the code is right on a system and wrong in the transpiled build'
priority: medium
state: open
first_seen: 2026-10-08
upstream: abaplint/transpiler
evidence:
  - found 2026-10-08 in abap2UI5-addons/admin-cockpit - `z2ui5_cl_cockpit_session=>business_of` and `messages_of` took the last component of a field path with `substring_after( val = path sub = '-' occ = -1 )` and `substring_before( … occ = -1 )`; two unit tests failed under `npm run unit` (1 of 3 and 0 of 3 rows) because every path was cut at its first dash. Worked around with `find( val = path sub = '-' occ = -1 )` plus `substring( )` - `find( )` handles occ = -1 in the runtime
  - the cause, read in `@abaplint/runtime` 2.13.99 (`build/src/builtin/substring_after.js`) and unchanged at abaplint/transpiler main 65b3da1 - the function reads `val`, `sub`, `regex` and `pcre`, builds `new RegExp(reg + "(.*)")` and returns the first group; `occ`, `len` and `case` are not referenced in either file
  - nothing else in abap2UI5/src, sapgui, popups, abap-cloud-gui or admin-cockpit passes occ, len or case to these two functions (scan 2026-10-08)
checked_upstream: 2026-10-08
---

# runtime: substring_after( ) / substring_before( ) ignore occ, len and case

## What happens

```abap
DATA(lv_last) = substring_after( val = `ZCL_APP-MS_HEAD-KUNNR` sub = `-` occ = -1 ).
" system: KUNNR
" @abaplint/runtime 2.13.99: MS_HEAD-KUNNR
```

| Call | System | Runtime |
|---|---|---|
| `substring_after( val = 'a-b-c' sub = '-' occ = -1 )` | `c` | `b-c` |
| `substring_after( val = 'a-b-c' sub = '-' occ = 2 )` | `c` | `b-c` |
| `substring_before( val = 'a-b-c' sub = '-' occ = -1 )` | `a-b` | `a` |
| `substring_after( val = 'aXb' sub = 'x' case = abap_false )` | `b` | `` |
| `substring_after( val = 'a-bcd' sub = '-' len = 2 )` | `bc` | `bcd` |

## Why

`packages/runtime/src/builtin/substring_after.ts` (and `substring_before.ts`
alike) takes `sub`, `regex` or `pcre` into one pattern and returns the first
group of `new RegExp(reg + "(.*)")`. `occ`, `len` and `case` are never read.

## A fix

The runtime's `find( )` already resolves `occ` (positive and negative) and
`case`; `substring_after` can use it for the offset of the match and its
length, then cut with `substring( )`:

- position of the occ-th match (from the end for a negative occ) and its
  length - from `find( )` with `sub`/`regex`/`pcre`, `case`, `occ`;
- not found: an empty result (as today);
- the rest after the match, cut to `len` when given (`substring_before`: the
  part before the match, the last `len` characters of it).

## Tests to add

The five rows of the table above, plus `regex` with `occ = -1`.

## How to file

An issue or a PR against abaplint/transpiler (`packages/runtime`). Record the
search in `checked_upstream:` (2026-10-08: the issue search "substring_after
occ substring_before occurrence ignored" in abaplint/transpiler, 0 results).
