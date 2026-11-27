---
target: abaplint
title: 'implement_methods: a REDEFINITION implemented under the superclass alias is reported as missing'
summary: 'METHODS zif~count REDEFINITION. implemented as METHOD count. (an alias of the superclass) activates with a SLIN warning; abaplint reports "Implement method zif~count" instead'
priority: medium
state: filed
filed: https://github.com/abaplint/abaplint/pull/4788
first_seen: 2026-11-24
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'oblomov-dev/s5s_dev 3173ec5: one activation of the S5S DEV state on an S/4HANA EWM system (2026-11-24): /KRO/UI502_CL_APP_002 redefines z2ui5_if_lp_kpi~count and implements it as METHOD count. (an ALIAS of its superclass) - the system activates it and warns "The component addressed here under the name COUNT is accessed in the current context under a different name"'
  - 'probed 2026-11-24 against abaplint 2.120.116, every rule on from `abaplint --default`, open-abap-core as dependency, an isolated syntax-clean project with a control finding firing: zcl_p13_base INTERFACES zif_p13_kpi + ALIASES count FOR zif_p13_kpi~count; zcl_p13_alias_name INHERITING FROM it, METHODS zif_p13_kpi~count REDEFINITION. and METHOD count. - implement_methods reports "Implement method "zif_p13_kpi~count""'
  - 'abap2UI5 9679656a, src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap ltcl_07_intf_attr->alias_and_intf_one_row: one method read `mo_app->mv_shared` (an ALIASES name) and `mo_app->lif_intf_alias~mv_shared` - the same attribute; an activation on a system (2026-11-25) gave the SLIN warning "The component addressed here under the name MO_APP->MV_SHARED is accessed in the current context under a different name" three times, abaplint (every rule on) reported nothing. Fixed by moving the alias spelling into a method of its own. A second shape of the same check: no abaplint rule notices one component named both by its alias and by its interface name in one procedure'
---

# implement_methods: a REDEFINITION implemented under the superclass alias is reported as missing

```abap
CLASS zcl_base DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_kpi.
    ALIASES count FOR zif_kpi~count.
ENDCLASS.

CLASS zcl_sub DEFINITION PUBLIC INHERITING FROM zcl_base FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS zif_kpi~count REDEFINITION.
ENDCLASS.

CLASS zcl_sub IMPLEMENTATION.
  METHOD count.          " system: activates, SLIN "... accessed under a different name"
    result = 2.          " abaplint: Implement method "zif_kpi~count"
  ENDMETHOD.
ENDCLASS.
```

The alias is inherited, so `METHOD count.` names `zif_kpi~count` and the
redefinition is implemented. `implement_methods` matches the implementation by
the interface-qualified name only and reports a missing implementation - an
error the code does not have, so the usual reaction is a pseudo comment over a
correct class. The real finding is the SLIN one: the method is implemented
under a name other than the one it was declared under.

**Proposal.** In `implement_methods`, resolve a `METHOD` name through the
aliases visible in the class (own and inherited) before deciding that an
implementation is missing. Report the alias use as its own, low finding
("implemented under the alias COUNT, declared as zif_kpi~count") - in
`implement_methods` behind an option, or in `no_aliases`.

**Not reported.** A method that is really not implemented; an alias that
does not exist (`check_syntax`, #3095).

**Where.** `implement_methods`. **Effort:** S.

**Source.** S5S (a consumer system), one activation on S/4HANA.

Related upstream: abaplint/abaplint#1410 (closed - false positive with ALL METHODS ABSTRACT + alias), #1561 (closed - implement method false positive), #4530 (closed - subclass alias vs. private superclass alias). None covers the implementation under an inherited alias.
