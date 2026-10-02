---
target: abaplint
title: 'check_syntax: a text symbol passed to a method parameter typed STRING is not type-compatible'
summary: a text symbol like `'Hallo'(001)` passed to a method parameter typed `string` is not type-compatible on a system - it is a character literal of type C and does not convert the way a plain literal does; abaplint treats it as a constant and reports nothing
priority: high
state: filed
filed: https://github.com/abaplint/abaplint/pull/4358
first_seen: 2026-10-02
upstream: abaplint/abaplint
evidence:
  - abap2UI5/samples, 2026-09-16 - app 519 (`z2ui5_cl_smp_app_519`, the sample about translatable texts) passed `'...'(001)` to the view builder's `v TYPE string`; a system's SYNTAX_CHECK refused the whole class while abaplint, the transpiler and the unit run were green (abap-check, "A text symbol is a CHARACTER literal")
  - gated in abap2UI5 since then by `npm run check:atc` (`text_symbol_arg`, `.github/scripts/extended-check-gate.mjs`) - a repository-local regex
  - measured 2026-10-02 on a real system (S/4HANA, ADT syntax check) - `m( v = 'Hallo'(001) )` and `m( 'Hallo'(001) )` are both `"'Ha'(001)" is not type-compatible with formal parameter "V"`; `m( v = 'Hallo' )` and `CONV string( 'Hallo'(001) )` are fine
  - measured 2026-10-02 on abaplint main 91efb82, `check_syntax` on, v750 and v757 - no finding for either call, while the control (an unknown variable) is reported
  - filed 2026-10-02 as abaplint/abaplint#4358 - reported for importing method parameters typed STRING, named and positional; a plain literal, a parameter typed C, an assignment, a string template and CONV string( ) stay unreported, one test each; PERFORM USING and CREATE OBJECT EXPORTING are left out as not measured; all 11 205 tests of packages/core pass (32 pending), eslint clean
---

# check_syntax: a text symbol passed to a STRING method parameter

## What happens

```abap
CLASS-METHODS m IMPORTING v TYPE string.
...
m( v = 'Hallo'(001) ).   " system: "'Ha'(001)" is not type-compatible with formal parameter "V".
m( 'Hallo'(001) ).       " the same
m( v = 'Hallo' ).        " fine - a plain literal converts
```

A text symbol is a character literal of type `C`. Unlike a plain literal it
does not convert when it is bound to a `STRING` parameter, and the system
refuses the whole class. `check_syntax` treats it as a constant, which does
convert, and reports nothing.

## The remedy

Read the text into a variable and pass that, or wrap it in
`CONV string( 'Hallo'(001) )`. A plain assignment `lv = 'Hallo'(001).` is a
conversion and always allowed, and a symbol inside a string template needs
nothing.

## What it must NOT report

- a plain literal `m( v = 'Hallo' )`
- a parameter typed `C`
- an assignment, a string template, `CONV string( )`

## How it is filed

abaplint/abaplint#4358 checks it where a method call binds an importing
parameter, named and positional, and leaves `PERFORM ... USING` and
`CREATE OBJECT ... EXPORTING` out until they are measured.
