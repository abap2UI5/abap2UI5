---
target: abap2ui5
title: 'A skipped delta cell names the field but not the record it sits in, nor the value that was refused'
summary: '`client->get( )-t_model_skipped` locates a top-level cell exactly, but a NESTED cell loses its parent row, and no entry carries the refused value — so the one message an app most wants to write, quoting what the user typed, is not expressible'
priority: medium
state: open
first_seen: 2026-08-27
checked_upstream: 2026-08-30
upstream: abap2UI5/abap2UI5
evidence:
  - 'measured 2026-08-27 by writing the first consumer of the API (`ltcl_app_price_editor` / `ltcl_test_model_skipped` in `src/01/02/z2ui5_cl_ui5_client.clas.testclasses.abap`), driving the real path `model_json_parse` -> `ms_actual-t_model_skipped` -> `client->get( )`'
  - '`delta_apply_field` recurses with `iv_table = |{ is_cell-name }-{ is_cell-field }|` (`z2ui5_cl_ui5_srv_model.clas.abap`, in `delta_apply_field`; line 965 on 2026-08-30) and does NOT propagate `is_cell-row`; inside, `row = lv_tabix` (same method, line 931) is the INNER table index. So `MT_PRODUCT-T_POS` row 1 does not say which `MT_PRODUCT` row owns that `T_POS`'
  - 'the entry is `name` / `row` / `field` only — the backend kept the old value and the browser holds the new one, so `''1,250.00'' is not a valid price` is not expressible; only `Price of ''Monitor'' was not accepted`'
  - 'samples-controls app 570 already solves the same problem BETTER by hand: it binds the price as `string`, validates in its own Save loop, and toasts `Not a number, the old price was kept - Notebook: ''1,250.00''` — quoting the value the API cannot reach'
  - 'app 093 did the same on 2026-08-26 (`salary TYPE string`), both citing `delta_apply_field`''s `CATCH cx_root ##NO_HANDLER` in their source comments — so as of today NO port in any corpus can produce a `t_model_skipped` entry at all, and the API has no producer to prove itself against'
---

# A skipped delta cell names the field but not the record, nor the value

## What is there today

`6fce3ae2` kept the "skip just this cell" behaviour of
`z2ui5_cl_ui5_srv_model=>delta_apply_field` and gave it a trace, readable as
`client->get( )-t_model_skipped`. That was the right shape of fix: the skip
itself must stay, because one unconvertible cell must not kill a delta
carrying many good ones, and before this an app could not find out it had
happened at all.

The parts that work, confirmed by the first consumer:

- **`row` is a plain ABAP table index.** `READ TABLE mt_product INDEX
  ls_skip-row` reaches the cell with no translation, because the client array
  order is the model order.
- **The trace is per-roundtrip.** The request after a refusal sees an empty
  list, so a Save may legitimately succeed again.
- **One bad cell still does not kill the good ones** in the same delta.

## The two gaps

### A nested cell cannot be located

The recursion is called with the path but not the row:

```abap
delta_apply_nodes( EXPORTING io_delta = lo_sub->slice( `/__delta` )
                             iv_table = |{ is_cell-name }-{ is_cell-field }|
                   CHANGING  ct_tab   = <sub_tab> ).
```

`is_cell-row` — the parent's index — is dropped. Inside, `row` is `lv_tabix`
of the inner table. For a tree or any parent/child edit the app can name the
field and cannot name the record, which is most of what a message needs.

### The entry carries no value

An app can point at the cell and cannot quote what the user typed. That is not
a cosmetic loss. It is the difference between the two messages an app would
actually write, and the weaker one is the only reachable one.

## Why this matters more than it looks

The corpus already routed around the defect this API exists for. samples-controls
apps 570 and 093 both changed the bound cell to `string` and validate in their
own Save loop — and 570's message quotes the refused value, which
`t_model_skipped` cannot. So today the API is strictly less capable than the
workaround its own motivating example uses, and no port in any corpus can
produce an entry for it.

That is not an argument to withdraw it — the string workaround costs the app
its type — but it does mean the shape has never been pushed by a real
consumer, and these are the two things the first one hit.

## What would close it

Both are additive at the end of a public structure, which `check:api` accepts:

1. a parent row — either a `row_parent` component, or `name` carrying indices
   (`MT_PRODUCT[1]-T_POS`) so the whole path locates one record;
2. the refused raw value, as it arrived from the client.
