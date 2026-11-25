---
target: abap2ui5-linter
title: 'Report a REF TO data attribute of an app that is not PUBLIC'
summary: 'a protected or private `TYPE REF TO data` attribute of a z2ui5_if_app class whose target has a type built at runtime makes the draft fail on a system (APP_SERIALIZATION_ERROR, CX_REFERENCE_NOT_SERIALIZABLE) - and private-app-attribute recommends PROTECTED for exactly this case'
priority: high
state: filed
filed: https://github.com/abap2UI5/linter/pull/197
first_seen: 2026-11-25
checked_upstream: 2026-11-25
evidence:
  - 'abap2UI5-addons/table-maintenance 9c8f911: z2ui5_cl_tm_pop got a PROTECTED `DATA mr_row_org TYPE REF TO data`, filled by `CREATE DATA mr_row_org LIKE <row>` for a row of a table built with RTTI. Every first roundtrip of the popup on a system (S/4, release 816, 2026-11-25) failed: APP_SERIALIZATION_ERROR - "Please check if all generic data references are public attributes of your class", CX_XSLT_SERIALIZATION_ERROR / CX_REFERENCE_NOT_SERIALIZABLE "The (Anonymous) data object referenced has only got a technical type", ABAP_POSITION {O:...\CLASS=Z2UI5_CL_TM_POP}-MR_ROW_ORG. Fixed in ca6da36 by making it PUBLIC'
  - 'the repository gates (abaplint, @abap2ui5/linter 0.11.x, the transpiled unit runtime) passed: no rule looks at the visibility of a REF TO data attribute, the transpiled serializer accepts the reference, and private-app-attribute''s remedy says "PROTECTED for a helper"'
  - 'z2ui5_cl_ui5_srv_model serializes the generic data references of PUBLIC attributes itself (dissolve / main_attri_db_save_srtti, S-RTTI); a non-public one is left to CALL TRANSFORMATION, which refuses a technical type'
---

# Report a REF TO data attribute of an app that is not PUBLIC

```abap
CLASS zcl_app DEFINITION PUBLIC.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
  PROTECTED SECTION.
    DATA mr_row TYPE REF TO data.      " CREATE DATA mr_row LIKE <row_of_rtti_table>
ENDCLASS.
```

## Motivation

abap2UI5 writes the app into the draft after every roundtrip. A `REF TO
data` whose target has a type built at runtime (`CREATE DATA ... TYPE HANDLE`,
`LIKE` a field symbol of such a table) can only be written by the
framework's own S-RTTI handling, which covers PUBLIC attributes. Anywhere
else `CALL TRANSFORMATION` meets a technical type and the request fails -
on a system only; the transpiled runtime and the unit tests pass.

## Proposal

A rule `nonpublic-data-reference`: an instance attribute `TYPE REF TO data`
(or a structure / table holding one) in the PROTECTED or PRIVATE section of a
class implementing `z2ui5_if_app` is reported (warning; an error when the
class contains a `CREATE DATA` into it with `TYPE HANDLE` or `LIKE`). The
remedy of `private-app-attribute` must not suggest PROTECTED for a `REF TO
data` attribute.
