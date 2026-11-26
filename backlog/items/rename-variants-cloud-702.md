---
target: abap2ui5
title: 'Namespace rename exists for main only - no renamed cloud or 702 installation'
summary: build-rename renames main only - there is no renamed variant of the branches cloud (HTTP service, SCO2, SIA1/SIA6/SIA7 and SUSH objects neither abaplint nor tools/bsp_rename renames) and 702, so a renamed installation exists for Standard ABAP 7.50+ only
priority: low
state: open
first_seen: 2026-11-26
upstream: abap2UI5/abap2UI5
evidence:
  - 'abap2UI5 origin/main d6b0d4a4, 2026-11-26: build-rename.yaml checks out main and renames src/ (rename.jsonc excludes src/03, rename-service.mjs renames it); cloud/src/03 holds z2ui5.http.xml (HTTP service), z2ui5_http.sco2.xml, z2ui5_http_ibs.sia6.xml, z2ui5_bc.sia1.xml, z2ui5_iam_ext.sia6.xml, z2ui5_bc_0001.sia7.xml, a SUSH object and z2ui5_cl_ui5_icf_handler on if_http_service_extension - none is in abaplint''s renamer (CLAS, INTF, TABL, DTEL, DOMA, TTYP, PROG, MSAG, SICF) or in tools/bsp_rename'
  - 'origin/702 and origin/cloud carry no build-rename workflow; changelog 1.151.0: the frontend branches standard_<name> are not built any more - there was never a cloud_<name>'
---

# Namespace rename exists for `main` only

`rename_<name>` is the whole installation for Standard ABAP from 7.50. These
users get no renamed installation:

- **ABAP Cloud (branch `cloud`).** `src/00`-`src/02` rename fine (they are
  linted under the cloud profile already). The service package
  `cloud/src/03` cannot be renamed: an HTTP service, a communication scenario,
  IAM app and business catalog objects, and a SUSH. abaplint has no renamer
  for these types, and `tools/bsp_rename` only knows WAPA/SICF/SMIM. Since the
  objects are created in ADT on a cloud system anyway, a cloud user can rename
  `src/` by hand today and create the service themselves - but nothing tells
  them how.
- **7.02 (branch `702`).** It is the downport of main. A renamed 702 would be
  the downport of `rename_<name>`, or `build-rename` running on `702` (which
  has no `src/03`).

## Proposed

- 702: let `auto_downport` (or a `build-rename` input `target: 702`) produce
  `rename_<name>_702` from the renamed tree. The downport does not care about
  the prefix, as long as the 25+5 length budget holds.
- cloud: a `rename_<name>_cloud` with `src/00`-`02` renamed and
  `cloud/src/03` renamed by a text replacement in the XML (the names are short:
  `z2ui5_http`, `z2ui5_bc`, ...; check the SIA/SCO2 length limits first). At
  least, document the manual way in docs advanced/renaming.md.
