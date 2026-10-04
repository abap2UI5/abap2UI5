---
target: abaplint
title: 'Report an ABAP Doc line that begins with @ but is no command'
summary: '`"! @UI.presentationVariant ...` is "A command was expected after ABAP Doc symbol @" on a system - only @parameter, @raising and @exception may start a line; abaplint reports nothing'
priority: low
state: open
first_seen: 2026-10-04
upstream: abaplint/abaplint
evidence:
  - 2026-10-04, Code Inspector SYNTAX_CHECK on an S/4HANA 7.58 system - four warnings in abap2UI5-addons/rap-ext, each a doc line starting with a CDS annotation (`@UI.presentationVariant`, `@ObjectModel.text.element`, `@Semantics.systemDateTime.createdAt`); fixed in abap2UI5-addons/rap-ext#19 by breaking the line one word earlier
  - an `@` mid-line (`… the @UI.facet entries …`) was not reported in the same run
  - measured 2026-10-04 on abaplint main 506e7b9 - no finding with check_syntax or wrong_abapdoc_position
---

# ABAP Doc: a line that begins with @

```abap
"! the first of
"! @UI.presentationVariant's sortOrder     " A command was expected after ABAP Doc symbol "@"
DATA mv_sort_field TYPE string.
```

Proposed: an ABAP Doc rule (next to the HTML-tag check of
`abaplint-abapdoc-html-tag`) that reports a `"!` line whose text begins with
`@` followed by something other than `parameter`, `raising` or `exception`.
