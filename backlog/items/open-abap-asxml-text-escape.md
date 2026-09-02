---
target: open-abap
title: 'CALL TRANSFORMATION id writes character values into asXML unescaped - a value containing markup does not survive the roundtrip'
summary: 'kernel_call_transformation (lcl_data_to_xml=>run) concatenates a string value into its element as it is, while the parser resolves &lt; &gt; &amp; on the way back; a string that contains `<` comes back cut at that point. A system escapes on the way out'
priority: medium
state: open
first_seen: 2026-09-02
checked_upstream: 2026-09-02
upstream: open-abap/open-abap-core
evidence:
  - 'src/kernel/call_transformation/kernel_call_transformation.clas.locals_imp.abap, lcl_data_to_xml=>run, kind_elem branch: `rv_xml = rv_xml && |<{ iv_name }>| && <ref> && |</{ iv_name }>|` - no escaping; src/ixml/cl_ixml.clas.locals_imp.abap resolves the four entities when parsing'
  - 'probed in node/output with z2ui5_cl_ui5_util_context: an S-RTTI payload (an XML document in a string, 1186 characters) serialized inside a structure and parsed back is 45 characters long; the same in place, without the outer roundtrip, is intact'
  - 'every abap2UI5 draft with a generic data reference carries such a payload (mt_attri-srtti_data), so in the transpiled backend no such draft restored - APP_STATE_RESTORE_ERROR on the next roundtrip'
  - 'shimmed locally by node/setup/patch-open-abap-core.mjs (patch 2), applied to the pinned checkout before abap_transpile: `&`, `<` and `>` are escaped in string and character values'
  - 'same family, patch 4: lcl_escape=>unescape_value resolves `&amp;` before `&lt;`, so an escaped payload inside an escaped value (`&amp;lt;`) is resolved twice and its markup parsed as elements - `&amp;` must be the last replacement'
  - 'same family, patch 3: the parser (cl_ixml, if_ixml_parser~parse) strips every literal LF from the document before reading it, so a string with a line break came back as one line; the writer now emits `&#10;` for a LF and the unescape resolves it - probed with a two-line string through z2ui5_cl_ui5_util_context=>xml_stringify / xml_parse: `a\nb` came back `ab`'
---

# CALL TRANSFORMATION id and character values that contain markup

A system's `CALL TRANSFORMATION id SOURCE data = any RESULT XML result`
escapes the characters XML reserves (`&`, `<`, `>`) in every character value,
and the parse direction resolves them again - a string that holds an XML
document goes out and comes back unchanged. The runtime's asXML writer
(`lcl_data_to_xml=>run`, `kind_elem`) concatenates the value as it is; its
parser (`cl_ixml`) does resolve the entities. The two do not meet in the
middle: a value with a `<` in it is cut at that point on the way back.

## The shim

`node/setup/patch-open-abap-core.mjs` (patch 2) adds a branch for
`typekind_string` and `typekind_char` that writes the value through three
`REPLACE ALL OCCURRENCES` (`&` first). Numbers, dates and the rest keep the
original expression. Idempotent (marker comment), and it fails the transpile
when the anchor lines move upstream.

## The line feed (patch 3)

The parser side has a second gap of the same kind: `if_ixml_parser~parse`
removes every literal LF from the document before it tokenizes it, so a
string value with a line break is one line after the roundtrip. Patch 3a
writes a LF as `&#10;` in the same escaped branch, patch 3b lets
`lcl_escape=>unescape_value` resolve that reference. A system keeps the LF
of a text area across the draft; so does the transpiled backend now.

## The entity order (patch 4)

`lcl_escape=>unescape_value` resolves `&amp;` first. A value that is itself
an escaped document - abap2UI5's S-RTTI payload of a table with a `<` in a
cell, written as `&amp;lt;` - is resolved twice: `&amp;lt;` becomes `&lt;`
becomes `<`, and the inner parse then reads the cell's text as markup. A
parser resolves each reference once. Patch 4 moves `&amp;` to the end of the
replacements. Found by `ltcl_05_draft->markup_survives`: `<b>tag</b>` in a
row of a generic table came back as `tag`.

## Removing this

Bump the open-abap-core pin in `node/setup/fetch-deps.mjs` to a SHA that
escapes on the way out, keeps a LF and resolves `&amp;` last, delete patches
2, 3 and 4 from `node/setup/patch-open-abap-core.mjs`, and close this item.
