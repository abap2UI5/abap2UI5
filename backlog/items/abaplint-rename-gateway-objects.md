---
target: abaplint
title: 'rename: SAP Gateway objects (IWPR, IWSV, IWMO, IWOM, IWSG, G4BA)'
summary: abaplint renames no Gateway object - project, service, model, the service and model groups, and the V4 service group (G4BA) - it blocks the namespace rename of launchpad-kpi (a SEGW project and its service) and the OData V4 package of samples-stack today
priority: high
state: open
upstream: abaplint/abaplint
first_seen: 2026-11-26
checked_upstream: 2026-11-26
evidence:
  - 'abaplint 2.120.120 Renamer.factory: no IWPR, IWSV, IWMO, IWOM, IWSG, G4BA'
  - 'audit 2026-11-26 (backlog item abap2ui5-addon-rename-gaps): launchpad-kpi - the Gateway project and service (IWPR, IWSV, IWMO, IWOM, IWSG) are not renameable, and the service name is in the OData URL'
  - 'samples-stack origin/main 7538290: src/05/01/z2ui5_sb_smps_tck.g4ba.xml next to its service binding'
  - 'gh search 2026-11-26 (repo:abaplint/abaplint: "rename IWSV", "rename gateway"): nothing'
---

# rename: SAP Gateway objects

## Why

Every repository of the abap2UI5 ecosystem has to be renameable.
**launchpad-kpi** serves its KPI tiles through a SEGW project; the project,
its service, model and the generated MPC/DPC classes belong together, and
abaplint renames only the classes. **samples-stack** has a V4 service group
(`G4BA`).

## Proposed

One renamer family that keeps the Gateway set consistent:

- `IWPR` (project) -> its `IWSV` (service, technical name and version),
  `IWMO` (model), `IWOM` (model to service assignment), `IWSG` (service
  group, the activation in /IWFND/MAINT_SERVICE), with the MPC/DPC class names
  the project generates (already CLAS renames, so the project XML has to
  follow them);
- `G4BA` with the service binding it groups.

The OData URL changes with the service name - a consumer's tile or app has to
follow, which is the consumer's part, not abaplint's.
