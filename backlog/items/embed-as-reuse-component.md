---
target: abap2ui5
title: 'Embed abap2UI5 in other UI5 apps as a reuse component (freestyle views, Fiori elements extensions)'
summary: The frontend runs once per page and owns the page - stage 1 (one embedded instance via ComponentContainer) is feasible, stage 2 (several instances) and a wrapping custom control are deferred until there is real demand (maintainer decision 2026-09-23)
priority: low
state: deferred
first_seen: 2026-09-23
upstream: abap2UI5/abap2UI5
evidence:
  - frontend audit 2026-09-23 after the z2ui5 global was removed - findings and file references below
  - the framework ids are component-prefixed since the same day (ViewSlots.ownId), the one part that needed no embedding mode
---

# Embed abap2UI5 in other UI5 apps as a reuse component

**Status: deferred (maintainer decision 2026-09-23).** abap2UI5 is built for
the whole page: a stateful roundtrip per event, and the backend drives
routing, popups, title and favicon. Embedding it as one area of a host app
(a freestyle view, a Fiori elements V4 custom section or V2 reuse
component) is possible, but only stage 1 below is worth its cost, and only
once someone actually needs it. Stage 2 and a custom control are **not** to
be built without a concrete scenario, and should not be re-proposed as
general cleanup.

## Already in place

- `z2ui5.Component` is a self-contained UIComponent with its own manifest,
  and there is no frontend global. Configuration arrives as
  `componentData` (`Component.init`).
- The start app does not need the URL. `componentData.startupParameters.app_start`
  is read by the backend (`z2ui5_cl_ui5_handler`, the launchpad path).
- The backend endpoint comes from `sap.app/dataSources/http`.
- `Component.exit` tears down listeners, timers, popups and OData clients.
- Actions are data (no eval, no custom JS), so a host with a strict CSP is
  fine.
- **Done 2026-09-23:** the MAIN view (`mainView`) and the popup/popover
  fragments (`popupId`/`popoverId`) are created under the owner component's
  id (`ViewSlots.ownId`), and the fatal-error overlay is
  `z2ui5ServerErrorContainer`. Nothing the framework creates carries a bare
  page-global id any more.
- **Done 2026-09-23:** a second instance on the same page is refused with
  an error (`Component._claimSingleInstance`) instead of silently resetting
  the first one's state. The guard is what stage 2 removes.

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

## Stage 2 - several instances per page (deferred, not recommended)

Every piece of frontend state is a module singleton: `core/AppState.js`,
plus the module state of `Server`, `Session`, `Router`, `Shortcuts` and
`ErrorView`. `Component.init` calls `AppState.reset()`, so a second instance
resets the first. About 25 modules read `AppState`, 12 of them custom
controls. Making the state per component means a context that modules find
through the owner component instead of a module import. That touches the
signatures of almost all of `core/` and `cc/` and most of the ~1,200 specs,
and it adds a hosting mode that has to be tested forever against 1.71 and
the current release. The benefit is small: two stateful abap2UI5 apps side
by side on one page, each with its own draft chain, busy state and
messages, is a rare and awkward UI.

## A custom control (deferred)

A `z2ui5.Embed` control with `appStart`/`endpoint` properties would only be
a thin wrapper around the `ComponentContainer`. It is worth writing after
stage 1, not instead of it. The UI5 standard for this is a reuse
component, not a custom control.

## 1.71

`ComponentContainer`, `componentData` and `Component#createId` all exist in
1.71. No stage is blocked by the floor.
