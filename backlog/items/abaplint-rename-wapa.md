---
target: abaplint
title: 'rename: BSP applications (WAPA)'
summary: abaplint cannot rename a BSP application (WAPA) - it blocks the namespace rename of custom-controls, custom-controls-customer and embed-excel today, and abap2UI5 renames its own BSP (src/03/02) with tools/bsp_rename as a workaround; upstream PR #4721 is open, the MIME folder half (#4722) merged after 2.120.120
priority: high
state: filed
filed: https://github.com/abaplint/abaplint/pull/4721
upstream: abaplint/abaplint
first_seen: 2026-11-26
checked_upstream: 2026-11-26
evidence:
  - 'abaplint 2.120.120 (the pin of abap2UI5 and of every addon, 2026-11-26): Renamer.factory knows CLAS, DTEL, DOMA, TABL, TTYP, INTF, PROG, MSAG, SICF - anything else throws "Renaming of <type> not yet supported"'
  - 'abap2UI5 main: rename.jsonc excludes src/03; .github/scripts/rename-service.mjs renames the BSP Z2UI5 (src/03/02, z2ui5.wapa.*) and its SICF nodes with tools/bsp_rename/rename-bsp.mjs - a second renamer in this repository that exists only because abaplint has none for WAPA'
  - 'audit 2026-11-26 (backlog item abap2ui5-addon-rename-gaps): custom-controls (BSP for the resource path z2ui5_cci), custom-controls-customer (BSP Z2UI5_CCC: 1 wapa, 2 sicf, 1 ui5repositorypathmapping at 65f5b4b) and embed-excel (a BSP) have no namespace rename because of it'
  - 'gh search 2026-11-26: abaplint/abaplint#4721 "rename WAPA: BSP applications" open (2026-11-25); #4722 "rename WAPA: the MIME folder of the application moves with it" merged 2026-11-25 19:46 UTC - after 2.120.120 was published (13:57 UTC), so no release carries it yet'
  - 'custom-controls DEV and custom-controls-customer DEV 2026-11-26: npm run rename (the shared .github/scripts/rename.mjs) now exists in both, with src/01 - the BSP and its ICF nodes - left out by package.json config.renameSkip and printed on every run; the literal c_ns that names the BSP resource root is kept (config.renameLiterals). abaplint renaming the ICF nodes but not the WAPA is why the whole package is left out rather than the WAPA alone'
---

# rename: BSP applications (WAPA)

## Why

The abap2UI5 ecosystem has to rename every repository into a customer
namespace (`ZMYUI5`, `/CA2UI5/`), so that two installations can sit in one
system. Four of them ship a BSP application:

| Repository | BSP | Today |
|---|---|---|
| abap2UI5 | `Z2UI5` (the launchpad app around the embed control) | renamed by `tools/bsp_rename`, a separate renamer that duplicates what abaplint does for SICF |
| custom-controls | the resource path `z2ui5_cci` | rename without the BSP (`src/01` in `config.renameSkip`) |
| custom-controls-customer | `Z2UI5_CCC` with two SICF nodes | rename without the BSP (`src/01` in `config.renameSkip`) |
| embed-excel | a BSP | **no rename** |

## Current behaviour

`abaplint --rename` with a pattern for `WAPA` stops with
`Renaming of WAPA not yet supported`.

## Proposed

#4721 (open): a WAPA renamer - the application name, the page and MIME file
names, the SICF nodes pointing at it, and (#4722, merged) its MIME folder.
Once released, abap2UI5 drops `tools/bsp_rename` from `build-rename`,
custom-controls and custom-controls-customer take `src/01` out of
`config.renameSkip` (and `c_ns` out of `config.renameLiterals`), and
embed-excel gets the shared `rename.mjs`.
