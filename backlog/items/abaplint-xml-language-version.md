---
target: abaplint
title: 'Report an object whose XML carries another ABAP language version than the configuration'
summary: 'five .clas.xml of one addon had UNICODE 5 (ABAP for Cloud Development), eleven had X - CI green, the 702 branch shipped five Cloud classes to standard systems; abaplint takes the version from the configuration and never looks at the object'
priority: low
state: open
first_seen: 2026-11-27
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/layout-management 2a91e97, 2026-11: five .clas.xml (four samples and z2ui5_cl_layo_xml_builder) had <UNICODE>5</UNICODE>, the other eleven X; set to X by hand'
  - 'abaplint main 2026-11-27: only the downport rule reads the field (abaplint/abaplint#4735, the language version of an object becomes standard ABAP), so only under v702'
---

# The ABAP language version of an object against the configuration

abapGit keeps the language version of an object in its XML - `UNICODE` for
classes and interfaces (`X` standard, `5` ABAP for Cloud Development, `2` key
users), `ABAP_LANGU_VERSION` elsewhere. A class created in a Cloud project
and moved into a standard repository keeps its `5`, and a standard system
then activates it under the Cloud rules.

## Proposal

A rule (or an option of `xml_consistency`) that reports an object whose
language version differs from the one the configuration checks with - `5` or
`2` under a standard version, `X` under `Cloud`.

## Must not report

An object without the field; object types that carry no version. A
repository that mixes on purpose needs `exclude` or an option naming the
allowed values - what the default should be is the open design question.
