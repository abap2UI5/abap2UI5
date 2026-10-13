---
target: open-abap
title: 'cl_sxml_string_reader on JSON drops a duplicate object key - the reader is JSON.parse( ), which keeps the last one'
summary: the JSON branch of `cl_sxml_string_reader` is `JSON.parse(iv_json)` in a `@KERNEL` line (`lcl_json_parser=>parse`), so an object with the same key twice delivers one `OPEN_ELEMENT` for it; a system's sXML reader delivers both in document order, and ajson (abap2UI5's `z2ui5_cl_ajson`, upstream sbcgua/ajson) has a parser test that expects both nodes
priority: low
state: filed
filed: https://github.com/open-abap/open-abap-core/pull/1313
first_seen: 2026-10-12
evidence:
  - found 2026-10-12 going through every abap2UI5 unit test that does not run under `npm run unit` - `z2ui5_cl_ajson` `ltcl_parser_test->unicode_characters` parses `{ "unicodeሴ": 3, "unicodeሴ": { "c": 3 }, "c": "unicodeሴ" }` and expects five nodes; the skip note blamed the `CL_ABAP_CONV_IN_CE=>uccpi` dynamic call, which works at open-abap-core b2d219d (`uccpi( 4660 )` answers U+1234)
  - measured 2026-10-12 on open-abap-core b2d219d with `@abaplint/runtime` 2.14.3 - the parse answers four nodes, the first `unicodeሴ` (`num 3`) is gone, the second (`object`) and everything after it is as expected
  - the cause, read in `src/sxml/cl_sxml_string_reader.clas.locals_imp.abap` at b2d219d - `lcl_json_parser=>parse` is `WRITE '@KERNEL lv_json = {value: JSON.parse(iv_json.get())};'` and `traverse( lv_json )` walks the resulting JS object, whose later duplicate key has overwritten the earlier one
  - filed 2026-10-13 as open-abap/open-abap-core#1313 - `JSON.parse( )` stays for validation and the parse error, then a small scanner reads the valid text into key/value pairs in document order; checked against abap2UI5's tree (open-abap-core b2d219d plus the patch, `@abaplint/runtime` 2.14.3, the skip entry removed) - `z2ui5_cl_ajson` `ltcl_parser_test->unicode_characters` passes and `npm run unit` stays green
checked_upstream: 2026-10-13
---

# JSON through `cl_sxml_string_reader`: a duplicate key is one key

## What happens

```abap
DATA(li_reader) = cl_sxml_string_reader=>create( cl_abap_codepage=>convert_to( `{"a": 1, "a": 2}` ) ).
" system: OPEN_ELEMENT a, VALUE 1, CLOSE, OPEN_ELEMENT a, VALUE 2, CLOSE
" open-abap: OPEN_ELEMENT a, VALUE 2, CLOSE
```

RFC 8259 says names "SHOULD be unique", and SAP's reader delivers what the
document holds. A library that validates on top of sXML - ajson's
`duplicate_key` test, for one - cannot see the duplicate under the runtime.

## Where

`src/sxml/cl_sxml_string_reader.clas.locals_imp.abap`, `lcl_json_parser`:
`parse( )` is `JSON.parse( )`, `traverse( )` walks the object.

## The fix

A small tokenizer in `lcl_json_parser` that emits the nodes in document
order instead of walking a JS object: objects, arrays, strings (with the
escapes `JSON.parse` already handles), numbers, `true`/`false`/`null`. The
`traverse( )`/`append( )` shape stays, only the source of the events
changes. The error path (`cx_sxml_parse_error` with `xml_offset`) becomes
exact as a side effect - the comment in `parse( )` notes that Node 20 no
longer reports the position in `JSON.parse`'s message.

## Why it is low priority here

One test in the ajson mirror. The framework never sends a duplicate key, and
a client that does gets the last value, which is what every browser's
`JSON.parse` would give it too. It matters for a reader whose job is to
validate input.

## How to file

An issue against open-abap/open-abap-core with the two-line repro; a PR
with the tokenizer if somebody wants it - `cl_sxml_string_reader.clas.testclasses.abap`
has the JSON cases to extend.

1. Search the open-abap-core tracker first and record the date in
   `checked_upstream:`.
2. Open the issue or the PR.
3. Set `state: filed` and `filed: <url>` here, run `npm run backlog`, commit.
4. When it merges, bump the open-abap-core pin in abap2UI5, drop the
   `unicode_characters` entry from `node/setup/abap_transpile.json`, delete
   this item.
