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
             `    "z2ui5/core/Lib",` && |\n| &&
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
             `    Lib,` && |\n| &&
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
             `      addStyleClass: ["string"], // sap.ui.core.Control: add a CSS style class` && |\n| &&
             `      removeStyleClass: ["string"], // sap.ui.core.Control: remove a CSS style class` && |\n| &&
             `      toggleStyleClass: ["string"], // sap.ui.core.Control: toggle a CSS style class` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    // global object -> lazy getter + its allowed methods (with arg kinds).` && |\n| &&
             `    const GLOBAL_TARGETS = {` && |\n| &&
             `      MESSAGE_TOAST: { get: () => MessageToast, methods: { show: ["string"] } },` && |\n| &&
             `      MESSAGE_BOX: {` && |\n| &&
             `        get: () => MessageBox,` && |\n| &&
             `        methods: {` && |\n| &&
             `          show: ["string"],` && |\n| &&
             `          information: ["string"],` && |\n| &&
             `          warning: ["string"],` && |\n| &&
             `          error: ["string"],` && |\n| &&
             `          success: ["string"],` && |\n| &&
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
             `    };` && |\n| &&
             `` && |\n| &&
             `    // Cast one raw string argument to the kind the whitelist declared.` && |\n| &&
             `    // ``view`` (optional) is the slot the owning control was resolved in, so a` && |\n| &&
             `    // controlId argument resolves against the same view first - this keeps` && |\n| &&
             `    // slot-local ids unambiguous (e.g. a NavContainer navigating to one of` && |\n| &&
             `    // its own pages) before falling back to the global lookup.` && |\n| &&
             `    function castArg(kind, raw, view) {` && |\n| &&
             `      switch (kind) {` && |\n| &&
             `        case "int":` && |\n| &&
             `          return Number(raw);` && |\n| &&
             `        case "bool":` && |\n| &&
             `          return raw === "true" || raw === "X" || raw === true;` && |\n| &&
             `        case "controlId":` && |\n| &&
             `          return (` && |\n| &&
             `            (view && ViewSlots.byId(view.toUpperCase(), raw)) ||` && |\n| &&
             `            ViewSlots.resolveById(raw)` && |\n| &&
             `          );` && |\n| &&
             `        case "anchor":` && |\n| &&
             `          // anchor argument for openBy-style methods: resolve the control id` && |\n| &&
             `          // and hand over the CONTROL itself, not its DOM element. Every` && |\n| &&
             `          // sap.m openBy accepts a control, and MessagePopover.openBy` && |\n| &&
             `          // dereferences oControl.getParent() on its argument, so a bare DOM` && |\n| &&
             `          // element throws ("getParent is not a function") and the popup never` && |\n| &&
             `          // opens. DatePicker/TimePicker/Menu accept a control just as well,` && |\n| &&
             `          // so a control is the universally-correct anchor.` && |\n| &&
             `          return (` && |\n| &&
             `            (view && ViewSlots.byId(view.toUpperCase(), raw)) ||` && |\n| &&
             `            ViewSlots.resolveById(raw)` && |\n| &&
             `          );` && |\n| &&
             `        case "object":` && |\n| &&
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
             `    function castArgs(kinds, rawArgs, view) {` && |\n| &&
             `      // only cast args the caller actually sent - padding missing trailing` && |\n| &&
             `      // args would turn open() into open(undefined) and ints into NaN` && |\n| &&
             `      return kinds` && |\n| &&
             `        .slice(0, rawArgs.length)` && |\n| &&
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
             `      const kinds = CONTROL_METHODS[method];` && |\n| &&
             `      if (!kinds) {` && |\n| &&
             `        Lib.logError(``CONTROL_BY_ID: method '${method}' not allowed``);` && |\n| &&
             `        return;` && |\n| &&
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
             `      if (!control || typeof control[method] !== "function") {` && |\n| &&
             `        Lib.logError(` && |\n| &&
             `          ``CONTROL_BY_ID: '${method}' not callable on control '${id}'``,` && |\n| &&
             `        );` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      if (method === "openBy") {` && |\n| &&
             `        const anchor = castArgs(kinds, args.slice(4), view)[0];` && |\n| &&
             `        // Same reason as toggleBy: wait for the anchor to render.` && |\n| &&
             `        whenAnchorRendered(anchor, oController, () => control.openBy(anchor));` && |\n| &&
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
             `      if (!obj || typeof obj[method] !== "function") {` && |\n| &&
             `        Lib.logError(``CONTROL_GLOBAL: '${name}.${method}' not available``);` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      const raw = args.slice(3);` && |\n| &&
             `      // a single-string method (MessageToast.show, MessageBox.*) may receive` && |\n| &&
             `      // extra positional values: the first arg is then a template and its` && |\n| &&
             `      // {0},{1},... placeholders are replaced by the client-resolved extras, so` && |\n| &&
             `      // a "X has been activated" toast can be composed on the frontend without a` && |\n| &&
             `      // server round-trip. A lone string is passed through unchanged.` && |\n| &&
             `      if (kinds.length === 1 && kinds[0] === "string" && raw.length > 1) {` && |\n| &&
             `        obj[method](formatTemplate(String(raw[0]), raw.slice(1)));` && |\n| &&
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
             `    ]);` && |\n| &&
             `` && |\n| &&
             `    const isEmpty = (v) => v == null || v === "";` && |\n| &&
             `` && |\n| &&
             `    // binding method -> builder that turns the trailing params into the` && |\n| &&
             `    // aggregation-update call. Same declarative-whitelist shape as` && |\n| &&
             `    // CONTROL_METHODS: an unlisted method fails closed at the lookup.` && |\n| &&
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
             `          new Sorter(path, castArg("bool", descending), castArg("bool", group)),` && |\n| &&
             `        ]);` && |\n|.
    result = result &&
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
             `    function evClipboardCopy(oController, args) {` && |\n| &&
             `      Lib.copyToClipboard(args[1]);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evClipboardAppState() {` && |\n| &&
             `      // Guard against a missing response so the copied link never carries` && |\n| &&
             `      // the literal "undefined" as its state id.` && |\n| &&
             `      const id = AppState.state.oResponse?.ID || "";` && |\n| &&
             `      // Strip any existing hash (e.g. an active app-state) so the copied` && |\n| &&
             `      // link carries only the fresh state id.` && |\n| &&
             `      const base = window.location.href.split("#")[0];` && |\n| &&
             `      Lib.copyToClipboard(``${base}#/z2ui5-xapp-state=${id}``);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evDownloadB64File(oController, args) {` && |\n| &&
             `      if (!Lib.isSafeDownloadURL(args[1])) {` && |\n| &&
             `        Lib.logError("DOWNLOAD_B64_FILE: blocked unsafe URL");` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      const a = document.createElement("a");` && |\n| &&
             `      a.href = args[1];` && |\n| &&
             `      // Fall back to an empty download attribute when the backend omits the` && |\n| &&
             `      // filename, so the anchor never carries the literal "undefined".` && |\n| &&
             `      a.download = args[2] || "";` && |\n| &&
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
             `      const separator = path.includes("?") ? "&" : "?";` && |\n| &&
             `      const bspKill = ``${path}${separator}sap-sessioncmd=logoff``;` && |\n| &&
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
             `    function evUrlHelper(oController, args) {` && |\n| &&
             `      const params = args[2] ?? {};` && |\n| &&
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
             `        TRIGGER_SMS: () => _URLHelper.triggerSms(params),` && |\n| &&
             `        TRIGGER_TEL: () => _URLHelper.triggerTel(params),` && |\n| &&
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
             `        oController.eB([callbackEvent]);` && |\n| &&
             `      }, delay);` && |\n| &&
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
             `    function evSetFocus(oController, args) {` && |\n| &&
             `      // resolveById (not byId "MAIN") so a fully-qualified control id also` && |\n| &&
             `      // resolves - ids that come from a UI5 Message (getControlIds()) or any` && |\n| &&
             `      // event carry the view prefix and only match via the global registry.` && |\n| &&
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
             `      Lib.whenRendered(oElement, oController, applyFocus);` && |\n| &&
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
             `      // does nothing on a Page. ScrollEnablement.scrollTo(x, y, time)` && |\n|.
    result = result &&
             `      // animates when time > 0, so "smooth" maps to a 300ms animation.` && |\n| &&
             `      // Native Element.scrollTo is only used as a fallback for controls` && |\n| &&
             `      // without a delegate.` && |\n| &&
             `      try {` && |\n| &&
             `        const oElement = ViewSlots.byId("MAIN", args[1]);` && |\n| &&
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
             `        // resolveById so a fully-qualified control id (e.g. from a UI5` && |\n| &&
             `        // Message's getControlIds()) also resolves, not just a MAIN-local id.` && |\n| &&
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
             `      POPUP_CLOSE: () => ViewSlots.destroy("POPUP"),` && |\n| &&
             `      POPOVER_CLOSE: () => ViewSlots.destroy("POPOVER"),` && |\n| &&
             `      BIND_ELEMENT: evBindElement,` && |\n| &&
             `      URLHELPER: evUrlHelper,` && |\n| &&
             `      IMAGE_EDITOR_POPUP_CLOSE: evImageEditorPopupClose,` && |\n| &&
             `      SET_TITLE: evSetTitle,` && |\n| &&
             `      SET_TITLE_LAUNCHPAD: evSetTitleLaunchpad,` && |\n| &&
             `      SET_FOCUS: evSetFocus,` && |\n| &&
             `      SCROLL_TO: evScrollTo,` && |\n| &&
             `      SCROLL_INTO_VIEW: evScrollIntoView,` && |\n| &&
             `      START_TIMER: evStartTimer,` && |\n| &&
             `      KEYBOARD_SET_MODE: evSetInputMode,` && |\n| &&
             `      Z2UI5: evZ2ui5Custom,` && |\n| &&
             `      WIZARD_SET_NEXT_STEP: evWizardSetNextStep,` && |\n| &&
             `      PLAY_AUDIO: evPlayAudio,` && |\n| &&
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
             `    return { execute };` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
