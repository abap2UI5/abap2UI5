---
target: abap2ui5
title: 'Simplify the frontend/backend wire: verified work packages up to protocol 3'
summary: Fifteen work packages that remove coupled special cases from the roundtrip protocol - five without a wire change, six as one protocol-3 change set, four that need a decision first - plus five ideas checked and dropped, each with the evidence it was verified against on 2026-11-22
priority: medium
state: open
first_seen: 2026-11-22
checked_upstream: 2026-11-22
upstream: abap2UI5/abap2UI5
evidence:
  - 'baseline on d3f2978 (2026-11-22): `npm run verify` green, 1230 ABAP unit test methods, 1855 JS specs, tree unchanged'
  - 'real roundtrips captured against the transpiled backend (`npm run express`): start page 308 B request / 5131 B response, hello world 356 / 657 B, an event with a delta 120 / 204 B, an event that changes nothing 103 / 100 B'
  - 'usage counted in abap2UI5/samples-controls (9f3378a, 690 classes) and abap2UI5/samples-stack (4e268b9, 84 classes); abap2UI5/samples could not be read in that session'
  - 'OpenUI5 1.71.80 sources from npm: `sap/ui/base/ExpressionParser.js` parses a map literal (`{` nud, identifier or string keys), so an object inside an event handler expression is available on the floor'
  - 'searched abap2UI5/abap2UI5 open issues 2026-11-22 for protocol / wire / S_ACTION / follow_up_action / hash routing / simplify frontend: nothing overlapping (the one hit, #3023, is about merging the frontend repository)'
---

# Simplify the frontend/backend wire: verified work packages up to protocol 3

**Written for an agent that implements one package per session.** Read the
root `AGENTS.md` and `app/AGENTS.md` first; this item repeats none of their
rules. Every package below names what was checked, what to change, which tests
move, and when it is done. Nothing here has been implemented.

## How to work through this

- One package, one pull request. Stage 1 packages are independent. Stage 2
  is ONE change set: it raises `z2ui5_if_ui5_types=>c_protocol` and
  `PROTOCOL` in `app/webapp/core/Server.js` from 2 to 3 together, once.
- Every change under `app/webapp/` ends with `npm run app2abap` (rule 2).
  `npm run verify:full` before the pull request.
- A package that ships is **deleted** from this item (the backlog keeps no
  `implemented` rows). Delete the whole item when the last one is gone.
- "Decide first" means: ask the maintainer, record the answer in
  `docs/agents/decisions.md`, then build. Do not pick a side alone.
- Before removing anything public, rerun
  `node .github/scripts/removal-blockers.mjs <checkouts of samples, samples-controls, samples-stack>`.

## The wire today (captured, protocol 2)

Request, `POST` body:

```json
{ "value": { "MODEL": { "NAME": "changed" },
             "S_FRONT": { "ID": "<draft>", "EVENT": "BUTTON_POST" } } }
```

Response:

```json
{ "S_FRONT": { "ID": "<new draft>", "APP": "Z2UI5_CL_UI5_APP_HI_WORLD", "PROTOCOL": 2,
    "S_ACTION": {
      "T_SYSTEM": [["VIEW_SLOTS","display","MAIN","<xml>"]],
      "T_CUSTOM": [["SET_FOCUS","INPUT_CLASSNAME","25","25"]] } },
  "MODEL": { "NAME": "" } }
```

An event wire in the view XML: `press=".eB(['BUTTON_POST'])"`, with flags
`.eB(['NAME',false,false,false,true,true], args)`.

Who reads the response keys, and so moves with stage 2: `View1.controller.js`,
`core/Server.js`, `core/FrontendAction.js`, `core/Lib.js`, `core/AppState.js`,
`core/actions/Browser.js`, `core/actions/ControlCall.js`, the developer tools
(`devtools/Inspect.js`, `Journey.js`, `Recorder.js`, `Help.js`), eleven unit
specs and four e2e specs under `node/tests/`, `z2ui5_if_ui5_types`,
`z2ui5_cl_ui5_handler` and its test class. The docs repository names none of
these keys. Outside this repository: abap2UI5/frontend (generated from here),
`@abap2ui5/node-runtime`, and any port that pairs its own frontend - the
protocol number is what tells them.

---

## Stage 1 - no wire change

### S1. Work off the removal plan (the cheapest package)

- **Verified:** `removal-blockers.mjs` against samples-controls and
  samples-stack: 0 of 11 names have callers. Counted separately: 0 calls of
  `view_model_update`, `popup_model_update`, `popover_model_update`,
  `nest_view_model_update`, `nest2_view_model_update`, `_event_client`,
  `_bind_edit`, `custom_mapper`, `custom_filter`; 0 view XML naming
  `destroyPopup` / `destroyPopover` / `destroyNestView` / `destroyNestView2` /
  `destroyView`.
- **Change:** what `docs/removal-plan.md` sections 1 and 3 list as open: the
  five empty `*_model_update` methods and `_bind_edit` of `z2ui5_if_client`,
  the `custom_mapper` / `custom_filter` parameters with `json_custom_set` and
  the mapper cache in `z2ui5_cl_ui5_srv_model=>main_json_stringify`, the five
  `destroy*` wrappers in `View1.controller.js`.
- **Decide first:** these are rule-5 breaks; the plan dates `_bind_edit` at
  about a year from 2026-07. The maintainer sets the release.
- **Blocker left:** abap2UI5/samples and the docs repository were not scanned.
- **Done when:** the API snapshot is rewritten, `changelog.txt` carries the
  `- BREAKING:` lines, `docs/removal-plan.md` ticks the entries.

### S2. The backend states every slot teardown itself

- **Verified:** three rules are split across both halves today.
  `z2ui5_cl_ui5_frontend=>slots_serialize` DROPS a popup/popover destroy next
  to a MAIN display because `actions/Slots.js` `displayMain` does it;
  `View1._processAfterRendering` destroys POPUP and POPOVER when `APP` differs
  from the app rendered before; `z2ui5_cl_ui5_action=>prepare_app_stack`
  queues the destroys only for a hop to the SAME class, the one case the
  frontend cannot see. `ViewSlots.destroy` is safe on a closed slot (its own
  comment, and the code returns on an empty slot after clearing the records).
  One destroy action is 33 B (`POPUP`) or 35 B (`POPOVER`).
- **Change (backend only, compatible with a protocol-2 frontend):**
  `prepare_app_stack` queues both destroys on EVERY hop (drop the class-name
  comparison); `factory_first_start` queues them too (a route restore changes
  the app without a hop; on a fresh page they are no-ops); `slots_serialize`
  stops deleting the destroys next to a MAIN display.
- **Tests:** the `slots_serialize` cases in
  `z2ui5_cl_ui5_handler.clas.testclasses.abap` (`test_system_destroy_only` and
  the three before it), `same_class_twice_in_stack`, the teardown assertion in
  `z2ui5_cl_ui5_action.clas.testclasses.abap`.
- **Done when:** a response of an app hop always carries both destroys, and
  the e2e specs `subapp-roundtrip` and `popup-binding` stay green.
- **Follow-up:** P2 removes the frontend half.

### S3. One implementation of the "empty argument" rule

- **Verified:** "an empty argument between filled ones keeps its position,
  trailing empties are dropped" is written twice in
  `z2ui5_cl_ui5_srv_event`: in `get_t_arg` (the `lv_pending` buffer) and in
  `get_event_client_ajson` (the `WHILE` that deletes from the end).
- **Change:** one private method that returns the trimmed argument table;
  both callers use it. No output changes.
- **Done when:** the existing byte-level tests of both forms pass unchanged.

### S4. Send the live device fields with every request

- **Verified:** `core/Session.js` keeps four latches (`configSent`,
  `ui5Sent`, `liveSent`, `locationSent`) and a per-request confirmation token
  (`pending`, `takePending`, `confirmSent`). Measured: the live block
  (`ORIENTATION`, `RESIZE`) is 77 B, the static device block 151 B, the UI5
  info 133 B, the location 123 B.
- **Change:** send the live block on every request and remove `liveSent`
  and the `live` half of the token. `configSent`, `ui5Sent` and
  `locationSent` stay: the UI5 info arrives asynchronously, so it needs its
  confirmation. Backend `session_merge` keeps working as it is (an arriving
  value wins).
- **Honest size of the gain:** one latch and part of the token, about 20
  lines. Skip this package if that is not worth 77 B per request.
- **Tests:** `node/tests/session.spec.js` (8 tests).

### S5. The first roundtrip runs under the busy protocol - decide first

- **Verified:** `App.controller.js` `startApp` calls `Server.roundtrip(ctx)`
  without setting `state.isBusy`; every later roundtrip sets it in `eB`. The
  comment in `View1._processAfterRendering` records what this cost: a control
  that fires while the first view renders dispatches request 2 and
  supersedes the response that builds the screen (measured there:
  samples-controls 350 and 534 lost their follow-up actions). The controls
  that fire without a user action: `cc/Storage.js` (`finished` from
  `onAfterRendering`), `cc/Geolocation.js`, `cc/Websocket.js`,
  `cc/MessageManager.js`, `cc/ExcelBridge.js`. On every LATER roundtrip the
  same event meets the busy guard and is dropped unless its wire carries
  `check_queue_last` - so today the behaviour differs between the first
  roundtrip and all others.
- **Change:** set `isBusy` (and the busy overlay) in `startApp`, and settle
  what happens to an event that arrives while a response is being
  PROCESSED (not while the request is in flight).
- **Decide first:** keep such an event and dispatch it after the response
  (recommended - it is what the first roundtrip does today, minus the
  superseding), or drop it like a click. A bound FIFO is needed if more than
  one control fires.
- **Done when:** a `Storage` `finished` on the first render reaches the
  backend, the follow-up actions of the first response run without the
  "superseded but not replaced" path, and the 1.71 e2e leg is green.

---

## Stage 2 - protocol 3, one change set

Raise both protocol constants in this change set and in no other. A
protocol-2 half paired with a protocol-3 half already answers with the
mismatch overlay (`Server.readHttp`); keep that test (`serverReadHttp.spec.js`,
"the wire version").

### P1. Views and navigation as response sections, not as actions

- **Verified:** `T_SYSTEM` carries at most one action per slot
  (`slot_reset`) plus one `ROUTER/sync`. Three mechanisms hide behind "it is
  an action": the `ROUTER` target in `core/actions/ControlCall.js` only
  STASHES its options on the response (`ctx.response._routerOptions`) and
  `View1` runs the real sync later; the model push is no action at all but
  the presence of `MODEL`; `View1._replacesMainOwner` scans the generic list
  for `VIEW_SLOTS / display / MAIN`.
- **Change, proposed shape (finalize it in the pull request):**

  ```json
  { "S_FRONT": { "ID": "...", "APP": "...", "PROTOCOL": 3,
      "VIEWS": { "MAIN": { "XML": "<xml>", "OPT": { "transition": "slide" } },
                 "POPUP": { "DESTROY": true } },
      "NAV": { "setNavRouting": "KEEP" },
      "ACTIONS": [["SET_FOCUS","id1"]] },
    "MODEL": { } }
  ```

  The frontend applies `VIEWS` in its own fixed order (MAIN, NEST, NEST2,
  POPUP, POPOVER); the backend no longer sorts. `NAV` goes straight into
  `Router.sync`. `ACTIONS` is today's `T_CUSTOM`.
- **Backend:** `z2ui5_if_ui5_types` (`ty_s_response`, `ty_s_action`,
  `ty_s_system_action`), `z2ui5_cl_ui5_frontend` (`slots_serialize`,
  `nav_serialize`, `queue_system`), `z2ui5_cl_ui5_handler`
  (`response_abap_to_json`, `actions_serialize`, `main_end`).
- **Frontend:** `View1.controller.js` (`_runSystemActions`,
  `_replacesMainOwner`, the `_routerOptions` read), `FrontendAction.js`
  (`runSystem`, `executeSystem`), the `ROUTER` stash hook, `actions/Slots.js`
  `action`, and the four developer-tools readers.
- **Stays:** the `VIEW_SLOTS` global target itself - a view closes its popup
  without a roundtrip through `.eF('CONTROL_GLOBAL','VIEW_SLOTS','destroy','POPUP')`
  (`map_client_event`).
- **Risk:** this reverses part of the move to `S_ACTION` that protocol 2
  made. Decide first; the argument is the three mechanisms above.

### P2. The frontend stops inferring teardowns (needs S2)

- **Change:** remove the `ViewSlots.destroy(POPUP / POPOVER)` on an `APP`
  change in `View1._processAfterRendering` (keep the clearing of
  `oQueuedEvent` / `oQueuedWindow` and of the app-owned state there). The
  rule "a MAIN display replaces the two standalone slots" stays, on the
  frontend only (`actions/Slots.js` `displayMain`): `view_display( )`
  documents it, and the backend cannot state it without an ordering rule
  between `popup_display( )` and `view_display( )`.
- **Done when:** each teardown rule has one owner - a MAIN display on the
  frontend, an app change on the backend.

### P3. Event flags as an object in slot [1]

- **Verified:** the event array is read by position in `View1.eB`:
  `[0]` name, `[1]` and `[2]` always `false`, `[3]` `useMainModel`, `[4]`
  `queueLast`, `[5]` `noBusy`. Nothing in `app/webapp` or in
  `z2ui5_cl_ui5_srv_event=>get_event` emits `[3]`. The sample corpora contain
  no hand-written `.eB(` (0 in code; one mention in a comment), so every wire
  comes out of `get_event`. Usage of the flags there: `check_queue_last` 78,
  `check_no_busy` 42, prevent-default 83. An options object as a SECOND
  argument is not possible: 983 event arguments in samples-controls are raw
  expressions, some of them object literals, and would be mistaken for it.
- **Change:** `get_event` emits `.eB(['NAME',{queueLast:true,noBusy:true}], args)`
  when a flag is set and the bare `['NAME']` otherwise; `eB` reads an object
  in `[1]` and keeps reading positions `[3]`-`[5]` when `[1]` is not one (a
  view rendered by an older backend, rule 7). Update the two frontend
  emitters: `actions/Slots.js` (`_z2ui5WindowSend`) and the `START_TIMER`
  dispatch in `actions/ViewOps.js`.
- **Tests:** `view1Events.spec.js`, `eventArgs.spec.js`, `windowModel.spec.js`,
  the `get_event` cases of `z2ui5_cl_ui5_srv_event`.

### P4. The frontend sends the parsed route

- **Verified:** the hash is parsed twice and mirrored by hand: `splitHash`,
  `segmentsOf`, `parse` in `core/Router.js`; `hash_split`,
  `hash_get_app_part`, `parse_app_route_rest`, `route_split`,
  `request_app_start_route`, `request_app_start_route_draft`,
  `request_app_start_draft` in `z2ui5_cl_ui5_handler` (about 230 lines, 36
  references in its test class). Apps read the raw hash
  (`client->get( )-s_config-hash`, used in samples-controls), so `HASH` keeps
  travelling. `hash_get_shell_part` has two callers (`app_get_url`,
  `z2ui5_cl_ui5_client` for `app_state_get_href( )`).
- **Change:** add `S_FRONT.ROUTE` = `{ "APP", "DRAFT", "APP_STATE", "SHELL" }`
  to a request without an `ID`; `request_json_to_abap` reads it; the seven
  parser methods and their tests go, their cases move to `router.spec.js`.
  `SHELL` replaces `hash_get_shell_part`.
- **No security change:** the hash is client-controlled today; the parsed
  values are exactly as trusted. `app_create` still checks the class.

### P5. Navigation options: absent means "no change"

- **Verified:** `Router.sync` ends in
  `write(ctx, mOptions.setAppStateActive ? "/z2ui5-xapp-state=<id>" : "", true)`,
  so a response that does not repeat the flag clears the hash. That is why
  `z2ui5_cl_ui5_handler=>main_end_nav` re-asserts `mv_app_state_active` on
  every response and keeps the `nav_mode_sent` latch for the routing mode.
- **Change:** the frontend remembers both per rendered app (reset where
  `_replacesMainOwner` already resets `hashEvent`); the backend sends each
  once when it changes and on an app-start-shaped request. `main_end_nav`
  shrinks to the hop cases.
- **Tests:** `router.spec.js` (48 tests), `nav-back-forward` e2e, the
  `main_end` cases of the handler test class.

### P6. Names that outlived their meaning

Rename in the same change set, nothing else: `T_CUSTOM` and
`_pendingCustomJs` (no custom JavaScript since 2026-09-22), `OVIEWMODEL`,
the request's intermediate `ARGUMENTS` / `ID` fields that `Server.roundtrip`
folds into `S_FRONT` and deletes again. Leave `SET_PUSH_STATE`,
`SET_NAV_ROUTING`, `eB`, `eF`, `eBP` alone - they are public names (rule 7,
`cs_event`). The `{ "value": … }` envelope stays readable both ways; a
launchpad proxy strips it.

---

## Stage 3 - decide first, then prototype

### X1. Remove the stale checks that S5 and X1a make unreachable

- **Verified:** `isStale()` is asked 8 times in `Server.readHttp`; the
  request stamp is read in 6 places each in `Server.js` and
  `View1.controller.js` and 7 in `actions/Slots.js`. Three paths bypass the
  busy guard and are the reason: the first roundtrip (S5),
  `Server.restoreFromRoute` (aborts the request in flight), `Server.reset`.
- **X1a, decide first:** a Back/Forward during a roundtrip is PARKED like an
  app-owned hash change already is (`Router.dispatchPendingAppHash`) instead
  of aborting. Visible change: Back waits for the running request, bounded
  by the 600 s timeout unless a shorter bound is added.
- **Not verified:** that an aborted `fetch` leaves the ABAP work process
  running to the end. It is the reason the abort would save nothing; check it
  on a system before arguing with it.
- **Then:** delete what no path reaches any more (`restoreSeq`, the
  superseded/replaced distinction). `serverRequestSeq.spec.js` (12 tests) and
  `concurrency.spec.js` describe today's behaviour and are rewritten.

### X2. Fewer ways to own the URL hash

- **Verified:** five mechanisms share one hash in `Router.sync`: KEEP
  routing, FRESH routing, the app-state hash, the app-owned listener, and
  the suffix written with `history.pushState`. Usage in samples-controls:
  `hash_set` 27, `hash_replace` 16, `hash_attach_changed` 18 - all 10 apps
  that write a hash register the listener; `hash_routing` 0,
  `app_state_set_active` 0, `app_state_get_href` 11. The `hash_*` events sit
  under "experimental" in `cs_event`.
- **X2a:** `hash_set( )` / `hash_replace( )` require the listener; the
  suffix branch (`writeLegacyUrl`) goes. No caller in the corpus depends on it.
- **X2b:** one URL format for "this draft": fold the app-state hash into the
  KEEP route. Old links die with their draft within hours anyway.
- **Unknown:** abap2UI5/samples and customer apps.

### X3. One model per app instead of one per slot

- **Verified:** POPUP and POPOVER get a deep copy of the response model
  (`dataForSlot` in `actions/Slots.js`), their own changed-path set, the
  fan-out of every response into every open slot with the re-application of
  unsent edits (`updateModelIfRequired`), an ownership check per slot, and
  the `useMainModel` flag. A response carries the model of exactly one app.
  MAIN and the nested views already share one model.
- **Idea:** one tracked model per app, shared by every slot that app filled.
- **Risks to test:** `SET_SIZE_LIMIT` is per slot today (one sample sets it
  for `cs_view-popup`); a popup's bindings re-evaluate with MAIN's; the
  comment at `dataForSlot` records the bug that led to the copy - two MODELS
  over one data object, which one shared model would not be.

### X4. Outbound model as a per-attribute patch (performance, not simplicity)

- **Verified:** inbound is a cell delta (`Lib.buildDeltaFromPaths`);
  outbound is all or nothing - `main_snapshot_changed` returns a boolean at
  the first difference and `main_json_stringify` then serializes every bound
  attribute. Not measured with a large table.
- **Idea:** the snapshot is per attribute already; return the changed names,
  send only those, merge on the frontend (`setData( data, true )`). A second
  model path next to the full one - it adds code. Only with a measured case.

---

## Checked and dropped - do not re-propose

- **Slot state as one map.** 17 of the 20 direct accesses to the five view
  and controller fields are already inside `core/ViewSlots.js`; nothing to gain.
- **The app stack as a list in the draft.** `id_prev_app_stack` is a column of
  `z2ui5_t_01`, a field of the public `z2ui5_if_client=>ty_s_get-s_draft` and
  of the draft-store seam; the chain walk in `check_draft_on_stack` runs only
  when an existing instance is called again.
- **Typed arguments in the action list.** `t_arg` is a `string_table`, so the
  backend cannot emit a typed value, and `castArgAuto` in
  `core/actions/ControlCall.js` has to keep guessing (`""` is `false`). This
  belongs to the action object - see `frontend-action-named-api`.
- **An explicit raw/literal marker per event argument.**
  `check_arg_raw` decides by the first character; 983 arguments in
  samples-controls rely on it. `check_arg_literal` exists and has 0 users.
- **`z2ui5_cl_ui5_srv_model`'s binding search** (dissolve, reference compare,
  alias pairing) and the pre-`main( )` snapshot: both are decided in
  `docs/agents/decisions.md`.

## Order

S1, S2, S3 first (small, independent). S5 before X1. Stage 2 as one change
set once P1 is decided. X2 and X3 each as an experiment of their own. S4 and
X4 only if somebody wants them.
