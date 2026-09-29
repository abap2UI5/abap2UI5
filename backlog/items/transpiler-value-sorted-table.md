---
target: open-abap
title: 'VALUE #( ) of a SORTED table type is in insertion order until it is assigned - handed straight to a method, LOOP runs unsorted and READ TABLE misses'
summary: the transpiler builds a VALUE #( ) row by row with appendThis( ), which pushes; only an assignment sorts the result. A sorted-table VALUE handed straight to a method parameter or looped over is a SORTED table in insertion order - LOOP yields 5 4 3 2 1 and READ TABLE ... WITH TABLE KEY answers sy-subrc 8 for a row that is there. Fix and test are attached as a patch
priority: high
state: open
first_seen: 2026-09-29
patch: backlog/patches/transpiler-value-sorted-table.patch
upstream: abaplint/transpiler
evidence:
  - found 2026-09-29 while writing the sorted-primary-key fast path of @abap2ui5/node-runtime (abap2UI5#2813), whose binary search, like every other binary search of the runtime, assumes a sorted table is sorted
  - reproduced 2026-09-29 on @abaplint/transpiler-cli and @abaplint/runtime 2.13.93, the latest release - a method `show( IMPORTING it TYPE ty_sorted )` called as `show( VALUE ty_sorted( ( a = 5 ) ( a = 4 ) ( a = 3 ) ( a = 2 ) ( a = 1 ) ) )` loops 5 4 3 2 1 (ABAP 1 2 3 4 5), and `READ TABLE it WITH TABLE KEY a = 5` answers sy-subrc 8 (ABAP 0)
  - unchanged at abaplint/transpiler main 916d00f (2026-09-29) - `value_body_line.ts` emits `.appendThis( row )`, and `Table.appendThis` calls `append`, which pushes
  - the attached patch, on 916d00f - its test fails before (`5 4 3 2 1 8`) and passes after; the non-database test sets (2286 tests) pass; eslint clean
---

# VALUE #( ) of a sorted table type is in insertion order

## What happens

```abap
TYPES: BEGIN OF ty, a TYPE i, END OF ty.
TYPES ty_sorted TYPE SORTED TABLE OF ty WITH NON-UNIQUE KEY a.

CLASS lcl DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS show IMPORTING it TYPE ty_sorted.
ENDCLASS.
CLASS lcl IMPLEMENTATION.
  METHOD show.
    LOOP AT it INTO DATA(r).
      WRITE / r-a.                                  " ABAP 1 2 3 4 5 - transpiled 5 4 3 2 1
    ENDLOOP.
    READ TABLE it WITH TABLE KEY a = 5 TRANSPORTING NO FIELDS.
    WRITE / sy-subrc.                               " ABAP 0 - transpiled 8
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  lcl=>show( VALUE ty_sorted( ( a = 5 ) ( a = 4 ) ( a = 3 ) ( a = 2 ) ( a = 1 ) ) ).
```

## Why

The transpiler builds a table constructor row by row:
`value_body_line.ts` emits `.appendThis( row )`, and `Table.appendThis`
(`packages/runtime/src/types/table.ts`) calls `append`, which pushes.

`lt = VALUE #( ... )` comes out sorted, because `Table.set` copies the rows
through `insertInternal` and sorts them. A VALUE that is never assigned stays
in insertion order. That happens when it is handed to an IMPORTING parameter,
looped over, or read from. Every binary search on such a table then works on
unsorted rows: READ TABLE with the table key, a secondary index, and the
sorted-primary narrowing proposed in
[`transpiler-loop-sorted-primary-key`](transpiler-loop-sorted-primary-key.md).

## The change

`appendThis` puts each row of a table with a SORTED primary key at its sorted
place, the way INSERT ... INTO TABLE does (`insertSorted` with `compareRows`
over the key fields). An already sorted VALUE still appends at the end, which
is `insertSorted`'s fast path. A duplicate of a unique key is kept, as it is
today. ABAP raises CX_SY_ITAB_DUPLICATE_KEY there, and that would be a change
of its own.

Written and tested; attached as
[`backlog/patches/transpiler-value-sorted-table.patch`](../patches/transpiler-value-sorted-table.patch)
(`git am` against 916d00f). The new test in `test/expressions/value.ts` fails
before (`5 4 3 2 1 8`) and passes after. The non-database test sets pass (2286
tests), and eslint is clean.

## How to file

1. Search the abaplint/transpiler tracker first and record the date in `checked_upstream:`.
2. Open a PR with the patch and this body.
3. Set `state: filed` and `filed: <url>` here, run `npm run backlog`, commit.
