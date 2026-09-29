---
target: abap2ui5
title: 'Embed abap2UI5 in other UI5 apps as a reuse component (freestyle views, Fiori elements extensions)'
summary: Stage 2 is done - the frontend state is per component (core/Context.js) and several z2ui5.Component instances run side by side on one page - and the control that wraps it exists (z2ui5.embed.Container, abap2UI5/embed-control, loading the frontend through ?z2ui5-bundle); of stage 1 the embedded flag exists and hands the URL to the host (a Fiori elements custom section needed it), the other page-wide behaviours - title, favicon, busy indicator, sap.m.App root - wait for real demand
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
all), the custom control exists, stage 1 in part: the embedded flag and the
URL (2026-09-28, for the Fiori elements example of abap2UI5/embed-control),
the rest open.** abap2UI5 is built for the
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

**Done 2026-09-28 - the flag and the URL.** `componentData.embedded`
lands in `state.embedded` (`Component.init`, read on the top level only,
never from the launchpad's startup parameters), and the z2ui5/embed module
of `?z2ui5-bundle` passes it, so every page that loads the frontend that
way embeds it. An embedded component leaves the URL to its host:
`core/Router.js` neither listens to the hash nor writes it - above all not
the `replaceHash("")` that ended every roundtrip and took a Fiori elements
object page's route away - and `core/Server.js` sends no `HASH`, whose
`#/app/<CLASS>` route would win over the host's `app_start`. What drove it:
the Fiori elements example of abap2UI5/embed-control (an object page custom
section), which the cleanup sent back to its list after every click.
Still open of the URL item: `cc/History.js`, an app's explicit HASH_BACK
(both still act on the host's history, as asked), and `PATHNAME`/`SEARCH`
on the wire.

**Done 2026-09-29 - the focus.** An embedded app no longer takes the focus
from the host page: `sap.m.App` holds its autofocus off until its first page
has rendered (`controller/App.controller.js`), and SET_FOCUS, a CONTROL_BY_ID
`focus( )` and `cc/Focus` ask the guard in `core/ScrollFocus.js` first - yes
while the focus is in the app, or nowhere after the user's last focus or
click went there. Found by the review of abap2UI5/embed-control, pinned by
`node/tests/e2e/embedded.spec.js`.

**Done 2026-09-29 - the window.** UI5 1.x exports every class it creates as
a global, so the frontend's classes rebuilt a `window.z2ui5` on the host's
page. Every class module hands its class to `Env.ownClass`, and an embedded
component takes the exports off (`Env.dropClassGlobals`); a page of the
app's own keeps them for 1.71 (`docs/removal-plan.md` §3).

**Done 2026-09-29 - the Restart.** The fatal-error overlay's Restart
reloaded the host's page. An embedded component restarts the app in place
instead (`ctx.restart` -> `Component._restartApp`, `ErrorView.restart`):
the app ends as on exit, the App controller starts it again with new
controllers and a new backend session.

What else stage 1 needs:

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

## A custom control (exists)

The wrapper around the `ComponentContainer` came before stage 1 after all:
`z2ui5.embed.Container` in
[abap2UI5/embed-control](https://github.com/abap2UI5/embed-control), the
npm package `@abap2ui5/embed-control`, with `app`, `endpoint` and `params`
properties. It ships no frontend - it loads the bundle above from the
backend it talks to, so it needs abap2UI5 1.145.0 or later - and it is what
asked for `componentData.endpoint` and the bundle. The stage 1 items above
are still what it lacks, the URL aside (done 2026-09-28): an embedded app
shows the global busy indicator, may set the title and the favicon, and
renders its root as `sap.m.App`.

The control requires the bundle's `z2ui5/embed` module by that name, and
its own namespace `z2ui5.embed` sits below it, mapped to the host app's
`thirdparty/` - so the module keeps its name and `app/webapp` gets no
`embed/` folder.

## 1.71

`ComponentContainer`, `componentData` and `Component#createId` all exist in
1.71. No stage is blocked by the floor.
