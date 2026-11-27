---
target: abaplint
title: 'The 702 downport writes CREATE OBJECT for NEW of a data type (structure, table, inline target, operand position)'
summary: 'DATA(lr) = NEW ty_t( ). becomes CREATE OBJECT temp1 TYPE ty_t., and NEW ty_t( ( `a` ) ( `b` ) ) becomes a statement that does not parse - only target = NEW #( one value ) is lowered to CREATE DATA'
priority: high
state: open
first_seen: 2026-11-27
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5 main, src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap (1dc0803): the test writes CREATE DATA by hand, with the comment that the downport writes the NEW of a type of a local interface as CREATE OBJECT ... TYPE lif_intf_attr; written up in abap-check on 2026-11-24'
  - 'probed 2026-11-27 against abaplint main after 2.120.122, rule downport, syntax v702: DATA(lr) = NEW tt( ). becomes DATA temp1 TYPE REF TO tt. CREATE OBJECT temp1 TYPE tt.; lrs = NEW ty_s( a = 1 ). becomes CREATE OBJECT lrs TYPE ty_s EXPORTING a = 1.; lr = NEW ty_t( ( `a` ) ( `b` ) ). becomes CREATE OBJECT lr TYPE ty_t ClassDefinitionNotFound ERROR., which does not parse; DATA(lr3) = NEW zcl_p=>ty_t( ). becomes CREATE OBJECT temp1 TYPE zcl_p.'
  - 'rules/downport.ts newDataReference handles target = NEW type|#( [one value] ) with a declared target only (abaplint/abaplint#4404, 2.120.72); every other position falls through to the CREATE OBJECT path'
---

# The 702 downport: `NEW` of a data type becomes `CREATE OBJECT`

```abap
DATA(lr_tab) = NEW ty_t( ).
lr_str = NEW ty_s( a = 1 ).
lr_tab = NEW ty_t( ( `a` ) ( `b` ) ).
```

All three create a data object. The downport treats them as an instantiation:

```abap
CREATE OBJECT temp1 TYPE ty_t.
CREATE OBJECT lr_str TYPE ty_s EXPORTING a = 1.
CREATE OBJECT lr_tab TYPE ty_t ClassDefinitionNotFound ERROR.
```

The first two do not activate, the third does not parse - and a statement
that does not parse stops the downport for the rest of the file.

## Proposal

When the type after `NEW` (or the inferred type of `#`) is not a class,
write `CREATE DATA ref TYPE <type>.` and assign the content through `->*` as
`VALUE <type>( ... )`, so the existing VALUE lowering takes it from there.

## Must not change

`NEW` of a class, or of a type that resolves to an object reference; the form
that works today, `lr = NEW #( `x` )` with a declared target.
