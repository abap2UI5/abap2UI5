---
target: abaplint
title: 'Extend `obsolete_statement.defaultKey` to the IMPLICIT default key'
summary: '`DATA t TYPE TABLE OF x.` with no `WITH … KEY` gets the same default key the explicit `WITH DEFAULT KEY` declares — every character-like component, unasked — and the rule reports only the spelled-out form, so the commoner spelling passes every gate'
priority: medium
state: open
first_seen: 2026-09-19
upstream: abaplint/abaplint
evidence:
  - abap2UI5/samples-controls app 034 shipped `TYPE TABLE OF` without a key clause through a config that has `obsolete_statement.defaultKey` ON; the corpus gate grew a regex for it (`pattern-lint`), promoted 2026-09-12 into the abap2UI5-linter as `default-key-table` — which reads app classes only
  - measured 2026-09-19 over abap2UI5 `src/` (the probe beside this item) — 31 implicit default-key declarations, all in the vendored `z2ui5_cl_ajson` includes and test classes, code no abap2UI5-linter run ever reads
  - measured 2026-09-19 on abaplint 2.120.52, `obsolete_statement` with `defaultKey: true` — `DATA lt TYPE TABLE OF string.` produces no finding; the rule's implementation matches the `DEFAULT KEY` tokens
---

# Extend `obsolete_statement.defaultKey` to the IMPLICIT default key

## What happens

```abap
DATA lt_rows TYPE TABLE OF ty_row.            " implicit default key
DATA lt_rows TYPE TABLE OF ty_row WITH DEFAULT KEY.   " the same table, spelled out
```

Both declare the standard default key: every character-like component of
the row, in declaration order. `SORT itab` without `BY`, `COLLECT`, `DELETE
ADJACENT DUPLICATES` and `READ TABLE … WITH TABLE KEY` on such a table use
that key, unasked — which is the whole reason `obsolete_statement.defaultKey`
exists ("from 7.40 SP02 write the key you mean, `WITH EMPTY KEY` when there
is none"). The rule reports the second line and not the first, and the first
is what people write.

## Why no existing rule catches it

`obsolete_statement` checks for the tokens `DEFAULT KEY`
(`concatTokens().includes("EC DEFAULT_KEY")` for the pseudo comment, the
`DEFAULT KEY` keyword pair for the finding). A declaration with no `WITH`
clause at all never reaches that comparison. `fully_type_itabs` is about the
row type, not the key.

## Proposed rule

Under the same `defaultKey` option, also report `TYPE [STANDARD] TABLE OF …`
(in `DATA`, `TYPES`, `CLASS-DATA`, `STATICS`, parameter typing and inline
`BEGIN OF` components) with no `WITH … KEY` clause, from v740sp02 on. Same
pseudo comment `"#EC DEFAULT_KEY` to waive it.

No quick fix: `WITH EMPTY KEY` and a real key are different tables, and
choosing between them is the author's decision — the same reason the
explicit form has none today.

## What it must NOT report

- `SORTED` / `HASHED` tables — a key is mandatory there.
- `TYPE ty_t_rows` — a named table type carries its own key clause where it
  is declared, and is judged there.
- `TYPE RANGE OF`, `TYPE TABLE FOR` (RAP derived types) — no key clause
  applies.
- `LIKE lt_other` — the key comes from the referenced object.

## Example

```abap
" bad
DATA mt_rows TYPE TABLE OF string.

" good
DATA mt_rows TYPE STANDARD TABLE OF string WITH EMPTY KEY.
```

<!-- probe:start — written by `npm run backlog:probe`, do not edit by hand -->

## Measured

`abaplint-default-key-implicit.probe.mjs` — an implicit default-key table declaration, with the explicit WITH DEFAULT KEY as the negative.
Run **2026-09-19** against `abap2UI5` (not checked out: samples, samples-controls, samples-stack).

**Would fire on 31 site(s)** in 1 repository:

| Repository | Where | |
|---|---|---|
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:348 | ty_stack_tt TYPE STANDARD TABLE OF REF TO z2ui5_if_ajson_types=>ty_node. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:411 | DATA lt_text TYPE TABLE OF string. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.locals_imp.abap`:2283 | DATA mt_queue TYPE STANDARD TABLE OF REF TO lif_mutator_runner. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.testclasses.abap`:1972 | DATA lt_mock  TYPE TABLE OF string_table. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.testclasses.abap`:1973 | DATA lt_exp   TYPE TABLE OF string_table. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.testclasses.abap`:2006 | DATA lt_mock  TYPE TABLE OF string_table. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.testclasses.abap`:2007 | DATA lt_exp   TYPE TABLE OF string_table. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.testclasses.abap`:2494 | DATA lt_foo_bar TYPE STANDARD TABLE OF ty_foo_bar. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.testclasses.abap`:4210 | DATA lt_act TYPE TABLE OF ty_loc. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.testclasses.abap`:4211 | DATA lt_exp TYPE TABLE OF ty_loc. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.testclasses.abap`:4904 | DATA lt_tab TYPE TABLE OF ty_struc. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.testclasses.abap`:4972 | DATA mt_visit_history TYPE TABLE OF ty_visit_history. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson_mapping.clas.locals_imp.abap`:207 | DATA lt_tokens TYPE STANDARD TABLE OF ty_token. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson_mapping.clas.locals_imp.abap`:311 | DATA lt_tokens TYPE STANDARD TABLE OF lty_token. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson_utilities.clas.testclasses.abap`:582 | DATA lt_data TYPE TABLE OF string. |
| abap2UI5 | `src/00/01/z2ui5_cl_ajson_utilities.clas.testclasses.abap`:654 | DATA lt_data TYPE TABLE OF string. |
| abap2UI5 | `src/00/01/z2ui5_if_ajson_mapping.intf.abap`:24 | ty_table_of TYPE STANDARD TABLE OF REF TO z2ui5_if_ajson_mapping. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:1268 | DATA lt_result_tab TYPE TABLE OF string. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2101 | DATA lt_logs   TYPE STANDARD TABLE OF REF TO object. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2293 | DATA lt_logs_c   TYPE STANDARD TABLE OF REF TO object. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2426 | DATA lt_items    TYPE STANDARD TABLE OF ty_item. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2429 | DATA lt_logs     TYPE STANDARD TABLE OF REF TO object. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2726 | DATA lt_logs   TYPE STANDARD TABLE OF REF TO object. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2831 | DATA lt_logs   TYPE STANDARD TABLE OF REF TO object. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2900 | DATA lt_objects_c TYPE STANDARD TABLE OF REF TO object. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:2957 | CREATE DATA lr_objects TYPE STANDARD TABLE OF (`E071`). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3002 | DATA lt_transports TYPE STANDARD TABLE OF REF TO object. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:3891 | CREATE DATA lr_enq TYPE STANDARD TABLE OF (`SEQG3`). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4005 | CREATE DATA lr_enq TYPE STANDARD TABLE OF (`SEQG3`). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4489 | CREATE DATA lr_headers TYPE STANDARD TABLE OF (`CDHDR`). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:4490 | CREATE DATA lr_positions TYPE STANDARD TABLE OF (`CDPOS`). |

**Must NOT fire on 12 site(s)** that match the shape and are correct:

| Repository | Where | |
|---|---|---|
| abap2UI5 | `src/00/02/z2ui5_cl_srt_structdescr.clas.abap`:16 | TYPES sabap_component_tab TYPE STANDARD TABLE OF sabap_componentdescr WITH DEFAULT KEY. |
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:2626 | DATA lt_impl TYPE STANDARD TABLE OF ty_s_impl WITH DEFAULT KEY. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:236 | TYPES ty_t_fix_val TYPE STANDARD TABLE OF ty_s_fix_val WITH DEFAULT KEY. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:1134 | TYPES ty_t_classes TYPE STANDARD TABLE OF ty_s_class_descr WITH DEFAULT KEY. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:1143 | TYPES ty_t_stack TYPE STANDARD TABLE OF ty_s_stack WITH DEFAULT KEY. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:3903 | TYPES fixvalues TYPE STANDARD TABLE OF fixvalue WITH DEFAULT KEY. |
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:4072 | DATA lt_impl TYPE STANDARD TABLE OF ty_s_impl WITH DEFAULT KEY. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:12 | TYPES ty_t_fix_val TYPE STANDARD TABLE OF ty_s_fix_val WITH DEFAULT KEY. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:88 | ty_t_dfies TYPE STANDARD TABLE OF ty_s_dfies WITH DEFAULT KEY. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:262 | TYPES tt_ddshtextsearch_fields TYPE STANDARD TABLE OF ty_ddshtextsearch_field WITH DEFAULT KEY. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:482 | TYPES ty_t_lock_param TYPE STANDARD TABLE OF ty_s_lock_param WITH DEFAULT KEY. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_ext.clas.abap`:496 | TYPES ty_t_lock TYPE STANDARD TABLE OF ty_s_lock WITH DEFAULT KEY. |

**Where the detector is an approximation of the rule:**

- Declaration-element level (a chained DATA: is split on its commas by the terminator match), so a multi-line element is read.
- RANGE OF and TABLE FOR are not matched by construction; a `LIKE` declaration is not either.

<!-- probe:end -->
