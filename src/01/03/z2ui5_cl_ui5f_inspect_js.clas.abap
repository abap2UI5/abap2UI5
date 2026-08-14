* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Embedded frontend resource, generated from app/webapp/ by
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
CLASS z2ui5_cl_ui5f_inspect_js DEFINITION
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


CLASS z2ui5_cl_ui5f_inspect_js IMPLEMENTATION.

  METHOD get.

    result = `// Read-only inspectors of the developer tools.` && |\n| &&
             `//` && |\n| &&
             `// Like core/devtools/Recorder.js this module is OUTSIDE the framework: it` && |\n| &&
             `// only reads state other modules own (AppState, ViewSlots, the recorded` && |\n| &&
             `// history) and renders it as text for a developer-tools tab. Nothing here` && |\n| &&
             `// is wired into a framework code path, and nothing in the framework knows` && |\n| &&
             `// this file exists.` && |\n| &&
             `//` && |\n| &&
             `// Everything renders to plain text rather than a control tree, because the` && |\n| &&
             `// same string has to serve two consumers: the CodeEditor in the dialog and` && |\n| &&
             `// the Export blob.` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    "sap/ui/Device",` && |\n| &&
             `    "z2ui5/core/AppState",` && |\n| &&
             `    "z2ui5/core/Lib",` && |\n| &&
             `    "z2ui5/core/ScrollFocus",` && |\n| &&
             `    "z2ui5/core/ViewSlots",` && |\n| &&
             `    "z2ui5/core/devtools/Recorder",` && |\n| &&
             `  ],` && |\n| &&
             `  (Device, AppState, Lib, ScrollFocus, ViewSlots, Recorder) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // Longest argument rendered inline in the action list; a view XML` && |\n| &&
             `    // argument is thousands of characters and would bury the structure.` && |\n| &&
             `    const MAX_ARG_CHARS = 160;` && |\n| &&
             `` && |\n| &&
             `    // Cap for the scraped event list - a generated view can bind hundreds.` && |\n| &&
             `    const MAX_SCRAPED_EVENTS = 200;` && |\n| &&
             `` && |\n| &&
             `    const LABEL_WIDTH = 24;` && |\n| &&
             `` && |\n| &&
             `    function line(label, value) {` && |\n| &&
             `      const text =` && |\n| &&
             `        value === undefined || value === null || value === "" ? "-" : value;` && |\n| &&
             `      return ``  ${label.padEnd(LABEL_WIDTH)}${text}``;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function section(title) {` && |\n| &&
             `      return ``\n${title}\n${"-".repeat(title.length)}``;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function yesNo(value) {` && |\n| &&
             `      return value ? "yes" : "no";` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function truncate(text, max) {` && |\n| &&
             `      const str = String(text);` && |\n| &&
             `      if (str.length <= max) return str;` && |\n| &&
             `      return ``${str.slice(0, max)}... (${str.length} chars)``;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Environment` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    // The running theme, version-independently. sap/ui/core/Theming arrived` && |\n| &&
             `    // in 1.118 and is the only API left in UI5 2.x; older releases expose` && |\n| &&
             `    // it through the Configuration singleton.` && |\n| &&
             `    function getTheme() {` && |\n| &&
             `      const Theming = sap.ui.require("sap/ui/core/Theming");` && |\n| &&
             `      if (Theming?.getTheme) return Theming.getTheme();` && |\n| &&
             `      /* ui5lint-disable no-globals, no-deprecated-api --` && |\n| &&
             `       deliberate fallback for UI5 releases without sap/ui/core/Theming` && |\n| &&
             `       (added in 1.118); the modern API is used in the branch above. */` && |\n| &&
             `      if (sap.ui.getCore) {` && |\n| &&
             `        const config = sap.ui.getCore().getConfiguration?.();` && |\n| &&
             `        if (config?.getTheme) return config.getTheme();` && |\n| &&
             `      }` && |\n| &&
             `      /* ui5lint-enable no-globals, no-deprecated-api */` && |\n| &&
             `      return "";` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // SAPUI5 and OpenUI5 ship different control libraries, and a view that` && |\n| &&
             `    // works on one can fail to load a module on the other - so which one is` && |\n| &&
             `    // running is a first-order fact when a view refuses to build. The` && |\n| &&
             `    // distribution is visible in the version info's group/artefact id.` && |\n| &&
             `    function getDistribution(sUi5) {` && |\n| &&
             `      const gav = sUi5?.GAV || "";` && |\n| &&
             `      if (!gav) return "";` && |\n| &&
             `      return gav.includes("com.sap.ui5") ? "SAPUI5" : "OpenUI5";` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function modelAttributeCount(slotKey) {` && |\n| &&
             `      const data = ViewSlots.getView(slotKey)?.getModel?.()?.getData?.();` && |\n| &&
             `      if (!data) return 0;` && |\n| &&
             `      return Object.keys(data).length;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function formatSlots() {` && |\n| &&
             `      const lines = [];` && |\n| &&
             `      for (const slot of ViewSlots.slots) {` && |\n| &&
             `        const view = ViewSlots.getView(slot.key);` && |\n| &&
             `        const xml = ViewSlots.getViewXml(slot.key);` && |\n| &&
             `        if (!view && !xml) {` && |\n| &&
             `          lines.push(line(slot.key, "empty"));` && |\n| &&
             `          continue;` && |\n| &&
             `        }` && |\n| &&
             `        const parts = [];` && |\n| &&
             `        parts.push(view ? "filled" : "xml only");` && |\n| &&
             `        if (xml) parts.push(``${xml.length} chars XML``);` && |\n| &&
             `        if (slot.ownsModel) {` && |\n| &&
             `          parts.push(``${modelAttributeCount(slot.key)} model attributes``);` && |\n| &&
             `        } else {` && |\n| &&
             `          parts.push("inherits MAIN model");` && |\n| &&
             `        }` && |\n| &&
             `        lines.push(line(slot.key, parts.join(", ")));` && |\n| &&
             `      }` && |\n| &&
             `      return lines;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function formatEnvironment() {` && |\n| &&
             `      const state = AppState.state;` && |\n| &&
             `      const oConfig = AppState.getGlobal("oConfig") || {};` && |\n| &&
             `      const sUi5 = oConfig.S_UI5;` && |\n| &&
             `      const responseFront = state.responseData?.S_FRONT;` && |\n| &&
             `      const out = ["abap2UI5 Developer Tools - Environment"];` && |\n| &&
             `` && |\n| &&
             `      out.push(section("App"));` && |\n| &&
             `      out.push(line("App class", responseFront?.APP));` && |\n| &&
             `      out.push(line("Rendered app", state.renderedApp));` && |\n| &&
             `      out.push(line("Draft id (received)", responseFront?.ID));` && |\n| &&
             `      out.push(line("Draft id (sent)", state.oBody?.S_FRONT?.ID));` && |\n| &&
             `      out.push(line("Last event", state.oBody?.S_FRONT?.EVENT));` && |\n| &&
             `      out.push(line("Roundtrip in flight", yesNo(state.isBusy)));` && |\n| &&
             `` && |\n| &&
             `      out.push(section("Session"));` && |\n| &&
             `      out.push(line("sap-contextid", state.contextId));` && |\n| &&
             `      out.push(line("Backend endpoint", AppState.getGlobal("url")));` && |\n| &&
             `      out.push(` && |\n| &&
             `        line("Served by backend", yesNo(AppState.getGlobal("checkLocal"))),` && |\n| &&
             `      );` && |\n| &&
             `      out.push(line("Launchpad", yesNo(state.oLaunchpad)));` && |\n| &&
             `      out.push(line("Origin", window.location.origin));` && |\n| &&
             `      out.push(line("Pathname", window.location.pathname));` && |\n| &&
             `      out.push(line("Search", window.location.search));` && |\n| &&
             `      out.push(line("Hash", window.location.hash));` && |\n| &&
             `` && |\n| &&
             `      out.push(section("Routing"));` && |\n| &&
             `      out.push(line("Hash routing", yesNo(state.navRouting)));` && |\n| &&
             `      out.push(line("Mode", state.navMode));` && |\n| &&
             `      out.push(line("Current app", state.currentApp));` && |\n| &&
             `      out.push(line("Current draft id", state.currentDraftId));` && |\n| &&
             `` && |\n| &&
             `      out.push(section("UI5"));` && |\n| &&
             `      /* ui5lint-disable no-globals --` && |\n| &&
             `       sap.ui.version is the only way to read the running UI5 version; there` && |\n| &&
             `       is no injected/module equivalent (core/Lib.js reads it the same way). */` && |\n| &&
             `      out.push(line("Version", sap.ui.version));` && |\n| &&
             `      /* ui5lint-enable no-globals */` && |\n| &&
             `      out.push(line("Distribution", getDistribution(sUi5)));` && |\n| &&
             `      out.push(line("Build timestamp", sUi5?.BUILDTIMESTAMP));` && |\n| &&
             `      out.push(line("Theme", getTheme()));` && |\n| &&
             `` && |\n| &&
             `      out.push(section("Device"));` && |\n| &&
             `      out.push(line("System", Lib.deriveSystemType(Device.system)));` && |\n| &&
             `      out.push(` && |\n| &&
             `        line(` && |\n| &&
             `          "Browser",` && |\n| &&
             `          ``${Device.browser.name || "?"} ${Device.browser.version || ""}``.trim(),` && |\n| &&
             `        ),` && |\n| &&
             `      );` && |\n| &&
             `      out.push(` && |\n| &&
             `        line(` && |\n| &&
             `          "OS",` && |\n| &&
             `          ``${Device.os.name || "?"} ${Device.os.version || ""}``.trim(),` && |\n| &&
             `        ),` && |\n| &&
             `      );` && |\n| &&
             `      out.push(` && |\n| &&
             `        line(` && |\n| &&
             `          "Orientation",` && |\n| &&
             `          Device.orientation.portrait ? "portrait" : "landscape",` && |\n| &&
             `        ),` && |\n| &&
             `      );` && |\n| &&
             `      out.push(` && |\n| &&
             `        line(` && |\n| &&
             `          "Window",` && |\n| &&
             `          ``${Device.resize.width || window.innerWidth} x `` +` && |\n| &&
             `            ``${Device.resize.height || window.innerHeight}``,` && |\n| &&
             `        ),` && |\n| &&
             `      );` && |\n| &&
             `      out.push(line("Touch", yesNo(Device.support.touch)));` && |\n| &&
             `      out.push(line("Pointer", yesNo(Device.support.pointer)));` && |\n| &&
             `      out.push(line("Retina", yesNo(Device.support.retina)));` && |\n| &&
             `` && |\n| &&
             `      out.push(...formatFrontendInfo());` && |\n| &&
             `` && |\n| &&
             `      out.push(section("View slots"));` && |\n| &&
             `      out.push(...formatSlots());` && |\n| &&
             `` && |\n| &&
             `      return out.join("\n");` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // The frontend block the framework puts on the wire - what an app reads` && |\n| &&
             `    // as client->get( )-s_ui5 / -s_device / -s_focus / -s_scroll and what` && |\n| &&
             `    // the start page's "System Information" popup shows of it. Rendered` && |\n| &&
             `    // here from the LIVE producers (core/ScrollFocus.js), so it is what the` && |\n| &&
             `    // NEXT roundtrip will send, not what the last one happened to carry.` && |\n| &&
             `    //` && |\n| &&
             `    // Focus and scroll are the interesting half: they travel on every` && |\n| &&
             `    // roundtrip, they decide where the caret and the scroll position end up` && |\n| &&
             `    // after a re-render, and nothing has ever shown them.` && |\n| &&
             `    function formatFrontendInfo() {` && |\n| &&
             `      const out = [section("Frontend info sent to the backend")];` && |\n| &&
             `      out.push("  (client->get( )-s_focus / -s_scroll, live for the next");` && |\n| &&
             `      out.push("  roundtrip - see -s_ui5 / -s_device above)");` && |\n| &&
             `      out.push("");` && |\n| &&
             `` && |\n| &&
             `      let focus;` && |\n| &&
             `      let scroll;` && |\n| &&
             `      try {` && |\n| &&
             `        focus = ScrollFocus.getFocusInfo();` && |\n| &&
             `        scroll = ScrollFocus.getScrollInfo();` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("DevTools Inspect: reading focus/scroll failed", e);` && |\n| &&
             `        out.push("  (focus / scroll info unavailable)");` && |\n| &&
             `        return out;` && |\n| &&
             `      }` && |\n| &&
             `` && |\n| &&
             `      out.push(line("Focused control", focus?.ID));` && |\n| &&
             `      if (focus?.SELECTION_START !== undefined) {` && |\n| &&
             `        out.push(` && |\n| &&
             `          line("Caret", ``${focus.SELECTION_START} - ${focus.SELECTION_END}``),` && |\n| &&
             `        );` && |\n| &&
             `      }` && |\n| &&
             `      out.push("");` && |\n| &&
             `      let anyScroll = false;` && |\n| &&
             `      for (const slot of ViewSlots.slots) {` && |\n| &&
             `        // getScrollInfo keys by slot key and omits slots never scrolled` && |\n| &&
             `        const entry = scroll?.[slot.key];` && |\n| &&
             `        if (!entry) continue;` && |\n| &&
             `        anyScroll = true;` && |\n| &&
             `        out.push(` && |\n| &&
             `          line(` && |\n| &&
             `            ``Scroll ${slot.key}``,` && |\n| &&
             `            ``${entry.ID || "(unnamed)"}  x ${entry.X || 0} / y ${entry.Y || 0}``,` && |\n| &&
             `          ),` && |\n| &&
             `        );` && |\n| &&
             `      }` && |\n| &&
             `      if (!anyScroll) out.push(line("Scroll", "nothing scrolled yet"));` && |\n| &&
             `      return out;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Registry - what the frontend currently has registered` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    // Backend event names bound in a view's XML. The framework binds an` && |\n| &&
             `    // event as ``.eB(['NAME'])`` / ``.eF(['NAME'])`` (see the backend's` && |\n| &&
             `    // get_event), so the names can be read back off the XML the slot was` && |\n| &&
             `    // filled with. Best effort by design: this is a diagnostic listing, and` && |\n| &&
             `    // a name it misses costs nothing but a shorter list.` && |\n| &&
             `    function scrapeEvents(xml) {` && |\n| &&
             `      if (!xml) return [];` && |\n| &&
             `      const found = new Set();` && |\n| &&
             `      // eB / eBP / eF, then an optional array bracket, then the quoted` && |\n| &&
             `      // event name - single, double or the XML-escaped apostrophe.` && |\n| &&
             `      const pattern =` && |\n| &&
             `        /\b(eB|eBP|eF)\s*\(\s*\[?\s*(?:&apos;|&quot;|['"])([A-Za-z0-9_.-]+)/g;` && |\n| &&
             `      let match = pattern.exec(xml);` && |\n| &&
             `      while (match !== null && found.size < MAX_SCRAPED_EVENTS) {` && |\n| &&
             `        found.add(``${match[1]}  ${match[2]}``);` && |\n| &&
             `        match = pattern.exec(xml);` && |\n| &&
             `      }` && |\n| &&
             `      return Array.from(found).sort();` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function formatShortcuts() {` && |\n| &&
             `      const shortcuts = AppState.state.shortcuts || {};` && |\n| &&
             `      const combos = Object.keys(shortcuts).sort();` && |\n| &&
             `      if (!combos.length) return ["  (none registered)"];` && |\n| &&
             `      const out = [];` && |\n| &&
             `      for (const combo of combos) {` && |\n| &&
             `        const scopes = shortcuts[combo];` && |\n| &&
             `        for (const scope of Object.keys(scopes)) {` && |\n| &&
             `          const entry = scopes[scope];` && |\n| &&
             `          out.push(` && |\n| &&
             `            ``  ${combo.padEnd(22)}${(scope || "(global)").padEnd(12)}`` +` && |\n| &&
             `              ``-> ${entry?.event || "?"}``,` && |\n| &&
             `          );` && |\n| &&
             `        }` && |\n| &&
             `      }` && |\n| &&
             `      return out;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function formatRegistry() {` && |\n| &&
             `      const state = AppState.state;` && |\n| &&
             `      const out = ["abap2UI5 Developer Tools - Registry"];` && |\n| &&
             `` && |\n| &&
             `      out.push(section("Keyboard shortcuts (combo / scope / backend event)"));` && |\n| &&
             `      out.push(...formatShortcuts());` && |\n| &&
             `` && |\n| &&
             `      out.push(section("Pending backend timers"));` && |\n| &&
             `      const timers = Object.keys(state.timers || {});` && |\n| &&
             `      out.push(timers.length ? ``  ${timers.join(", ")}`` : "  (none pending)");` && |\n| &&
             `` && |\n| &&
             `      out.push(section("Framework callbacks registered"));` && |\n| &&
             `      for (const name of [` && |\n| &&
             `        "onBeforeRoundtrip",` && |\n| &&
             `        "onAfterRoundtrip",` && |\n| &&
             `        "onAfterRendering",` && |\n| &&
             `        "onBeforeEventFrontend",` && |\n| &&
             `      ]) {` && |\n| &&
             `        out.push(line(name, String((state[name] || []).length)));` && |\n| &&
             `      }` && |\n| &&
             `` && |\n| &&
             `      out.push(section("Model size limits"));` && |\n| &&
             `      const limits = state.viewSizeLimits || {};` && |\n| &&
             `      const limitKeys = Object.keys(limits);` && |\n| &&
             `      if (!limitKeys.length) out.push("  (UI5 default everywhere)");` && |\n| &&
             `      for (const key of limitKeys) out.push(line(key, String(limits[key])));` && |\n| &&
             `` && |\n| &&
             `      out.push(section("Backend events bound in the current views"));` && |\n| &&
             `      let any = false;` && |\n| &&
             `      for (const slot of ViewSlots.slots) {` && |\n| &&
             `        const xml =` && |\n| &&
             `          ViewSlots.getView(slot.key)?.mProperties?.viewContent ||` && |\n| &&
             `          ViewSlots.getViewXml(slot.key);` && |\n| &&
             `        const events = scrapeEvents(xml);` && |\n| &&
             `        if (!events.length) continue;` && |\n| &&
             `        any = true;` && |\n| &&
             `        out.push(``  [${slot.key}]``);` && |\n| &&
             `        for (const event of events) out.push(``    ${event}``);` && |\n| &&
             `      }` && |\n| &&
             `      if (!any) out.push("  (no event bindings found in the current views)");` && |\n| &&
             `      out.push("");` && |\n| &&
             `      out.push(` && |\n| &&
             `        "  Scraped from the view XML the backend sent - eB rounds a trip," +` && |\n| &&
             `          " eF is handled in the browser.",` && |\n| &&
             `      );` && |\n| &&
             `` && |\n| &&
             `      return out.join("\n");` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Actions - the response's two action lists, readable` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    function renderArg(arg) {` && |\n| &&
             `      if (arg === null) return "null";` && |\n| &&
             `      if (typeof arg === "object") {` && |\n| &&
             `        try {` && |\n| &&
             `          return truncate(JSON.stringify(arg), MAX_ARG_CHARS);` && |\n| &&
             `        } catch {` && |\n| &&
             `          return "[object]";` && |\n| &&
             `        }` && |\n| &&
             `      }` && |\n| &&
             `      return truncate(arg, MAX_ARG_CHARS);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function renderActionList(list, title) {` && |\n| &&
             `      const out = [section(title)];` && |\n| &&
             `      if (!Array.isArray(list) || !list.length) {` && |\n| &&
             `        out.push("  (none)");` && |\n| &&
             `        return out;` && |\n| &&
             `      }` && |\n| &&
             `      list.forEach((item, index) => {` && |\n| &&
             `        const number = String(index + 1).padStart(3);` && |\n| &&
             `        if (!Array.isArray(item)) {` && |\n| &&
             `          // legacy app-authored raw JS snippet, passed through untouched` && |\n| &&
             `          out.push(``${number}  [legacy JS] ${truncate(item, MAX_ARG_CHARS)}``);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        const [name, ...args] = item;` && |\n| &&
             `        out.push(``${number}  ${name}``);` && |\n| &&
             `        for (const arg of args) out.push(``       ${renderArg(arg)}``);` && |\n| &&
             `      });` && |\n| &&
             `      return out;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function formatActions() {` && |\n| &&
             `      const sAction = AppState.state.responseData?.S_FRONT?.S_ACTION;` && |\n| &&
             `      const out = ["abap2UI5 Developer Tools - Actions of the last response"];` && |\n| &&
             `      out.push("");` && |\n| &&
             `      out.push(` && |\n| &&
             `        "  T_SYSTEM runs first, in order, before the view is rendered;" +` && |\n| &&
             `          " T_CUSTOM runs last, once the DOM exists.",` && |\n| &&
             `      );` && |\n| &&
             `      out.push(` && |\n| &&
             `        ...renderActionList(sAction?.T_SYSTEM, "T_SYSTEM (view lifecycle)"),` && |\n| &&
             `      );` && |\n| &&
             `      out.push(...renderActionList(sAction?.T_CUSTOM, "T_CUSTOM (app)"));` && |\n| &&
             `      return out.join("\n");` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Messages - every backend message of the recorded session` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    function formatMessages() {` && |\n| &&
             `      const records = Recorder.getRecords();` && |\n| &&
             `      const out = ["abap2UI5 Developer Tools - Backend messages"];` && |\n| &&
             `      out.push("");` && |\n| &&
             `      out.push(` && |\n| &&
             `        "  Collected across the recorded roundtrip history, newest last -" +` && |\n| &&
             `          " a toast that has already faded is still here.",` && |\n| &&
             `      );` && |\n| &&
             `      out.push("");` && |\n| &&
             `      let any = false;` && |\n| &&
             `      for (const record of records) {` && |\n|.
    result = result &&
             `        for (const message of record.messages || []) {` && |\n| &&
             `          any = true;` && |\n| &&
             `          const kind =` && |\n| &&
             `            message.target === "MESSAGE_BOX"` && |\n| &&
             `              ? ``box.${message.method}``` && |\n| &&
             `              : "toast";` && |\n| &&
             `          out.push(` && |\n| &&
             `            ``  #${String(record.seq).padEnd(4)}${record.ts.slice(11, 19)}  `` +` && |\n| &&
             `              ``${kind.padEnd(14)}${message.text}``,` && |\n| &&
             `          );` && |\n| &&
             `        }` && |\n| &&
             `      }` && |\n| &&
             `      if (!any) out.push("  (no backend message in the recorded history)");` && |\n| &&
             `      return out.join("\n");` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Bindings - model paths, and which of them the user edited` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    // Describe a model value the way a developer scanning for "why is this` && |\n| &&
             `    // field empty" needs: type, size, and a short preview.` && |\n| &&
             `    function describeValue(value) {` && |\n| &&
             `      if (value === null) return "null";` && |\n| &&
             `      if (value === undefined) return "(absent)";` && |\n| &&
             `      if (Array.isArray(value)) {` && |\n| &&
             `        return ``table, ${value.length} row(s)``;` && |\n| &&
             `      }` && |\n| &&
             `      if (typeof value === "object") {` && |\n| &&
             `        return ``structure, ${Object.keys(value).length} field(s)``;` && |\n| &&
             `      }` && |\n| &&
             `      if (value === "") return ``${typeof value} (empty)``;` && |\n| &&
             `      return ``${typeof value}  ${truncate(value, 60)}``;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function formatSlotBindings(slotKey) {` && |\n| &&
             `      const view = ViewSlots.getView(slotKey);` && |\n| &&
             `      if (!view) return [];` && |\n| &&
             `      const model = view.getModel?.();` && |\n| &&
             `      const data = model?.getData?.();` && |\n| &&
             `      if (!data) return [];` && |\n| &&
             `      const out = [section(``Slot ${slotKey}``)];` && |\n| &&
             `      // The edited-path set the next roundtrip will ship as its delta.` && |\n| &&
             `      // Slots.trackChanges parks it on the model itself; nothing surfaces` && |\n| &&
             `      // it today, which is why "why was my edit not sent" is hard to answer.` && |\n| &&
             `      const changed = model._z2ui5ChangedPaths;` && |\n| &&
             `      const dirty = changed ? new Set(changed) : new Set();` && |\n| &&
             `      const keys = Object.keys(data).sort();` && |\n| &&
             `      if (!keys.length) out.push("  (model is empty)");` && |\n| &&
             `      for (const key of keys) {` && |\n| &&
             `        const path = ``/${key}``;` && |\n| &&
             `        // a table edit is tracked on the deep path, so mark the attribute` && |\n| &&
             `        // when any tracked path starts with it` && |\n| &&
             `        const isDirty = Array.from(dirty).some(` && |\n| &&
             `          (p) => p === path || p.startsWith(``${path}/``),` && |\n| &&
             `        );` && |\n| &&
             `        out.push(` && |\n| &&
             `          ``  ${isDirty ? "*" : " "} ${path.padEnd(30)}${describeValue(data[key])}``,` && |\n| &&
             `        );` && |\n| &&
             `      }` && |\n| &&
             `      if (dirty.size) {` && |\n| &&
             `        out.push("");` && |\n| &&
             `        out.push("  Edited paths queued for the next roundtrip:");` && |\n| &&
             `        for (const path of Array.from(dirty).sort()) out.push(``    ${path}``);` && |\n| &&
             `      }` && |\n| &&
             `      return out;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function formatBindings() {` && |\n| &&
             `      const out = ["abap2UI5 Developer Tools - Model bindings"];` && |\n| &&
             `      out.push("");` && |\n| &&
             `      out.push(` && |\n| &&
             `        "  A '*' marks an attribute the user edited: those paths travel as" +` && |\n| &&
             `          " the delta of the next roundtrip.",` && |\n| &&
             `      );` && |\n| &&
             `      out.push(` && |\n| &&
             `        "  MAIN, NEST and NEST2 share one model by UI5 propagation, so they" +` && |\n| &&
             `          " are listed once, under MAIN.",` && |\n| &&
             `      );` && |\n| &&
             `      let any = false;` && |\n| &&
             `      for (const slot of ViewSlots.slots) {` && |\n| &&
             `        // only the slots that own a model - the nested ones would repeat MAIN` && |\n| &&
             `        if (!slot.ownsModel) continue;` && |\n| &&
             `        const lines = formatSlotBindings(slot.key);` && |\n| &&
             `        if (!lines.length) continue;` && |\n| &&
             `        any = true;` && |\n| &&
             `        out.push(...lines);` && |\n| &&
             `      }` && |\n| &&
             `      if (!any) out.push("\n  (no slot carries a model yet)");` && |\n| &&
             `      return out.join("\n");` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // ABAP source helpers` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    // 1-based line number where ``eventName`` first appears in the ABAP` && |\n| &&
             `    // source, or 0 when it does not. Used to deep-link the ADT jump at the` && |\n| &&
             `    // handler of the event the last roundtrip carried, instead of at the` && |\n| &&
             `    // top of the class. Pure string work so it is unit-testable.` && |\n| &&
             `    //` && |\n| &&
             `    // Matched case-insensitively and only where the name is not part of a` && |\n| &&
             `    // longer identifier, so ``SAVE`` does not hit ``SAVE_ALL``.` && |\n| &&
             `    function findEventLine(source, eventName) {` && |\n| &&
             `      if (!source || !eventName) return 0;` && |\n| &&
             `      const lines = source.split("\n");` && |\n| &&
             `      const needle = eventName.toLowerCase();` && |\n| &&
             `      for (let i = 0; i < lines.length; i++) {` && |\n| &&
             `        const haystack = lines[i].toLowerCase();` && |\n| &&
             `        let from = haystack.indexOf(needle);` && |\n| &&
             `        while (from !== -1) {` && |\n| &&
             `          const before = haystack[from - 1];` && |\n| &&
             `          const after = haystack[from + needle.length];` && |\n| &&
             `          const isWordChar = (ch) => ch !== undefined && /[a-z0-9_]/.test(ch);` && |\n| &&
             `          if (!isWordChar(before) && !isWordChar(after)) return i + 1;` && |\n| &&
             `          from = haystack.indexOf(needle, from + 1);` && |\n| &&
             `        }` && |\n| &&
             `      }` && |\n| &&
             `      return 0;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Help - what each tab answers, and the entry points` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    // Discoverability is the real barrier here: a tab that nobody knows` && |\n| &&
             `    // exists helps nobody, and Ctrl+F12 is not guessable. Kept as text` && |\n| &&
             `    // next to the tabs it describes so it cannot drift into a wiki.` && |\n| &&
             `    const HELP = [` && |\n| &&
             `      "abap2UI5 Developer Tools",` && |\n| &&
             `      "",` && |\n| &&
             `      "Opening",` && |\n| &&
             `      "-------",` && |\n| &&
             `      "  Ctrl+F12                    open / close these tools",` && |\n| &&
             `      "  ?z2ui5-devtools=1           open them on page load (for problems",` && |\n| &&
             `      "                              that happen during startup)",` && |\n| &&
             `      "  ?z2ui5-devtools=HISTORY     open them directly on a tab, by its key",` && |\n| &&
             `      "",` && |\n| &&
             `      "Tabs - what each one answers",` && |\n| &&
             `      "----------------------------",` && |\n| &&
             `      "  Error         the last fatal error, with Retry / Restart / Logout",` && |\n| &&
             `      "  Log           the frontend error log, INCLUDING stack traces",` && |\n| &&
             `      "  Console       what you would open the browser devtools for: UI5's",` && |\n| &&
             `      "                own log (binding / control problems), uncaught errors,",` && |\n| &&
             `      "                unhandled rejections and every console.* call",` && |\n| &&
             `      "  History       every roundtrip: backend vs. render time, payload",` && |\n| &&
             `      "                sizes, draft ids - and the ones that never rendered",` && |\n| &&
             `      "  Model Diff    what the backend changed between two responses",` && |\n| &&
             `      "                (needs Record Payloads)",` && |\n| &&
             `      "  Messages      every toast / message box of the session, also the",` && |\n| &&
             `      "                ones that already faded",` && |\n| &&
             `      "  Actions       the response's T_SYSTEM / T_CUSTOM lists, readable",` && |\n| &&
             `      "  Bindings      the model attributes, and '*' on the paths that will",` && |\n| &&
             `      "                travel as the next delta",` && |\n| &&
             `      "  Picked        the last control picked with 'Pick Control'",` && |\n| &&
             `      "  Registry      shortcuts, timers, callbacks, bound backend events",` && |\n| &&
             `      "  Environment   versions, SAPUI5 vs OpenUI5, session, device, slots",` && |\n| &&
             `      "  Source Code   the running app's ABAP class (ADT opens it in a tab)",` && |\n| &&
             `      "  Request /     the raw JSON on the wire",` && |\n| &&
             `      "  Response",` && |\n| &&
             `      "  View / Popup / Popover / Nest   the view XML each slot holds",` && |\n| &&
             `      "",` && |\n| &&
             `      "Footer actions",` && |\n| &&
             `      "--------------",` && |\n| &&
             `      "  Pick Control     click any control in the app and see which ABAP",` && |\n| &&
             `      "                   attribute feeds it, with its current value",` && |\n| &&
             `      "  Record Payloads  keep request/response bodies in the history. OFF",` && |\n| &&
             `      "                   by default - it is the only part that costs real",` && |\n| &&
             `      "                   memory (2 MB budget, oldest dropped first)",` && |\n| &&
             `      "  Copy Tab         put the current tab's content on the clipboard",` && |\n| &&
             `      "  ADT              open the ABAP class, at the line of the last",` && |\n| &&
             `      "                   event when the source has been loaded",` && |\n| &&
             `      "  Export           one report over everything, with downloads",` && |\n| &&
             `      "",` && |\n| &&
             `      "On the view tabs",` && |\n| &&
             `      "----------------",` && |\n| &&
             `      "  Apply to App     render the edited XML into the running app with",` && |\n| &&
             `      "                   NO roundtrip and no activation - a local preview",` && |\n| &&
             `      "                   the next response replaces again",` && |\n| &&
             `      "  Reset            put the backend's original XML back",` && |\n| &&
             `      "",` && |\n| &&
             `      "Reporting a bug",` && |\n| &&
             `      "---------------",` && |\n| &&
             `      "  Export -> Download Report gives a text file with the environment,",` && |\n| &&
             `      "  the error, the log and the roundtrip history. With Record Payloads",` && |\n| &&
             `      "  on, Download History (JSON) additionally carries the actual",` && |\n| &&
             `      "  request/response bodies.",` && |\n| &&
             `    ].join("\n");` && |\n| &&
             `` && |\n| &&
             `    function formatHelp() {` && |\n| &&
             `      return HELP;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    return {` && |\n| &&
             `      formatEnvironment,` && |\n| &&
             `      formatHelp,` && |\n| &&
             `      formatRegistry,` && |\n| &&
             `      formatActions,` && |\n| &&
             `      formatMessages,` && |\n| &&
             `      formatBindings,` && |\n| &&
             `      findEventLine,` && |\n| &&
             `      // exposed for the unit specs` && |\n| &&
             `      _internals: { scrapeEvents, describeValue, getDistribution },` && |\n| &&
             `    };` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
