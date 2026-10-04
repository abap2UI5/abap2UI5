---
target: abaplint
title: 'redundant_conversion: CONV of a built-in function that already returns the type'
summary: '`CONV string( to_upper( x ) )` is "Redundant conversion for type STRING" on a system; redundant_conversion reports `CONV syuname( sy-uname )` but not the CONV around a built-in function result'
priority: low
state: open
first_seen: 2026-10-04
upstream: abaplint/abaplint
evidence:
  - 2026-10-04, Code Inspector SYNTAX_CHECK on an S/4HANA 7.58 system - "Redundant conversion for type STRING" three times for `CONV string( to_upper( entity_name ) )` in z2ui5_cl_rap_variant (abap2UI5-addons/rap-ext) and once for `condense( CONV string( ls_order-name ) )` in z2ui5_cl_cgui_alv (abap-cloud-gui); fixed in abap2UI5-addons/rap-ext#19 and abap2UI5-addons/abap-cloud-gui#9
  - measured 2026-10-04 on abaplint 2.120.65 with redundant_conversion on over rap-ext - the three `CONV syuname( sy-uname )` of the same run are reported, the three `CONV string( to_upper( … ) )` are not
---

# redundant_conversion: the result of a built-in function

```abap
DATA(lv_entity) = CONV string( to_upper( entity_name ) ).   " to_upper( ) returns string already
DATA(lv_name) = condense( CONV string( ls_order-name ) ).   " condense( ) takes any character-like value
```

The rule compares the CONV target with the type of its operand. A built-in
function's result type (`string` for the string functions) seems not to be
part of that comparison, and the second shape is about the parameter the
CONV feeds, not the result. Both need a measurement of what exactly SLIN
reports before this is filed.
