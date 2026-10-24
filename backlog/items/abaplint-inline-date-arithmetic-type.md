---
target: abaplint
title: 'check_syntax: `DATA(x) = date1 - date2` is typed as d - the type of an inline arithmetic expression is its calculation type, a number'
summary: 'an inline declaration takes the calculation type of an arithmetic expression; for date operands that is a number - abaplint types `DATA(x) = d - d` and `d + d` as d (and `d + i` as i), so the transpiled runtime writes the number of days as a date and an offset access on x looks valid'
priority: medium
state: open
first_seen: 2026-10-24
upstream: abaplint/abaplint
evidence:
  - 'found 2026-10-24 writing a corpus report of abap2UI5-addons/abap-cloud-gui (report2cloud) - `DATA(lv_between) = p_end - p_start.` (both TYPE d, 74 days apart), then `WRITE lv_between`: the transpiled runtime (@abaplint/transpiler 2.14.5, which takes the type from abaplint) printed `03/16/1`, a date, instead of 74'
  - 'probed 2026-10-24 with @abaplint/core 2.120.75 (SyntaxLogic, the variables of the method scope) - `DATA(lv_between) = lv_end - lv_start.` is DateType, `DATA(lv_sum) = lv_start + lv_end.` is DateType, `DATA(lv_later) = lv_start + 31.` is IntegerType; the transpiled code declares `new abap.types.Date(...)` for the first two'
  - 'ABAP keyword documentation, DATA - inline declaration: for an arithmetic expression the data type is the calculation type; date and time operands are numbers in arithmetic expressions'
---

# check_syntax: the inline type of date arithmetic is d

```abap
DATA lv_start TYPE d VALUE '20260105'.
DATA lv_end   TYPE d VALUE '20260320'.

DATA(lv_between) = lv_end - lv_start.
" system:   lv_between is a number - 74
" abaplint: DateType; the transpiled runtime writes 03/16/1
```

An inline declaration with an arithmetic expression on the right takes
the calculation type of the expression. Date and time operands count as
numbers there, so the result is never of type `d`: the difference of two
dates is a number of days. abaplint types the difference (and the sum) of
two dates as `DateType` and a date plus an integer as `IntegerType` - the
two answers cannot both follow the same rule.

Code that relies on the abaplint type goes wrong twice: the transpiler
declares a date and shows the number of days as one, and an offset access
on the result (`lv_x+6(2)`) passes check_syntax although a system refuses
it (`abaplint-syntax-offset-on-numeric`).

**Proposal.** Type the inline declaration of an arithmetic expression with
its calculation type, with date and time operands taken as numbers.

**Not reported.** This is a typing fix, not a rule: `DATA lv_x TYPE d.
lv_x = lv_start + 31.` stays a date.

**Where.** the inline declaration in the syntax check (the type of an
arithmetic `Source`). **Effort:** S.

**Source.** ABAP keyword documentation (DATA, inline declaration; calculation type).
