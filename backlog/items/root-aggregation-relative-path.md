---
target: abap2ui5-linter
title: 'Report a root-level aggregation bound with a bare relative path — it resolves against nothing and renders empty'
summary: "{path: 'T_ITEMS'} outside a bound row template has no context to resolve against; hardcoded-binding-path only matches paths that START with /, and relative-binding-without-context skips aggregations"
priority: high
state: open
first_seen: 2026-08-24
evidence:
  - samples-controls apps 541 and 554 bound their PlanningCalendarLegend items and appointmentItems (and 541 its specialDates) with a bare T_ path. The legend rendered empty - and in both cases the tables were additionally never passed to _bind( ), so they never reached the client model either
  - app 553 carries the correct absolute form with a comment naming the lesson, so the two were a copy that missed the fix
  - a corpus sweep found 33 such paths, 28 of them correctly relative inside a bound row template - so the rule has to distinguish the two, which is the whole difficulty
---

## The gap between two existing rules

- `hardcoded-binding-path` matches only paths that **start with `/`**. Dropping
  the slash is exactly what silences it.
- `relative-binding-without-context` skips aggregations (`member.set !== 'aggregations'`).

So a relative aggregation path at root falls between them and is reported by
neither. `Model.resolve` returns `undefined` for it (legacy syntax is off since
1.88), `bindList` never resolves, and the aggregation stays empty.

## Proposed rule

Report an aggregation binding whose path does not start with `/` **and** whose
control has no ancestor carrying a bound aggregation — i.e. no row context can
exist for it.

## What it must not report

This is the hard half and the reason the rule does not exist yet:

- A relative path **inside a bound row template** is the correct and dominant
  form — 28 of the 33 sites in the corpus. The rule is only about the ones with
  no enclosing bound aggregation.
- A control inside a `core:FragmentDefinition` that is displayed into a popup or
  popover slot: the slot carries its own model, and the fragment root is a root.
- A path made relative deliberately alongside an element binding
  (`cs_event-bind_element`), where a context does exist at runtime and the view
  cannot see it statically. Those need an escape hatch, or the rule will fight
  the `bindElement` idiom.

## Second half, worth catching in the same pass

Both ports also never passed the table to `client->_bind( )`, so even the
absolute path would have resolved to nothing — the serializer only ships
attributes with `bind = abap_true`. A binding whose path names an ABAP attribute
that is never bound is statically detectable and is arguably the stronger signal.
