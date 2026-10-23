---
target: open-abap
title: 'core: cl_sxml_string_writer answers new_open_element, new_close_element, new_value, write_attribute_raw and write_value_raw with ASSERT 1 = ''todo'' - a writer written against the node API dies uncatchably'
summary: 'five methods of `if_sxml_writer` in `cl_sxml_string_writer` are `ASSERT 1 = ''todo''`, so an sXML writer that uses the node-object API (`new_open_element( )` + `write_node( )`) rather than the convenience `open_element( )` ends in an uncatchable assertion in the transpiled runtime; the same class on a system supports both'
priority: low
state: filed
filed: https://github.com/open-abap/open-abap-core/pull/1328
first_seen: 2026-10-22
upstream: open-abap/open-abap-core
evidence:
  - 'read 2026-10-22 in open-abap-core main 239b817 - `src/sxml/cl_sxml_string_writer.clas.abap:83-101`: `if_sxml_writer~new_close_element`, `write_attribute_raw`, `new_value`, `new_open_element`, `write_value_raw` each `ASSERT 1 = ''todo''`; 89 ASSERT statements under `src/sxml` altogether'
  - 'abap2UI5 `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap:853-854`: a test feeds plain text instead of malformed markup because ''a system answers either with a catchable exception, the NodeJS parser ASSERTs on broken markup'''
  - 'prepared 2026-10-23 as `oblomov-dev/fork-open-abap-core` branch `fix/sxml-writer-node-api` (b5ba783) on open-abap-core main fde8095: new_open_element / new_close_element / new_value / write_node / write_attribute_raw / write_value_raw implemented over the existing writer and node classes, five tests; core suite 1177 green, abaplint clean. Open: the raw methods write the bytes decoded as text, a system writes RAW values Base64 - decide before filing; the reader-side ASSERTs are not touched'
  - 'filed 2026-10-23 as open-abap/open-abap-core#1328, open, awaiting review'
checked_upstream: 2026-10-23
---

# core: the node API of `cl_sxml_string_writer`

## What happens

```abap
DATA(lo_writer) = CAST if_sxml_writer( cl_sxml_string_writer=>create( ) ).
DATA(lo_elem) = lo_writer->new_open_element( 'root' ).   " open-abap-core: ASSERT 1 = 'todo'
lo_writer->write_node( lo_elem ).
```

`new_open_element`, `new_close_element`, `new_value`, `write_attribute_raw`
and `write_value_raw` are `ASSERT 1 = 'todo'` in
`cl_sxml_string_writer.clas.abap:83-101`. The convenience API
(`open_element`, `write_attribute`, `write_value`, `close_element`) works,
so code written against it is fine and code written against the node
objects - the shape SAP's own documentation uses first - dumps with an
assertion no `TRY` sees. Broken input on the reader side goes the same
way (`ASSERT` instead of `cx_sxml_parse_error`).

## Proposed change

Implement the five node methods over the existing string writer:
`new_open_element` returns an `if_sxml_open_element` holding name,
namespace and attributes; `write_node( )` dispatches on the node type to
the convenience methods. On the reader side, replace the `ASSERT`s that
guard malformed markup with `RAISE EXCEPTION TYPE cx_sxml_parse_error`.

## How to file

An issue against open-abap/open-abap-core; small, self-contained.

