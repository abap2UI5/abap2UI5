---
target: abaplint
title: 'rename: ABAP Cloud service objects (HTTP service, SCO2, SIA1, SIA6, SIA7)'
summary: abaplint renames none of the ABAP Cloud objects that publish a service - HTTP service, communication scenario, IAM app, business catalog and its app assignment - so abap2UI5 has no renamed cloud installation (cloud/src/03); a cloud user renames by hand today
priority: high
state: open
upstream: abaplint/abaplint
first_seen: 2026-11-26
checked_upstream: 2026-11-26
evidence:
  - 'abaplint 2.120.120 Renamer.factory: no HTTP, SCO2, SIA1, SIA6, SIA7'
  - 'abap2UI5 main, cloud/src/03: z2ui5.http.xml, z2ui5_http.sco2.xml, z2ui5_http_ibs.sia6.xml (01), z2ui5_bc.sia1.xml, z2ui5_iam_ext.sia6.xml, z2ui5_bc_0001.sia7.xml (02) - build-rename builds rename_<name> and rename_<name>_702 but no cloud variant (backlog item rename-variants-cloud)'
  - 'gh search 2026-11-26 (repo:abaplint/abaplint: "rename HTTP service", "rename SIA6"): nothing - #4717/#4718 are the classic SICF node'
  - 'abap2ui5-local DEV 2026-11-26: the shared rename.mjs on a checkout of the cloud branch renames z2ui5_cl_abap2ui5_local (10 files, 0 issues), but src/01 z2ui5_service_http.http.xml, z2ui5_service_http_http.sco2.xml and z2ui5_service_http_http_ibs.sia6.xml keep naming the original class - check_rename.yaml / build_rename.yaml therefore cover standard and 702 only'
---

# rename: ABAP Cloud service objects

## Why

Every repository of the abap2UI5 ecosystem has to be renameable, on every
target it ships for. abap2UI5 ships ABAP Cloud as the branch `cloud`, whose
`src/03` is the cloud form of the service: an HTTP service with its handler
class, the communication scenario it belongs to, an IAM app and a business
catalog. `src/00`-`02` rename fine; these do not.

## Proposed

Renamers that follow each other:

- `HTTP` (HTTP service): its name, the handler class (a CLAS rename the
  service has to follow) and the URL `/sap/bc/http/sap/<name>`;
- `SCO2` (communication scenario): its name and the inbound service it lists;
- `SIA6` (IAM app): its name and the service it authorizes; `SIA1` (business
  catalog) and `SIA7` (catalog to app assignment, `<catalog>_<nnnn>`).

The IAM names are short (SIA1 and SIA6 take fewer characters than a class), so
the name map of `abaplint-rename-authorization-objects` applies here too.
