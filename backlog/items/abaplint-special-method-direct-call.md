---
target: abaplint
title: 'check_syntax: SETUP / TEARDOWN called directly'
summary: '`teardown( )` called from `setup( )` in a test class is "The special method TEARDOWN cannot be called directly." on a system; abaplint and the transpiler accept it'
priority: high
state: open
first_seen: 2026-10-04
upstream: abaplint/abaplint
evidence:
  - 2026-10-04, Code Inspector SYNTAX_CHECK on an S/4HANA 7.58 system - z2ui5_cl_cgui_layout_db and z2ui5_cl_cgui_variant_db test classes (abap2UI5-addons/abap-cloud-gui), "The special method "TEARDOWN" cannot be called directly." for `teardown( ).` inside `setup( )`; fixed in abap2UI5-addons/abap-cloud-gui#9
  - measured 2026-10-04 on abaplint main 506e7b9 (v758, check_syntax) - no finding for `teardown( )` in setup nor for `setup( )` in a test method
---

# check_syntax: SETUP / TEARDOWN called directly

```abap
METHOD setup.
  teardown( ).     " system: The special method "TEARDOWN" cannot be called directly.
ENDMETHOD.
```

The test fixture methods of a test class are called by the ABAP Unit runtime
only. Before this is filed, confirm on a system which names count:
`setup`, `teardown`, `class_setup` and `class_teardown` are the candidates. Also
confirm whether it applies only in a `FOR TESTING` class or to any class that
declares a method of that name.

Proposed: in `MethodCallChain`, report a call of one of these methods of a
`FOR TESTING` class, also as `me->teardown( )`.
