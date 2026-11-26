---
target: open-abap
title: 'transpiler 2.14.35: line_exists( <fs>[ ... ] ) on a field symbol of a table - "table.getRowType is not a function"'
summary: transpiler 2.14.35 (the one @abap2ui5/node-runtime 1.151.0 is built with) hands the field symbol itself instead of the table it points to into the table expression of line_exists( ), and the runtime fails with TypeError table.getRowType is not a function; 2.14.33 ran the same code; abap-cloud-gui works around it by reading through the typed data reference
priority: medium
state: open
first_seen: 2026-11-26
checked_upstream: 2026-11-26
upstream: abaplint/transpiler
evidence:
  - 'abap2UI5-addons/abap-cloud-gui, npm run unit on @abap2ui5/node-runtime 1.151.0 (transpiler 2.14.35), 2026-11-26: FAIL Z2UI5_CL_CGUI_REPORT ltcl_test->link_holds_values - TypeError: table.getRowType is not a function at convertKeyValues (@abaplint/runtime 2.14.35 build/src/statements/read_table.js:109) at tableExpression (operators/table_expression.js:12) at line_exists; the ABAP: FIELD-SYMBOLS <fields> TYPE z2ui5_cl_cgui_selscreen=>ty_t_field. ASSIGN ctx-fields->* TO <fields>. ... IF line_exists( <fields>[ name = lv_name ] ). - green with transpiler/runtime 2.14.33'
  - 'workaround abap-cloud-gui 40acefb: line_exists( ctx-fields->*[ name = lv_name ] ) - the same table through the typed reference; 242 test methods green. Other line_exists( <fs>[ ... ] ) in z2ui5_cl_cgui_report / _memory are not covered by a test and may hit it too'
---

# transpiler 2.14.35: `line_exists( <fs>[ ... ] )` on a field symbol of a table

## What happens

```abap
FIELD-SYMBOLS <fields> TYPE ty_t_field.
ASSIGN ctx-fields->* TO <fields>.          " ctx-fields TYPE REF TO ty_t_field
IF line_exists( <fields>[ name = lv_name ] ).
```

Transpiled with 2.14.35, the generated code passes the field symbol object to
`abap.operators.tableExpression(...)`. The runtime then calls
`table.getRowType()` on it and fails with
`TypeError: table.getRowType is not a function`. With 2.14.33 the same code ran.

## Expected

A field symbol pointing to an internal table is dereferenced before the table
expression, as for `LOOP AT <fields>` and `READ TABLE <fields>`.

## Reproduce

    cd abap-cloud-gui && git checkout 1ce3d6f
    npm ci && npm run unit     # on @abap2ui5/node-runtime 1.151.0
