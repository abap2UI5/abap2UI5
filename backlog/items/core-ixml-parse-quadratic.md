---
target: open-abap
title: 'core: the transpiled CL_IXML parser is quadratic in document size - 29.8 s of a 31.3 s roundtrip went into parsing a 578 kB asXML draft'
summary: '`cl_ixml`''s parse re-slices and CONDENSEs the remaining text per node, so the cost grows with the square of the document; a draft of a few thousand rows made one roundtrip take half a minute on the Node backend, and the port was changed to bind less state - a cursor-based scan over the string (offset instead of substring) would make the parse linear'
priority: medium
state: open
first_seen: 2026-10-22
upstream: open-abap/open-abap-core
evidence:
  - 'samples-controls `docs/history.md:4933-4945` (2026-10): profiled roundtrip of a 578 kB draft on the transpiled backend - ''`all_xml_parse` 29.8 s of a 31.3 s round-trip''; the app now binds a slim state as the workaround'
  - 'abap2UI5 `docs/agents/decisions.md:16`: a draft parse of 1,100 ms at 4000 rows against a 1 ms in-memory copy, the reason for the serializer seam and the Node-only `zcl_serializer_live`; `node/srv/zcl_serializer_live.clas.abap:4-8` (''by far the most expensive part of a roundtrip in this runtime'')'
  - 'the shape, read 2026-10-22 in open-abap-core main 239b817 - `src/ixml/` parser methods take the rest of the document as a string, slice the consumed part off and `CONDENSE` / `SHIFT` the remainder per element'
checked_upstream: 2026-10-22
---

# core: a linear `CL_IXML` parse

## The problem

`CALL TRANSFORMATION id … RESULT` and every `cl_ixml` consumer go through
open-abap-core's XML parser. It is written as "take the rest of the
string, consume the next token, keep the rest", and each step copies the
rest - a quadratic algorithm. abap2UI5's state round-trip measured it:

| document | parse | whole roundtrip |
|---|---|---|
| 578 kB asXML draft | 29.8 s | 31.3 s |
| 4000-row table (abap2UI5 draft) | 1.1 s | 1 ms for the in-memory copy |

abap2UI5 built a serializer seam and a Node-only in-memory store around
it; samples-controls slimmed an app's state. Both work around the parser.

## Proposed change

Parse with an offset over the original string: `FIND … IN SECTION OFFSET
lv_off OF lv_xml` and `lv_xml+lv_off(lv_len)` instead of re-assigning the
remainder, no `CONDENSE` of the tail, and a single pass that emits the
node list. The kernel path (`@KERNEL`) could also hand the string to the
host's `DOMParser` when one exists (browser; Node 22 has none built in),
but the ABAP rewrite serves every host.

A benchmark in the core suite (a 500 kB document under a time bound)
keeps it linear.

## How to file

An issue against open-abap/open-abap-core with the two measurements.

