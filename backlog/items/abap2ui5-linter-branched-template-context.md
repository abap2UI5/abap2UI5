---
target: abap2ui5-linter
title: 'relative-binding-without-context: every arm''s control in a row template has the row context'
summary: 'a table:template filled from the arms of an IF/CASE holds one control per arm side by side in the reconstruction; only the first gets the row binding context, every other relative path is reported as an error'
priority: medium
state: open
first_seen: 2026-11-25
checked_upstream: 2026-11-25
evidence:
  - '@abap2ui5/linter with the S5S branches (abap2UI5/linter builder-helpers-across-classes) on oblomov-dev/S5S_DEV (DEV): /kro/ui504_cl_app_001 render_main( ) - a sap.ui.table.Table with rows = {/MT_TABLE_DISPLAY}, columns built in a LOOP, each column''s template filled in IF layout->fname = … ELSEIF … arms (RadialMicroChart, Button, GenericTag). Six errors "binds {ANZSER} relatively, but the control has no binding context" on the 3rd and later controls of the template'
  - 'the same template with one arm only reports nothing (probe, 2026-11-25); the arms are mutually exclusive at runtime, the template holds exactly one control'
  - 'abap2UI5/linter open issues and PRs checked 2026-11-25 (#195, #196, #197): nothing on this'
---

# relative-binding-without-context: arms of a row template

```abap
DATA(col) = columns->ele( n = `Column` ns = `table`
                    )->tag( `Text` )->a( n = `text` v = `Count`
                    )->ele( n = `template` ns = `table` ).
IF layout->fname = 'T_SERNR'.
  col->tag( `Button` )->a( n = `text` v = `{ANZSER}` ).          " reported
ELSEIF layout->fname = 'RECOUNT'.
  col->tag( `GenericTag` )->a( n = `text` v = `{COUNT_STATUS_TEXT}` ). " reported
ENDIF.
```

## Motivation

The reconstructor replays every arm of an IF / CASE and lands their
controls side by side, marking the container `branched`. A row template
(`template` of sap.ui.table.Column, `items` template of sap.m.Table) is a
0..1 aggregation; the walk gives the row context to its first child and
judges the others as controls outside any context - an error-level finding
on correct code, as many times as there are arms.

## Proposal

In a `branched` template aggregation every child is an alternative of the
others: each one gets the row context the first one gets. The
`too-many-children` / cardinality reading of a branched 0..1 aggregation
already stands down; the context propagation should follow it.

## Must not change

- Two controls written unconditionally into one 0..1 template are still a
  cardinality finding.
- A relative path outside any row-bound container is still reported.
