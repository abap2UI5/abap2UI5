---
target: open-abap
title: '`CALL TRANSFORMATION id` must escape XML character data'
summary: element values are written raw, so a model value containing `<` produces a draft the transpiled `CL_IXML` cannot parse back
priority: high
state: open
first_seen: 2026-07-31
upstream: open-abap/open-abap-core
evidence:
  - user report 2026-07-31 — every round-trip of the samples-controls overview app on the Pages demo died with `Network error: ASSERTION_FAILED`
  - the same failure recorded 2026-07-27 on the Node e2e backend and written off as an "open-abap runtime limit"
  - worked around by a build-time patch applied by both transpiled builds ([`web/ci/patch_open_abap_xml.mjs`](https://github.com/abap2UI5/samples-controls/blob/main/web/ci/patch_open_abap_xml.mjs))
---

> **Before filing: check whether it already is.** This item came over from
> `samples-controls/pr/`, where it was headed *"Status: open upstream — filed
> against open-abap/open-abap-core"* with **no link**, and the claim could not
> be verified when the stock was assembled on 2026-08-17. Search the tracker,
> record the date in `checked_upstream:`, and either set `state: filed` with
> the url or file it fresh. A duplicate costs a maintainer more than a late
> report does.

# `CALL TRANSFORMATION id` must escape XML character data

## Motivation

On the in-browser demo
(<https://abap2ui5.github.io/samples-controls/?app_start=z2ui5_cl_smpc_app_overview>)
every backend round-trip of the overview app died with

```
Network error: ASSERTION_FAILED
```

— reported by a user 2026-07-31 for the row buttons that open the links and the
generation-notes popover (the app's only two `client->_event( )` wires;
everything else in the overview is frontend-only). The same failure was recorded
on the Node e2e backend on 2026-07-27 and written off as an "open-abap runtime
limit" (*"the overview cannot do a second roundtrip … reloading its own draft
dies in the transpiled `cl_ixml` parse"*). It is not a limit — it is a
serializer bug, and it hits **every** app whose model data contains a `<`.

## Current behavior

`KERNEL_CALL_TRANSFORMATION`'s `LCL_DATA_TO_XML->RUN`
([`kernel_call_transformation.clas.locals_imp.abap`](https://github.com/open-abap/open-abap-core/blob/main/src/kernel/call_transformation/kernel_call_transformation.clas.locals_imp.abap))
builds the result XML by string concatenation and writes element values **raw**:

```abap
      WHEN cl_abap_typedescr=>kind_elem.
        ...
          rv_xml = rv_xml &&
            |<{ iv_name }>| &&
            <ref> &&              " <-- not escaped
            |</{ iv_name }>|.
```

abap2UI5 persists its app state with exactly that statement
(`z2ui5_cl_ui5_util_context=>xml_stringify` → `CALL TRANSFORMATION id … RESULT XML`,
stored by the core app class). The overview app's `NOTES` column carries
deviation texts such as `… menuPosition (1.56) … are <= 1.71`, so the draft ends
up containing

```xml
<NOTES>POST-1.71: … are <= 1.71. // IMPROVISED: …</NOTES>
```

On the next request the draft load parses that string back with the transpiled
`CL_IXML`. Its parser
([`cl_ixml.clas.locals_imp.abap`](https://github.com/open-abap/open-abap-core/blob/main/src/ixml/cl_ixml.clas.locals_imp.abap),
`LCL_PARSER->IF_IXML_PARSER~PARSE`) sees the stray `<` as the start of a tag,
its tag regex does not match at offset 0 and it dies in

```abap
        FIND REGEX lc_regex_tag IN lv_xml RESULTS ls_match.
        ASSERT ls_match-offset = 0.
```

An `ASSERT` is not catchable in the JS runtime, so the `TRY … CATCH cx_root`
around the draft load cannot absorb it: the whole round-trip 500s and the
frontend renders the generic `Network error: ASSERTION_FAILED`. On a real ABAP
server asXML escapes the value and the identical app works — which is why this
only ever showed in the transpiled builds.

Second, smaller defect on the read side: `LCL_ESCAPE=>UNESCAPE_VALUE` replaces
`&amp;` **first**, so a value that literally contains `&lt;` comes back as `<`.

## Proposed change

1. Escape `&`, `<` and `>` in element character data on write
   (`LCL_DATA_TO_XML->RUN`, `kind_elem` branch).
2. Unescape `&amp;` **last** in `LCL_ESCAPE=>UNESCAPE_VALUE`.

The exact patch the corpus applies (transpiler-friendly ABAP, escaping only
values that carry one of the three characters, so every other value serializes
byte-identically to today) is in
[`web/ci/patch_open_abap_xml.mjs`](https://github.com/abap2UI5/samples-controls/blob/main/web/ci/patch_open_abap_xml.mjs).

## Example

```abap
DATA lv_xml TYPE string.
DATA(ls_data) = VALUE ty_s( text = `a <= b` ).

CALL TRANSFORMATION id SOURCE data = ls_data RESULT XML lv_xml.
" today:  <TEXT>a <= b</TEXT>       -> CL_IXML parse: ASSERTION_FAILED
" wanted: <TEXT>a &lt;= b</TEXT>    -> parses back to `a <= b`

CALL TRANSFORMATION id SOURCE XML lv_xml RESULT data = ls_data.
```

A regression test belongs next to the existing round-trip tests in
`kernel_call_transformation.clas.testclasses.abap`.

## When it lands

Delete this item, and in `abap2UI5/samples-controls` drop the patch script, the
two clone steps (`web/package.json` assemble, `scripts/e2e-build.mjs`) and the
`folder` lib entries.
