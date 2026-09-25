// The SHAPE of the frontend state of one z2ui5.Component - the field
// inventory below and its defaults (createState). The instance lives on
// the component's context (core/Context.js, one per component since
// 2026-09-23); framework modules reach it as `ctx.state`, and a custom
// control through Context.of(this). There is NO global and NO singleton:
// the `z2ui5` object on `window` that used to mirror every field was
// removed on 2026-09-22 (docs/removal-plan.md, section 0), and the one
// module-level `state` this file kept afterwards went with the
// per-component context - two components on a page used to reset each
// other through it. Configuration from the backend GET page arrives as
// component data (Component.init).
//
// createState() below creates every field with its default in one place -
// no module needs lazy `if (!state.x) state.x = ...` bootstrapping for the
// fields listed here; add a new field with its default there instead.
//
// Field inventory - writer in parentheses:
//
// Configuration
//   checkLocal        true when served by the backend GET page, which
//                     passes it as component data (Component.init)
//   endpoint          backend endpoint a host app passed as component data,
//                     e.g. through a ComponentContainer, else null
//                     (Component.init)
//   url               backend endpoint for roundtrips (App.controller)
//   oConfig           { S_UI5: version info, ComponentData } (Component)
//   ccResourceRoot    absolute path of the custom-control BSP, passed as
//                     component data by the backend GET page when there is
//                     no sibling BSP to resolve "../z2ui5_cci/" against
//                     (Component.init)
//   cccResourceRoot   same for the customer frontend-extension BSP
//                     ("../z2ui5_ccc/") (Component.init)
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
//   lastRequestBytes  length of the last request body as serialized
//                     (Server.readHttp) - in UTF-16 code units, the
//                     JSON.stringify result's length, not the bytes on the
//                     wire; the developer tools' recorder shows it as REQ
//                     so the body is not serialized a second time for it
//   lastMainDisplayOptions  the options of the last MAIN display
//                     (actions/Slots), so a re-display of the slot outside
//                     a roundtrip (devtools LiveEdit) keeps the OData
//                     default model a switch-mode view was built with
//   isBusy            roundtrip in flight (View1.eB / Server). Set for every
//                     roundtrip, a check_no_busy wire included - that flag
//                     hides the OVERLAY, it does not exempt the wire from
//                     being the one request in flight
//   oQueuedEvent      { controller, args } of the LAST event a
//                     check_queue_last wire fired while a roundtrip was in
//                     flight (View1.eB keeps it instead of dropping it);
//                     one slot, last wins. Dispatched by
//                     View1._dispatchQueuedEvent once the roundtrip has
//                     landed, dropped by Server.reset / responseError
//   oSentModel        the JSON model whose edited-path set the in-flight
//                     request carried; its own _z2ui5ChangedPaths is cleared
//                     once that request wins (Server), so a stale response
//                     never clears newer edits and edits made in a DIFFERENT
//                     model (e.g. a popover) are never shipped against this one
//
// Control / helper state
//   timers            single pending backend timer (actions/ViewOps)
//   shortcuts         registered keyboard shortcuts, normalized combo ->
//                     scope -> { event, controller }, the scope being a view
//                     slot key or "" for unscoped (actions/Shortcuts). Dispatch takes the innermost OPEN
//                     scope, so a popover-local shortcut shadows the page one
//                     the way a UI5 CommandExecution in dependents does;
//                     an app switch resets it, the document listener stays
//   lastScrolled      last scrolled element per slot (ScrollFocus.onScrollCapture)
//   odataClients      every OData client the FRAMEWORK created for the MAIN
//                     view - the switch-mode default model (actions/Slots
//                     displayView) and every SET_ODATA_MODEL client, named
//                     or not (actions/ViewOps). A model is no aggregation,
//                     so none of them dies with the view: the next MAIN
//                     rebuild destroys the whole set (actions/Slots
//                     displayMain) and every display/replace path removes
//                     what it destroyed itself. Nothing an APP put on a
//                     view is ever in here, so nothing app-owned is touched
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

  // Fresh defaults for every field. Collections start out as empty
  // containers so consumers can use them without existence checks. Called
  // once per component by Context.create, and again by Context.destroy so
  // a dead context releases what it held.
  function createState() {
    return {
      // Configuration
      checkLocal: false,
      endpoint: null,
      url: null,
      oConfig: {},
      ccResourceRoot: null,
      cccResourceRoot: null,

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
      oQueuedEvent: null,
      oSentModel: null,
      lastRequestBytes: null,
      lastMainDisplayOptions: null,

      // Hash-based app routing (UI5 Router style, opt-in per app via
      // follow_up_action( cs_event-hash_routing )).
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

      // Control / helper state. The records keyed by a value that comes off
      // the wire - a timer key, a shortcut combo, a view key, a tree id -
      // are prototype-less: on a plain object `record["constructor"]`
      // answers Object.prototype's function and `record["__proto__"] = x`
      // writes into the prototype itself, so a malformed key was a wrong
      // answer or a write into every object of the page instead of a miss.
      // Same reason the dispatch tables in core/FrontendAction.js and
      // core/actions/ControlCall.js are built with Object.create(null).
      // (The error log is not here: Lib.logError's ring is page-wide.)
      timers: Object.create(null),
      shortcuts: Object.create(null),
      lastScrolled: {},
      odataClients: new Set(),
      viewSizeLimits: Object.create(null),
      treeStates: Object.create(null),
      lastError: null,

      // Callback arrays (see Lib.registerCallback / Lib.runCallbacks)
      onBeforeRoundtrip: [],
      onAfterRoundtrip: [],
      onAfterRendering: [],
      onBeforeEventFrontend: [],
      onErrorDetails: [],
    };
  }

  return { createState };
});
