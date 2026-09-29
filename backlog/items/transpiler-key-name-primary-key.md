---
target: open-abap
title: 'The runtime knows the primary key only as lower-case `primary_key`: READ TABLE ... WITH KEY primary_key COMPONENTS, USING KEY PRIMARY_KEY and a key name in a c field all throw "secondary key not found"'
summary: every spelling ABAP accepts for the primary key other than lower-case `primary_key`, and every dynamic key name held in a c field (it comes with its padding), is looked up among the secondary keys and throws "Table, secondary key ... not found" - as a plain string no CATCH catches. READ TABLE ... WITH [TABLE] KEY primary_key COMPONENTS fails even in lower case. Fix and tests are attached as a patch
priority: medium
state: open
first_seen: 2026-09-29
patch: backlog/patches/transpiler-key-name-primary-key.patch
upstream: abaplint/transpiler
evidence:
  - found 2026-09-29 while reproducing the LOOP items of this stock - a dynamic `USING KEY ( name )` with name = `PRIMARY_KEY`, the spelling ABAP code writes, threw where the lower-case name ran; abap2UI5's ajson only works because it writes `'primary_key'` in lower case
  - reproduced 2026-09-29 on @abaplint/transpiler-cli and @abaplint/runtime 2.13.93, the latest release - `LOOP AT t INTO r USING KEY PRIMARY_KEY.` and a dynamic name `PRIMARY_KEY` throw `Table, secondary key "PRIMARY_KEY" not found`; `READ TABLE s INTO r WITH KEY primary_key COMPONENTS a = 2` and `... WITH TABLE KEY primary_key COMPONENTS a = 2` throw `Table, secondary key "primary_key" not found` (ABAP finds the row, sy-subrc 0); a dynamic name in a `c LENGTH 20` field holding `K` throws `Table, secondary key "K                   " not found`, lower-case `k` and upper-case `K` in a string run
  - the thrown value is a string, not an exception object - `TRY ... CATCH cx_root` around the LOOP does not catch it
  - unchanged at abaplint/transpiler main 916d00f (2026-09-29) - `loop.ts` compares `options.usingKey !== "primary_key"`, `readTable` looks `keyName` up with `getSecondaryIndex`, and `getKeyByName` / `getSecondaryIndex` compare the untrimmed name
  - the attached patch, on 916d00f - its four tests fail before and pass after; the non-database test sets (2289 tests) pass; eslint clean
---

# The runtime knows the primary key only as lower-case `primary_key`

ABAP names the primary key `primary_key`, in whatever case the source writes
it or a dynamic name holds it, and it ignores the trailing blanks of a name
held in a `c` field. The runtime compares key names verbatim:

```abap
TYPES: BEGIN OF ty, a TYPE i, b TYPE i, END OF ty.
DATA t TYPE STANDARD TABLE OF ty WITH NON-UNIQUE KEY a b
       WITH NON-UNIQUE SORTED KEY k COMPONENTS a.
DATA s TYPE SORTED TABLE OF ty WITH NON-UNIQUE KEY a.
DATA r TYPE ty.
DATA name TYPE string VALUE 'PRIMARY_KEY'.
DATA key TYPE c LENGTH 20 VALUE 'K'.

LOOP AT t INTO r USING KEY PRIMARY_KEY.   " Table, secondary key "PRIMARY_KEY" not found
ENDLOOP.
LOOP AT t INTO r USING KEY (name).        " the same
ENDLOOP.
LOOP AT t INTO r USING KEY (key).         " Table, secondary key "K                   " not found
ENDLOOP.
READ TABLE s INTO r WITH KEY primary_key COMPONENTS a = 2.        " Table, secondary key "primary_key" not found
READ TABLE s INTO r WITH TABLE KEY primary_key COMPONENTS a = 2.  " the same
```

- The static name goes over as written (`usingKey: "PRIMARY_KEY"`). A dynamic
  one goes over as the field's value, padding included.
- `loop.ts` recognises only `options.usingKey === "primary_key"`.
- `readTable` sends every `keyName`, `primary_key` included, to
  `getSecondaryIndex`.
- `getKeyByName` / `getSecondaryIndex` compare case-insensitively but do not
  trim.

Each failure is `throw \`Table, secondary key "${name}" not found\``: a string,
which no `CATCH` catches.

There is a second, quieter difference. A LOOP USING KEY primary_key does not
refresh its end after each row the way a LOOP without USING KEY does, so it
does not visit rows its body appends. ABAP makes no difference between the
two loops.

## The change

A name is read the way ABAP reads it, in one place:

```ts
/** The secondary key a key name selects: without the blanks a c field pads
 *  it with, in any case - and undefined for the primary key, which
 *  primary_key names however it is written, and so does an initial name. */
export function secondaryKeyName(name: string | undefined): string | undefined {
  const trimmed = name?.trimEnd();
  return trimmed === undefined || trimmed === "" || trimmed.toLowerCase() === "primary_key" ? undefined : trimmed;
}
```

- **LOOP** uses it for the key it runs over. `undefined` takes the
  primary-key path, and the end refresh along with it.
- **READ TABLE** drops a `keyName` that names the primary key. It then reads
  as the same READ without the key name does.
- **`getKeyByName` / `getSecondaryIndex`** trim the name.

Written and tested; attached as
[`backlog/patches/transpiler-key-name-primary-key.patch`](../patches/transpiler-key-name-primary-key.patch)
(`git am --keep-cr` against 916d00f). It adds four tests:
- upper case, static and dynamic
- names in a `c` field
- a row appended under USING KEY primary_key is visited
- READ TABLE WITH [TABLE] KEY primary_key COMPONENTS

All four fail before and pass after. The non-database test sets pass (2289
tests), and eslint is clean.

The patch leaves one thing alone: the error for a key the table really does
not have is still thrown as a string. What ABAP raises there should be checked
on a system before this is changed.

## How to file

1. Search the abaplint/transpiler tracker first and record the date in `checked_upstream:`.
2. Open a PR with the patch (`git am --keep-cr`) and this body.
3. Set `state: filed` and `filed: <url>` here, run `npm run backlog`, commit.
