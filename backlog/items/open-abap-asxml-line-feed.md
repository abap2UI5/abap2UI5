---
target: open-abap
title: 'The asXML roundtrip loses every line feed - the parser strips a literal LF before it reads the document'
summary: 'cl_ixml removes every literal LF from the document before tokenizing it, and nothing writes one as a character reference, so a string with a line break comes back as one line through `CALL TRANSFORMATION id` and back'
priority: medium
state: open
first_seen: 2026-09-02
checked_upstream: 2026-09-15
upstream: open-abap/open-abap-core
evidence:
  - 'src/ixml/cl_ixml.clas.locals_imp.abap, if_ixml_parser~parse: `REPLACE ALL OCCURRENCES OF |\n| IN lv_xml WITH ||` ahead of the tokenizer loop; lcl_escape=>unescape_value resolves the five named entities and no character reference, so there is no form in which a LF survives'
  - 'probed with a two-line string through z2ui5_cl_ui5_util_context=>xml_stringify / xml_parse: `a\nb` came back `ab`'
  - 'every abap2UI5 text area that a draft carries across a roundtrip is affected - the user types two lines, the next request has one'
  - 'shimmed locally by node/setup/patch-open-abap-core.mjs (patch 3), applied to the pinned checkout before abap_transpile: 3a writes a LF as `&#10;` in lcl_data_to_xml=>escape_text, 3b resolves that reference in lcl_escape=>unescape_value'
  - 'the two sibling gaps of this family are CLOSED upstream: open-abap/open-abap-core#1193 (merged 2026-09-15, c4bb873) escapes `&`, `<` and `>` in character data on the way out and moves `&amp;` to the end of the replacements on the way back - patches 2 and 4 were deleted and the pin moved to that commit in the same change'
---

# The asXML roundtrip and a line feed

A system's `CALL TRANSFORMATION id SOURCE data = any RESULT XML result` and the
parse back keep a string as it was, line breaks included - a text area survives
a draft. The runtime does not: `if_ixml_parser~parse` removes every literal LF
from the document before it tokenizes it, and neither side has a form that
carries one instead, so a two-line value comes back as one line.

`&#10;` is the form a parser resolves and the one a LF reaches the parser in.
It costs one replacement on each side.

## Current behaviour

`src/ixml/cl_ixml.clas.locals_imp.abap`, ahead of the tokenizer loop:

```abap
    REPLACE ALL OCCURRENCES OF |\n| IN lv_xml WITH ||.
```

and `lcl_escape=>unescape_value` in the same file resolves `&lt;`, `&gt;`,
`&quot;`, `&apos;` and `&amp;` - the five named entities, no character
reference. `lcl_data_to_xml=>escape_text`
(`src/kernel/call_transformation/kernel_call_transformation.clas.locals_imp.abap`)
writes `&`, `<` and `>` and leaves a LF as it is, where the strip above then
eats it.

## Proposed change

Write a LF as `&#10;` in `escape_text`, and resolve `&#10;` in
`unescape_value` - before its `&amp;` replacement, which has to stay last for
the reason #1193 gave it. Every value without a line break serializes byte for
byte as it does today.

## The shim

`node/setup/patch-open-abap-core.mjs` (patch 3) does exactly those two
replacements against the pinned checkout before `abap_transpile` reads it.
Idempotent (marker comment), and it fails the transpile when the anchor lines
move upstream.

## Removing this

Bump the open-abap-core pin in `node/setup/fetch-deps.mjs` to a SHA that keeps
a LF across the roundtrip, delete `node/setup/patch-open-abap-core.mjs`
together with its entry in `auto_transpile` in `package.json`, and delete this
item.
