---
target: abaplint
title: 'check_syntax: `LOOP ... USING KEY <secondary> WHERE a = 1 OR b = 2` passes, a real system refuses it'
summary: a LOOP over a secondary key wants a WHERE the key can optimize - its key components compared with `=` and joined to the rest by AND; a top-level OR is a syntax error on a system, and abaplint reports nothing. A test written against abaplint alone shipped such a LOOP into abaplint/transpiler#1929 and drew "this gives a syntax error in a real system" twice
priority: medium
state: filed
filed: https://github.com/abaplint/abaplint/pull/4353
first_seen: 2026-10-02
upstream: abaplint/abaplint
evidence:
  - found 2026-09-30 in review of abaplint/transpiler#1929 - its test `LOOP AT t INTO r USING KEY k WHERE a = 1 OR b = 2.` (k a NON-UNIQUE SORTED secondary key over `a`) passed the transpiler's `check_syntax`, and the maintainer reported "this gives a syntax error in a real system", then "still error" after a merge from main left the test unchanged
  - measured 2026-10-01 on a real system (S/4HANA, ADT console) - with the key name dynamic, `USING KEY (name)` holding `'K'`, the same LOOP runs and loops every row matching either side; `USING KEY k WHERE a = 1 AND ( b = 2 OR b = 0 )` runs as well; `USING KEY k WHERE (cond)` with cond = `a = 1 OR b = 2` is a runtime error no `CATCH cx_root` catches
  - measured 2026-10-02 on abaplint 2.120.64, the latest release, `check_syntax` on, syntax version 7.58 - no finding for `USING KEY k WHERE a = 1 OR b = 2`; the control `USING KEY nokey WHERE a = 1` is reported ("Key nokey not found in table type"), so the check runs
  - `packages/core/src/abap/5_syntax/statements/loop.ts` (2.120.64) - the `USING KEY ... WHERE` block resolves the key and checks `IS INITIAL` before 7.40 SP02 (abap2xlsx#1341); nothing reads how the condition combines the key components
  - filed 2026-10-02 as abaplint/abaplint#4353 - a direct `OR` token of the WHERE's `ComponentCond` is reported once a statically named secondary key is found; an OR in parentheses, a dynamic key name, `primary_key` (after #4352) and no USING KEY stay unreported, one test each; all 11 198 tests of packages/core pass (32 pending), eslint clean
---

# check_syntax: `LOOP ... USING KEY <secondary> WHERE a = 1 OR b = 2`

## What happens

```abap
TYPES: BEGIN OF ty, a TYPE i, b TYPE i, END OF ty.
DATA t TYPE STANDARD TABLE OF ty WITH NON-UNIQUE KEY a b
       WITH NON-UNIQUE SORTED KEY k COMPONENTS a.
DATA r TYPE ty.

LOOP AT t INTO r USING KEY k WHERE a = 1 OR b = 2.             " syntax error on a system, abaplint: nothing
ENDLOOP.

LOOP AT t INTO r USING KEY k WHERE a = 1 AND ( b = 2 OR b = 0 ). " fine on both
ENDLOOP.
```

A LOOP over a secondary key reads the rows through that key, so its WHERE
has to be one the key can optimize: the key components compared with `=`,
joined to anything else by AND. An OR at the top of the condition leaves no
part every row must meet, and the system refuses the statement. abaplint
2.120.64 accepts it.

It is not academic. abaplint/transpiler#1929 shipped exactly this LOOP as a
unit test. Every check the transpiler runs passed, and only the maintainer's
real system caught it, twice.

## Why

`packages/core/src/abap/5_syntax/statements/loop.ts` has one check for a
`USING KEY ... WHERE`. It was added for abap2xlsx#1341: it resolves the key,
reports a key the table does not have, and reports `IS INITIAL` on a key
component before 7.40 SP02. How the condition combines the key components
is not read.

## What a rule must report, and what it must not

Report, for a **statically named secondary key** with a **static** WHERE:

- an `OR` at the top level of the condition (`a = 1 OR b = 2`) - measured on
  a system.

Do **not** report:

- an OR inside parentheses that AND joins to the key comparison
  (`a = 1 AND ( b = 2 OR b = 0 )`) - runs on a system;
- a dynamic key name, `USING KEY (name)` - the system decides at runtime,
  and with `a = 1 OR b = 2` it runs and loops every matching row;
- the primary key, `USING KEY primary_key` or no USING KEY at all - a WHERE
  over the primary key is not required to be optimizable;
- a dynamic WHERE, `WHERE (cond)` - a runtime error on a system when the
  condition cannot be optimized, which no syntax check can see.

Other shapes probably belong in the same rule: a WHERE that compares no key
component at all, a key component compared with something other than `=`.
They are left out until they are measured on a system. A rule that claims
more than was observed is the wish this stock does not file.

## How to file

The check sits in the statement's syntax, next to the abap2xlsx#1341 check,
so a PR is the realistic ask:

1. Search the abaplint tracker first and record the date in
   `checked_upstream:`.
2. Write the check and three tests: the top-level OR reported, the
   parenthesised OR and the dynamic key name not reported.
3. Set `state: filed` and `filed: <url>` here, run `npm run backlog`, commit.
