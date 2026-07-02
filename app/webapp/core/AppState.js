// Owner of the shared frontend state. Historically all state lived as
// plain properties on the global `z2ui5` object, written and lazily
// created from many modules. This module is the single owner now:
//
//  - the PUBLIC fields stay plain properties on the global (they are a
//    contract with apps and the backend-generated HTML),
//  - every INTERNAL field lives in the private `state` object below and
//    is exposed on the global through transitional accessors, so all
//    existing consumers (including apps poking at internals via the
//    js_loader popup) keep working unchanged,
//  - initGlobal() creates/resets everything in one place - no other
//    module needs lazy `if (!z2ui5.x) z2ui5.x = ...` bootstrapping for
//    the fields listed here.
//
// PUBLIC contract on the global (plain properties, not managed here):
//   checkLocal        true when served by the backend GET page (backend HTML)
//   url               backend endpoint for roundtrips (App.controller)
//   oConfig           { S_UI5: version info, ComponentData } (Component)
//   Util              PUBLIC date helpers for view formatters - apps rely on
//                     this global and on the z2ui5/Util module (Component)
//   requestTimeoutMs  optional override for the roundtrip timeout (apps)
//   <custom>          apps can register functions via the js_loader popup
//                     and call them through the Z2UI5 frontend event
//
// INTERNAL field inventory (defaults in createState below) - writer in
// parentheses:
//
// Views / controllers / UI5 objects
//   oApp              sap.m.App hosting the main view (App.controller)
//   oOwnerComponent, oRouter, oDeviceModel (Component / App.controller)
//   oView, oViewNest, oViewNest2, oViewPopup, oViewPopover
//                     the five view slots, see core/ViewSlots.js (View1)
//   oController, oControllerNest, oControllerNest2, oControllerPopup,
//   oControllerPopover  controller instance per slot (App.controller)
//   oLaunchpad        FLP services when running inside the launchpad, else
//                     null (Component._initLaunchpad)
//
// Roundtrip state
//   oBody             mirror of the current request payload - the body
//                     itself travels as a parameter through
//                     Server.roundtrip/readHttp; this record exists for
//                     onBeforeRoundtrip hooks and the debug tool
//                     (View1.eB / Server)
//   oResponse         last processed response { ID, PARAMS, OVIEWMODEL }
//   responseData      raw parsed response JSON (Server.readHttp); kept
//                     besides oResponse because it carries fields the
//                     cooked record does not (e.g. S_FRONT.APP, used by
//                     the debug tool)
//   contextId         stateful session id, header transport (Server)
//   isBusy            roundtrip in flight (View1.eB / Server)
//   xxChangedPaths    Set of edited /XX/ model paths for the delta (View1)
//   checkNestAfter, checkNestAfter2  nested views rebuilt this roundtrip
//   search            overrides location.search in S_FRONT; never written
//                     by the framework itself, set externally (custom JS)
//   pendingCustomJs   follow-up JS to run after rendering (Server)
//
// Control / helper state
//   errors            capped error log, see Lib.logError
//   timers            single pending backend timer (FrontendAction)
//   lastScrolled      last scrolled element per slot (Server.onScrollCapture)
//   viewSizeLimits    per-slot model size limits (FrontendAction)
//   treeState         tree binding state across rebuilds (Tree control)
//   debugTool         DebugTool instance (Component, Ctrl+F12)
//   onBeforeRoundtrip, onAfterRoundtrip, onAfterRendering,
//   onBeforeEventFrontend  callback arrays, see Lib.registerCallback
sap.ui.define([], () => {
  "use strict";

  // Fresh defaults for every internal field. Collections start out as
  // empty containers so consumers can use them without existence checks.
  function createState() {
    return {
      // Views / controllers / UI5 objects
      oApp: null,
      oOwnerComponent: null,
      oRouter: null,
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
      oLaunchpad: null,

      // Roundtrip state
      oBody: null,
      oResponse: null,
      responseData: null,
      contextId: null,
      isBusy: false,
      xxChangedPaths: new Set(),
      checkNestAfter: false,
      checkNestAfter2: false,
      search: null,
      pendingCustomJs: null,

      // Control / helper state
      errors: [],
      timers: {},
      lastScrolled: {},
      viewSizeLimits: {},
      treeState: null,
      debugTool: null,

      // Callback arrays (see Lib.registerCallback / Lib.runCallbacks)
      onBeforeRoundtrip: [],
      onAfterRoundtrip: [],
      onAfterRendering: [],
      onBeforeEventFrontend: [],
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

  return { initGlobal, reset };
});
