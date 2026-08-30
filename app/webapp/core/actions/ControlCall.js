sap.ui.define(
  [
    "sap/m/MessageBox",
    "sap/ui/core/BusyIndicator",
    "sap/ui/core/Popup",
    "sap/ui/model/Filter",
    "sap/ui/model/FilterOperator",
    "sap/ui/model/Sorter",
    "z2ui5/core/Router",
    "z2ui5/core/Lib",
    "z2ui5/core/ViewSlots",
    "z2ui5/core/actions/Slots",
  ],
  (
    MessageBox,
    BusyIndicator,
    CorePopup,
    Filter,
    FilterOperator,
    Sorter,
    Router,
    Lib,
    ViewSlots,
    Slots,
  ) => {
    "use strict";

    // sap/m/MessageToast is required LAZILY instead of being listed as a
    // dependency: its module factory captures
    // DataType.getType("sap.ui.core.Popup.Dock") in a closure at load time,
    // and sibling dependencies carry no execution-order guarantee - when the
    // toast factory ran before Popup's, the captured type stayed broken for
    // the whole session and every toast logged '"center bottom" is not of
    // type "sap.ui.core.Popup.Dock"' (even for valid values). This require
    // runs while THIS factory executes, i.e. strictly after sap/ui/core/Popup
    // (a hard dependency above) has loaded, so the capture always works.
    let MessageToast;
    sap.ui.require(["sap/m/MessageToast"], (MT) => {
      MessageToast = MT;
    });

    // ------------------------------------------------------------------
    // The generic, whitelisted call surface of the action protocol:
    // CONTROL_GLOBAL / CONTROL_BY_ID call a method on a global object or a
    // control resolved by id, BINDING_CALL applies a declarative
    // filter/sorter to an aggregation binding - each detailed at its own
    // section below.
    // ------------------------------------------------------------------

    // ------------------------------------------------------------------
    // MESSAGE_TOAST / MESSAGE_BOX display hooks (moved here from the former
    // core/Messages.js). The options arrive as a plain object already
    // carrying the UI5 option names (duration, my, actions, ...): the backend
    // sends only what the app actually set and normalizes everything it can
    // decide on its own, so there is no mapping layer and no mirrored UI5
    // default here. What is left are the three things only the client can do
    // - turn an ONCLOSE event name into a callback that round-trips through
    // the controller's eB(), sanitize the message box details, and resolve a
    // control id to the live element dependentOn needs.
    // ------------------------------------------------------------------

    // `class` is not a MessageToast option: a toast carries no id, so the
    // classes go onto the DOM node of the newest toast (several can be open at
    // once). The element may not exist right after show(), so retry once on the
    // next animation frame.
    function applyToastClass(sClass) {
      const classes = sClass.trim().split(/\s+/).filter(Boolean);
      if (!classes.length) return;
      const apply = () => {
        const toasts = document.querySelectorAll(".sapMMessageToast");
        const toastEl = toasts[toasts.length - 1];
        if (toastEl) toastEl.classList.add(...classes);
        return Boolean(toastEl);
      };
      if (!apply()) requestAnimationFrame(apply);
    }

    function showToast(sText, mOptions, oController) {
      const o = { ...(mOptions || {}) };
      const sClass = o.class;
      delete o.class;
      if (o.onClose) {
        const sEvent = o.onClose;
        o.onClose = () => oController.eB([sEvent]);
      }
      const doShow = (MT) => {
        // no option set -> a plain show(), so UI5 owns every default
        if (Object.keys(o).length) MT.show(sText, o);
        else MT.show(sText);
        if (sClass) applyToastClass(sClass);
      };
      if (MessageToast) doShow(MessageToast);
      else sap.ui.require(["sap/m/MessageToast"], doShow);
    }

    function showBox(sType, sText, mOptions, oController) {
      const o = { ...(mOptions || {}) };
      if (o.onClose) {
        // the pressed action must ride OUTSIDE the event array: eB treats
        // args[0] as the event array (name + flags) and Server.roundtrip
        // shifts the WHOLE array away, so anything placed inside it never
        // reaches T_EVENT_ARG - the action then has to be the first
        // positional argument, like evImageEditorPopupClose's eB(["SAVE"], image)
        const sEvent = o.onClose;
        o.onClose = (sAction) => oController.eB([sEvent], sAction);
      }
      if (o.details) o.details = Lib.sanitizeMessageDetails(o.details);
      if (o.dependentOn) {
        // dependentOn (UI5 >= 1.124) ties the message box to an element's
        // lifecycle - the backend sends the control id, resolved here. A
        // missing/unresolvable id drops the option instead of passing a
        // string UI5 would choke on.
        const oDependentOn = ViewSlots.resolveById(o.dependentOn);
        if (oDependentOn) o.dependentOn = oDependentOn;
        else delete o.dependentOn;
      }
      // The backend lowercases the type, but an app can still spell one that
      // is no MessageBox display method at all. Restrict the lookup to
      // functions (MessageBox also carries enum objects like Action and Icon)
      // and never drop a requested message box silently: fall back to show().
      let showFn = MessageBox[sType];
      if (typeof showFn !== "function") {
        Lib.logError(
          `ControlCall: unknown message box type '${sType}', shown via show()`,
        );
        showFn = MessageBox.show;
      }
      // no option set -> the bare per-method call, so UI5 owns every default
      if (Object.keys(o).length) showFn(sText, o);
      else showFn(sText);
    }

    // ------------------------------------------------------------------
    // CONTROL_GLOBAL / CONTROL_BY_ID: call a whitelisted method on a
    // control (by id) or a global object. The whitelist is the safety
    // boundary; each entry lists the kind of every positional argument so
    // string payloads are cast/resolved (never "call anything with
    // anything"). Scope: imperative methods that have no binding equivalent.
    // NavContainer navigation (NAV_CONTAINER_TO and the NEST/NEST2/POPUP/
    // POPOVER variants) is dispatched here too: the backend routes those
    // events through the generic CONTROL_BY_ID path (method "to", the
    // slot passed as the view), handled by evControlCallById below.
    // ------------------------------------------------------------------

    // control method -> kinds of its positional args. Args beyond the
    // declared kinds are dropped; trailing args the caller did not send are
    // not passed at all (so `open()` stays a true no-arg call).
    // Object.create(null), not a plain literal, and the same for the two
    // whitelists below and for the handler map in FrontendAction.js.
    // These tables are indexed with a name that comes off the wire, and a
    // plain object answers for every key Object.prototype has: with a method
    // named "constructor" the CONTROL_METHODS lookup below returned a truthy
    // value, skipped isSafeControlMethod( ) entirely and then invoked
    // control["constructor"](...); BINDING_METHODS["toString"] silently ran
    // Object.prototype.toString instead of logging "method not allowed".
    // Not a security boundary by this module's own model - the backend is
    // trusted - but it defeated the deny-list and turned a malformed payload
    // into a silent wrong call rather than the log line that says what
    // happened. A prototype-less table has no keys but its own.
    const CONTROL_METHODS = Object.assign(Object.create(null), {
      // `pageId`, NOT `controlId`: the three containers that own a `to( )`
      // disagree about what the first argument may be. sap.m.NavContainer
      // normalises a Control to its id on its own first line, but
      // sap.f.FlexibleColumnLayout.to and sap.m.SplitContainer.to PROBE the
      // columns with `getPage( sPageId )`, which compares `aPages[i].getId()
      // == pageId` - a Control never equals an id string, so every probe
      // misses and the trailing `else` navigates the LAST column instead of
      // the one that owns the page. Measured on samples-controls app 578,
      // whose begin column never moved. Handing over the RESOLVED control's
      // id serves all three: NavContainer would compute exactly that id
      // itself, and the two probing containers finally match.
      to: ["pageId", "string"], // target page + optional transitionName
      back: [],
      // Same `pageId` kind as `to`, and MEASURED the same way (2026-08-27,
      // samples-controls app 101 on the live Node backend). Unlike `to`,
      // sap.m.NavContainer.backToPage does NOT rescue a raw id:
      // `_backTo` normalises only a Control (`if (sRequestedPageId instanceof
      // Control) sRequestedPageId = sRequestedPageId.getId()`), then hands the
      // value to `_findClosestPreviousPageInfo`, which walks `_pageStack` and
      // compares `info.id === sRequestedPreviousPageId` - strict, no prefixing.
      // Every `_pageStack` entry was pushed as `page.getId()`, so it carries
      // the view prefix the backend never sees. The unlisted-method path used
      // to hand over the raw ABAP literal, which therefore matched nothing:
      // UI5 logged "Cannot navigate backToPage('wizardContentPage') because
      // target page was not found among the previous pages." and `_backTo`
      // returned without navigating - a SILENT miss, the review page stayed up
      // and app 101's four "Edit" links and its Cancel/Submit legs did nothing.
      // Resolving to `mainView--wizardContentPage` navigates.
      backToPage: ["pageId"],
      toDetail: ["controlId"], // sap.m.SplitApp/SplitContainer: show a detail page
      toMaster: ["controlId"], // sap.m.SplitApp/SplitContainer: show a master page
      backDetail: [], // sap.m.SplitApp/SplitContainer: back in the detail stack
      backMaster: [], // sap.m.SplitApp/SplitContainer: back in the master stack
      setMode: ["string"], // sap.m.SplitApp/SplitContainer: SplitAppMode
      navigateBack: [], // sap.m.QuickView/QuickViewCard: navigate one page back
      focus: [],
      scrollToIndex: ["int"],
      scrollTo: ["int", "int"],
      open: ["string"], // optional page key (ViewSettingsDialog); PDFViewer/Dialog ignore it
      close: [],
      setExpanded: ["bool"],
      discardProgress: ["controlId"],
      setNextStep: ["controlId"],
      goToStep: ["controlId", "bool"], // Wizard: target step + focus flag
      openBy: ["anchor"], // DatePicker/TimePicker/Menu/MessagePopover... anchored open
      toggleBy: ["anchor"], // sap.m.Menu/MessagePopover: open anchored if closed, close if open
      setActivePage: ["controlId"], // sap.m.Carousel
      expandToLevel: ["int"], // sap.m.Tree / sap.ui.table.TreeTable: expand to N levels
      collapseAll: [], // sap.m.Tree / sap.ui.table.TreeTable: collapse every node
      expandSelected: [], // NOT a UI5 method: expand the tree's selected nodes
      collapseSelected: [], // NOT a UI5 method: collapse the tree's selected nodes
      setHiddenInPopin: ["object"], // sap.m.Table: hide columns by importance (JSON array of Priority keys)
      setSticky: ["object"], // sap.m.ListBase/sap.m.Table: JSON array of sap.m.Sticky keys
      setSelectedSection: ["controlIdOrNull"], // sap.uxap.ObjectPageLayout: an EMPTY argument clears the association
      setSelectedItem: ["controlIdOrNull"], // sap.m.List/sap.m.Select/...: an EMPTY argument clears the selection
      setP13nData: ["object"], // sap.m.p13n.*Panel: JSON array of the panel's items

      // sap.m.Button badge bounds. The `int` kind is load-bearing, not
      // decoration: both setters compare the incoming value against the
      // STORED bound (`iMax >= this._badgeMinValue`), so an undeclared
      // numeric string makes the second comparison a STRING comparison -
      // "50" >= "9" is false - and the setter drops the value into an `else`
      // whose only effect is a Log.warning. min 9 / max 50 is the smallest
      // pair that breaks (samples-controls app 249 drives both).
      setBadgeMinValue: ["int"], // below this value the badge stays hidden
      setBadgeMaxValue: ["int"], // above this value the badge reads "999+"

      css: ["string", "string"], // NOT a UI5 method: set one CSS property on the control's own DOM node
      enablePostButton: ["bool"], // sap.m.FeedInput: toggle the Post button independent of `enabled`
      addStyleClass: ["string"], // sap.ui.core.Control: add a CSS style class
      removeStyleClass: ["string"], // sap.ui.core.Control: remove a CSS style class
      toggleStyleClass: ["string"], // sap.ui.core.Control: toggle a CSS style class
      setAsyncURLHandler: ["string"], // sap.m.MessagePopover: name of a URL_POLICY below
    });

    // sap.m.MessagePopover.setAsyncURLHandler expects a live JS callback that
    // resolves a promise per message link - a shape no backend payload can
    // carry, and one round-trip per link would be the wrong ergonomics anyway.
    // The backend names one of these built-in policies instead, so the
    // link-gating stays declarative data on the wire (see rule "the frontend is
    // a thin, data-driven executor").
    const URL_POLICIES = {
      ALLOW_ALL: () => true,
      // the sap.m MessagePopover demo case: in-app links (#/x, /path, ?q=) may
      // be followed, anything that leaves the app (http:, mailto:, //host) is
      // disabled in the popover.
      RELATIVE_ONLY: (url) => !isAbsoluteUrl(url),
      DENY_ALL: () => false,
    };

    // CONTROL_METHODS.css writes ONE declaration onto the control's own DOM
    // node. It exists for the case where a control has no property for the
    // value at all - sap.m.Page has no `width`, so a sample that resizes its
    // container (a Slider driving `byId(...).$().width(v + "%")`) has nothing
    // to bind and no method to call. Where the target DOES have the property,
    // a bound property stays the correct path (rule "prefer a bindable
    // property"); this is the residue, not a general styling API.
    //
    // The property name is checked against this list so the wire stays a
    // narrow, declarative contract instead of "write anything anywhere"; the
    // value goes through CSSOM setProperty, which drops an invalid declaration
    // (a smuggled second declaration never parses).
    const CSS_PROPERTIES = [
      "width",
      "min-width",
      "max-width",
      "height",
      "min-height",
      "max-height",
      "color",
      "background-color",
      "font-size",
      "opacity",
    ];

    function isAbsoluteUrl(url) {
      const s = String(url ?? "").trim();
      // a scheme ("http:", "mailto:", "javascript:") or a protocol-relative
      // "//host" - everything else resolves against the app's own origin
      return /^[a-z][a-z0-9+.-]*:/i.test(s) || s.startsWith("//");
    }

    // A method LISTED above carries explicit arg kinds (and some, like openBy/
    // toggleBy, get special handling). A method NOT listed is still callable as
    // long as it is a public control method that is not framework-hostile - so
    // ordinary setters/toggles (setVisible, enablePostButton, setLayout, ...) work
    // without enumerating each one here. The denylist protects abap2UI5's own
    // invariants: nothing that frees or reparents a tracked control, swaps the
    // model/binding out from under the framework, tampers with event handlers, or
    // drives the render lifecycle by hand. (The backend is the trusted driver, so
    // this is a footgun guard, not a security boundary - and control[method] is
    // still checked to be a function before the call, so a typo just no-ops.)
    // Named setters/mutators (setVisible, addItem, removeItem, ...) stay
    // allowed - they are the API the backend legitimately drives. Denied are
    // the framework-hostile methods: teardown/reparenting (destroy, exit,
    // setParent, addDependent, placeAt), model/binding swaps (setModel,
    // setBinding*, bind*/unbind*), event-handler tampering (attach*/detach*,
    // fireEvent), the render lifecycle (rerender, invalidate) and the GENERIC
    // reflection mutators (setAggregation/addAggregation/insertAggregation/
    // removeAggregation/removeAllAggregation and their Association twins),
    // which take the member NAME as an argument and reparent tracked controls
    // behind the framework's back.
    // Two lists, because the two halves need different matching. A generic
    // reflection mutator has ONE spelling, so it is denied by EXACT name -
    // matching it by prefix would swallow the named per-aggregation methods
    // that share those first characters (removeAllSelectedDates,
    // removeAllItems, destroySpecialDates, ...), which are exactly the API
    // this allowlist is meant to offer: they detach or destroy children the
    // control itself owns - the same footprint the already-allowed removeItem
    // has - and carry no invariant beyond it. The other half is hostile in
    // every spelling (bindProperty as much as bind), so it stays a PREFIX.
    // Built from lists (not one long literal) so no single source line is too
    // long once embedded into the ABAP string constant (trans2abap.js caps
    // generated lines at 255 chars).
    const CONTROL_METHOD_DENY_EXACT = [
      "destroy",
      "exit",
      "fireEvent",
      "clone",
      "applySettings",
      "setAggregation",
      "addAggregation",
      "insertAggregation",
      "removeAggregation",
      "removeAllAggregation",
      "destroyAggregation",
      "setAssociation",
      "addAssociation",
      "removeAssociation",
      "removeAllAssociation",
    ];

    const CONTROL_METHOD_DENY_PREFIXES = [
      "_",
      "bind",
      "unbind",
      "attach",
      "detach",
      "addDependent",
      "placeAt",
      "rerender",
      "invalidate",
      "setModel",
      "setBinding", // covers setBindingContext
      "setParent",
    ];

    const CONTROL_METHOD_DENY = new RegExp(
      "^(" + CONTROL_METHOD_DENY_PREFIXES.join("|") + ")",
    );

    const CONTROL_METHOD_DENY_SET = new Set(CONTROL_METHOD_DENY_EXACT);

    function isSafeControlMethod(method) {
      return (
        typeof method === "string" &&
        method.length > 0 &&
        !CONTROL_METHOD_DENY_SET.has(method) &&
        !CONTROL_METHOD_DENY.test(method)
      );
    }

    // global object -> lazy getter + its allowed methods (with arg kinds).
    const GLOBAL_TARGETS = Object.assign(Object.create(null), {
      // The two message targets carry a `display` hook: the call is routed
      // through the local showToast/showBox instead of straight at the
      // global, so the option
      // handling client->message_toast_display( ) / message_box_display( )
      // relies on - an ONCLOSE event name turned into an eB() round-trip, the
      // details sanitizing, dependentOn, the toast style class - lives in one
      // place. A bare app call simply arrives without options.
      MESSAGE_TOAST: {
        get: () => MessageToast,
        methods: { show: ["string"] },
        display: (oController, method, aArgs, mOptions) =>
          showToast(aArgs[0], mOptions, oController),
      },
      MESSAGE_BOX: {
        get: () => MessageBox,
        // the method IS the box type - showBox itself falls back to show()
        // for a type this UI5 version does not carry
        methods: {
          show: ["string"],
          alert: ["string"],
          confirm: ["string"],
          information: ["string"],
          warning: ["string"],
          error: ["string"],
          success: ["string"],
        },
        display: (oController, method, aArgs, mOptions) =>
          showBox(method, aArgs[0], mOptions, oController),
      },
      // Not a UI5 global but the framework's own view-slot registry: the
      // slots (MAIN, NEST, NEST2, POPUP, POPOVER) are what a backend response
      // opens, fills and tears down, and every one of those calls is a
      // SYSTEM follow-up action. `display` and `updateModel` are not
      // ViewSlots methods - they live in actions/Slots, which owns the
      // fragment loading and the model - so the hook below routes them there.
      VIEW_SLOTS: {
        get: () => ViewSlots,
        // display takes TWO positional arguments, the slot and the view XML.
        // Declaring both also keeps it off the template path below, which
        // would otherwise read the XML as a placeholder value for the slot.
        methods: {
          destroy: ["string"],
          display: ["string", "string"],
          // takes no slot: which slots are open is the frontend's own
          // knowledge, so the action only says that the model changed
          updateModel: [],
        },
        display: (oController, method, aArgs, mOptions, ctx) =>
          Slots.action(method, aArgs[0], aArgs[1], mOptions, ctx?.seq),
      },
      // The browser history / URL. Router computes ONE outcome from the whole
      // options object - adopt the hash, push a route entry, replace it, or
      // write the app-state hash - which is why it is one call and not a
      // field per decision input. In the SYSTEM phase the options are only
      // STASHED on the response: View1 runs the one per-response sync after
      // the displays, whether or not a ROUTER action travelled (the common
      // roundtrip carries none), and injects the response's draft id there.
      ROUTER: {
        get: () => Router,
        methods: { sync: [] },
        display: (oController, method, aArgs, mOptions, ctx) => {
          if (ctx?.response) ctx.response._routerOptions = mOptions;
          else Router.sync(mOptions);
        },
      },
      BUSY_INDICATOR: {
        get: () => BusyIndicator,
        methods: { show: ["int"], hide: [] },
      },
      // A UI5 icon collection outside the default SAP-icons font - sap.tnt's
      // SAP-icons-TNT is the common one - resolves only once something has
      // called IconPool.registerFont({ fontFamily, fontURI }). In a normal UI5
      // app that call sits in the Component's init. An abap2UI5 app has no
      // Component of its own, and IconPool is a module-level SINGLETON rather
      // than a control, so CONTROL_BY_ID cannot address it and no global target
      // reached it: a sap-icon://SAP-icons-TNT/... URI rendered no glyph at
      // all, silently (samples-controls app 350).
      //
      // Two positional arguments rather than the config object UI5 takes,
      // because that is what a t_arg can carry; the hook assembles it.
      ICON_POOL: {
        get: () => sap.ui.require("sap/ui/core/IconPool"),
        methods: { registerFont: ["string", "string"] },
        display: (oController, method, aArgs) =>
          registerIconFont(aArgs[0], aArgs[1]),
      },
      // sap/ui/core/Theming only exists since UI5 1.118, so it must NOT be a
      // hard dependency (it 404s on 1.71 and kills the whole component load).
      // Resolve it lazily: on modern UI5 the core has it loaded, on 1.71 the
      // require returns undefined and the dispatch reports "not available".
      THEMING: {
        get: () => sap.ui.require("sap/ui/core/Theming"),
        methods: { setTheme: ["string"] },
      },
      // sap/ui/core/Popup is a HARD dependency of this module on purpose:
      // loading it registers the Popup.Dock enum with the DataType registry,
      // which MessageToast's dock validation needs - and MessageToast itself
      // is required lazily (see the module top) so its factory can only run
      // AFTER Popup's, capturing a working Dock type. The module exists on
      // every supported release; only setWithinArea is @since 1.89, and the
      // "not available" guard below covers that.
      POPUP: {
        get: () => CorePopup,
        methods: { setWithinArea: ["within"] },
      },
      // sap/ui/core/InvisibleMessage is @since 1.78 and is a SINGLETON: it
      // renders nothing, so it has no id CONTROL_BY_ID could resolve - a
      // global target is the only way a backend-driven content change can be
      // announced to a screen reader. Lazy-require like THEMING so 1.71 hits
      // the "not available" guard instead of failing the component load.
      // announce(sText, sMode) with sMode Polite (default) | Assertive.
      INVISIBLE_MESSAGE: {
        get: () => {
          const IM = sap.ui.require("sap/ui/core/InvisibleMessage");
          return IM ? IM.getInstance() : undefined;
        },
        methods: { announce: ["string", "string"] },
      },
      // sap/base/i18n/Formatting (@since 1.120) carries the global formatting
      // configuration. Custom currencies are the case an app cannot express
      // otherwise: the digit count of a currency code is neither a control
      // property nor something a per-binding formatter can register for the
      // standard sap.ui.model.type.Currency. The payload is a JSON object -
      // data the backend owns anyway. Lazy-require like THEMING.
      // The two are NOT interchangeable and the difference is silent: set
      // REPLACES the whole registration, add MERGES codes into it. An app
      // that registers currencies as it loads more data and reaches for
      // `set` drops the ones it registered before - and the symptom is a
      // wrong digit count in a table, never an error.
      // Both names are the module's own and were WRONG here until 2026-08-23:
      // the target read `sap/ui/core/Formatting`, which is not a module in any
      // UI5 release (Core.js loads the base one), so the require returned
      // undefined and every call logged "not available" and did nothing; and
      // the second method was spelled `addCustomCurrency`, which the module
      // does not have either - it is addCustomCurrencies, taking the same map
      // as set. Found through samples-controls app 196.
      FORMATTING: {
        get: () => sap.ui.require("sap/base/i18n/Formatting"),
        methods: {
          setCustomCurrencies: ["object"], // REPLACES: { CODE: { digits: n }, ... }
          addCustomCurrencies: ["object"], // MERGES: same shape, keeps the rest
        },
      },
    });

    // Cast one raw string argument to the kind the whitelist declared.
    // `view` (optional) is the slot the owning control was resolved in, so a
    // controlId argument resolves against the same view first - this keeps
    // slot-local ids unambiguous (e.g. a NavContainer navigating to one of
    // its own pages) before falling back to the global lookup.
    // A control CLONED from an aggregation template has no id the backend can
    // spell. UI5 mints it as `<templateId>-<parentId>-<index>` - deterministic,
    // but the parent id carries the VIEW PREFIX the framework assigns at
    // runtime (`v1--tpl-v1--car-0`), which the backend never sees. So an
    // aggregation item is addressed positionally instead:
    //
    //     "<controlId>/<aggregation>/<index>"     e.g. "carousel/pages/2"
    //
    // resolved here, on the client, where both the prefix and the aggregation
    // are known. This is the equivalent of the UI5 controller idiom
    // `oCarousel.setActivePage(oCarousel.getPages()[i])`, which no id-based
    // call can express. A plain id (no slashes) resolves exactly as before.
    const AGG_ITEM = /^([^/]+)\/([A-Za-z_][\w]*)\/(\d+)$/;

    function resolveControl(raw, view) {
      const byId = (id) =>
        (view && ViewSlots.byId(view.toUpperCase(), id)) ||
        ViewSlots.resolveById(id);

      const m = AGG_ITEM.exec(String(raw ?? ""));
      if (!m) return byId(raw);

      const owner = byId(m[1]);
      if (!owner || typeof owner.getAggregation !== "function") {
        Lib.logError(`aggregation item '${raw}': no control '${m[1]}'`);
        return null;
      }
      const items = owner.getAggregation(m[2]);
      if (!Array.isArray(items)) {
        Lib.logError(
          `aggregation item '${raw}': '${m[2]}' is no multiple aggregation of ${m[1]}`,
        );
        return null;
      }
      const item = items[Number(m[3])];
      if (!item) {
        // out of range is not an error the app can see otherwise - the method
        // would silently receive undefined and do nothing
        Lib.logError(
          `aggregation item '${raw}': ${m[2]} has ${items.length} item(s)`,
        );
        return null;
      }
      return item;
    }

    function castArg(kind, raw, view) {
      switch (kind) {
        case "int":
          return Number(raw);
        case "bool":
          return raw === "true" || raw === "X" || raw === true;
        case "controlId":
          return resolveControl(raw, view);
        case "pageId": {
          // Like `controlId`, but hands the container the resolved control's
          // ID rather than the control. Only for methods whose UI5 signature
          // is a page ID and which do NOT normalise a Control themselves -
          // see the `to` entry in CONTROL_METHODS for the measurement. The
          // resolution step is what makes this safe: the rendered id carries
          // the view prefix the backend never sees, so passing the raw ABAP
          // literal instead would break every existing navigation.
          const page = resolveControl(raw, view);
          if (page && typeof page.getId === "function") return page.getId();
          // No control under that id. Today the container absorbs this
          // silently (it just navigates its last column and logs a UI5
          // warning nobody reads), so name it here; the raw value is still
          // handed over, which is the best effort an already-qualified id
          // needs and is never worse than the `undefined` this used to pass.
          Lib.logError(
            `CONTROL_CALL: no control '${raw}' for the page argument`,
          );
          return raw;
        }
        case "controlIdOrNull":
          // an ASSOCIATION cannot be data-bound, so clearing one
          // (setSelectedSection(null), setSelectedItem(null)) can only travel
          // as a method argument - and an EMPTY argument must arrive as null,
          // not as the `false` castArgAuto would infer. Same "empty means
          // null" contract as the `within` kind below.
          if (raw === "" || raw === undefined || raw === null) return null;
          return resolveControl(raw, view) || null;
        case "anchor":
          // anchor argument for openBy-style methods: resolve the control id
          // and hand over the CONTROL itself, not its DOM element. Every
          // sap.m openBy accepts a control, and MessagePopover.openBy
          // dereferences oControl.getParent() on its argument, so a bare DOM
          // element throws ("getParent is not a function") and the popup never
          // opens. DatePicker/TimePicker/Menu accept a control just as well,
          // so a control is the universally-correct anchor.
          return resolveControl(raw, view);
        case "within":
          // sap.ui.core.Popup.setWithinArea: a control id confines every popup
          // to that control, an EMPTY argument releases the restriction (the
          // popup is bounded by the window again). Popup.convertWithin()
          // accepts a sap.ui.core.Element and dereferences its DOM node when a
          // popup opens, so handing over the CONTROL - not its DOM element -
          // is what survives a re-render of the area in between.
          if (raw === "" || raw === undefined || raw === null) return null;
          return resolveControl(raw, view) || null;
        case "object":
          // the backend embeds an argument that starts with { or [ as real
          // JSON (get_event_client_ajson), so on that path the value arrives
          // already parsed; only the legacy eF( ) string form needs parsing.
          if (raw && typeof raw === "object") return raw;
          try {
            return JSON.parse(raw);
          } catch {
            Lib.logError(`CONTROL_CALL: malformed object argument '${raw}'`);
            return {};
          }
        default:
          return raw;
      }
    }

    // Infer the type of an argument for a method with no declared kinds (the
    // generalized-allowlist path). abap2UI5 sends booleans as the ABAP tokens
    // 'X'/space, so recognize those; everything else passes through as a string
    // (UI5 coerces numeric strings for index/number setters). A method that needs
    // a literal 'X'/'true'/'false' string or a JSON object must be declared in
    // CONTROL_METHODS with an explicit kind, which overrides this inference.
    function castArgAuto(raw) {
      if (raw === "X" || raw === "true") return true;
      if (raw === "" || raw === " " || raw === "false") return false;
      return raw;
    }

    // The one case where inference is provably wrong: a string-typed property.
    // castArgAuto has to map ""/" " to false - that is how an ABAP boolean
    // travels - which leaves the EMPTY STRING with no spelling at all, so every
    // string setter on the unlisted path can be given any value except "".
    // UI5 then hides the failure instead of reporting it: validateProperty does
    // not reject a boolean for a string property, it casts implicitly
    // (`oValue = "" + oValue`), so setText("") arrives as setText(false) and
    // renders the four characters "false" - no error, no warning, and a
    // screenshot that reads like a typo rather than a type bug.
    //
    // The control and the method are both known here, so UI5's own declaration
    // can settle it instead of a guess: for a setXxx whose property is declared
    // `string`, pass the raw value through untouched. Everything else keeps the
    // inference, so the "X"/space boolean contract is untouched.
    function setsStringProperty(control, method) {
      if (!control || typeof method !== "string" || !/^set[A-Z]/.test(method))
        return false;
      const prop = control.getMetadata?.()?.getAllProperties?.()[
        method.charAt(3).toLowerCase() + method.slice(4)
      ];
      return !!prop && prop.type === "string";
    }

    // kinds whose EMPTY value is meaningful (null), so a missing trailing
    // argument still has to be passed: the backend wire drops a trailing empty
    // t_arg entry, and "clear this association" is exactly a call whose only
    // argument is empty.
    const NULLABLE_KINDS = ["controlIdOrNull"];

    // `target` (optional) is the { control, method } the call will land on -
    // only the CONTROL_BY_ID path can supply it, and it is only consulted on
    // the inferred branch.
    function castArgs(kinds, rawArgs, view, target) {
      // kinds === null: unlisted-but-allowed method, infer each arg's type
      if (kinds === null) {
        // a setXxx takes its value first, and that is the only position a
        // declared property type can speak for
        const keepString = setsStringProperty(target?.control, target?.method);
        return rawArgs.map((raw, i) =>
          i === 0 && keepString ? raw : castArgAuto(raw),
        );
      }
      // only cast args the caller actually sent - padding missing trailing
      // args would turn open() into open(undefined) and ints into NaN. The one
      // exception is a nullable kind (see above): pad it so the call carries
      // an explicit null instead of relying on the control's no-arg handling.
      let count = rawArgs.length;
      while (count < kinds.length && NULLABLE_KINDS.includes(kinds[count]))
        count++;
      return kinds
        .slice(0, count)
        .map((kind, i) => castArg(kind, rawArgs[i], view));
    }

    // Collections already registered in this session. UI5 tolerates a repeat
    // registerFont but Log.warning's on it, and a port issuing this from its
    // init branch would do so on every single round-trip.
    const registeredIconFonts = new Set();

    function registerIconFont(fontFamily, fontURI) {
      const IconPool = sap.ui.require("sap/ui/core/IconPool");
      if (!IconPool) {
        Lib.logError("ICON_POOL: sap/ui/core/IconPool is not loaded");
        return;
      }
      if (!fontFamily || !fontURI) {
        Lib.logError(
          "ICON_POOL: registerFont needs a fontFamily AND a fontURI",
        );
        return;
      }
      if (registeredIconFonts.has(fontFamily)) return;
      /* fontURI is a MODULE PATH in every real use ('sap/tnt/themes/base/fonts/'),
       * and resolving it through sap.ui.require.toUrl is what makes the
       * registration survive a different mount point - it is also what the UI5
       * samples pass. Anything that already looks like a URL is left alone. */
      const uri = /^(?:[a-z]+:)?\/\//i.test(fontURI)
        ? fontURI
        : sap.ui.require.toUrl(fontURI);
      IconPool.registerFont({ fontFamily, fontURI: uri });
      registeredIconFonts.add(fontFamily);
    }

    // The selected rows of a tree, as the row INDICES its expand()/collapse()
    // take. Two shapes, because the two tree controls disagree:
    //   sap.ui.table.TreeTable - getSelectedIndices() gives them directly
    //   sap.m.Tree             - getSelectedItems() + indexOfItem() per item
    // Returns null when the control is neither, so the caller can say so
    // rather than silently doing nothing. An index of -1 (an item the tree no
    // longer holds) is dropped: expand(-1) is not a smaller mistake than
    // expand(undefined).
    function selectedIndicesOf(control) {
      if (typeof control.getSelectedIndices === "function") {
        return control.getSelectedIndices();
      }
      if (
        typeof control.getSelectedItems === "function" &&
        typeof control.indexOfItem === "function"
      ) {
        return control
          .getSelectedItems()
          .map((item) => control.indexOfItem(item))
          .filter((i) => i >= 0);
      }
      return null;
    }

    // Run fn once the openBy/toggleBy anchor is in the DOM. A control anchor
    // goes through Lib.whenRendered (immediate if already rendered, otherwise
    // after its next onAfterRendering); anything else (a bare DOM element, or a
    // missing anchor) runs fn straight away.
    function whenAnchorRendered(anchor, oController, fn) {
      if (anchor && typeof anchor.getDomRef === "function") {
        Lib.whenRendered(anchor, oController, fn);
      } else {
        fn();
      }
    }

    // args: [_, id, view, method, ...params]
    function evControlCallById(oController, args) {
      const [, id, view, method] = args;
      let kinds = CONTROL_METHODS[method];
      if (!kinds) {
        // not explicitly listed: allow any public, non-hostile control method
        // (kinds = null -> arg types are inferred), else fail closed.
        if (!isSafeControlMethod(method)) {
          Lib.logError(`CONTROL_BY_ID: method '${method}' not allowed`);
          return;
        }
        kinds = null;
      }
      // slot first, registry fallback - the SAME rule resolveControl
      // applies to argument controls. The target used to be slot-ONLY when
      // `view` was set, so a fully-qualified id (the form UI5 messages
      // return from getControlIds()) resolved fine as an argument and
      // reported "not callable" as the target of the very same call.
      const control = view
        ? (ViewSlots.byId(view.toUpperCase(), id) ?? ViewSlots.resolveById(id))
        : ViewSlots.resolveById(id);
      // toggleBy is not a real control method: open the control anchored to
      // the anchor control if it is closed, close it if it is already open
      // (mirrors openBy for a press-to-toggle button). The popup's open state lives
      // client-side, so the decision stays here rather than round-tripping.
      if (method === "toggleBy") {
        if (!control || typeof control.openBy !== "function") {
          Lib.logError(
            `CONTROL_BY_ID: 'toggleBy' not callable on control '${id}'`,
          );
          return;
        }
        const anchor = castArgs(kinds, args.slice(4), view)[0];
        // Defer the open until the anchor is rendered: a Save-style roundtrip
        // can make the anchor (e.g. a button hidden until there are messages)
        // visible in the same response, so it may not be in the DOM yet.
        whenAnchorRendered(anchor, oController, () => {
          if (control.isOpen?.()) control.close();
          else control.openBy(anchor);
        });
        return;
      }
      // css is not a UI5 method either: it writes one whitelisted CSS
      // declaration onto the control's own DOM node, for the case where the
      // control has no property carrying that value (sap.m.Page has no
      // `width`). Like the original jQuery-style samples do, the declaration
      // lives on the element and is gone after a re-render - the backend
      // re-sends it with the next view, exactly as it re-sends every property.
      if (method === "css") {
        const prop = String(args[4] ?? "").toLowerCase();
        if (!CSS_PROPERTIES.includes(prop)) {
          Lib.logError(
            `CONTROL_BY_ID: css property '${args[4]}' not allowed (allowed: ${CSS_PROPERTIES.join(", ")})`,
          );
          return;
        }
        const el = control?.getDomRef?.();
        if (!el) {
          Lib.logError(`CONTROL_BY_ID: 'css' - control '${id}' has no DOM ref`);
          return;
        }
        el.style.setProperty(prop, String(args[5] ?? ""));
        return;
      }
      // expandSelected / collapseSelected are not UI5 methods either. Both
      // trees take INDICES (`expand(int|int[])`, `collapse(int|int[])`), and
      // only sap.ui.table.TreeTable can hand them over: it has
      // getSelectedIndices(). sap.m.Tree offers getSelectedItems() plus
      // indexOfItem(), so the mapping is a LOOP - and a loop written into an
      // event argument needs a JS callback, which UI5's ExpressionParser has
      // no grammar for (no `function` keyword, `{` is the object-literal nud),
      // so `.getSelectedItems().map(function (o) { ... })` does not fail on that
      // argument, it takes the WHOLE handler down and every argument with it.
      // The loop therefore lives here, which is the same reason `css` does:
      // the app has no spelling for it at all. It stays a thin executor - no
      // decision is made, the selection is read and handed straight back to
      // the control's own method.
      if (method === "expandSelected" || method === "collapseSelected") {
        const op = method === "expandSelected" ? "expand" : "collapse";
        if (!control || typeof control[op] !== "function") {
          Lib.logError(
            `CONTROL_BY_ID: '${method}' not callable on control '${id}'`,
          );
          return;
        }
        const indices = selectedIndicesOf(control);
        if (indices === null) {
          Lib.logError(
            `CONTROL_BY_ID: '${method}' - control '${id}' exposes no selection`,
          );
          return;
        }
        // an empty selection is not an error: nothing selected, nothing to
        // expand. Calling expand([]) would be a no-op anyway, but skipping it
        // keeps a stray re-render off a tree the user did not touch.
        if (indices.length) control[op](indices);
        return;
      }
      // setAsyncURLHandler takes a FUNCTION, so the argument names a policy
      // (see URL_POLICIES) and the client installs the matching built-in
      // validator - the wire still carries data, never code.
      if (method === "setAsyncURLHandler") {
        const policy = String(args[4] ?? "").toUpperCase();
        const isAllowed = URL_POLICIES[policy];
        if (!isAllowed) {
          Lib.logError(
            `CONTROL_BY_ID: unknown URL policy '${args[4]}' (allowed: ${Object.keys(URL_POLICIES).join(", ")})`,
          );
          return;
        }
        if (!control || typeof control.setAsyncURLHandler !== "function") {
          Lib.logError(
            `CONTROL_BY_ID: 'setAsyncURLHandler' not callable on control '${id}'`,
          );
          return;
        }
        control.setAsyncURLHandler((config) => {
          // the control hands over { url, id, promise }; the promise's
          // resolve() decides whether the link stays clickable
          config?.promise?.resolve({
            allowed: isAllowed(config.url),
            id: config.id,
          });
        });
        return;
      }
      // openBy is handled BEFORE the generic callable check: a control
      // without an own openBy (sap.ui.unified.Menu) still supports the
      // anchored open via its open(bWithKeyboard, opener, my, at, of)
      // signature - the anchor doubles as opener and dock reference.
      if (method === "openBy") {
        if (
          !control ||
          (typeof control.openBy !== "function" &&
            typeof control.open !== "function")
        ) {
          Lib.logError(
            `CONTROL_BY_ID: 'openBy' not callable on control '${id}'`,
          );
          return;
        }
        const anchor = castArgs(kinds, args.slice(4), view)[0];
        // Same reason as toggleBy: wait for the anchor to render.
        whenAnchorRendered(anchor, oController, () => {
          if (typeof control.openBy === "function") control.openBy(anchor);
          else control.open(false, anchor, "begin top", "begin bottom", anchor);
        });
        return;
      }
      if (!control || typeof control[method] !== "function") {
        Lib.logError(
          `CONTROL_BY_ID: '${method}' not callable on control '${id}'`,
        );
        return;
      }
      control[method](
        ...castArgs(kinds, args.slice(4), view, { control, method }),
      );
    }

    // args: [_, object, method, ...params]. `ctx` is the action context the
    // dispatcher threads through (FrontendAction.executeSystem) - it carries
    // the request stamp the VIEW_SLOTS display hook needs.
    function evControlCall(oController, args, ctx) {
      const [, name, method] = args;
      const target = GLOBAL_TARGETS[name];
      const kinds = target?.methods[method];
      if (!kinds) {
        Lib.logError(`CONTROL_GLOBAL: '${name}.${method}' not allowed`);
        return;
      }
      const obj = target.get();
      if (!obj) {
        Lib.logError(`CONTROL_GLOBAL: '${name}.${method}' not available`);
        return;
      }
      let raw = args.slice(3);
      // A `display` target additionally takes an OPTIONS OBJECT as its last
      // argument (the full set client->message_toast_display( ) sends). It
      // needs no marker to be told apart from the template values below: the
      // backend embeds a JSON object argument as real JSON
      // (get_event_client_ajson), so it arrives here already parsed, while
      // every positional and template value is a string.
      let mOptions;
      if (target.display) {
        const last = raw[raw.length - 1];
        if (last && typeof last === "object") {
          mOptions = last;
          raw = raw.slice(0, -1);
        }
      }
      // a single-string method (MessageToast.show, MessageBox.*) may receive
      // extra positional values: the first arg is then a template and its
      // {0},{1},... placeholders are replaced by the client-resolved extras, so
      // a "X has been activated" toast can be composed on the frontend without a
      // server round-trip. A lone string is passed through unchanged.
      if (kinds.length === 1 && kinds[0] === "string" && raw.length > 1) {
        raw = [formatTemplate(String(raw[0]), raw.slice(1))];
      }
      // A display hook is the executor, not obj[method] - so only the plain
      // path needs the "does this UI5 version carry it" probe (which is also
      // what let VIEW_SLOTS route methods that never exist on the target).
      if (target.display) {
        return target.display(oController, method, raw, mOptions || {}, ctx);
      }
      if (typeof obj[method] !== "function") {
        Lib.logError(`CONTROL_GLOBAL: '${name}.${method}' not available`);
        return;
      }
      obj[method](...castArgs(kinds, raw));
    }

    // replace placeholders in a template with the positional values (as
    // strings). Two forms:
    //   {N}                -> the Nth value verbatim
    //   {N?trueText:falseText} -> trueText when the Nth value is truthy, else
    //                         falseText (a boolean event param arrives as
    //                         "true"/"false", so a toggle can toast
    //                         "Pressed"/"Unpressed" without a server round-trip;
    //                         trueText/falseText carry no ":" or "}")
    // an out-of-range placeholder is left as-is.
    function formatTemplate(tpl, values) {
      return tpl.replace(
        /\{(\d+)(?:\?([^:}]*):([^}]*))?\}/g,
        (m, i, tText, fText) => {
          const n = Number(i);
          if (n >= values.length) return m;
          const v = String(values[n]);
          if (tText === undefined) return v;
          const truthy = v !== "" && !/^(false|0|undefined|null)$/i.test(v);
          return truthy ? tText : fText;
        },
      );
    }

    // ------------------------------------------------------------------
    // BINDING_CALL: apply a declarative filter/sorter to an aggregation
    // binding of a control resolved by id - the client-side equivalent of
    // the classic demo kit controller pattern
    // oList.getBinding("items").filter([new Filter(...)]). Same safety
    // boundary as CONTROL_BY_ID: only whitelisted binding methods,
    // only whitelisted filter operators, everything built from data
    // (path/operator/values), never from code strings.
    // ------------------------------------------------------------------

    const FILTER_OPERATORS = new Set([
      "BT",
      "Contains",
      "EndsWith",
      "EQ",
      "GE",
      "GT",
      "LE",
      "LT",
      "NB",
      "NE",
      "NotContains",
      "NotEndsWith",
      "NotStartsWith",
      "StartsWith",
    ]);

    const isEmpty = (v) => v == null || v === "";

    // binding method -> builder that turns the trailing params into the
    // aggregation-update call. A strict whitelist (unlike CONTROL_METHODS,
    // which now allows any non-denied public control method): an unlisted
    // binding method fails closed at the lookup.
    //   filter: params = [path, operator, value1, value2?]
    //   sort:   params = [path, descending?, group?] (ABAP bools "X"/"")
    // The backend arg serializer keeps empty args between filled ones as ''
    // placeholders but trims trailing empties, so all optionals sit at the
    // end and may arrive as undefined.
    // Compound form of the filter payload: ONE param carrying a JSON array
    // of groups, each group an array of [path, operator, value1, value2?]
    // rows - OR inside a group, AND across groups (the FacetFilter /
    // ViewSettingsDialog multi-facet shape). Data only: paths, whitelisted
    // operators and values - never code. An empty groups array clears.
    function buildFilterGroups(binding, json) {
      // the backend embeds a '['-starting argument as real JSON, so on that
      // path the groups arrive already parsed; only the XML-bound eF( )
      // string form still needs the parse
      let groups = json;
      if (typeof json === "string") {
        try {
          groups = JSON.parse(json);
        } catch {
          Lib.logError("BINDING_CALL: malformed filter groups JSON");
          return;
        }
      }
      if (!Array.isArray(groups)) {
        Lib.logError("BINDING_CALL: filter groups must be an array");
        return;
      }
      groups = groups.filter((g) => Array.isArray(g) && g.length);
      if (!groups.length) {
        binding.filter([]);
        return;
      }
      const outer = [];
      for (const group of groups) {
        const inner = [];
        for (const row of group) {
          const [path, operator, value1, value2] = Array.isArray(row)
            ? row
            : [];
          if (typeof path !== "string" || !FILTER_OPERATORS.has(operator)) {
            Lib.logError(
              `BINDING_CALL: bad filter row (path '${path}' / operator '${operator}')`,
            );
            return;
          }
          inner.push(
            new Filter(path, FilterOperator[operator], value1, value2),
          );
        }
        outer.push(new Filter(inner, false)); // OR inside the group
      }
      binding.filter([new Filter(outer, true)]); // AND across the groups
    }

    const BINDING_METHODS = Object.assign(Object.create(null), {
      filter(binding, params) {
        const [path, operator, value1, value2] = params;
        // A single param that starts with '[' is the compound groups JSON -
        // a model path can never start with '[', so the sniff is
        // unambiguous and the positional single-filter form stays as-is. It
        // arrives as a real array when the backend embedded it as JSON, as a
        // string from the XML-bound eF( ) form.
        if (
          params.length === 1 &&
          (Array.isArray(path) ||
            (typeof path === "string" && path.trimStart().startsWith("[")))
        ) {
          buildFilterGroups(binding, path);
          return;
        }
        // No filter values at all -> clear the filter (the demo kit search
        // pattern: an emptied search field). A one-sided range (empty
        // value1 but a set value2, e.g. BT with only an upper bound) is a
        // real filter, so only clear when BOTH values are empty.
        if (isEmpty(value1) && isEmpty(value2)) {
          binding.filter([]);
          return;
        }
        if (!FILTER_OPERATORS.has(operator)) {
          Lib.logError(`BINDING_CALL: operator '${operator}' not allowed`);
          return;
        }
        binding.filter([
          new Filter(path, FilterOperator[operator], value1, value2),
        ]);
      },
      sort(binding, [path, descending, group]) {
        binding.sort([
          new Sorter(path, castArg("bool", descending), castArg("bool", group)),
        ]);
      },
    });

    // args: [_, id, aggregation, method, ...params]
    function evBindingCall(oController, args) {
      const [, id, aggregation, method] = args;
      const build = BINDING_METHODS[method];
      if (!build) {
        Lib.logError(`BINDING_CALL: method '${method}' not allowed`);
        return;
      }
      const binding = ViewSlots.resolveById(id)?.getBinding?.(aggregation);
      if (!binding || typeof binding[method] !== "function") {
        Lib.logError(
          `BINDING_CALL: no '${aggregation}' binding with '${method}' on control '${id}'`,
        );
        return;
      }
      build(binding, args.slice(4));
    }

    // The events this module owns in the eF dispatch (see
    // core/FrontendAction.js, which merges the domain modules' handler maps).
    const handlers = {
      CONTROL_BY_ID: evControlCallById,
      CONTROL_GLOBAL: evControlCall,
      BINDING_CALL: evBindingCall,
    };

    // Every whitelisted global target is dispatchable by its own name too:
    // a backend-built action travels as ["VIEW_SLOTS","display",...] - the
    // CONTROL_GLOBAL prefix of the eF( ) form is a dispatch constant, not
    // information, so the wire drops it. The alias re-prepends it, so both
    // forms share one execution path (and the prefixed form stays accepted
    // for apps and skewed backends).
    for (const name of Object.keys(GLOBAL_TARGETS)) {
      handlers[name] = (oController, args, ctx) =>
        evControlCall(oController, ["CONTROL_GLOBAL", ...args], ctx);
    }

    return { handlers };
  },
);
