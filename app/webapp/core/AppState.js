/* ui5lint-disable no-project-globals -- this module owns the public
   z2ui5 global facade; it is the single place that may touch it */
// Owner of the shared frontend state. Historically all state lived as
// plain properties on the global `z2ui5` object, written and lazily
// created from many modules. This module is the single owner now:
//
//  - the PUBLIC fields stay plain properties on the global (they are a
//    contract with apps and the backend-generated HTML); framework
//    modules read/write them via getGlobal()/setGlobal() below,
//  - every INTERNAL field lives in the private `state` object below;
//    framework modules access it via the `state` export, and the global
//    additionally exposes it through accessors so external consumers
//    (apps poking at internals via the js_loader popup) keep working
//    unchanged,
//  - initGlobal() creates/resets everything in one place - no other
//    module needs lazy `if (!z2ui5.x) z2ui5.x = ...` bootstrapping for
//    the fields listed here.
//
// No other framework module may reference the z2ui5 global directly:
// internal fields go through `AppState.state`, public-contract fields
// through `AppState.getGlobal()/setGlobal()`.
//
// PUBLIC contract on the global (plain properties, not managed here):
//   checkLocal        true when served by the backend GET page (backend HTML)
//   url               backend endpoint for roundtrips (App.controller)
//   oConfig           { S_UI5: version info, ComponentData } (Component)
//   Util              PUBLIC date helpers for view formatters - apps rely on
//                     this global and on the z2ui5/Util module (Component)
//   Formatter         PUBLIC curated formatter module for view binding
//                     strings (z2ui5/model/formatter, wired via
//                     core:require; the global covers releases without
//                     core:require); owns the date helpers Util
//                     re-exports - grows via framework PRs only (Component)
//   ccResourceRoot    absolute path of the custom-control BSP, set by the
//                     backend GET page when there is no sibling BSP to
//                     resolve "../z2ui5_cci/" against (backend HTML)
//   cccResourceRoot   same for the customer frontend-extension BSP
//                     ("../z2ui5_ccc/") (backend HTML)
//   requestTimeoutMs  optional override for the roundtrip timeout (apps)
//   <custom>          apps can register functions via the js_loader popup
//                     and call them through the Z2UI5 frontend event
//
// INTERNAL field inventory (defaults in createState below) - writer in
// parentheses:
//
// Views / controllers / UI5 objects
//   oApp              sap.m.App hosting the main view (App.controller)
//   oOwnerComponent, oDeviceModel (Component / App.controller)
//   oView, oViewNest, oViewNest2, oViewPopup, oViewPopover
//                     the five view slots, written by ViewSlots.setView
//   slotXml           the view XML each slot was filled with, per slot key -
//                     recorded by ViewSlots.setView and dropped by
//                     ViewSlots.destroy, so it tracks the slot itself no
//                     matter who tore it down (backend action or a
//                     roundtrip-free frontend close). The developer tools
//                     read a slot's source from here: a fragment or a view
//                     built from a `definition` keeps no viewContent of its
//                     own
//   slotApp           the app class each slot was filled BY, per slot key -
//                     recorded and dropped alongside slotXml. A response
//                     carries the model of ONE app, so this is what says
//                     which open slots it may be pushed into
//                     (actions/Slots.updateModelIfRequired)
//   oController, oControllerNest, oControllerNest2, oControllerPopup,
//   oControllerPopover  controller instance per slot (App.controller)
//   oLaunchpad        FLP services when running inside the launchpad, else
//                     null (Component._initLaunchpad)
//
// Roundtrip state
//   oBody             mirror of the current request payload - the body
//                     itself travels as a parameter through
//                     Server.roundtrip/readHttp; this record exists for
//                     onBeforeRoundtrip hooks and the developer tools
//                     (View1.eB / Server)
//   oResponse         last processed response { ID, S_ACTION, OVIEWMODEL,
//                     APP, MODELPRESENT }
//   renderedApp       class name of the last rendered app - an APP switch in
//                     a response tears the standalone slots down implicitly
//                     (View1._processAfterRendering)
//   responseData      raw parsed response JSON (Server.readHttp); kept
//                     besides oResponse because the developer tools render
//                     the raw payload
//   contextId         stateful session id, header transport (Server)
//   isBusy            roundtrip in flight (View1.eB / Server)
//   oSentModel        the JSON model whose edited-path set the in-flight
//                     request carried; its own _z2ui5ChangedPaths is cleared
//                     once that request wins (Server), so a stale response
//                     never clears newer edits and edits made in a DIFFERENT
//                     model (e.g. a popover) are never shipped against this one
//   search            overrides location.search in S_FRONT; never written
//                     by the framework itself, set externally (custom JS)
//
// Control / helper state
//   errors            capped error log, see Lib.logError
//   timers            single pending backend timer (actions/ViewOps)
//   shortcuts         registered keyboard shortcuts, normalized combo ->
//                     scope -> { event, controller }, the scope being a view
//                     slot key or "" for unscoped (actions/Shortcuts). Dispatch takes the innermost OPEN
//                     scope, so a popover-local shortcut shadows the page one
//                     the way a UI5 CommandExecution in dependents does;
//                     an app switch resets it, the document listener stays
//   lastScrolled      last scrolled element per slot (ScrollFocus.onScrollCapture)
//   viewSizeLimits    per-slot model size limits (actions/ViewOps)
//   treeStates        tree binding state per tree_id across rebuilds (Tree control)
//   lastError         the last fatal error shown by ErrorView (title/text/
//                     onRetry), so a details view can re-show it
//   onBeforeRoundtrip, onAfterRoundtrip, onAfterRendering,
//   onBeforeEventFrontend, onErrorDetails  callback arrays, see
//                     Lib.registerCallback. onErrorDetails is the extension
//                     point behind the fatal-error overlay's Details action:
//                     ErrorView runs whatever registered and hides the button
//                     when nothing did (devtools/DevTools.js registers
//                     the in-app developer tools there)
sap.ui.define([], () => {
  "use strict";

  // Fresh defaults for every internal field. Collections start out as
  // empty containers so consumers can use them without existence checks.
  function createState() {
    return {
      // Views / controllers / UI5 objects
      oApp: null,
      oOwnerComponent: null,
      oDeviceModel: null,
      oView: null,
      oViewNest: null,
      oViewNest2: null,
      oViewPopup: null,
      oViewPopover: null,
      oController: null,
      oControllerNest: null,
      oControllerNest2: null,
      oControllerPopup: null,
      oControllerPopover: null,
      slotXml: {},
      slotApp: {},
      oLaunchpad: null,

      // Roundtrip state
      oBody: null,
      oResponse: null,
      renderedApp: null,
      responseData: null,
      contextId: null,
      isBusy: false,
      oSentModel: null,
      search: null,

      // Hash-based app routing (UI5 Router style, opt-in per app via
      // follow_up_action( cs_event-set_nav_routing )).
      // Owned by core/Router.js - see there for the route format and how the
      // hash is split between the FLP shell and the app.
      //  navRouting  once the running app enabled routing, the URL hash mirrors
      //              the current app as a bookmarkable route and browser
      //              Back/Forward navigate between apps via the hash.
      //  navMode        routing mode (z2ui5_if_client=>cs_nav_mode): 'KEEP' keeps
      //                 the app state (draft id in the route '#/app/<CLASS>/
      //                 <DRAFT>', restored on Back/Forward), 'FRESH' routes by
      //                 class only ('#/app/<CLASS>', always a fresh start).
      //  currentApp     class name of the app currently rendered.
      //  currentDraftId server draft id reflected in the current route - the
      //                 app-state id in KEEP, null in FRESH. The routing guard
      //                 compares an incoming hash route's draft id against it so
      //                 our own hash writes do not re-trigger a navigation, and
      //                 (KEEP) browser Back/Forward restore the exact draft.
      //  navFromHash    the pending roundtrip was triggered by a browser
      //                 Back/Forward (or manual hash edit) via the router, so
      //                 the resulting render must NOT rewrite the hash: the
      //                 browser is at a non-top history position and rewriting
      //                 there drops the forward entries (Forward would break).
      //  hashEvent      app-owned hash routing (routing OFF): the backend
      //                 event name the app registered via
      //                 cs_event-hash_attach_changed (Router.applyHashEvent,
      //                 the setHashEvent nav option). While registered the
      //                 hash belongs to the app: hash_set pushes
      //                 through the HashChanger and a hash change the app
      //                 did not write itself round-trips this event on the
      //                 current MAIN controller; the per-response cleanup
      //                 leaves the hash alone. Dies with the app switch.
      //  appHash        the app hash last written or dispatched under that
      //                 listener - the echo guard, mirroring what
      //                 currentDraftId does for the draft routes.
      //  pendingAppHash a hash change that arrived while a roundtrip was in
      //                 flight (the busy guard would have dropped its
      //                 event); the roundtrip's end dispatches it
      //                 (Router.dispatchPendingAppHash). null = nothing
      //                 parked.
      navRouting: false,
      navMode: null,
      currentApp: null,
      currentDraftId: null,
      navFromHash: false,
      hashEvent: null,
      appHash: "",
      pendingAppHash: null,
      // How many app hashes this PAGE LOAD has pushed (listener, legacy and
      // KEEP-suffix pushes alike) - Router.navBack's stand-in for UI5's
      // History.getPreviousHash(): zero means a cold deep link with no
      // in-app history entry to consume, so a fallback replaces instead.
      hashPushCount: 0,

      // Control / helper state
      errors: [],
      timers: {},
      shortcuts: {},
      lastScrolled: {},
      viewSizeLimits: {},
      treeStates: {},
      lastError: null,

      // Callback arrays (see Lib.registerCallback / Lib.runCallbacks)
      onBeforeRoundtrip: [],
      onAfterRoundtrip: [],
      onAfterRendering: [],
      onBeforeEventFrontend: [],
      onErrorDetails: [],
    };
  }

  let state = createState();

  // Reset all internal fields to their defaults. The accessors installed
  // by initGlobal() read through to the current `state`, so a reset is
  // immediately visible on the global.
  function reset() {
    state = createState();
  }

  // Prepare the z2ui5 global for a component start:
  //  - make sure the global exists (standalone there is no backend HTML
  //    declaring it),
  //  - start from a clean object when checkLocal === false,
  //  - reset the internal state and expose it via accessors,
  //  - provide a fresh oConfig for the bootstrap info.
  // Idempotent: a re-init (e.g. FLP re-launch) redefines the accessors
  // and starts from clean defaults again.
  function initGlobal() {
    if (typeof z2ui5 === "undefined" || z2ui5.checkLocal === false) {
      // Assign via window - a bare `z2ui5 = {}` would throw a
      // ReferenceError on an undeclared global in strict mode.
      window.z2ui5 = {};
    }
    reset();
    for (const name of Object.keys(state)) {
      const desc = Object.getOwnPropertyDescriptor(z2ui5, name);
      // Preserve a value someone put on the global before we took over
      // (plain data property only - accessors from a previous init
      // already delegate to `state`).
      if (desc && "value" in desc && desc.value !== undefined) {
        state[name] = desc.value;
      }
      Object.defineProperty(z2ui5, name, {
        configurable: true,
        enumerable: true,
        get() {
          return state[name];
        },
        set(val) {
          state[name] = val;
        },
      });
    }
    z2ui5.oConfig = {};
  }

  // Read/write a field on the public z2ui5 global facade - the PUBLIC
  // contract fields listed in the header (checkLocal, url, oConfig, Util,
  // requestTimeoutMs) and app-registered custom members (js_loader).
  // Internal fields are accessed via the `state` export instead. Reads and
  // writes go through the global on purpose: these fields are shared with
  // apps and the backend-generated HTML.
  function getGlobal(name) {
    return window.z2ui5?.[name];
  }

  function setGlobal(name, value) {
    if (typeof z2ui5 === "undefined") window.z2ui5 = {};
    window.z2ui5[name] = value;
  }

  return {
    initGlobal,
    reset,
    getGlobal,
    setGlobal,
    // Live internal state - always the current object, also after reset().
    get state() {
      return state;
    },
  };
});
