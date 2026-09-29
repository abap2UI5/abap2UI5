---
target: open-abap
title: 'LOOP reads a row that is not there: index -1 on a secondary key the WHERE does not name, and past the end after a DELETE under USING KEY primary_key'
summary: `LOOP AT t USING KEY k WHERE b = 2` (k over a) starts at row index -1 and throws "Cannot read properties of undefined (reading 'get')"; a LOOP USING KEY primary_key whose body deletes a row reads array[array.length] - with a WHERE the same TypeError, without one the last row twice. ABAP runs both. Two one-line fixes and tests are attached as a patch
priority: medium
state: open
first_seen: 2026-09-29
patch: backlog/patches/transpiler-loop-where-crashes.patch
upstream: abaplint/transpiler
evidence:
  - found 2026-09-29 by the differential test of the sorted-primary-key fast path in @abap2ui5/node-runtime (abap2UI5#2813), which runs thousands of generated LOOP bodies against the original runtime - the fast path deliberately reproduces the second crash to stay identical to the function it replaces
  - reproduced 2026-09-29 on @abaplint/transpiler-cli and @abaplint/runtime 2.13.93, the latest release - `LOOP AT t INTO r USING KEY k WHERE b = 2` throws the TypeError at `build/src/statements/loop.js:139` (ABAP yields 1/2 2/2); `LOOP AT s INTO r USING KEY (name) WHERE a = 1` with name = `primary_key` and `DELETE s INDEX 3` in the body throws the same (ABAP yields 1/1 1/2); `LOOP AT s INTO r USING KEY primary_key` with that DELETE and no WHERE yields 1/1 1/2 1/2
  - unchanged at abaplint/transpiler main 916d00f (2026-09-29) - `determineFromTo` starts at `from = 0` where its branch without topEquals answers 1, and the loop's guard is `index > array.length`
  - the attached patch, on 916d00f - its three tests fail before and pass after; the non-database test sets (2288 tests) pass; eslint clean
---

# LOOP reads a row that is not there

Two ways `abap.statements.loop` (`packages/runtime/src/statements/loop.ts`)
reads past the rows of the table. Both end in `TypeError: Cannot read
properties of undefined (reading 'get')`, where ABAP runs the loop.

## 1. A WHERE that does not name the secondary key's first field

```abap
TYPES: BEGIN OF ty, a TYPE i, b TYPE i, END OF ty.
DATA t TYPE STANDARD TABLE OF ty WITH NON-UNIQUE KEY a b
       WITH NON-UNIQUE SORTED KEY k COMPONENTS a.
DATA r TYPE ty.
t = VALUE #( ( a = 1 b = 0 ) ( a = 2 b = 2 ) ( a = 3 b = 0 ) ( a = 1 b = 2 ) ).
LOOP AT t INTO r USING KEY k WHERE b = 2.   " TypeError; ABAP: 1/2 2/2
ENDLOOP.
```

`topEquals` is `{b: 2}`, and it does not name `a`. `determineFromTo` answers
`from = 0`, but without `topEquals` it answers `from = 1`, and the caller
takes `from` as 1-based: `loopFrom = Math.max(loopFrom, from) - 1`. So the
loop starts at index -1.

## 2. A DELETE in the body of a LOOP USING KEY primary_key

```abap
DATA s TYPE SORTED TABLE OF ty WITH NON-UNIQUE KEY a.
s = VALUE #( ( a = 1 b = 1 ) ( a = 1 b = 2 ) ( a = 2 b = 3 ) ).
LOOP AT s INTO r USING KEY primary_key.
  IF lines( s ) = 3.
    DELETE s INDEX 3.
  ENDIF.
ENDLOOP.
" ABAP: 1/1 1/2    transpiled: 1/1 1/2 1/2
" with a WHERE (USING KEY (name) WHERE a = 1): TypeError
```

`loopTo` is refreshed after each row only for a LOOP without USING KEY. The
guard `if (loopController.index > array.length) break;` lets the index reach
`array.length`, and `array[array.length]` is `undefined`. With a WHERE,
`current.get()` throws. Without one, the target keeps the previous row, and
the body runs for it a second time.

(A static `USING KEY primary_key WHERE ...` hits
[`abaplint-loop-using-primary-key-where`](abaplint-loop-using-primary-key-where.md)
first, so the repro uses a dynamic name - which is what ajson, abap2UI5's
`z2ui5_cl_ajson`, writes: `USING KEY (lv_tab_key) WHERE path = ...`.)

## The change

```diff
-  let from = 0;
+  let from = 1;
   let to = array.length;
 ...
-    from = binarySearchFrom(array, from, to, keyField, keyValue);
+    from = binarySearchFrom(array, 0, to, keyField, keyValue);
 ...
-      if (loopController.index > array.length) {
+      if (loopController.index >= array.length) {
         break;
       }
```

Written and tested; attached as
[`backlog/patches/transpiler-loop-where-crashes.patch`](../patches/transpiler-loop-where-crashes.patch)
(`git am --keep-cr` against 916d00f). The three new tests in
`test/statements/loop.ts` fail before and pass after. The non-database test
sets pass (2288 tests), and eslint is clean.

[`transpiler-loop-sorted-primary-key`](transpiler-loop-sorted-primary-key.md)
carries the same two lines; whichever lands second drops them.

## How to file

1. Search the abaplint/transpiler tracker first and record the date in `checked_upstream:`.
2. Open a PR with the patch (`git am --keep-cr`) and this body.
3. Set `state: filed` and `filed: <url>` here, run `npm run backlog`, commit.
