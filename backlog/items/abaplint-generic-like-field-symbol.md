---
target: abaplint
title: 'check_syntax accepts FIELD-SYMBOLS <x> LIKE LINE OF <a generically typed table>'
summary: 'FIELD-SYMBOLS <row> LIKE LINE OF <tab> with <tab> TYPE STANDARD TABLE is an activation error on a real system, but abaplint check_syntax passes it (it does report the same shape for DATA) - so a downport that writes it (abaplint #4734) went unnoticed until the 702 branch was pulled'
priority: high
state: open
first_seen: 2026-11-26
checked_upstream: 2026-11-27
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5 #3056, 2026-11-26: pulling the 702 branch failed to activate z2ui5_cl_ui5_srv_model - the downport lowered table expressions on generically typed tables to READ TABLE ... ASSIGNING <temp447> with FIELD-SYMBOLS <temp447> LIKE LINE OF <tab> (14 declarations in the test include); the v702 check_syntax of the 702 gate passed all of them'
  - 'abaplint #4734 fixes the downport (the row of a generic table becomes TYPE any); the syntax check that would have caught it is still missing'
---

# check_syntax accepts `LIKE` on a generically typed field symbol

```abap
FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
FIELD-SYMBOLS <row> LIKE LINE OF <tab>.   " activation error - abaplint: no finding
DATA ls_row LIKE LINE OF <tab>.           " activation error - abaplint: "DATA definition cannot be generic"
```

A real system refuses both: *"`<TAB>` is a generic type. Use this type only
for typing field symbols and formal parameters."* abaplint 2.120.120
`check_syntax` reports the `DATA` line but not the `FIELD-SYMBOLS` line - at
v702 and at v750 alike (checked 2026-11-27 with the snippet above). So the
whole chain stayed green - downport, `check_syntax` at v702, CI - and the
error showed only when the 702 branch was pulled into a system (abap2UI5
#3056).

Two halves, two pull requests:

1. **The downport** must not write such a declaration - abaplint #4734
   (the row of a generic table becomes `TYPE any`).
2. **check_syntax** must reject `FIELD-SYMBOLS <x> LIKE`, `LIKE LINE OF`
   and `LIKE REF TO` on a generically typed field symbol or variable, the way
   it already rejects `DATA x LIKE ...` (`TYPE STANDARD TABLE`,
   `TYPE ANY TABLE`, `TYPE any`, `TYPE data` ...). This item. Without it the
   next downport rule that writes the same shape slips through again, and so
   does hand-written code.

## Proposal

Give `FIELD-SYMBOLS` with `LIKE [LINE OF | REF TO] <x>` the check `DATA`
already has ("DATA definition cannot be generic"): when the resulting type
is generic, report it. Test it at v702 and at v750 - the rule is not version-specific.

## Workaround

`node/setup/downport-fix.mjs check-generic-like` in abap2UI5 reads the
downport OUTPUT and rejects `DATA x LIKE <fs>` and (since #3056)
`FIELD-SYMBOLS <x> LIKE [REF TO | LINE OF] <fs>` on a generic `<fs>`. In
`src/`, assign the row first (`ASSIGN <tab>[ n ] TO FIELD-SYMBOL(<row>)`),
which the downport lowers without such a declaration.
