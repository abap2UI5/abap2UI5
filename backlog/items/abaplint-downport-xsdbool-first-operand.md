---
target: abaplint
title: 'The 702 downport leaves xsdbool( ) alone when it is the first operand of + or &&'
summary: 'lv = xsdbool( a = 1 ) + xsdbool( a = 2 ). and s = xsdbool( a = 1 ) && `x`. come out unchanged at v702; as second operand, in an assignment, an IF or a template it is rewritten to boolc( )'
priority: medium
state: open
first_seen: 2026-11-27
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5, 2026-11-24, a local test class of z2ui5_cl_ui5_srv_model: xsdbool( ... ) + xsdbool( ... ) was left unparsed by the downport; the source was rewritten, written up in abap-check the same day'
  - 'probed 2026-11-27 against abaplint main after 2.120.122, rule downport, syntax v702: lv_cnt = xsdbool( lv_a = 1 ) + xsdbool( lv_a = 2 ). and lv_s = xsdbool( lv_a = 1 ) && `x`. are unchanged after --fix and then report a method parameter that does not exist; lv_s = `a` && xsdbool( lv_a = 1 ). is rewritten to boolc( )'
  - 'rules/downport.ts replaceXsdBool requires the Source that starts at the xsdbool token to have exactly four children; with an operator behind it the Source is longer and is skipped'
---

# The 702 downport: `xsdbool( )` as the first operand of an expression

```abap
lv_cnt = xsdbool( lv_a = 1 ) + xsdbool( lv_a = 2 ).
lv_s   = xsdbool( lv_a = 1 ) && `x`.
```

Both statements are unchanged after the downport, and 7.02 has no `xsdbool`.
With the operands swapped (`` `a` && xsdbool( ... ) ``) the function is
replaced by `boolc( )`.

## Proposal

Replace `xsdbool( ... )` wherever the call is a complete operand, not only
when it is the whole source.

## Must not change

The positions that work today (assignment, comparison in IF, string template,
actual parameter, nested xsdbool, second operand) and a method of the class
that is itself named `xsdbool`.
