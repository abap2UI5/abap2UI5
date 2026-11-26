---
target: abap2ui5
title: 'Renamed installation: the BSP keeps the UI5 identity z2ui5 - two installations in one launchpad session'
summary: A renamed BSP keeps the UI5 identity of the original - component z2ui5.Component, sap.app.id z2ui5, the inbound z2ui5-display and the frontend modules z2ui5/core/* - so two installations of different versions in one launchpad session share one module cache; the docs say only one installation is ever loaded per page, which the launchpad does not guarantee; needs a launchpad test
priority: medium
state: open
first_seen: 2026-11-26
upstream: abap2UI5/abap2UI5
evidence:
  - 'abap2UI5 origin/main d6b0d4a4, npm run rename / rename-service.mjs with zabc and /ca2ui5/, 2026-11-26: lint green; renamed src/03/02/#ca2ui5#ui5.wapa.component.js line 18 UIComponent.extend("z2ui5.Component", ...), #ca2ui5#ui5.wapa.manifest.json "id": "z2ui5", inbound "z2ui5-display" with "semanticObject": "z2ui5", dataSource uri /sap/bc/ca2ui5/ui5 (renamed), index.html data-name="z2ui5", resourceroots { "z2ui5": "./" }'
  - 'tools/bsp_rename/README.md "What it deliberately keeps": the UI5 framework namespace z2ui5; docs advanced/renaming.md "The Frontend Namespace": "the frontend namespace lives inside one browser page, where only one abap2UI5 installation is ever loaded"'
---

# Renamed installation: the BSP keeps the UI5 identity `z2ui5`

## What happens

`build-rename` gives the BSP, its SICF nodes and the ICF handler the new name.
The handler and the data source point at the renamed backend. All of that
lints and is consistent.

What stays the same by design is the browser side:

- the component `z2ui5.Component` and `sap.app.id` `z2ui5`
- the inbound `z2ui5-display` (semanticObject `z2ui5`)
- the module namespace `z2ui5/core/*` of the frontend bundle the page loads
  (`?z2ui5-bundle`)

The docs justify this with "only one abap2UI5 installation is ever loaded" per
page. That holds for the standalone BSP URL. It is not guaranteed in the
**Fiori launchpad**, which is one page for the whole session. Take a user who
opens an app of installation A (version N) and then one of installation B
(version N+3), which the rename exists for. UI5's loader already holds
`z2ui5/Component` and `z2ui5/core/*` from A. Whether B then runs on A's
frontend code, or the launchpad reuses A's component, has not been tested. In
either case the frontend and backend versions of B no longer match, which
protocol 3 does not tolerate. A second launchpad tile also needs its own
semantic object (the BSP's inbound is the same for both).

## Proposed

1. Test it: two renamed installations of different versions, two tiles, both
   opened one after the other in one launchpad session.
2. If they collide, give a renamed BSP its own component id, and the frontend
   bundle a module prefix derived from the name (`tools/bsp_rename
   --with-namespace` already rewrites the namespace; the bundle would need the
   same). Alternatively, document that two installations in one launchpad need
   the launchpad to start apps in their own iframe (or not at all), and
   correct the sentence in renaming.md.
3. Rename the inbound's semantic object along with the BSP (`<name>`), so the
   target mappings of two installations do not clash.

## Reproduce

    npm run rename   # in abap2UI5 main
    grep -n 'extend(\|"id"\|semanticObject' .github/abaplint/output/**/src/03/02/*component.js .github/abaplint/output/**/src/03/02/*manifest.json
