---
target: abaplint
title: 'Report `GET REFERENCE OF … INTO` under the Cloud language version'
summary: 'the statement is not released for ABAP Cloud and has a released equivalent (`REF`), yet abaplint 2.120.52 under `syntax.version` Cloud accepts it without a finding — `check:cloud` in abap2UI5 is green with it in place'
priority: low
state: open
first_seen: 2026-09-19
upstream: abaplint/abaplint
evidence:
  - abap2UI5, 2026-08/09 — the cloud-readiness pass that turned bare Open SQL literals into host expressions (#2657) also had to find every `GET REFERENCE OF` by hand: `npm run check:cloud` (abaplint with the Cloud language version) and the transpiled unit run were both green with the three in `z2ui5_cl_ui5_srv_model` in place; abap-check §3 carries the case
  - 25 statements in six files under abap2UI5 `src/` still carry it (2026-09-19), all in vendored mirrors (`src/00`) or the frozen package (`src/99`) — the probe beside this item counts them
  - measured 2026-09-19 on abaplint 2.120.52, `syntax.version` Cloud, `check_syntax` on: `GET REFERENCE OF lv INTO lr` in an isolated class produces no finding. The grammar has the statement as `verNotLang(LanguageVersion.KeyUser)` — excluded for KeyUser only, not for Cloud
---

# Report `GET REFERENCE OF … INTO` under the Cloud language version

## What happens

```abap
GET REFERENCE OF lv_value INTO lr_ref.     " not released for ABAP Cloud
lr_ref = REF #( lv_value ).                " the released spelling
```

ABAP Cloud does not release `GET REFERENCE`; the ADT syntax check on a cloud
system reports it, and a class carrying it cannot be imported there. abaplint
run with `syntax.version: Cloud` — which is what `check:cloud` in abap2UI5
is — says nothing, so the migration to the released spelling had to be done
by grep.

## Why no existing rule catches it

`GetReference.getMatcher()` is `verNotLang(LanguageVersion.KeyUser, …)`:
the statement is excluded for the Key User language version only. Under
Cloud it parses as a normal statement, and `cloud_types` / `check_syntax`
have nothing to say about it. The bundle's `obsolete_statement` list does not
include it either — for on-premise it is indeed only old-fashioned, not
obsolete.

## Proposed rule

Mark the statement as not available under `LanguageVersion.Cloud` as well
(`verNotLang` for both), so `parser_error` / `check_syntax` report it there.
Nothing changes for on-premise syntax versions.

The quick fix `x = REF #( … )` is mechanical only when the target is
concretely typed — see `abaplint-ref-into-generic-target` beside this item
for the case where it is not; the message should say `REF #( )` for a typed
target and `REF data( )` for a generic one, or carry no fix.

## What it must NOT report

- anything under an on-premise `syntax.version` — `GET REFERENCE` is valid
  there and `REF #( )` needs 7.40 SP08 (the `downport` rule goes the other
  way).

## Example

```abap
" bad (syntax.version Cloud)
GET REFERENCE OF ls_row INTO lr_row.

" good
lr_row = REF #( ls_row ).
```

<!-- probe:start — written by `npm run backlog:probe`, do not edit by hand -->

## Measured

`abaplint-get-reference-obsolete.probe.mjs` — GET REFERENCE OF, with the REF constructor as the negative.
Run **2026-09-19** against `abap2UI5` (not checked out: samples, samples-controls, samples-stack).

**Would fire on 25 site(s)** in 1 repository:

| Repository | Where | |
|---|---|---|
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:502 | GET REFERENCE OF <item> INTO lr_stack_top. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:914 | GET REFERENCE OF c_container INTO lr_ref. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:915 | GET REFERENCE OF it_nodes INTO mr_nodes. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:1094 | GET REFERENCE OF <field> INTO lr_target_field. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:2088 | GET REFERENCE OF it_source_tree INTO mr_source_tree. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:2089 | GET REFERENCE OF et_dest_tree INTO mr_dest_tree. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:2210 | GET REFERENCE OF it_source_tree INTO mr_source_tree. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:2211 | GET REFERENCE OF et_dest_tree INTO mr_dest_tree. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.testclasses.abap`:3154 | GET REFERENCE OF lv_foo INTO lr_foo. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.testclasses.abap`:3185 | GET REFERENCE OF lv_foo INTO ls_struc-r. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.testclasses.abap`:5610 | GET REFERENCE OF ls_data-str INTO ls_refs-dref. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.testclasses.abap`:5613 | GET REFERENCE OF ls_data-int INTO ls_refs-dref. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.testclasses.abap`:5659 | GET REFERENCE OF ls_data-itab INTO ls_refs-dref. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:1517 | GET REFERENCE OF val INTO result. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.testclasses.abap`:1663 | GET REFERENCE OF lv_val INTO lr_ref. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.testclasses.abap`:1675 | GET REFERENCE OF lv_val INTO lr_ref. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.testclasses.abap`:1687 | GET REFERENCE OF lv_val INTO lr_ref. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.testclasses.abap`:1694 | GET REFERENCE OF lv_val INTO lr_ref. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3904 | GET REFERENCE OF lv_client INTO ls_param-value. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3908 | GET REFERENCE OF lv_name INTO ls_param-value. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3912 | GET REFERENCE OF lv_uname INTO ls_param-value. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3917 | GET REFERENCE OF <lt_enq> INTO ls_param-value. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4050 | GET REFERENCE OF lv_check_upd INTO ls_param-value. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4055 | GET REFERENCE OF lv_subrc INTO ls_param-value. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4060 | GET REFERENCE OF <lt_enq> INTO ls_param-value. |

**Must NOT fire on 118 site(s)** that match the shape and are correct:

| Repository | Where | |
|---|---|---|
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:1099 | result = REF #( val ). |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.testclasses.abap`:154 | DATA(lr_text) = REF #( lv_text ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:236 | bind( ir_val  = REF #( mo_user->mv_string ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:238 | bind( ir_val  = REF #( mo_user->mt_std ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:244 | bind( ir_val  = REF #( mo_user->mo_inner->mv_inner ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:658 | bind( ir_val  = REF #( mo_user->mv_string ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:683 | ir_val  = REF #( mo_user->mv_string ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:872 | bind( ir_val  = REF #( mo_user->mv_string ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:924 | bind( ir_val  = REF #( mo_user->mv_string ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:970 | bind( ir_val  = REF #( mo_user->mt_std ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_client.clas.testclasses.abap`:1339 | lr_attri = REF #( mo_action->mo_app->mt_attri->*[ name = `MV_NAME` ] ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_client.clas.testclasses.abap`:1374 | lr_attri = REF #( mo_action->mo_app->mt_attri->*[ name = `MV_NAME` ] ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_client.clas.testclasses.abap`:1432 | lr_attri = REF #( lo_cont_db->mt_attri->*[ name = `MV_NAME` ] OPTIONAL ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.abap`:170 | lr_ref_in = REF #( <ele> ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:212 | result = REF #( <row>-name ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:342 | act = bind( ir_val    = REF #( mo_app->ms_deep-input ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:345 | act = bind( ir_val    = REF #( mo_app->mv_value ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:348 | act = bind( ir_val    = REF #( mo_app->mv_value ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:358 | expect_bind_error( ir_val    = REF #( lv_local ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:413 | is_config = VALUE #( tab           = REF #( mo_app->mt_tab ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:427 | is_config = VALUE #( tab           = REF #( mo_app->mt_tab ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:435 | is_config = VALUE #( tab           = REF #( mo_app->mt_tab ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:446 | is_config = VALUE #( tab       = REF #( mo_app->mt_tab ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:450 | is_config = VALUE #( tab       = REF #( mo_app->mt_tab ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:462 | act = bind( ir_val    = REF #( <row>-job ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:463 | is_config = VALUE #( tab       = REF #( mo_app->mt_tab ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:472 | is_config = VALUE #( tab       = REF #( mo_app->mt_tab ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:477 | is_config = VALUE #( tab                  = REF #( mo_app->mt_tab ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:490 | act = bind( ir_val    = REF #( <row>-name ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:491 | is_config = VALUE #( tab       = REF #( mo_app->mo_obj->mt_tab ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:510 | act = bind( ir_val    = REF #( <name> ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:524 | expect_bind_error( ir_val    = REF #( mo_app->ms_deep-input ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:525 | is_config = VALUE #( tab       = REF #( mo_app->ms_deep ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:534 | is_config = VALUE #( tab       = REF #( mo_app->mt_tab ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:543 | expect_bind_error( ir_val    = REF #( mo_app->mv_other ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:544 | is_config = VALUE #( tab       = REF #( mo_app->mt_tab ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:552 | expect_bind_error( ir_val    = REF #( mo_app->mt_strings[ 1 ] ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:553 | is_config = VALUE #( tab       = REF #( mo_app->mt_strings ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:569 | is_config = VALUE #( tab       = REF #( mo_app->mt_tab ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:572 | act = bind( ir_val    = REF #( <row>-name ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:573 | is_config = VALUE #( tab       = REF #( mo_app->mo_obj->mt_tab ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:577 | is_config = VALUE #( tab       = REF #( mo_app->mt_tab ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:582 | expect_bind_error( ir_val    = REF #( <row>-name ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:583 | is_config = VALUE #( tab       = REF #( mo_app->mt_tab ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:601 | act = bind( ir_val    = REF #( <name> ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:608 | lr_old_cell = REF #( <name> ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:621 | act = bind( ir_val    = REF #( <name> ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:680 | bind( ir_val    = REF #( mo_app->mv_value ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:716 | bind( ir_val    = REF #( mo_app->mv_value ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:718 | bind( ir_val    = REF #( mo_app->mv_value ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:720 | bind( ir_val    = REF #( mo_app->mv_value ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:735 | bind( ir_val    = REF #( mo_app->mv_value ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:754 | bind( ir_val    = REF #( mo_app->mv_value ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:757 | DATA(lv_path) = bind( ir_val    = REF #( mo_app->mv_value ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:768 | bind( ir_val    = REF #( mo_app->mv_value ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:771 | expect_bind_error( ir_val    = REF #( mo_app->mv_value ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:779 | bind( ir_val    = REF #( mo_app->mv_value ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:783 | expect_bind_error( ir_val    = REF #( mo_app->mv_value ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:791 | expect_bind_error( ir_val    = REF #( mo_app->mv_value ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:798 | expect_bind_error( ir_val    = REF #( mo_app->mv_value ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:806 | bind( ir_val    = REF #( mo_app->mv_value ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:824 | bind( ir_val    = REF #( mo_app->ms_deep ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:839 | bind( ir_val    = REF #( mo_app->mt_tab ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:854 | bind( ir_val    = REF #( mo_app->ms_deep ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:849 | <parent_ref> = REF data( <source_ref> ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:885 | ref  = REF #( <dref> ) ) INTO TABLE lt_dref. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1058 | result = REF #( <attri> ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1711 | ir_comp     = REF #( <comp> ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1712 | ir_before   = REF #( <before> ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:279 | result = REF #( mv_protected ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:350 | mr_alias_struc = REF #( ms_flat ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:351 | mr_alias_tab   = REF #( mt_std ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:370 | mo_inner_2->mr_shared = REF #( mt_std ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:934 | DATA(lr_flat) = REF #( mo_app->ms_flat ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:935 | DATA(lr_std)  = REF #( mo_app->mt_std ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1151 | DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1352 | DATA(lr_val) = REF #( mo_app->mv_string ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1381 | cl_abap_unit_assert=>assert_true( xsdbool( mo_model->attri_get_val_ref( `MV_STRING` ) = REF #( mo_app->mv_string ) ) ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1383 | cl_abap_unit_assert=>assert_true( xsdbool( mo_model->attri_get_val_ref( `MO_INNER->MV_INNER` ) = REF #( mo_app->mo_inner->mv_inner ) ) ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1385 | cl_abap_unit_assert=>assert_true( xsdbool( mo_model->attri_get_val_ref( `MS_DEEP-L1-L2-L3-V4` ) = REF #( mo_app->ms_deep-l1-l2-l3-v4 ) ) ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1386 | cl_abap_unit_assert=>assert_true( xsdbool( mo_model->attri_get_val_ref( `MR_TYPED_STRUC->COL1` ) = REF #( mo_app->mr_typed_struc->col1 ) ) ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1440 | lo_app->mr_alias = REF #( lo_app->ms_data ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1443 | DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1466 | DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1690 | DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3112 | DATA(lr_row) = REF #( mo_app->mo_inner->mt_own[ 1 ] ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3113 | DATA(lv_path) = lo_bind->main( val    = REF #( lr_row->col1 ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3114 | config = VALUE #( tab       = REF #( mo_app->mo_inner->mt_own ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3127 | lv_path = lo_bind->main( val    = REF #( <cell> ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3211 | mo_app->mr_alias_tab = REF #( mo_app->mo_inner->mt_own ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3245 | DATA(lr_own_tab) = REF #( mo_app->mo_inner->mt_own ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3462 | lo_late->mr_shared = REF #( mo_app->mt_std ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3483 | DATA(lr_std) = REF #( mo_app->mt_std ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3488 | lr_std = REF #( mo_app->mt_std ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3540 | mr_alias = REF #( ms_nested ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3598 | DATA(lr_struc) = REF #( lo_app->ms_nested ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3643 | mr_a   = REF #( ma_tab ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3644 | mr_b   = REF #( ma_tab ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3700 | DATA(lr_tab) = REF #( lo_app->ma_tab ). |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:1651 | DATA(lr_filter) = REF #( result[ name = name ] ). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_range.clas.testclasses.abap`:45 | ir_range     = REF #( lt_range ) ). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_range.clas.testclasses.abap`:58 | ir_range     = REF #( lt_range ) ). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_range.clas.testclasses.abap`:73 | ir_range     = REF #( lt_range ) ). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_range.clas.testclasses.abap`:88 | ir_range     = REF #( lt_range ) ). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_range.clas.testclasses.abap`:103 | ir_range     = REF #( lt_range ) ). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_range.clas.testclasses.abap`:118 | ir_range     = REF #( lt_range ) ). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_range.clas.testclasses.abap`:133 | ir_range     = REF #( lt_range ) ). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_range.clas.testclasses.abap`:148 | ir_range     = REF #( lt_range ) ). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_range.clas.testclasses.abap`:163 | ir_range     = REF #( lt_range ) ). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_range.clas.testclasses.abap`:178 | ir_range     = REF #( lt_range ) ). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_range.clas.testclasses.abap`:193 | ir_range     = REF #( lt_range ) ). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_range.clas.testclasses.abap`:208 | ir_range     = REF #( lt_range ) ). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_range.clas.testclasses.abap`:224 | ir_range     = REF #( lt_range ) ). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_range.clas.testclasses.abap`:239 | ir_range     = REF #( lt_range ) ). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_range.clas.testclasses.abap`:254 | ir_range     = REF #( lt_range ) ). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_range.clas.testclasses.abap`:371 | ir_range     = REF #( lt_range ) ). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_range.clas.testclasses.abap`:384 | DATA(lv_sql1) = NEW z2ui5_cl_util_range( iv_fieldname = `CARRID` ir_range = REF #( lt_r1 ) )->get_sql( ). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_range.clas.testclasses.abap`:385 | DATA(lv_sql2) = NEW z2ui5_cl_util_range( iv_fieldname = `CONNID` ir_range = REF #( lt_r2 ) )->get_sql( ). |

**Where the detector is an approximation of the rule:**

- The rule is only about the Cloud language version; the count says how much a repository would have to rewrite to pass it, not that anything is wrong on-premise.
- abap2UI5 keeps its remaining sites in vendored mirrors (src/00) and the frozen package (src/99) on purpose - those follow their upstreams.

<!-- probe:end -->
