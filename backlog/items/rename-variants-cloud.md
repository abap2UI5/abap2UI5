---
target: abap2ui5
title: 'Namespace rename for ABAP Cloud - no renamed cloud branch, and the docs do not say how to do it by hand'
summary: build-rename builds rename_<name> and (since 2026-11-26) rename_<name>_702, but no renamed cloud - the service objects of cloud/src/03 (HTTP service, SCO2, SIA1/SIA6/SIA7, SUSH) have no renamer in abaplint or tools/bsp_rename; until they do, docs advanced/renaming.md has to tell a cloud user how to rename by hand
priority: low
state: open
first_seen: 2026-11-26
checked_upstream: 2026-11-26
upstream: abap2UI5/abap2UI5
evidence:
  - 'abap2UI5 origin/main d6b0d4a4, 2026-11-26: build-rename.yaml renamed main only; cloud/src/03 holds z2ui5.http.xml (HTTP service), z2ui5_http.sco2.xml, z2ui5_http_ibs.sia6.xml, z2ui5_bc.sia1.xml, z2ui5_iam_ext.sia6.xml, z2ui5_bc_0001.sia7.xml, a SUSH object and z2ui5_cl_ui5_icf_handler on if_http_service_extension - none is in abaplint''s renamer (2.120.120: CLAS, INTF, TABL, DTEL, DOMA, TTYP, PROG, MSAG, SICF) or in tools/bsp_rename'
  - 'abap2UI5 DEV 2026-11-26: the 702 half is built - build-rename.yaml pushes rename_<name>_702 (input with_702), the renamed tree run through npm run auto_downport. Tested locally: npm run rename (placeholder znamespace), the renamed src/ in a worktree, npm run auto_downport (check-generic-like and check-702 OK, drop-bsp), npx abaplint with the 702 config 0 issues over 193 files, rename-literal-gate over the downported tree OK'
  - 'the upstream renamers this needs: backlog items abaplint-rename-cloud-service-objects and abaplint-rename-authorization-objects'
---

# Namespace rename for ABAP Cloud

`rename_<name>` is the renamed installation for Standard ABAP from 7.50, and
`rename_<name>_702` the same tree downported for 7.02 to 7.4x (one
`build-rename` run builds both). ABAP Cloud (branch `cloud`) has none:

- `src/00`-`src/02` rename fine - they are the same code on `cloud` and are
  linted under the cloud profile already.
- The service package `cloud/src/03` cannot be renamed by a tool: an HTTP
  service, a communication scenario (SCO2), the IAM app and business catalog
  objects (SIA1/SIA6/SIA7) and a SUSH. abaplint has no renamer for these
  types, and `tools/bsp_rename` only knows WAPA/SICF/SMIM.

## What the docs need (abap2UI5/docs, advanced/renaming.md)

Until the renamers exist, a section "ABAP Cloud" that says:

1. Pull `rename_<name>` into a package of your own with abapGit (ADT). Its
   `src/03` is the Standard ABAP service (an ICF node, a BSP and a handler on
   `if_http_extension`); those objects do not import on ABAP Cloud - leave
   them out (or delete them after the pull). `src/00`-`src/02` is the whole
   renamed framework.
2. Create the handler class `<prefix>cl_ui5_icf_handler` on
   `if_http_service_extension` by hand; its one statement is
   `<prefix>cl_ui5_http_handler=>run( req = request res = response ).`
   (the handler of `cloud/src/03/01`, renamed).
3. Create an HTTP service in ADT (name: the new name, e.g. `ZMYUI5`) with
   that class as its handler, and open `/sap/bc/http/sap/<name>`.
4. For the launchpad: the IAM app, the business catalog and the
   communication scenario of `cloud/src/03` are created in ADT under the new
   name, the way `cloud/src/03` shows them. The names have length limits of
   their own (an IAM app and a business catalog take fewer characters than a
   class) - choose a short name.

## Proposed

- A `rename_<name>_cloud`: `src/00`-`02` renamed by `abaplint --rename`, and
  `cloud/src/03` renamed once abaplint renames HTTP, SCO2, SIA* and SUSH
  (the abaplint items above) - not by a text replacement here, which would be
  a second way to rename.
- Until then the doc section above.
