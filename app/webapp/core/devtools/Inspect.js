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
    "z2ui5/core/ViewSlots",
    "z2ui5/core/devtools/Recorder",
  ],
  (Device, AppState, Lib, ViewSlots, Recorder) => {
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

      out.push(section("View slots"));
      out.push(...formatSlots());

      return out.join("\n");
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
    // Messages - every backend message of the recorded session
    // ------------------------------------------------------------------

    function formatMessages() {
      const records = Recorder.getRecords();
      const out = ["abap2UI5 Developer Tools - Backend messages"];
      out.push("");
      out.push(
        "  Collected across the recorded roundtrip history, newest last -" +
          " a toast that has already faded is still here.",
      );
      out.push("");
      let any = false;
      for (const record of records) {
        for (const message of record.messages || []) {
          any = true;
          const kind =
            message.target === "MESSAGE_BOX"
              ? `box.${message.method}`
              : "toast";
          out.push(
            `  #${String(record.seq).padEnd(4)}${record.ts.slice(11, 19)}  ` +
              `${kind.padEnd(14)}${message.text}`,
          );
        }
      }
      if (!any) out.push("  (no backend message in the recorded history)");
      return out.join("\n");
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
      "Tabs - what each one answers",
      "----------------------------",
      "  Error         the last fatal error, with Retry / Restart / Logout",
      "  Log           the frontend error log, INCLUDING stack traces",
      "  History       every roundtrip: backend vs. render time, payload",
      "                sizes, draft ids - and the ones that never rendered",
      "  Model Diff    what the backend changed between two responses",
      "                (needs Record Payloads)",
      "  Messages      every toast / message box of the session, also the",
      "                ones that already faded",
      "  Actions       the response's T_SYSTEM / T_CUSTOM lists, readable",
      "  Bindings      the model attributes, and '*' on the paths that will",
      "                travel as the next delta",
      "  Picked        the last control picked with 'Pick Control'",
      "  Registry      shortcuts, timers, callbacks, bound backend events",
      "  Environment   versions, SAPUI5 vs OpenUI5, session, device, slots",
      "  Source Code   the running app's ABAP class (ADT opens it in a tab)",
      "  Request /     the raw JSON on the wire",
      "  Response",
      "  View / Popup / Popover / Nest   the view XML each slot holds",
      "",
      "Footer actions",
      "--------------",
      "  Pick Control     click any control in the app and see which ABAP",
      "                   attribute feeds it, with its current value",
      "  Record Payloads  keep request/response bodies in the history. OFF",
      "                   by default - it is the only part that costs real",
      "                   memory (2 MB budget, oldest dropped first)",
      "  Copy Tab         put the current tab's content on the clipboard",
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
      "  the error, the log and the roundtrip history. With Record Payloads",
      "  on, Download History (JSON) additionally carries the actual",
      "  request/response bodies.",
    ].join("\n");

    function formatHelp() {
      return HELP;
    }

    return {
      formatEnvironment,
      formatHelp,
      formatRegistry,
      formatActions,
      formatMessages,
      formatBindings,
      findEventLine,
      // exposed for the unit specs
      _internals: { scrapeEvents, describeValue, getDistribution },
    };
  },
);
