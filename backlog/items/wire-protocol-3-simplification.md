---
target: abap2ui5
title: 'Protocol 3: what is implemented, what the protocol repository has to follow, and what is still open'
summary: The wire is protocol 3 - event flags as an object, the response sections VIEWS / NAV / ACTIONS, one owner per teardown rule, the route of an app start parsed by the frontend - and abap2UI5/protocol, cap2UI5 and the other frontends have to follow; events fired while a view is being built are kept, and three ideas are open with what was measured for them
priority: high
state: open
first_seen: 2026-11-22
checked_upstream: 2026-11-22
upstream: abap2UI5/abap2UI5
evidence:
  - 'baseline on DEV 1af8c19 (2026-11-22): 1031 ABAP unit test methods and 1867 JS specs green, abap2UI5/protocol f592b16 backend suite 88 of 88 and frontend suite 83 passed / 4 skipped; `check:api` and `check:shared` red before any change of this item (the snapshot and the app-template mirror of #3040)'
  - 'after the protocol-3 changes: 1026 ABAP unit test methods, 1874 JS specs, and in Chromium against the transpiled backend 92 e2e specs on OpenUI5 1.144.0 and 49 on 1.71.80'
  - 'OpenUI5 1.71.80 in Chromium: a handler wired as `.eB([''LIVE'',{queueLast:true,noBusy:true}], ''arg'', ${$source>/text})` is called with `[["LIVE",{"queueLast":true,"noBusy":true}],"arg","x"]`; on 1.153.0 a view with XML templating reads the object too'
  - 'browser experiment through the protocol suite''s mock backend, before the fix: a `core:HTML` whose `afterRendering` is wired to `.eB` reached the backend on the FIRST response (POSTs: start, R1) and was dropped on a LATER one (POSTs: start, NEXT); after it: start, NEXT, R2, and an app that answers the event with the same view again stops at 26 POSTs'
  - 'usage counted in abap2UI5/samples-controls (9f3378a, 690 classes) and abap2UI5/samples-stack (4e268b9, 84 classes); abap2UI5/samples could not be read'
---

# Protocol 3: what is implemented, what the protocol repository has to follow, and what is still open

The roundtrip is a written contract - [abap2UI5/protocol](https://github.com/abap2UI5/protocol)
holds the specification, the JSON Schemas and two conformance suites, and
`test.yaml` runs both against every pull request here. The maintainer decided
on 2026-11-22 to break it: the changes below are in this repository, **the
protocol repository, cap2UI5 and the other frontends are not updated yet**.
Until they are, `conformance_backend` and `conformance_frontend` fail against
the commit `test.yaml` pins.

## Implemented here (protocol 3)

`z2ui5_if_ui5_types=>c_protocol` and `PROTOCOL` in
`bundle/webapp/core/Server.js` are 3.

1. **The flags of an event wire are one object.**
   `.eB(['LIVE_CHANGE',{queueLast:true,noBusy:true}], args)` where positions
   `[4]` and `[5]` of the event array carried them behind three slots that
   were always `false`. Writer: `z2ui5_cl_ui5_srv_event=>get_event`. Reader:
   `Lib.eventOptions` (a positional flag is logged and not read).
2. **The response says what the screen is, and what to do on it.**

   ```json
   { "S_FRONT": { "ID": "...", "APP": "...", "PROTOCOL": 3,
       "VIEWS": { "MAIN":  { "XML": "<mvc:View/>", "OPT": { "transition": "slide" } },
                  "POPUP": { "DESTROY": true } },
       "NAV": { "setNavRouting": "KEEP" },
       "ACTIONS": [["SET_FOCUS","id1"]] },
     "MODEL": { } }
   ```

   `S_ACTION.T_SYSTEM` and `S_ACTION.T_CUSTOM` are gone. A section that says
   nothing is absent. The frontend applies `VIEWS` in its own order (MAIN,
   NEST, NEST2, POPUP, POPOVER - `View1._applyViews`); the backend sorts
   nothing (`z2ui5_cl_ui5_frontend=>slots_serialize`, `nav_serialize`).
3. **One owner per teardown rule.** The backend queues the teardown of
   POPUP and POPOVER for every app hop and every app start
   (`z2ui5_cl_ui5_action=>prepare_app_stack`, `factory_first_start`). The
   frontend no longer takes them down when a response names another class.
   That a new MAIN view takes the standalone slots down is the frontend's
   rule alone (`actions/Slots.js` `displayMain`); the backend no longer drops
   a `popup_destroy( )` next to a `view_display( )`.
4. **The route of an app start travels parsed.** A request without a draft
   id carries `S_FRONT.ROUTE` - `{ "APP", "DRAFT" }` for
   `#/app/<CLASS>/<DRAFT>`, `{ "APP_STATE" }` for an app-state link - read by
   `Router.startRoute`. The backend's six route parsers are deleted; it keeps
   `hash_get_shell_part` for the links it composes. `HASH` still travels with
   every request (an app reads `client->get( )-s_config-hash`).
5. **One implementation of the empty-argument rule**
   (`z2ui5_cl_ui5_srv_event=>args_trim_trailing`). No wire change.
6. **Events fired while a view is being built are kept** (2026-11-22, no
   wire change). A control that fires from its rendering - `cc/Storage.js`
   with the value it found, an `afterRendering` an app wired - used to reach
   the backend on the first roundtrip only (it was not busy, and the event
   superseded the response that was building the screen) and was dropped on
   every later one. `View1.eB` keeps such an event (`aRenderEvents`), the
   first roundtrip is busy like every other (`App.controller` `startApp`),
   and the events go out one per landed roundtrip. An unbroken run of 25
   ends with a line in the log - an app that answers a rendering event with
   a view that fires it again. Measured in Chromium through the protocol
   suite's mock backend: first response POSTs `start, R1`, a later one
   `start, NEXT, R2` (before: `start, NEXT`), the looping app stops at 26.
7. **Window requests are kept per table** (`actions/Slots.js`
   `keepWindowRequest`, `dispatchQueuedWindows`), by the model that asked.
   One place for all tables lost every request but the last, and a request
   sent while its view was being built was dropped when it was due.

## What the protocol repository has to follow

| There | Change |
|---|---|
| `spec/versioning.md` | protocol 3 and what broke; open question 15 (the window and the number) is answered with it |
| `spec/response.md` | `VIEWS` / `NAV` / `ACTIONS` in place of `T_SYSTEM` / `T_CUSTOM`; no slot order for the backend; the two teardown rules with their new owners |
| `spec/request.md` | `ROUTE`; `HASH` is no longer what an app start is resolved from |
| `spec/navigation.md` | app start resolution reads `ROUTE`; the `ROUTER` action is the `NAV` section |
| `spec/actions.md`, `profiles/ui5.md` | `ACTIONS`; the `.eB` wire form with the options object |
| `schema/request.schema.json`, `response.schema.json` | the keys above |
| backend checks | `slots.*`, `response.*`, `route.*`, `ui5.event-wire`: read the sections; send `ROUTE` where they sent a hash; a hop and an app start carry both teardowns |
| frontend checks | `slots.app-change` turns round (the frontend must NOT tear down on the name); `ui5.wire-queue-last` and the mock's responses in the new shape; `router.*` |
| `conformance/apps`, `traffic/` | record again; cap2UI5's twins and `@cap2ui5/cds-plugin` |
| the other frontends | the agent client of abap2UI5/mcp-server, the terminal and Adaptive Cards renderers, the Web Components frontend: read `VIEWS` / `NAV` / `ACTIONS`, parse the options object out of a view, send `ROUTE` |

Then move the pinned commit in `test.yaml` (both jobs).

## Open - decide first

### Park a Back/Forward, then remove the stale checks

A first response can no longer be superseded by an event of its own view
(below, "Events fired while a view is being built"). Two paths still
dispatch a request while another is in flight or being processed:
`Server.restoreFromRoute` (Back/Forward aborts the request in flight), and
any event after `isBusy` went false while the follow-up actions of the
response still await (`View1._processAfterRendering` ends the busy state
BEFORE the actions, so that `SET_FOCUS` finds its control under no
overlay). While both exist, the "superseded but not replaced" handling there
and the stale checks in `core/Server.js` (`isStale( )` eight times) stay.
Parking the restore like an app-owned hash change
(`Router.dispatchPendingAppHash`) removes the first; the second needs the
busy STATE to outlast the overlay.

### One model per app instead of one per slot

POPUP and POPOVER get a deep copy of the response model (`dataForSlot` in
`actions/Slots.js`), their own changed-path set, the fan-out of every
response into every open slot with the re-application of unsent edits
(`updateModelIfRequired`) and an ownership check per slot. A response carries
the model of exactly one app, and MAIN and the nested views already share
one. Changes what a popup's event sends (it would carry MAIN's pending edits
too - the protocol's `model.slot-model` check). Risks to test:
`SET_SIZE_LIMIT` is per slot (one sample sets it for `cs_view-popup`), and a
popup's bindings re-evaluate with MAIN's.

### Fewer ways to own the URL hash

Five mechanisms share one hash in `Router.sync`: KEEP routing, FRESH
routing, the app-state hash, the app-owned listener, and a suffix written
with `history.pushState`. In samples-controls all 10 apps that write a hash
register the listener; `hash_routing` and `app_state_set_active` have no
caller in either corpus, `app_state_get_href` has 11. Candidates:
`hash_set( )` / `hash_replace( )` only with a listener (drops
`writeLegacyUrl`), and one URL format for the app-state link and the KEEP
route (old links die with their draft within hours).

## Checked and dropped - do not re-propose

- **Navigation options: absent means "no change"** for `setAppStateActive`.
  The backend re-asserts the flag in three lines of `main_end_nav`; making
  the frontend remember it needs a tri-state on the wire (off has to be
  said), a reset on the app switch and the same send conditions the routing
  mode already has (`nav_mode_sent`). More code on both sides for 34 B per
  response of an app that uses the hash.
- **Send the live device fields with every request** to save one latch in
  `core/Session.js`. The block is 77 B, a typical event request 103 to 120 B.
- **Outbound model as a per-attribute patch.** A second model path next to
  the full one; only with a measured case.
- **Slot state as one map.** 17 of the 20 direct accesses to the five view
  and controller fields are already inside `core/ViewSlots.js`.
- **The app stack as a list in the draft.** `id_prev_app_stack` is a column of
  `z2ui5_t_01`, a field of the public `z2ui5_if_client=>ty_s_get-s_draft` and
  of the draft-store seam.
- **Typed arguments in the action list.** `t_arg` is a `string_table`, so
  `castArgAuto` in `core/actions/ControlCall.js` has to keep guessing. This
  belongs to the action object - see `frontend-action-named-api`.
- **The shell part of the hash from the frontend as well.** It is needed on
  every roundtrip (`app_state_get_href( )`, the start page's links) and
  `client->get( )-s_config` has no field for it; `hash_get_shell_part` stays.
- **`z2ui5_cl_ui5_srv_model`'s binding search** and the pre-`main( )`
  snapshot: decided in `docs/agents/decisions.md`.

## How to check a change here

```bash
npm run verify:full                 # this repository
# the protocol's suites against this checkout, as test.yaml runs them:
npm run pack:node-runtime -- --out <dir>
cd <checkout of abap2UI5/protocol> && npm ci
npm install --no-save <dir>/abap2ui5-node-runtime-*.tgz
OPEN_ABAP_CORE_DIR=<here>/node/deps/open-abap-core node scripts/run-conformance.mjs node-runtime
ABAP2UI5_HOME=<here> CHROMIUM_BIN=<chrome> node conformance/backend/bin/abap2ui5-conformance.mjs frontend --adapter ui5
```

The frontend suite's mock backend is also the quickest way to try a timing
question in a real browser: `runFrontendSuite({ adapter: "ui5", checks: [...] })`
with a check of your own, as the experiment above did.
