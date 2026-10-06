---
target: abaplint
title: 'Report an inline declaration whose type would come from a packed computation'
summary: '`DATA(x) = a - b` with packed operands gets the implicit type P(8,0) - a syntax-check warning on a system, and decimals of the operands are lost; abaplint infers the type of the first operand and reports nothing'
priority: medium
state: open
first_seen: 2026-10-04
upstream: abaplint/abaplint
evidence:
  - abap2UI5/samples-controls, 2026-10-04 - Code Inspector SYNTAX_CHECK on S/4HANA 7.58, `z2ui5_cl_smpc_demo_002->row_json` line 9 - "For the result of a computation with type P, the type P(8,0) is used here implicitly because it is not possible to determine ..." for `DATA(margin) = order-requireddate - order-shippeddate.` (both `p LENGTH 8 DECIMALS 0`); fixed in abap2UI5/samples-controls#251
  - measured 2026-10-04 with an abaplint-based probe over abap2UI5, samples-controls and samples-stack - inline declarations whose source is a packed computation, one instance (the above); a `COND #( … ELSE packed * 1000 )` in app 377 takes its type from the THEN operand and is a different case
  - abap2UI5-addons/admin-cockpit, 2026-10-06 - a user's pull, `z2ui5_cl_cockpit_stats->p95` line 20 - the same warning for `DATA(lv_target) = lv_total * 95 / 100.` with `lv_total TYPE p LENGTH 16 DECIMALS 0`, so `*` and `/` are covered and a P(16,0) operand still gives P(8,0); abaplint 2.120.70 reports nothing
  - abaplint main 506e7b9 infers `p LENGTH 8 DECIMALS 0` for the inline variable (the first operand's type) and reports nothing
---

# Report an inline declaration whose type would come from a packed computation

## What happens

```abap
TYPES ty_ms TYPE p LENGTH 8 DECIMALS 0.
DATA a TYPE ty_ms.
DATA b TYPE ty_ms.
DATA(margin) = a - b.   " warning: the type P(8,0) is used here implicitly
```

The calculation type of an arithmetic expression with packed operands has no
length and decimals that a declaration could inherit, so the inline
declaration falls back to P(8,0) and the syntax check warns. With operands that
carry decimals, the fallback cuts them off silently.

## Proposed rule

Report `DATA(x) = <arithmetic expression>` when the calculation type is P
(packed operands and no `decfloat`/`f` operand that would change it). Quick
fix: none that does not pick a type. The message names the remedy, which is to
declare `x` with the operands' type.

## What it must NOT report

- `DATA(x) = packed_field.`: a plain copy takes the field's type.
- `DATA(x) = COND #( WHEN … THEN packed_field ELSE packed_field * 2 )`: the type comes from the THEN operand.
- `DATA(x) = int1 - int2.`: calculation type I.
- `DATA(x) = CONV ty_ms( a - b ).`: the type is named.

To confirm on a system before it is filed: whether a packed operand with decimals (`p LENGTH 8 DECIMALS 3`) gets
P(8,0) or something else.
