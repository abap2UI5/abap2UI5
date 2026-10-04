---
target: abaplint
title: 'check_syntax: DATA ... LIKE REF TO a generically typed table'
summary: '`DATA lr LIKE REF TO <tab>.` with `<tab> TYPE STANDARD TABLE` is refused on every release - "specified under LIKE either does not have a type or has a generic type"; abaplint reports the TYPE any operand but not a generic table'
priority: medium
state: filed
filed: https://github.com/abaplint/abaplint/pull/4363
first_seen: 2026-10-03
upstream: abaplint/abaplint
evidence:
  - abap2UI5#2786 - the downport lowers `bind( REF #( <tab> ) )` into `DATA temp LIKE REF TO <tab>.`, refused by 7.02-7.4x systems; abaplint's v702 check_syntax reported 0 issues on that output; earlier abap2UI5#161 for a generic parameter
  - gated in abap2UI5 since then by `downport-fix.mjs check-generic-like`
  - measured 2026-10-03 on abaplint main 506e7b9 - no finding at v702, v750 or v758; `LIKE REF TO val` with `val TYPE any` is reported
  - measured 2026-10-03 on a real system (S/4HANA, release 758, ADT) - `DATA lr LIKE REF TO <tab>.` with `<tab> TYPE STANDARD TABLE` is a syntax error there too
  - filed 2026-10-03 as abaplint/abaplint#4363 - DataReference.isGeneric( ) also counts a generic table; 6 tests, 0 new findings over abap2UI5, samples-controls and open-abap-core
---

# check_syntax: DATA ... LIKE REF TO a generic table

## What happens

```abap
FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
DATA lr LIKE REF TO <tab>.   " system: ... has a generic type
```

abaplint treats a reference as generic only when `TYPE any` is behind it, so a
reference to a generic table passes. In abap2UI5 the shape only exists in the
downport output, which is why the repository gate reads that output.

## How it is filed

abaplint/abaplint#4363 makes `DataReference.isGeneric( )` count a generic
table. `TYPE REF TO data` is not affected.
