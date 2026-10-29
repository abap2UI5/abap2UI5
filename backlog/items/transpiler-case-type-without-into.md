---
target: open-abap
title: 'transpiler: `CASE TYPE OF` with a `WHEN TYPE` without `INTO` crashes the build - "Traverse, node undefined"'
summary: '`CaseTypeTranspiler` transpiles the `INTO` target of every `WHEN TYPE` unconditionally, and `INTO` is optional - a `WHEN TYPE zcl_x.` that only tests the type stops the whole transpile with "Traverse, node undefined, <file>", without a line'
priority: medium
state: open
first_seen: 2026-10-24
upstream: abaplint/transpiler
evidence:
  - 'found 2026-10-24 by the start measurement of report2cloud (abap2UI5-addons/abap-cloud-gui, `report2cloud:web --start`) - a converted report of the open-source web corpus loops over detector objects with `CASE TYPE OF csr. WHEN TYPE zcl_csr_sbcs. DATA(csr_sbcs) = CAST zcl_csr_sbcs( csr ). ...`; the build stops with "Error: Traverse, node undefined, z2ui5_cl_cgui_w0701.clas.abap" and the report is left out'
  - 'reduced 2026-10-24 with @abaplint/transpiler-cli 2.14.5 - a class whose method holds only `CASE TYPE OF o. WHEN TYPE zcl_tr_t. r = 1. ENDCASE.` stops the build with "Traverse, node undefined, zcl_tr_t.clas.abap"; abaplint reports no syntax error for it'
  - 'read 2026-10-24 in @abaplint/transpiler 2.14.5 `build/src/structures/case_type.js` - for each `WhenType` statement: `traversal.traverse(c.findDirectExpression(abaplint.Expressions.Target)).getCode() + ".set(" + u + ")"`, with no check that the `Target` (the optional `INTO`) is there'
  - 're-measured 2026-10-29 on abaplint/transpiler main ca16f9f (2.14.15) with the repository''s test harness - unchanged, the repro in the evidence above still fails the same way'
---

# transpiler: `CASE TYPE OF` without `INTO` crashes the build

## What happens

```abap
CASE TYPE OF o.
  WHEN TYPE zcl_shape.
    r = 1.
ENDCASE.
" system:     r = 1 when o is a zcl_shape
" transpiled: the build stops - "Traverse, node undefined, <file>"
```

`INTO` is optional in `WHEN TYPE`. Code that only branches on the type, or
casts later with `CAST`, leaves it out. The error names no line, so the
statement is hard to find in a large class.

## Why

`build/src/structures/case_type.js`, for each `WHEN TYPE`:

```js
ret.appendString(traversal.traverse(c.findDirectExpression(abaplint.Expressions.Target)).getCode() + ".set(" + u + ")\n");
```

`findDirectExpression(Target)` is `undefined` without `INTO`, and
`traverse(undefined)` throws.

## The change

Emit the assignment only when there is a target:

```js
const target = c.findDirectExpression(abaplint.Expressions.Target);
if (target) {
  ret.appendString(traversal.traverse(target).getCode() + ".set(" + u + ")\n");
}
```

## Example

```abap
DATA o TYPE REF TO object.
o = NEW zcl_shape( ).
CASE TYPE OF o.
  WHEN TYPE zcl_shape.
    DATA(hit) = abap_true.
ENDCASE.
cl_abap_unit_assert=>assert_true( hit ).
```
