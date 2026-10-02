---
target: open-abap
title: 'LOOP ... WHERE over a SORTED primary key scans every row - one table of n rows costs abap2UI5 n² per roundtrip'
summary: the runtime narrows a LOOP ... WHERE by binary search only on a secondary key; over a sorted primary key it evaluates the WHERE on every row, and abap2UI5's JSON serializer (a fork of abapGit's ajson) runs such a LOOP once per node - the event roundtrip of a 2000-row table took 22.6 s in a CAP project, 1.8 s with this and the CP change. @abap2ui5/node-runtime ships both as a runtime patch meanwhile; the upstream change is attached as a patch
priority: medium
state: open
first_seen: 2026-09-29
checked_upstream: 2026-10-02
patch: backlog/patches/transpiler-loop-sorted-primary-key.patch
upstream: abaplint/transpiler
evidence:
  - measured 2026-09-29 in a CAP project (@cap2ui5/cds-plugin on @abap2ui5/node-runtime 1.145.0, Node 22) - one table of n rows bound to a sap.m.Table, the event roundtrip took 6.2 s at 1000 rows and 22.6 s at 2000; CPU profiles put the time in `statements/loop.ts` (this item) and `compare/cp.ts` (the CP change, abaplint/transpiler#1933)
  - with both changes installed on the running runtime (`accelerate()` of @abap2ui5/node-runtime, `node/srv/accelerate.mjs`, abap2UI5#2813) - 1.8 s at 2000 rows, 2.6 s at 4000, 4.4 s at 8000; the plain package without CAP (`node/tests-examples/rowsRoundtrip.bench.mjs`) 8.8 s -> 2.1 s CPU for the event at 2000 rows; abap2UI5's unit suite 18.0 s -> 12.6 s
  - the runtime patch is held to the original function by a differential, seeded property test (`node/tests/accelerate.spec.js`) - about 51 000 generated LOOP scenarios per run, identical traces everywhere except where the original crashes (fixed upstream with abaplint/transpiler#1930)
  - unchanged at abaplint/transpiler main 916d00f (2026-09-29); @abaplint/runtime 2.13.93 is the latest release
  - the attached patch, rebased 2026-10-02 on abaplint/transpiler main 1181ca6 (after #1929-#1933 merged) - the non-database test sets (2315 tests, two new ones for the block, sy-tabix, AND, OR and inserts into the block) pass; eslint clean. A LOOP WHERE over 4000 rows of a sorted table, 2000 times, took 1664 ms before and 70 ms after, the same rows found
---

# LOOP ... WHERE over a sorted primary key: binary-search the block

## The problem

Take an abap2UI5 app whose one table of *n* rows is bound to a `sap.m.Table`.
A roundtrip of it costs O(n²) in the transpiled framework. The ABAP is
linear, and on an SAP system the same app answers in milliseconds.

`statements/loop.ts` narrows a `LOOP AT itab ... WHERE` by binary search
(`determineFromTo`) only for a *secondary* key. Over a **SORTED primary key**
it evaluates the WHERE on every row, even when the transpiler handed it
`topEquals` for the first key field.

abap2UI5's JSON serializer (`z2ui5_cl_ajson`, a fork of abapGit's ajson) runs
such a loop once per node:

```abap
LOOP AT mt_json_tree ASSIGNING <n> USING KEY (lv_tab_key) WHERE path = iv_parent_path.
```

`mt_json_tree` is a `SORTED TABLE ... WITH UNIQUE KEY path name`, so n nodes
each scan n rows.

| rows | event roundtrip, 2.13.93 | with this and the CP change | measured in |
|---:|---:|---:|---|
| 1000 | 6.2 s | - | CAP project, Node 22 |
| 2000 | 22.6 s | 1.8 s | CAP project, Node 22 |
| 8000 | - | 4.4 s | CAP project, Node 22 |
| 2000 | 8.8 s CPU | 2.1 s CPU | plain package, `rowsRoundtrip.bench.mjs` |

## The change

The narrowing applies when three things hold:
- the table's primary key is SORTED
- the loop runs over the primary key
- `topEquals` requires the key's first field to equal a value

Then the rows the WHERE can accept are one contiguous block of the array. The
loop binary-searches the start of the block, scans from there with the WHERE
as today, and stops at the first row that sorts *after* the value.

Three things it has to get right:

- **`topEquals` must be a conjunction.** A narrowing by one side of an OR loses
  the other side's rows. The transpiler emits it for a pure conjunction only
  since abaplint/transpiler#1929, which this patch is based on.
- **The operand has to order like the sort.** The sort compares key fields
  with `lt`/`eq`, and the binary search compares a key field with the WHERE
  operand. Mixed types can disagree: for a `c(10)` key and a `c(3)` operand,
  `eq('abc       ', 'abc')` and `gt('abc       ', 'abc')` are both true. So the
  loop narrows only where the orders provably agree:
  - the operand has the field's own type, and for `c`, `n`, `x` its length
  - or a `c` operand is compared with a `string` field

  Everything else scans as before.
- **Stopping early must not change what a scan finds.** `INSERT LINES OF`
  into the table in the body re-sorts it without moving the loop index. So
  the loop stops at a row that sorts *after* the value, not at the first
  unequal one.

Everything else about the loop stays as it is: `startLoop`/`unregisterLoop`
(so an INSERT or DELETE in the body shifts the index as today), sy-tabix per
row and its restore, and sy-subrc.

The patch
[`backlog/patches/transpiler-loop-sorted-primary-key.patch`](../patches/transpiler-loop-sorted-primary-key.patch)
applies with `git am --keep-cr` on abaplint/transpiler main 1181ca6. It adds two
tests to `test/statements/loop.ts`:
- the block and its sy-tabix, a miss with sy-subrc 4, AND and OR
- a row the body inserts into the block is visited, one it inserts before the block is not

The two one-liners the narrowing runs into (the loop starting at index -1,
and reading `array[array.length]` after a DELETE) landed upstream with
abaplint/transpiler#1930, so the rebased patch no longer carries them.

## Also seen

- A LOOP WHERE evaluates its operands per row. With the narrowing, an operand
  that is a functional method call runs for fewer rows than today. That is a
  behaviour change worth a changelog line.
- What abap2UI5 does meanwhile: `@abap2ui5/node-runtime` installs the same
  narrowing on the running runtime (`accelerate()`), pinned to
  `@abaplint/runtime` 2.13.93. On any other version it installs nothing, and
  CI goes red when the lockfile moves the runtime. The patch goes once the
  runtime narrows sorted primary keys itself.

## How to file

1. Search the abaplint/transpiler tracker and record the date in `checked_upstream:`.
2. Open a PR with the patch and this body. Link abaplint/transpiler#1933 (CP), since the measurements are for both.
3. Set `state: filed` and `filed: <url>` here, run `npm run backlog`, commit.
