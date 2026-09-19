---
target: abaplint
title: 'Report an empty `CATCH` block without `##NO_HANDLER`'
summary: 'SLIN reports an empty exception handler on every real system; a systemless pipeline never sees it, and the pragma that says "deliberately empty" is the one sanctioned way to silence it — no abaplint rule reads the block'
priority: low
state: open
first_seen: 2026-09-19
upstream: abaplint/abaplint
evidence:
  - abap-check §3 carries the house rule ("an empty CATCH block wants ##NO_HANDLER") because the extended check reports it on the systems abap2UI5 is pulled into, and nothing here does
  - measured 2026-09-19 over abap2UI5 `src/` (200 ABAP files) — 14 empty handlers without the pragma, all of them in the vendored `z2ui5_cl_ajson` test classes, i.e. exactly the code the abap2UI5-linter never reads (it carries the rule as a hint since 2026-09 — `empty-catch-block` — for app classes only)
  - measured 2026-09-19 on abaplint 2.120.52 with every rule on — no finding on an isolated class with `CATCH cx_root.` followed by `ENDTRY.`; `empty_structure`, `try_without_catch` and `unnecessary_pragma` do not cover it
---

# Report an empty `CATCH` block without `##NO_HANDLER`

## What happens

```abap
TRY.
    risky( ).
  CATCH cx_root.          " SLIN: "Empty exception handler"
ENDTRY.
```

The extended check (SLIN / ATC) reports every empty handler, and on a real
system that finding blocks a transport in most landscapes. The sanctioned way
to say the empty handler is meant is the pragma on the `CATCH` statement:

```abap
  CATCH cx_root ##NO_HANDLER.
```

A comment inside the block does not count — SLIN reads the statements, not
the prose — which is why the pragma, not a comment, is the remedy.

## Why no existing rule catches it

`empty_structure` reports empty `IF`/`LOOP`/`WHILE`/`CASE`/`DO` structures
and does not list `CATCH`. `try_without_catch` is the opposite shape.
`unnecessary_pragma` reports a `##NO_HANDLER` on a NON-empty handler — the
mirror image, which shows the rule set already knows what the pragma means.

## Proposed rule

Report a `CATCH` (and `CLEANUP`) statement followed by no statement before
the next `CATCH`, `CLEANUP` or `ENDTRY`, unless the `CATCH` carries
`##NO_HANDLER`. Purely structural, one statement lookahead. A natural home
is `empty_structure` with a `catch` option, so a repository that disagrees
can switch just that part off.

Quick fix: appending ` ##NO_HANDLER` is a suppression, not a fix, so none —
or the fix inserts the pragma and says so, since that is what SLIN's own
quick fix does in ADT.

## What it must NOT report

- a `CATCH … ##NO_HANDLER.` — the pragma is the point.
- a handler containing only a `RETURN.`, `CONTINUE.` or `EXIT.` — a statement
  is a statement.
- `CATCH … INTO DATA(lx).` followed by statements — not empty.

## Example

```abap
" bad
TRY.
    risky( ).
  CATCH cx_root.
ENDTRY.

" good
TRY.
    risky( ).
  CATCH cx_root ##NO_HANDLER.   " deliberate, and says so
ENDTRY.
```

<!-- probe:start — written by `npm run backlog:probe`, do not edit by hand -->

## Measured

`abaplint-empty-catch-block.probe.mjs` — an empty CATCH block without ##NO_HANDLER, with the pragma-carrying one as the negative.
Run **2026-09-19** against `abap2UI5` (not checked out: samples, samples-controls, samples-stack).

**Would fire on 14 site(s)** in 1 repository:

| Repository | Where | |
|---|---|---|
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.testclasses.abap`:663 | CATCH z2ui5_cx_ajson_error. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.testclasses.abap`:1055 | CATCH z2ui5_cx_ajson_error. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.testclasses.abap`:1062 | CATCH z2ui5_cx_ajson_error. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.testclasses.abap`:3744 | CATCH z2ui5_cx_ajson_error. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.testclasses.abap`:3750 | CATCH z2ui5_cx_ajson_error. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.testclasses.abap`:3758 | CATCH z2ui5_cx_ajson_error. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.testclasses.abap`:3764 | CATCH z2ui5_cx_ajson_error. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.testclasses.abap`:3770 | CATCH z2ui5_cx_ajson_error. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.testclasses.abap`:4081 | CATCH z2ui5_cx_ajson_error. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.testclasses.abap`:4087 | CATCH z2ui5_cx_ajson_error. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.testclasses.abap`:1982 | CATCH cx_root. |
| abap2UI5 | `src/99/01/z2ui5_cx_util_error.clas.testclasses.abap`:62 | CATCH cx_root INTO DATA(lx_root). |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_error.clas.testclasses.abap`:20 | CATCH cx_root INTO DATA(lx). |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_messages.clas.testclasses.abap`:38 | CATCH cx_root INTO DATA(lx). |

**Must NOT fire on 104 site(s)** that match the shape and are correct:

| Repository | Where | |
|---|---|---|
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:1029 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:1275 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:1304 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:1791 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:1908 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:2290 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:2304 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:2607 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:2925 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:3048 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:3065 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:3077 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:3159 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:3192 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:3237 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:3273 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:3413 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.testclasses.abap`:1026 | CATCH z2ui5_cx_ui5_util_error INTO lx ##NO_HANDLER. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_http.clas.abap`:278 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_http.clas.testclasses.abap`:32 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_http.clas.testclasses.abap`:90 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/00/03/z2ui5_cx_ui5_util_error.clas.abap`:246 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/00/03/z2ui5_cx_ui5_util_error.clas.testclasses.abap`:71 | CATCH cx_root INTO DATA(lx_root) ##NO_HANDLER. |
| abap2UI5 | `src/00/03/z2ui5_cx_ui5_util_error.clas.testclasses.abap`:206 | CATCH cx_root INTO DATA(lx_root) ##NO_HANDLER. |
| abap2UI5 | `src/01/01/z2ui5_cl_ui5_srv_draft.clas.testclasses.abap`:136 | CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER. |
| abap2UI5 | `src/01/01/z2ui5_cl_ui5_srv_draft.clas.testclasses.abap`:164 | CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_action.clas.abap`:245 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.testclasses.abap`:895 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_client.clas.abap`:221 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_handler.clas.abap`:486 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_handler.clas.abap`:633 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_handler.clas.abap`:688 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_handler.clas.abap`:717 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_handler.clas.abap`:793 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_handler.clas.abap`:982 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_handler.clas.testclasses.abap`:141 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:842 | CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_bind.clas.testclasses.abap`:857 | CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_event.clas.abap`:272 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1243 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:1978 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:2093 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1391 | CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1526 | CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1737 | CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2196 | CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:2198 | CATCH z2ui5_cx_ajson_error ##NO_HANDLER. |
| abap2UI5 | `src/01/04/z2ui5_cl_ui5_app_start.clas.abap`:309 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/01/04/z2ui5_cl_ui5_user_exit.clas.abap`:157 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/01/04/z2ui5_cl_ui5_user_exit.clas.testclasses.abap`:207 | CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER. |
| abap2UI5 | `src/02/z2ui5_cl_ui5_http_handler.clas.abap`:777 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/02/z2ui5_cl_ui5_http_handler.clas.abap`:836 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/02/z2ui5_cl_ui5_http_handler.clas.abap`:941 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:1452 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:1903 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:1914 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:1957 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:2085 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:2111 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:2146 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:3773 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4740 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4776 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4805 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4931 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_db.clas.testclasses.abap`:146 | CATCH z2ui5_cx_util_error ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_db.clas.testclasses.abap`:158 | CATCH z2ui5_cx_util_error ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:987 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1040 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1251 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1468 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1701 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1800 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1889 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2005 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2051 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2156 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2161 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2269 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2333 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2388 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2481 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2489 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2497 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2517 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2937 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2942 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2988 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3053 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3060 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3113 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3137 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3154 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3861 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4468 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4554 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_http.clas.testclasses.abap`:32 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_http.clas.testclasses.abap`:90 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.abap`:321 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.abap`:349 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.abap`:389 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_msg.clas.abap`:504 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_demo_output.clas.abap`:58 | CATCH cx_root ##NO_HANDLER. |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:15290 | CATCH cx_root ##NO_HANDLER. |

**Where the detector is an approximation of the rule:**

- Line-based; a CATCH statement continued on the next line (a long exception list) is judged on its first line, which can miss a pragma written at the end.
- In abap2UI5 every site is in the vendored ajson test classes - the code the app-class linter does not read, which is the argument for the upstream rule.

<!-- probe:end -->
