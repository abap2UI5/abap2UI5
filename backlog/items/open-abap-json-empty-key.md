---
target: open-abap
title: 'A JSON object member with an EMPTY key loses its name attribute, and the consumer dumps instead of raising'
summary: 'cl_sxml_string_reader decides on `IF <ls_parsed>-key IS NOT INITIAL`, so `{"":1}` reaches the reader as an element with NO attributes - indistinguishable from an array element - and ajson''s `ASSERT sy-subrc = 0` fires two lines before the error it would have raised'
priority: medium
state: open
first_seen: 2026-09-16
checked_upstream: 2026-09-16
patch: backlog/patches/open-abap-json-empty-key.patch
upstream: open-abap/open-abap-core
evidence:
  - 'src/sxml/cl_sxml_string_reader.clas.locals_imp.abap, lcl_reader=>initialize: the `name` attribute is created only `IF <ls_parsed>-key IS NOT INITIAL`, and ty_node-key is a plain string, so "no key" (an array element) and "an empty key" (an object member) are the same value'
  - 'the parser CAN tell them apart and throws the distinction away: traverse_object always passes iv_key, traverse_array never does'
  - 'abap2UI5 repro through the real HTTP entry point: POST `{"value":{"S_FRONT":{"ID":"<draft>"},"MODEL":{"":"x"}}}` to z2ui5_cl_ui5_http_handler=>_main answers with an uncaught ASSERTION_FAILED - not a 500, not a body, nothing. Same for `{"a":{"":1}}` nested one level down'
  - 'the assert is z2ui5_cl_ajson.clas.locals_imp.abap:491, `ASSERT sy-subrc = 0 AND lo_attr->qname-name = ''name''.`, six lines above ajson''s own `IF <item>-name IS INITIAL. raise( ''Node without name (maybe not JSON)'' ).` - so a system answers the same body with a catchable CX_AJSON_ERROR and a clean 500'
  - 'verified: with the attached patch applied to the pinned checkout and the sources re-transpiled, the four empty-key shapes answer 500 and the abap2UI5 unit suite stays green (1271 tests)'
  - 'found a second time from the other end: a fuzz of the row-delta path over sixteen malformed `__delta` shapes (ltcl_04_model_in->delta_malformed_survives) answers all sixteen with the table untouched - except the empty-key one, which never reaches the model because the parser asserts first. That test carries the exclusion and points here'
---

# An empty JSON key, and the dump that replaces the error

`{"":1}` is legal JSON. A real system's sXML reader hands it on as an element
carrying a `name` attribute whose value is empty, the consumer sees an empty
name and raises its own error. Under open-abap the attribute is not there at
all, and a consumer that reads it by index and asserts on the `sy-subrc` dumps
instead - **before** reaching the line that would have raised.

The direction is what makes it worth fixing: the runtime turns a catchable
exception into an uncatchable one. For a web framework parsing a request body
that is the difference between a 500 with a message and a response with no
body, no status code and none of its security headers, because `ASSERTION_FAILED`
is a short dump that no `TRY` takes.

## Current behaviour

`src/sxml/cl_sxml_string_reader.clas.locals_imp.abap`, `lcl_reader=>initialize`:

```abap
WHEN if_sxml_node=>co_nt_element_open.
  CLEAR lt_attributes.
  IF <ls_parsed>-key IS NOT INITIAL.
    CREATE OBJECT li_attribute TYPE lcl_attribute
      EXPORTING
        name       = 'name'
        value      = <ls_parsed>-key
        value_type = if_sxml_value=>co_vt_text.
    APPEND li_attribute TO lt_attributes.
  ENDIF.
```

`ty_node-key` is a `string`, so the test cannot distinguish an object member
whose key is `''` from an array element, which has no key at all. Both come out
with an empty attribute table.

The parser above it knows the difference and discards it:
`lcl_json_parser=>traverse_object` passes `iv_key` for every member,
`traverse_array` passes none.

## Who it bites

ajson, which is vendored into abap2UI5 as `src/00/01` and reads every request
body the framework receives:

```abap
lt_attributes = lo_open->get_attributes( ).
" JSON nodes always have one "name" attribute
READ TABLE lt_attributes INTO lo_attr INDEX 1.
ASSERT sy-subrc = 0 AND lo_attr->qname-name = 'name'.
<item>-name = lo_attr->get_value( ).
...
IF <item>-name IS INITIAL.
  raise( 'Node without name (maybe not JSON)' ).
ENDIF.
```

The comment on the `READ TABLE` states the invariant this gap breaks. Six lines
further down ajson handles the empty name properly - the assert never lets it
get there.

## Proposed change

Carry "there was a key" next to the key. `ty_node` gains `has_key TYPE
abap_bool`, `traverse_object` sets it for every member it traverses,
`traverse_array` does not, and the reader attaches the attribute on the flag
instead of on the value. Every document without an empty key produces exactly
the node table it produces today.

Written and measured - `backlog/patches/open-abap-json-empty-key.patch`
(`git am` against `open-abap/open-abap-core`). Not opened as a pull request
because this session has no write access to the `open-abap` organization.

## Why abap2UI5 ships no shim for it

The other open-abap items in this folder carry one in
`node/setup/patch-open-abap-core.mjs`, and this one deliberately does not.
Those shims fix a divergence a REAL SYSTEM also suffers from through abap2UI5;
this divergence exists only on the transpiled runtime - on a system the very
same request is already answered with a clean 500. A shim would be eight
anchored edits in one file for a defect no installation has, and every anchor
is a way for the next `auto_transpile` to break.

What it costs instead: the empty-key request shape cannot be pinned by a test
in abap2UI5 until upstream ships the fix, because the test would dump in CI
and pass on every system. That is the reason this item exists rather than a
test.

## Removing this

Bump the open-abap-core pin in `node/setup/fetch-deps.mjs` to a SHA that
carries the fix, add the framework test that pins the 500 for an empty-named
model key (`z2ui5_cl_ui5_http_handler`'s test class, next to
`test_post_no_s_front`), and delete this item together with its patch.
