---
target: abaplint
title: 'Report `REF #( )` assigned to a generically typed target'
summary: '`<fs> = REF #( x )` where `<fs>` is `TYPE any` (or `data`, or a field symbol bound by a dynamic ASSIGN) is "Unexpected operator REF" on a system — `#` infers the reference type from the target, and a generic target has none; abaplint 2.120.52 accepts it under every syntax version'
priority: high
state: open
first_seen: 2026-09-19
upstream: abaplint/abaplint
evidence:
  - abap2UI5, 2026-09 — three `GET REFERENCE OF` in `z2ui5_cl_ui5_srv_model` (`attri_get_val_ref`, the alias re-wiring on the load) were rewritten to `REF #( )`; two of them came back from a user's system the same day as "Unexpected operator REF", because the left side is a field symbol `TYPE any` after a dynamic `ASSIGN`
  - both were repaired as `REF data( … )`; abap-check §3 carries the case
  - measured 2026-09-19 on abaplint 2.120.52 with `check_syntax` on, at `syntax.version` v750 and again under Cloud — an isolated class carrying `<any> = REF #( lv )` after `ASSIGN lr->* TO <any>` produces no finding while the same run reports the control probes in the same file
---

# Report `REF #( )` assigned to a generically typed target

## What happens

```abap
FIELD-SYMBOLS <val> TYPE any.
ASSIGN lr_data->* TO <val>.
<val> = REF #( lv_source ).        " system: Unexpected operator REF
```

`REF #( )` takes its reference type from the **target** of the assignment. A
field symbol `TYPE any` (or `TYPE data`, or one bound by a dynamic `ASSIGN`
with no static type) has nothing to infer from, and the kernel refuses the
statement outright. The spelling that works names the type itself:

```abap
<val> = REF data( lv_source ).     " or REF ty_concrete( … )
```

The defect only shows on a system. abaplint parses `REF #( )` as a
constructor expression without asking what the target can supply, and the
transpiler runs it, so it went through every gate abap2UI5 has — and it was
INTRODUCED by a cleanup, a rewrite of `GET REFERENCE OF` into the modern
spelling, which is exactly the direction a linter pushes people in.

## Why no existing rule catches it

`check_syntax` resolves `REF #( )` but does not carry the rule that `#` needs
an inferable target type. `downport` rewrites `REF #( )` into
`GET REFERENCE OF` for older syntax versions and is silent at v750 and above.
`cloud_types` and `fully_type_itabs` are about declarations, not this
expression. Measured (see evidence): zero findings at v750 and under Cloud.

## Proposed rule

In `check_syntax` (it is a syntax error, not a style question): report a
`REF #( … )` whose assignment target is generically typed — a field symbol or
parameter declared with a generic type (`any`, `data`, `simple`, `clike`,
`csequence`, `numeric`, `xsequence`, `c`, `n`, `x`, `p`, `any table`,
`index table`, `standard table`, `sorted table`, `hashed table`), or a field
symbol declared inline by an `ASSIGN` whose source type is itself generic.

The quick fix is mechanical: `REF #(` → `REF data(` (the type that is always
assignable to a generic target; where the target is a typed reference the
rule does not fire in the first place).

## What it must NOT report

- `lr = REF #( x )` into a variable declared `TYPE REF TO data` or
  `TYPE REF TO ty` — the target is typed, the inference works.
- `REF #( )` as an actual parameter or inside a `VALUE`/`NEW` constructor,
  where the formal parameter or component supplies the type.
- `<fs> = REF data( x )` / `REF ty( x )` — already the remedy.
- a field symbol declared `TYPE REF TO data` — concretely typed, only its
  target is generic.

## Example

```abap
" bad
FIELD-SYMBOLS <any> TYPE any.
ASSIGN lr_ref->* TO <any>.
<any> = REF #( lv_value ).

" good
<any> = REF data( lv_value ).
```

<!-- probe:start — written by `npm run backlog:probe`, do not edit by hand -->

## Measured

`abaplint-ref-into-generic-target.probe.mjs` — REF #( ) assigned to a generically typed target, with the typed target as the negative.
Run **2026-09-19** against `abap2UI5` (not checked out: samples, samples-controls, samples-stack).

**Would fire on 0 site(s)** in 0 repositories:

_none_

**Must NOT fire on 39 site(s)** that match the shape and are correct:

| Repository | Where | |
|---|---|---|
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:1099 | result = REF #( val ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:683 | ir_val  = REF #( mo_user->mv_string ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_client.clas.testclasses.abap`:1339 | lr_attri = REF #( mo_action->mo_app->mt_attri->*[ name = `MV_NAME` ] ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_client.clas.testclasses.abap`:1374 | lr_attri = REF #( mo_action->mo_app->mt_attri->*[ name = `MV_NAME` ] ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_client.clas.testclasses.abap`:1432 | lr_attri = REF #( lo_cont_db->mt_attri->*[ name = `MV_NAME` ] OPTIONAL ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.abap`:170 | lr_ref_in = REF #( <ele> ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:212 | result = REF #( <row>-name ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:608 | lr_old_cell = REF #( <name> ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:885 | ref  = REF #( <dref> ) ) INTO TABLE lt_dref. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1058 | result = REF #( <attri> ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1711 | ir_comp     = REF #( <comp> ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1712 | ir_before   = REF #( <before> ) |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:279 | result = REF #( mv_protected ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:350 | mr_alias_struc = REF #( ms_flat ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:351 | mr_alias_tab   = REF #( mt_std ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:370 | mo_inner_2->mr_shared = REF #( mt_std ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1440 | lo_app->mr_alias = REF #( lo_app->ms_data ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3211 | mo_app->mr_alias_tab = REF #( mo_app->mo_inner->mt_own ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3462 | lo_late->mr_shared = REF #( mo_app->mt_std ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3488 | lr_std = REF #( mo_app->mt_std ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3540 | mr_alias = REF #( ms_nested ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3643 | mr_a   = REF #( ma_tab ). |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:3644 | mr_b   = REF #( ma_tab ). |
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

**Where the detector is an approximation of the rule:**

- Generic parameters are read only where the declaration keeps name and TYPE on one line; a multi-line METHODS signature is missed, so the count is a floor.
- A field symbol assigned by a dynamic ASSIGN of a typed reference is treated as typed - the rule would ask the reference type, this cannot.
- The two sites of 2026-09 were repaired as REF data( ) the same day, so the current tree is expected to answer 0 - the negatives show the rule can tell a typed target apart.

<!-- probe:end -->
