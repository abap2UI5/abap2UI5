---
target: abaplint
title: 'Parser: COMMIT ENTITIES BEGIN ... END, CONVERT KEY OF and READ ENTITIES OPERATIONS'
summary: 'four EML statements are parser errors at v758 - COMMIT ENTITIES BEGIN/END, CONVERT KEY OF ... FROM ... TO, READ ENTITIES OPERATIONS; one addon keeps three classes under noIssues for it'
priority: low
state: open
first_seen: 2026-11-27
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/rap-ext, abaplint.jsonc and abaplint-cloud.jsonc (in place since 2026-10, still there after 11f2319): global.noIssues for three one-statement classes, "the dynamic EML statements abaplint cannot parse" - z2ui5_cl_rap_eml_key and z2ui5_cl_rap_eml_read are the two this item is about'
  - 'probed 2026-11-27 against abaplint main after 2.120.122, v758: parser_error for COMMIT ENTITIES BEGIN RESPONSES FAILED failed REPORTED reported., CONVERT KEY OF (entity_name) FROM pid TO key., COMMIT ENTITIES END., READ ENTITIES OPERATIONS operations FAILED failed REPORTED reported. - and for the static forms COMMIT ENTITIES BEGIN RESPONSE OF zi_root FAILED DATA(f) REPORTED DATA(r). and CONVERT KEY OF zi_root FROM pid TO DATA(key).'
  - 'the same probe: GET PERMISSIONS OPERATIONS and MODIFY ENTITIES OPERATIONS parse, so the third noIssues entry of rap-ext (z2ui5_cl_rap_eml_perm) is stale'
  - 'the dynamic forms in rap-ext were written from the keyword documentation and not verified on a system; the static BEGIN / END / CONVERT KEY forms are the safe part to start with'
---

# Parser: the long form of `COMMIT ENTITIES`, `CONVERT KEY`, dynamic `READ ENTITIES`

```abap
COMMIT ENTITIES BEGIN RESPONSE OF zi_root FAILED DATA(failed) REPORTED DATA(reported).
CONVERT KEY OF zi_root FROM pid TO DATA(key).
COMMIT ENTITIES END.

READ ENTITIES OPERATIONS operations FAILED failed REPORTED reported.
```

All four are parser errors. `statements/commit_entities.ts` has no
`BEGIN` / `END`, `convert.ts` no `KEY OF`, `read_entities.ts` no
`OPERATIONS`.

## Proposal

Add the forms, gated to the release of the other EML statements. Start with
the static ones; add the dynamic entity name and `RESPONSES` once a system
confirmed them.

## Must not change

Plain `COMMIT ENTITIES` and the existing `CONVERT` statements.

Related: `abaplint-downport-rap-eml` is about EML in the 7.02 downport, not
about parsing it.
