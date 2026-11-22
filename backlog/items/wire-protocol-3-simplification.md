---
target: abap2ui5
title: 'Simplify the frontend/backend wire: what protocol 2 allows and what needs a protocol revision'
summary: Fifteen ideas to remove coupled special cases from the roundtrip, checked against DEV and against the written protocol (abap2UI5/protocol) - one is implemented, eleven change a rule the protocol states and tests and so start as a revision there, three were dropped on measurement, and the busy guard treats an event fired while a view renders differently on the first roundtrip and on every later one
priority: medium
state: open
first_seen: 2026-11-22
checked_upstream: 2026-11-22
upstream: abap2UI5/abap2UI5
evidence:
  - 'baseline on DEV 1af8c19 (2026-11-22): 1031 ABAP unit test methods and 1867 JS specs green; `check:api` and `check:shared` red before any change of this item (the snapshot and the app-template mirror of #3040)'
  - 'abap2UI5/protocol f592b16 run against that checkout: backend suite 88 of 88, frontend suite (ui5 adapter, Chromium, OpenUI5 1.153.0) 83 passed and 4 skipped'
  - 'browser experiment through the protocol suite''s mock backend: a `core:HTML` whose `afterRendering` is wired to `.eB` reaches the backend on the FIRST response (POSTs: start, R1) and is dropped on a LATER one (POSTs: start, NEXT); with the queue-last flag the later one arrives (start, NEXT, R2)'
  - 'real roundtrips of the transpiled backend: hello world 356 B request / 657 B response, an event with a delta 120 / 204 B, an event that changes nothing 103 / 100 B'
  - 'usage counted in abap2UI5/samples-controls (9f3378a, 690 classes) and abap2UI5/samples-stack (4e268b9, 84 classes); abap2UI5/samples could not be read'
  - 'searched abap2UI5/abap2UI5 open issues 2026-11-22 for protocol / wire / S_ACTION / follow_up_action / hash routing: nothing overlapping'
---

# Simplify the frontend/backend wire: what protocol 2 allows and what needs a protocol revision

**Read this before proposing a change to the roundtrip.** The first version
of this item was written against `main` without knowing that the protocol is
a written contract. It is: [abap2UI5/protocol](https://github.com/abap2UI5/protocol)
holds the specification, the JSON Schemas and two conformance suites, and
`test.yaml` runs both against every pull request here (`conformance_backend`,
`conformance_frontend`). Three backends and six frontends speak it - cap2UI5,
the MCP server's agent client, the terminal and Adaptive Cards renderers
among them. `spec/versioning.md` there says what keeps protocol 2 (a new
optional key, action, slot option or `ROUTER` option) and what does not
(renaming or removing a key, changing a key's meaning or the shape of an
action array, a system action a frontend must run).

So most of what follows cannot be done in this repository alone. Each entry
names the rule it meets.

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
with a check of your own, as the experiment below did.

## Implemented

- **One implementation of the empty-argument rule** (2026-11-22).
  `z2ui5_cl_ui5_srv_event=>args_trim_trailing` is asked by both forms of an
  action; the handler expression and the JSON array each had their own.

## A finding that is not a simplification: events fired while a view renders

`bundle/webapp/controller/App.controller.js` `startApp` starts the first
roundtrip without setting `state.isBusy`; every later roundtrip sets it in
`View1.eB`. Measured in Chromium (evidence above): an event a control fires
from its `onAfterRendering` is SENT on the first response and DROPPED on
every later one, unless its wire carries `check_queue_last`. The controls
that do this: `cc/Storage.js` (`finished`), and whatever an app wires to a
rendering event.

Two ways to make it one behaviour, and neither is safe to pick alone:

- **Drop it on the first roundtrip too** (set `isBusy` in `startApp`). An app
  that reads a stored value on its first screen stops getting it.
- **Keep it on later roundtrips too.** An app that answers such an event with
  a new `view_display( )` renders again, fires again, and loops; today the
  drop is what ends that loop.

Decide first. Until then the first roundtrip stays as it is, and with it the
"superseded but not replaced" handling in `View1._processAfterRendering` and
the stale checks in `core/Server.js` - they cannot be removed while a first
response can be superseded.

## Needs a protocol revision first

Start each of these as a change in abap2UI5/protocol (the rule, its check,
`spec/open-questions.md`), then follow here and in cap2UI5.

| Idea | The rule it changes |
|---|---|
| Views and navigation as response sections (`VIEWS`, `NAV`) instead of `T_SYSTEM` actions | `spec/response.md`: `T_SYSTEM` / `T_CUSTOM`, the action array shape; checks `slots.*`, `response.*` |
| The frontend stops tearing POPUP and POPOVER down when `APP` changes; the backend states every teardown | `spec/response.md` "A frontend MUST tear down POPUP and POPOVER when a response names another APP"; check `slots.app-change`. The backend half alone (always queue both destroys) is compatible and useless without the frontend half |
| Event flags as an object in slot `[1]` of the event array | `profiles/ui5.md`, the `.eB` wire form; every frontend that parses a view reads it; checks `ui5.event-wire`, `ui5.wire-queue-last` |
| The frontend sends the parsed route, the backend drops its seven hash parsers | a new `S_FRONT.ROUTE` key is compatible, but the other frontends send `HASH` only, so the parsers stay; checks `route.*` |
| Navigation options: absent means "no change" | `spec/navigation.md`; check `router.app-state` "a response without it clears it" |
| Rename `T_CUSTOM` and the other names that outlived their meaning | renaming a key |
| One model per app instead of one per slot | `spec/request.md` "edits in another slot's model stay pending"; check `model.slot-model` (MUST) |
| Outbound model as a per-attribute patch | `spec/response.md` "MODEL is the complete view model ... never a delta" |
| `hash_set( )` only with a listener; one URL format for app state and KEEP route | `spec/navigation.md`; checks `router.*`, `route.app-state` |

What was measured for them, so the revision does not have to measure again:

- The three teardown rules sit in `z2ui5_cl_ui5_frontend=>slots_serialize`,
  `View1._processAfterRendering` and `z2ui5_cl_ui5_action=>prepare_app_stack`;
  `ViewSlots.destroy` is safe on a closed slot; a destroy action is 33 B
  (`POPUP`) or 35 B (`POPOVER`).
- `ROUTER/sync` is only stashed on the response
  (`core/actions/ControlCall.js`), the model push is the presence of `MODEL`,
  and `View1._replacesMainOwner` scans the action list for
  `VIEW_SLOTS / display / MAIN` - three mechanisms behind one list.
- Event array: `[1]` and `[2]` are always `false`, nothing emits `[3]`.
  OpenUI5 1.71.80 parses a map literal in a handler expression
  (`sap/ui/base/ExpressionParser.js`). An options object as a second ARGUMENT
  is not possible: 983 event arguments in samples-controls are raw
  expressions, some of them object literals. No app in the two corpora
  hand-writes `.eB(`.
- Hash: all 10 apps in samples-controls that write a hash also register the
  listener; `hash_routing` and `app_state_set_active` have no caller in
  either corpus, `app_state_get_href` has 11.
- Apps read the raw hash (`client->get( )-s_config-hash`), so `HASH` keeps
  travelling whatever else is sent.

## Checked and dropped - do not re-propose

- **Send the live device fields with every request** to save one latch in
  `core/Session.js`. The block is 77 B and a typical event request is 103 to
  120 B; the latch is about twenty lines.
- **A request queue instead of the stale checks.** Follows from the finding
  above; and parking a Back/Forward alone (the specification allows it, "MAY
  supersede") removes `restoreSeq` and nothing else.
- **The backend half of the teardown rules alone.** Compatible, and without
  the frontend half it only adds two actions to every hop.
- **Slot state as one map.** 17 of the 20 direct accesses to the five view
  and controller fields are already inside `core/ViewSlots.js`.
- **The app stack as a list in the draft.** `id_prev_app_stack` is a column of
  `z2ui5_t_01`, a field of the public `z2ui5_if_client=>ty_s_get-s_draft` and
  of the draft-store seam.
- **Typed arguments in the action list.** `t_arg` is a `string_table`, so
  `castArgAuto` in `core/actions/ControlCall.js` has to keep guessing. This
  belongs to the action object - see `frontend-action-named-api`.
- **`z2ui5_cl_ui5_srv_model`'s binding search** and the pre-`main( )`
  snapshot: decided in `docs/agents/decisions.md`.

## Already done or blocked elsewhere

`_bind_edit( )` and the five `*_model_update( )` no-ops went with #3040.
`custom_mapper` / `custom_filter` and the `destroy*` wrappers of
`View1.controller.js` wait for the conditions `docs/removal-plan.md` names;
in samples-controls and samples-stack none of them has a caller.
