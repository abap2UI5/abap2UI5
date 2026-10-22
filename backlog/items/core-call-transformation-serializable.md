---
target: open-abap
title: 'core: CALL TRANSFORMATION id SOURCE … writes an object reference whose class does not implement IF_SERIALIZABLE_OBJECT as an empty element - a system raises CX_XSLT_SERIALIZATION_ERROR'
summary: 'the kernel transformation''s heap writer checks `IF_SERIALIZABLE_OBJECT` and, when it is missing, emits `<prg:NAME id="oN"/>` and continues; a system refuses the whole serialization. So an app state that holds such a reference passes every transpiled test and dies on the first real roundtrip with APP_SERIALIZATION_ERROR - abap2UI5 checks the interface by RTTI at bind time and subclasses its serializer in tests to force the failure'
priority: medium
state: open
first_seen: 2026-10-22
upstream: open-abap/open-abap-core
evidence:
  - 'read 2026-10-22 in open-abap-core main 239b817 - `src/kernel/call_transformation/kernel_call_transformation.clas.locals_imp.abap:116-145` (`lcl_heap->add_object`): `is_serializable` is set from the interface list; the `ELSE` branch writes `|<prg:{ lv_name } … id="o{ mv_counter }"/>|` and returns an id, no exception'
  - 'abap2UI5 `src/01/02/z2ui5_cl_ui5_client.clas.locals_imp.abap:189-193` (2026-09): the vendored ajson AND-filter ''does not compose if_serializable_object, so every filter class'' passed every check and failed only on a real system with APP_SERIALIZATION_ERROR; `src/01/02/z2ui5_cl_ui5_serializer.clas.abap:1-5` (''open-abap skips what a system refuses'' - the class is non-FINAL only so a test can inject the failure); `z2ui5_cl_ui5_client.clas.testclasses.abap:29-33`, `:1380-1382`, `:1505-1507`'
  - 'the workaround in abap2UI5: `rtti_check_serializable` at bind time (`z2ui5_cl_ui5_util_context`), which re-implements the check the transformation should make'
checked_upstream: 2026-10-22
---

# core: refuse a non-serializable object in `CALL TRANSFORMATION id`

## What happens

```abap
CLASS lcl_plain DEFINITION. ENDCLASS.          " no if_serializable_object
DATA: BEGIN OF ls_state, ref TYPE REF TO object, END OF ls_state.
ls_state-ref = NEW lcl_plain( ).
CALL TRANSFORMATION id SOURCE data = ls_state RESULT XML lv_xml.
" system:            CX_XSLT_SERIALIZATION_ERROR
" open-abap-core:    <prg:LCL_PLAIN … id="o1"/>, no error
```

`lcl_heap->add_object` in `kernel_call_transformation.clas.locals_imp.abap`
tests the interface list and, for a class without
`IF_SERIALIZABLE_OBJECT`, writes an empty element and goes on. The
asXML then deserialises to an initial reference, so even a round-trip
test is green. abap2UI5 learned it from a user's system: a filter class
of the vendored ajson lacked the interface and every state that held one
failed with APP_SERIALIZATION_ERROR - after a transpiled suite of some
thousand tests had passed.

## Proposed change

In the `ELSE` branch raise `cx_xslt_serialization_error` (exists in
open-abap-core? if not, add it under `src/exceptions`, inheriting from
`cx_xslt_runtime_error`/`cx_transformation_error` as on a system) with
the class name in the text. `CALL TRANSFORMATION` on a system raises
`CX_XSLT_SERIALIZATION_ERROR` for exactly this case; the existing kernel
test classes gain one test with a plain class.

## How to file

An issue or PR against open-abap/open-abap-core with the snippet.

