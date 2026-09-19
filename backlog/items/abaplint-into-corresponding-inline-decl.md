---
target: abaplint
title: 'Version-gate `INTO CORRESPONDING FIELDS OF TABLE @DATA( )` — it is 7.55 syntax'
summary: 'below 7.55 the system refuses the class with "Inline data declarations cannot be used together with INTO CORRESPONDING additions"; abaplint`s SELECT grammar puts no version gate on the inline declaration, so a v750 project is green with it'
priority: high
state: open
first_seen: 2026-09-19
upstream: abaplint/abaplint
evidence:
  - abap2UI5/samples, 2026-08-17 — a user pulling main found `z2ui5_cl_smp_app_348` carrying it in both of its SELECTs; the class did not activate. Fixed in samples `0d082a3` by declaring the tables `TYPE STANDARD TABLE OF … WITH EMPTY KEY` and selecting into them
  - measured on abaplint 2.120.24 with `check_syntax` and `downport` on at `syntax.version` v750 — zero findings, control probe fired (abap-check §2); measured again 2026-09-19 on 2.120.52, same result
  - the abap2UI5-linter carries the rule since 2026-08-30 (`into-corresponding-inline-decl`) for consumers whose only gate it is; this item is its upstream generalization — the linter reads app classes, abaplint reads every ABAP object
---

# Version-gate `INTO CORRESPONDING FIELDS OF TABLE @DATA( )` — it is 7.55 syntax

## What happens

```abap
SELECT * FROM scarr INTO CORRESPONDING FIELDS OF TABLE @DATA(lt_carr).
```

Below 7.55 the system refuses the class: *"Inline data declarations cannot be
used together with INTO CORRESPONDING additions"*, plus one *"Field … is
unknown"* for every later read of the table that was never declared — three
errors whose cause is the first one. Plain `INTO TABLE @DATA( )` is fine from
7.40 on; it is only the combination with `CORRESPONDING` that is late.

```abap
DATA lt_carr TYPE STANDARD TABLE OF scarr WITH EMPTY KEY.
SELECT * FROM scarr INTO CORRESPONDING FIELDS OF TABLE @lt_carr.
```

## Why no existing rule catches it

The `Select` grammar accepts an `InlineData` target after `INTO CORRESPONDING
FIELDS OF TABLE` at every version; `downport` only rewrites inline
declarations for versions that have none at all (v702), and at v750 leaves
the statement as it is. `check_syntax` types the inline table from the
`FROM` and is content.

## Proposed rule

In the version model / `downport`: `INTO CORRESPONDING FIELDS OF TABLE
@DATA( )` and `APPENDING CORRESPONDING FIELDS OF TABLE @DATA( )` (and the
single-row `INTO CORRESPONDING FIELDS OF @DATA( )`) require v755. Below that,
report — and `downport` can carry the quick fix it already knows how to
write: a `DATA … TYPE STANDARD TABLE OF <from-table> WITH EMPTY KEY.` before
the statement for the `SELECT *` case, and the target rewritten to `@lt_…`.

## What it must NOT report

- `INTO TABLE @DATA( )` / `INTO @DATA( )` — 7.40, fine.
- `INTO CORRESPONDING FIELDS OF TABLE @lt_declared` — the remedy.
- anything at `syntax.version` v755 or newer, or with no version set.

## Example

```abap
" bad (syntax.version v750)
SELECT * FROM t000 INTO CORRESPONDING FIELDS OF TABLE @DATA(lt_t000).

" good
DATA lt_t000 TYPE STANDARD TABLE OF t000 WITH EMPTY KEY.
SELECT * FROM t000 INTO CORRESPONDING FIELDS OF TABLE @lt_t000.
```

<!-- probe:start — written by `npm run backlog:probe`, do not edit by hand -->

## Measured

`abaplint-into-corresponding-inline-decl.probe.mjs` — CORRESPONDING FIELDS OF … @DATA( ) in a SELECT, with INTO TABLE @DATA( ) and a declared target as the negatives.
Run **2026-09-19** against `abap2UI5` (not checked out: samples, samples-controls, samples-stack).

**Would fire on 0 site(s)** in 0 repositories:

_none_

**Must NOT fire on 8 site(s)** that match the shape and are correct:

| Repository | Where | |
|---|---|---|
| abap2UI5 | `src/01/01/z2ui5_cl_ui5_srv_draft.clas.abap`:121 | INTO @DATA(lv_owner). |
| abap2UI5 | `src/01/01/z2ui5_cl_ui5_srv_draft.clas.abap`:150 | INTO CORRESPONDING FIELDS OF @result ##SUBRC_OK. |
| abap2UI5 | `src/01/01/z2ui5_cl_ui5_srv_draft.clas.abap`:201 | INTO @DATA(ls_row). |
| abap2UI5 | `src/01/01/z2ui5_cl_ui5_srv_draft.clas.testclasses.abap`:169 | INTO @DATA(lv_data). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_db.clas.abap`:91 | INTO @DATA(lv_data). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_db.clas.abap`:133 | INTO CORRESPONDING FIELDS OF TABLE @result. |
| abap2UI5 | `src/99/01/z2ui5_cl_util_db.clas.abap`:143 | INTO @DATA(lv_data). |
| abap2UI5 | `src/99/01/z2ui5_cl_util_db.clas.abap`:168 | INTO @DATA(lv_id) ##SUBRC_OK. |

**Where the detector is an approximation of the rule:**

- Statement-level, so a SELECT spread over lines is read. Open SQL only by construction of the `@` host prefix; the samples-348 shape was exactly this.
- The negatives are the two neighbouring legal spellings: an inline declaration without CORRESPONDING, and CORRESPONDING into a declared table.

<!-- probe:end -->
