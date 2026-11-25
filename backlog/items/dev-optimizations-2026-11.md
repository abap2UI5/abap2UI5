---
target: abap2ui5
title: 'Optimization round 2026-11: what went in, and the two ideas that need an opt-in'
summary: A review of the JavaScript and ABAP code on DEV found the hot paths already tuned; one finding with a measured effect (the load order of the first page) and a handful of small ones are implemented, and two - dropping stale bindings, skipping the rebuild of an identical MAIN view - are not, because apps can see them; both would need an option on the client API
priority: low
state: open
first_seen: 2026-11-23
checked_upstream: 2026-11-23
upstream: abap2UI5/abap2UI5
evidence:
  - 'first page load, Chromium, cold cache, +40 ms latency, median of 5: first view 3.31-3.46 s before, 2.81-2.95 s with the bundle preload and data-sap-ui-libs="sap.m" on the page; the bundle is requested once, no console warning'
  - 'delivered bundle: 354 KB comment-stripped, 250 KB minified with identifiers kept (gzipped 81.8 KB -> 70.9 KB), 191 KB / 55.6 KB gzipped without the custom controls, which are a bundle of 57.5 KB / 15.4 KB gzipped on demand; mangled the whole would have been 58 KB gzipped'
  - 'a MAIN rebuild in Chromium (OpenUI5 1.153.0, form + tabs + 6-column table, median of 15): 107 ms at 394 controls, 314 ms at 1,434; a model push with changed values 22 ms / 84 ms'
  - 'corpus (742 app classes in samples-controls and samples-stack): 31 re-display MAIN from their event path, 14 of them with identical XML; samples-controls 351 and 289 and samples-stack 016 / 021 / 028 rely on the rebuild (a closed MessageStrip comes back, a FileUploader forgets its file); no class stores view XML, a builder or a bind path in an attribute'
  - 'after the round: 1,051 ABAP unit test methods, 1,926 JS specs, e2e 97 (OpenUI5 1.144.0) and 54 (1.71.80) in two cold runs, abap2UI5/protocol DEV backend suite 91 of 91 and frontend suite 88 passed / 4 skipped'
---

# Optimization round 2026-11: what went in, and the two ideas that need an opt-in

The maintainer asked for a general look at optimization potential on DEV
(2026-11-22) and then for all of it to be implemented. The honest summary of
the review: event handling, the model delta, the request and the draft store
are already in the microsecond-and-one-statement range - per roundtrip one
SELECT, one INSERT, one COMMIT, an average response of 731 B. What was left
is below.

## Implemented

1. **The first page loads the bundle and sap.m while UI5 boots**
   (`z2ui5_cl_ui5_http_handler`): a `<link rel="preload" as="script">` for
   `?z2ui5-bundle=<hash>` and `data-sap-ui-libs="sap.m"` on the bootstrap
   tag. No hint for a path ending in a slash (the control strips it - the
   URLs would differ and the bundle load twice), none without a path, and
   no second `data-sap-ui-libs` next to one the exit sets.
2. **The frontend is delivered minified** (`tools/app2abap/trans2abap.js`
   `minifyJs`): comments and whitespace only, identifiers stay.
3. **Model**: include row types and TIMESTAMP / TIMESTAMPL columns on the
   fast serialization path, byte-identical to ajson
   (`z2ui5_cl_ui5_util_context`); the fast-path tables spliced into the
   model in one pass (`z2ui5_cl_ui5_srv_model=>json_fast_splice`).
4. **`window_bind_tab( total = <no attribute> )`** no longer rebuilds the
   attribute table per call - and no longer leaves the bind service on a
   row of the table the swallowed search had cleared
   (`z2ui5_cl_ui5_srv_model=>main_attri_find`). The stale row was a real
   defect: the new test failed on the old code.
5. **The user exit is asked once per request** for its POST config, and a
   response that is not the page takes its five headers without the page
   config when no exit is installed (`z2ui5_cl_ui5_user_exit`).
6. **Frontend**: a response is remembered by a token, not held whole
   (`core/ViewSlots.js`, `core/actions/Slots.js`); one abort mechanism per
   request with a timer that is released (`core/Server.js`
   `_openRequest`); the action targets protocol 3 left without a writer
   are gone (`ROUTER` sync, `VIEW_SLOTS` display / updateModel).
7. **The custom controls are a bundle of their own**
   (`?z2ui5-bundle=cc`, `core/CustomControls.js`,
   `z2ui5_cl_ui5f_cc`), loaded once per page before the first view that
   names one: the eager bundle is 191 KB where it was 247 KB (56 KB
   gzipped, was 70 KB). 19 of 763 sample apps use a control. The residual:
   JavaScript outside a view that requires `z2ui5/cc/<Name>` on a page
   whose views name none has to load the bundle itself
   (`docs/agents/decisions.md`).

## Not implemented - both are visible to apps

### Dropping bindings the screen no longer uses

Bindings only grow: after an app replaces its MAIN view, the tables the
earlier view bound still travel in `MODEL` and are snapshotted and compared
on every roundtrip. No rule the backend can apply by itself is safe:

- MAIN re-displayed from stored XML or stored paths, in a roundtrip in
  which any other bind ran, would lose its bindings;
- a popup, popover or nested view opened earlier and still open when MAIN
  is displayed again - the request carries no slot state, and a popup can
  close on the client without a roundtrip, so the backend cannot know;
- paths used outside the XML it sends (follow-up actions, fragments a
  control loads) defeat a scan of the XML as well;
- the failure is silent: an edit to a wrongly dropped path is skipped.

The corpora would pass the rule - they are uniformly built views that bind
everything again on every display - which says little about apps in the
field. **An explicit opt-in would be safe** (an additive option of the
client API, e.g. on `view_display( )`: "what this roundtrip did not bind is
unbound"). Decide whether the API should grow by it.

### Skipping the rebuild of an identical MAIN view

When a response displays MAIN with the XML and options the slot already
holds, the view is destroyed and built again; a model push would be 85 to
230 ms cheaper. Apps rely on the rebuild: a re-display is how a closed
MessageStrip comes back and a FileUploader forgets its file (the corpus
says so in comments), an edit not sent yet dies with the view, the popup and
popover are taken down with it (the protocol's `slots.main-tears-down`),
and a control that acts when it is rendered acts again. **It can only be an
opt-in** as well - an option of `view_display( )` that says "keep the view
if it is the same".

## Checked and found fine - do not re-propose

- `structuredClone` in place of the JSON round trip for a slot's model
  (`actions/Slots.js`): 1.07 ms against 1.01 ms at 1,000 rows.
- Lazy loading of the developer tools: they already are; the eager part
  (the capture and the recorder) is deliberate (`docs/agents/decisions.md`).
- The request: 141 B for a typical event; static blocks are latched.
- Draft store: one SELECT, one INSERT, one COMMIT per roundtrip; cleanup
  only on a first start.
- Mangling the bundle's identifiers: 58 KB gzipped instead of 71 KB, at the
  price of unreadable stack traces - a decision of its own, not taken.
