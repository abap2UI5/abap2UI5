---
target: abaplint
title: 'Report / between integers where a whole-number quotient is meant (the ceiling idiom needs DIV)'
summary: '( total + size - 1 ) / size with all operands TYPE i rounds commercially - 4 rows of page size 2 gave 3 pages; DIV was meant, nothing reports it'
priority: low
state: open
first_seen: 2026-11-27
upstream: abaplint/abaplint
evidence:
  - 'abap-util/abap-util 3235c85, 2026-11 ("itab_paginate rounded the page count instead of dividing (4 rows, size 2: 3)"): total_pages = COND #( WHEN page_size <= 0 THEN 1 ELSE ( total_count + page_size - 1 ) / page_size ). with every operand TYPE i, fixed to DIV; found by review and a unit test'
  - 'probed 2026-11-27 against abaplint main, v750, every default rule on: no finding for the statement; no rule mentions DIV except test data of inline_packed_computation'
---

# `/` between integers rounds

```abap
total_pages = ( total_count + page_size - 1 ) / page_size.   " all TYPE i
```

`/` with integer operands and an integer target rounds the quotient
commercially. The line is the integer ceiling as written in other languages,
where `/` truncates - in ABAP it needs `DIV`.

## Proposal

Report `/` when every operand and the target are integers and the shape
shows that a whole-number quotient is meant: the dividend is `x + y - 1` with
the divisor `y`, or the division is the direct argument of `ceil( )`,
`floor( )` or `trunc( )`. An option may widen it to every all-integer `/`.
Quick fix: `DIV`.

## Must not report

An expression with a p, f or decfloat operand or target. By default, a plain
`a * 100 / b` - the rounding is usually what a percentage wants.
