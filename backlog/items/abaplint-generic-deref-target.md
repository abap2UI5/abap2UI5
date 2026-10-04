---
target: abaplint
title: 'check_syntax: a generic REF TO data dereferenced as a target, below v756'
summary: '`CLEAR lr->*`, `IMPORTING ev = lr->*` and `lr->* = x` with `lr TYPE REF TO data` are refused below 7.56 like the source positions abaplint already reports; abaplint checks only sources'
priority: medium
state: filed
filed: https://github.com/abaplint/abaplint/pull/4364
first_seen: 2026-10-03
upstream: abaplint/abaplint
evidence:
  - abap2UI5#156, #1168, #1816, #1856, #1922 - "A generic reference cannot be dereferenced (->) in the current statement" on 7.50-7.52, among the refused shapes `CLEAR lr->*` and an IMPORTING actual
  - measured 2026-10-03 on abaplint main 506e7b9 at v750 - `CLEAR ir->*` and `give( IMPORTING ev = ir->* )` give no finding, seven source shapes of the same family are reported
  - measured 2026-10-03 on a real system (S/4HANA, release 758, ADT) - both are fine there, as the v756 boundary says
  - filed 2026-10-03 as abaplint/abaplint#4364 - Target runs the same condition as FieldChain; 7 tests, 0 new findings over abap2UI5, samples-controls and open-abap-core
---

# check_syntax: a generic reference dereferenced as a target

## What happens

```abap
METHODS run IMPORTING ir TYPE REF TO data.
CLEAR ir->*.                    " below 7.56: generic reference cannot be dereferenced
give( IMPORTING ev = ir->* ).   " the same
```

abaplint reports the source positions of this family below v756
(`abaplint-generic-deref-old-releases`, shape 1) but not the target positions.

## How it is filed

abaplint/abaplint#4364 runs the same release, language-version and open-abap
condition in `Target`. `ASSIGN lr->* TO <fs>` stays allowed.
