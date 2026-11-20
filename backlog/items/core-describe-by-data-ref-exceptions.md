---
target: open-abap
title: 'cl_abap_typedescr=>describe_by_data_ref: declare EXCEPTIONS reference_is_initial and name the RETURNING parameter p_descr_ref'
summary: 'the open-abap stub of describe_by_data_ref has no EXCEPTIONS and returns `type` where SAP returns `p_descr_ref`, so a caller cannot write the safe form `CALL METHOD ... RECEIVING p_descr_ref = ... EXCEPTIONS reference_is_initial = 1` and still transpile; describe_by_object_ref already declares and raises it'
priority: medium
state: open
first_seen: 2026-11-20
checked_upstream: 2026-11-20
upstream: open-abap/open-abap-core
evidence:
  - 'open-abap-core f735eed, `src/rtti/cl_abap_typedescr.clas.abap`: `describe_by_data_ref IMPORTING p_data_ref TYPE REF TO data RETURNING VALUE(type) TYPE REF TO cl_abap_typedescr` - no EXCEPTIONS, and the implementation ASSIGNs `p_data_ref->*` without testing it; `describe_by_object_ref` next to it declares `EXCEPTIONS reference_is_initial` and raises it for an initial reference'
  - 'SAP (steampunk-2305 API stubs, node/deps): `describe_by_data_ref IMPORTING p_data_ref RETURNING VALUE(p_descr_ref) EXCEPTIONS reference_is_initial`'
  - 'abap2UI5, 2026-11-20: the abaplint rule unhandled_classic_exception (option missingExceptions, abaplint/abaplint#4594) reports five functional describe_by_*_ref calls in z2ui5_cl_ui5_util_context - a runtime error for an initial reference that no CATCH reaches. The fix with EXCEPTIONS does not transpile against open-abap, so util_context tests the reference first, and missingExceptions stays off in abaplint.jsonc until this is fixed'
---

# cl_abap_typedescr=>describe_by_data_ref: EXCEPTIONS reference_is_initial

## What happens

```abap
CALL METHOD cl_abap_typedescr=>describe_by_data_ref
  EXPORTING
    p_data_ref           = lr_data
  RECEIVING
    p_descr_ref          = lo_type
  EXCEPTIONS
    reference_is_initial = 1
    OTHERS               = 2.
```

This is the form SAP documents and the form a linter asks for, because a functional call turns an initial reference into a runtime error. Against open-abap it does not compile: the method declares no `EXCEPTIONS`, and its RETURNING parameter is called `type`, not `p_descr_ref`.

## Proposal

In `src/rtti/cl_abap_typedescr.clas.abap`:
- rename the RETURNING parameter of `describe_by_data_ref` to `p_descr_ref`, as on SAP (positional and functional callers are unaffected);
- declare `EXCEPTIONS reference_is_initial` and `RAISE reference_is_initial.` when `p_data_ref IS INITIAL`, as `describe_by_object_ref` already does.

Check the other RTTI entry points the same way (`describe_by_name` and `type_not_found`).

## Where it matters

Once this is in, abap2UI5 can call the method with `EXCEPTIONS` and switch on `missingExceptions` of `unhandled_classic_exception`.
