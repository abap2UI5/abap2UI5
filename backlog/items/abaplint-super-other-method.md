---
target: abaplint
title: 'check_syntax: super-> calling a method other than the one it stands in'
summary: '`super->get_where_clause( )` inside a redefined `load_data` is "SUPER-> can only be used to call the previous implementation of the same method" on a system; abaplint accepts it'
priority: high
state: open
first_seen: 2026-10-04
upstream: abaplint/abaplint
evidence:
  - 2026-10-04, Code Inspector SYNTAX_CHECK on an S/4HANA 7.58 system - z2ui5_cl_rap_worklist->load_data (abap2UI5-addons/rap-ext), "SUPER-> can only be used to call the previous implementation of the same method (for example SUPER->)."; fixed in abap2UI5-addons/rap-ext#19 with a second, non-redefined method in the superclass
  - measured 2026-10-04 on abaplint main 506e7b9 (v758, check_syntax) - `super->m2( )` inside the redefinition of m1 gives no finding
---

# check_syntax: super-> calling another method

```abap
METHOD load_data.          " a redefinition
  super->load_data( ).     " fine
  DATA(lv) = super->get_where_clause( ).   " system: SUPER-> can only be used to call the previous implementation of the same method
ENDMETHOD.
```

Proposed: where `MethodCallChain` resolves `super->name( )`, report it when
`name` is not the method whose implementation contains the call. The
constructor's `super->constructor( )` is the same rule, and is correct
there.
