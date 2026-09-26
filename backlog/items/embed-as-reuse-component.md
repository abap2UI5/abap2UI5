---
target: abap2ui5
title: 'Embed abap2UI5 in other UI5 apps as a reuse component (freestyle views, Fiori elements extensions)'
summary: Stage 2 is done - the frontend state is per component (core/Context.js) and several z2ui5.Component instances run side by side on one page; stage 1 (the embedded flag that turns the page-wide behaviours off) and a wrapping custom control stay open until there is real demand
priority: low
state: open
first_seen: 2026-09-23
upstream: abap2UI5/abap2UI5
evidence:
  - frontend audit 2026-09-23 after the z2ui5 global was removed - findings and file references below
  - the framework ids are component-prefixed since the same day (ViewSlots.ownId), the one part that needed no embedding mode
---

# Embed abap2UI5 in other UI5 apps as a reuse component

**Status: stage 2 done (2026-09-23, maintainer decision to build it after
all), stage 1 and the custom control open.** abap2UI5 is built for the
whole page: a stateful roundtrip per event, and the backend drives routing,
popups, title and favicon. Embedding it as one area of a host app (a
freestyle view, a Fiori elements V4 custom section or V2 reuse component)
needs stage 1 below, which is only worth its cost once someone actually
needs it; a custom control is a thin wrapper on top of it.

## Already in place

- `z2ui5.Component` is a self-contained UIComponent with its own manifest,
  and there is no frontend global. Configuration arrives as
  `componentData` (`Component.init`).
- The start app does not need the URL. `componentData.startupParameters.app_start`
  is read by the backend (`z2ui5_cl_ui5_handler`, the launchpad path).
- The backend endpoint comes from `sap.app/dataSources/http`, or - since
  2026-09-24 - from `componentData.endpoint`, which a host passes per
  instance (`Component.init`, `controller/App.controller.js`). Only the top
  level of the component data is read, never the launchpad's
  `startupParameters`, so a link cannot point the roundtrips elsewhere.
- `Component.exit` tears down listeners, timers, popups and OData clients.
- Actions are data (no eval, no custom JS), so a host with a strict CSP is
  fine.
- **Done 2026-09-23:** the MAIN view (`mainView`) and the popup/popover
  fragments (`popupId`/`popoverId`) are created under the owner component's
  id (`ViewSlots.ownId`), and the fatal-error overlay is
  `z2ui5ServerErrorContainer`. Nothing the framework creates carries a bare
  page-global id any more.
- **Done 2026-09-23 (stage 2):** the frontend state is per component.
  `core/Context.js` creates one context per `z2ui5.Component` - the state
  of `core/AppState.js` plus the module records of Server, Session, Router,
  Shortcuts, ScrollFocus, ErrorView and the developer tools - and every
  module takes it as its first argument or resolves it from the control
  (`Context.of`, through the owner component: views and fragments are built
  under `Context.runAsOwner`). Several instances run side by side; the
  instance guard that briefly refused a second one is gone. Proven in the
  browser by `node/tests/e2e/two-components.spec.js`.

## Stage 1 - one embedded instance per page (feasible, a few days)

A host would write
`<core:ComponentContainer name="z2ui5" async="true" settings="{componentData: {embedded: true, startupParameters: {app_start: ['ZCL_MY_APP']}}}"/>`.
What that needs:

1. **An `embedded` flag in `componentData`** that switches off what belongs
   to the page, not to an area of it:
   - URL ownership: `core/Router.js` (HashChanger writes, `pushState`,
     `replaceState`), `cc/History.js`, and `HASH`/`PATHNAME`/`SEARCH` on
     the wire (`core/Server.js`, `core/Session.js`). The backend then has to
     tolerate a request without them.
   - Document title and favicon: `SET_TITLE`/`SET_FAVICON` in
     `core/actions/Browser.js`, `cc/Title.js`, `cc/Favicon.js`.
   - `window.onbeforeunload` (`cc/Dirty.js`) and the unload listener in
     `Component.js`.
   - The developer tools' page-wide capture (`devtools/Console.js`
     `error`/`unhandledrejection`, `sessionStorage`).
2. **A neutral root container** instead of `sap.m.App` in
   `view/App.view.xml` (`core/actions/Slots.js` swaps MAIN with
   `removeAllPages`/`insertPage`). `sap.m.App` is a full-screen root, and
   inside an Object Page section it is the wrong control.
3. **A decision on messaging.** `Env.getMessaging` is the page-wide
   `Messaging`/`MessageManager`, so in Fiori elements the embedded app's
   messages show up in the host's message button. That may be what we want,
   but it should be decided rather than left to happen.

**Why this is NOT done for the standalone and launchpad case:** document-wide
listeners cannot simply be scoped to the component's DOM. UI5 renders
dialogs and popovers into the static UI area outside the component, so
keyboard shortcuts (`core/actions/Shortcuts.js`, `keydown` on `document`)
and scroll tracking (`Component._installScrollListener`, capture on
`document`) would stop working inside popups. The fatal-error overlay
(`core/ErrorView.js`) is full-page by design. All three have to become
component-scoped only in embedded mode, and that mode has to handle the
static area explicitly.

Before building stage 1: a 1-2 day spike with a freestyle test page hosting
the component in a `ComponentContainer`, to see what actually breaks.

## Stage 2 - several instances per page (done 2026-09-23)

Was: every piece of frontend state a module singleton (`core/AppState.js`
plus the module state of `Server`, `Session`, `Router`, `Shortcuts`,
`ErrorView`), and `Component.init` reset it for whoever came last. Is: one
context per component (`core/Context.js`), found through the controller
(`oController.ctx`), the component, or the owner component of a control.
What is still shared between two instances is what the page owns - the URL
hash (both routed instances react to a change; an embedded instance leaves
routing off, see stage 1), document title and favicon, the global
BusyIndicator (each instance shows and hides it; two busy instances overlap
on one overlay), the messaging facade, the developer tools' console capture
(installed once, use-counted), the unsaved-changes prompt and the raw
fatal-error overlay (one at a time). Two stateful apps side by side is still
a rare UI; what the stage bought is that a launchpad in keep-alive mode, or
a host that creates the component twice, no longer corrupts the first
instance.

- **Done 2026-09-26:** the frontend as a script of its own. A GET of the
  node with `?z2ui5-bundle` answers with the preload the page embeds
  (`z2ui5_cl_ui5f_preload=>get_bundle`, generated from the same entries as
  the page script) plus a `z2ui5/embed` module with the sibling BSP paths
  (`z2ui5_cl_ui5_http_handler=>_http_get_bundle`). A host loads it with a
  `<script src>` and creates the component - no copy of the frontend in the
  host, and always the frontend of the backend it talks to. Without the
  parameter the node answers with the page as before.

## A custom control (deferred)

A `z2ui5.Embed` control with `appStart`/`endpoint` properties would only be
a thin wrapper around the `ComponentContainer`. It is worth writing after
stage 1, not instead of it. The UI5 standard for this is a reuse
component, not a custom control.

A first version is under way in
[abap2UI5/test-cc](https://github.com/abap2UI5/test-cc): the npm package
`@abap2ui5/reuse-custom-control` with a `z2ui5.reuse.Container` control
that ships this frontend at a pinned commit. It is what asked for
`componentData.endpoint`; the stage 1 items above are still what it lacks.

## 1.71

`ComponentContainer`, `componentData` and `Component#createId` all exist in
1.71. No stage is blocked by the floor.
