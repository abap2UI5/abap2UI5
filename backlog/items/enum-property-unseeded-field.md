---
target: abap2ui5-linter
title: 'Report an ENUM-typed property bound to an ABAP field a runtime INSERT leaves unset — the empty string takes the view down'
summary: 'an ABAP field is never absent, so an unseeded one reaches an enum property as "" and validateProperty throws, killing the binding update and the view'
priority: high
state: filed
filed: https://github.com/abap2UI5/linter/pull/61
first_seen: 2026-08-24
evidence:
  - samples-controls apps 546, 609 and 610 each insert a row at runtime without seeding an enum-typed field (CalendarDayType type, aria.HasPopup ariaHasPopup). Every drag-create or dialog-save takes the view down
  - app 531 has the same shape from the seed side - two mock rows genuinely omit elementType, and QuickViewGroupElement.type is enum-typed
  - the framework contract already names this case (z2ui5_if_client: "an enum-typed property rejects the empty string outright") and ships omit_initial_paths for it. Three ports still did it
---

## What happens

The originals push a JS object with the key **absent**, and UI5 falls back to the
property default. ABAP has no absent: the field ships as `""`, which is not a
member of any enum, so `ManagedObject.validateProperty` throws — and
`ManagedObjectBindingSupport` re-throws anything that is not a `FormatException`,
so the binding update dies and takes the view with it.

Both repairs already exist: seed the default (`type = 'None'`), or list the field
in `omit_initial_paths`.

## Proposed rule

Report a bound property whose UI5 type is a registered enum, where the ABAP field
behind the binding is not covered by `omit_initial_paths` **and** the class
contains at least one `INSERT`/`APPEND` into that table which does not set the
field.

The second half is what makes it a rule rather than noise — a field seeded on
every row in `model_init` is fine, and that is the common case.

## What it must not report

- A field seeded on every construction site, including `model_init`.
- A field already named in `omit_initial_paths`.
- A property whose type is a plain `string`, `sap.ui.core.URI` or `CSSColor` —
  all of those accept `""` (the URI and CSSColor regexes carry an empty
  alternative), which is why only the enum case bites.
- An expression binding with a `|| null` or ternary fallback: `null` reaches
  `validateProperty` as "use the default" and is a legitimate spelling.
