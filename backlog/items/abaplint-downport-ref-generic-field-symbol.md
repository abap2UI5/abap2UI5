---
target: abaplint
title: 'downport: REF TO data for the reference to a generically typed field symbol'
summary: '`bind( REF #( <tab> ) )` with `<tab> TYPE STANDARD TABLE` is downported to `DATA temp1 LIKE REF TO <tab>.`, which a 7.02-7.4x system refuses and which check_syntax itself reports since abaplint/abaplint#4363 - the downport produces code its own check refuses'
priority: medium
state: filed
filed: https://github.com/abaplint/abaplint/pull/4405
first_seen: 2026-09-23
upstream: abaplint/abaplint
evidence:
  - abap2UI5, 2026-09-23 - two test classes (`z2ui5_cl_ui5_srv_bind`, `z2ui5_cl_ui5_srv_model`) passed `REF #( <tab> )` of a generic field symbol; the 702 branch did not activate ("The field "<TAB>" specified under LIKE either does not have a type or has a generic type"), and abap2UI5 has run `downport-fix.mjs check-generic-like` over the downport output since
  - reproduced 2026-10-09 on abaplint main 8db4281 (2.120.71), v702, `downport` and `check_syntax` on - the output is `DATA temp1 LIKE REF TO <tab>.` and check_syntax answers "DATA definition cannot be generic, temp1"
  - filed 2026-10-09 as abaplint/abaplint#4405 - `TYPE REF TO data` when the source of GET REFERENCE is a generically typed variable, field symbol or parameter; abap2UI5's whole downport is byte-identical to 2.120.71 with it
---

# downport: REF TO data for the reference to a generically typed field symbol

```abap
FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
bind( REF #( <tab> ) ).
```

was downported to `DATA temp1 LIKE REF TO <tab>.` plus `GET REFERENCE OF
<tab> INTO temp1`. With abaplint/abaplint#4405 the declaration is
`DATA temp1 TYPE REF TO data.` - a reference to a generic operand is a
`REF TO data` anyway. Once it ships, `check-generic-like` in
`node/setup/downport-fix.mjs` guards a shape the downport no longer writes.
