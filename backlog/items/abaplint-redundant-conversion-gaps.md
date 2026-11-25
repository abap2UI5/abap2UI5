---
target: abaplint
title: 'redundant_conversion: three shapes the extended check reports and the rule does not'
summary: 'DATA(x) = CONV string( lr->comp ) with a string component, CONV #( xsdbool( ... ) ) for a string formal and CONV #( lr->comp ) for a clike formal - SLIN "Redundant conversion", redundant_conversion silent on all three'
priority: low
state: open
first_seen: 2026-11-24
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5/abap2UI5 1f85280c: a user''s pull (2026-11-24) warned "Redundant conversion for type STRING" on z2ui5_cl_ui5_http_handler->_bootstrap_attributes, `DATA(lv_name) = CONV string( lr_config->n ).` in a LOOP ... REFERENCE INTO, n TYPE string'
  - 'abap2UI5-addons/layout-management 5b1c8b7: the same pull warned on z2ui5_cl_layo_xml_builder->xml_build_table, `->a( n = `growing` v = CONV #( xsdbool( i_growingthreshold <> space ) ) )` with v TYPE string'
  - 'abap2UI5-addons/table-maintenance 3751aca: the same day''s pull warned "Redundant conversion for type ROLLNAME" on z2ui5_cl_tm_pop->get_fixval, `rtti_get_t_ddic_fixed_values( CONV #( dfies->rollname ) )` with the formal `rollname TYPE clike` - CONV # takes the operand''s own type for a generic formal'
  - 'probed 2026-11-24 against abaplint 2.120.113, redundant_conversion on, an isolated syntax-clean class: `take_clike( CONV #( df->roll ) )` - no finding; reported are `DATA(x) = CONV string( lv_string )`, `lv_s = CONV string( lv_s )` and `lv_tgt = CONV string( lr->n )` (typed target); NOT reported are `DATA(x) = CONV string( lr->n )`, `DATA(x) = CONV string( <fs>-n )` and `take_str( CONV #( xsdbool( a > 0 ) ) )`'
  - 'oblomov-dev/s5s_dev 3173ec5: one activation of the S5S DEV state on an S/4HANA EWM system (2026-11-24) warned "Redundant conversion" at 57 sites - S5S had redundant_conversion off, and most sites are shapes the rule reports when on; two are not: take_clike( CONV #( ''SIMPLE_VIEW'' ) ) (a literal into a generic formal) and take_str( CONV string( lr->n ) ) (a component through a reference as an actual parameter)'
  - 'probed 2026-11-24 against abaplint 2.120.116, every rule on from `abaplint --default`, open-abap-core as dependency, an isolated syntax-clean project with a control finding firing: CONV #( ''SIMPLE_VIEW'' ) into val TYPE clike and take_str( v = CONV string( lr_nv->name ) ) inside LOOP ... REFERENCE INTO - no finding; lv_str = CONV string( lr_nv->name ) on the next line IS reported, and so are take_str( v = CONV string( ls_nv-name ) ) and take_str( v = CONV string( lv_msg ) )'
---

# redundant_conversion: three shapes the extended check reports and the rule does not

```abap
LOOP AT it REFERENCE INTO DATA(lr).            " it: TABLE OF ty_nv, n TYPE string
  DATA(lv_name) = CONV string( lr->n ).        " SLIN: Redundant conversion for type STRING
ENDLOOP.

take_str( CONV #( xsdbool( amount > 0 ) ) ).   " take_str IMPORTING v TYPE string
                                               " SLIN: Redundant conversion for type STRING

take_clike( CONV #( df->roll ) ).              " take_clike IMPORTING val TYPE clike
                                               " SLIN: Redundant conversion for type ROLLNAME
```

`redundant_conversion` reports `DATA(x) = CONV string( lv_string )` and
`lv_tgt = CONV string( lr->n )` into a typed target. It is silent when the
target is an **inline declaration and the operand a component** - reached
through a data reference (`lr->n`) or a field symbol (`<fs>-n`) - and for a
`CONV #( )` whose inferred target is the type of the formal parameter it is
passed to, around a built-in function. And for `CONV #( x )` passed to a
**generic** formal (`clike`, `csequence`, `any`): `#` then resolves to the
operand's own type, so the CONV converts nothing.

**Proposal.** Three extensions of the rule:

1. for an inline declaration `DATA(x) = CONV t( operand )`, resolve the
   operand's type through `->` and `-` component selectors, as the rule
   already does when the target is declared;
2. report `CONV #( <functional call or built-in function> )` as an actual
   parameter, when `#` resolves to the formal's own type and the formal is
   passed by value or the operand is an expression (the kernel creates the
   temporary anyway);
3. report `CONV #( operand )` as the actual of a generic formal - `#` takes
   the operand's type, the result is the operand.

Two more shapes, measured on 2.120.116 (S5S, a consumer system,
2026-11-24):

```abap
take_clike( CONV #( 'SIMPLE_VIEW' ) ).        " a literal into a generic formal - # is the literal's type
LOOP AT lt_nv REFERENCE INTO DATA(lr_nv).
  take_str( v = CONV string( lr_nv->name ) ). " not reported - name TYPE string
  lv_str = CONV string( lr_nv->name ).        " reported
ENDLOOP.
```

The first is extension 3 with a literal operand. The second is extension 1 for
an actual parameter instead of an inline declaration: the rule resolves
`ls_nv-name` there, and `lr_nv->name` into a typed variable, but not
`lr_nv->name` as the actual of a `string` formal.

**Not reported.** A CONV whose operand is generic (`clike`, `any`) - there the
CONV fixes the type; a CONV whose target differs from the operand's type in
length; a CONV in a comparison or arithmetic expression.

**Where.** `redundant_conversion`. **Effort:** M.

**Source.** abap2UI5 and layout-management, a user's pull on S/4HANA.
