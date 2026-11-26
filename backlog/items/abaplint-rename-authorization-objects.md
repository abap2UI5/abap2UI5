---
target: abaplint
title: 'rename: authorization objects, fields and default values (SUSO, AUTH, SUSH)'
summary: abaplint renames none of SUSO, AUTH and SUSH, nor the AUTHORITY-CHECK OBJECT/ID literals that name them - it blocks the namespace rename of config-management (Z2UI5_CONF / Z2UI5_CTYP), rfc-connector and samples-stack (SUSH) and of abap2UI5's cloud service package (a SUSH) today; the 10-character limit of SUSO/AUTH needs a name map, not a prefix
priority: high
state: open
upstream: abaplint/abaplint
first_seen: 2026-11-26
checked_upstream: 2026-11-26
evidence:
  - 'abaplint 2.120.120 Renamer.factory: no SUSO, AUTH, SUSH (abaplint/abaplint#2934 "bug: renaming of AUTH reference", closed 2023, was about a reference, not about renaming the object)'
  - 'audit 2026-11-26 (backlog item abap2ui5-addon-rename-gaps): config-management - authorization object Z2UI5_CONF and field Z2UI5_CTYP, at most 10 characters, so no longer prefix fits; rfc-connector - SUSH objects'
  - 'samples-stack origin/main 7538290: src/07/01/9914e9cf825a17215b92f08ac321afht.sush.xml (the APC service); abap2UI5 cloud/src/03/01/1782d97775fb5801cef397bb74b1dcht.sush.xml (the HTTP service)'
  - 'gh search 2026-11-26 (repo:abaplint/abaplint: "rename AUTH", "rename SUSO", "rename SUSH"): only #2934'
  - 'samples-stack DEV 2026-11-26: src/07 left out of npm run rename (config.renameSkip), its SUSH among the reasons; abap2ui5-local DEV 2026-11-26: check_rename.yaml renames the branches standard and 702 only - the cloud branch carries 22f9b5d5b22bd68daedaf6608d5bb7ht.sush.xml next to its HTTP service'
---

# rename: authorization objects, fields and default values

## Why

Every repository of the abap2UI5 ecosystem has to be renameable. Blocked:

- **config-management** - authorization object `Z2UI5_CONF`, field
  `Z2UI5_CTYP`.
- **rfc-connector**, **samples-stack**, abap2UI5's **cloud** service package -
  SUSH (authorization default values of a service), whose file name is a hash
  and whose content names the service it belongs to.

## Proposed

- `SUSO` and `AUTH` renamers, with the references in ABAP: `AUTHORITY-CHECK
  OBJECT 'Z2UI5_CONF' ID 'Z2UI5_CTYP' FIELD ...` - literals, so the renamer
  rewrites exactly these operands.
- Both are limited to **10 characters**, so a prefix pattern cannot work
  (`z2ui5_conf` is already 10): the rename needs an explicit name map
  (`oldName -> newName` per object) next to the patterns.
- `SUSH`: follow the rename of the object it belongs to (an ICF/HTTP service,
  an APC application) - the head entry names it - and keep the file name.
