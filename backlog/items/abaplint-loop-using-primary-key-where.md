---
target: abaplint
title: 'check_syntax: `LOOP ... USING KEY primary_key WHERE ...` is "Key primary_key not found in table type"'
summary: a LOOP with USING KEY and a WHERE has its key looked up among the secondary keys only, so the predefined name of the primary key is a syntax error - for every table kind, INTO and ASSIGNING alike - while the same LOOP without a WHERE, and DELETE ... USING KEY primary_key WHERE, pass. Fix and tests are attached as a patch
priority: medium
state: open
first_seen: 2026-09-29
patch: backlog/patches/abaplint-loop-using-primary-key-where.patch
upstream: abaplint/abaplint
evidence:
  - found 2026-09-29 writing the repros of this stock's LOOP items - the transpile of `LOOP AT s INTO r USING KEY primary_key WHERE a = 1.` stopped at `check_syntax, Key primary_key not found in table type`
  - measured 2026-09-29 on abaplint 2.120.60, the latest release - reported for a SORTED table (declared with DATA and through TYPES), a STANDARD table WITH EMPTY KEY, INTO a variable and ASSIGNING an inline field symbol, and for a table that names its primary key explicitly (`WITH NON-UNIQUE KEY primary_key COMPONENTS a`); not reported for the same LOOP without a WHERE, for `DELETE s USING KEY primary_key WHERE a = 1`, for `READ TABLE ... WITH [TABLE] KEY primary_key COMPONENTS` and for `USING KEY <secondary> WHERE`
  - unchanged at abaplint main f09171a (2026-09-28) - `packages/core/src/abap/5_syntax/statements/loop.ts` looks the name up in `topType.getOptions().secondary` only; the existing test `loop USING KEY primary_key` has no WHERE
  - the attached patch, on f09171a - two new tests fail before and pass after, a third pins that an unknown key is still reported; all 11 151 tests of packages/core pass (32 pending, as before), eslint clean
---

# check_syntax: `LOOP ... USING KEY primary_key WHERE ...`

## What happens

```abap
TYPES: BEGIN OF ty, a TYPE i, b TYPE i, END OF ty.
DATA tab TYPE SORTED TABLE OF ty WITH NON-UNIQUE KEY a.

LOOP AT tab INTO DATA(row) USING KEY primary_key WHERE a = 1.   " Key primary_key not found in table type
ENDLOOP.

LOOP AT tab INTO row USING KEY primary_key.                     " fine
ENDLOOP.
DELETE tab USING KEY primary_key WHERE a = 1.                    " fine
```

`primary_key` is the predefined name of the primary key, which every internal
table has, and `USING KEY primary_key` is legal in any LOOP. The check reports
it for every table kind, with INTO and with ASSIGNING, and even for a table
that names its primary key explicitly (`WITH NON-UNIQUE KEY primary_key
COMPONENTS a`).

## Why

`packages/core/src/abap/5_syntax/statements/loop.ts`, the check added for
abap2xlsx#1341 (IS INITIAL on a secondary key's field before 7.40 SP02),
looks the key of a `USING KEY <name>` with a WHERE up among the secondary
keys only:

```ts
key = topType.getOptions().secondary?.find(k => k.name.toUpperCase() === keyName.getFirstToken().getStr().toUpperCase());
if (key === undefined) {
  const message = "Key " + keyName?.concatTokens() + " not found in table type";
```

## The change

`primary_key` is accepted as the key every table has. The 7.40 SP02 check
keeps applying to secondary keys only, as today, and a key name the table
does not have is still reported:

```diff
-      if (keyName?.get() instanceof Expressions.SimpleName) {
-        // it might be dynamic, in that case we cannot check anything
-        key = topType.getOptions().secondary?.find(k => k.name.toUpperCase() === keyName.getFirstToken().getStr().toUpperCase());
+      const name = keyName?.get() instanceof Expressions.SimpleName ? keyName.getFirstToken().getStr().toUpperCase() : undefined;
+      // it might be dynamic, in that case we cannot check anything; and
+      // primary_key is the predefined name of the primary key every table has
+      if (name !== undefined && name !== "PRIMARY_KEY") {
+        key = topType.getOptions().secondary?.find(k => k.name.toUpperCase() === name);
```

Written and tested; attached as
[`backlog/patches/abaplint-loop-using-primary-key-where.patch`](../patches/abaplint-loop-using-primary-key-where.patch)
(`git am` against abaplint/abaplint f09171a). It adds three tests in
`packages/core/test/abap/syntax/syntax.ts`:
- a sorted table with INTO
- a standard table with ASSIGNING
- a key the table does not have, which is still reported

The first two fail before and pass after. All 11 151 tests of `packages/core`
pass (32 pending, as before), and eslint is clean.

## How to file

The fix is small and tested, so a PR is the realistic ask:

1. Search the abaplint tracker first and record the date in `checked_upstream:`.
2. Fork `abaplint/abaplint`, `git am` the patch, push a branch, and open the PR with this body.
3. Set `state: filed` and `filed: <url>` here, run `npm run backlog`, commit.
