---
target: open-abap
title: 'Built-in find( ): `case` ignored for `sub`, and negative `occ` fails for a multi-character `sub`'
summary: the transpiled find( ) searches case-sensitively whatever `case` says when it searches for `sub`, and answers -1 for a negative `occ` with a `sub` of two or more characters - correct ABAP finds nothing in the one place it runs without a system. Fix and tests are written and attached as a patch; filing is blocked only on write access to abaplint/transpiler
priority: medium
state: open
first_seen: 2026-09-23
checked_upstream: 2026-09-23
patch: backlog/patches/transpiler-find-case-negative-occ.patch
upstream: abaplint/transpiler
evidence:
  - found 2026-09-23 by the e2e smoke of abap2UI5/samples-controls - ports 109 and 307 read the marshalled DateRange array with `find( ... sub = '"startdate":"' case = abap_false )`, the framework writes `"startDate"`, and the toast / list stayed empty on the transpiled backend while correct on a system; worked around in abap2UI5/samples-controls#233 by matching the key in its exact case
  - reproduced against @abaplint/runtime 2.13.91 (the latest release on 2026-09-23) directly - `find( val = 'Hello World' sub = 'WORLD' case = abap_false )` answers -1 (ABAP 6), the same call with `regex` answers 6; `find( val = 'abcab' sub = 'ab' occ = -1 )` answers -1 (ABAP 3)
  - the upstream tests in `test/builtin/find.ts` use a negative `occ` only with `sub = '/'`, which is why the second bug passes there
  - abap2UI5/samples z2ui5_cl_smp_app_197 and 327 use the same case-insensitive reader, with keys whose case already matches the wire - safe today, and exposed the moment a key is spelled differently
---

# Built-in find( ): `case` ignored for `sub`, and negative `occ` fails for a multi-character `sub`

Two bugs in the non-regex branch of `find( )` (`packages/runtime/src/builtin/find.ts`), both reproducible on `@abaplint/runtime` 2.13.91.

## 1. `case = abap_false` is ignored when searching with `sub`

The `regex` / `pcre` branch applies `case` (it adds the `i` flag), but the `sub` branch always calls `val.indexOf( sub )`, so the search is always case-sensitive.

```abap
DATA(off) = find( val = `Hello World` sub = `WORLD` case = abap_false ).
" ABAP: 6    transpiled: -1
```

## 2. Negative `occ` returns -1 or a wrong offset for a `sub` longer than one character

For `occ < 0`, `val` is reversed but `sub` is not. The offset is then mapped back with `val.length - found - 1`, which is only correct for a one-character `sub`.

```abap
DATA(off) = find( val = `abcab` sub = `ab` occ = -1 ).
" ABAP: 3    transpiled: -1
```

The existing tests in `test/builtin/find.ts` use a negative `occ` only with `sub = '/'`, which is why this passes today.

## Repro against the runtime directly

```js
const { ABAP } = require("@abaplint/runtime");   // 2.13.91
const abap = new ABAP();
const S = (v) => new abap.types.String().set(v);
const C = (v) => new abap.types.Character(1).set(v);

abap.builtin.find({ val: S("Hello World"), sub: S("WORLD"), case: C(" ") }).get();    // -1, expected 6
abap.builtin.find({ val: S("Hello World"), regex: S("WORLD"), case: C(" ") }).get();  //  6 (regex branch is fine)
abap.builtin.find({ val: S("abcab"), sub: S("ab"), occ: new abap.types.Integer().set(-1) }).get(); // -1, expected 3
```

## The change

Written and tested; attached as
[`backlog/patches/transpiler-find-case-negative-occ.patch`](../patches/transpiler-find-case-negative-occ.patch)
(`git am` against `abaplint/transpiler`, made on top of `53963f2`).

- **`case`**: for a `case` other than `X`, both strings are lower-cased one character at a time. A character whose lower-case form has another length (`U+0130`) is kept as it is, so every offset stays valid. A plain `toLowerCase( )` would shift them.
- **Negative `occ`**: it searches from the right with `lastIndexOf` on the unreversed string, within the range that starts at `off`. The offset needs no mapping back. An empty `sub` keeps the previous behaviour.
- **Five new tests** in `test/builtin/find.ts`:
  - `case = abap_false` with `sub`
  - `case = abap_true` / default stays case-sensitive
  - `case` combined with a positive and a negative `occ`
  - a multi-character `sub` with a negative `occ`
  - a negative `occ` together with `off`

Measured on 2026-09-23:
- Against the old code, the 4 new behaviour tests fail and every existing one passes.
- With the fix, `test/builtin/find` and `find_any_of` pass (52 tests).
- The rest of `build/test` (without `unit`) has the identical failure set before and after. The only failures are the 127 `Database` top-level tests, which need a database that was not available.
- eslint is clean.

One assumption is not confirmed on a system: that a negative `occ` together with `off` searches only the range from `off` to the end. The ABAP documentation of `find( )` says `off` / `len` define the searched subarea, and the patch follows it.

## How to file it

A PR is the realistic ask here, since the fix is small and tested:

1. Fork `abaplint/transpiler`, `git am backlog/patches/transpiler-find-case-negative-occ.patch`, push a branch.
2. Open the PR with this body (from "Two bugs" down to the end of "The change").
3. Set `state: filed` and `filed: <url>` here, run `npm run backlog`, commit.

Filing was not done on 2026-09-23 because the session that wrote the patch had no write access to `abaplint/transpiler` (issue creation answered 403).
