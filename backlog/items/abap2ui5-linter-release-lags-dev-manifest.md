---
target: abap2ui5-linter
title: 'The released linter lags the DEV manifest and builder API: component_path( ) and STOP_TIMER are reported as errors'
summary: 'every @abap2ui5/linter 0.11.x predates abap2UI5 40e8a073 and 4a418249, so z2ui5_cl_ui5_view_builder=>component_path( ) is an unknown-builder-method and a wired STOP_TIMER an unknown-frontend-action, although DEV documents both and its linter-manifest.json lists STOP_TIMER - a release that picks up the DEV manifest, and builder statics derived from it'
priority: high
state: filed
filed: https://github.com/abap2UI5/linter/pull/200
first_seen: 2026-11-24
checked_upstream: 2026-11-24
evidence:
  - 'abap2UI5 40e8a073 (2026-11-24) added CLASS-METHODS component_path to z2ui5_cl_ui5_view_builder (src/02), the documented way to bind a column whose name is only known at run time (docs/agents/building-apps.md section 4)'
  - '@abap2ui5/linter 0.11.0, lib/builders.mjs: VIEW_BUILDER.statics = [''factory'', ''escape_literal''] - "what unknown-builder-method accepts beside the verbs and stringify( )"'
  - 'abap2UI5/table-maintenance 880fc2d: Z2UI5_CL_TM_001 suppresses the error with `" abap2ui5lint-disable-next-line unknown-builder-method -- component_path( ) is a static of the builder since abap2UI5 40e8a073, the linter 0.11 does not know it yet`'
  - 'abap2UI5 4a418249 (2026-11-24) added cs_event-stop_timer (STOP_TIMER), as a follow-up action and as the wire .eF(''STOP_TIMER''); the generated .github/shared/linter-manifest.json of DEV lists it in clientEvents and frontendEvents'
  - 'abap2UI5/protocol 9361b44 (revision 0.8, 2026-11-24), conformance/RESULTS.md and CHANGELOG.md: the linter of abap2UI5''s own package.json (@abap2ui5/linter 0.11.0) reports the wired STOP_TIMER of the protocol conformance app (ACTIONS) as unknown-frontend-action'
  - '@abap2ui5/linter 0.11.3 (latest on npm, published 2026-11-20): FRONTEND_EVENTS in lib/frontend-actions.mjs is still written by hand and has no STOP_TIMER, data/abap2ui5-manifest.json lists 30 frontendEvents without it, VIEW_BUILDER.statics has no component_path (checked 2026-11-24)'
  - 'abap2UI5/linter: no issue or PR names STOP_TIMER or component_path (searched 2026-11-24); #196 (open) reports drift of the hand-maintained mirrors checked by scripts/check-upstream.mjs, the builder statics are not among them; #185 (closed 2026-11-16) was the last "release due: the abap2UI5 mirrors moved since the last tag"'
---

# The released linter lags the DEV manifest and builder API

Two new APIs of abap2UI5 DEV, both documented for apps, are reported as
errors by every released `@abap2ui5/linter` (0.11.0 to 0.11.3). Both have
the same cause: the linter's knowledge of abap2UI5 is a snapshot taken at
its last release, and what it does not know it reports. A false positive on
the API the documentation recommends teaches people to suppress the rule.

## Current behaviour

### Case 1 - `component_path( )` is an unknown builder method

`lib/builders.mjs` describes the view builder with a hand-written list of
its class methods:

```js
// the class's other public methods (CLASS-METHODS of its PUBLIC SECTION):
// what unknown-builder-method accepts beside the verbs and stringify( )
statics: ['factory', 'escape_literal'],
```

abap2UI5 40e8a073 added a third, `component_path( )`, which returns the
row-relative binding path of a column (`/CWM/XCWMAT` becomes `CWM/XCWMAT`)
and is what `building-apps` section 4 tells an app to use. Every call of it
is reported by `unknown-builder-method` as an error:

```abap
DATA(path) = z2ui5_cl_ui5_view_builder=>component_path( layout->fname ).   " unknown-builder-method
```

The first consumer, abap2UI5/table-maintenance 880fc2d, had to suppress it
with a disable comment. This list is not in the manifest at all, so no sync
would have caught it.

### Case 2 - a wired `STOP_TIMER` is an unknown frontend action

abap2UI5 4a418249 added `cs_event-stop_timer`, the end of the new repeating
`START_TIMER`. On a press it is wired without a roundtrip:

```abap
page->button( text  = `Stop`
              press = client->_event_client( client->cs_event-stop_timer ) ).   " .eF('STOP_TIMER') - unknown-frontend-action
```

DEV's generated `.github/shared/linter-manifest.json` already lists
`STOP_TIMER` in `clientEvents` and `frontendEvents`. The released linter
does not: its `FRONTEND_EVENTS` in `lib/frontend-actions.mjs` is a hand-kept
list, and its `data/abap2ui5-manifest.json` is the manifest of its last
sync. The protocol conformance app (abap2UI5/protocol 9361b44) is the first
place it showed.

## Proposed change

1. **Now:** a linter release that runs `npm run sync-manifest` against
   abap2UI5 DEV and adds `STOP_TIMER` to `FRONTEND_EVENTS` and
   `component_path` to `VIEW_BUILDER.statics`. Its own `check-upstream`
   then passes against DEV again.
2. **So it does not happen again - the frontend actions:** build
   `FRONTEND_EVENTS` from `UPSTREAM_SETS.frontendEvents`, as
   `BINDING_METHODS`, `CSS_PROPERTIES` and the other closed sets already
   are. The manifest has the list; the hand copy is what went stale.
3. **So it does not happen again - the builder statics:** the public
   `CLASS-METHODS` of `z2ui5_cl_ui5_view_builder` become one more entry of
   the abap2UI5 manifest (a `builderStatics` list, generated from the class
   like the rest), and `VIEW_BUILDER.statics` is read from it. The next
   static is then reported as drift by the linter's own check rather than
   as an error in a consumer's CI. The manifest side is an abap2UI5 change;
   the linter side is reading it.

Both cases are a release lag, not a missing rule: as long as the linter is
released by hand, a DEV feature that apps adopt the same day will meet the
previous release. Points 2 and 3 shrink what a release has to remember to
one command.

## What must still be reported

- An instance method that does not exist (`view->tagg( )`) - the purpose of
  `unknown-builder-method`.
- A static that does not exist (`z2ui5_cl_ui5_view_builder=>escape( )`).
- `component_path( )` called on the frozen builder (`z2ui5_cl_xml_view`),
  which does not have it.
- An action name the frontend does not dispatch (`.eF('STOP_TIMERS')`,
  `.eF('stop_timer')` - the dispatch is case-sensitive).
- `STOP_TIMER` and `component_path( )` under `abap2ui5-api-too-new` for a
  project whose declared minimum abap2UI5 release predates 4a418249 or
  40e8a073 - known is not the same as available.
