---
target: abap2ui5
title: 'A table cell whose value will not convert is skipped silently, so a user edit disappears with no error anywhere'
summary: delta_apply_field ends in `CATCH cx_root ##NO_HANDLER` ("skip just this cell"), so a conversion failure in a ROW cell keeps the old value while the browser still shows what was typed - unlike the scalar path, which raises JSON_PARSING_ERROR
priority: medium
state: open
first_seen: 2026-08-26
upstream: abap2UI5/abap2UI5
evidence:
  - z2ui5_cl_ui5_srv_model.clas.abap:874-916 - delta_apply_field's WHEN OTHERS does `<comp> = io_row_d->get_string( iv_path )` and the method ends in `CATCH cx_root ##NO_HANDLER. " skip just this cell`
  - the scalar attribute path is the opposite - z2ui5_cl_ui5_srv_model.clas.abap:159-177 catches and RE-RAISES as `JSON_PARSING_ERROR - attribute '<NAME>' (model path '/<NAME>')`, so the same mistake in a non-table field is loud
  - samples-controls app 570 - measured on the transpiled backend: typing `1250.00` into the Price cell and pressing Save stored 1250, while `1,250.00`, `1 250`, `12.50 EUR` and `abc` all left the model unchanged with no error, no toast and no valueState. The accepted case is what proves it is a conversion failure and not a dead wire
  - samples-controls app 093 - the same, measured: `1,455.22` typed into Salary came back as the old value after the round trip
  - both ports passed every gate and the e2e smoke throughout, because nothing anywhere reports the skip
---

# A cell edit that will not convert vanishes without a word

## Motivation

`##NO_HANDLER` here is a deliberate choice and a defensible one: one bad cell
should not take down a delta carrying many good ones. The problem is not that
the cell is skipped, it is that **nothing can find out**.

The app cannot tell. The user cannot tell - the browser still shows the text
they typed, because the client model was updated before the round trip; only the
backend quietly kept the old value. A port whose Save handler relies on the
write-back (rather than reading the event) therefore discards input and reports
success.

The asymmetry with the scalar path is the sharpest argument: the identical
mistake in a non-table field raises `JSON_PARSING_ERROR` and the app dies
loudly. In a row cell it is silent. Two ports in samples-controls carried this
in production form until it was measured.

## Proposed change

Keep the skip, add a trace of it. Something an app can read after the round trip
- a collected list of `(table, row, field)` the delta could not apply, exposed
the way other framework diagnostics are - would be enough for a port to react,
and enough for the e2e harness to assert on.

## What the change must NOT do

- **It must not start raising.** Turning the skip into an exception would make
  one unconvertible cell kill an otherwise valid delta, which is the behaviour
  the `##NO_HANDLER` was chosen to avoid.
- **It must not report a cell the app never sent.** Only a value that actually
  arrived and failed to convert belongs in the trace; an absent field is not an
  error.
- **It must not change the scalar path.** That one already raises, and apps
  depend on the message.
