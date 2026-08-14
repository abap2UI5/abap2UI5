// Read-only inspectors of the developer tools.
//
// Like core/devtools/Recorder.js this module is OUTSIDE the framework: it
// only reads state other modules own (AppState, ViewSlots, the recorded
// history) and renders it as text for a developer-tools tab. Nothing here
// is wired into a framework code path, and nothing in the framework knows
// this file exists.
//
// Everything renders to plain text rather than a control tree, because the
// same string has to serve two consumers: the CodeEditor in the dialog and
// the Export blob.
sap.ui.define(
  [
    "sap/ui/Device",
    "z2ui5/core/AppState",
    "z2ui5/core/Lib",
    "z2ui5/core/ScrollFocus",
    "z2ui5/core/ViewSlots",
    "z2ui5/core/devtools/Console",
    "z2ui5/core/devtools/Recorder",
  ],
  (Device, AppState, Lib, ScrollFocus, ViewSlots, Console, Recorder) => {
    "use strict";

    // Longest argument rendered inline in the action list; a view XML
    // argument is thousands of characters and would bury the structure.
    const MAX_ARG_CHARS = 160;

    // Cap for the scraped event list - a generated view can bind hundreds.
    const MAX_SCRAPED_EVENTS = 200;

    const LABEL_WIDTH = 24;

    function line(label, value) {
      const text =
        value === undefined || value === null || value === "" ? "-" : value;
      return `  ${label.padEnd(LABEL_WIDTH)}${text}`;
    }

    function section(title) {
      return `\n${title}\n${"-".repeat(title.length)}`;
    }

    function yesNo(value) {
      return value ? "yes" : "no";
    }

    function truncate(text, max) {
      const str = String(text);
      if (str.length <= max) return str;
      return `${str.slice(0, max)}... (${str.length} chars)`;
    }

    // ------------------------------------------------------------------
    // Environment
    // ------------------------------------------------------------------

    // The running theme, version-independently. sap/ui/core/Theming arrived
    // in 1.118 and is the only API left in UI5 2.x; older releases expose
    // it through the Configuration singleton.
    function getTheme() {
      const Theming = sap.ui.require("sap/ui/core/Theming");
      if (Theming?.getTheme) return Theming.getTheme();
      /* ui5lint-disable no-globals, no-deprecated-api --
       deliberate fallback for UI5 releases without sap/ui/core/Theming
       (added in 1.118); the modern API is used in the branch above. */
      if (sap.ui.getCore) {
        const config = sap.ui.getCore().getConfiguration?.();
        if (config?.getTheme) return config.getTheme();
      }
      /* ui5lint-enable no-globals, no-deprecated-api */
      return "";
    }

    // The bootstrap <script> of the page. Both pages abap2UI5 can run on
    // give it the id "sap-ui-bootstrap": the standalone app/webapp/index.html
    // and the HTML the backend generates (z2ui5_cl_ui5_http_handler), whose
    // `src` comes from the exit configuration. Which SDK URL a system is
    // actually configured with is the first question when a view fails to
    // load a control, and it is nowhere else to be seen.
    function bootstrapElement() {
      try {
        return document.getElementById("sap-ui-bootstrap");
      } catch {
        return null;
      }
    }

    function bootstrapAttr(el, name) {
      // The bootstrap attributes are written camelCase in the page
      // (data-sap-ui-compatVersion); getAttribute is case-insensitive for
      // HTML elements, so the lower-case form finds them either way.
      return el?.getAttribute?.(`data-sap-ui-${name}`) || "";
    }

    // Where the UI5 loader resolves a module namespace to. Answers "is this
    // app loading its own resources from the BSP, the standalone service or
    // a sibling add-on BSP", which a wrong resourceroot silently breaks.
    function resourceUrl(namespace) {
      try {
        return sap.ui.require?.toUrl ? sap.ui.require.toUrl(namespace) : "";
      } catch {
        return "";
      }
    }

    // Language and text direction, version-independently.
    // sap/base/i18n/Localization arrived in 1.118 and is the only API left
    // in UI5 2.x; older releases expose both through the Configuration.
    function getLocale() {
      const Localization = sap.ui.require("sap/base/i18n/Localization");
      if (Localization?.getLanguage) {
        return {
          language: Localization.getLanguage(),
          rtl: Boolean(Localization.getRTL?.()),
        };
      }
      /* ui5lint-disable no-globals, no-deprecated-api --
       deliberate fallback for UI5 releases without
       sap/base/i18n/Localization (added in 1.118); the modern API is used
       in the branch above. */
      if (sap.ui.getCore) {
        const config = sap.ui.getCore().getConfiguration?.();
        if (config?.getLanguage) {
          return {
            language: config.getLanguage(),
            rtl: Boolean(config.getRTL?.()),
          };
        }
      }
      /* ui5lint-enable no-globals, no-deprecated-api */
      return { language: "", rtl: false };
    }

    // Compact vs cozy decides control heights and is set on the body by the
    // page (or by an app) - a layout that looks wrong in one density and
    // right in the other is a classic, and invisible without this.
    function getContentDensity() {
      try {
        const classes = document.body?.classList;
        if (classes?.contains("sapUiSizeCompact")) return "Compact";
        if (classes?.contains("sapUiSizeCozy")) return "Cozy";
      } catch {
        return "";
      }
      return "(neither class set)";
    }

    // SAPUI5 and OpenUI5 ship different control libraries, and a view that
    // works on one can fail to load a module on the other - so which one is
    // running is a first-order fact when a view refuses to build. The
    // distribution is visible in the version info's group/artefact id.
    function getDistribution(sUi5) {
      const gav = sUi5?.GAV || "";
      if (!gav) return "";
      return gav.includes("com.sap.ui5") ? "SAPUI5" : "OpenUI5";
    }

    function modelAttributeCount(slotKey) {
      const data = ViewSlots.getView(slotKey)?.getModel?.()?.getData?.();
      if (!data) return 0;
      return Object.keys(data).length;
    }

    function formatSlots() {
      const lines = [];
      for (const slot of ViewSlots.slots) {
        const view = ViewSlots.getView(slot.key);
        const xml = ViewSlots.getViewXml(slot.key);
        if (!view && !xml) {
          lines.push(line(slot.key, "empty"));
          continue;
        }
        const parts = [];
        parts.push(view ? "filled" : "xml only");
        if (xml) parts.push(`${xml.length} chars XML`);
        if (slot.ownsModel) {
          parts.push(`${modelAttributeCount(slot.key)} model attributes`);
        } else {
          parts.push("inherits MAIN model");
        }
        lines.push(line(slot.key, parts.join(", ")));
      }
      return lines;
    }

    function formatEnvironment() {
      const state = AppState.state;
      const oConfig = AppState.getGlobal("oConfig") || {};
      const sUi5 = oConfig.S_UI5;
      const responseFront = state.responseData?.S_FRONT;
      const out = ["abap2UI5 Developer Tools - Environment"];

      out.push(section("App"));
      out.push(line("App class", responseFront?.APP));
      out.push(line("Rendered app", state.renderedApp));
      out.push(line("Draft id (received)", responseFront?.ID));
      out.push(line("Draft id (sent)", state.oBody?.S_FRONT?.ID));
      out.push(line("Last event", state.oBody?.S_FRONT?.EVENT));
      out.push(line("Roundtrip in flight", yesNo(state.isBusy)));

      out.push(section("Session"));
      out.push(line("sap-contextid", state.contextId));
      out.push(line("Backend endpoint", AppState.getGlobal("url")));
      out.push(
        line("Served by backend", yesNo(AppState.getGlobal("checkLocal"))),
      );
      out.push(line("Launchpad", yesNo(state.oLaunchpad)));
      out.push(line("Origin", window.location.origin));
      out.push(line("Pathname", window.location.pathname));
      out.push(line("Search", window.location.search));
      out.push(line("Hash", window.location.hash));

      out.push(section("Routing"));
      out.push(line("Hash routing", yesNo(state.navRouting)));
      out.push(line("Mode", state.navMode));
      out.push(line("Current app", state.currentApp));
      out.push(line("Current draft id", state.currentDraftId));

      out.push(section("UI5"));
      /* ui5lint-disable no-globals --
       sap.ui.version is the only way to read the running UI5 version; there
       is no injected/module equivalent (core/Lib.js reads it the same way). */
      out.push(line("Version", sap.ui.version));
      /* ui5lint-enable no-globals */
      out.push(line("Distribution", getDistribution(sUi5)));
      out.push(line("Build timestamp", sUi5?.BUILDTIMESTAMP));
      out.push(line("Theme", getTheme()));
      const locale = getLocale();
      out.push(line("Language", locale.language));
      out.push(line("Text direction", locale.rtl ? "RTL" : "LTR"));
      out.push(line("Content density", getContentDensity()));

      out.push(...formatBootstrap());

      out.push(section("Device"));
      out.push(line("System", Lib.deriveSystemType(Device.system)));
      out.push(
        line(
          "Browser",
          `${Device.browser.name || "?"} ${Device.browser.version || ""}`.trim(),
        ),
      );
      out.push(
        line(
          "OS",
          `${Device.os.name || "?"} ${Device.os.version || ""}`.trim(),
        ),
      );
      out.push(
        line(
          "Orientation",
          Device.orientation.portrait ? "portrait" : "landscape",
        ),
      );
      out.push(
        line(
          "Window",
          `${Device.resize.width || window.innerWidth} x ` +
            `${Device.resize.height || window.innerHeight}`,
        ),
      );
      out.push(line("Touch", yesNo(Device.support.touch)));
      out.push(line("Pointer", yesNo(Device.support.pointer)));
      out.push(line("Retina", yesNo(Device.support.retina)));

      out.push(...formatFrontendInfo());

      out.push(section("View slots"));
      out.push(...formatSlots());

      return out.join("\n");
    }

    // How this page loaded UI5 and where it resolves resources from. Every
    // value is read from the LIVE page, not from what the backend says it
    // configured - which is the point: a proxy, a launchpad or a stale
    // cached page can all make these differ from the configuration.
    function formatBootstrap() {
      const out = [section("UI5 bootstrap")];
      const el = bootstrapElement();
      if (!el) {
        out.push('  (no <script id="sap-ui-bootstrap"> on this page -');
        out.push("  UI5 was started some other way, e.g. by a launchpad)");
      } else {
        // .src resolves relative to the page, so this is the absolute URL
        // the browser actually fetched the SDK from.
        out.push(line("SDK source", el.src || bootstrapAttr(el, "src")));
        for (const [label, attr] of [
          ["Bootstrap theme", "theme"],
          ["Resource roots", "resourceroots"],
          ["On init", "oninit"],
          ["Compat version", "compatversion"],
          ["Async", "async"],
          ["Frame options", "frameoptions"],
          ["Binding syntax", "bindingsyntax"],
          ["Libs", "libs"],
        ]) {
          const value = bootstrapAttr(el, attr);
          if (value) out.push(line(label, truncate(value, MAX_ARG_CHARS)));
        }
      }

      out.push("");
      // The resolved roots matter more than the declared ones: this is
      // where a module request actually goes.
      out.push(line("Resource base", resourceUrl("")));
      out.push(line("z2ui5 root", resourceUrl("z2ui5")));
      // The two sibling BSPs for community controls and the customer's own
      // frontend extension. Reported only when the app set them up, since
      // a system that has neither installed should not look misconfigured.
      const cci = AppState.getGlobal("ccResourceRoot");
      const ccc = AppState.getGlobal("cccResourceRoot");
      if (cci) out.push(line("z2ui5_cci root", cci));
      if (ccc) out.push(line("z2ui5_ccc root", ccc));
      return out;
    }

    // The frontend block the framework puts on the wire - what an app reads
    // as client->get( )-s_ui5 / -s_device / -s_focus / -s_scroll and what
    // the start page's "System Information" popup shows of it. Rendered
    // here from the LIVE producers (core/ScrollFocus.js), so it is what the
    // NEXT roundtrip will send, not what the last one happened to carry.
    //
    // Focus and scroll are the interesting half: they travel on every
    // roundtrip, they decide where the caret and the scroll position end up
    // after a re-render, and nothing has ever shown them.
    function formatFrontendInfo() {
      const out = [section("Frontend info sent to the backend")];
      out.push("  (client->get( )-s_focus / -s_scroll, live for the next");
      out.push("  roundtrip - see -s_ui5 / -s_device above)");
      out.push("");

      let focus;
      let scroll;
      try {
        focus = ScrollFocus.getFocusInfo();
        scroll = ScrollFocus.getScrollInfo();
      } catch (e) {
        Lib.logError("DevTools Inspect: reading focus/scroll failed", e);
        out.push("  (focus / scroll info unavailable)");
        return out;
      }

      out.push(line("Focused control", focus?.ID));
      if (focus?.SELECTION_START !== undefined) {
        out.push(
          line("Caret", `${focus.SELECTION_START} - ${focus.SELECTION_END}`),
        );
      }
      out.push("");
      let anyScroll = false;
      for (const slot of ViewSlots.slots) {
        // getScrollInfo keys by slot key and omits slots never scrolled
        const entry = scroll?.[slot.key];
        if (!entry) continue;
        anyScroll = true;
        out.push(
          line(
            `Scroll ${slot.key}`,
            `${entry.ID || "(unnamed)"}  x ${entry.X || 0} / y ${entry.Y || 0}`,
          ),
        );
      }
      if (!anyScroll) out.push(line("Scroll", "nothing scrolled yet"));
      return out;
    }

    // ------------------------------------------------------------------
    // Registry - what the frontend currently has registered
    // ------------------------------------------------------------------

    // Backend event names bound in a view's XML. The framework binds an
    // event as `.eB(['NAME'])` / `.eF(['NAME'])` (see the backend's
    // get_event), so the names can be read back off the XML the slot was
    // filled with. Best effort by design: this is a diagnostic listing, and
    // a name it misses costs nothing but a shorter list.
    function scrapeEvents(xml) {
      if (!xml) return [];
      const found = new Set();
      // eB / eBP / eF, then an optional array bracket, then the quoted
      // event name - single, double or the XML-escaped apostrophe.
      const pattern =
        /\b(eB|eBP|eF)\s*\(\s*\[?\s*(?:&apos;|&quot;|['"])([A-Za-z0-9_.-]+)/g;
      let match = pattern.exec(xml);
      while (match !== null && found.size < MAX_SCRAPED_EVENTS) {
        found.add(`${match[1]}  ${match[2]}`);
        match = pattern.exec(xml);
      }
      return Array.from(found).sort();
    }

    function formatShortcuts() {
      const shortcuts = AppState.state.shortcuts || {};
      const combos = Object.keys(shortcuts).sort();
      if (!combos.length) return ["  (none registered)"];
      const out = [];
      for (const combo of combos) {
        const scopes = shortcuts[combo];
        for (const scope of Object.keys(scopes)) {
          const entry = scopes[scope];
          out.push(
            `  ${combo.padEnd(22)}${(scope || "(global)").padEnd(12)}` +
              `-> ${entry?.event || "?"}`,
          );
        }
      }
      return out;
    }

    function formatRegistry() {
      const state = AppState.state;
      const out = ["abap2UI5 Developer Tools - Registry"];

      out.push(section("Keyboard shortcuts (combo / scope / backend event)"));
      out.push(...formatShortcuts());

      out.push(section("Pending backend timers"));
      const timers = Object.keys(state.timers || {});
      out.push(timers.length ? `  ${timers.join(", ")}` : "  (none pending)");

      out.push(section("Framework callbacks registered"));
      for (const name of [
        "onBeforeRoundtrip",
        "onAfterRoundtrip",
        "onAfterRendering",
        "onBeforeEventFrontend",
      ]) {
        out.push(line(name, String((state[name] || []).length)));
      }

      out.push(section("Model size limits"));
      const limits = state.viewSizeLimits || {};
      const limitKeys = Object.keys(limits);
      if (!limitKeys.length) out.push("  (UI5 default everywhere)");
      for (const key of limitKeys) out.push(line(key, String(limits[key])));

      out.push(section("Backend events bound in the current views"));
      let any = false;
      for (const slot of ViewSlots.slots) {
        const xml =
          ViewSlots.getView(slot.key)?.mProperties?.viewContent ||
          ViewSlots.getViewXml(slot.key);
        const events = scrapeEvents(xml);
        if (!events.length) continue;
        any = true;
        out.push(`  [${slot.key}]`);
        for (const event of events) out.push(`    ${event}`);
      }
      if (!any) out.push("  (no event bindings found in the current views)");
      out.push("");
      out.push(
        "  Scraped from the view XML the backend sent - eB rounds a trip," +
          " eF is handled in the browser.",
      );

      return out.join("\n");
    }

    // ------------------------------------------------------------------
    // Actions - the response's two action lists, readable
    // ------------------------------------------------------------------

    function renderArg(arg) {
      if (arg === null) return "null";
      if (typeof arg === "object") {
        try {
          return truncate(JSON.stringify(arg), MAX_ARG_CHARS);
        } catch {
          return "[object]";
        }
      }
      return truncate(arg, MAX_ARG_CHARS);
    }

    function renderActionList(list, title) {
      const out = [section(title)];
      if (!Array.isArray(list) || !list.length) {
        out.push("  (none)");
        return out;
      }
      list.forEach((item, index) => {
        const number = String(index + 1).padStart(3);
        if (!Array.isArray(item)) {
          // legacy app-authored raw JS snippet, passed through untouched
          out.push(`${number}  [legacy JS] ${truncate(item, MAX_ARG_CHARS)}`);
          return;
        }
        const [name, ...args] = item;
        out.push(`${number}  ${name}`);
        for (const arg of args) out.push(`       ${renderArg(arg)}`);
      });
      return out;
    }

    function formatActions() {
      const sAction = AppState.state.responseData?.S_FRONT?.S_ACTION;
      const out = ["abap2UI5 Developer Tools - Actions of the last response"];
      out.push("");
      out.push(
        "  T_SYSTEM runs first, in order, before the view is rendered;" +
          " T_CUSTOM runs last, once the DOM exists.",
      );
      out.push(
        ...renderActionList(sAction?.T_SYSTEM, "T_SYSTEM (view lifecycle)"),
      );
      out.push(...renderActionList(sAction?.T_CUSTOM, "T_CUSTOM (app)"));
      return out.join("\n");
    }

    // ------------------------------------------------------------------
    // Log - ONE timeline of everything the app logged
    //
    // These used to be three tabs: the framework's own error log, the
    // console capture, and the backend messages. They are three views of
    // the same timeline, and splitting them forced the developer to
    // correlate three tabs by timestamp by hand - which is exactly the
    // work a log is supposed to save. Merged and sorted by time, with the
    // origin in a column, the sequence reads itself: a UI5 binding warning,
    // then the toast the user saw, then the uncaught error that followed.
    // ------------------------------------------------------------------

    const LEVEL_LABEL = {
      error: "ERROR",
      warn: "WARN ",
      info: "INFO ",
      log: "LOG  ",
      debug: "DEBUG",
    };

    // Column width of the origin marker. The longest is "rejection" at
    // nine characters, so nine would leave no separating space.
    const SOURCE_WIDTH = 10;

    // Indent of a wrapped line (a stack trace) so it lines up under the
    // message rather than under the timestamp.
    const CONTINUATION_INDENT = " ".repeat(23 + SOURCE_WIDTH);

    // The framework's own error log (Lib.logError) stores the caught error
    // alongside the message, and that is where the STACK TRACE is - the one
    // thing that says which line actually threw. Render it under its
    // message rather than dropping it.
    function frameworkEntryText(entry) {
      if (entry.error === undefined) return entry.message;
      let detail;
      if (entry.error && typeof entry.error === "object") {
        detail = entry.error.stack || entry.error.message;
      }
      if (!detail) {
        try {
          detail = String(entry.error);
        } catch {
          detail = "(error could not be rendered)";
        }
      }
      return `${entry.message}\n${detail}`;
    }

    // A message box carries its severity in the method name
    // (MessageBox.error / .warning / .success); a toast has none.
    function messageLevel(message) {
      const method = String(message.method || "").toLowerCase();
      if (method === "error" || method === "alert") return "error";
      if (method === "warning") return "warn";
      return "info";
    }

    function messageSource(message) {
      return message.target === "MESSAGE_BOX"
        ? `box.${message.method || "show"}`
        : "toast";
    }

    // Everything, in one array, oldest first. Sorted by the ISO timestamp
    // every source already carries - lexicographic order is chronological
    // for ISO strings, so no date parsing is needed.
    function collectLog() {
      const out = [];
      for (const entry of AppState.state.errors || []) {
        out.push({
          ts: entry.ts,
          level: "error",
          source: "framework",
          text: frameworkEntryText(entry),
        });
      }
      for (const entry of Console.getEntries()) {
        out.push({
          ts: entry.ts,
          level: entry.level,
          source: entry.source,
          text: entry.text,
          previousLoad: entry.previousLoad,
        });
      }
      for (const record of Recorder.getRecords()) {
        for (const message of record.messages || []) {
          out.push({
            ts: record.ts,
            level: messageLevel(message),
            source: messageSource(message),
            text: message.text,
            previousLoad: record.previousLoad,
          });
        }
      }
      out.sort((a, b) => {
        if (a.ts === b.ts) return 0;
        return a.ts < b.ts ? -1 : 1;
      });
      return out;
    }

    function countLevels(entries) {
      const out = { error: 0, warn: 0, info: 0, log: 0, debug: 0 };
      for (const entry of entries) {
        if (out[entry.level] !== undefined) out[entry.level] += 1;
      }
      return out;
    }

    function formatLog() {
      const entries = collectLog();
      const lines = ["abap2UI5 Developer Tools - Log"];
      lines.push("");
      lines.push(
        "  One timeline of everything the app logged, so the browser's own",
      );
      lines.push(
        "  devtools do not have to be open. The origin is in the third",
      );
      lines.push("  column:");
      lines.push("");
      lines.push(
        "    framework   the framework's own error log (Lib.logError)",
      );
      lines.push("    ui5         UI5's log - binding and control problems");
      lines.push("    console     a console.* call from the app or a library");
      lines.push("    uncaught    an uncaught error");
      lines.push("    rejection   an unhandled promise rejection");
      lines.push("    toast/box   a backend message the user was shown");
      lines.push("");
      const counts = countLevels(entries);
      const dropped = Console.getDropped();
      lines.push(
        `  ${entries.length} entr(ies) - ${counts.error} error,` +
          ` ${counts.warn} warn, ${counts.info} info, ${counts.log} log,` +
          ` ${counts.debug} debug` +
          (dropped ? ` (${dropped} older console entries dropped)` : ""),
      );
      lines.push("");
      if (!entries.length) {
        lines.push("  (nothing logged yet)");
        return lines.join("\n");
      }
      for (const entry of entries) {
        const label = LEVEL_LABEL[entry.level] || entry.level.toUpperCase();
        const head =
          `  ${entry.ts.slice(11, 23)}${entry.previousLoad ? "*" : " "} ` +
          `${label}  ${entry.source.padEnd(SOURCE_WIDTH)}`;
        const [first, ...rest] = String(entry.text).split("\n");
        lines.push(`${head}${first}`);
        // a stack trace keeps its own lines, indented under its message
        for (const line of rest) {
          lines.push(`${CONTINUATION_INDENT}${line.trim()}`);
        }
      }
      if (entries.some((entry) => entry.previousLoad)) {
        lines.push("");
        lines.push(
          "  A '*' after the time marks an entry of the PREVIOUS page load," +
            " carried across the reload.",
        );
      }
      return lines.join("\n");
    }

    // ------------------------------------------------------------------
    // Bindings - model paths, and which of them the user edited
    // ------------------------------------------------------------------

    // Describe a model value the way a developer scanning for "why is this
    // field empty" needs: type, size, and a short preview.
    function describeValue(value) {
      if (value === null) return "null";
      if (value === undefined) return "(absent)";
      if (Array.isArray(value)) {
        return `table, ${value.length} row(s)`;
      }
      if (typeof value === "object") {
        return `structure, ${Object.keys(value).length} field(s)`;
      }
      if (value === "") return `${typeof value} (empty)`;
      return `${typeof value}  ${truncate(value, 60)}`;
    }

    function formatSlotBindings(slotKey) {
      const view = ViewSlots.getView(slotKey);
      if (!view) return [];
      const model = view.getModel?.();
      const data = model?.getData?.();
      if (!data) return [];
      const out = [section(`Slot ${slotKey}`)];
      // The edited-path set the next roundtrip will ship as its delta.
      // Slots.trackChanges parks it on the model itself; nothing surfaces
      // it today, which is why "why was my edit not sent" is hard to answer.
      const changed = model._z2ui5ChangedPaths;
      const dirty = changed ? new Set(changed) : new Set();
      const keys = Object.keys(data).sort();
      if (!keys.length) out.push("  (model is empty)");
      for (const key of keys) {
        const path = `/${key}`;
        // a table edit is tracked on the deep path, so mark the attribute
        // when any tracked path starts with it
        const isDirty = Array.from(dirty).some(
          (p) => p === path || p.startsWith(`${path}/`),
        );
        out.push(
          `  ${isDirty ? "*" : " "} ${path.padEnd(30)}${describeValue(data[key])}`,
        );
      }
      if (dirty.size) {
        out.push("");
        out.push("  Edited paths queued for the next roundtrip:");
        for (const path of Array.from(dirty).sort()) out.push(`    ${path}`);
      }
      out.push(...formatPendingDelta(dirty, data));
      out.push(...formatBindingCheck(slotKey, data));
      out.push(...formatSizeRanking(data));
      return out;
    }

    // Absolute model paths bound in a view's XML. Only the ABSOLUTE ones
    // ("{/NAME}", "{path: '/NAME'}", "${/NAME}" inside an expression) can be
    // checked against the model - a relative binding inside an aggregation
    // template ("{COL}") resolves against the row context and says nothing
    // on its own, so it is deliberately not collected.
    //
    // Returns the top-level ATTRIBUTE of each path ("/TAB/0/COL" -> "TAB"),
    // because that is what client->_bind( ) creates and what the model has
    // as a key.
    function scrapeBindingAttributes(xml) {
      if (!xml) return [];
      const found = new Set();
      // a "/" directly after {, ${, a quote or a comma-separated path:
      // covers {/A}, {path:'/A'}, {parts:['/A','/B']}, {= ${/A} > 1 }
      const pattern = /[{$'",:[\s]\/([A-Za-z_][A-Za-z0-9_]*)/g;
      let match = pattern.exec(xml);
      while (match !== null) {
        found.add(match[1]);
        match = pattern.exec(xml);
      }
      return Array.from(found).sort();
    }

    // The check that answers "why is my field empty": every absolute path
    // the view binds, against the attributes the model actually carries. A
    // renamed ABAP attribute, a typo, or a forgotten client->_bind( ) all
    // land here, and nothing else in the tools makes them visible.
    function formatBindingCheck(slotKey, data) {
      const xml =
        ViewSlots.getView(slotKey)?.mProperties?.viewContent ||
        ViewSlots.getViewXml(slotKey);
      const bound = scrapeBindingAttributes(xml);
      if (!bound.length) return [];
      const missing = bound.filter((name) => !(name in data));
      const out = [];
      if (missing.length) {
        out.push("");
        out.push("  BOUND IN THE VIEW BUT NOT IN THE MODEL:");
        for (const name of missing) out.push(`    /${name}`);
        out.push(
          "    -> a typo, a renamed ABAP attribute, or a missing" +
            " client->_bind( ).",
        );
      }
      // The other direction is worth one line, not a list: an unbound
      // attribute is wasted payload, not a defect.
      const unused = Object.keys(data).filter((name) => !bound.includes(name));
      if (unused.length) {
        out.push("");
        out.push(
          `  ${unused.length} model attribute(s) not bound in this view:` +
            ` ${unused.slice(0, 12).join(", ")}` +
            `${unused.length > 12 ? ", ..." : ""}`,
        );
      }
      return out;
    }

    // Serialized size of one model attribute. This is the number that
    // explains a large response - and the ranking below turns "the response
    // is 800 KB" into "/T_ITEMS is 92 % of it".
    function attributeSize(value) {
      try {
        const json = JSON.stringify(value);
        return json === undefined ? 0 : json.length;
      } catch {
        return 0;
      }
    }

    function formatBytes(bytes) {
      if (bytes < 1024) return `${bytes} B`;
      if (bytes < 1024 * 1024) return `${Math.round(bytes / 1024)} KB`;
      return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
    }

    function formatSizeRanking(data) {
      const sizes = Object.keys(data)
        .map((name) => ({ name, size: attributeSize(data[name]) }))
        .sort((a, b) => b.size - a.size);
      const total = sizes.reduce((sum, entry) => sum + entry.size, 0);
      if (!total) return [];
      const out = ["", `  Model size: ${formatBytes(total)} serialized`];
      // Only the heavy end is interesting; a long tail of small scalars
      // would bury it.
      for (const entry of sizes.slice(0, 8)) {
        if (!entry.size) continue;
        const share = Math.round((entry.size * 100) / total);
        const rows = Array.isArray(data[entry.name])
          ? `, ${data[entry.name].length} row(s)`
          : "";
        out.push(
          `    ${`/${entry.name}`.padEnd(30)}${formatBytes(entry.size).padStart(8)}` +
            `  ${String(share).padStart(3)}%${rows}`,
        );
      }
      return out;
    }

    // The delta the NEXT roundtrip will actually put on the wire, built
    // with the very function the framework uses for it
    // (Lib.buildDeltaFromPaths). Answers "why does my change not arrive in
    // the backend" BEFORE the roundtrip instead of after it.
    function formatPendingDelta(dirty, data) {
      if (!dirty.size) return [];
      const out = ["", "  Delta the next roundtrip will send:"];
      try {
        const delta = Lib.buildDeltaFromPaths(dirty, data);
        const json = JSON.stringify(delta, null, 2);
        for (const line of truncate(json, 1200).split("\n")) {
          out.push(`    ${line}`);
        }
      } catch (e) {
        Lib.logError("DevTools Inspect: building the delta preview failed", e);
        out.push("    (could not be built)");
      }
      return out;
    }

    function formatBindings() {
      const out = ["abap2UI5 Developer Tools - Model bindings"];
      out.push("");
      out.push(
        "  A '*' marks an attribute the user edited: those paths travel as" +
          " the delta of the next roundtrip.",
      );
      out.push(
        "  MAIN, NEST and NEST2 share one model by UI5 propagation, so they" +
          " are listed once, under MAIN.",
      );
      let any = false;
      for (const slot of ViewSlots.slots) {
        // only the slots that own a model - the nested ones would repeat MAIN
        if (!slot.ownsModel) continue;
        const lines = formatSlotBindings(slot.key);
        if (!lines.length) continue;
        any = true;
        out.push(...lines);
      }
      if (!any) out.push("\n  (no slot carries a model yet)");
      return out.join("\n");
    }

    // ------------------------------------------------------------------
    // ABAP source helpers
    // ------------------------------------------------------------------

    // 1-based line number where `eventName` first appears in the ABAP
    // source, or 0 when it does not. Used to deep-link the ADT jump at the
    // handler of the event the last roundtrip carried, instead of at the
    // top of the class. Pure string work so it is unit-testable.
    //
    // Matched case-insensitively and only where the name is not part of a
    // longer identifier, so `SAVE` does not hit `SAVE_ALL`.
    function findEventLine(source, eventName) {
      if (!source || !eventName) return 0;
      const lines = source.split("\n");
      const needle = eventName.toLowerCase();
      for (let i = 0; i < lines.length; i++) {
        const haystack = lines[i].toLowerCase();
        let from = haystack.indexOf(needle);
        while (from !== -1) {
          const before = haystack[from - 1];
          const after = haystack[from + needle.length];
          const isWordChar = (ch) => ch !== undefined && /[a-z0-9_]/.test(ch);
          if (!isWordChar(before) && !isWordChar(after)) return i + 1;
          from = haystack.indexOf(needle, from + 1);
        }
      }
      return 0;
    }

    // ------------------------------------------------------------------
    // Help - what each tab answers, and the entry points
    // ------------------------------------------------------------------

    // Discoverability is the real barrier here: a tab that nobody knows
    // exists helps nobody, and Ctrl+F12 is not guessable. Kept as text
    // next to the tabs it describes so it cannot drift into a wiki.
    const HELP = [
      "abap2UI5 Developer Tools",
      "",
      "Opening",
      "-------",
      "  Ctrl+F12                    open / close these tools",
      "  ?z2ui5-devtools=1           open them on page load (for problems",
      "                              that happen during startup)",
      "  ?z2ui5-devtools=HISTORY     open them directly on a tab, by its key",
      "",
      "  Without a tab named, they reopen on the tab you were last on.",
      "",
      "Tabs - what each one answers",
      "----------------------------",
      "  Error         the last fatal error, with Retry / Restart / Logout",
      "  Log           ONE timeline of everything logged: the framework's",
      "                own error log (with stack traces), UI5's log (binding",
      "                and control problems), uncaught errors, unhandled",
      "                rejections, every console.* call, and the backend",
      "                messages the user was shown - so the browser's own",
      "                devtools do not have to be open",
      "  History       every roundtrip: backend vs. render time, payload",
      "                sizes, draft ids - and the ones that never rendered",
      "  Model Diff    what the backend changed between two responses",
      "                (needs Record Payloads)",
      "  View Diff     what changed in the view XML between two rebuilds",
      "                (needs Record Payloads)",
      "  Search        one term across EVERY tab at once - answers 'where",
      "                does /CUSTOMER appear?' without opening each tab",
      "  Actions       the response's T_SYSTEM / T_CUSTOM lists, readable",
      "  Bindings      the model attributes, '*' on the paths that will",
      "                travel as the next delta, the delta itself, the paths",
      "                bound in the view that the model does NOT have (the",
      "                usual cause of an empty field), and the attributes",
      "                ranked by size (the usual cause of a huge response)",
      "  Picked        the last control picked with 'Pick Control'",
      "  Registry      shortcuts, timers, callbacks, bound backend events",
      "  Environment   versions, SAPUI5 vs OpenUI5, the SDK url the page",
      "                bootstrapped from and its resource roots, theme,",
      "                language, content density, session, device, the",
      "                focus/scroll block sent on every roundtrip, slots",
      "  Source Code   the running app's ABAP class (ADT opens it in a tab)",
      "  Request /     the raw JSON on the wire",
      "  Response",
      "  View / Popup / Popover / Nest   the view XML each slot holds",
      "",
      "In the tabs themselves",
      "----------------------",
      "  Search tab       the search field",
      "  Picked tab       'Pick Control' - click any control in the app and",
      "                   see which ABAP attribute feeds it, with its",
      "                   current value",
      "  History tab      'Record Payloads' - keep request/response bodies.",
      "                   OFF by default: it is the only part that costs",
      "                   real memory (2 MB budget, oldest dropped first).",
      "                   The Model Diff and View Diff need it",
      "",
      "Footer actions",
      "--------------",
      "  (i)              this help",
      "  Copy Tab         put the current tab's content on the clipboard",
      "  Open on Error    pop these tools open on the Log tab as soon as",
      "                   anything logs at error level. Off by default",
      "  ADT              open the ABAP class, at the line of the last",
      "                   event when the source has been loaded",
      "  Export           one report over everything, with downloads",
      "",
      "On the view tabs",
      "----------------",
      "  Apply to App     render the edited XML into the running app with",
      "                   NO roundtrip and no activation - a local preview",
      "                   the next response replaces again",
      "  Reset            put the backend's original XML back",
      "",
      "Reporting a bug",
      "---------------",
      "  Export -> Download Report gives a text file with the environment,",
      "  the error, the log and the roundtrip history. Copy as Markdown puts",
      "  the same content on the clipboard as a GitHub-ready issue body.",
      "  With Record Payloads on, Download History (JSON) additionally",
      "  carries the actual request/response bodies.",
      "",
      "  The console errors and the roundtrip history survive a page reload",
      "  (sessionStorage), so an app that died and was reloaded keeps its",
      "  evidence - those rows are marked with a '*'.",
    ].join("\n");

    function formatHelp() {
      return HELP;
    }

    return {
      formatEnvironment,
      formatHelp,
      formatRegistry,
      formatActions,
      formatLog,
      formatBindings,
      findEventLine,
      // exposed for the unit specs
      _internals: {
        scrapeEvents,
        scrapeBindingAttributes,
        describeValue,
        getDistribution,
      },
    };
  },
);
