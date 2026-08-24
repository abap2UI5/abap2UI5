---
target: abap2ui5
title: 'A global target for IconPool.registerFont — icon collections an app cannot register'
summary: an app that uses an icon collection outside the default SAP-icons font has no way to register it, because IconPool is a module-level singleton no frontend-action target can address
priority: low
state: filed
filed: https://github.com/abap2UI5/abap2UI5/tree/claude/samples-controls-review-u4g6cr
first_seen: 2026-08-24
upstream: abap2UI5/abap2UI5
evidence:
  - samples-controls app 350 (sap.ui.layout.sample.ProductHomeLayout) renders its first Frequent Operations tile without a glyph
  - the original's Component.js init does IconPool.registerFont({ fontFamily: 'SAP-icons-TNT', fontURI: sap.ui.require.toUrl('sap/tnt/themes/base/fonts/') })
  - neither sap.tnt's library.js nor abap2UI5 registers the collection (both grepped 2026-08-21 and 2026-08-24, zero hits)
---

# A global target for `IconPool.registerFont`

> **Implemented 2026-08-24** in this repository - the ICON_POOL global target, its two-argument wire and the toUrl resolution - on branch `claude/samples-controls-review-u4g6cr`. The item stays here until that merges.

## Motivation

UI5 ships icon collections beyond the default `SAP-icons` font — `sap.tnt`'s
`SAP-icons-TNT` is the common one. A `sap-icon://SAP-icons-TNT/...` URI only
resolves once something has called
`IconPool.registerFont({ fontFamily, fontURI })`. In a normal UI5 app that call
lives in the Component's `init`.

An abap2UI5 app has no Component of its own to run it in, and no existing wire
reaches `IconPool`: it is a module-level singleton rather than a control, so
`control_by_id` cannot address it, and `control_global` has no target token for
it. The result is silent — the URI stays in the view, the control renders, and
only the glyph is missing.

## Current behaviour

samples-controls app 350 keeps the original's icon URI verbatim and its first
Frequent Operations tile renders glyph-less, in a real system as much as in the
render harness. The port declares this as an IMPROVISED deviation; there is no
workaround it can apply.

## Proposed change

A `control_global` target for the icon pool, in the shape the existing global
singletons already use (`BUSY_INDICATOR`, `INVISIBLE_MESSAGE`, `THEMING`,
`FORMATTING`):

```abap
client->follow_up_action(
    val   = client->cs_event-control_global
    t_arg = VALUE #( ( `ICON_POOL` ) ( `registerFont` )
                     ( `SAP-icons-TNT` ) ( `sap/tnt/themes/base/fonts/` ) ) ).
```

Notes for whoever picks this up:

- `fontURI` is a module path in every real use, so the handler wants
  `sap.ui.require.toUrl( )` applied to it rather than taking a raw URL — that
  is what makes the registration portable across mount points, and it is
  exactly what the samples do.
- `registerFont` is idempotent per family in practice, but the handler should
  still be safe to call on every round-trip, since a port would issue it from
  its init branch.
- Registration must happen before the first view carrying such a URI renders;
  if the wire runs as an ordinary follow-up action that ordering needs
  checking, and a re-render after registration may be the simpler contract.

## Scope

Low priority: one port in a 622-port corpus is affected today, and the failure
is cosmetic (a missing glyph, not a broken view). It is filed because the gap is
a real capability boundary rather than a porting mistake, and because app 350's
deviation asserted it had been filed when it had not.
