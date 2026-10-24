---
target: open-abap
title: 'runtime: an absolute type name of a local class (`\CLASS-POOL=ZCL_X\CLASS=LCL`) is not found - describe_by_name( ) and CALL METHOD (name)=>(m) fail'
summary: 'a local class of a class pool is named from outside the pool by its absolute type name; cl_abap_typedescr=>describe_by_name( ) of open-abap-core raises on it (describe_by_dashes) and a dynamic static call by that name cannot be made - framework code that calls a static handler of a local class of a generated report class needs it'
priority: low
state: open
first_seen: 2026-10-24
upstream: abaplint/transpiler
evidence:
  - 'found 2026-10-24 in abap2UI5-addons/abap-cloud-gui (report2cloud) - the stand-in of the SAP GUI controls called a static event handler of a local class of a converted report by `\CLASS-POOL=Z2UI5_CL_CGUI_R2C_31\CLASS=LCL_COUNTER`: the transpiled runtime (@abap2ui5/node-runtime 1.148.0, @abaplint/runtime 2.14.5) answered HTTP 500 "Error at cl_abap_typedescr.describe_by_name ... at cl_abap_typedescr.describe_by_dashes"; the converter now passes an object of the local class instead (`handler = NEW lcl( )`) and uses the absolute name only for a class whose constructor takes parameters'
  - 'ABAP keyword documentation, absolute type names: `\CLASS-POOL=class\CLASS=local_class` names a local class of a class pool in RTTI and in dynamic specifications'
---

# runtime: absolute type names of local classes are not resolved

```abap
" in a global class that calls back into a local class of another one
DATA(lo_type) = cl_abap_typedescr=>describe_by_name( `\CLASS-POOL=ZCL_REPORT\CLASS=LCL_EVENTS` ).
CALL METHOD (`\CLASS-POOL=ZCL_REPORT\CLASS=LCL_EVENTS`)=>on_click.
" system:     the local class LCL_EVENTS of ZCL_REPORT
" transpiled: describe_by_name( ) raises (describe_by_dashes)
```

A local class is visible only inside its class pool. From outside, RTTI
and dynamic calls name it by its absolute type name. The transpiled
runtime registers local classes under a name of its own, and
`describe_by_name( )` of open-abap-core does not map the absolute form
onto it.

## The change

In open-abap-core `cl_abap_typedescr=>describe_by_name( )` (and the
dynamic class name lookup of `CALL METHOD`, `CREATE OBJECT ... TYPE
(name)`), parse `\CLASS-POOL=<pool>\CLASS=<local>` and look the class up
under the name the transpiler gives the local classes of `<pool>`.

## Example

```abap
DATA(lo_type) = CAST cl_abap_classdescr(
  cl_abap_typedescr=>describe_by_name( `\CLASS-POOL=ZCL_REPORT\CLASS=LCL_EVENTS` ) ).
cl_abap_unit_assert=>assert_equals( act = lo_type->get_relative_name( ) exp = `LCL_EVENTS` ).
```
