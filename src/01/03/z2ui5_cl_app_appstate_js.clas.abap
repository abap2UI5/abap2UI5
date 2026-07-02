CLASS z2ui5_cl_app_appstate_js DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_app_appstate_js IMPLEMENTATION.

  METHOD get.

    result = `// Owner of the shared frontend state. Historically all state lived as` && |\n| &&
             `// plain properties on the global ``z2ui5`` object, written and lazily` && |\n| &&
             `// created from many modules. This module is the single owner now:` && |\n| &&
             `//` && |\n| &&
             `//  - the PUBLIC fields stay plain properties on the global (they are a` && |\n| &&
             `//    contract with apps and the backend-generated HTML),` && |\n| &&
             `//  - every INTERNAL field lives in the private ``state`` object below and` && |\n| &&
             `//    is exposed on the global through transitional accessors, so all` && |\n| &&
             `//    existing consumers (including apps poking at internals via the` && |\n| &&
             `//    js_loader popup) keep working unchanged,` && |\n| &&
             `//  - initGlobal() creates/resets everything in one place - no other` && |\n| &&
             `//    module needs lazy ``if (!z2ui5.x) z2ui5.x = ...`` bootstrapping for` && |\n| &&
             `//    the fields listed here.` && |\n| &&
             `//` && |\n| &&
             `// PUBLIC contract on the global (plain properties, not managed here):` && |\n| &&
             `//   checkLocal        true when served by the backend GET page (backend HTML)` && |\n| &&
             `//   url               backend endpoint for roundtrips (App.controller)` && |\n| &&
             `//   oConfig           { S_UI5: version info, ComponentData } (Component)` && |\n| &&
             `//   Util              PUBLIC date helpers for view formatters - apps rely on` && |\n| &&
             `//                     this global and on the z2ui5/Util module (Component)` && |\n| &&
             `//   requestTimeoutMs  optional override for the roundtrip timeout (apps)` && |\n| &&
             `//   <custom>          apps can register functions via the js_loader popup` && |\n| &&
             `//                     and call them through the Z2UI5 frontend event` && |\n| &&
             `//` && |\n| &&
             `// INTERNAL field inventory (defaults in createState below) - writer in` && |\n| &&
             `// parentheses:` && |\n| &&
             `//` && |\n| &&
             `// Views / controllers / UI5 objects` && |\n| &&
             `//   oApp              sap.m.App hosting the main view (App.controller)` && |\n| &&
             `//   oOwnerComponent, oRouter, oDeviceModel (Component / App.controller)` && |\n| &&
             `//   oView, oViewNest, oViewNest2, oViewPopup, oViewPopover` && |\n| &&
             `//                     the five view slots, see core/ViewSlots.js (View1)` && |\n| &&
             `//   oController, oControllerNest, oControllerNest2, oControllerPopup,` && |\n| &&
             `//   oControllerPopover  controller instance per slot (App.controller)` && |\n| &&
             `//   oLaunchpad        FLP services when running inside the launchpad, else` && |\n| &&
             `//                     null (Component._initLaunchpad)` && |\n| &&
             `//` && |\n| &&
             `// Roundtrip state` && |\n| &&
             `//   oBody             mirror of the current request payload - the body` && |\n| &&
             `//                     itself travels as a parameter through` && |\n| &&
             `//                     Server.roundtrip/readHttp; this record exists for` && |\n| &&
             `//                     onBeforeRoundtrip hooks and the debug tool` && |\n| &&
             `//                     (View1.eB / Server)` && |\n| &&
             `//   oResponse         last processed response { ID, PARAMS, OVIEWMODEL }` && |\n| &&
             `//   responseData      raw parsed response JSON (Server.readHttp); kept` && |\n| &&
             `//                     besides oResponse because it carries fields the` && |\n| &&
             `//                     cooked record does not (e.g. S_FRONT.APP, used by` && |\n| &&
             `//                     the debug tool)` && |\n| &&
             `//   contextId         stateful session id, header transport (Server)` && |\n| &&
             `//   isBusy            roundtrip in flight (View1.eB / Server)` && |\n| &&
             `//   xxChangedPaths    Set of edited /XX/ model paths for the delta (View1)` && |\n| &&
             `//   checkNestAfter, checkNestAfter2  nested views rebuilt this roundtrip` && |\n| &&
             `//   search            overrides location.search in S_FRONT; never written` && |\n| &&
             `//                     by the framework itself, set externally (custom JS)` && |\n| &&
             `//   pendingCustomJs   follow-up JS to run after rendering (Server)` && |\n| &&
             `//` && |\n| &&
             `// Control / helper state` && |\n| &&
             `//   errors            capped error log, see Lib.logError` && |\n| &&
             `//   timers            single pending backend timer (FrontendAction)` && |\n| &&
             `//   lastScrolled      last scrolled element per slot (Server.onScrollCapture)` && |\n| &&
             `//   viewSizeLimits    per-slot model size limits (FrontendAction)` && |\n| &&
             `//   treeState         tree binding state across rebuilds (Tree control)` && |\n| &&
             `//   debugTool         DebugTool instance (Component, Ctrl+F12)` && |\n| &&
             `//   onBeforeRoundtrip, onAfterRoundtrip, onAfterRendering,` && |\n| &&
             `//   onBeforeEventFrontend  callback arrays, see Lib.registerCallback` && |\n| &&
             `sap.ui.define([], () => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  // Fresh defaults for every internal field. Collections start out as` && |\n| &&
             `  // empty containers so consumers can use them without existence checks.` && |\n| &&
             `  function createState() {` && |\n| &&
             `    return {` && |\n| &&
             `      // Views / controllers / UI5 objects` && |\n| &&
             `      oApp: null,` && |\n| &&
             `      oOwnerComponent: null,` && |\n| &&
             `      oRouter: null,` && |\n| &&
             `      oDeviceModel: null,` && |\n| &&
             `      oView: null,` && |\n| &&
             `      oViewNest: null,` && |\n| &&
             `      oViewNest2: null,` && |\n| &&
             `      oViewPopup: null,` && |\n| &&
             `      oViewPopover: null,` && |\n| &&
             `      oController: null,` && |\n| &&
             `      oControllerNest: null,` && |\n| &&
             `      oControllerNest2: null,` && |\n| &&
             `      oControllerPopup: null,` && |\n| &&
             `      oControllerPopover: null,` && |\n| &&
             `      oLaunchpad: null,` && |\n| &&
             `` && |\n| &&
             `      // Roundtrip state` && |\n| &&
             `      oBody: null,` && |\n| &&
             `      oResponse: null,` && |\n| &&
             `      responseData: null,` && |\n| &&
             `      contextId: null,` && |\n| &&
             `      isBusy: false,` && |\n| &&
             `      xxChangedPaths: new Set(),` && |\n| &&
             `      checkNestAfter: false,` && |\n| &&
             `      checkNestAfter2: false,` && |\n| &&
             `      search: null,` && |\n| &&
             `      pendingCustomJs: null,` && |\n| &&
             `` && |\n| &&
             `      // Control / helper state` && |\n| &&
             `      errors: [],` && |\n| &&
             `      timers: {},` && |\n| &&
             `      lastScrolled: {},` && |\n| &&
             `      viewSizeLimits: {},` && |\n| &&
             `      treeState: null,` && |\n| &&
             `      debugTool: null,` && |\n| &&
             `` && |\n| &&
             `      // Callback arrays (see Lib.registerCallback / Lib.runCallbacks)` && |\n| &&
             `      onBeforeRoundtrip: [],` && |\n| &&
             `      onAfterRoundtrip: [],` && |\n| &&
             `      onAfterRendering: [],` && |\n| &&
             `      onBeforeEventFrontend: [],` && |\n| &&
             `    };` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  let state = createState();` && |\n| &&
             `` && |\n| &&
             `  // Reset all internal fields to their defaults. The accessors installed` && |\n| &&
             `  // by initGlobal() read through to the current ``state``, so a reset is` && |\n| &&
             `  // immediately visible on the global.` && |\n| &&
             `  function reset() {` && |\n| &&
             `    state = createState();` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Prepare the z2ui5 global for a component start:` && |\n| &&
             `  //  - make sure the global exists (standalone there is no backend HTML` && |\n| &&
             `  //    declaring it),` && |\n| &&
             `  //  - start from a clean object when checkLocal === false,` && |\n| &&
             `  //  - reset the internal state and expose it via accessors,` && |\n| &&
             `  //  - provide a fresh oConfig for the bootstrap info.` && |\n| &&
             `  // Idempotent: a re-init (e.g. FLP re-launch) redefines the accessors` && |\n| &&
             `  // and starts from clean defaults again.` && |\n| &&
             `  function initGlobal() {` && |\n| &&
             `    if (typeof z2ui5 === "undefined" || z2ui5.checkLocal === false) {` && |\n| &&
             `      // Assign via window - a bare ``z2ui5 = {}`` would throw a` && |\n| &&
             `      // ReferenceError on an undeclared global in strict mode.` && |\n| &&
             `      window.z2ui5 = {};` && |\n| &&
             `    }` && |\n| &&
             `    reset();` && |\n| &&
             `    for (const name of Object.keys(state)) {` && |\n| &&
             `      const desc = Object.getOwnPropertyDescriptor(z2ui5, name);` && |\n| &&
             `      // Preserve a value someone put on the global before we took over` && |\n| &&
             `      // (plain data property only - accessors from a previous init` && |\n| &&
             `      // already delegate to ``state``).` && |\n| &&
             `      if (desc && "value" in desc && desc.value !== undefined) {` && |\n| &&
             `        state[name] = desc.value;` && |\n| &&
             `      }` && |\n| &&
             `      Object.defineProperty(z2ui5, name, {` && |\n| &&
             `        configurable: true,` && |\n| &&
             `        enumerable: true,` && |\n| &&
             `        get() {` && |\n| &&
             `          return state[name];` && |\n| &&
             `        },` && |\n| &&
             `        set(val) {` && |\n| &&
             `          state[name] = val;` && |\n| &&
             `        },` && |\n| &&
             `      });` && |\n| &&
             `    }` && |\n| &&
             `    z2ui5.oConfig = {};` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  return { initGlobal, reset };` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
