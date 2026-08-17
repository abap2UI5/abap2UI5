---
target: abaplint
title: 'Report a `sy-subrc` test used as the success check of an `ASSIGN`'
summary: on 7.40 SP7 a successful `ASSIGN` does not reset `sy-subrc`, so the test reads a value left by an earlier statement — `IS ASSIGNED` is the only correct check
priority: high
state: open
upstream: abaplint/abaplint
evidence:
  - abap2UI5 issue #1937 — every app on a 7.40 SP7 system ran into an endless loop; fixed by `41890d59` testing the field symbol instead
  - the `sy-subrc` there was still `4` from a `READ TABLE` in a branch that had not been taken
  - not reproducible under the transpiler, which is more forgiving about `sy-subrc` than the release range abap2UI5 ships to — so no test in that repository can guard it
---

# Report a `sy-subrc` test used as the success check of an `ASSIGN`

## What happens

```abap
ASSIGN (lv_name) TO <attri>.
IF sy-subrc = 0.
  " ... use <attri>
ENDIF.
```

On a 7.40 SP7 system this reads a `sy-subrc` that the `ASSIGN` never wrote. In
abap2UI5's case the value was still `4` from a `READ TABLE` in an earlier branch
that had not been taken, so `attri_get_val_ref` treated an unassigned field
symbol as assigned and every app on that system went into an endless loop
(#1937). The correct check has no such gap:

```abap
IF <attri> IS NOT ASSIGNED.
```

The failure is release-dependent and silent everywhere else, which is the worst
combination: it passes every check the author can run, ships, and then breaks
for one customer.

## Why no existing rule catches it

`check_subrc` is the closest, and it is the mirror image of this. It reports
statements whose `sy-subrc` is **not** checked, and its extended information
already records that "If IS ASSIGNED is checked after assigning, it is
considered okay" — i.e. it accepts either check after an `ASSIGN` and prefers
neither. Nothing reports the check that is actually wrong.

## Proposed rule

Report a `sy-subrc` comparison whose nearest preceding `sy-subrc`-setting
statement is an `ASSIGN`, and suggest `IS [NOT] ASSIGNED` on the assigned field
symbol.

Both halves are statically decidable within a statement block: the set of
statements that set `sy-subrc` is fixed and abaplint already models it for
`check_subrc`, and the field symbol to name in the message is the `ASSIGN`
target.

## What it must NOT report

- An `ASSIGN` whose `sy-subrc` is read for a reason other than the assign
  succeeding — there is no such use, but a `sy-subrc` set by an intervening
  statement must end the association, or the rule fires across unrelated code.
- `ASSIGN COMPONENT … OF STRUCTURE`, where `sy-subrc` distinguishes "component
  not found" from "assigned" and is the documented check. This is the scoping
  question the rule has to get right; the plain dynamic `ASSIGN (name)` form is
  the one with no alternative.

## Suggested severity

A warning rather than an error. The code is correct on current releases, and a
project that has dropped 7.40 support can turn it off knowingly — which is the
distinction between this and a defect that is wrong everywhere.
