---
target: abaplint
title: 'abapdoc_html_tag: report a namespaced tag such as <html:style>'
summary: '<layoutData> in ABAP Doc is reported, <html:style> is not - SLIN reports both ("HTML tag <html:style> is not supported in ABAP Doc" and "... is not closed")'
priority: low
state: open
first_seen: 2026-11-24
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'one activation of a consumer system on S/4HANA (2026-11-24) warned "HTML tag <html:style> is not supported in ABAP Doc" and "HTML tag <html:style> is not closed" - an ABAP Doc comment quoting an XML view node (<html:style>)'
  - 'probed 2026-11-24 against abaplint 2.120.116, every rule on from `abaplint --default`, open-abap-core as dependency, an isolated syntax-clean project with a control finding firing: "! weil der Builder keine Textknoten (<html:style>...) kennt. - no finding; "! Adds <layoutData><layout:GridData span="..."/></layoutData> ... - reported twice for <layoutData>, never for <layout:GridData>'
---

# abapdoc_html_tag: report a namespaced tag such as <html:style>

```abap
"! The builder knows no text nodes (<html:style>...).        " SLIN: not supported + not closed
METHODS run2.
"! Adds <layoutData><layout:GridData span="..."/></layoutData>  " abaplint: <layoutData> only
METHODS run.
```

ABAP Doc is parsed as HTML, so any tag outside the supported list is a
finding on the system, whether its name carries a namespace prefix or not.
`abapdoc_html_tag` reports `<layoutData>` and does not report `<html:style>`
or `<layout:GridData>` - the tag name pattern evidently stops at, or rejects,
the colon. UI5 XML in a comment is exactly where namespaced tags occur.

**Proposal.** Accept `[A-Za-z_][\w.-]*(:[A-Za-z_][\w.-]*)?` as a tag name in
`abapdoc_html_tag` and report a prefixed name like any other unsupported tag,
with the same `&lt;` quick fix.

**Not reported.** The supported tags; a `<` already escaped as `&lt;`; a
colon that is not inside a tag (`a < b: c`).

**Where.** `abapdoc_html_tag`. **Effort:** S.

**Source.** A consumer system, one activation on S/4HANA.

Related upstream: abaplint/abaplint#4655 (unsupported tag in the class header comment is not seen) - another gap of the same rule; #4385.
