---
target: abaplint
title: 'The 702 downport of VALUE #( itab[ ... ] DEFAULT x ) drops the table read and the default'
summary: 'VALUE string( itab[ 1 ] DEFAULT `OK` ) is lowered to CLEAR temp. target = temp. - no READ TABLE, no default; the output compiles, so the 702 gate is green and the value is silently initial'
priority: high
state: filed
filed: https://github.com/abaplint/abaplint/pull/4814
first_seen: 2026-11-27
checked_upstream: 2026-11-27
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/abap-agent-runtime, 2026-11-27: main has DATA(lv_choice) = VALUE string( is_action-t_choice[ 1 ] DEFAULT `OK` ). in z2ui5_cl_agent_session; the published 702 branch (ddf225a) holds CLEAR temp88. lv_choice = temp88. at that place - no READ TABLE and no OK, the 702 gate is green'
  - 'probed 2026-11-27 against abaplint main after 2.120.122, rule downport, syntax v702: s = VALUE #( it[ k = 1 ]-v DEFAULT `OK` ). becomes DATA temp1 TYPE string. CLEAR temp1. s = temp1.; n = VALUE #( it[ name = `B` ]-num DEFAULT 5 ) becomes DATA temp5 TYPE i. CLEAR temp5. n = temp5.'
  - 'rules/downport.ts handles only the addition OPTIONAL in this branch; DEFAULT falls through with an empty body, and no test in test/rules/downport*.ts mentions DEFAULT'
  - 'upstream search 2026-11-27 (open issues and pull requests of abaplint/abaplint): nothing on it; filed the same day as abaplint/abaplint#4814 - DEFAULT takes the OPTIONAL branch, with the default assigned in an ELSE'
---

# The 702 downport drops `VALUE #( itab[ ... ] DEFAULT x )`

```abap
DATA(lv_choice) = VALUE string( is_action-t_choice[ 1 ] DEFAULT `OK` ).
```

comes out of the downport (syntax v702) as

```abap
DATA temp1 TYPE string.
CLEAR temp1.
lv_choice = temp1.
```

The table is never read and the default is gone. The result compiles, so
nothing reports it - the target is initial where the source returns the row
or the default.

## Proposal

Lower it like the `OPTIONAL` form, with the default in the not-found branch:

```abap
READ TABLE is_action-t_choice INDEX 1 INTO temp1.
IF sy-subrc <> 0.
  temp1 = `OK`.
ENDIF.
```

with the component taken from the row when the expression has one
(`itab[ ... ]-comp DEFAULT x`).

## Must not change

`VALUE #( itab[ ... ] OPTIONAL )` (lowered correctly today), the bare
`VALUE t( itab[ 1 ] )` (raises, as the source does), and `REF #( ... OPTIONAL )`,
which is `abaplint-downport-ref-optional`.

## Workaround

`IF line_exists( ... )` around a plain table expression, or `OPTIONAL` plus an
`IS INITIAL` test where an initial row cannot be a real one.
