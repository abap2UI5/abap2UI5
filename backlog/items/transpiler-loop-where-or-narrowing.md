---
target: open-abap
title: 'LOOP ... USING KEY ... WHERE with an OR drops the rows only the other side of the OR accepts'
summary: the transpiler hands the runtime every `=` of a LOOP's WHERE as a condition all rows must meet (`topEquals`), also the ones inside an OR, and the runtime narrows a secondary key by it - `LOOP AT t USING KEY k WHERE a = 1 OR b = 2` never visits the rows only `b = 2` accepts. Silently wrong rows, no error. Fix and test are written and attached as a patch
priority: high
state: open
first_seen: 2026-09-29
patch: backlog/patches/transpiler-loop-where-or-narrowing.patch
upstream: abaplint/transpiler
evidence:
  - found 2026-09-29 while writing the sorted-primary-key fast path of @abap2ui5/node-runtime (`node/srv/accelerate.mjs`, abap2UI5#2813) - its differential test compares every WHERE shape with the original runtime, and a narrowing that trusts `topEquals` loses rows on an OR; the patch had to detect the OR itself
  - reproduced 2026-09-29 on @abaplint/transpiler-cli and @abaplint/runtime 2.13.93, the latest release - rows 1/0 2/2 3/0 1/2, `LOOP AT t INTO r USING KEY k WHERE a = 1 OR b = 2` (k over a) yields 1/0 1/2; ABAP yields 1/0 1/2 2/2. The emitted code carries `topEquals: {"a": 1, "b": 2}` for the OR
  - unchanged at abaplint/transpiler main 916d00f (2026-09-29) - `packages/transpiler/src/statements/loop.ts` collects `findDirectExpressions(ComponentCompare)` of the WHERE without looking at the operators between them
  - the attached patch, on 916d00f - its test fails before and passes after; the non-database test sets (2286 tests: builtin, code_structure, expressions, operators, statements, types, conversion, keywords, running_examples and the transpiler and runtime packages' own) pass; eslint clean
---

# LOOP ... USING KEY ... WHERE with an OR drops rows

## What happens

```abap
TYPES: BEGIN OF ty, a TYPE i, b TYPE i, END OF ty.
DATA t TYPE STANDARD TABLE OF ty WITH NON-UNIQUE KEY a b
       WITH NON-UNIQUE SORTED KEY k COMPONENTS a.
DATA r TYPE ty.
t = VALUE #( ( a = 1 b = 0 ) ( a = 2 b = 2 ) ( a = 3 b = 0 ) ( a = 1 b = 2 ) ).
LOOP AT t INTO r USING KEY k WHERE a = 1 OR b = 2.
  WRITE / |{ r-a }/{ r-b }|.
ENDLOOP.
" ABAP: 1/0 1/2 2/2    transpiled: 1/0 1/2
```

No error. The row that only the right side of the OR accepts is never visited.

## Why

`LoopTranspiler` (`packages/transpiler/src/statements/loop.ts`) collects the
`=` comparisons of the WHERE into `topEquals` - the conditions every row has
to meet. It takes every direct `ComponentCompare` of the `ComponentCond`, but
`ComponentCond` is `cnd ((AND|OR) cnd)*`, so for `a = 1 OR b = 2` it emits

```js
abap.statements.loop(t, {usingKey: "k", where: ..., topEquals: {"a": ..., "b": ...}})
```

The runtime (`determineFromTo` in `packages/runtime/src/statements/loop.ts`)
then binary-searches the secondary key's first field for `a = 1` and runs the
WHERE only on that block.

## The change

`topEquals` is emitted only when every top-level operator of the WHERE is
`AND`. `a = 1 AND ( b = 2 OR b = 3 )` still gives `{a}`, and
`( a = 1 OR a = 2 ) AND b = 3` gives `{b}`:

```diff
     const topEquals: {[key: string]: string} = {};
-    for (const compare of whereNode?.findDirectExpressions(abaplint.Expressions.ComponentCompare) || []) {
+    // only a pure conjunction makes each top-level `=` a condition every row
+    // has to meet: `a = 1 OR b = 2` narrows by neither
+    const onlyAnd = whereNode?.getChildren().every(
+      c => !(c instanceof abaplint.Nodes.TokenNode) || c.concatTokens().toUpperCase() !== "OR") ?? true;
+    for (const compare of onlyAnd ? whereNode?.findDirectExpressions(abaplint.Expressions.ComponentCompare) || [] : []) {
```

Code transpiled before the fix still carries the OR's `topEquals` until it is
transpiled again. If the runtime should not trust old output, the new emission
could use a new property name.

Written and tested; attached as
[`backlog/patches/transpiler-loop-where-or-narrowing.patch`](../patches/transpiler-loop-where-or-narrowing.patch)
(`git am --keep-cr` against `abaplint/transpiler` 916d00f - the test file has
CRLF line endings). A new test in `test/statements/loop.ts` fails before and
passes after. With it, the non-database test sets pass (2286 tests) and eslint
is clean.

## How to file

1. Search the abaplint/transpiler tracker for an existing report and record the date in `checked_upstream:`.
2. Fork `abaplint/transpiler`, `git am --keep-cr` the patch, push a branch, and open the PR with this body (from "What happens" to the end of "The change").
3. Set `state: filed` and `filed: <url>` here, run `npm run backlog`, commit.

[`transpiler-loop-sorted-primary-key`](transpiler-loop-sorted-primary-key.md)
builds on this fix: a primary-key narrowing needs the same guarantee.
