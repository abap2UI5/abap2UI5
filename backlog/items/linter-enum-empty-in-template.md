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
  - a full e2e sweep of all 417 samples-controls apps (2026-08-17) found **two** apps DEAD on their first render from this class, both reporting green until the gate learned to read the framework's fatal overlay — app 362 (`sap.ui.core.SortOrder`) and app 121 (`sap.m.ObjectMarkerVisibility`)
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

## The same trap without a template: a plain member left initial

App **121** is the sharper case, because **the original UI5 sample does the
same thing and works**. Its view binds

```xml
<ObjectMarker type="{type}" visibility="{visibility}"/>
```

and its data is `{"type":"Draft"}` — no `visibility` anywhere. In JavaScript
that resolves to `undefined`, and UI5 leaves the property at its default. ABAP
has no `undefined`: the unfilled `TYPE string` serialises as `""`, and `""` is a
member of no enum. The app terminated on its first render.

So a **1:1 port of a correct sample is fatal**, and nothing about the view or
the data looks wrong at either end. That is the structural half of this entry,
proven against the original rather than argued from ABAP's type system.

It also widens the rule's scope beyond the emptied-table case: any enum-typed
property bound to a path the model may not carry — a template row that omits
the field, or a plain member never assigned — has the same end state. The fix
is the same shape in both: keep the value out of the model
(`_bind( … omit_initial_paths = … )`, which apps 121, 241 and 299 use) or give
the binding a fallback.

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
