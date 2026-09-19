---
target: abaplint
title: 'Report a method call as the operand of `CREATE DATA … TYPE HANDLE`'
summary: '`CREATE DATA lr TYPE HANDLE cl_abap_structdescr=>create( comps )` is "No method can be specified in the current position" on a system — the operand has to be a variable holding the descriptor; abaplint parses the call as an expression and says nothing'
priority: medium
state: open
first_seen: 2026-09-19
upstream: abaplint/abaplint
evidence:
  - abap2UI5, 2026-09-02 — `ltcl_app_shapes` in `z2ui5_cl_ui5_srv_model` shipped `CREATE DATA lr TYPE HANDLE cl_abap_structdescr=>create( lt_comp )` through abaplint and the transpiled unit run, and a user's system reported the syntax error on activation
  - gated in abap2UI5 since then by `npm run check:atc` (`handle_call`, `.github/scripts/extended-check-gate.mjs`) — a repository-local regex, which is the shape this backlog exists to replace
  - measured 2026-09-19 on abaplint 2.120.52, `check_syntax` on, v750 and Cloud — no finding on an isolated class carrying the statement, while control probes in the same file are reported
---

# Report a method call as the operand of `CREATE DATA … TYPE HANDLE`

## What happens

```abap
CREATE DATA lr_data TYPE HANDLE cl_abap_structdescr=>create( lt_components ).
```

The kernel refuses the class with *"No method can be specified in the current
position"*: the `TYPE HANDLE` operand is a **data object** holding an RTTS
descriptor, not an expression. The transpiler evaluates the call and carries
on, so the test class ran green on the transpiled runtime and failed on the
first real system.

```abap
DATA(lo_struct) = cl_abap_structdescr=>create( lt_components ).
CREATE DATA lr_data TYPE HANDLE lo_struct.
```

## Why no existing rule catches it

abaplint's `CreateData` statement takes `Source` after `TYPE HANDLE`, and a
functional method call is a valid `Source` everywhere else — the grammar is
wider than the kernel's here. No rule narrows it, and `check_syntax` resolves
the call successfully because the method exists.

## Proposed rule

In `check_syntax`, or as a small standalone rule: report `CREATE DATA … TYPE
HANDLE <operand>` (and `CREATE OBJECT … TYPE HANDLE`, same restriction)
whose operand is a method call or a constructor expression rather than a
plain data object (a variable, a field symbol, a structure component, a
dereferenced reference).

Quick fix: none that does not choose a variable name — the message names the
remedy, "assign the descriptor to a variable first".

## What it must NOT report

- `TYPE HANDLE lo_type`, `TYPE HANDLE <fs>`, `TYPE HANDLE ls_meta-type`,
  `TYPE HANDLE lr_type->*` — all data objects.
- `CREATE DATA lr TYPE (lv_name)` — the dynamic form, no `HANDLE`.

## Example

```abap
" bad
CREATE DATA lr TYPE HANDLE cl_abap_structdescr=>create( lt_comp ).

" good
DATA(lo_type) = cl_abap_structdescr=>create( lt_comp ).
CREATE DATA lr TYPE HANDLE lo_type.
```

<!-- probe:start — written by `npm run backlog:probe`, do not edit by hand -->

## Measured

`abaplint-type-handle-method-call.probe.mjs` — a CREATE DATA/OBJECT … TYPE HANDLE operand that is a call, with the plain variable operand as the negative.
Run **2026-09-19** against `abap2UI5` (not checked out: samples, samples-controls, samples-stack).

**Would fire on 0 site(s)** in 0 repositories:

_none_

**Must NOT fire on 46 site(s)** that match the shape and are correct:

| Repository | Where | |
|---|---|---|
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:993 | CREATE DATA rs_node_type-tab_item_buf TYPE HANDLE lo_ddescr. |
| abap2UI5 | `src/00/02/z2ui5_cl_srt_aunit.clas.abap`:50 | CREATE DATA ref_variable2 TYPE HANDLE rtti2. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:1609 | CREATE DATA result TYPE HANDLE lo_datadescr. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:2768 | CREATE DATA ddic_ref TYPE HANDLE struct_descr. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.testclasses.abap`:491 | CREATE DATA lr_tab TYPE HANDLE lo_tab. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:124 | CREATE DATA result TYPE HANDLE lo_tab. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_handler.clas.testclasses.abap`:234 | CREATE DATA mr_tab TYPE HANDLE lo_tab. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:112 | CREATE DATA mr_tab TYPE HANDLE lo_tab. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:613 | CREATE DATA mo_app->mr_tab TYPE HANDLE lo_tab. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:332 | CREATE DATA mr_handle_tab TYPE HANDLE lo_tab. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:341 | CREATE DATA mr_handle_struc TYPE HANDLE lo_struc. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:354 | CREATE DATA mr_shared_a TYPE HANDLE lo_tab. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:387 | CREATE DATA mr_handle_nested TYPE HANDLE lo_nested. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:399 | CREATE DATA ms_with_dref-r_tab TYPE HANDLE lo_tab. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:459 | CREATE DATA mt_table TYPE HANDLE lo_tab. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:498 | CREATE DATA mt_data TYPE HANDLE lo_tab. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2754 | CREATE DATA lo_app->mr_table TYPE HANDLE lo_tab. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3213 | CREATE DATA lr_own TYPE HANDLE lo_tab. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3314 | CREATE DATA lr_new TYPE HANDLE lo_tab. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:1844 | CREATE DATA result TYPE HANDLE o_table_desc. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:1851 | CREATE DATA lr_row TYPE HANDLE struc. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:2311 | CREATE DATA result TYPE HANDLE lo_datadescr. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:2931 | CREATE DATA result TYPE HANDLE gr_dyntable_typ. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:3508 | CREATE DATA result TYPE HANDLE lo_tabledescr. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4220 | CREATE DATA ddic_ref TYPE HANDLE struct_desrc. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:945 | CREATE DATA dfies TYPE HANDLE new_table_desc. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1428 | CREATE DATA mt_data TYPE HANDLE tabdescr. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1438 | CREATE DATA ms_data_row TYPE HANDLE strucdescr. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1443 | CREATE DATA lr_line TYPE HANDLE strucdescr. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1695 | CREATE DATA t_e071k TYPE HANDLE table_desc. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1696 | CREATE DATA s_e071k TYPE HANDLE struct_desc. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1794 | CREATE DATA t_e071 TYPE HANDLE table_desc_new. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1795 | CREATE DATA s_e071 TYPE HANDLE struct_desc_new. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1865 | CREATE DATA lo_tab TYPE HANDLE new_table_desc. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1866 | CREATE DATA lo_line TYPE HANDLE new_struct_desc. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1977 | CREATE DATA lo_tab TYPE HANDLE new_table_desc. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1978 | CREATE DATA lo_line TYPE HANDLE new_struct_desc. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3085 | CREATE DATA lr_data TYPE HANDLE lo_table. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4431 | CREATE DATA lr_cds_tab TYPE HANDLE lo_table_c. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.testclasses.abap`:165 | CREATE DATA lr_data TYPE HANDLE lo_top_struct. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.testclasses.abap`:173 | CREATE DATA lr_row TYPE HANDLE lo_row_struct. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.testclasses.abap`:243 | CREATE DATA lr_data TYPE HANDLE lo_top. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.testclasses.abap`:340 | CREATE DATA lr_data TYPE HANDLE lo_top_struct. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.testclasses.abap`:348 | CREATE DATA lr_row TYPE HANDLE lo_row_struct. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_to_select.clas.abap`:194 | CREATE DATA mr_tab_popup TYPE HANDLE ls_sel_tab_type-tabledescr. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_to_select.clas.abap`:195 | CREATE DATA mr_tab_popup_backup TYPE HANDLE ls_sel_tab_type-tabledescr. |

**Where the detector is an approximation of the rule:**

- Line-based: a statement whose operand continues on the next line is not read. The one incident was on one line.
- The 2026-09-02 site was repaired the same day, so the current tree is expected to answer 0.

<!-- probe:end -->
