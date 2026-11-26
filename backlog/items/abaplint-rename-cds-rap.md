---
target: abaplint
title: 'rename: CDS and RAP objects (DDLS, BDEF, SRVD, SRVB)'
summary: abaplint renames none of DDLS, BDEF, SRVD and SRVB, nor the references to them in ABAP (SELECT FROM, EML, TYPE TABLE FOR ...) - it blocks the namespace rename of rap-ext (two CDS views) and samples-stack (14 DDLS, 9 BDEF, a service definition and binding) today
priority: high
state: open
upstream: abaplint/abaplint
first_seen: 2026-11-26
checked_upstream: 2026-11-26
evidence:
  - 'abaplint 2.120.120 Renamer.factory: no DDLS, BDEF, SRVD, SRVB'
  - 'audit 2026-11-26 (backlog item abap2ui5-addon-rename-gaps): rap-ext - two CDS views (DDLS), no namespace rename'
  - 'samples-stack origin/main 7538290: 14 ddls, 9 bdef, z2ui5_sd_smps_tck.srvd.xml, z2ui5_sb_smps_tck.srvb.xml (src/05/01); classes reference them in SELECT, EML (MODIFY/READ ENTITIES OF) and derived types - no rename (backlog item samples-rename-semantics)'
  - 'gh search 2026-11-26 (repo:abaplint/abaplint: "rename DDLS", "rename CDS"): nothing'
---

# rename: CDS and RAP objects

## Why

Every repository of the abap2UI5 ecosystem has to be renameable. Two are
blocked by CDS/RAP objects:

- **rap-ext** - two CDS views.
- **samples-stack** - RAP packages (`src/03`, `src/04`, `src/05`, ...):
  root view entities `Z2UI5_R_SMPS_*`, their behavior definitions, a service
  definition and binding.

## Proposed

Renamers for `DDLS`, `BDEF`, `SRVD`, `SRVB` (in that order of need):

- DDLS: the entity name (`define view entity`), the SQL view name where there
  is one (16 characters), associations and `select from` of other renamed
  entities, and the ABAP references (`SELECT ... FROM`, `TYPE`, `READ
  ENTITIES OF`, `TYPE TABLE FOR CREATE`, ...);
- BDEF: its name (= the root entity), `implementation in class` (a renamed
  class), the draft table and persistent table names, `with draft;` targets;
- SRVD/SRVB: `expose <entity>`, the binding's service definition.

The parser already reads DDLS and BDEF, so the references are known.
