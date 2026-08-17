---
target: abap2ui5-linter
title: 'Report an enum-typed property bound with no fallback inside an aggregation template'
summary: an emptied table makes UI5 evaluate the template with no row behind it, the path resolves to `""`, and an enum-typed property throws rather than falling back to its default
priority: high
state: open
first_seen: 2026-08-17
upstream: abap2UI5/linter
evidence:
  - `abap2UI5/samples-controls` app 308, 2026-08-16 — found by an e2e interaction, not by any gate
  - the control throws `"" is of type string, expected sap.ui.unified.CalendarDayType for property "secondaryType"` and takes the view down
  - the port boots clean, survives the first press of its toggle and dies on the second — the press that empties the table
  - the analysis and the scope this proposal needs are written up in `.claude/skills/ui5-check/SKILL.md` §4
---

# Report an enum-typed property bound with no fallback inside an aggregation template

## What happens

```
"" is of type string, expected sap.ui.unified.CalendarDayType
 for property "secondaryType"
```

Not "falls back to the default" — the control throws.

The trigger is worth stating precisely, because the obvious reading is wrong.
It is **not** the row that leaves the field unset: an unset field never reaches
the model at all (`_bind( … omit_initial_paths = … )` keeps it out). It is the
table being **cleared**. UI5 then evaluates the aggregation TEMPLATE with no row
behind it, `{SECONDARY_TYPE}` resolves to `` — and the enum-typed property
rejects it.

The trap is structural rather than particular to that control: ABAP has no
null, an unfilled `TYPE string` serialises as `""`, and **`""` is a member of no
UI5 enum**. So it applies to every enum-typed property in an aggregation
template — `type`, `state`, `design`, `valueState`, `highlight` — whenever the
bound table can be empty. A first render passes and the emptying fails, which is
why nothing offline sees it.

## Why this one is worth a rule

Once the trigger is stated correctly the rule gets *easier*, not harder. It does
not need to know anything about the data. **An enum-typed property inside an
aggregation template, bound to a plain path with no fallback** is decidable from
the view alone, and both halves are already modelled:

- the enum-valued properties are known — `enum-value-too-new` reads their
  `enumSince` out of `properties.json`;
- "inside a template" is the `ele( <aggregation> )` the builder chain already
  reconstructs.

## What it must NOT report

A property bound **outside** a template, or one whose table can never be
emptied, is fine. A rule that reported every enum binding would be routed
around within a week, and the entry has been left open rather than filed as a
wish precisely until the scope above was clear.

## The fix the rule should point at

An expression binding with the enum's own default as the else branch:

```abap
)->a( n = `secondaryType` v = `{= ${SECONDARY_TYPE} ? ${SECONDARY_TYPE} : 'None' }`
```

Write it as a backtick literal rather than a string template — a template has to
escape every brace, and one missed escape is a `parser_error` on the whole
statement.
