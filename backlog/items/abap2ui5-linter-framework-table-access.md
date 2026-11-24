---
target: abap2ui5-linter
title: 'Report SQL on the framework''s and the addons'' own tables in app code'
summary: 'an app that reads or deletes z2ui5_t_01 (drafts) or z2ui5_t_11 (layouts) directly bypasses the owner check, the draft store and the authority checks the APIs apply, and breaks when the internal table changes'
priority: high
state: open
first_seen: 2026-11-24
checked_upstream: 2026-11-24
evidence:
  - 'a downstream app repository, review of 2026-11 - a method delete_session_drafts deletes from z2ui5_t_01 directly, and a layout copy app reads and writes z2ui5_t_11 directly'
  - 'abap2UI5 cdd2fb25 / 04ead8ec (2026-11-24): drafts are pruned by the framework (draft_keep_per_chain, z2ui5_if_ui5_draft_store=>prune_chain), behind a draft store a host can replace (z2ui5_if_ui5_draft_store) - a DELETE on z2ui5_t_01 bypasses both, and a replaced store does not use the table at all'
  - 'abap2UI5/layout-management 569a35e: z2ui5_cl_layo_manager=>select_layouts_by_range( ) reads layouts by ranges, also of every user, through the layout authority interface (z2ui5_if_layo_auth)'
  - 'docs/agents/building-apps.md section 5: "the framework''s own tables (z2ui5_t_01) are internals that may change - naming one from an app is borrowing a table, not using an API"'
  - '@abap2ui5/linter 0.11.0: non-released-api reports framework CLASSES outside src/02, not SQL on tables; no issue in abap2UI5/linter (searched 2026-11-24)'
---

# Report SQL on the framework's and the addons' own tables in app code

## Motivation

The framework and its addons keep their state in tables of their own:
`z2ui5_t_01` holds the drafts, `z2ui5_t_11` the layouts of
layout-management. They are reachable from any app with one `SELECT` or
`DELETE`, and an app that wants to clean up its drafts or copy a layout to
another user is tempted to do exactly that.

What it bypasses:

- **the owner and authority checks** the API applies - a layout copied by
  `INSERT` skips `z2ui5_if_layo_auth`, and a draft deleted by hand may
  belong to an app stack or an app state link the framework keeps;
- **the draft store** - a host can replace it
  (`z2ui5_if_ui5_draft_store`), and then `z2ui5_t_01` is not where the
  drafts are;
- **the shape**, which is internal and changes without notice.

The APIs exist: the framework prunes drafts itself since 04ead8ec
(`draft_keep_per_chain`, `draft_exp_time_in_hours` in the exit), and
`z2ui5_cl_layo_manager=>select_layouts_by_range( )` reads layouts of any user
through the authority interface.

## Current behaviour

- `non-released-api` reports a framework class outside `src/02` named from
  an app; a table is not a class and is not judged.
- `docs/agents/building-apps.md` section 5 says not to, as prose.

## Proposed rule

`framework-table-access`, severity warning.

Report an Open SQL statement (`SELECT`, `INSERT`, `UPDATE`, `MODIFY`,
`DELETE`, `OPEN CURSOR`) whose data source is a table of a fixed list
shipped with the linter - the `z2ui5_t_*` tables of abap2UI5 and of the
addons, each with the API to use instead:

| Table | Holds | Instead |
|---|---|---|
| `z2ui5_t_01` | drafts | the exit's `draft_keep_per_chain` / `draft_exp_time_in_hours`; `app_state_*` for a kept state |
| `z2ui5_t_11` | layouts | `z2ui5_cl_layo_manager` (`select_layouts_by_range( )`, …) |

The list is data: a new addon table is one entry.

## What it must not report

- Code inside the package that owns the table (the framework in abap2UI5,
  the addon in its own repository) - judged by the class prefix the list
  records per table.
- A table of the app's own namespace that happens to start with `z2ui5_`
  but is not on the list.
- A `TYPE` reference to the table or its line type (`DATA ls TYPE
  z2ui5_t_11`) - a structure, not an access.

## Example

```abap
DELETE FROM z2ui5_t_01 WHERE uname = @sy-uname.                          " reported
SELECT * FROM z2ui5_t_11 WHERE uname = @lv_from INTO TABLE @DATA(lt).    " reported

DATA(lt_heads) = z2ui5_cl_layo_manager=>select_layouts_by_range( … ).    " not reported
```
