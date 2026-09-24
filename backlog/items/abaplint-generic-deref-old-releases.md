---
target: abaplint
title: 'Version-gate two generic-type constructs the kernel only accepts on newer releases'
summary: 'dereferencing a generic `REF TO data` inline (`lr->*` in an expression, `ASSIGN COMPONENT … OF STRUCTURE mr->*`), the dynamic component selector on a `TYPE any` operand (`val->(name)`) and `CORRESPONDING #( <generic> )` all activate here and fail on 7.50/7.52 systems — bitten three times, twice by users after a pull; abaplint already reports the first below v756 (`check_syntax`), and accepts the other two at every `syntax.version`'
priority: high
state: open
first_seen: 2026-09-19
upstream: abaplint/abaplint
evidence:
  - abap2UI5 issue #1922 — on SAP_ABA 750 SP22, `lr_ref->*` in an expression and `ASSIGN COMPONENT … OF STRUCTURE mr_data->*` fail with "A generic reference cannot be dereferenced (->) in the current statement"; fixed in `a16e2465` (#1923). The same shape had been reported before on another low release, #1856, fixed in `75bf5515` (#1857)
  - abap2UI5 issue #2409 — `ASSIGN val->(lv_name) TO …` where `val` is `TYPE any` is "VAL is not a reference variable" on NW 7.52 and 7.02; the remedy is a cast into a typed reference first
  - `CORRESPONDING #( <generic> )` fails on the same releases and went with `a16e2465`; abaplint's `prefer_corresponding` had to be switched OFF in the low-release config because it recommends the construct that does not compile there
  - re-measured 2026-09-23 on 2.120.52 and 2.120.59, `check_syntax` on, isolated class with a control probe - shape 1 (`lines( lr->* )`, `ASSIGN COMPONENT … OF STRUCTURE mr_data->*`) IS reported, "A generic reference cannot be dereferenced", at v702 through v755 and not from v756 on; shape 2 (`ASSIGN val->(lv_name)`, `val TYPE any`) and shape 3 (`CORRESPONDING #( <generic> )`) give no finding at v750, v752 or v755; `ASSIGN lr->* TO <fs>` stays clean. The first version of this item said all three were accepted everywhere, which was already false on 2.120.52
  - abap-check §2 ("Generic types on older releases — the recurring one") carries all three as prose, and calls the family "the single most likely thing to break a system that is not on the newest release"
---

# Version-gate two generic-type constructs the kernel only accepts on newer releases

## What happens

Three shapes, one cause: the kernel's rules for **generic** operands (a
`REF TO data`, a `TYPE any` field symbol or parameter) were relaxed over
several releases. abaplint models the older rule for the first shape
(`check_syntax` reports it below v756) and the newest behaviour for the other
two at every `syntax.version`. This item asks for shapes 2 and 3; shape 1 is
kept in the text because it is the same family and the version gate that
already exists for it is the model for the other two.

```abap
" 1. inline dereference of a generic reference - 750 SP22: syntax error
lv = lr_generic->*.
ASSIGN COMPONENT lv_name OF STRUCTURE mr_data->* TO <comp>.

" 2. dynamic component selector on a TYPE any operand - 7.52 / 7.02
ASSIGN val->(lv_name) TO <attr>.           " val TYPE any: "not a reference variable"

" 3. CORRESPONDING on a generic operand - same releases
ls_target = CORRESPONDING #( <generic> ).
```

Each activates on the developer's system and on the transpiler, ships, and
fails on the first customer system that is a few support packages behind. Two
of the three reached abap2UI5's main branch twice.

The remedies are all local rewrites:

```abap
ASSIGN lr_generic->* TO FIELD-SYMBOL(<val>).        " 1: bind first, then use <val>
DATA(lx) = CAST cx_root( val ).  ASSIGN lx->(lv_name) TO <attr>.   " 2: typed reference first
CLEAR ls_target. MOVE-CORRESPONDING <generic> TO ls_target.        " 3
```

## Why no existing rule catches it

`downport` rewrites constructs that do not exist at all below a version
(inline declarations, string templates, `NEW`), not constructs that exist but
refuse a **generic** operand. `fully_type_itabs` and `cloud_types` are about
declarations.

`check_syntax` does have the condition for shape 1: "A generic reference
cannot be dereferenced" is reported when the release is below v756 and the
language is not Cloud (measured 2026-09-23, identical on 2.120.52 and
2.120.59). So abap2UI5's v750 and v702 configs already catch that one. It has
no such condition for shapes 2 and 3, which it resolves as valid at every
version — which, on the newest kernel, they are.

## Proposed rule

Give shapes 2 and 3 the same kind of version condition shape 1 already has,
so `check_syntax` (or `downport`) reports, under a `syntax.version` below the
release that accepts it:

1. ~~`->*` on a generic reference~~ — already reported below v756, nothing to
   ask for;
2. the dynamic component selector `x->(name)` where `x` is not statically a
   reference variable (a `TYPE any` field symbol, parameter or attribute);
3. `CORRESPONDING #( x )` / `CORRESPONDING ty( x )` where `x` is generic.

The exact release per shape is to be confirmed on systems; the reports above
give upper bounds (7.52 for 2). Even a conservative gate ("report below
v754") would have caught both incidents; shape 1's existing gate (below
v756) is the natural default.

## What it must NOT report

- the same operators on concretely typed operands;
- anything under a `syntax.version` that accepts it, or with `syntax.version`
  unset.

## Example

```abap
" bad (at syntax.version v750)
ASSIGN val->(lv_name) TO FIELD-SYMBOL(<attr>).    " val TYPE any

" good
DATA(lx) = CAST cx_root( val ).
ASSIGN lx->(lv_name) TO FIELD-SYMBOL(<attr>).
```
