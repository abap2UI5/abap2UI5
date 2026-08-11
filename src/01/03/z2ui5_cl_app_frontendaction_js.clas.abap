* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Embedded frontend resource, generated from app/webapp/ by
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
CLASS z2ui5_cl_app_frontendaction_js DEFINITION
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


CLASS z2ui5_cl_app_frontendaction_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    "sap/m/MessageBox",` && |\n| &&
             `    "sap/m/MessageToast",` && |\n| &&
             `    "sap/ui/core/BusyIndicator",` && |\n| &&
             `    "sap/ui/model/odata/v2/ODataModel",` && |\n| &&
             `    "sap/ui/model/Filter",` && |\n| &&
             `    "sap/ui/model/FilterOperator",` && |\n| &&
             `    "sap/ui/model/Sorter",` && |\n| &&
             `    "sap/m/library",` && |\n| &&
             `    "sap/ui/util/Storage",` && |\n| &&
             `    "z2ui5/core/Router",` && |\n| &&
             `    "z2ui5/core/Lib",` && |\n| &&
             `    "z2ui5/core/Messages",` && |\n| &&
             `    "z2ui5/core/ViewSlots",` && |\n| &&
             `    "z2ui5/core/AppState",` && |\n| &&
             `  ],` && |\n| &&
             `  (` && |\n| &&
             `    MessageBox,` && |\n| &&
             `    MessageToast,` && |\n| &&
             `    BusyIndicator,` && |\n| &&
             `    ODataModel,` && |\n| &&
             `    Filter,` && |\n| &&
             `    FilterOperator,` && |\n| &&
             `    Sorter,` && |\n| &&
             `    mobileLibrary,` && |\n| &&
             `    Storage,` && |\n| &&
             `    Router,` && |\n| &&
             `    Lib,` && |\n| &&
             `    Messages,` && |\n| &&
             `    ViewSlots,` && |\n| &&
             `    AppState,` && |\n| &&
             `  ) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Frontend actions: the handlers behind the controller's eF() entry` && |\n| &&
             `    // point. eF itself stays on View1.controller (its name is part of the` && |\n| &&
             `    // protocol - backend-generated view XML binds events to eB/eF); the` && |\n| &&
             `    // behavior lives here, one function per event. Handlers that need to` && |\n| &&
             `    // reach controller state (destroyPopup, eB, ...) receive the calling` && |\n| &&
             `    // controller as first argument.` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    const _URLHelper = mobileLibrary.URLHelper;` && |\n| &&
             `` && |\n| &&
             `    // Animation duration (ms) mapped to a "smooth" scroll request; 0 means an` && |\n| &&
             `    // instant jump. Shared by every scroll path in evScrollTo.` && |\n| &&
             `    const SMOOTH_SCROLL_MS = 300;` && |\n| &&
             `` && |\n| &&
             `    // SMART_VARIANT_INIT waits for the smart controls to register themselves at` && |\n| &&
             `    // the SmartVariantManagement - that happens once their OData metadata has` && |\n| &&
             `    // loaded, so the wait has to survive a slow service (5s) but must not run` && |\n| &&
             `    // forever when no smart control is there at all.` && |\n| &&
             `    const SMART_VARIANT_INIT_TRIES = 50;` && |\n| &&
             `    const SMART_VARIANT_INIT_DELAY = 100;` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Launchpad helpers` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    function withCrossAppNavigator(callback) {` && |\n| &&
             `      const nav = AppState.state.oLaunchpad?.CrossAppNavigator;` && |\n| &&
             `      if (!nav) {` && |\n| &&
             `        Lib.logError("CrossAppNav: not running inside Launchpad");` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      try {` && |\n| &&
             `        callback(nav);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("CrossAppNav: callback failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // NavContainer navigation (NAV_CONTAINER_TO and the NEST/NEST2/POPUP/` && |\n| &&
             `    // POPOVER variants) is no longer dispatched here: the backend routes those` && |\n| &&
             `    // events through the generic CONTROL_BY_ID path (method "to", the` && |\n| &&
             `    // slot passed as the view), so evControlCallById below handles them.` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // CONTROL_GLOBAL / CONTROL_BY_ID: call a whitelisted method on a` && |\n| &&
             `    // control (by id) or a global object. The whitelist is the safety` && |\n| &&
             `    // boundary; each entry lists the kind of every positional argument so` && |\n| &&
             `    // string payloads are cast/resolved (never "call anything with` && |\n| &&
             `    // anything"). Scope: imperative methods that have no binding equivalent.` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    // control method -> kinds of its positional args. Args beyond the` && |\n| &&
             `    // declared kinds are dropped; trailing args the caller did not send are` && |\n| &&
             `    // not passed at all (so ``open()`` stays a true no-arg call).` && |\n| &&
             `    const CONTROL_METHODS = {` && |\n| &&
             `      to: ["controlId", "string"], // target page + optional transitionName` && |\n| &&
             `      back: [],` && |\n| &&
             `      toDetail: ["controlId"], // sap.m.SplitApp/SplitContainer: show a detail page` && |\n| &&
             `      toMaster: ["controlId"], // sap.m.SplitApp/SplitContainer: show a master page` && |\n| &&
             `      backDetail: [], // sap.m.SplitApp/SplitContainer: back in the detail stack` && |\n| &&
             `      backMaster: [], // sap.m.SplitApp/SplitContainer: back in the master stack` && |\n| &&
             `      setMode: ["string"], // sap.m.SplitApp/SplitContainer: SplitAppMode` && |\n| &&
             `      navigateBack: [], // sap.m.QuickView/QuickViewCard: navigate one page back` && |\n| &&
             `      focus: [],` && |\n| &&
             `      scrollToIndex: ["int"],` && |\n| &&
             `      scrollTo: ["int", "int"],` && |\n| &&
             `      open: ["string"], // optional page key (ViewSettingsDialog); PDFViewer/Dialog ignore it` && |\n| &&
             `      close: [],` && |\n| &&
             `      setExpanded: ["bool"],` && |\n| &&
             `      discardProgress: ["controlId"],` && |\n| &&
             `      setNextStep: ["controlId"],` && |\n| &&
             `      goToStep: ["controlId", "bool"], // Wizard: target step + focus flag` && |\n| &&
             `      openBy: ["anchor"], // DatePicker/TimePicker/Menu/MessagePopover... anchored open` && |\n| &&
             `      toggleBy: ["anchor"], // sap.m.Menu/MessagePopover: open anchored if closed, close if open` && |\n| &&
             `      setActivePage: ["controlId"], // sap.m.Carousel` && |\n| &&
             `      expandToLevel: ["int"], // sap.m.Tree / sap.ui.table.TreeTable: expand to N levels` && |\n| &&
             `      collapseAll: [], // sap.m.Tree / sap.ui.table.TreeTable: collapse every node` && |\n| &&
             `      setHiddenInPopin: ["object"], // sap.m.Table: hide columns by importance (JSON array of Priority keys)` && |\n| &&
             `      setSticky: ["object"], // sap.m.ListBase/sap.m.Table: JSON array of sap.m.Sticky keys` && |\n| &&
             `      setSelectedSection: ["controlIdOrNull"], // sap.uxap.ObjectPageLayout: an EMPTY argument clears the association` && |\n| &&
             `      setSelectedItem: ["controlIdOrNull"], // sap.m.List/sap.m.Select/...: an EMPTY argument clears the selection` && |\n| &&
             `      setP13nData: ["object"], // sap.m.p13n.*Panel: JSON array of the panel's items` && |\n| &&
             `` && |\n| &&
             `      css: ["string", "string"], // NOT a UI5 method: set one CSS property on the control's own DOM node` && |\n| &&
             `      enablePostButton: ["bool"], // sap.m.FeedInput: toggle the Post button independent of ``enabled``` && |\n| &&
             `      addStyleClass: ["string"], // sap.ui.core.Control: add a CSS style class` && |\n| &&
             `      removeStyleClass: ["string"], // sap.ui.core.Control: remove a CSS style class` && |\n| &&
             `      toggleStyleClass: ["string"], // sap.ui.core.Control: toggle a CSS style class` && |\n| &&
             `      setAsyncURLHandler: ["string"], // sap.m.MessagePopover: name of a URL_POLICY below` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    // sap.m.MessagePopover.setAsyncURLHandler expects a live JS callback that` && |\n| &&
             `    // resolves a promise per message link - a shape no backend payload can` && |\n| &&
             `    // carry, and one round-trip per link would be the wrong ergonomics anyway.` && |\n| &&
             `    // The backend names one of these built-in policies instead, so the` && |\n| &&
             `    // link-gating stays declarative data on the wire (see rule "the frontend is` && |\n| &&
             `    // a thin, data-driven executor").` && |\n| &&
             `    const URL_POLICIES = {` && |\n| &&
             `      ALLOW_ALL: () => true,` && |\n| &&
             `      // the sap.m MessagePopover demo case: in-app links (#/x, /path, ?q=) may` && |\n| &&
             `      // be followed, anything that leaves the app (http:, mailto:, //host) is` && |\n| &&
             `      // disabled in the popover.` && |\n| &&
             `      RELATIVE_ONLY: (url) => !isAbsoluteUrl(url),` && |\n| &&
             `      DENY_ALL: () => false,` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    // CONTROL_METHODS.css writes ONE declaration onto the control's own DOM` && |\n| &&
             `    // node. It exists for the case where a control has no property for the` && |\n| &&
             `    // value at all - sap.m.Page has no ``width``, so a sample that resizes its` && |\n| &&
             `    // container (a Slider driving ``byId(...).$().width(v + "%")``) has nothing` && |\n| &&
             `    // to bind and no method to call. Where the target DOES have the property,` && |\n| &&
             `    // a bound property stays the correct path (rule "prefer a bindable` && |\n| &&
             `    // property"); this is the residue, not a general styling API.` && |\n| &&
             `    //` && |\n| &&
             `    // The property name is checked against this list so the wire stays a` && |\n| &&
             `    // narrow, declarative contract instead of "write anything anywhere"; the` && |\n| &&
             `    // value goes through CSSOM setProperty, which drops an invalid declaration` && |\n| &&
             `    // (a smuggled second declaration never parses).` && |\n| &&
             `    const CSS_PROPERTIES = [` && |\n| &&
             `      "width",` && |\n| &&
             `      "min-width",` && |\n| &&
             `      "max-width",` && |\n| &&
             `      "height",` && |\n| &&
             `      "min-height",` && |\n| &&
             `      "max-height",` && |\n| &&
             `      "color",` && |\n| &&
             `      "background-color",` && |\n| &&
             `      "font-size",` && |\n| &&
             `      "opacity",` && |\n| &&
             `    ];` && |\n| &&
             `` && |\n| &&
             `    function isAbsoluteUrl(url) {` && |\n| &&
             `      const s = String(url ?? "").trim();` && |\n| &&
             `      // a scheme ("http:", "mailto:", "javascript:") or a protocol-relative` && |\n| &&
             `      // "//host" - everything else resolves against the app's own origin` && |\n| &&
             `      return /^[a-z][a-z0-9+.-]*:/i.test(s) || s.startsWith("//");` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // A method LISTED above carries explicit arg kinds (and some, like openBy/` && |\n| &&
             `    // toggleBy, get special handling). A method NOT listed is still callable as` && |\n| &&
             `    // long as it is a public control method that is not framework-hostile - so` && |\n| &&
             `    // ordinary setters/toggles (setVisible, enablePostButton, setLayout, ...) work` && |\n| &&
             `    // without enumerating each one here. The denylist protects abap2UI5's own` && |\n| &&
             `    // invariants: nothing that frees or reparents a tracked control, swaps the` && |\n| &&
             `    // model/binding out from under the framework, tampers with event handlers, or` && |\n| &&
             `    // drives the render lifecycle by hand. (The backend is the trusted driver, so` && |\n| &&
             `    // this is a footgun guard, not a security boundary - and control[method] is` && |\n| &&
             `    // still checked to be a function before the call, so a typo just no-ops.)` && |\n| &&
             `    // Named setters/mutators (setVisible, addItem, removeItem, ...) stay` && |\n| &&
             `    // allowed - they are the API the backend legitimately drives. Denied are` && |\n| &&
             `    // the framework-hostile methods: teardown/reparenting (destroy, exit,` && |\n| &&
             `    // setParent, addDependent, placeAt), model/binding swaps (setModel,` && |\n| &&
             `    // setBinding*, bind*/unbind*), event-handler tampering (attach*/detach*,` && |\n| &&
             `    // fireEvent), the render lifecycle (rerender, invalidate) and the GENERIC` && |\n| &&
             `    // reflection mutators (setAggregation/addAggregation/insertAggregation/` && |\n| &&
             `    // removeAggregation/removeAllAggregation and their Association twins),` && |\n| &&
             `    // which take the member NAME as an argument and reparent tracked controls` && |\n| &&
             `    // behind the framework's back.` && |\n| &&
             `    // Two lists, because the two halves need different matching. A generic` && |\n| &&
             `    // reflection mutator has ONE spelling, so it is denied by EXACT name -` && |\n| &&
             `    // matching it by prefix would swallow the named per-aggregation methods` && |\n| &&
             `    // that share those first characters (removeAllSelectedDates,` && |\n| &&
             `    // removeAllItems, destroySpecialDates, ...), which are exactly the API` && |\n| &&
             `    // this allowlist is meant to offer: they detach or destroy children the` && |\n| &&
             `    // control itself owns - the same footprint the already-allowed removeItem` && |\n| &&
             `    // has - and carry no invariant beyond it. The other half is hostile in` && |\n| &&
             `    // every spelling (bindProperty as much as bind), so it stays a PREFIX.` && |\n| &&
             `    // Built from lists (not one long literal) so no single source line is too` && |\n| &&
             `    // long once embedded into the ABAP string constant (trans2abap.js caps` && |\n| &&
             `    // generated lines at 255 chars).` && |\n| &&
             `    const CONTROL_METHOD_DENY_EXACT = [` && |\n| &&
             `      "destroy",` && |\n| &&
             `      "exit",` && |\n| &&
             `      "fireEvent",` && |\n| &&
             `      "clone",` && |\n| &&
             `      "applySettings",` && |\n| &&
             `      "setAggregation",` && |\n| &&
             `      "addAggregation",` && |\n| &&
             `      "insertAggregation",` && |\n| &&
             `      "removeAggregation",` && |\n| &&
             `      "removeAllAggregation",` && |\n| &&
             `      "destroyAggregation",` && |\n| &&
             `      "setAssociation",` && |\n| &&
             `      "addAssociation",` && |\n| &&
             `      "removeAssociation",` && |\n| &&
             `      "removeAllAssociation",` && |\n| &&
             `    ];` && |\n| &&
             `    const CONTROL_METHOD_DENY_PREFIXES = [` && |\n| &&
             `      "_",` && |\n| &&
             `      "bind",` && |\n| &&
             `      "unbind",` && |\n| &&
             `      "attach",` && |\n| &&
             `      "detach",` && |\n| &&
             `      "addDependent",` && |\n| &&
             `      "placeAt",` && |\n| &&
             `      "rerender",` && |\n| &&
             `      "invalidate",` && |\n| &&
             `      "setModel",` && |\n| &&
             `      "setBinding", // covers setBindingContext` && |\n| &&
             `      "setParent",` && |\n| &&
             `    ];` && |\n| &&
             `    const CONTROL_METHOD_DENY = new RegExp(` && |\n| &&
             `      "^(" + CONTROL_METHOD_DENY_PREFIXES.join("|") + ")",` && |\n| &&
             `    );` && |\n| &&
             `    const CONTROL_METHOD_DENY_SET = new Set(CONTROL_METHOD_DENY_EXACT);` && |\n| &&
             `    function isSafeControlMethod(method) {` && |\n| &&
             `      return (` && |\n| &&
             `        typeof method === "string" &&` && |\n| &&
             `        method.length > 0 &&` && |\n| &&
             `        !CONTROL_METHOD_DENY_SET.has(method) &&` && |\n| &&
             `        !CONTROL_METHOD_DENY.test(method)` && |\n| &&
             `      );` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // global object -> lazy getter + its allowed methods (with arg kinds).` && |\n| &&
             `    const GLOBAL_TARGETS = {` && |\n| &&
             `      // The two message targets carry a ``display`` hook: the call is routed` && |\n| &&
             `      // through Messages instead of straight at the global, so the option` && |\n| &&
             `      // handling client->message_toast_display( ) / message_box_display( )` && |\n| &&
             `      // relies on - an ONCLOSE event name turned into an eB() round-trip, the` && |\n| &&
             `      // details sanitizing, dependentOn, the toast style class - lives in one` && |\n| &&
             `      // place. A bare app call simply arrives without options.` && |\n| &&
             `      MESSAGE_TOAST: {` && |\n| &&
             `        get: () => MessageToast,` && |\n| &&
             `        methods: { show: ["string"] },` && |\n| &&
             `        display: (oController, method, aArgs, mOptions) =>` && |\n| &&
             `          Messages.showToast(aArgs[0], mOptions, oController),` && |\n| &&
             `      },` && |\n| &&
             `      MESSAGE_BOX: {` && |\n| &&
             `        get: () => MessageBox,` && |\n| &&
             `        // the method IS the box type - the availability check below then` && |\n| &&
             `        // reports a type this UI5 version does not carry` && |\n| &&
             `        methods: {` && |\n| &&
             `          show: ["string"],` && |\n| &&
             `          alert: ["string"],` && |\n| &&
             `          confirm: ["string"],` && |\n| &&
             `          information: ["string"],` && |\n| &&
             `          warning: ["string"],` && |\n| &&
             `          error: ["string"],` && |\n| &&
             `          success: ["string"],` && |\n| &&
             `        },` && |\n| &&
             `        display: (oController, method, aArgs, mOptions) =>` && |\n| &&
             `          Messages.showBox(method, aArgs[0], mOptions, oController),` && |\n| &&
             `      },` && |\n| &&
             `      // Not a UI5 global but the framework's own view-slot registry: the` && |\n| &&
             `      // slots (MAIN, NEST, NEST2, POPUP, POPOVER) are what a backend response` && |\n| &&
             `      // opens, fills and tears down, and every one of those calls is a` && |\n| &&
             `      // SYSTEM follow-up action. ``display`` and ``updateModel`` are not` && |\n| &&
             `      // ViewSlots methods - they live on the controller, which owns the` && |\n| &&
             `      // fragment loading and the model - so the hook below routes them there.` && |\n| &&
             `      VIEW_SLOTS: {` && |\n| &&
             `        get: () => ViewSlots,` && |\n| &&
             `        // display takes TWO positional arguments, the slot and the view XML.` && |\n| &&
             `        // Declaring both also keeps it off the template path below, which` && |\n| &&
             `        // would otherwise read the XML as a placeholder value for the slot.` && |\n| &&
             `        methods: {` && |\n| &&
             `          destroy: ["string"],` && |\n| &&
             `          display: ["string", "string"],` && |\n| &&
             `          updateModel: ["string"],` && |\n| &&
             `        },` && |\n| &&
             `        display: (oController, method, aArgs, mOptions) =>` && |\n| &&
             `          oController.slotAction(method, aArgs[0], aArgs[1], mOptions),` && |\n| &&
             `        // display and updateModel are not ViewSlots methods at all, so the` && |\n| &&
             `        // "does this UI5 version carry it" check below has nothing to look` && |\n| &&
             `        // at - and nothing to answer either, since none of the three depends` && |\n| &&
             `        // on the UI5 version. The whitelist above is the only gate.` && |\n| &&
             `        virtualMethods: true,` && |\n| &&
             `      },` && |\n| &&
             `      BUSY_INDICATOR: {` && |\n| &&
             `        get: () => BusyIndicator,` && |\n| &&
             `        methods: { show: ["int"], hide: [] },` && |\n| &&
             `      },` && |\n| &&
             `      // sap/ui/core/Theming only exists since UI5 1.118, so it must NOT be a` && |\n| &&
             `      // hard dependency (it 404s on 1.71 and kills the whole component load).` && |\n| &&
             `      // Resolve it lazily: on modern UI5 the core has it loaded, on 1.71 the` && |\n| &&
             `      // require returns undefined and the dispatch reports "not available".` && |\n| &&
             `      THEMING: {` && |\n| &&
             `        get: () => sap.ui.require("sap/ui/core/Theming"),` && |\n| &&
             `        methods: { setTheme: ["string"] },` && |\n| &&
             `      },` && |\n| &&
             `      // sap/ui/core/Popup exists on every supported release, but` && |\n| &&
             `      // setWithinArea is @since 1.89 - so resolve the module lazily like` && |\n| &&
             `      // THEMING and let the "not available" guard below report the older` && |\n| &&
             `      // runtime instead of failing the component load.` && |\n| &&
             `      POPUP: {` && |\n| &&
             `        get: () => sap.ui.require("sap/ui/core/Popup"),` && |\n| &&
             `        methods: { setWithinArea: ["within"] },` && |\n| &&
             `      },` && |\n| &&
             `      // sap/ui/core/InvisibleMessage is @since 1.78 and is a SINGLETON: it` && |\n| &&
             `      // renders nothing, so it has no id CONTROL_BY_ID could resolve - a` && |\n| &&
             `      // global target is the only way a backend-driven content change can be` && |\n| &&
             `      // announced to a screen reader. Lazy-require like THEMING so 1.71 hits` && |\n| &&
             `      // the "not available" guard instead of failing the component load.` && |\n| &&
             `      // announce(sText, sMode) with sMode Polite (default) | Assertive.` && |\n| &&
             `      INVISIBLE_MESSAGE: {` && |\n| &&
             `        get: () => {` && |\n| &&
             `          const IM = sap.ui.require("sap/ui/core/InvisibleMessage");` && |\n| &&
             `          return IM ? IM.getInstance() : undefined;` && |\n| &&
             `        },` && |\n| &&
             `        methods: { announce: ["string", "string"] },` && |\n| &&
             `      },` && |\n| &&
             `      // sap/ui/core/Formatting (@since 1.120) carries the global formatting` && |\n| &&
             `      // configuration. Custom currencies are the case an app cannot express` && |\n| &&
             `      // otherwise: the digit count of a currency code is neither a control` && |\n| &&
             `      // property nor something a per-binding formatter can register for the` && |\n| &&
             `      // standard sap.ui.model.type.Currency. The payload is a JSON object -` && |\n| &&
             `      // data the backend owns anyway. Lazy-require like THEMING.` && |\n| &&
             `      FORMATTING: {` && |\n| &&
             `        get: () => sap.ui.require("sap/ui/core/Formatting"),` && |\n| &&
             `        methods: {` && |\n| &&
             `          setCustomCurrencies: ["object"], // { CODE: { digits: n }, ... }` && |\n| &&
             `          addCustomCurrency: ["string", "object"], // code, { digits: n }` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    // Cast one raw string argument to the kind the whitelist declared.` && |\n| &&
             `    // ``view`` (optional) is the slot the owning control was resolved in, so a` && |\n| &&
             `    // controlId argument resolves against the same view first - this keeps` && |\n| &&
             `    // slot-local ids unambiguous (e.g. a NavContainer navigating to one of` && |\n| &&
             `    // its own pages) before falling back to the global lookup.` && |\n| &&
             `    // A control CLONED from an aggregation template has no id the backend can` && |\n| &&
             `    // spell. UI5 mints it as ``<templateId>-<parentId>-<index>`` - deterministic,` && |\n| &&
             `    // but the parent id carries the VIEW PREFIX the framework assigns at` && |\n| &&
             `    // runtime (``v1--tpl-v1--car-0``), which the backend never sees. So an` && |\n| &&
             `    // aggregation item is addressed positionally instead:` && |\n| &&
             `    //` && |\n| &&
             `    //     "<controlId>/<aggregation>/<index>"     e.g. "carousel/pages/2"` && |\n| &&
             `    //` && |\n| &&
             `    // resolved here, on the client, where both the prefix and the aggregation` && |\n| &&
             `    // are known. This is the equivalent of the UI5 controller idiom` && |\n| &&
             `    // ``oCarousel.setActivePage(oCarousel.getPages()[i])``, which no id-based` && |\n| &&
             `    // call can express. A plain id (no slashes) resolves exactly as before.` && |\n| &&
             `    const AGG_ITEM = /^([^/]+)\/([A-Za-z_][\w]*)\/(\d+)$/;` && |\n| &&
             `` && |\n| &&
             `    function resolveControl(raw, view) {` && |\n| &&
             `      const byId = (id) =>` && |\n| &&
             `        (view && ViewSlots.byId(view.toUpperCase(), id)) ||` && |\n| &&
             `        ViewSlots.resolveById(id);` && |\n| &&
             `` && |\n| &&
             `      const m = AGG_ITEM.exec(String(raw ?? ""));` && |\n| &&
             `      if (!m) return byId(raw);` && |\n| &&
             `` && |\n| &&
             `      const owner = byId(m[1]);` && |\n| &&
             `      if (!owner || typeof owner.getAggregation !== "function") {` && |\n| &&
             `        Lib.logError(``aggregation item '${raw}': no control '${m[1]}'``);` && |\n| &&
             `        return null;` && |\n| &&
             `      }` && |\n| &&
             `      const items = owner.getAggregation(m[2]);` && |\n| &&
             `      if (!Array.isArray(items)) {` && |\n| &&
             `        Lib.logError(` && |\n| &&
             `          ``aggregation item '${raw}': '${m[2]}' is no multiple aggregation of ${m[1]}``,` && |\n| &&
             `        );` && |\n| &&
             `        return null;` && |\n| &&
             `      }` && |\n| &&
             `      const item = items[Number(m[3])];` && |\n| &&
             `      if (!item) {` && |\n| &&
             `        // out of range is not an error the app can see otherwise - the method` && |\n| &&
             `        // would silently receive undefined and do nothing` && |\n| &&
             `        Lib.logError(` && |\n| &&
             `          ``aggregation item '${raw}': ${m[2]} has ${items.length} item(s)``,` && |\n| &&
             `        );` && |\n| &&
             `        return null;` && |\n| &&
             `      }` && |\n|.
    result = result &&
             `      return item;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function castArg(kind, raw, view) {` && |\n| &&
             `      switch (kind) {` && |\n| &&
             `        case "int":` && |\n| &&
             `          return Number(raw);` && |\n| &&
             `        case "bool":` && |\n| &&
             `          return raw === "true" || raw === "X" || raw === true;` && |\n| &&
             `        case "controlId":` && |\n| &&
             `          return resolveControl(raw, view);` && |\n| &&
             `        case "controlIdOrNull":` && |\n| &&
             `          // an ASSOCIATION cannot be data-bound, so clearing one` && |\n| &&
             `          // (setSelectedSection(null), setSelectedItem(null)) can only travel` && |\n| &&
             `          // as a method argument - and an EMPTY argument must arrive as null,` && |\n| &&
             `          // not as the ``false`` castArgAuto would infer. Same "empty means` && |\n| &&
             `          // null" contract as the ``within`` kind below.` && |\n| &&
             `          if (raw === "" || raw === undefined || raw === null) return null;` && |\n| &&
             `          return resolveControl(raw, view) || null;` && |\n| &&
             `        case "anchor":` && |\n| &&
             `          // anchor argument for openBy-style methods: resolve the control id` && |\n| &&
             `          // and hand over the CONTROL itself, not its DOM element. Every` && |\n| &&
             `          // sap.m openBy accepts a control, and MessagePopover.openBy` && |\n| &&
             `          // dereferences oControl.getParent() on its argument, so a bare DOM` && |\n| &&
             `          // element throws ("getParent is not a function") and the popup never` && |\n| &&
             `          // opens. DatePicker/TimePicker/Menu accept a control just as well,` && |\n| &&
             `          // so a control is the universally-correct anchor.` && |\n| &&
             `          return resolveControl(raw, view);` && |\n| &&
             `        case "within":` && |\n| &&
             `          // sap.ui.core.Popup.setWithinArea: a control id confines every popup` && |\n| &&
             `          // to that control, an EMPTY argument releases the restriction (the` && |\n| &&
             `          // popup is bounded by the window again). Popup.convertWithin()` && |\n| &&
             `          // accepts a sap.ui.core.Element and dereferences its DOM node when a` && |\n| &&
             `          // popup opens, so handing over the CONTROL - not its DOM element -` && |\n| &&
             `          // is what survives a re-render of the area in between.` && |\n| &&
             `          if (raw === "" || raw === undefined || raw === null) return null;` && |\n| &&
             `          return resolveControl(raw, view) || null;` && |\n| &&
             `        case "object":` && |\n| &&
             `          // the backend embeds an argument that starts with { or [ as real` && |\n| &&
             `          // JSON (get_event_client_json), so on that path the value arrives` && |\n| &&
             `          // already parsed; only the legacy eF( ) string form needs parsing.` && |\n| &&
             `          if (raw && typeof raw === "object") return raw;` && |\n| &&
             `          try {` && |\n| &&
             `            return JSON.parse(raw);` && |\n| &&
             `          } catch {` && |\n| &&
             `            return {};` && |\n| &&
             `          }` && |\n| &&
             `        default:` && |\n| &&
             `          return raw;` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Infer the type of an argument for a method with no declared kinds (the` && |\n| &&
             `    // generalized-allowlist path). abap2UI5 sends booleans as the ABAP tokens` && |\n| &&
             `    // 'X'/space, so recognize those; everything else passes through as a string` && |\n| &&
             `    // (UI5 coerces numeric strings for index/number setters). A method that needs` && |\n| &&
             `    // a literal 'X'/'true'/'false' string or a JSON object must be declared in` && |\n| &&
             `    // CONTROL_METHODS with an explicit kind, which overrides this inference.` && |\n| &&
             `    function castArgAuto(raw) {` && |\n| &&
             `      if (raw === "X" || raw === "true") return true;` && |\n| &&
             `      if (raw === "" || raw === " " || raw === "false") return false;` && |\n| &&
             `      return raw;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // kinds whose EMPTY value is meaningful (null), so a missing trailing` && |\n| &&
             `    // argument still has to be passed: the backend wire drops a trailing empty` && |\n| &&
             `    // t_arg entry, and "clear this association" is exactly a call whose only` && |\n| &&
             `    // argument is empty.` && |\n| &&
             `    const NULLABLE_KINDS = ["controlIdOrNull"];` && |\n| &&
             `` && |\n| &&
             `    function castArgs(kinds, rawArgs, view) {` && |\n| &&
             `      // kinds === null: unlisted-but-allowed method, infer each arg's type` && |\n| &&
             `      if (kinds === null) return rawArgs.map((raw) => castArgAuto(raw));` && |\n| &&
             `      // only cast args the caller actually sent - padding missing trailing` && |\n| &&
             `      // args would turn open() into open(undefined) and ints into NaN. The one` && |\n| &&
             `      // exception is a nullable kind (see above): pad it so the call carries` && |\n| &&
             `      // an explicit null instead of relying on the control's no-arg handling.` && |\n| &&
             `      let count = rawArgs.length;` && |\n| &&
             `      while (count < kinds.length && NULLABLE_KINDS.includes(kinds[count]))` && |\n| &&
             `        count++;` && |\n| &&
             `      return kinds` && |\n| &&
             `        .slice(0, count)` && |\n| &&
             `        .map((kind, i) => castArg(kind, rawArgs[i], view));` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Run fn once the openBy/toggleBy anchor is in the DOM. A control anchor` && |\n| &&
             `    // goes through Lib.whenRendered (immediate if already rendered, otherwise` && |\n| &&
             `    // after its next onAfterRendering); anything else (a bare DOM element, or a` && |\n| &&
             `    // missing anchor) runs fn straight away.` && |\n| &&
             `    function whenAnchorRendered(anchor, oController, fn) {` && |\n| &&
             `      if (anchor && typeof anchor.getDomRef === "function") {` && |\n| &&
             `        Lib.whenRendered(anchor, oController, fn);` && |\n| &&
             `      } else {` && |\n| &&
             `        fn();` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // args: [_, id, view, method, ...params]` && |\n| &&
             `    function evControlCallById(oController, args) {` && |\n| &&
             `      const [, id, view, method] = args;` && |\n| &&
             `      let kinds = CONTROL_METHODS[method];` && |\n| &&
             `      if (!kinds) {` && |\n| &&
             `        // not explicitly listed: allow any public, non-hostile control method` && |\n| &&
             `        // (kinds = null -> arg types are inferred), else fail closed.` && |\n| &&
             `        if (!isSafeControlMethod(method)) {` && |\n| &&
             `          Lib.logError(``CONTROL_BY_ID: method '${method}' not allowed``);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        kinds = null;` && |\n| &&
             `      }` && |\n| &&
             `      const control = view` && |\n| &&
             `        ? ViewSlots.byId(view.toUpperCase(), id)` && |\n| &&
             `        : ViewSlots.resolveById(id);` && |\n| &&
             `      // toggleBy is not a real control method: open the control anchored to` && |\n| &&
             `      // the anchor control if it is closed, close it if it is already open` && |\n| &&
             `      // (mirrors openBy for a press-to-toggle button). The popup's open state lives` && |\n| &&
             `      // client-side, so the decision stays here rather than round-tripping.` && |\n| &&
             `      if (method === "toggleBy") {` && |\n| &&
             `        if (!control || typeof control.openBy !== "function") {` && |\n| &&
             `          Lib.logError(` && |\n| &&
             `            ``CONTROL_BY_ID: 'toggleBy' not callable on control '${id}'``,` && |\n| &&
             `          );` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        const anchor = castArgs(kinds, args.slice(4), view)[0];` && |\n| &&
             `        // Defer the open until the anchor is rendered: a Save-style roundtrip` && |\n| &&
             `        // can make the anchor (e.g. a button hidden until there are messages)` && |\n| &&
             `        // visible in the same response, so it may not be in the DOM yet.` && |\n| &&
             `        whenAnchorRendered(anchor, oController, () => {` && |\n| &&
             `          if (control.isOpen?.()) control.close();` && |\n| &&
             `          else control.openBy(anchor);` && |\n| &&
             `        });` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      // css is not a UI5 method either: it writes one whitelisted CSS` && |\n| &&
             `      // declaration onto the control's own DOM node, for the case where the` && |\n| &&
             `      // control has no property carrying that value (sap.m.Page has no` && |\n| &&
             `      // ``width``). Like the original jQuery-style samples do, the declaration` && |\n| &&
             `      // lives on the element and is gone after a re-render - the backend` && |\n| &&
             `      // re-sends it with the next view, exactly as it re-sends every property.` && |\n| &&
             `      if (method === "css") {` && |\n| &&
             `        const prop = String(args[4] ?? "").toLowerCase();` && |\n| &&
             `        if (!CSS_PROPERTIES.includes(prop)) {` && |\n| &&
             `          Lib.logError(` && |\n| &&
             `            ``CONTROL_BY_ID: css property '${args[4]}' not allowed (allowed: ${CSS_PROPERTIES.join(", ")})``,` && |\n| &&
             `          );` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        const el = control?.getDomRef?.();` && |\n| &&
             `        if (!el) {` && |\n| &&
             `          Lib.logError(``CONTROL_BY_ID: 'css' - control '${id}' has no DOM ref``);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        el.style.setProperty(prop, String(args[5] ?? ""));` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      // setAsyncURLHandler takes a FUNCTION, so the argument names a policy` && |\n| &&
             `      // (see URL_POLICIES) and the client installs the matching built-in` && |\n| &&
             `      // validator - the wire still carries data, never code.` && |\n| &&
             `      if (method === "setAsyncURLHandler") {` && |\n| &&
             `        const policy = String(args[4] ?? "").toUpperCase();` && |\n| &&
             `        const isAllowed = URL_POLICIES[policy];` && |\n| &&
             `        if (!isAllowed) {` && |\n| &&
             `          Lib.logError(` && |\n| &&
             `            ``CONTROL_BY_ID: unknown URL policy '${args[4]}' (allowed: ${Object.keys(URL_POLICIES).join(", ")})``,` && |\n| &&
             `          );` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        if (!control || typeof control.setAsyncURLHandler !== "function") {` && |\n| &&
             `          Lib.logError(` && |\n| &&
             `            ``CONTROL_BY_ID: 'setAsyncURLHandler' not callable on control '${id}'``,` && |\n| &&
             `          );` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        control.setAsyncURLHandler((config) => {` && |\n| &&
             `          // the control hands over { url, id, promise }; the promise's` && |\n| &&
             `          // resolve() decides whether the link stays clickable` && |\n| &&
             `          config?.promise?.resolve({` && |\n| &&
             `            allowed: isAllowed(config.url),` && |\n| &&
             `            id: config.id,` && |\n| &&
             `          });` && |\n| &&
             `        });` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      // openBy is handled BEFORE the generic callable check: a control` && |\n| &&
             `      // without an own openBy (sap.ui.unified.Menu) still supports the` && |\n| &&
             `      // anchored open via its open(bWithKeyboard, opener, my, at, of)` && |\n| &&
             `      // signature - the anchor doubles as opener and dock reference.` && |\n| &&
             `      if (method === "openBy") {` && |\n| &&
             `        if (` && |\n| &&
             `          !control ||` && |\n| &&
             `          (typeof control.openBy !== "function" &&` && |\n| &&
             `            typeof control.open !== "function")` && |\n| &&
             `        ) {` && |\n| &&
             `          Lib.logError(` && |\n| &&
             `            ``CONTROL_BY_ID: 'openBy' not callable on control '${id}'``,` && |\n| &&
             `          );` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        const anchor = castArgs(kinds, args.slice(4), view)[0];` && |\n| &&
             `        // Same reason as toggleBy: wait for the anchor to render.` && |\n| &&
             `        whenAnchorRendered(anchor, oController, () => {` && |\n| &&
             `          if (typeof control.openBy === "function") control.openBy(anchor);` && |\n| &&
             `          else control.open(false, anchor, "begin top", "begin bottom", anchor);` && |\n| &&
             `        });` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      if (!control || typeof control[method] !== "function") {` && |\n| &&
             `        Lib.logError(` && |\n| &&
             `          ``CONTROL_BY_ID: '${method}' not callable on control '${id}'``,` && |\n| &&
             `        );` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      control[method](...castArgs(kinds, args.slice(4), view));` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // args: [_, object, method, ...params]` && |\n| &&
             `    function evControlCall(oController, args) {` && |\n| &&
             `      const [, name, method] = args;` && |\n| &&
             `      const target = GLOBAL_TARGETS[name];` && |\n| &&
             `      const kinds = target?.methods[method];` && |\n| &&
             `      if (!kinds) {` && |\n| &&
             `        Lib.logError(``CONTROL_GLOBAL: '${name}.${method}' not allowed``);` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      const obj = target.get();` && |\n| &&
             `      if (` && |\n| &&
             `        !obj ||` && |\n| &&
             `        (!target.virtualMethods && typeof obj[method] !== "function")` && |\n| &&
             `      ) {` && |\n| &&
             `        Lib.logError(``CONTROL_GLOBAL: '${name}.${method}' not available``);` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      let raw = args.slice(3);` && |\n| &&
             `      // A ``display`` target additionally takes an OPTIONS OBJECT as its last` && |\n| &&
             `      // argument (the full set client->message_toast_display( ) sends). It` && |\n| &&
             `      // needs no marker to be told apart from the template values below: the` && |\n| &&
             `      // backend embeds a JSON object argument as real JSON` && |\n| &&
             `      // (get_event_client_json), so it arrives here already parsed, while` && |\n| &&
             `      // every positional and template value is a string.` && |\n| &&
             `      let mOptions;` && |\n| &&
             `      if (target.display) {` && |\n| &&
             `        const last = raw[raw.length - 1];` && |\n| &&
             `        if (last && typeof last === "object") {` && |\n| &&
             `          mOptions = last;` && |\n| &&
             `          raw = raw.slice(0, -1);` && |\n| &&
             `        }` && |\n| &&
             `      }` && |\n| &&
             `      // a single-string method (MessageToast.show, MessageBox.*) may receive` && |\n| &&
             `      // extra positional values: the first arg is then a template and its` && |\n| &&
             `      // {0},{1},... placeholders are replaced by the client-resolved extras, so` && |\n| &&
             `      // a "X has been activated" toast can be composed on the frontend without a` && |\n| &&
             `      // server round-trip. A lone string is passed through unchanged.` && |\n| &&
             `      if (kinds.length === 1 && kinds[0] === "string" && raw.length > 1) {` && |\n| &&
             `        raw = [formatTemplate(String(raw[0]), raw.slice(1))];` && |\n| &&
             `      }` && |\n| &&
             `      if (target.display) {` && |\n| &&
             `        return target.display(oController, method, raw, mOptions || {});` && |\n| &&
             `      }` && |\n| &&
             `      obj[method](...castArgs(kinds, raw));` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // replace placeholders in a template with the positional values (as` && |\n| &&
             `    // strings). Two forms:` && |\n| &&
             `    //   {N}                -> the Nth value verbatim` && |\n| &&
             `    //   {N?trueText:falseText} -> trueText when the Nth value is truthy, else` && |\n| &&
             `    //                         falseText (a boolean event param arrives as` && |\n| &&
             `    //                         "true"/"false", so a toggle can toast` && |\n| &&
             `    //                         "Pressed"/"Unpressed" without a server round-trip;` && |\n| &&
             `    //                         trueText/falseText carry no ":" or "}")` && |\n| &&
             `    // an out-of-range placeholder is left as-is.` && |\n| &&
             `    function formatTemplate(tpl, values) {` && |\n| &&
             `      return tpl.replace(` && |\n| &&
             `        /\{(\d+)(?:\?([^:}]*):([^}]*))?\}/g,` && |\n| &&
             `        (m, i, tText, fText) => {` && |\n| &&
             `          const n = Number(i);` && |\n| &&
             `          if (n >= values.length) return m;` && |\n| &&
             `          const v = String(values[n]);` && |\n| &&
             `          if (tText === undefined) return v;` && |\n| &&
             `          const truthy = v !== "" && !/^(false|0|undefined|null)$/i.test(v);` && |\n| &&
             `          return truthy ? tText : fText;` && |\n| &&
             `        },` && |\n| &&
             `      );` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // BINDING_CALL: apply a declarative filter/sorter to an aggregation` && |\n| &&
             `    // binding of a control resolved by id - the client-side equivalent of` && |\n| &&
             `    // the classic demo kit controller pattern` && |\n| &&
             `    // oList.getBinding("items").filter([new Filter(...)]). Same safety` && |\n| &&
             `    // boundary as CONTROL_BY_ID: only whitelisted binding methods,` && |\n| &&
             `    // only whitelisted filter operators, everything built from data` && |\n| &&
             `    // (path/operator/values), never from code strings.` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    const FILTER_OPERATORS = new Set([` && |\n| &&
             `      "BT",` && |\n| &&
             `      "Contains",` && |\n| &&
             `      "EndsWith",` && |\n| &&
             `      "EQ",` && |\n| &&
             `      "GE",` && |\n| &&
             `      "GT",` && |\n| &&
             `      "LE",` && |\n| &&
             `      "LT",` && |\n| &&
             `      "NB",` && |\n| &&
             `      "NE",` && |\n| &&
             `      "NotContains",` && |\n| &&
             `      "NotEndsWith",` && |\n| &&
             `      "NotStartsWith",` && |\n| &&
             `      "StartsWith",` && |\n| &&
             `    ]);` && |\n| &&
             `` && |\n| &&
             `    const isEmpty = (v) => v == null || v === "";` && |\n| &&
             `` && |\n| &&
             `    // binding method -> builder that turns the trailing params into the` && |\n| &&
             `    // aggregation-update call. A strict whitelist (unlike CONTROL_METHODS,` && |\n| &&
             `    // which now allows any non-denied public control method): an unlisted` && |\n| &&
             `    // binding method fails closed at the lookup.` && |\n| &&
             `    //   filter: params = [path, operator, value1, value2?]` && |\n| &&
             `    //   sort:   params = [path, descending?, group?] (ABAP bools "X"/"")` && |\n| &&
             `    // The backend arg serializer keeps empty args between filled ones as ''` && |\n| &&
             `    // placeholders but trims trailing empties, so all optionals sit at the` && |\n| &&
             `    // end and may arrive as undefined.` && |\n| &&
             `    // Compound form of the filter payload: ONE param carrying a JSON array` && |\n| &&
             `    // of groups, each group an array of [path, operator, value1, value2?]` && |\n| &&
             `    // rows - OR inside a group, AND across groups (the FacetFilter /` && |\n| &&
             `    // ViewSettingsDialog multi-facet shape). Data only: paths, whitelisted` && |\n| &&
             `    // operators and values - never code. An empty groups array clears.` && |\n| &&
             `    function buildFilterGroups(binding, json) {` && |\n| &&
             `      let groups;` && |\n| &&
             `      try {` && |\n| &&
             `        groups = JSON.parse(json);` && |\n| &&
             `      } catch {` && |\n| &&
             `        Lib.logError("BINDING_CALL: malformed filter groups JSON");` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      if (!Array.isArray(groups)) {` && |\n| &&
             `        Lib.logError("BINDING_CALL: filter groups must be an array");` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      groups = groups.filter((g) => Array.isArray(g) && g.length);` && |\n| &&
             `      if (!groups.length) {` && |\n| &&
             `        binding.filter([]);` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      const outer = [];` && |\n| &&
             `      for (const group of groups) {` && |\n| &&
             `        const inner = [];` && |\n| &&
             `        for (const row of group) {` && |\n| &&
             `          const [path, operator, value1, value2] = Array.isArray(row)` && |\n| &&
             `            ? row` && |\n| &&
             `            : [];` && |\n| &&
             `          if (typeof path !== "string" || !FILTER_OPERATORS.has(operator)) {` && |\n| &&
             `            Lib.logError(` && |\n| &&
             `              ``BINDING_CALL: bad filter row (path '${path}' / operator '${operator}')``,` && |\n| &&
             `            );` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          inner.push(` && |\n| &&
             `            new Filter(path, FilterOperator[operator], value1, value2),` && |\n| &&
             `          );` && |\n| &&
             `        }` && |\n| &&
             `        outer.push(new Filter(inner, false)); // OR inside the group` && |\n| &&
             `      }` && |\n| &&
             `      binding.filter([new Filter(outer, true)]); // AND across the groups` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    const BINDING_METHODS = {` && |\n| &&
             `      filter(binding, params) {` && |\n| &&
             `        const [path, operator, value1, value2] = params;` && |\n| &&
             `        // A single param that starts with '[' is the compound groups JSON -` && |\n| &&
             `        // a model path can never start with '[', so the sniff is` && |\n| &&
             `        // unambiguous and the positional single-filter form stays as-is.` && |\n| &&
             `        if (` && |\n| &&
             `          params.length === 1 &&` && |\n| &&
             `          typeof path === "string" &&` && |\n| &&
             `          path.trimStart().startsWith("[")` && |\n| &&
             `        ) {` && |\n| &&
             `          buildFilterGroups(binding, path);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        // No filter values at all -> clear the filter (the demo kit search` && |\n| &&
             `        // pattern: an emptied search field). A one-sided range (empty` && |\n| &&
             `        // value1 but a set value2, e.g. BT with only an upper bound) is a` && |\n| &&
             `        // real filter, so only clear when BOTH values are empty.` && |\n| &&
             `        if (isEmpty(value1) && isEmpty(value2)) {` && |\n| &&
             `          binding.filter([]);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        if (!FILTER_OPERATORS.has(operator)) {` && |\n| &&
             `          Lib.logError(``BINDING_CALL: operator '${operator}' not allowed``);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        binding.filter([` && |\n| &&
             `          new Filter(path, FilterOperator[operator], value1, value2),` && |\n| &&
             `        ]);` && |\n| &&
             `      },` && |\n| &&
             `      sort(binding, [path, descending, group]) {` && |\n| &&
             `        binding.sort([` && |\n| &&
             `          new Sorter(path, castArg("bool", descending), castArg("bool", group)),` && |\n|.
    result = result &&
             `        ]);` && |\n| &&
             `      },` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    // args: [_, id, aggregation, method, ...params]` && |\n| &&
             `    function evBindingCall(oController, args) {` && |\n| &&
             `      const [, id, aggregation, method] = args;` && |\n| &&
             `      const build = BINDING_METHODS[method];` && |\n| &&
             `      if (!build) {` && |\n| &&
             `        Lib.logError(``BINDING_CALL: method '${method}' not allowed``);` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      const binding = ViewSlots.resolveById(id)?.getBinding?.(aggregation);` && |\n| &&
             `      if (!binding || typeof binding[method] !== "function") {` && |\n| &&
             `        Lib.logError(` && |\n| &&
             `          ``BINDING_CALL: no '${aggregation}' binding with '${method}' on control '${id}'``,` && |\n| &&
             `        );` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      build(binding, args.slice(4));` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Individual event handlers - one per entry in the dispatch table at` && |\n| &&
             `    // the bottom. Uniform signature (oController, args) so the dispatch` && |\n| &&
             `    // stays trivial; handlers that don't need the controller ignore it.` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    function evHistoryBack() {` && |\n| &&
             `      history.back();` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evNavToRoute(oController, args) {` && |\n| &&
             `      // Navigate to another app by setting the hash route - the UI5 navTo` && |\n| &&
             `      // equivalent. args[1] is the target app class (or a full "app/<CLASS>"` && |\n| &&
             `      // route). The push adds a browser history entry, so Back returns to the` && |\n| &&
             `      // current app; the router's hashChanged handler then starts the target` && |\n| &&
             `      // app. No-op unless the app enabled routing.` && |\n| &&
             `      const raw = Lib.toText(args[1]);` && |\n| &&
             `      if (!raw) return;` && |\n| &&
             `      Router.navToApp(raw);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evClipboardCopy(oController, args) {` && |\n| &&
             `      Lib.copyToClipboard(args[1]);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evClipboardAppState() {` && |\n| &&
             `      // Guard against a missing response so the copied link never carries` && |\n| &&
             `      // the literal "undefined" as its state id.` && |\n| &&
             `      const id = AppState.state.oResponse?.ID || "";` && |\n| &&
             `      // Router.hrefFor drops the current app hash (e.g. an active app-state)` && |\n| &&
             `      // so the link carries only the fresh state id, but KEEPS the FLP shell` && |\n| &&
             `      // hash - without it the recipient lands on the launchpad home page` && |\n| &&
             `      // instead of this app.` && |\n| &&
             `      Lib.copyToClipboard(Router.hrefFor(``/z2ui5-xapp-state=${id}``));` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evDownloadB64File(oController, args) {` && |\n| &&
             `      if (!Lib.isSafeDownloadURL(args[1])) {` && |\n| &&
             `        Lib.logError("DOWNLOAD_B64_FILE: blocked unsafe URL");` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      // A data: URL carrying active HTML combined with an attacker-chosen` && |\n| &&
             `      // .html/.hta filename is a known drive-by vector; block executable data:` && |\n| &&
             `      // MIME types outright (real downloads are octet-stream, images, pdf, ...).` && |\n| &&
             `      if (` && |\n| &&
             `        /^data:(text\/html|application\/xhtml|text\/xml|image\/svg)/i.test(` && |\n| &&
             `          args[1],` && |\n| &&
             `        )` && |\n| &&
             `      ) {` && |\n| &&
             `        Lib.logError("DOWNLOAD_B64_FILE: blocked active data: MIME type");` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      const a = document.createElement("a");` && |\n| &&
             `      a.href = args[1];` && |\n| &&
             `      // Fall back to an empty download attribute when the backend omits the` && |\n| &&
             `      // filename, so the anchor never carries the literal "undefined". Strip` && |\n| &&
             `      // path separators and control characters so the filename cannot escape` && |\n| &&
             `      // the download directory or carry a misleading name.` && |\n| &&
             `      // eslint-disable-next-line no-control-regex -- control chars are matched on purpose here` && |\n| &&
             `      a.download = String(args[2] || "").replace(/[\\/:*?"<>|\x00-\x1f]/g, "_");` && |\n| &&
             `      // Firefox only triggers a programmatic download click when the anchor` && |\n| &&
             `      // is part of the document, so attach it briefly and remove it again.` && |\n| &&
             `      document.body.appendChild(a);` && |\n| &&
             `      a.click();` && |\n| &&
             `      document.body.removeChild(a);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evCrossAppNavToPrevApp() {` && |\n| &&
             `      withCrossAppNavigator((nav) => nav.backToPreviousApp());` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evSetSizeLimit(oController, args) {` && |\n| &&
             `      // Two call shapes:` && |\n| &&
             `      //   ["SET_SIZE_LIMIT", "<limit>", "<viewKey>"]   -> set the limit` && |\n| &&
             `      //   ["SET_SIZE_LIMIT", "<viewKey>"]              -> reset the limit` && |\n| &&
             `      const hasLimit = args[2] !== undefined && args[2] !== "";` && |\n| &&
             `      const viewKey = hasLimit ? args[2] : args[1];` && |\n| &&
             `      const limit = hasLimit ? Number(args[1]) : NaN;` && |\n| &&
             `` && |\n| &&
             `      const isValidLimit = Number.isFinite(limit) && limit > 0;` && |\n| &&
             `      if (isValidLimit) {` && |\n| &&
             `        AppState.state.viewSizeLimits[viewKey] = limit;` && |\n| &&
             `      } else {` && |\n| &&
             `        delete AppState.state.viewSizeLimits[viewKey];` && |\n| &&
             `      }` && |\n| &&
             `` && |\n| &&
             `      // MAIN and the two nested views share one root model via propagation, so` && |\n| &&
             `      // resolve the model through MAIN for those slots and apply the effective` && |\n| &&
             `      // (largest) limit across them; popup/popover keep their own model/limit.` && |\n| &&
             `      const modelKey = Lib.isRootModelSlot(viewKey) ? "MAIN" : viewKey;` && |\n| &&
             `      const model = ViewSlots.getView(modelKey)?.getModel();` && |\n| &&
             `      if (model) {` && |\n| &&
             `        const effective = Lib.effectiveSizeLimit(` && |\n| &&
             `          AppState.state.viewSizeLimits,` && |\n| &&
             `          viewKey,` && |\n| &&
             `        );` && |\n| &&
             `        // 100 is the UI5 JSONModel default size limit.` && |\n| &&
             `        model.setSizeLimit(effective ?? 100);` && |\n| &&
             `        model.refresh(true);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evSetODataModel(oController, args) {` && |\n| &&
             `      let oModel;` && |\n| &&
             `      try {` && |\n| &&
             `        oModel = new ODataModel({` && |\n| &&
             `          serviceUrl: args[1],` && |\n| &&
             `          annotationURI: args[3] || "",` && |\n| &&
             `        });` && |\n| &&
             `        const oView = ViewSlots.getView("MAIN");` && |\n| &&
             `        if (oView) {` && |\n| &&
             `          oView.setModel(oModel, args[2] || undefined);` && |\n| &&
             `        } else {` && |\n| &&
             `          // No view to attach to - release the model instead of leaking it.` && |\n| &&
             `          oModel.destroy();` && |\n| &&
             `        }` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError(``SET_ODATA_MODEL: failed for '${args[1]}'``, e);` && |\n| &&
             `        // setModel (or the model construction) threw after the model opened` && |\n| &&
             `        // its metadata request - release it so it does not leak.` && |\n| &&
             `        oModel?.destroy?.();` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evStoreData(oController, args) {` && |\n| &&
             `      // Guard against a missing payload so the try below logs a` && |\n| &&
             `      // STORE_DATA-specific error instead of a generic dispatch failure.` && |\n| &&
             `      const { TYPE, PREFIX, VALUE, KEY } = args[1] ?? {};` && |\n| &&
             `      try {` && |\n| &&
             `        const storageType = Storage.Type[TYPE] || Storage.Type.session;` && |\n| &&
             `        const oStorage = new Storage(storageType, PREFIX);` && |\n| &&
             `        if (VALUE === "" || VALUE == null) {` && |\n| &&
             `          oStorage.remove(KEY);` && |\n| &&
             `        } else {` && |\n| &&
             `          oStorage.put(KEY, VALUE);` && |\n| &&
             `        }` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError(` && |\n| &&
             `          ``STORE_DATA: storage operation failed for key '${KEY}'``,` && |\n| &&
             `          e,` && |\n| &&
             `        );` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evCrossAppNavToExt(oController, args) {` && |\n| &&
             `      withCrossAppNavigator((nav) => {` && |\n| &&
             `        const hash =` && |\n| &&
             `          nav.hrefForExternal({ target: args[1], params: args[2] }) || "";` && |\n| &&
             `        if (args[3] === "EXT") {` && |\n| &&
             `          // External redirect: replace the location while keeping the host.` && |\n| &&
             `          // base is the current page (same origin) + a shell-hash fragment,` && |\n| &&
             `          // so this is same-origin by construction; validate anyway to stay` && |\n| &&
             `          // consistent with every other redirect handler in this file.` && |\n| &&
             `          const base = window.location.href.split("#")[0];` && |\n| &&
             `          const url = ``${base}${hash}``;` && |\n| &&
             `          if (!Lib.isValidRedirectURL(url)) {` && |\n| &&
             `            Lib.logError(``CrossAppNav EXT: unsafe redirect URL '${url}'``);` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          _URLHelper.redirect(url, true);` && |\n| &&
             `        } else {` && |\n| &&
             `          nav.toExternal({ target: { shellHash: hash } });` && |\n| &&
             `        }` && |\n| &&
             `      });` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evLocationReload(oController, args) {` && |\n| &&
             `      if (Lib.isValidRedirectURL(args[1])) {` && |\n| &&
             `        window.location.href = args[1];` && |\n| &&
             `      } else {` && |\n| &&
             `        MessageBox.error(` && |\n| &&
             `          "Invalid redirect URL. Only relative URLs to the same domain are allowed.",` && |\n| &&
             `        );` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // SYSTEM_LOGOUT: prefer the launchpad logout when running inside the` && |\n| &&
             `    // FLP; otherwise terminate a possible stateful BSP session first and` && |\n| &&
             `    // then navigate to the logout URL.` && |\n| &&
             `    function evSystemLogout(oController, args) {` && |\n| &&
             `      const logoutUrl = args[1] || "/sap/public/bc/icf/logoff";` && |\n| &&
             `      try {` && |\n| &&
             `        const container = AppState.state.oLaunchpad?.Container;` && |\n| &&
             `        // No explicit logout URL was passed (args is just the event name):` && |\n| &&
             `        // inside the launchpad, prefer its own logout over the BSP/ICF` && |\n| &&
             `        // redirect below.` && |\n| &&
             `        if (container?.logout && args.length <= 1) {` && |\n| &&
             `          container.logout();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("SYSTEM_LOGOUT: ushell logout failed", e);` && |\n| &&
             `      }` && |\n| &&
             `      logoutViaBspTerminate(logoutUrl);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // When abap2UI5 is hosted as a BSP application,` && |\n| &&
             `    // /sap/public/bc/icf/logoff alone does not terminate the stateful` && |\n| &&
             `    // BSP context (sap-contextid stays bound to /sap/bc/bsp/sap/<app>/).` && |\n| &&
             `    // Hit the BSP path with ?sap-sessioncmd=logoff first so the BSP` && |\n| &&
             `    // runtime calls server->session->terminate( ), then go to the ICF` && |\n| &&
             `    // logoff to also drop the SSO2 ticket. Outside a BSP path this goes` && |\n| &&
             `    // straight to the logout URL.` && |\n| &&
             `    function logoutViaBspTerminate(logoutUrl) {` && |\n| &&
             `      const path = window.location.pathname;` && |\n| &&
             `      if (!path.startsWith("/sap/bc/bsp/")) {` && |\n| &&
             `        redirectToLogout(logoutUrl);` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `` && |\n| &&
             `      // location.pathname never contains a query string, so "?" always starts` && |\n| &&
             `      // the sap-sessioncmd parameter` && |\n| &&
             `      const bspKill = ``${path}?sap-sessioncmd=logoff``;` && |\n| &&
             `      let done = false;` && |\n| &&
             `      let frame;` && |\n| &&
             `      const finish = () => {` && |\n| &&
             `        if (done) return;` && |\n| &&
             `        done = true;` && |\n| &&
             `        // Remove the hidden BSP-kill iframe. On a successful logout the page` && |\n| &&
             `        // navigates away and unload cleans up anyway; but if redirectToLogout` && |\n| &&
             `        // blocks an invalid URL (MessageBox, no navigation) the iframe would` && |\n| &&
             `        // otherwise leak - and accumulate over repeated logout attempts.` && |\n| &&
             `        if (frame) {` && |\n| &&
             `          try {` && |\n| &&
             `            frame.remove();` && |\n| &&
             `          } catch {` && |\n| &&
             `            /* already detached */` && |\n| &&
             `          }` && |\n| &&
             `          frame = null;` && |\n| &&
             `        }` && |\n| &&
             `        redirectToLogout(logoutUrl);` && |\n| &&
             `      };` && |\n| &&
             `      try {` && |\n| &&
             `        frame = document.createElement("iframe");` && |\n| &&
             `        frame.style.display = "none";` && |\n| &&
             `        frame.src = bspKill;` && |\n| &&
             `        frame.addEventListener("load", finish);` && |\n| &&
             `        document.body.appendChild(frame);` && |\n| &&
             `      } catch {` && |\n| &&
             `        finish();` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      // Safety net: never wait longer than 1.5s for the BSP terminate.` && |\n| &&
             `      setTimeout(finish, 1500);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function redirectToLogout(logoutUrl) {` && |\n| &&
             `      if (Lib.isValidRedirectURL(logoutUrl)) {` && |\n| &&
             `        window.location.href = logoutUrl;` && |\n| &&
             `      } else {` && |\n| &&
             `        MessageBox.error(` && |\n| &&
             `          "Invalid logout URL. Only relative URLs to the same domain are allowed.",` && |\n| &&
             `        );` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evOpenNewTab(oController, args) {` && |\n| &&
             `      if (!Lib.isValidRedirectURL(args[1])) {` && |\n| &&
             `        MessageBox.error(` && |\n| &&
             `          "Invalid URL. Only relative URLs to the same domain are allowed.",` && |\n| &&
             `        );` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      const newWindow = window.open(args[1], "_blank");` && |\n| &&
             `      // Clear opener to prevent the new tab from accessing window.opener.` && |\n| &&
             `      if (newWindow) newWindow.opener = null;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // BIND_ELEMENT: element-bind a whole view slot (popup / popover / main) to` && |\n| &&
             `    // a row of a registered table, so the fragment's relative bindings ({Name},` && |\n| &&
             `    // {ProductPicUrl}, ...) resolve against that row - the abap2UI5 equivalent of` && |\n| &&
             `    // oControl.bindElement(oCtx.getPath()). args = [slot, index, path]; the path` && |\n| &&
             `    // comes from client->_bind( table ) (braces already stripped server-side and` && |\n| &&
             `    // again here defensively), the slot from the follow_up_action view param.` && |\n| &&
             `    function evBindElement(oController, args) {` && |\n| &&
             `      const slot = args[1] || "MAIN";` && |\n| &&
             `      const view = ViewSlots.getView(slot);` && |\n| &&
             `      if (!view) {` && |\n| &&
             `        Lib.logError(``BIND_ELEMENT: no view for slot '${slot}'``);` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      const path = String(args[3] ?? "").replace(/[{}]/g, "");` && |\n| &&
             `      if (!path) {` && |\n| &&
             `        Lib.logError("BIND_ELEMENT: empty binding path");` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      view.bindElement(``${path}/${args[2]}``);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // The anchor. setPersControler() is sap.ui.comp's own setter and does` && |\n| &&
             `    // more than assign the field: it also creates the control promise that` && |\n| &&
             `    // initialise() insists on. A page variant never gets that call -` && |\n| &&
             `    // addPersonalizableControl() returns early for isPageVariant() and only` && |\n| &&
             `    // the single-control case reaches setPersControler() - which is exactly` && |\n| &&
             `    // why a controller-less app ends up with no anchor and no promise.` && |\n| &&
             `    function anchorPersoControl(oSVM, target) {` && |\n| &&
             `      if (oSVM._oPersoControl) {` && |\n| &&
             `        // a runtime that anchors the control itself is left alone` && |\n| &&
             `      } else if (typeof oSVM.setPersControler === "function") {` && |\n| &&
             `        oSVM.setPersControler(target);` && |\n| &&
             `      } else {` && |\n| &&
             `        // older runtimes without the setter: the field alone still carries` && |\n| &&
             `        // the write path (saving), which is better than nothing` && |\n| &&
             `        oSVM._oPersoControl = target;` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // With the anchor in place the load flow still has to be started once.` && |\n| &&
             `    // A smart control does that itself when it registers - but only then,` && |\n| &&
             `    // and it may already have tried (and aborted) before the anchor existed.` && |\n| &&
             `    // So wait for the control's wrapper and initialise it if nobody has:` && |\n| &&
             `    // a wrapper is required (initialise answers "unknown control" without` && |\n| &&
             `    // one) and an initialised wrapper must be left alone ("already executed").` && |\n| &&
             `    function ensureInitialised(oSVM, target, attempt, fnCallback) {` && |\n| &&
             `      if (Lib.isDestroyed(oSVM)) return;` && |\n| &&
             `      const wrapper = oSVM._getControlWrapper` && |\n| &&
             `        ? oSVM._getControlWrapper(target)` && |\n| &&
             `        : null;` && |\n| &&
             `      if (!wrapper) {` && |\n| &&
             `        if (attempt < SMART_VARIANT_INIT_TRIES) {` && |\n| &&
             `          setTimeout(` && |\n| &&
             `            () => ensureInitialised(oSVM, target, attempt + 1, fnCallback),` && |\n| &&
             `            SMART_VARIANT_INIT_DELAY,` && |\n| &&
             `          );` && |\n| &&
             `        }` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      if (wrapper.bInitialized) return;` && |\n| &&
             `      oSVM.initialise(fnCallback || (() => {}), target);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // SMART_VARIANT_INIT: place the anchor sap.ui.comp variant management needs` && |\n| &&
             `    // and that only an app controller would otherwise set - the personalizable` && |\n| &&
             `    // control the SmartVariantManagement works against (_oPersoControl).` && |\n| &&
             `    // args = [_, svmId, controlId?].` && |\n| &&
             `    //` && |\n| &&
             `    // Why an anchor and not a call: SmartVariantManagement.initialise(fn, control)` && |\n| &&
             `    // aborts its load flow when ``_oPersoControl`` is missing ("no personalizable` && |\n| &&
             `    // component available") and marks that control's wrapper as done - a second` && |\n| &&
             `    // call answers "already executed". The smart controls call initialise on` && |\n| &&
             `    // themselves as soon as their metadata arrives, so an anchor set too late` && |\n| &&
             `    // buys nothing: saving works (it only reads the field) but stored variants` && |\n| &&
             `    // are never loaded. Hence: set the field as EARLY as the control exists, and` && |\n| &&
             `    // leave the initialise call to the smart control, which then finds the` && |\n| &&
             `    // anchor in place. Only when no control id was given does this wait for the` && |\n| &&
             `    // registration list and call initialise itself (nobody else will).` && |\n| &&
             `    function evSmartVariantInit(oController, args) {` && |\n| &&
             `      const [, svmId, controlId] = args;` && |\n| &&
             `      let tries = 0;` && |\n| &&
             `      const run = () => {` && |\n| &&
             `        const oSVM = ViewSlots.resolveById(svmId);` && |\n| &&
             `        const control = controlId ? ViewSlots.resolveById(controlId) : null;` && |\n| &&
             `        if (!oSVM || (controlId && !control)) {` && |\n| &&
             `          // the view may still be building - wait for both controls to exist` && |\n| &&
             `          if (tries++ < SMART_VARIANT_INIT_TRIES) {` && |\n| &&
             `            setTimeout(run, SMART_VARIANT_INIT_DELAY);` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          Lib.logError(` && |\n| &&
             `            ``SMART_VARIANT_INIT: '${controlId ? ``${svmId}' / '${controlId}`` : svmId}' not found``,` && |\n| &&
             `          );` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        if (Lib.isDestroyed(oSVM) || typeof oSVM.initialise !== "function") {` && |\n| &&
             `          Lib.logError(` && |\n| &&
             `            ``SMART_VARIANT_INIT: no SmartVariantManagement for id '${svmId}'``,` && |\n| &&
             `          );` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        let target = control;` && |\n| &&
             `        if (!target) {` && |\n| &&
             `          // no control named: fall back to the first one that registered, which` && |\n| &&
             `          // means waiting for that registration (it follows the metadata load)` && |\n| &&
             `          const registered = oSVM.getPersonalizableControls` && |\n| &&
             `            ? oSVM.getPersonalizableControls()` && |\n| &&
             `            : [];` && |\n| &&
             `          if (!registered.length) {` && |\n| &&
             `            if (tries++ < SMART_VARIANT_INIT_TRIES) {` && |\n|.
    result = result &&
             `              setTimeout(run, SMART_VARIANT_INIT_DELAY);` && |\n| &&
             `              return;` && |\n| &&
             `            }` && |\n| &&
             `            Lib.logError(` && |\n| &&
             `              ``SMART_VARIANT_INIT: no personalizable control registered at '${svmId}'``,` && |\n| &&
             `            );` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          target = ViewSlots.resolveById(registered[0].getControl());` && |\n| &&
             `          if (!target) return;` && |\n| &&
             `        }` && |\n| &&
             `        anchorPersoControl(oSVM, target);` && |\n| &&
             `        ensureInitialised(oSVM, target, 0);` && |\n| &&
             `      };` && |\n| &&
             `` && |\n| &&
             `      run();` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // FILTER_BAR_VARIANT_INIT: wire a CLASSIC sap.ui.comp.filterbar.FilterBar` && |\n| &&
             `    // to a SmartVariantManagement. args = [_, svmId, filterBarId].` && |\n| &&
             `    //` && |\n| &&
             `    // A SmartFilterBar registers itself at the variant management (it knows its` && |\n| &&
             `    // fields from the OData metadata), so SMART_VARIANT_INIT above only has to` && |\n| &&
             `    // place the anchor. A classic FilterBar knows nothing about variants: every` && |\n| &&
             `    // list-report controller hand-writes the same three callbacks` && |\n| &&
             `    // (registerFetchData / registerApplyData / registerGetFiltersWithValues),` && |\n| &&
             `    // adds a PersonalizableInfo and marks the variant dirty on each filter` && |\n| &&
             `    // change. That is boilerplate over the bar's own filter items - data, not` && |\n| &&
             `    // app logic - so the framework owns it and the app needs no JavaScript.` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    // marker so a re-sent action cannot stack a second set of callbacks and` && |\n| &&
             `    // change handlers on the same bar (a rebuilt view reuses the ids, but it` && |\n| &&
             `    // builds NEW control instances, which arrive here unmarked)` && |\n| &&
             `    const FILTER_BAR_WIRED = "_z2ui5FilterBarVariantWired";` && |\n| &&
             `` && |\n| &&
             `    function filterItemControl(item) {` && |\n| &&
             `      return item && typeof item.getControl === "function"` && |\n| &&
             `        ? item.getControl()` && |\n| &&
             `        : null;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function filterItemValue(item) {` && |\n| &&
             `      const control = filterItemControl(item);` && |\n| &&
             `      return control && typeof control.getValue === "function"` && |\n| &&
             `        ? control.getValue()` && |\n| &&
             `        : "";` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // what a variant stores, how it is put back, and which filters count as` && |\n| &&
             `    // "assigned" for the bar's own summary text` && |\n| &&
             `    function registerFilterBarCallbacks(oFilterBar) {` && |\n| &&
             `      oFilterBar.registerFetchData(() =>` && |\n| &&
             `        oFilterBar.getAllFilterItems().map((item) => ({` && |\n| &&
             `          groupName: item.getGroupName(),` && |\n| &&
             `          fieldName: item.getName(),` && |\n| &&
             `          fieldData: filterItemValue(item),` && |\n| &&
             `        })),` && |\n| &&
             `      );` && |\n| &&
             `      oFilterBar.registerApplyData((data) => {` && |\n| &&
             `        (data || []).forEach((entry) => {` && |\n| &&
             `          const control = oFilterBar.determineControlByName(` && |\n| &&
             `            entry.fieldName,` && |\n| &&
             `            entry.groupName,` && |\n| &&
             `          );` && |\n| &&
             `          // setValue, not a model write: the two-way binding abap2UI5 put on` && |\n| &&
             `          // the property carries the restored value back to the backend on the` && |\n| &&
             `          // next roundtrip, so selecting a variant needs none of its own` && |\n| &&
             `          if (control && typeof control.setValue === "function") {` && |\n| &&
             `            control.setValue(entry.fieldData);` && |\n| &&
             `          }` && |\n| &&
             `        });` && |\n| &&
             `      });` && |\n| &&
             `      oFilterBar.registerGetFiltersWithValues(() =>` && |\n| &&
             `        oFilterBar` && |\n| &&
             `          .getFilterGroupItems()` && |\n| &&
             `          .filter((item) => String(filterItemValue(item)).length > 0),` && |\n| &&
             `      );` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // every filter change makes the current variant dirty (the "*" next to the` && |\n| &&
             `    // variant title) and refreshes the bar's assigned-filters summary` && |\n| &&
             `    function attachFilterBarChange(oSVM, oFilterBar) {` && |\n| &&
             `      oFilterBar.getAllFilterItems().forEach((item) => {` && |\n| &&
             `        const control = filterItemControl(item);` && |\n| &&
             `        if (!control || typeof control.attachChange !== "function") return;` && |\n| &&
             `        control.attachChange((oEvent) => {` && |\n| &&
             `          if (typeof oSVM.currentVariantSetModified === "function") {` && |\n| &&
             `            oSVM.currentVariantSetModified(true);` && |\n| &&
             `          }` && |\n| &&
             `          if (typeof oFilterBar.fireFilterChange === "function") {` && |\n| &&
             `            oFilterBar.fireFilterChange(oEvent);` && |\n| &&
             `          }` && |\n| &&
             `        });` && |\n| &&
             `      });` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // sap.ui.comp is SAPUI5-only, so PersonalizableInfo must never be a hard` && |\n| &&
             `    // dependency of this file (it 404s on OpenUI5 and would kill the component` && |\n| &&
             `    // load). Resolve it at call time: synchronously when the SmartVariant-` && |\n| &&
             `    // Management already pulled it in, asynchronously otherwise.` && |\n| &&
             `    function withPersonalizableInfo(callback) {` && |\n| &&
             `      const name = "sap/ui/comp/smartvariants/PersonalizableInfo";` && |\n| &&
             `      /* ui5lint-disable no-globals --` && |\n| &&
             `       the guard has to read the global sap.ui itself: the point of this` && |\n| &&
             `       function is to load a module that must NOT be a declared dependency` && |\n| &&
             `       (sap.ui.comp is SAPUI5-only and 404s on OpenUI5), so sap.ui.require is` && |\n| &&
             `       the only entry point and there is no injected equivalent to probe. */` && |\n| &&
             `      if (` && |\n| &&
             `        typeof sap === "undefined" ||` && |\n| &&
             `        !sap.ui ||` && |\n| &&
             `        typeof sap.ui.require !== "function"` && |\n| &&
             `      ) {` && |\n| &&
             `        Lib.logError("FILTER_BAR_VARIANT_INIT: sap.ui.require not available");` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      const loaded = sap.ui.require(name);` && |\n| &&
             `      if (loaded) {` && |\n| &&
             `        callback(loaded);` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      sap.ui.require([name], callback, () =>` && |\n| &&
             `        Lib.logError(` && |\n| &&
             `          "FILTER_BAR_VARIANT_INIT: sap.ui.comp.smartvariants not available",` && |\n| &&
             `        ),` && |\n| &&
             `      );` && |\n| &&
             `      /* ui5lint-enable no-globals */` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evFilterBarVariantInit(oController, args) {` && |\n| &&
             `      const [, svmId, filterBarId] = args;` && |\n| &&
             `      let tries = 0;` && |\n| &&
             `      const run = () => {` && |\n| &&
             `        const oSVM = ViewSlots.resolveById(svmId);` && |\n| &&
             `        const oFilterBar = ViewSlots.resolveById(filterBarId);` && |\n| &&
             `        if (!oSVM || !oFilterBar) {` && |\n| &&
             `          // the view may still be building - wait for both controls to exist` && |\n| &&
             `          if (tries++ < SMART_VARIANT_INIT_TRIES) {` && |\n| &&
             `            setTimeout(run, SMART_VARIANT_INIT_DELAY);` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          Lib.logError(` && |\n| &&
             `            ``FILTER_BAR_VARIANT_INIT: '${svmId}' / '${filterBarId}' not found``,` && |\n| &&
             `          );` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        if (` && |\n| &&
             `          Lib.isDestroyed(oSVM) ||` && |\n| &&
             `          typeof oSVM.addPersonalizableControl !== "function"` && |\n| &&
             `        ) {` && |\n| &&
             `          Lib.logError(` && |\n| &&
             `            ``FILTER_BAR_VARIANT_INIT: no SmartVariantManagement for id '${svmId}'``,` && |\n| &&
             `          );` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        if (typeof oFilterBar.registerFetchData !== "function") {` && |\n| &&
             `          Lib.logError(` && |\n| &&
             `            ``FILTER_BAR_VARIANT_INIT: no FilterBar for id '${filterBarId}'``,` && |\n| &&
             `          );` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        if (oFilterBar[FILTER_BAR_WIRED]) return;` && |\n| &&
             `        oFilterBar[FILTER_BAR_WIRED] = true;` && |\n| &&
             `` && |\n| &&
             `        registerFilterBarCallbacks(oFilterBar);` && |\n| &&
             `        attachFilterBarChange(oSVM, oFilterBar);` && |\n| &&
             `        withPersonalizableInfo((PersonalizableInfo) => {` && |\n| &&
             `          oSVM.addPersonalizableControl(` && |\n| &&
             `            new PersonalizableInfo({` && |\n| &&
             `              type: "filterBar",` && |\n| &&
             `              keyName: "persistencyKey",` && |\n| &&
             `              dataSource: "",` && |\n| &&
             `              control: oFilterBar,` && |\n| &&
             `            }),` && |\n| &&
             `          );` && |\n| &&
             `          anchorPersoControl(oSVM, oFilterBar);` && |\n| &&
             `          // the load flow ends in registerApplyData, so the bar is clean again` && |\n| &&
             `          // right after it - drop the "*" the restored values would leave` && |\n| &&
             `          ensureInitialised(oSVM, oFilterBar, 0, () => {` && |\n| &&
             `            if (typeof oSVM.currentVariantSetModified === "function") {` && |\n| &&
             `              oSVM.currentVariantSetModified(false);` && |\n| &&
             `            }` && |\n| &&
             `          });` && |\n| &&
             `        });` && |\n| &&
             `      };` && |\n| &&
             `` && |\n| &&
             `      run();` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evUrlHelper(oController, args) {` && |\n| &&
             `      const params = args[2] ?? {};` && |\n| &&
             `      // mailto:/sms:/tel: targets are handed to URLHelper as-is; a CR/LF in a` && |\n| &&
             `      // recipient/subject can inject extra headers in some mail clients.` && |\n| &&
             `      // Reject CR/LF in the string params up front.` && |\n| &&
             `      const hasCrLf = (v) => typeof v === "string" && /[\r\n]/.test(v);` && |\n| &&
             `      if (Object.values(params).some(hasCrLf)) {` && |\n| &&
             `        Lib.logError("URLHELPER: blocked CR/LF in parameters");` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      const actions = {` && |\n| &&
             `        REDIRECT: () => {` && |\n| &&
             `          if (!Lib.isSafeRedirectProtocol(params.URL)) {` && |\n| &&
             `            MessageBox.error(` && |\n| &&
             `              "Invalid redirect URL. Only http/https protocols are allowed.",` && |\n| &&
             `            );` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          _URLHelper.redirect(params.URL, params.NEW_WINDOW);` && |\n| &&
             `        },` && |\n| &&
             `        TRIGGER_EMAIL: () =>` && |\n| &&
             `          _URLHelper.triggerEmail(` && |\n| &&
             `            params.EMAIL,` && |\n| &&
             `            params.SUBJECT,` && |\n| &&
             `            params.BODY,` && |\n| &&
             `            params.CC,` && |\n| &&
             `            params.BCC,` && |\n| &&
             `            params.NEW_WINDOW,` && |\n| &&
             `          ),` && |\n| &&
             `        TRIGGER_SMS: () =>` && |\n| &&
             `          _URLHelper.triggerSms(params.TEL, params.TEXT, params.NEW_WINDOW),` && |\n| &&
             `        TRIGGER_TEL: () => _URLHelper.triggerTel(params.TEL),` && |\n| &&
             `      };` && |\n| &&
             `      try {` && |\n| &&
             `        const fn = actions[args[1]];` && |\n| &&
             `        if (fn) fn();` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError(``URLHELPER: '${args[1]}' failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evImageEditorPopupClose(oController) {` && |\n| &&
             `      let image;` && |\n| &&
             `      try {` && |\n| &&
             `        const editor = ViewSlots.byId("POPUP", "imageEditor");` && |\n| &&
             `        if (editor) image = editor.getImagePngDataURL();` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("IMAGE_EDITOR_POPUP_CLOSE: getImagePngDataURL failed", e);` && |\n| &&
             `      }` && |\n| &&
             `      ViewSlots.destroy("POPUP");` && |\n| &&
             `      oController.eB(["SAVE"], image);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evStartTimer(oController, args) {` && |\n| &&
             `      // Intentionally a single timer slot: args[0] is always the event` && |\n| &&
             `      // name "START_TIMER", so a new START_TIMER replaces the previous` && |\n| &&
             `      // one. At most one backend timer is pending at any time - this is` && |\n| &&
             `      // by design, not a bug.` && |\n| &&
             `      const timerKey = args[0];` && |\n| &&
             `      const callbackEvent = args[1];` && |\n| &&
             `      const delay = Number(args[2]) || 0;` && |\n| &&
             `      const timers = AppState.state.timers;` && |\n| &&
             `      clearTimeout(timers[timerKey]);` && |\n| &&
             `      timers[timerKey] = setTimeout(() => {` && |\n| &&
             `        delete timers[timerKey];` && |\n| &&
             `        // dispatch as a background event (args[2] = ignore busy) - a timer` && |\n| &&
             `        // firing while an ordinary roundtrip is in flight must not be` && |\n| &&
             `        // swallowed by the busy guard, or a self-rescheduling poll chain` && |\n| &&
             `        // dies on the first collision with a user click` && |\n| &&
             `        oController.eB([callbackEvent, false, true]);` && |\n| &&
             `      }, delay);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // KEYBOARD_SHORTCUT: bind a key combination to a NAMED BACKEND EVENT -` && |\n| &&
             `    // the declarative equivalent of a sap.ui.core.CommandExecution shortcut` && |\n| &&
             `    // (which needs a controller method and therefore has no place in a` && |\n| &&
             `    // controller-less app). The backend registers "combo -> event" pairs as` && |\n| &&
             `    // data; the document listener below is installed once and always reads` && |\n| &&
             `    // the CURRENT registry, so an app switch (which resets AppState) starts` && |\n| &&
             `    // from an empty set without touching the listener.` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    // in the order they are emitted into a normalized combo, so registration` && |\n| &&
             `    // and keydown produce the same string for any spelling` && |\n| &&
             `    const SHORTCUT_MODIFIERS = ["ctrl", "shift", "alt", "meta"];` && |\n| &&
             `` && |\n| &&
             `    // spellings apps/UI5 use for the same modifier or key` && |\n| &&
             `    const SHORTCUT_ALIASES = {` && |\n| &&
             `      control: "ctrl",` && |\n| &&
             `      cmd: "meta",` && |\n| &&
             `      command: "meta",` && |\n| &&
             `      option: "alt",` && |\n| &&
             `      esc: "escape",` && |\n| &&
             `      del: "delete",` && |\n| &&
             `      ins: "insert",` && |\n| &&
             `      return: "enter",` && |\n| &&
             `      space: " ",` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    function shortcutToken(part) {` && |\n| &&
             `      const t = part.trim().toLowerCase();` && |\n| &&
             `      return SHORTCUT_ALIASES[t] ?? t;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // "Ctrl+Shift+S" / "shift + CTRL + s" -> "ctrl+shift+s". Returns an empty` && |\n| &&
             `    // string when no actual key (only modifiers) is named.` && |\n| &&
             `    function normalizeShortcut(combo) {` && |\n| &&
             `      const parts = String(combo ?? "")` && |\n| &&
             `        .split("+")` && |\n| &&
             `        .map(shortcutToken)` && |\n| &&
             `        .filter((p) => p !== "");` && |\n| &&
             `      const mods = SHORTCUT_MODIFIERS.filter((m) => parts.includes(m));` && |\n| &&
             `      const keys = parts.filter((p) => !SHORTCUT_MODIFIERS.includes(p));` && |\n| &&
             `      if (keys.length === 0) return "";` && |\n| &&
             `      return [...mods, keys[keys.length - 1]].join("+");` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // the same normalized form for an actual keydown event` && |\n| &&
             `    function shortcutFromEvent(oEvent) {` && |\n| &&
             `      const key = String(oEvent.key ?? "").toLowerCase();` && |\n| &&
             `      // a bare modifier press is not a shortcut` && |\n| &&
             `      if (key === "" || SHORTCUT_MODIFIERS.includes(shortcutToken(key)))` && |\n| &&
             `        return "";` && |\n| &&
             `      const mods = [];` && |\n| &&
             `      if (oEvent.ctrlKey) mods.push("ctrl");` && |\n| &&
             `      if (oEvent.shiftKey) mods.push("shift");` && |\n| &&
             `      if (oEvent.altKey) mods.push("alt");` && |\n| &&
             `      if (oEvent.metaKey) mods.push("meta");` && |\n| &&
             `      return [...mods, key].join("+");` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // A shortcut may be SCOPED, which is how UI5's own CommandExecution` && |\n| &&
             `    // behaves: one in a Popover's dependents shadows the page-level one for` && |\n| &&
             `    // the same command while that popover is open. A scope is either` && |\n| &&
             `    //` && |\n| &&
             `    //   a VIEW SLOT   - POPOVER/POPUP/NEST2/NEST/MAIN, open when the framework` && |\n| &&
             `    //                   has that slot showing (popover_display, popup_display,` && |\n| &&
             `    //                   a nested view)` && |\n| &&
             `    //   a CONTROL ID  - any control DECLARED IN THE VIEW that can be open or` && |\n| &&
             `    //                   closed: a sap.m.Popover/Dialog in ``dependents`` opened` && |\n| &&
             `    //                   with control_by_id openBy, which is the shape the demo` && |\n| &&
             `    //                   kit's Commands sample actually uses. It never enters a` && |\n| &&
             `    //                   framework slot, so the slot form alone would never fire.` && |\n| &&
             `    //` && |\n| &&
             `    // Dispatch prefers a CONTROL scope (the more specific statement) over a` && |\n| &&
             `    // slot scope, then takes the innermost open slot, then the unscoped entry.` && |\n| &&
             `    const SHORTCUT_SLOTS = ["POPOVER", "POPUP", "NEST2", "NEST", "MAIN"];` && |\n| &&
             `    const SHORTCUT_GLOBAL = ""; // the unscoped registration` && |\n| &&
             `` && |\n| &&
             `    // A control scope counts while the control is OPEN - isOpen() for the` && |\n| &&
             `    // popup-like controls this is for, visibility otherwise.` && |\n| &&
             `    function scopeControlOpen(id) {` && |\n| &&
             `      const c = ViewSlots.resolveById(id);` && |\n| &&
             `      if (!c) return false;` && |\n| &&
             `      if (typeof c.isOpen === "function") return !!c.isOpen();` && |\n| &&
             `      return typeof c.getVisible === "function"` && |\n| &&
             `        ? c.getVisible() !== false` && |\n| &&
             `        : true;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function shortcutEntry(combo) {` && |\n| &&
             `      const scopes = AppState.state.shortcuts[combo];` && |\n| &&
             `      if (!scopes) return undefined;` && |\n| &&
             `      for (const key of Object.keys(scopes)) {` && |\n| &&
             `        if (key === SHORTCUT_GLOBAL || SHORTCUT_SLOTS.includes(key)) continue;` && |\n| &&
             `        if (scopeControlOpen(key)) return scopes[key];` && |\n| &&
             `      }` && |\n| &&
             `      for (const key of SHORTCUT_SLOTS) {` && |\n| &&
             `        if (scopes[key] && ViewSlots.getView(key)) return scopes[key];` && |\n| &&
             `      }` && |\n| &&
             `      return scopes[SHORTCUT_GLOBAL];` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    let shortcutListener = null;` && |\n| &&
             `` && |\n| &&
             `    function installShortcutListener() {` && |\n| &&
             `      if (shortcutListener || typeof document === "undefined") return;` && |\n| &&
             `      shortcutListener = (oEvent) => {` && |\n| &&
             `        try {` && |\n| &&
             `          const entry = shortcutEntry(shortcutFromEvent(oEvent));` && |\n| &&
             `          if (!entry) return;` && |\n| &&
             `          // the browser's own default for the combo (Ctrl+S saves the page,` && |\n| &&
             `          // Ctrl+D bookmarks it) must not fire alongside the app command` && |\n| &&
             `          oEvent.preventDefault();` && |\n| &&
             `          entry.controller.eB([entry.event]);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("KEYBOARD_SHORTCUT: dispatch failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      };` && |\n| &&
             `      document.addEventListener("keydown", shortcutListener);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // args: [_, combo, eventName, scope] - an empty event name unregisters the` && |\n| &&
             `    // combo IN THAT SCOPE; scope is a view slot key (cs_view-popover/popup/...)` && |\n| &&
             `    // and defaults to the unscoped, always-eligible registration` && |\n| &&
             `    function evKeyboardShortcut(oController, args) {` && |\n| &&
             `      const combo = normalizeShortcut(args[1]);` && |\n| &&
             `      if (!combo) {` && |\n| &&
             `        Lib.logError(` && |\n| &&
             `          ``KEYBOARD_SHORTCUT: '${args[1]}' names no key to bind (modifiers only?)``,` && |\n| &&
             `        );` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      // a slot key is matched case-insensitively; anything else is taken as a` && |\n| &&
             `      // control id and keeps its case, because that is how it must resolve` && |\n| &&
             `      const raw = String(args[3] ?? "");` && |\n| &&
             `      const scope = SHORTCUT_SLOTS.includes(raw.toUpperCase())` && |\n| &&
             `        ? raw.toUpperCase()` && |\n| &&
             `        : raw;` && |\n|.
    result = result &&
             `      const shortcuts = AppState.state.shortcuts;` && |\n| &&
             `      const scopes = shortcuts[combo] ?? (shortcuts[combo] = {});` && |\n| &&
             `      if (!args[2]) {` && |\n| &&
             `        delete scopes[scope];` && |\n| &&
             `        // a combo with no registration left must not keep an empty entry:` && |\n| &&
             `        // shortcutEntry would still find it and fall through to undefined,` && |\n| &&
             `        // but preventDefault has already been decided by then` && |\n| &&
             `        if (Object.keys(scopes).length === 0) delete shortcuts[combo];` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      // re-registering a combo in the same scope replaces it, so the backend` && |\n| &&
             `      // can rebind a shortcut without unregistering it first` && |\n| &&
             `      scopes[scope] = { event: args[2], controller: oController };` && |\n| &&
             `      installShortcutListener();` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evSetInputMode(oController, args) {` && |\n| &&
             `      try {` && |\n| &&
             `        const oElement = ViewSlots.byId("MAIN", args[1]);` && |\n| &&
             `        if (!oElement) return;` && |\n| &&
             `        const dom = oElement.getDomRef();` && |\n| &&
             `        if (!dom) return;` && |\n| &&
             `        const input = dom.matches("input, textarea")` && |\n| &&
             `          ? dom` && |\n| &&
             `          : dom.querySelector("input, textarea");` && |\n| &&
             `        if (!input) return;` && |\n| &&
             `        input.setAttribute("inputmode", args[2] || "text");` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError(` && |\n| &&
             `          ``KEYBOARD_SET_MODE: setAttribute failed for '${args[1]}'``,` && |\n| &&
             `          e,` && |\n| &&
             `        );` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // The three handlers below resolve their target with ViewSlots.resolveById` && |\n| &&
             `    // (not byId "MAIN"): it searches every open slot first, so controls in a` && |\n| &&
             `    // popup/popover/nested view are found, and falls back to the global` && |\n| &&
             `    // registry, so a fully-qualified id resolves too - ids that come from a` && |\n| &&
             `    // UI5 Message (getControlIds()) or any event carry the view prefix.` && |\n| &&
             `` && |\n| &&
             `    function evSetFocus(oController, args) {` && |\n| &&
             `      const oElement = ViewSlots.resolveById(args[1]);` && |\n| &&
             `      if (!oElement) return;` && |\n| &&
             `` && |\n| &&
             `      const applyFocus = () => {` && |\n| &&
             `        try {` && |\n| &&
             `          const info = oElement.getFocusInfo();` && |\n| &&
             `          if (args[2] != null && args[2] !== "") {` && |\n| &&
             `            info.selectionStart = Number(args[2]);` && |\n| &&
             `          }` && |\n| &&
             `          if (args[3] != null && args[3] !== "") {` && |\n| &&
             `            info.selectionEnd = Number(args[3]);` && |\n| &&
             `          }` && |\n| &&
             `          oElement.applyFocusInfo(info);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError(``SET_FOCUS: failed for '${args[1]}'``, e);` && |\n| &&
             `        }` && |\n| &&
             `      };` && |\n| &&
             `` && |\n| &&
             `      // The control may still be missing from the DOM when SET_FOCUS runs` && |\n| &&
             `      // together with a fresh view build. Apply now if it is rendered,` && |\n| &&
             `      // otherwise once it is.` && |\n| &&
             `      Lib.whenRendered(oElement, oController, () => {` && |\n| &&
             `        applyFocus();` && |\n| &&
             `        const dom = oElement.getDomRef();` && |\n| &&
             `        if (dom && dom.contains(document.activeElement)) return;` && |\n| &&
             `        // The focus did not stick. A view_model_update in the same response` && |\n| &&
             `        // may have changed the control - e.g. re-enabled a locked input via` && |\n| &&
             `        // its ``enabled`` binding: the control already reports the new state,` && |\n| &&
             `        // but the DOM still carries the OLD rendering until UI5's async` && |\n| &&
             `        // re-render, and the browser silently ignores focus() on a disabled` && |\n| &&
             `        // element. Re-apply once after the pending re-render has replaced` && |\n| &&
             `        // the DOM.` && |\n| &&
             `        const prevActive = document.activeElement;` && |\n| &&
             `        // "Same place" by node OR by element id: when the re-render also` && |\n| &&
             `        // rebuilt the element that held the focus (the pressed button in the` && |\n| &&
             `        // same form), the focus sits on a NEW node of the SAME control` && |\n| &&
             `        // afterwards - that still counts as "the user did not move it".` && |\n| &&
             `        const samePlace = (el) =>` && |\n| &&
             `          el == null ||` && |\n| &&
             `          el === document.body ||` && |\n| &&
             `          el === prevActive ||` && |\n| &&
             `          Boolean(el.id && prevActive && el.id === prevActive.id);` && |\n| &&
             `        const delegate = {` && |\n| &&
             `          onAfterRendering: () => {` && |\n| &&
             `            oElement.removeEventDelegate(delegate);` && |\n| &&
             `            // Defer past the rendering task: when the re-render replaced the` && |\n| &&
             `            // focused element, UI5's FocusHandler restores its focus AFTER` && |\n| &&
             `            // all onAfterRendering delegates ran - focusing here would be` && |\n| &&
             `            // overridden right away.` && |\n| &&
             `            setTimeout(() => {` && |\n| &&
             `              if (Lib.isDestroyed(oController)) return;` && |\n| &&
             `              // Only when the focus was not actively moved elsewhere in` && |\n| &&
             `              // between - a re-render at some arbitrary later point must` && |\n| &&
             `              // never steal the user's focus.` && |\n| &&
             `              if (!samePlace(document.activeElement)) return;` && |\n| &&
             `              applyFocus();` && |\n| &&
             `            }, 0);` && |\n| &&
             `          },` && |\n| &&
             `        };` && |\n| &&
             `        oElement.addEventDelegate(delegate);` && |\n| &&
             `      });` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evScrollTo(oController, args) {` && |\n| &&
             `      // args[1] = control id` && |\n| &&
             `      // args[2] = scrollTop  (Y, vertical, px)` && |\n| &&
             `      // args[3] = scrollLeft (X, horizontal, px) - optional, default 0` && |\n| &&
             `      // args[4] = behavior - "auto" (default) | "smooth" | "instant"` && |\n| &&
             `      // Strategy: prefer the control's scroll delegate (sap.m.Page,` && |\n| &&
             `      // ScrollContainer etc. expose ScrollEnablement). The delegate knows` && |\n| &&
             `      // the real scroll container, which often is NOT the control's root` && |\n| &&
             `      // DOM element - so native Element.scrollTo on getDomRef() silently` && |\n| &&
             `      // does nothing on a Page. ScrollEnablement.scrollTo(x, y, time)` && |\n| &&
             `      // animates when time > 0, so "smooth" maps to a 300ms animation.` && |\n| &&
             `      // Native Element.scrollTo is only used as a fallback for controls` && |\n| &&
             `      // without a delegate.` && |\n| &&
             `      try {` && |\n| &&
             `        const oElement = ViewSlots.resolveById(args[1]);` && |\n| &&
             `        if (!oElement) return;` && |\n| &&
             `        const y = Number(args[2]) || 0;` && |\n| &&
             `        const x = Number(args[3]) || 0;` && |\n| &&
             `        const behavior = args[4] || "auto";` && |\n| &&
             `        const smooth = behavior === "smooth";` && |\n| &&
             `` && |\n| &&
             `        let handled = false;` && |\n| &&
             `        try {` && |\n| &&
             `          const delegate = oElement.getScrollDelegate?.();` && |\n| &&
             `          if (delegate?.scrollTo) {` && |\n| &&
             `            // ScrollEnablement / iScroll delegate: scrollTo(x, y, time)` && |\n| &&
             `            delegate.scrollTo(x, y, smooth ? SMOOTH_SCROLL_MS : 0);` && |\n| &&
             `            handled = true;` && |\n| &&
             `          }` && |\n| &&
             `        } catch {` && |\n| &&
             `          // fall through` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        if (!handled) {` && |\n| &&
             `          const dom =` && |\n| &&
             `            document.getElementById(``${oElement.getId()}-inner``) ||` && |\n| &&
             `            oElement.getDomRef();` && |\n| &&
             `          if (dom?.scrollTo) {` && |\n| &&
             `            dom.scrollTo({ top: y, left: x, behavior });` && |\n| &&
             `          } else if (dom) {` && |\n| &&
             `            dom.scrollTop = y;` && |\n| &&
             `            dom.scrollLeft = x;` && |\n| &&
             `          } else if (oElement.scrollTo) {` && |\n| &&
             `            // sap.m.Page.scrollTo(y, time) - vertical only` && |\n| &&
             `            oElement.scrollTo(y, smooth ? SMOOTH_SCROLL_MS : 0);` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError(``SCROLL_TO: failed for '${args[1]}'``, e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evScrollIntoView(oController, args) {` && |\n| &&
             `      // args[1] = control id` && |\n| &&
             `      // args[2] = behavior - "smooth" (default) | "auto" | "instant"` && |\n| &&
             `      // args[3] = block    - "start"  (default) | "center" | "end" | "nearest"` && |\n| &&
             `      // args[4] = inline   - "nearest" (default)| "start"  | "center" | "end"` && |\n| &&
             `      // Modern declarative scroll: bring a control into the viewport,` && |\n| &&
             `      // regardless of where the surrounding scroll container currently is.` && |\n| &&
             `      try {` && |\n| &&
             `        const oElement = ViewSlots.resolveById(args[1]);` && |\n| &&
             `        if (!oElement) return;` && |\n| &&
             `        const dom = oElement.getDomRef();` && |\n| &&
             `        if (!dom || !dom.scrollIntoView) return;` && |\n| &&
             `        dom.scrollIntoView({` && |\n| &&
             `          behavior: args[2] || "smooth",` && |\n| &&
             `          block: args[3] || "start",` && |\n| &&
             `          inline: args[4] || "nearest",` && |\n| &&
             `        });` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError(``SCROLL_INTO_VIEW: failed for '${args[1]}'``, e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evSetTitle(oController, args) {` && |\n| &&
             `      const title = Lib.toText(args[1]);` && |\n| &&
             `      try {` && |\n| &&
             `        document.title = title;` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("SET_TITLE: setting document.title failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evSetFavicon(oController, args) {` && |\n| &&
             `      const href = Lib.toText(args[1]);` && |\n| &&
             `      try {` && |\n| &&
             `        // Reuse the icon link the page already has instead of appending a` && |\n| &&
             `        // second one - which of two competing <link rel="icon"> elements the` && |\n| &&
             `        // browser honours is up to it, and an app that switches its icon` && |\n| &&
             `        // would otherwise leave one behind per change. ``~=`` matches one entry` && |\n| &&
             `        // of the whitespace-separated rel list, so a page declaring the` && |\n| &&
             `        // legacy rel="shortcut icon" is found too.` && |\n| &&
             `        const existing = document.head.querySelector('link[rel~="icon"]');` && |\n| &&
             `        if (existing) {` && |\n| &&
             `          existing.href = href;` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        const link = document.createElement("link");` && |\n| &&
             `        link.rel = "icon";` && |\n| &&
             `        link.href = href;` && |\n| &&
             `        document.head.appendChild(link);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("SET_FAVICON: setting the favicon failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evSetTitleLaunchpad(oController, args) {` && |\n| &&
             `      const title = Lib.toText(args[1]);` && |\n| &&
             `      try {` && |\n| &&
             `        const shell = AppState.state.oLaunchpad?.ShellUIService;` && |\n| &&
             `        if (shell?.setTitle) {` && |\n| &&
             `          const result = shell.setTitle(title);` && |\n| &&
             `          if (result?.catch) {` && |\n| &&
             `            result.catch((e) =>` && |\n| &&
             `              Lib.logError(` && |\n| &&
             `                "SET_TITLE_LAUNCHPAD: ShellUIService.setTitle failed",` && |\n| &&
             `                e,` && |\n| &&
             `              ),` && |\n| &&
             `            );` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("SET_TITLE_LAUNCHPAD: ShellUIService.setTitle failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evZ2ui5Custom(oController, args) {` && |\n| &&
             `      try {` && |\n| &&
             `        // Custom functions are registered by apps on the public z2ui5` && |\n| &&
             `        // global (js_loader popup), so resolve them via the facade.` && |\n| &&
             `        const fn = AppState.getGlobal(args[1]);` && |\n| &&
             `        if (typeof fn === "function") {` && |\n| &&
             `          fn(args.slice(2));` && |\n| &&
             `        } else {` && |\n| &&
             `          // Missing or not callable (e.g. the app never registered it via` && |\n| &&
             `          // the js_loader popup) - log it instead of failing silently or` && |\n| &&
             `          // with a generic TypeError.` && |\n| &&
             `          Lib.logError(``Z2UI5: 'z2ui5.${args[1]}' is not a function``);` && |\n| &&
             `        }` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError(``Z2UI5: '${args[1]}' failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evWizardSetNextStep(oController, args) {` && |\n| &&
             `      try {` && |\n| &&
             `        const wiz = ViewSlots.byId("MAIN", args[1]);` && |\n| &&
             `        const step = ViewSlots.byId("MAIN", args[2]);` && |\n| &&
             `        const nextStep = ViewSlots.byId("MAIN", args[3]);` && |\n| &&
             `        if (wiz && step) wiz.discardProgress(step);` && |\n| &&
             `        if (step && nextStep) step.setNextStep(nextStep);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError(``WIZARD_SET_NEXT_STEP: failed for wizard '${args[1]}'``, e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evPlayAudio(oController, args) {` && |\n| &&
             `      // Only http(s)/data:/blob: sources are meaningful for Audio; validating` && |\n| &&
             `      // the protocol keeps this consistent with the other URL-consuming` && |\n| &&
             `      // actions and blocks odd schemes early.` && |\n| &&
             `      if (!Lib.isSafeDownloadURL(args[1])) {` && |\n| &&
             `        Lib.logError("PLAY_AUDIO: blocked unsafe audio URL");` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      try {` && |\n| &&
             `        const playing = new Audio(args[1]).play();` && |\n| &&
             `        // play() returns a Promise; a rejection (e.g. blocked by the` && |\n| &&
             `        // browser's autoplay policy) is not caught by the surrounding` && |\n| &&
             `        // try/catch and would surface as an unhandled rejection.` && |\n| &&
             `        if (playing?.catch) {` && |\n| &&
             `          playing.catch((e) =>` && |\n| &&
             `            Lib.logError(``PLAY_AUDIO: failed for '${args[1]}'``, e),` && |\n| &&
             `          );` && |\n| &&
             `        }` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError(``PLAY_AUDIO: failed for '${args[1]}'``, e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Frontend event dispatch: maps the eF event name to its handler.` && |\n| &&
             `    const handlers = {` && |\n| &&
             `      SET_SIZE_LIMIT: evSetSizeLimit,` && |\n| &&
             `      HISTORY_BACK: evHistoryBack,` && |\n| &&
             `      NAV_TO_ROUTE: evNavToRoute,` && |\n| &&
             `      CLIPBOARD_COPY: evClipboardCopy,` && |\n| &&
             `      CLIPBOARD_APP_STATE: evClipboardAppState,` && |\n| &&
             `      SET_ODATA_MODEL: evSetODataModel,` && |\n| &&
             `      STORE_DATA: evStoreData,` && |\n| &&
             `      DOWNLOAD_B64_FILE: evDownloadB64File,` && |\n| &&
             `      CROSS_APP_NAV_TO_PREV_APP: evCrossAppNavToPrevApp,` && |\n| &&
             `      CROSS_APP_NAV_TO_EXT: evCrossAppNavToExt,` && |\n| &&
             `      LOCATION_RELOAD: evLocationReload,` && |\n| &&
             `      SYSTEM_LOGOUT: evSystemLogout,` && |\n| &&
             `      OPEN_NEW_TAB: evOpenNewTab,` && |\n| &&
             `      BIND_ELEMENT: evBindElement,` && |\n| &&
             `      URLHELPER: evUrlHelper,` && |\n| &&
             `      IMAGE_EDITOR_POPUP_CLOSE: evImageEditorPopupClose,` && |\n| &&
             `      SET_TITLE: evSetTitle,` && |\n| &&
             `      SET_FAVICON: evSetFavicon,` && |\n| &&
             `      SET_TITLE_LAUNCHPAD: evSetTitleLaunchpad,` && |\n| &&
             `      SET_FOCUS: evSetFocus,` && |\n| &&
             `      SCROLL_TO: evScrollTo,` && |\n| &&
             `      SCROLL_INTO_VIEW: evScrollIntoView,` && |\n| &&
             `      START_TIMER: evStartTimer,` && |\n| &&
             `      KEYBOARD_SET_MODE: evSetInputMode,` && |\n| &&
             `      KEYBOARD_SHORTCUT: evKeyboardShortcut,` && |\n| &&
             `      Z2UI5: evZ2ui5Custom,` && |\n| &&
             `      WIZARD_SET_NEXT_STEP: evWizardSetNextStep,` && |\n| &&
             `      PLAY_AUDIO: evPlayAudio,` && |\n| &&
             `      SMART_VARIANT_INIT: evSmartVariantInit,` && |\n| &&
             `      FILTER_BAR_VARIANT_INIT: evFilterBarVariantInit,` && |\n| &&
             `      CONTROL_BY_ID: evControlCallById,` && |\n| &&
             `      CONTROL_GLOBAL: evControlCall,` && |\n| &&
             `      BINDING_CALL: evBindingCall,` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    // Entry point called by View1.controller's eF().` && |\n| &&
             `    function execute(oController, args) {` && |\n| &&
             `      // runCallbacks isolates each hook in its own try/catch, so a throwing` && |\n| &&
             `      // before-event hook cannot escape here.` && |\n| &&
             `      Lib.runCallbacks(AppState.state.onBeforeEventFrontend, args);` && |\n| &&
             `` && |\n| &&
             `      try {` && |\n| &&
             `        const handler = handlers[args[0]];` && |\n| &&
             `        if (handler) handler(oController, args);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        // Backstop: individual handlers already guard themselves, but a` && |\n| &&
             `        // malformed payload must never let an error escape into the caller.` && |\n| &&
             `        Lib.logError(``FrontendAction: handler '${args[0]}' failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Entry point for the SYSTEM phase. Two differences to execute( ), both` && |\n| &&
             `    // deliberate: the result is RETURNED so an async view display can be` && |\n| &&
             `    // awaited before the next action runs, and errors are NOT swallowed - a` && |\n| &&
             `    // malformed-XML load has always propagated to _processAfterRendering and` && |\n| &&
             `    // surfaced the fatal "App Terminated" overlay rather than leaving the app` && |\n| &&
             `    // half-built behind a log line.` && |\n| &&
             `    function executeSystem(oController, args) {` && |\n| &&
             `      Lib.runCallbacks(AppState.state.onBeforeEventFrontend, args);` && |\n| &&
             `      const handler = handlers[args[0]];` && |\n| &&
             `      if (!handler) {` && |\n| &&
             `        Lib.logError(``FrontendAction: unknown system action '${args[0]}'``);` && |\n| &&
             `        return undefined;` && |\n| &&
             `      }` && |\n| &&
             `      return handler(oController, args);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    return { execute, executeSystem };` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
