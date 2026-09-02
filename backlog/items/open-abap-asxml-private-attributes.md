---
target: open-abap
title: 'CALL TRANSFORMATION id cannot serialize an object with a PRIVATE attribute - the heap writer asserts on its dynamic ASSIGN'
summary: 'kernel_call_transformation (lcl_heap=>add_object) and kernel_ixml_xml_to_data reach the attributes of a serializable object by `ASSIGN iv_ref->(name)`; a private attribute is a #field in the transpiled class, the walker in @abaplint/runtime reads undefined, and the ASSERT on sy-subrc dies. A system serializes private attributes'
priority: medium
state: open
first_seen: 2026-09-02
checked_upstream: 2026-09-02
upstream: open-abap/open-abap-core
evidence:
  - 'src/kernel/call_transformation/kernel_call_transformation.clas.locals_imp.abap, lcl_heap=>add_object: `ASSIGN iv_ref->(ls_attribute-name) TO <any>` followed by `ASSERT sy-subrc = 0` over every attribute cl_abap_classdescr lists, private ones included; kernel_ixml_xml_to_data reads them back the same way'
  - 'instrumented in node/output: the assert fires for CLAS-Z2UI5_CL_AJSON_MAPPING-LCL_MAPPING_TO_LOWER, attribute MI_MAPPING_FIELDS (private) - every mapper of z2ui5_cl_ajson_mapping keeps one, so a bound attribute with custom_mapper never survived a draft in the transpiled backend'
  - 'shimmed locally by node/setup/patch-abaplint-runtime-assign.mjs (block 2): the walker of the dynamic ASSIGN falls back to FRIENDS_ACCESS_INSTANCE, the map the transpiler keeps for friend access. Wider than a system (a dynamic ASSIGN from outside the class reaches a private attribute), accepted for the test runtime'
---

# asXML and private attributes

`CALL TRANSFORMATION id SOURCE ... RESULT XML` on a system writes every
attribute of a serializable object, whatever its visibility - the kernel does
not go through the language's access rules. open-abap-core's kernel is ABAP
code and reaches the attributes by a dynamic `ASSIGN iv_ref->(name)`. The
transpiler makes a private attribute a JavaScript `#field`, invisible to the
runtime's walker; the writer's `ASSERT sy-subrc = 0` dies, the reader would
skip it.

abap2UI5 stores the mapper and the filter of a binding on the attribute
table (`mt_attri-custom_mapper`, `custom_filter`), which travels through
this serialization with the app. Every mapper of `z2ui5_cl_ajson_mapping`
holds a private `mi_mapping_fields`, so in the transpiled backend a
`_bind( custom_mapper = ... )` could not cross a draft. On a system it does.

## The shim

`node/setup/patch-abaplint-runtime-assign.mjs`, block 2: when the walker
reads `undefined` for an attribute segment, it looks the name up in the
object's `FRIENDS_ACCESS_INSTANCE`, the map the transpiler keeps for
`FRIENDS` access and for the unit-test runner. Idempotent by marker; fails
the transpile when the anchor moves.

The shim is wider than a system: a dynamic ASSIGN from outside the class
reaches a private attribute here, gets sy-subrc 4 there. No abap2UI5 code
relies on that difference, and the unit tests that cover it
(`ltcl_05_draft->bind_options_survive`) assert the system's behaviour.

## Removing this

The right fix is in open-abap-core (a kernel-side access to the attributes
that bypasses visibility, as the transpiler already gives the unit runner)
or in the transpiler's walker. Bump the pin that carries it, delete block 2
from the patch script, and close this item.
