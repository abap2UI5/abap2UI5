---
target: abaplint
title: 'Report a `sy-subrc` test used as the success check of an `ASSIGN`'
summary: on 7.40 SP7 a successful `ASSIGN` does not reset `sy-subrc`, so the test reads a value left by an earlier statement — `IS ASSIGNED` is the only correct check
priority: high
state: open
first_seen: 2026-08-17
upstream: abaplint/abaplint
evidence:
  - abap2UI5 issue #1937 — every app on a 7.40 SP7 system ran into an endless loop; fixed by `41890d59` testing the field symbol instead
  - the `sy-subrc` there was still `4` from a `READ TABLE` in a branch that had not been taken
  - not reproducible under the transpiler, which is more forgiving about `sy-subrc` than the release range abap2UI5 ships to — so no test in that repository can guard it
---

# Report a `sy-subrc` test used as the success check of an `ASSIGN`

## What happens

```abap
ASSIGN (lv_name) TO <attri>.
IF sy-subrc = 0.
  " ... use <attri>
ENDIF.
```

On a 7.40 SP7 system this reads a `sy-subrc` that the `ASSIGN` never wrote. In
abap2UI5's case the value was still `4` from a `READ TABLE` in an earlier branch
that had not been taken, so `attri_get_val_ref` treated an unassigned field
symbol as assigned and every app on that system went into an endless loop
(#1937). The correct check has no such gap:

```abap
IF <attri> IS NOT ASSIGNED.
```

The failure is release-dependent and silent everywhere else, which is the worst
combination: it passes every check the author can run, ships, and then breaks
for one customer.

## Why no existing rule catches it

`check_subrc` is the closest, and it is the mirror image of this. It reports
statements whose `sy-subrc` is **not** checked, and its extended information
already records that "If IS ASSIGNED is checked after assigning, it is
considered okay" — i.e. it accepts either check after an `ASSIGN` and prefers
neither. Nothing reports the check that is actually wrong.

## Proposed rule

Report a `sy-subrc` comparison whose nearest preceding `sy-subrc`-setting
statement is an `ASSIGN`, and suggest `IS [NOT] ASSIGNED` on the assigned field
symbol — **but not unconditionally**, see the next section.

Both halves are statically decidable within a statement block: the set of
statements that set `sy-subrc` is fixed and abaplint already models it for
`check_subrc`, and the field symbol to name in the message is the `ASSIGN`
target.

## `IS ASSIGNED` is not a drop-in replacement, and the rule has to say so

A **failed** `ASSIGN` leaves the field symbol bound to whatever it pointed at
before. Verified in `@abaplint/runtime`'s `assign`: every failure path sets
`sy-subrc = 4` and returns *without* clearing the target. So wherever the same
symbol can already be bound, `IS ASSIGNED` reads TRUE for a failure — turning a
wrong-branch bug into a silently-taken one, which is worse than what it
replaces.

The detector next to this item classifies every site by which fix applies,
measured over abap2UI5, samples, samples-controls and samples-stack:

| | | fix |
|---|--:|---|
| **simple** | 42 | freshly declared in this method, assigned once — `IS [NOT] ASSIGNED` is a drop-in |
| **in-loop** | 17 | inside `LOOP`/`DO`/`WHILE` — needs `UNASSIGN <fs>.` before the `ASSIGN` |
| **reassigned** | 2 | the same symbol was already assigned earlier in the method — same trap, same fix |

So roughly **one site in three cannot take the naive fix**, and a rule that
offered it as a quick-fix everywhere would introduce bugs in those. Either the
rule reports all three and describes both fixes, or it fires only on the simple
shape and stays silent on the other two — the second is smaller and safer, and
the classification above is decidable from the same single file.

The corpus's own #1937 fix is a *simple* case and is correct:
`attri_get_val_ref` declares `<attri>` at method start and assigns it in two
mutually exclusive branches, so nothing can be left over from before.

## What it must NOT report

- An `ASSIGN` whose `sy-subrc` is read for a reason other than the assign
  succeeding — there is no such use, but a `sy-subrc` set by an intervening
  statement must end the association, or the rule fires across unrelated code.
- `ASSIGN COMPONENT … OF STRUCTURE`, where `sy-subrc` distinguishes "component
  not found" from "assigned" and is the documented check. This is the scoping
  question the rule has to get right; the plain dynamic `ASSIGN (name)` form is
  the one with no alternative.

## Suggested severity

A warning rather than an error. The code is correct on current releases, and a
project that has dropped 7.40 support can turn it off knowingly — which is the
distinction between this and a defect that is wrong everywhere.

<!-- probe:start — written by `npm run backlog:probe`, do not edit by hand -->

## Measured

`abaplint-subrc-after-assign.probe.mjs` — a sy-subrc test whose nearest sy-subrc-setting statement is a plain ASSIGN, with ASSIGN COMPONENT as the negative.
Run **2026-08-17** against `abap2UI5`, `samples`, `samples-controls`, `samples-stack`.

**Would fire on 61 site(s)** in 3 repositories:

| Repository | Where | |
|---|---|---|
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:1035 | [simple] ASSERT sy-subrc = 0. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:1039 | [simple] ASSERT sy-subrc = 0. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:1043 | [simple] ASSERT sy-subrc = 0. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:1048 | [simple] ASSERT sy-subrc = 0. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:1180 | [simple] ASSERT sy-subrc = 0. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:1179 | [simple] IF sy-subrc <> 0. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:1191 | [simple] IF sy-subrc <> 0. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:1513 | [in-loop] IF sy-subrc <> 0. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:1876 | [simple] IF sy-subrc <> 0. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:1882 | [reassigned] IF sy-subrc <> 0. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:1970 | [simple] ASSERT sy-subrc = 0. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:2032 | [simple] ASSERT sy-subrc = 0. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:2274 | [in-loop] IF sy-subrc <> 0. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:2321 | [in-loop] IF sy-subrc <> 0. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_http.clas.abap`:191 | [simple] ASSERT sy-subrc = 0. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_http.clas.abap`:233 | [simple] ASSERT sy-subrc = 0. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_http.clas.abap`:457 | [simple] ASSERT sy-subrc = 0. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_http.clas.abap`:470 | [simple] ASSERT sy-subrc = 0. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:320 | [simple] IF sy-subrc <> 0. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:336 | [simple] IF sy-subrc <> 0. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:342 | [simple] IF sy-subrc <> 0. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:371 | [in-loop] IF sy-subrc <> 0. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:376 | [in-loop] IF sy-subrc <> 0. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:392 | [in-loop] IF sy-subrc <> 0. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:414 | [in-loop] IF sy-subrc <> 0. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:827 | [simple] IF sy-subrc <> 0. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:892 | [simple] IF sy-subrc = 0. |
| abap2UI5 | `src/02/z2ui5_cl_ui5_http_handler.clas.abap`:243 | [simple] IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:1563 | [in-loop] IF sy-subrc <> 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:2502 | [in-loop] IF sy-subrc <> 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4105 | [simple] IF sy-subrc <> 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4111 | [reassigned] IF sy-subrc <> 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4176 | [simple] ASSERT sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4223 | [simple] ASSERT sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4628 | [in-loop] IF sy-subrc <> 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4673 | [in-loop] IF sy-subrc <> 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1015 | [simple] IF sy-subrc  <> 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1027 | [simple] ASSERT sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4586 | [simple] ASSERT sy-subrc = 0. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_to_select.clas.abap`:205 | [in-loop] ASSERT sy-subrc = 0. |
| samples | `src/00/01/z2ui5_cl_smp_context.clas.abap`:692 | [in-loop] IF sy-subrc <> 0. |
| samples | `src/00/01/z2ui5_cl_smp_context.clas.abap`:1608 | [simple] IF sy-subrc  <> 0. |
| samples | `src/00/01/z2ui5_cl_smp_context.clas.abap`:1620 | [simple] ASSERT sy-subrc = 0. |
| samples | `src/00/01/z2ui5_cl_smp_context.clas.abap`:1790 | [in-loop] IF sy-subrc <> 0. |
| samples | `src/00/01/z2ui5_cl_smp_context.clas.abap`:1833 | [in-loop] IF sy-subrc <> 0. |
| samples | `src/00/98/z2ui5_cl_smp_app_117.clas.abap`:136 | [simple] IF sy-subrc = 0 AND <view_display> = abap_true. |
| samples | `src/00/98/z2ui5_cl_smp_app_131.clas.abap`:139 | [simple] IF sy-subrc = 0 AND <view_display> = abap_true. |
| samples | `src/00/98/z2ui5_cl_smp_app_185.clas.abap`:123 | [simple] IF sy-subrc = 0 AND <view_display> = abap_true. |
| samples | `src/00/98/z2ui5_cl_smp_app_191.clas.abap`:124 | [simple] IF sy-subrc = 0 AND <view_display> = abap_true. |
| samples | `src/00/98/z2ui5_cl_smp_app_193.clas.abap`:43 | [simple] IF sy-subrc = 0. |
| samples | `src/00/98/z2ui5_cl_smp_app_193.clas.abap`:51 | [simple] IF sy-subrc = 0. |
| samples | `src/00/98/z2ui5_cl_smp_app_195.clas.abap`:123 | [simple] IF sy-subrc = 0 AND <view_display> = abap_true. |
| samples | `src/00/98/z2ui5_cl_smp_app_211.clas.abap`:150 | [simple] IF sy-subrc = 0 AND <view_display> = abap_true. |
| samples | `src/00/98/z2ui5_cl_smp_app_212.clas.abap`:86 | [simple] IF sy-subrc <> 0. |
| samples | `src/00/98/z2ui5_cl_smp_app_338.clas.abap`:138 | [simple] IF sy-subrc = 0 AND <view_display> = abap_true. |
| samples | `src/01/z2ui5_cl_smp_app_104.clas.abap`:49 | [simple] IF sy-subrc <> 0. |
| samples | `src/01/z2ui5_cl_smp_app_104.clas.abap`:68 | [simple] IF sy-subrc <> 0. |
| samples | `src/01/z2ui5_cl_smp_app_461.clas.abap`:85 | [simple] IF sy-subrc <> 0. |
| samples | `src/01/z2ui5_cl_smp_app_461.clas.abap`:89 | [simple] IF sy-subrc <> 0. |
| samples-stack | `src/00/00/z2ui5_cl_smps_context.clas.abap`:449 | [in-loop] IF sy-subrc <> 0. |
| samples-stack | `src/00/00/z2ui5_cl_smps_context.clas.abap`:492 | [in-loop] IF sy-subrc <> 0. |

**Must NOT fire on 171 site(s)** that match the shape and are correct:

| Repository | Where | |
|---|---|---|
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:1093 | ASSERT sy-subrc = 0. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:1867 | ASSERT sy-subrc = 0. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:982 | IF sy-subrc <> 0. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:997 | IF sy-subrc <> 0. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:1366 | IF sy-subrc <> 0. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:2224 | IF sy-subrc <> 0. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:2376 | CHECK sy-subrc = 0. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:2415 | CHECK sy-subrc = 0. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:2446 | IF sy-subrc = 0. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:2461 | IF sy-subrc = 0. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:2464 | IF sy-subrc = 0. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:2491 | IF sy-subrc = 0. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:2505 | CHECK sy-subrc = 0. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:2544 | IF sy-subrc <> 0 OR <tky> IS INITIAL. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:2562 | CHECK sy-subrc = 0. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.abap`:94 | IF sy-subrc <> 0. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:863 | IF sy-subrc <> 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:1739 | IF sy-subrc <> 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:1748 | IF sy-subrc <> 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:1805 | IF sy-subrc <> 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:1856 | IF sy-subrc <> 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:2471 | IF sy-subrc <> 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:3466 | IF sy-subrc <> 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:3559 | IF sy-subrc <> 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:3708 | IF sy-subrc <> 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:3712 | IF sy-subrc <> 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:3795 | IF sy-subrc <> 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:3822 | IF sy-subrc <> 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4583 | IF sy-subrc <> 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4726 | CHECK sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4765 | CHECK sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4796 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4811 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4814 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4836 | CHECK sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4851 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4864 | CHECK sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4875 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4884 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4893 | IF sy-subrc <> 0 OR <tky> IS INITIAL. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4911 | CHECK sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1032 | IF sy-subrc <> 0 OR <field> <> abap_true. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1036 | ASSERT sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1341 | IF sy-subrc <> 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1451 | IF sy-subrc <> 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1487 | IF sy-subrc <> 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2253 | IF sy-subrc = 0. ls_hdr-log_handle = <comp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2255 | IF sy-subrc = 0. ls_hdr-object = <comp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2257 | IF sy-subrc = 0. ls_hdr-subobject = <comp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2259 | IF sy-subrc = 0. ls_hdr-external_id = <comp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2261 | IF sy-subrc = 0. ls_hdr-log_date = <comp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2263 | IF sy-subrc = 0. ls_hdr-log_time = <comp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2265 | IF sy-subrc = 0. ls_hdr-user = <comp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2980 | IF sy-subrc = 0. ls_obj-pgmid = <comp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2982 | IF sy-subrc = 0. ls_obj-object = <comp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2984 | IF sy-subrc = 0. ls_obj-obj_name = <comp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3036 | IF sy-subrc = 0. ls_req_c-owner = <pcomp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3041 | IF sy-subrc = 0. ls_req_c-description = <pcomp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3043 | IF sy-subrc = 0. ls_req_c-status = <pcomp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3045 | IF sy-subrc = 0. ls_req_c-type = <pcomp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3096 | IF sy-subrc = 0. ls_req-trkorr = <comp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3098 | IF sy-subrc = 0. ls_req-owner = <comp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3100 | IF sy-subrc = 0. ls_req-status = <comp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3102 | IF sy-subrc = 0. ls_req-type = <comp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3723 | IF sy-subrc <> 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3746 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3750 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3754 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3758 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3762 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3766 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3770 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3774 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3935 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3939 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3943 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3947 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3951 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3955 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3959 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3963 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3967 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4013 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4017 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4021 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4025 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4029 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4033 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4037 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4442 | IF sy-subrc <> 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4446 | IF sy-subrc = 0. ls_doc_c-changenr = <cds_fld>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4448 | IF sy-subrc = 0. ls_doc_c-username = <cds_fld>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4450 | IF sy-subrc = 0. ls_doc_c-udate = <cds_fld>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4452 | IF sy-subrc = 0. ls_doc_c-utime = <cds_fld>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4454 | IF sy-subrc = 0. ls_doc_c-tcode = <cds_fld>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4456 | IF sy-subrc = 0. ls_doc_c-fieldname = <cds_fld>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4458 | IF sy-subrc = 0. ls_doc_c-new_value = <cds_fld>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4460 | IF sy-subrc = 0. ls_doc_c-old_value = <cds_fld>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4462 | IF sy-subrc = 0. ls_doc_c-tabname = <cds_fld>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4464 | IF sy-subrc = 0. ls_doc_c-chngind = <cds_fld>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4512 | IF sy-subrc = 0. ls_doc-changenr = <comp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4514 | IF sy-subrc = 0. ls_doc-username = <comp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4516 | IF sy-subrc = 0. ls_doc-udate = <comp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4518 | IF sy-subrc = 0. ls_doc-utime = <comp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4520 | IF sy-subrc = 0. ls_doc-tcode = <comp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4539 | IF sy-subrc = 0. ls_pos-fieldname = <comp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4541 | IF sy-subrc = 0. ls_pos-old_value = <comp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4543 | IF sy-subrc = 0. ls_pos-new_value = <comp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4545 | IF sy-subrc = 0. ls_pos-tabname = <comp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4547 | IF sy-subrc = 0. ls_pos-chngind = <comp>. ENDIF. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.abap`:307 | CHECK sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.abap`:340 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.abap`:355 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.abap`:358 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.abap`:378 | CHECK sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.abap`:408 | CHECK sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.abap`:423 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.abap`:436 | CHECK sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.abap`:447 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.abap`:456 | IF sy-subrc = 0. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.abap`:465 | IF sy-subrc <> 0 OR <tky> IS INITIAL. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.abap`:483 | CHECK sy-subrc = 0. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_to_select.clas.abap`:237 | ASSERT sy-subrc = 0. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_to_select.clas.abap`:244 | ASSERT sy-subrc = 0. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_to_select.clas.testclasses.abap`:244 | IF sy-subrc <> 0. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_to_select.clas.testclasses.abap`:288 | IF sy-subrc <> 0. |
| samples | `src/00/01/z2ui5_cl_smp_context.clas.abap`:850 | IF sy-subrc <> 0. |
| samples | `src/00/01/z2ui5_cl_smp_context.clas.abap`:859 | IF sy-subrc <> 0. |
| samples | `src/00/01/z2ui5_cl_smp_context.clas.abap`:914 | IF sy-subrc <> 0. |
| samples | `src/00/01/z2ui5_cl_smp_context.clas.abap`:965 | IF sy-subrc <> 0. |
| samples | `src/00/01/z2ui5_cl_smp_context.clas.abap`:1625 | IF sy-subrc <> 0 OR <field> <> abap_true. |
| samples | `src/00/01/z2ui5_cl_smp_context.clas.abap`:1629 | ASSERT sy-subrc = 0. |
| samples | `src/00/01/z2ui5_cl_smp_context.clas.abap`:1743 | IF sy-subrc <> 0. |
| samples | `src/00/01/z2ui5_cl_smp_context.clas.abap`:1886 | CHECK sy-subrc = 0. |
| samples | `src/00/01/z2ui5_cl_smp_context.clas.abap`:1927 | CHECK sy-subrc = 0. |
| samples | `src/00/01/z2ui5_cl_smp_context.clas.abap`:1959 | IF sy-subrc = 0. |
| samples | `src/00/01/z2ui5_cl_smp_context.clas.abap`:1974 | IF sy-subrc = 0. |
| samples | `src/00/01/z2ui5_cl_smp_context.clas.abap`:1977 | IF sy-subrc = 0. |
| samples | `src/00/01/z2ui5_cl_smp_context.clas.abap`:1998 | CHECK sy-subrc = 0. |
| samples | `src/00/01/z2ui5_cl_smp_context.clas.abap`:2013 | IF sy-subrc = 0. |
| samples | `src/00/01/z2ui5_cl_smp_context.clas.abap`:2026 | CHECK sy-subrc = 0. |
| samples | `src/00/01/z2ui5_cl_smp_context.clas.abap`:2037 | IF sy-subrc = 0. |
| samples | `src/00/01/z2ui5_cl_smp_context.clas.abap`:2046 | IF sy-subrc = 0. |
| samples | `src/00/01/z2ui5_cl_smp_context.clas.abap`:2055 | IF sy-subrc <> 0 OR <tky> IS INITIAL. |
| samples | `src/00/01/z2ui5_cl_smp_context.clas.abap`:2075 | CHECK sy-subrc = 0. |
| samples | `src/00/98/z2ui5_cl_smp_app_194.clas.abap`:55 | IF sy-subrc <> 0. |
| samples | `src/00/98/z2ui5_cl_smp_app_212.clas.abap`:94 | IF sy-subrc <> 0. |
| samples | `src/00/98/z2ui5_cl_smp_app_212.clas.abap`:101 | IF sy-subrc <> 0. |
| samples | `src/00/98/z2ui5_cl_smp_app_212.clas.abap`:142 | IF sy-subrc <> 0. |
| samples | `src/00/98/z2ui5_cl_smp_app_328.clas.abap`:43 | IF sy-subrc <> 0. |
| samples | `src/00/98/z2ui5_cl_smp_app_332.clas.abap`:81 | IF sy-subrc <> 0. |
| samples | `src/00/98/z2ui5_cl_smp_app_334.clas.abap`:97 | IF sy-subrc <> 0. |
| samples | `src/00/98/z2ui5_cl_smp_app_335.clas.abap`:127 | IF sy-subrc <> 0. |
| samples | `src/00/98/z2ui5_cl_smp_app_337.clas.abap`:185 | IF sy-subrc <> 0. |
| samples | `src/00/98/z2ui5_cl_smp_app_348.clas.abap`:175 | IF sy-subrc <> 0. |
| samples | `src/00/98/z2ui5_cl_smp_app_349.clas.abap`:193 | IF sy-subrc <> 0. |
| samples | `src/01/z2ui5_cl_smp_app_070.clas.abap`:356 | IF sy-subrc <> 0. |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_012.clas.abap`:558 | IF sy-subrc = 0. |
| samples-stack | `src/00/00/z2ui5_cl_smps_context.clas.abap`:414 | CHECK sy-subrc = 0. |
| samples-stack | `src/00/00/z2ui5_cl_smps_context.clas.abap`:535 | IF sy-subrc <> 0. |
| samples-stack | `src/00/00/z2ui5_cl_smps_context.clas.abap`:589 | CHECK sy-subrc = 0. |
| samples-stack | `src/00/00/z2ui5_cl_smps_context.clas.abap`:618 | CHECK sy-subrc = 0. |
| samples-stack | `src/00/00/z2ui5_cl_smps_context.clas.abap`:629 | IF sy-subrc = 0. |
| samples-stack | `src/00/00/z2ui5_cl_smps_context.clas.abap`:642 | CHECK sy-subrc = 0. |
| samples-stack | `src/00/00/z2ui5_cl_smps_context.clas.abap`:686 | CHECK sy-subrc = 0. |
| samples-stack | `src/00/00/z2ui5_cl_smps_context.clas.abap`:751 | IF sy-subrc = 0. |
| samples-stack | `src/00/00/z2ui5_cl_smps_context.clas.abap`:767 | IF sy-subrc = 0. |
| samples-stack | `src/00/00/z2ui5_cl_smps_context.clas.abap`:782 | IF sy-subrc = 0. |
| samples-stack | `src/00/00/z2ui5_cl_smps_context.clas.abap`:785 | IF sy-subrc = 0. |
| samples-stack | `src/00/00/z2ui5_cl_smps_context.clas.abap`:802 | IF sy-subrc = 0. |
| samples-stack | `src/00/00/z2ui5_cl_smps_context.clas.abap`:811 | IF sy-subrc <> 0 OR <tky> IS INITIAL. |

**Where the detector is an approximation of the rule:**

- Which fix applies: 42 simple · 17 in a loop · 2 re-assigned. Only the first is a drop-in; the other two need `UNASSIGN` before the `ASSIGN`, because a failed assign leaves the previous binding in place and `IS ASSIGNED` then reads TRUE for a failure. Verified against `@abaplint/runtime`'s assign, which sets sy-subrc = 4 and returns without clearing the target.
- The set of sy-subrc-writing statements is hand-written and short. A statement missing from it lets an ASSIGN keep its claim too long, so the count is an upper bound — abaplint knows the real set (it models it for `check_subrc`) and would report fewer.
- Field-symbol assignment inside a macro or a chained statement is not followed.

<!-- probe:end -->
