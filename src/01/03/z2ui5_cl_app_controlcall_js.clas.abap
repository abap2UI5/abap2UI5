* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Embedded frontend resource, generated from app/webapp/ by
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
CLASS z2ui5_cl_app_controlcall_js DEFINITION
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


CLASS z2ui5_cl_app_controlcall_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    "sap/m/MessageBox",` && |\n| &&
             `    "sap/ui/core/BusyIndicator",` && |\n| &&
             `    "sap/ui/core/Popup",` && |\n| &&
             `    "sap/ui/model/Filter",` && |\n| &&
             `    "sap/ui/model/FilterOperator",` && |\n| &&
             `    "sap/ui/model/Sorter",` && |\n| &&
             `    "z2ui5/core/Router",` && |\n| &&
             `    "z2ui5/core/Lib",` && |\n| &&
             `    "z2ui5/core/ViewSlots",` && |\n| &&
             `    "z2ui5/core/actions/Slots",` && |\n| &&
             `  ],` && |\n| &&
             `  (` && |\n| &&
             `    MessageBox,` && |\n| &&
             `    BusyIndicator,` && |\n| &&
             `    CorePopup,` && |\n| &&
             `    Filter,` && |\n| &&
             `    FilterOperator,` && |\n| &&
             `    Sorter,` && |\n| &&
             `    Router,` && |\n| &&
             `    Lib,` && |\n| &&
             `    ViewSlots,` && |\n| &&
             `    Slots,` && |\n| &&
             `  ) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // sap/m/MessageToast is required LAZILY instead of being listed as a` && |\n| &&
             `    // dependency: its module factory captures` && |\n| &&
             `    // DataType.getType("sap.ui.core.Popup.Dock") in a closure at load time,` && |\n| &&
             `    // and sibling dependencies carry no execution-order guarantee - when the` && |\n| &&
             `    // toast factory ran before Popup's, the captured type stayed broken for` && |\n| &&
             `    // the whole session and every toast logged '"center bottom" is not of` && |\n| &&
             `    // type "sap.ui.core.Popup.Dock"' (even for valid values). This require` && |\n| &&
             `    // runs while THIS factory executes, i.e. strictly after sap/ui/core/Popup` && |\n| &&
             `    // (a hard dependency above) has loaded, so the capture always works.` && |\n| &&
             `    let MessageToast;` && |\n| &&
             `    sap.ui.require(["sap/m/MessageToast"], (MT) => {` && |\n| &&
             `      MessageToast = MT;` && |\n| &&
             `    });` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // The generic, whitelisted call surface of the action protocol:` && |\n| &&
             `    // CONTROL_GLOBAL / CONTROL_BY_ID call a method on a global object or a` && |\n| &&
             `    // control resolved by id, BINDING_CALL applies a declarative` && |\n| &&
             `    // filter/sorter to an aggregation binding - each detailed at its own` && |\n| &&
             `    // section below.` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // MESSAGE_TOAST / MESSAGE_BOX display hooks (moved here from the former` && |\n| &&
             `    // core/Messages.js). The options arrive as a plain object already` && |\n| &&
             `    // carrying the UI5 option names (duration, my, actions, ...): the backend` && |\n| &&
             `    // sends only what the app actually set and normalizes everything it can` && |\n| &&
             `    // decide on its own, so there is no mapping layer and no mirrored UI5` && |\n| &&
             `    // default here. What is left are the three things only the client can do` && |\n| &&
             `    // - turn an ONCLOSE event name into a callback that round-trips through` && |\n| &&
             `    // the controller's eB(), sanitize the message box details, and resolve a` && |\n| &&
             `    // control id to the live element dependentOn needs.` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    // ``class`` is not a MessageToast option: a toast carries no id, so the` && |\n| &&
             `    // classes go onto the DOM node of the newest toast (several can be open at` && |\n| &&
             `    // once). The element may not exist right after show(), so retry once on the` && |\n| &&
             `    // next animation frame.` && |\n| &&
             `    function applyToastClass(sClass) {` && |\n| &&
             `      const classes = sClass.trim().split(/\s+/).filter(Boolean);` && |\n| &&
             `      if (!classes.length) return;` && |\n| &&
             `      const apply = () => {` && |\n| &&
             `        const toasts = document.querySelectorAll(".sapMMessageToast");` && |\n| &&
             `        const toastEl = toasts[toasts.length - 1];` && |\n| &&
             `        if (toastEl) toastEl.classList.add(...classes);` && |\n| &&
             `        return Boolean(toastEl);` && |\n| &&
             `      };` && |\n| &&
             `      if (!apply()) requestAnimationFrame(apply);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function showToast(sText, mOptions, oController) {` && |\n| &&
             `      const o = { ...(mOptions || {}) };` && |\n| &&
             `      const sClass = o.class;` && |\n| &&
             `      delete o.class;` && |\n| &&
             `      if (o.onClose) {` && |\n| &&
             `        const sEvent = o.onClose;` && |\n| &&
             `        o.onClose = () => oController.eB([sEvent]);` && |\n| &&
             `      }` && |\n| &&
             `      const doShow = (MT) => {` && |\n| &&
             `        // no option set -> a plain show(), so UI5 owns every default` && |\n| &&
             `        if (Object.keys(o).length) MT.show(sText, o);` && |\n| &&
             `        else MT.show(sText);` && |\n| &&
             `        if (sClass) applyToastClass(sClass);` && |\n| &&
             `      };` && |\n| &&
             `      if (MessageToast) doShow(MessageToast);` && |\n| &&
             `      else sap.ui.require(["sap/m/MessageToast"], doShow);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function showBox(sType, sText, mOptions, oController) {` && |\n| &&
             `      const o = { ...(mOptions || {}) };` && |\n| &&
             `      if (o.onClose) {` && |\n| &&
             `        // the pressed action must ride OUTSIDE the event array: eB treats` && |\n| &&
             `        // args[0] as the event array (name + flags) and Server.roundtrip` && |\n| &&
             `        // shifts the WHOLE array away, so anything placed inside it never` && |\n| &&
             `        // reaches T_EVENT_ARG - the action then has to be the first` && |\n| &&
             `        // positional argument, like evImageEditorPopupClose's eB(["SAVE"], image)` && |\n| &&
             `        const sEvent = o.onClose;` && |\n| &&
             `        o.onClose = (sAction) => oController.eB([sEvent], sAction);` && |\n| &&
             `      }` && |\n| &&
             `      if (o.details) o.details = Lib.sanitizeMessageDetails(o.details);` && |\n| &&
             `      if (o.dependentOn) {` && |\n| &&
             `        // dependentOn (UI5 >= 1.124) ties the message box to an element's` && |\n| &&
             `        // lifecycle - the backend sends the control id, resolved here. A` && |\n| &&
             `        // missing/unresolvable id drops the option instead of passing a` && |\n| &&
             `        // string UI5 would choke on.` && |\n| &&
             `        const oDependentOn = ViewSlots.resolveById(o.dependentOn);` && |\n| &&
             `        if (oDependentOn) o.dependentOn = oDependentOn;` && |\n| &&
             `        else delete o.dependentOn;` && |\n| &&
             `      }` && |\n| &&
             `      // The backend lowercases the type, but an app can still spell one that` && |\n| &&
             `      // is no MessageBox display method at all. Restrict the lookup to` && |\n| &&
             `      // functions (MessageBox also carries enum objects like Action and Icon)` && |\n| &&
             `      // and never drop a requested message box silently: fall back to show().` && |\n| &&
             `      let showFn = MessageBox[sType];` && |\n| &&
             `      if (typeof showFn !== "function") {` && |\n| &&
             `        Lib.logError(` && |\n| &&
             `          ``ControlCall: unknown message box type '${sType}', shown via show()``,` && |\n| &&
             `        );` && |\n| &&
             `        showFn = MessageBox.show;` && |\n| &&
             `      }` && |\n| &&
             `      // no option set -> the bare per-method call, so UI5 owns every default` && |\n| &&
             `      if (Object.keys(o).length) showFn(sText, o);` && |\n| &&
             `      else showFn(sText);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // CONTROL_GLOBAL / CONTROL_BY_ID: call a whitelisted method on a` && |\n| &&
             `    // control (by id) or a global object. The whitelist is the safety` && |\n| &&
             `    // boundary; each entry lists the kind of every positional argument so` && |\n| &&
             `    // string payloads are cast/resolved (never "call anything with` && |\n| &&
             `    // anything"). Scope: imperative methods that have no binding equivalent.` && |\n| &&
             `    // NavContainer navigation (NAV_CONTAINER_TO and the NEST/NEST2/POPUP/` && |\n| &&
             `    // POPOVER variants) is dispatched here too: the backend routes those` && |\n| &&
             `    // events through the generic CONTROL_BY_ID path (method "to", the` && |\n| &&
             `    // slot passed as the view), handled by evControlCallById below.` && |\n| &&
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
             `` && |\n| &&
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
             `` && |\n| &&
             `    const CONTROL_METHOD_DENY = new RegExp(` && |\n| &&
             `      "^(" + CONTROL_METHOD_DENY_PREFIXES.join("|") + ")",` && |\n| &&
             `    );` && |\n| &&
             `` && |\n| &&
             `    const CONTROL_METHOD_DENY_SET = new Set(CONTROL_METHOD_DENY_EXACT);` && |\n| &&
             `` && |\n| &&
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
             `      // through the local showToast/showBox instead of straight at the` && |\n| &&
             `      // global, so the option` && |\n| &&
             `      // handling client->message_toast_display( ) / message_box_display( )` && |\n| &&
             `      // relies on - an ONCLOSE event name turned into an eB() round-trip, the` && |\n| &&
             `      // details sanitizing, dependentOn, the toast style class - lives in one` && |\n| &&
             `      // place. A bare app call simply arrives without options.` && |\n| &&
             `      MESSAGE_TOAST: {` && |\n| &&
             `        get: () => MessageToast,` && |\n| &&
             `        methods: { show: ["string"] },` && |\n| &&
             `        display: (oController, method, aArgs, mOptions) =>` && |\n| &&
             `          showToast(aArgs[0], mOptions, oController),` && |\n| &&
             `      },` && |\n| &&
             `      MESSAGE_BOX: {` && |\n| &&
             `        get: () => MessageBox,` && |\n| &&
             `        // the method IS the box type - showBox itself falls back to show()` && |\n| &&
             `        // for a type this UI5 version does not carry` && |\n| &&
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
             `          showBox(method, aArgs[0], mOptions, oController),` && |\n| &&
             `      },` && |\n| &&
             `      // Not a UI5 global but the framework's own view-slot registry: the` && |\n| &&
             `      // slots (MAIN, NEST, NEST2, POPUP, POPOVER) are what a backend response` && |\n| &&
             `      // opens, fills and tears down, and every one of those calls is a` && |\n| &&
             `      // SYSTEM follow-up action. ``display`` and ``updateModel`` are not` && |\n| &&
             `      // ViewSlots methods - they live in actions/Slots, which owns the` && |\n| &&
             `      // fragment loading and the model - so the hook below routes them there.` && |\n| &&
             `      VIEW_SLOTS: {` && |\n| &&
             `        get: () => ViewSlots,` && |\n| &&
             `        // display takes TWO positional arguments, the slot and the view XML.` && |\n| &&
             `        // Declaring both also keeps it off the template path below, which` && |\n| &&
             `        // would otherwise read the XML as a placeholder value for the slot.` && |\n| &&
             `        methods: {` && |\n| &&
             `          destroy: ["string"],` && |\n| &&
             `          display: ["string", "string"],` && |\n| &&
             `          // takes no slot: which slots are open is the frontend's own` && |\n| &&
             `          // knowledge, so the action only says that the model changed` && |\n| &&
             `          updateModel: [],` && |\n| &&
             `        },` && |\n| &&
             `        display: (oController, method, aArgs, mOptions, ctx) =>` && |\n| &&
             `          Slots.action(method, aArgs[0], aArgs[1], mOptions, ctx?.seq),` && |\n| &&
             `      },` && |\n| &&
             `      // The browser history / URL. Router computes ONE outcome from the whole` && |\n| &&
             `      // options object - adopt the hash, push a route entry, replace it, or` && |\n| &&
             `      // write the app-state hash - which is why it is one call and not a` && |\n| &&
             `      // field per decision input. In the SYSTEM phase the options are only` && |\n| &&
             `      // STASHED on the response: View1 runs the one per-response sync after` && |\n| &&
             `      // the displays, whether or not a ROUTER action travelled (the common` && |\n| &&
             `      // roundtrip carries none), and injects the response's draft id there.` && |\n| &&
             `      ROUTER: {` && |\n| &&
             `        get: () => Router,` && |\n| &&
             `        methods: { sync: [] },` && |\n| &&
             `        display: (oController, method, aArgs, mOptions, ctx) => {` && |\n| &&
             `          if (ctx?.response) ctx.response._routerOptions = mOptions;` && |\n| &&
             `          else Router.sync(mOptions);` && |\n| &&
             `        },` && |\n| &&
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
             `      // sap/ui/core/Popup is a HARD dependency of this module on purpose:` && |\n| &&
             `      // loading it registers the Popup.Dock enum with the DataType registry,` && |\n| &&
             `      // which MessageToast's dock validation needs - and MessageToast itself` && |\n| &&
             `      // is required lazily (see the module top) so its factory can only run` && |\n| &&
             `      // AFTER Popup's, capturing a working Dock type. The module exists on` && |\n| &&
             `      // every supported release; only setWithinArea is @since 1.89, and the` && |\n| &&
             `      // "not available" guard below covers that.` && |\n| &&
             `      POPUP: {` && |\n| &&
             `        get: () => CorePopup,` && |\n| &&
             `        methods: { setWithinArea: ["within"] },` && |\n|.
    result = result &&
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
             `      // The two are NOT interchangeable and the difference is silent: set` && |\n| &&
             `      // REPLACES the whole registration, add ADDS one code to it. An app` && |\n| &&
             `      // that registers currencies as it loads more data and reaches for` && |\n| &&
             `      // ``set`` drops the ones it registered before - and the symptom is a` && |\n| &&
             `      // wrong digit count in a table, never an error.` && |\n| &&
             `      FORMATTING: {` && |\n| &&
             `        get: () => sap.ui.require("sap/ui/core/Formatting"),` && |\n| &&
             `        methods: {` && |\n| &&
             `          setCustomCurrencies: ["object"], // REPLACES: { CODE: { digits: n }, ... }` && |\n| &&
             `          addCustomCurrency: ["string", "object"], // ADDS one: code, { digits: n }` && |\n| &&
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
             `      }` && |\n| &&
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
             `          // JSON (get_event_client_ajson), so on that path the value arrives` && |\n| &&
             `          // already parsed; only the legacy eF( ) string form needs parsing.` && |\n| &&
             `          if (raw && typeof raw === "object") return raw;` && |\n| &&
             `          try {` && |\n| &&
             `            return JSON.parse(raw);` && |\n| &&
             `          } catch {` && |\n| &&
             `            Lib.logError(``CONTROL_CALL: malformed object argument '${raw}'``);` && |\n| &&
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
             `    // args: [_, object, method, ...params]. ``ctx`` is the action context the` && |\n| &&
             `    // dispatcher threads through (FrontendAction.executeSystem) - it carries` && |\n| &&
             `    // the request stamp the VIEW_SLOTS display hook needs.` && |\n| &&
             `    function evControlCall(oController, args, ctx) {` && |\n| &&
             `      const [, name, method] = args;` && |\n| &&
             `      const target = GLOBAL_TARGETS[name];` && |\n| &&
             `      const kinds = target?.methods[method];` && |\n| &&
             `      if (!kinds) {` && |\n| &&
             `        Lib.logError(``CONTROL_GLOBAL: '${name}.${method}' not allowed``);` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      const obj = target.get();` && |\n| &&
             `      if (!obj) {` && |\n| &&
             `        Lib.logError(``CONTROL_GLOBAL: '${name}.${method}' not available``);` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      let raw = args.slice(3);` && |\n| &&
             `      // A ``display`` target additionally takes an OPTIONS OBJECT as its last` && |\n| &&
             `      // argument (the full set client->message_toast_display( ) sends). It` && |\n| &&
             `      // needs no marker to be told apart from the template values below: the` && |\n| &&
             `      // backend embeds a JSON object argument as real JSON` && |\n| &&
             `      // (get_event_client_ajson), so it arrives here already parsed, while` && |\n| &&
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
             `      // A display hook is the executor, not obj[method] - so only the plain` && |\n| &&
             `      // path needs the "does this UI5 version carry it" probe (which is also` && |\n| &&
             `      // what let VIEW_SLOTS route methods that never exist on the target).` && |\n| &&
             `      if (target.display) {` && |\n| &&
             `        return target.display(oController, method, raw, mOptions || {}, ctx);` && |\n| &&
             `      }` && |\n| &&
             `      if (typeof obj[method] !== "function") {` && |\n| &&
             `        Lib.logError(``CONTROL_GLOBAL: '${name}.${method}' not available``);` && |\n| &&
             `        return;` && |\n| &&
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
             `    ]);` && |\n|.
    result = result &&
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
             `      // the backend embeds a '['-starting argument as real JSON, so on that` && |\n| &&
             `      // path the groups arrive already parsed; only the XML-bound eF( )` && |\n| &&
             `      // string form still needs the parse` && |\n| &&
             `      let groups = json;` && |\n| &&
             `      if (typeof json === "string") {` && |\n| &&
             `        try {` && |\n| &&
             `          groups = JSON.parse(json);` && |\n| &&
             `        } catch {` && |\n| &&
             `          Lib.logError("BINDING_CALL: malformed filter groups JSON");` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
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
             `        // unambiguous and the positional single-filter form stays as-is. It` && |\n| &&
             `        // arrives as a real array when the backend embedded it as JSON, as a` && |\n| &&
             `        // string from the XML-bound eF( ) form.` && |\n| &&
             `        if (` && |\n| &&
             `          params.length === 1 &&` && |\n| &&
             `          (Array.isArray(path) ||` && |\n| &&
             `            (typeof path === "string" && path.trimStart().startsWith("[")))` && |\n| &&
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
             `          new Sorter(path, castArg("bool", descending), castArg("bool", group)),` && |\n| &&
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
             `    // The events this module owns in the eF dispatch (see` && |\n| &&
             `    // core/FrontendAction.js, which merges the domain modules' handler maps).` && |\n| &&
             `    const handlers = {` && |\n| &&
             `      CONTROL_BY_ID: evControlCallById,` && |\n| &&
             `      CONTROL_GLOBAL: evControlCall,` && |\n| &&
             `      BINDING_CALL: evBindingCall,` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    // Every whitelisted global target is dispatchable by its own name too:` && |\n| &&
             `    // a backend-built action travels as ["VIEW_SLOTS","display",...] - the` && |\n| &&
             `    // CONTROL_GLOBAL prefix of the eF( ) form is a dispatch constant, not` && |\n| &&
             `    // information, so the wire drops it. The alias re-prepends it, so both` && |\n| &&
             `    // forms share one execution path (and the prefixed form stays accepted` && |\n| &&
             `    // for apps and skewed backends).` && |\n| &&
             `    for (const name of Object.keys(GLOBAL_TARGETS)) {` && |\n| &&
             `      handlers[name] = (oController, args, ctx) =>` && |\n| &&
             `        evControlCall(oController, ["CONTROL_GLOBAL", ...args], ctx);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    return { handlers };` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
