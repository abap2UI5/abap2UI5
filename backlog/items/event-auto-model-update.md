---
target: abap2ui5
title: 'Push the model automatically when an event round-trip changed it'
summary: detect a model change during an event round-trip and send the model automatically — removes the mandatory `view_model_update( )` (230 calls / 125 ports) and its silent-stale-UI failure mode
priority: medium
state: filed
first_seen: 2026-08-11
upstream: abap2UI5/abap2UI5
filed: https://github.com/abap2UI5/abap2UI5/pull/2545 — implemented, always on, pending merge
evidence:
  - 230 `view_model_update( )` calls across 125 ports in `abap2UI5/samples-controls`, every one of them boilerplate
  - a forgotten call is a stale UI with no error anywhere — no gate can see it
  - implemented 2026-08-11; all three abaplint builds, the transpiled unit suite and the JS/guide/API-snapshot gates green
---

# Push the model automatically when an event round-trip changed it

**Status: implemented on branch, pending merge** — implemented 2026-08-11 on
the abap2UI5 branch `claude/ai-demokit-samples-simplify-kneyyl`
(PR [abap2UI5#2545](https://github.com/abap2UI5/abap2UI5/pull/2545)), and
**always on**: snapshot after delta-apply / before `main( )`, compare in
`main_end`, response byte-identical to an explicit `view_model_update( )`,
unchanged model still responds `{}`. It shipped first as an opt-in
(`set_model_auto_update( )`); the maintainer decided the same day that the
behaviour should simply be the default, so the activation method was
withdrawn again — the public API is byte-identical to before.
`view_model_update( )` **stays in the interface and keeps working**: for the
ordinary "changed data, now push" case it is now redundant, but it still
FORCES the unchanged model out, which detection cannot express (resetting a
control that wrote a bound property on its own). Popup/popover own their own
model instance, so `popup_model_update( )` / `popover_model_update( )` are
still required. All three abaplint builds, the transpiled unit suite (4
tests) and the JS/guide/API-snapshot gates green.

**Consequence for this corpus (do NOT bulk-remove yet):** the 230
`view_model_update( )` calls in 125 ports become redundant once the branch is
merged AND the `A2UI5_PIN` moved — but not before, and removing them is a
separate, gate-verified change (the ports must keep working against the
pinned framework version). Delete this folder once the branch is merged
upstream (pr/ convention: folders hold open requests only). Original proposal
below.

## Motivation

After changing bound data in an event handler, every app must remember to call
`client->view_model_update( )` — or the UI silently shows stale data. Measured
over this corpus: **230 calls in 125 of 365 ports**, and in the minimal ports
the call is half of the handler body, e.g. app 348
(`src/02/b19/z2ui5_cl_smpc_app_348.clas.abap`):

```abap
WHEN `LAYOUT_CHANGE`.
  currentbreakpoint = client->get_event_arg( ).
  client->view_model_update( ).
```

The real cost is not the line — it is the failure mode of forgetting it.
A handler that mutates bound state without the call is syntactically clean,
passes every gate (the render gate mocks the model, structural-diff never sees
behaviour), and simply renders stale. That is the same silent-failure shape
that motivated the `dead-event-wire` and `relative-binding-without-context`
linter rules — except this one is not statically detectable in general (the
mutation can happen behind any method call).

## Current behavior

The decision to send the model is a manual flag:

- `z2ui5_cl_core_client=>z2ui5_if_client~view_model_update` sets
  `ms_next-s_set-s_view-check_update_model = abap_true` (src/01/02/z2ui5_cl_core_client.clas.abap).
- `z2ui5_cl_core_handler=>check_view_update_needed` returns true when a slot
  ships new XML or one of the three `check_update_model` flags is set;
  otherwise `main_end` responds with `ms_response-model = '{}'`
  (src/01/02/z2ui5_cl_core_handler.clas.abap).

So on an event round-trip that displays nothing and sets no flag, the app's
model changes stay on the server until the next full render.

## Proposed change

Detect the mutation instead of asking the app to declare it. In
`main_process` / `main_end`, for an event round-trip that ships no view XML:

1. serialize the model once **after** the incoming model deltas are applied
   but **before** `app->main( )` runs (`model_json_stringify( )` — the same
   call `main_end` already uses),
2. serialize again after `main( )` returned,
3. if the two strings differ, respond with the second one exactly as if
   `view_model_update( )` had been called.

Nothing changes on the wire or in the frontend — the response is
byte-identical to today's explicit call, so the thin-frontend contract is
untouched; the backend only becomes the authority on *whether* its own state
changed, which it arguably should be.

Costs and options, honestly:

- The diff costs one extra `model_json_stringify( )` per event round-trip
  (the "after" one is the response payload itself when a change is detected;
  when no change is detected today's `'{}'` short-circuit is lost). For large
  models that is measurable CPU — worth a benchmark against `db_save( )`,
  which already XML-serializes the full app state every round-trip anyway.
- The "before" stringify cannot be replaced by a hash stored at the previous
  render: the incoming two-way deltas already mutate the state before
  `main( )`, so a stale hash would false-positive on every delta-carrying
  event. The clean comparison point is after delta-apply, before `main( )`.
- If default-on is judged too invasive, an **opt-in** keeps it free for
  everyone else: `client->set_model_auto_update( )` once in `check_on_init`
  (mirroring `set_nav_routing`), or a marker on `z2ui5_if_app`.
  `view_model_update( )` stays supported either way — existing apps are
  unaffected.

## Payload trade-off — deliberate non-pushes lose their suppression

A per-push response is **full-model already**: `view_model_update( )` sends
`model_json_stringify( )` whole, not a delta — changing one scalar ships the
whole bound table today too. Auto-detection therefore never makes a single
push bigger, and an unchanged model still responds `'{}'`. What it does
change is *when* pushes happen: change-triggered instead of
developer-declared. An app mutates its model without pushing for two
reasons:

1. **forgot** — the silent-stale-UI bug this request wants to remove;
2. **deliberately** — server-side bookkeeping in a public attribute, data
   prepared for a later popup, a change the currently rendered view does not
   bind. Today that costs nothing; with auto-detection it ships the full
   model.

Case 2 is a real optimization valve, so default-on needs one of:

- **opt-in** (see above) — large-model apps simply keep it off;
- **default-on + per-round-trip suppression** (`client->skip_model_update( )`)
  — inverts the burden: the rare deliberate case becomes explicit, the common
  forgotten case disappears;
- **response-side model deltas** — the symmetric counterpart of the request
  direction, which is already delta-based. Sending only changed paths would
  fix the "one scalar → whole table" cost for the *explicit*
  `view_model_update( )` too, and the before/after diff computes exactly
  those paths as a by-product. It is however a real model-layer rework (the
  frontend would merge instead of replace) — the same category in which
  `named-json-models` was declined — so it is listed as the long-term shape,
  not as a precondition.

## Example

App 007 (`sap.m.CheckBox` tri-state, `src/01/b02/z2ui5_cl_smpc_app_007.clas.abap`) today:

```abap
WHEN `PARENT_CLICKED`.
  child1 = client->get_event_arg( ).
  child2 = client->get_event_arg( ).
  child3 = client->get_event_arg( ).
  client->view_model_update( ).
```

with auto-detection the last line disappears — and a new app that forgets it
can no longer render stale.
