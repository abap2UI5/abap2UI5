---
target: abap2ui5-linter
title: 'Report an enum property bound to a table cell without a fallback for the empty value'
summary: 'type, design or valueColor bound straight to a STRING column of a bound table - an initial value is no member of the enum, UI5 throws in validateProperty and the view does not render'
priority: medium
state: open
first_seen: 2026-11-25
checked_upstream: 2026-11-25
evidence:
  - 'abap2UI5-addons/layout-management a6da435 (2026-11-25): xml_build_table bound Switch type and Button type to {ROW/TYPE}; TYPE is a STRG column whose initial value is an empty string - checked against the OpenUI5 1.71 sources, ManagedObject.validateProperty rejects it and updateProperty rethrows everything but a FormatException, so the table view breaks. Fixed with {= ${ROW/TYPE} || ''Default'' }'
  - 'the same file binds state, design/status, color and valueColor of template cells the same way (older code) - a value outside the enum breaks the view the same way'
  - '.claude/skills/ui5-check names the class (an enum value a release does not know); @abap2ui5/linter 0.11.3 has no rule that reads a binding of an enum-typed property'
---

# Report an enum property bound to a table cell without a fallback for the empty value

## Motivation

A property typed with an enum (`sap.m.ButtonType`, `sap.m.SwitchType`,
`sap.ui.core.ValueState`, `sap.m.ValueColor`, ...) validates every value the
model hands it. Bound to a column of a bound table, the value is whatever
the ABAP row holds - and an initial STRING is `""`, which is no member of
most of these enums. UI5 throws, and the whole view fails to render, not just
the cell. The transpiled tests and abaplint stay green: the XML is valid.

## Proposed rule

`enum-binding-no-fallback`, severity warning.

Report an attribute of a view built with `z2ui5_cl_ui5_view_builder` (or an
XML string) whose property is enum-typed in the UI5 API manifest, whose value
is a plain property binding `{path}`, and whose path resolves into a row of a
bound table (a template under `items`/`rows`).

Message: an empty or unknown value breaks the view; bind with a fallback,
e.g. `{= ${path} || 'Default' }`, or a formatter.

## What it must not report

- An enum property that accepts the empty value - the rule needs that list
  per enum, taken from the 1.71 sources, not guessed.
- An expression binding or a binding with a formatter.
- A binding to a scalar attribute of the app (not a row) - the app controls
  that value and it is usually filled.
- A literal value.

## Example

```abap
switch->a( n = `type` v = |\{{ path }/TYPE\}| ).                          " reported
switch->a( n = `type` v = |\{= $\{{ path }/TYPE\} \|\| 'Default' \}| ).   " not reported
```
