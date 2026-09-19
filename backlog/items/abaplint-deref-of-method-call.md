---
target: abaplint
title: 'Report `->*` applied to a method call or constructor expression'
summary: '`result = row_ref( name )->*.` is a syntax error on 7.50 — the dereferencing operator takes a reference VARIABLE, not the result of a functional call; abaplint parses the chain at v750 and the transpiler runs it'
priority: medium
state: open
first_seen: 2026-09-19
upstream: abaplint/abaplint
evidence:
  - abap2UI5 issue #2722 — a user on SAP_ABA 750 SP33 reported `ltcl_00_base~row` in `z2ui5_cl_ui5_srv_model` (`result = row_ref( iv_name )->*.`), green through abaplint at `syntax.version` v750 and through the transpiled unit run
  - gated in abap2UI5 since then by `npm run check:atc` (`deref_call`) — a `)` directly in front of a `->*`
  - measured 2026-09-19 on abaplint 2.120.52, `check_syntax` on, v750 — no finding on an isolated class carrying `lv = row( )->*.`
---

# Report `->*` applied to a method call or constructor expression

## What happens

```abap
result = row_ref( iv_name )->*.     " 7.50: syntax error
```

On 7.50 the dereferencing operator `->*` needs a **reference variable** on its
left; the result of a functional method call, a `NEW`/`CAST`/`REF`
constructor expression, or a table expression is not one. The kernel refuses
the statement; newer releases accept the chain, which is why nothing upstream
of a real 7.50 system notices.

```abap
DATA(lr_row) = row_ref( iv_name ).
result = lr_row->*.
```

## Why no existing rule catches it

The expression grammar allows `->*` after any `Source` producing a reference,
regardless of `syntax.version`. `downport` rewrites method chains into
temporaries for OLDER versions (v702), but at v750 the chain is left alone,
and the release-dependent part — that `->*` in particular is late to accept an
expression on its left — is not modelled.

## Proposed rule

Under `syntax.version` v750 and below (the exact release the kernel widened
this in is to be confirmed on a system; abap2UI5's report is SP33 of 7.50):
report `->*` whose left operand is not a plain reference variable (a
variable, field symbol, structure component or attribute). Ideally in
`downport`, which already knows how to hoist an expression into a `DATA( )`
temporary and could carry the quick fix.

## What it must NOT report

- `lr->*`, `<fs>->*`, `ls-ref->*`, `me->mr_data->*` — reference variables.
- `->*` under a `syntax.version` that accepts the chain (v754 and later, to
  be confirmed).

## Example

```abap
" bad
lv_value = get_ref( )->*.

" good
DATA(lr) = get_ref( ).
lv_value = lr->*.
```

<!-- probe:start — written by `npm run backlog:probe`, do not edit by hand -->

## Measured

`abaplint-deref-of-method-call.probe.mjs` — `)->*` — a call or constructor expression dereferenced inline, with `var->*` as the negative.
Run **2026-09-19** against `abap2UI5` (not checked out: samples, samples-controls, samples-stack).

**Would fire on 0 site(s)** in 0 repositories:

_none_

**Must NOT fire on 339 site(s)** that match the shape and are correct:

| Repository | Where | |
|---|---|---|
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:1034 | ASSIGN i_container_ref->* TO <parent_anytab>. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:1038 | ASSIGN is_parent_type-tab_item_buf->* TO <tab_item>. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:1042 | ASSIGN i_container_ref->* TO <parent_stdtab>. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:1047 | ASSIGN i_container_ref->* TO <parent_struc>. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:1054 | LOOP AT mr_nodes->* ASSIGNING <n> USING KEY array_index WHERE path = iv_path. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:1179 | ASSIGN i_container_ref->* TO <container>. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:1799 | ASSIGN iv_data->* TO <data>. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:2104 | LOOP AT mr_source_tree->* INTO ls_node USING KEY (lv_tab_key) WHERE path = iv_path. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:2147 | INSERT ls_node INTO TABLE mr_dest_tree->*. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:2224 | FIELD-SYMBOLS <item> LIKE LINE OF mr_source_tree->*. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:2227 | LOOP AT mr_source_tree->* ASSIGNING <item> WHERE path = iv_path. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:2244 | INSERT ls_renamed_node INTO TABLE mr_dest_tree->*. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:2319 | ASSIGN lr_buf->* TO <from>. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:2326 | ASSIGN lr_buf->* TO <to>. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.testclasses.abap`:3697 | ASSIGN lr_utclong->* TO <utclong>. |
| abap2UI5 | `src/00/02/z2ui5_cl_srt_aunit.clas.abap`:52 | ASSIGN ref_variable2->* TO <variable2>. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:1065 | ASSIGN val->* TO <any>. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:1077 | ASSIGN from->* TO <from>. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:1086 | ASSIGN result->* TO <result>. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:1367 | INSERT lr_comp->* INTO TABLE result. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:1448 | ASSIGN val->* TO <unassign>. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:1461 | ASSIGN val->* TO <unassign>. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:1537 | SPLIT lr_param->* AT `=` INTO DATA(lv_name) DATA(lv_value). |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:1610 | ASSIGN result->* TO FIELD-SYMBOL(<variable>). |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:1924 | ASSIGN ir_tab->* TO <tab>. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:2214 | ASSIGN lr_data->* TO <val>. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:2672 | ASSIGN class->* TO <class>. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:2775 | ASSIGN ddic_ref->* TO <ddic>. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:3059 | ASSIGN lr_tab->* TO <tab>. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:3071 | ASSIGN lr_tab->* TO <tab>. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.testclasses.abap`:160 | ASSIGN lr_copy->* TO <copy>. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.testclasses.abap`:492 | ASSIGN lr_tab->* TO <tab>. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.testclasses.abap`:508 | ASSIGN lr_back->* TO <back>. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.testclasses.abap`:600 | ASSIGN lr_filled->* TO <val>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:125 | ASSIGN result->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:143 | ASSIGN mr_elem->* TO <elem>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:272 | ASSIGN io_app->mr_handle_tab->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:368 | act = lo_parsed->mt_attri->*[ name = `MV_STRING` ]-name_client ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:386 | LOOP AT lo_parsed->mt_attri->* TRANSPORTING NO FIELDS WHERE srtti_data IS NOT INITIAL. "#EC CI_SORTSEQ |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:396 | LOOP AT lo_parsed->mt_attri->* TRANSPORTING NO FIELDS WHERE srtti_data IS NOT INITIAL. "#EC CI_SORTSEQ |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:585 | ASSIGN lo_app->mo_inner->mr_shared->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:598 | ASSIGN lo_app_2->mr_handle_tab->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:677 | cl_abap_unit_assert=>assert_not_bound( lo_loaded->mt_attri->*[ name = `MO_ANY->MT_TABLE->*` ]-o_typedescr ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:689 | cl_abap_unit_assert=>assert_false( xsdbool( line_exists( lo_loaded->mt_attri->*[ name = `MO_ANY->MT_TABLE->*` ] ) ) ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:741 | LOOP AT mo_cont->mt_attri->* TRANSPORTING NO FIELDS WHERE srtti_data IS NOT INITIAL. "#EC CI_SORTSEQ |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:771 | ASSIGN mo_user->mo_inner->mr_shared->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:783 | ASSIGN mo_user->mr_handle_tab->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:789 | LOOP AT lo_loaded->mt_attri->* TRANSPORTING NO FIELDS WHERE srtti_data IS NOT INITIAL. "#EC CI_SORTSEQ |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:824 | LOOP AT mo_cont->mt_attri->* REFERENCE INTO DATA(lr_attri) "#EC CI_SORTSEQ |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:959 | ASSIGN mo_user->mr_handle_tab->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_client.clas.testclasses.abap`:928 | ASSIGN mo_action->ms_next-r_data->* TO <data>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_client.clas.testclasses.abap`:1339 | lr_attri = REF #( mo_action->mo_app->mt_attri->*[ name = `MV_NAME` ] ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_client.clas.testclasses.abap`:1374 | lr_attri = REF #( mo_action->mo_app->mt_attri->*[ name = `MV_NAME` ] ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_client.clas.testclasses.abap`:1432 | lr_attri = REF #( lo_cont_db->mt_attri->*[ name = `MV_NAME` ] OPTIONAL ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_frontend.clas.abap`:230 | iv_val  = lr_arg->* ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_handler.clas.testclasses.abap`:194 | ASSIGN mo_caller->mr_tab->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_handler.clas.testclasses.abap`:207 | ASSIGN mo_caller->mr_tab->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_handler.clas.testclasses.abap`:235 | ASSIGN mr_tab->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_handler.clas.testclasses.abap`:244 | ASSIGN mr_tab->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_handler.clas.testclasses.abap`:1382 | READ TABLE lo_handler->mo_action->mo_app->mt_attri->* REFERENCE INTO DATA(lr_attri) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.abap`:131 | ASSIGN ms_config-tab->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.abap`:323 | READ TABLE mo_app->mt_attri->* REFERENCE INTO DATA(lr_ref_attri) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:109 | mr_value->* = `typed-ref`. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:113 | ASSIGN mr_tab->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:304 | ASSIGN mo_app->mr_tab->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:331 | LOOP AT mo_cont->mt_attri->* TRANSPORTING NO FIELDS WHERE name = `MV_VALUE` AND bind = abap_true. "#EC CI_SORTSEQ |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:502 | ASSIGN mo_app->mr_tab->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:596 | ASSIGN mo_app->mr_tab->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:614 | ASSIGN mo_app->mr_tab->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:433 | LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:506 | LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri) "#EC CI_SORTSEQ |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:517 | ASSIGN lr_ref->* TO FIELD-SYMBOL(<val>). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:603 | LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)   "#EC CI_SORTSEQ |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:623 | LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)   "#EC CI_SORTSEQ |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:672 | ASSIGN lr_ref->* TO FIELD-SYMBOL(<live>). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:701 | <live> = attri_srtti_parse( lr_attri->* ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:745 | ASSIGN lr_parent->* TO <parent>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:761 | LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)   "#EC CI_SORTSEQ |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:769 | READ TABLE mt_attri->* REFERENCE INTO DATA(lr_up) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:806 | READ TABLE mt_attri->* REFERENCE INTO DATA(lr_attri_parent) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:874 | LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)   "#EC CI_SORTSEQ |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:894 | ASSIGN <dref>->* TO <val_deref>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:913 | LOOP AT mt_attri->* TRANSPORTING NO FIELDS USING KEY parent |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:951 | ASSIGN lr_dref->ref->* TO <dref>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:982 | LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri) "#EC CI_SORTSEQ |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1085 | READ TABLE mt_attri->* REFERENCE INTO DATA(lr_hit) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1128 | LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)   "#EC CI_SORTSEQ |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1292 | IF mt_attri->* IS NOT INITIAL |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1293 | AND NOT line_exists( mt_attri->*[ check_dissolved = abap_false ] ). "#EC CI_SORTSEQ |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1331 | LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)   "#EC CI_SORTSEQ |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1349 | ASSIGN lr_ref->* TO <ref>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1493 | LOOP AT mt_attri->* REFERENCE INTO DATA(lr_child) USING KEY parent |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1510 | IF mt_attri->* IS INITIAL. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1513 | INSERT LINES OF lt_init INTO TABLE mt_attri->*. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1518 | LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)   "#EC CI_SORTSEQ |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1564 | INSERT LINES OF lt_attri_new INTO TABLE mt_attri->*. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1574 | LOOP AT mt_attri->* REFERENCE INTO DATA(lr_bound)   "#EC CI_SORTSEQ |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1576 | INSERT lr_bound->* INTO TABLE lt_attri. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1578 | CLEAR mt_attri->*. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1583 | READ TABLE mt_attri->* REFERENCE INTO DATA(lr_attri) WITH TABLE KEY name = lr_old->name. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1639 | ASSIGN lr_ref_d->* TO <delta_tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1669 | ASSIGN lr_work_row->* TO <work_row>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1763 | ASSIGN ir_comp->* TO <comp>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1814 | ASSIGN ir_comp->* TO <comp>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1847 | ASSIGN ir_before->* TO <before>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1871 | ASSIGN ir_comp->* TO <sub_tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1933 | ASSIGN ir_comp->* TO <comp>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1987 | ASSIGN ir_ref->* TO <val>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:2042 | ASSIGN lr_ref->* TO FIELD-SYMBOL(<val>). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:2052 | ASSIGN lr_before->* TO <before>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:310 | mr_typed_tab->* = VALUE #( ( col1 = `typed` col2 = 7 ) ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:312 | mr_typed_struc->* = VALUE #( col1 = `typed-struc` col2 = 8 ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:314 | mr_typed_elem->* = `typed-elem`. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:333 | ASSIGN mr_handle_tab->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:342 | ASSIGN mr_handle_struc->* TO <row>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:347 | ASSIGN mr_elem->* TO <elem>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:355 | ASSIGN mr_shared_a->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:388 | ASSIGN mr_handle_nested->* TO <row>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:400 | ASSIGN ms_with_dref-r_tab->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:408 | <row_ref>-r_elem->* = `cell-ref`. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:460 | ASSIGN mt_table->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:499 | ASSIGN mt_data->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:792 | ASSIGN mo_app->ms_with_dref-r_tab->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:805 | DATA(lv_attri_xml) = z2ui5_cl_ui5_util_context=>xml_stringify( mr_attri->* ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:816 | IMPORTING any = mr_attri->* ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:853 | result = lr_row->*. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:859 | READ TABLE mr_attri->* REFERENCE INTO result WITH TABLE KEY name = iv_name. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:868 | result = xsdbool( line_exists( mr_attri->*[ name = iv_name ] ) ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:879 | LOOP AT mr_attri->* REFERENCE INTO DATA(lr_attri). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:904 | LOOP AT mr_attri->* REFERENCE INTO DATA(lr_attri). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:978 | LOOP AT mr_attri->* REFERENCE INTO DATA(lr_attri) "#EC CI_SORTSEQ |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1076 | cl_abap_unit_assert=>assert_false( xsdbool( line_exists( mr_attri->*[ check_dissolved = abap_false ] ) ) ). "#EC CI_SORTSEQ |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1128 | LOOP AT mr_attri->* TRANSPORTING NO FIELDS "#EC CI_SORTSEQ |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1168 | LOOP AT mr_attri->* REFERENCE INTO DATA(lr_attri). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1177 | cl_abap_unit_assert=>assert_false( xsdbool( line_exists( mr_attri->*[ check_dissolved = abap_false ] ) ) ). "#EC CI_SORTSEQ |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1191 | LOOP AT mr_attri->* REFERENCE INTO DATA(lr_attri). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1199 | cl_abap_unit_assert=>assert_false( xsdbool( line_exists( mr_attri->*[ check_dissolved = abap_false ] ) ) ). "#EC CI_SORTSEQ |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1210 | LOOP AT mr_attri->* TRANSPORTING NO FIELDS "#EC CI_SORTSEQ |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1289 | DATA(lv_rows) = lines( mr_attri->* ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1293 | act = lines( mr_attri->* ) ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1487 | kind            = lo_descr->kind ) INTO TABLE mr_attri->*. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1546 | ASSIGN mo_app->mr_elem->* TO <elem>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1924 | ASSIGN mo_app->mr_elem->* TO <elem>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1974 | DATA(ls_extra) = lr_attri->*. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1977 | INSERT ls_extra INTO TABLE mr_attri->*. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2101 | APPEND VALUE #( col1 = `second` ) TO mo_app->mr_typed_tab->*. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2102 | APPEND VALUE #( col1 = `third` ) TO mo_app->mr_typed_tab->*. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2108 | CLEAR mo_app->mr_typed_tab->*. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2110 | ASSIGN mo_app->mr_typed_tab->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2114 | act = mo_app->mr_typed_tab->*[ 3 ]-col1 ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2241 | ASSIGN mo_app->mr_handle_tab->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2438 | act = mo_app->mt_rows_ref[ 1 ]-r_elem->* ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2634 | ASSIGN mo_app->mr_handle_tab->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2637 | ASSIGN mo_app->ms_with_dref-r_tab->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2641 | act = mo_app->mr_typed_elem->* ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2647 | act = mo_app->mt_rows_ref[ 1 ]-r_elem->* ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2657 | ASSIGN mo_app->mr_handle_nested->* TO <nested>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2677 | ASSIGN mo_app->mo_inner->mr_shared->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2688 | ASSIGN mo_app->mr_shared_a->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2722 | ASSIGN lr_val->* TO <val>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2755 | ASSIGN lo_app->mr_table->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2773 | cl_abap_unit_assert=>assert_not_initial( lr_attri->*[ name = `MZ_INNER->MR_SHARED` ]-srtti_data ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2774 | cl_abap_unit_assert=>assert_initial( lr_attri->*[ name = `MR_TABLE` ]-srtti_data ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2777 | DATA(lv_attri_xml) = z2ui5_cl_ui5_util_context=>xml_stringify( lr_attri->* ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2783 | IMPORTING any = lr_attri->* ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2861 | DATA(lv_attri_xml) = z2ui5_cl_ui5_util_context=>xml_stringify( mr_attri->* ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2867 | IMPORTING any = mr_attri->* ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2875 | name_client     = `/MV_GONE` ) INTO TABLE mr_attri->*. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2879 | srtti_data      = `payload of a reference nobody has` ) INTO TABLE mr_attri->*. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2884 | name_ref        = `MR_SHARED_B->*` ) INTO TABLE mr_attri->*. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2905 | DATA(lv_attri_xml) = z2ui5_cl_ui5_util_context=>xml_stringify( mr_attri->* ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2911 | IMPORTING any = mr_attri->* ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2912 | DELETE mr_attri->* WHERE name = `MV_XSTR`. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2951 | DATA(lv_attri_xml) = z2ui5_cl_ui5_util_context=>xml_stringify( lr_attri->* ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2957 | IMPORTING any = lr_attri->* ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2965 | cl_abap_unit_assert=>assert_not_bound( lr_attri->*[ name = `MO_APP->MO_LAYOUT->MV_INNER` ]-o_typedescr ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2977 | cl_abap_unit_assert=>assert_false( xsdbool( line_exists( lr_attri->*[ name = `MO_APP->MT_TABLE->*` ] ) ) ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3001 | DATA(lv_attri_xml) = z2ui5_cl_ui5_util_context=>xml_stringify( lr_attri->* ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3007 | IMPORTING any = lr_attri->* ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3024 | lv_attri_xml = z2ui5_cl_ui5_util_context=>xml_stringify( lr_attri->* ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3030 | IMPORTING any = lr_attri->* ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3082 | ASSIGN mo_app->mr_handle_tab->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3122 | ASSIGN mo_app->mr_handle_tab->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3172 | ASSIGN mo_app->mr_ref_ref->* TO <inner>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3174 | ASSIGN <inner>->* TO <elem>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3183 | ASSIGN mo_app->mr_ref_ref->* TO <inner>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3186 | ASSIGN <inner>->* TO <elem>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3214 | ASSIGN lr_own->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3249 | ASSIGN mo_app->mr_shared_a->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3315 | ASSIGN lr_new->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3323 | ASSIGN mo_app->mr_elem->* TO <elem>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3348 | ASSIGN mo_app->mr_shared_a->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3351 | ASSIGN mo_app->mr_elem->* TO <elem>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3358 | ASSIGN mo_app->mr_shared_a->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3375 | ASSIGN mo_app->mr_elem->* TO <elem>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3392 | ASSIGN mo_app->mr_elem->* TO <elem>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3400 | ASSIGN mo_app->mr_elem->* TO <elem>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3413 | LOOP AT mr_attri->* TRANSPORTING NO FIELDS WHERE srtti_data IS NOT INITIAL. "#EC CI_SORTSEQ |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3417 | DATA(lt_rows) = mr_attri->*. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3422 | LOOP AT mr_attri->* TRANSPORTING NO FIELDS WHERE srtti_data IS NOT INITIAL. "#EC CI_SORTSEQ |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3433 | act = lines( mr_attri->* ) ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3570 | ASSIGN lo_app->mr_alias->* TO <struc>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3580 | DATA(lv_attri_xml) = z2ui5_cl_ui5_util_context=>xml_stringify( lr_attri->* ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3586 | IMPORTING any = lr_attri->* ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3673 | ASSIGN lo_app->mr_a->* TO <tab>. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3680 | LOOP AT lr_attri->* REFERENCE INTO DATA(lr_alias) "#EC CI_SORTSEQ |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3689 | DATA(lv_attri_xml) = z2ui5_cl_ui5_util_context=>xml_stringify( lr_attri->* ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3695 | IMPORTING any = lr_attri->* ). |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:1492 | ASSIGN val->* TO <any>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:1504 | ASSIGN from->* TO <from>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:1509 | ASSIGN result->* TO <result>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:1803 | ASSIGN lr_row->* TO FIELD-SYMBOL(<row>). |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:1831 | DATA(lv_name) = c_trim_upper( lr_col->* ). |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:1845 | ASSIGN result->* TO <tab>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:1850 | SPLIT lr_rows->* AT `;` INTO TABLE lt_cols. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:1854 | ASSIGN lr_row->* TO FIELD-SYMBOL(<row>). |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:1859 | <field> = lr_col->*. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:1984 | APPEND lr_incl_comp->* TO result. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:1989 | APPEND lr_comp->* TO result. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:2046 | APPEND lr_comp->* TO result. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:2107 | ASSIGN table->* TO <table>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:2199 | ASSIGN val->* TO <unassign>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:2208 | ASSIGN val->* TO <unassign>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:2259 | SPLIT lr_param->* AT `=` INTO DATA(lv_name) DATA(lv_value). |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:2312 | ASSIGN result->* TO FIELD-SYMBOL(<variable>). |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:2447 | INSERT lr_comp->* INTO TABLE result. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:2980 | ASSIGN ir_tab->* TO <tab>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:3490 | ASSIGN lr_copy->* TO <tab_copy>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:3512 | ASSIGN result->* TO <result>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4151 | ASSIGN class->* TO <class>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4222 | ASSIGN ddic_ref->* TO <ddic>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4504 | ASSIGN r->* TO <any>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4643 | ASSIGN lr_tab->* TO FIELD-SYMBOL(<tab2>). |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4657 | ASSIGN lr_tab->* TO <tab2>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.testclasses.abap`:1326 | ASSIGN lr_result->* TO <tab>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.testclasses.abap`:1336 | ASSIGN lr_result->* TO <tab>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.testclasses.abap`:1346 | ASSIGN lr_result->* TO <tab>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.testclasses.abap`:1360 | ASSIGN lr_result->* TO <tab>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.testclasses.abap`:1376 | ASSIGN lr_result->* TO <tab>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.testclasses.abap`:1703 | ASSIGN lr_ref->* TO <val>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.testclasses.abap`:2008 | ASSIGN lr_result->* TO <tab>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.testclasses.abap`:2017 | ASSIGN lr_result->* TO <tab>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:947 | ASSIGN dfies->* TO <dfies>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1026 | ASSIGN lr_ddfields->* TO <ddfields>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1281 | ASSIGN lr_shlp->* TO <shlp>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1316 | ASSIGN lr_t_shlp->* TO <shlp2>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1337 | ASSIGN mr_data->* TO <any>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1390 | ASSIGN lr_shlp->* TO <shlp>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1432 | ASSIGN mt_data->* TO <fs_target_tab>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1444 | ASSIGN lr_line->* TO FIELD-SYMBOL(<fs_line>). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1484 | ASSIGN ms_data_row->* TO <any>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1516 | ASSIGN mt_data->* TO <tab>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1540 | ASSIGN ms_data_row->* TO FIELD-SYMBOL(<row>). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1632 | ASSIGN r_e071k->* TO <e071>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1640 | ASSIGN r_e071k->* TO <t_e071k>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1641 | ASSIGN r_e071->* TO <t_e071>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1698 | ASSIGN t_e071k->* TO <t_e071k>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1699 | ASSIGN s_e071k->* TO <s_e071k>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1752 | ASSIGN ir_data->* TO <tab>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1797 | ASSIGN t_e071->* TO <t_e071>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1798 | ASSIGN s_e071->* TO <s_e071>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1868 | ASSIGN lo_tab->* TO <table>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1869 | ASSIGN lo_line->* TO <line>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1980 | ASSIGN lo_tab->* TO <table>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1981 | ASSIGN lo_line->* TO <line>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2042 | ASSIGN ir_data->* TO <tab>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2180 | ASSIGN lr_filter->* TO <filter>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2185 | ASSIGN lr_rline->* TO <rline>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2195 | ASSIGN lr_rline->* TO <rline>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2205 | ASSIGN lr_rline->* TO <rline>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2215 | ASSIGN lr_rline->* TO <rline>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2228 | ASSIGN lr_rline->* TO <rline>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2236 | ASSIGN lr_headers->* TO <headers>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2349 | ASSIGN lr_filter->* TO <filter>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2353 | ASSIGN lr_rline->* TO <rline>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2362 | ASSIGN lr_rline->* TO <rline>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2371 | ASSIGN lr_rline->* TO <rline>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2550 | ASSIGN lr_handles->* TO <handles>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2553 | ASSIGN lr_single->* TO <single>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2555 | ASSIGN lr_msgh->* TO <msgh>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2557 | ASSIGN lr_msg->* TO <msg>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2669 | ASSIGN lr_log->* TO <log>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2678 | ASSIGN lr_handle->* TO <handle>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2696 | ASSIGN lr_handles->* TO <handles>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2792 | ASSIGN lr_handles->* TO <handles>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2872 | ASSIGN lr_filter->* TO <filter>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2958 | ASSIGN lr_objects->* TO <objects>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2961 | ASSIGN lr_header->* TO <header>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3034 | ASSIGN ls_prop->* TO <prop>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3086 | ASSIGN lr_data->* TO <tab>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3260 | ASSIGN lr_header->* TO <header>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3333 | ASSIGN lr_headers->* TO <headers>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3416 | ASSIGN lr_exc->* TO <exc>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3490 | ASSIGN lr_settings->* TO <settings>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3494 | ASSIGN lr_sysline->* TO <sysline>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3499 | ASSIGN lr_cofile->* TO <cofile>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3606 | ASSIGN lr_msg->* TO <msg>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3661 | ASSIGN lr_filter->* TO <filter>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3664 | ASSIGN lr_headers->* TO <headers>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3679 | ASSIGN result->* TO <handles>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3697 | ASSIGN result->* TO <filter>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3728 | ASSIGN lr_line->* TO <line>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3892 | ASSIGN lr_enq->* TO <lt_enq>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4006 | ASSIGN lr_enq->* TO <lt_enq>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4008 | ASSIGN lr_row->* TO <ls_enq>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4233 | ASSIGN lr_body->* TO <body>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4235 | ASSIGN lr_line->* TO <line>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4432 | ASSIGN lr_cds_tab->* TO <cds_tab>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4491 | ASSIGN lr_headers->* TO <headers>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4492 | ASSIGN lr_positions->* TO <positions>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4696 | lr_value->* = ls_lock_param-value. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.abap`:206 | ASSIGN lr_tab->* TO FIELD-SYMBOL(<tab2>). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.abap`:220 | ASSIGN lr_tab->* TO <tab2>. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.testclasses.abap`:166 | ASSIGN lr_data->* TO FIELD-SYMBOL(<failed>). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.testclasses.abap`:174 | ASSIGN lr_row->* TO FIELD-SYMBOL(<row>). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.testclasses.abap`:244 | ASSIGN lr_data->* TO FIELD-SYMBOL(<reported>). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.testclasses.abap`:341 | ASSIGN lr_data->* TO FIELD-SYMBOL(<failed>). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.testclasses.abap`:349 | ASSIGN lr_row->* TO FIELD-SYMBOL(<row>). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_range.clas.abap`:184 | ASSIGN me->mr_range->* TO <lt_range>. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_data.clas.abap`:31 | ASSIGN mr_data->* TO <data>. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_data.clas.abap`:58 | ASSIGN r_result->mr_data->* TO <data>. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_table.clas.abap`:49 | ASSIGN mr_tab->* TO <tab_out>. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_table.clas.testclasses.abap`:91 | ASSIGN lo_pop->mr_tab->* TO <tab>. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_to_select.clas.abap`:89 | ASSIGN mr_tab_popup->* TO <tab_out>. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_to_select.clas.abap`:188 | ASSIGN mr_tab->* TO <tab>. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_to_select.clas.abap`:197 | ASSIGN mr_tab_popup->* TO <tab_out>. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_to_select.clas.abap`:198 | ASSIGN mr_tab_popup_backup->* TO <tab_out2>. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_to_select.clas.abap`:202 | ASSIGN lr_row->* TO <row2>. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_to_select.clas.abap`:227 | ASSIGN mr_tab_popup->* TO <tab>. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_to_select.clas.abap`:228 | ASSIGN ms_result-table->* TO <table_result>. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_to_select.clas.abap`:229 | ASSIGN ms_result-row->* TO <row_result>. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_to_select.clas.abap`:269 | ASSIGN mr_tab_popup->* TO <tab_out>. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_to_select.clas.abap`:270 | ASSIGN mr_tab_popup_backup->* TO <tab_out_backup>. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_to_select.clas.testclasses.abap`:118 | ASSIGN lo_pop->mr_tab->* TO <tab>. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_to_select.clas.testclasses.abap`:238 | ASSIGN io_pop->mr_tab_popup->* TO <lt_pop>. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_to_select.clas.testclasses.abap`:256 | ASSIGN lo_pop->mr_tab_popup->* TO <lt_pop>. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_to_select.clas.testclasses.abap`:279 | ASSIGN ls_result-table->* TO <lt_result>. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_to_select.clas.testclasses.abap`:323 | ASSIGN lo_pop->mr_tab_popup->* TO <lt_pop>. |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:15234 | DATA(ls_prop) = st_ns_map[ n = lr_ns->* ]. |

**Where the detector is an approximation of the rule:**

- Every ordinary `ref->*` on a line counts as one negative; the negatives show how common the legal form is next to the reported one.
- The #2722 site was repaired, so the current tree is expected to answer 0.

<!-- probe:end -->
