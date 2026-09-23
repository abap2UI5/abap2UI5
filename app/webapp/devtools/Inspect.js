// Read-only inspectors of the developer tools: Overview, Environment,
// Registry, Actions and Error, plus the ABAP-source line lookup.
//
// Like devtools/Recorder.js this module is OUTSIDE the framework: it
// only reads state other modules own (the component context's state,
// ViewSlots, the recorded history) and renders it as text for a
// developer-tools tab. Nothing here is wired into a framework code path,
// and nothing in the framework knows this file exists. Every inspector
// takes the component context first (core/Context.js): what it reports is
// the state of ONE z2ui5.Component, the one whose tools are open.
//
// The Log tab (devtools/Log.js), the Bindings tab (devtools/Bindings.js)
// and the help text (devtools/Help.js) are separate modules; their
// renderers are re-exported here so the tab registry and the dialog reach
// every inspector through one module.
//
// Everything renders to plain text rather than a control tree, because the
// same string has to serve two consumers: the CodeEditor in the dialog and
// the Export blob.
sap.ui.define(
  [
    "sap/ui/Device",
    "z2ui5/core/Lib",
    "z2ui5/core/Env",
    "z2ui5/core/ScrollFocus",
    "z2ui5/core/ViewSlots",
    "z2ui5/devtools/Recorder",
    "z2ui5/devtools/Format",
    "z2ui5/devtools/SlotXml",
    "z2ui5/devtools/Log",
    "z2ui5/devtools/Bindings",
    "z2ui5/devtools/Help",
  ],
  (
    Device,
    Lib,
    Env,
    ScrollFocus,
    ViewSlots,
    Recorder,
    Format,
    SlotXml,
    Log,
    Bindings,
    Help,
  ) => {
    "use strict";

    // Longest argument rendered inline in the action list; a view XML
    // argument is thousands of characters and would bury the structure.
    const MAX_ARG_CHARS = 160;

    // Cap for the scraped event list - a generated view can bind hundreds.
    const MAX_SCRAPED_EVENTS = 200;

    // The bootstrap attributes the Environment section reports, label first.
    const BOOTSTRAP_ATTRS = [
      ["Bootstrap theme", "theme"],
      ["Resource roots", "resourceroots"],
      ["On init", "oninit"],
      ["Compat version", "compatversion"],
      ["Async", "async"],
      ["Frame options", "frameoptions"],
      ["Binding syntax", "bindingsyntax"],
      ["Libs", "libs"],
    ];

    // All FIVE callback arrays AppState.createState declares (the state of
    // a context) - onErrorDetails
    // was missing here once, and it is the one whose absence is a defect a
    // reader would want to see: with no provider registered the fatal-error
    // overlay shows no Details button at all.
    const CALLBACK_ARRAYS = [
      "onBeforeRoundtrip",
      "onAfterRoundtrip",
      "onAfterRendering",
      "onBeforeEventFrontend",
      "onErrorDetails",
    ];

    // The event wires of a view, scanned whole: the shared regex compiled
    // once with the global flag (matchAll clones it per scan, so the
    // early exit on MAX_SCRAPED_EVENTS never leaves a lastIndex behind).
    const EVENT_CALL = new RegExp(Format.FRAMEWORK_CALL.source, "g");

    // A word character for the whole-word test of findEventLine.
    const WORD_CHAR = /[a-z0-9_]/;
    const isWordChar = (ch) => ch !== undefined && WORD_CHAR.test(ch);

    const LABEL_WIDTH = 24;

    function line(label, value) {
      const text =
        value === undefined || value === null || value === "" ? "-" : value;
      return `  ${label.padEnd(LABEL_WIDTH)}${text}`;
    }

    function yesNo(value) {
      return value ? "yes" : "no";
    }

    const { truncate, section, renderValue } = Format;

    // ------------------------------------------------------------------
    // Environment
    // ------------------------------------------------------------------

    // The bootstrap <script> of the page. Both pages abap2UI5 can run on
    // give it the id "sap-ui-bootstrap": the standalone app/webapp/index.html
    // and the HTML the backend generates (z2ui5_cl_ui5_http_handler), whose
    // `src` comes from the exit configuration. Which SDK URL a system is
    // actually configured with is the first question when a view fails to
    // load a control, and it is nowhere else to be seen.
    function bootstrapElement() {
      try {
        return /** @type {HTMLScriptElement | null} */ (
          document.getElementById("sap-ui-bootstrap")
        );
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

    function modelAttributeCount(ctx, slotKey) {
      // the TRACKED framework model - in switch mode the default model is
      // the app's OData client and this read came back empty
      const data = ViewSlots.trackedModel(
        ViewSlots.getView(ctx, slotKey),
      )?.getData?.();
      if (!data) return 0;
      return Object.keys(data).length;
    }

    function formatSlots(ctx) {
      const lines = [];
      for (const slot of ViewSlots.slots) {
        const view = ViewSlots.getView(ctx, slot.key);
        const xml = ViewSlots.getViewXml(ctx, slot.key);
        if (!view && !xml) {
          lines.push(line(slot.key, "empty"));
          continue;
        }
        const parts = [];
        parts.push(view ? "filled" : "xml only");
        if (xml) parts.push(`${xml.length} chars XML`);
        if (slot.ownsModel) {
          parts.push(`${modelAttributeCount(ctx, slot.key)} model attributes`);
        } else {
          parts.push("inherits MAIN model");
        }
        lines.push(line(slot.key, parts.join(", ")));
      }
      return lines;
    }

    function formatEnvironment(ctx) {
      const state = ctx.state;
      const oConfig = state.oConfig;
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
      out.push(line("Backend endpoint", state.url));
      out.push(line("Served by backend", yesNo(state.checkLocal)));
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
      // Theme and locale are read through the shared probes in core/Lib.js
      // (the same ones Component.init's S_UI5 block uses), not through a
      // wrapper of their own.
      out.push(line("Theme", Env.getTheme()));
      const locale = Env.getLocale();
      out.push(line("Language", locale.language));
      out.push(line("Text direction", locale.rtl ? "RTL" : "LTR"));
      out.push(line("Content density", getContentDensity()));

      out.push(...formatBootstrap(ctx));

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

      out.push(...formatFrontendInfo(ctx));

      out.push(section("View slots"));
      out.push(...formatSlots(ctx));

      return out.join("\n");
    }

    // How this page loaded UI5 and where it resolves resources from. Every
    // value is read from the LIVE page, not from what the backend says it
    // configured - which is the point: a proxy, a launchpad or a stale
    // cached page can all make these differ from the configuration.
    function formatBootstrap(ctx) {
      const out = [section("UI5 bootstrap")];
      const el = bootstrapElement();
      if (!el) {
        out.push('  (no <script id="sap-ui-bootstrap"> on this page -');
        out.push("  UI5 was started some other way, e.g. by a launchpad)");
      } else {
        // .src resolves relative to the page, so this is the absolute URL
        // the browser actually fetched the SDK from.
        out.push(line("SDK source", el.src || bootstrapAttr(el, "src")));
        for (const [label, attr] of BOOTSTRAP_ATTRS) {
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
      const cci = ctx.state.ccResourceRoot;
      const ccc = ctx.state.cccResourceRoot;
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
    function formatFrontendInfo(ctx) {
      const out = [section("Frontend info sent to the backend")];
      out.push("  (client->get( )-s_focus / -s_scroll, live for the next");
      out.push("  roundtrip - see -s_ui5 / -s_device above)");
      out.push("");

      let focus;
      let scroll;
      try {
        focus = ScrollFocus.getFocusInfo(ctx);
        scroll = ScrollFocus.getScrollInfo(ctx);
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
      // eB / eBP / eF, then the quoted event name - single, double or the
      // XML-escaped apostrophe - right after the parenthesis or as the
      // first entry of the argument array. For eBP that array sits behind
      // the $event and the veto expression (`.eBP($event,true,['X'])`), so
      // the name of every prevent-default wire went unlisted before.
      for (const match of xml.matchAll(EVENT_CALL)) {
        if (found.size >= MAX_SCRAPED_EVENTS) break;
        found.add(`${match[1]}  ${match[2]}`);
      }
      return Array.from(found).sort();
    }

    function formatShortcuts(ctx) {
      const shortcuts = ctx.state.shortcuts || {};
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

    function formatRegistry(ctx) {
      const state = ctx.state;
      const out = ["abap2UI5 Developer Tools - Registry"];

      out.push(section("Keyboard shortcuts (combo / scope / backend event)"));
      out.push(...formatShortcuts(ctx));

      out.push(section("Pending backend timers"));
      const timers = Object.keys(state.timers || {});
      out.push(timers.length ? `  ${timers.join(", ")}` : "  (none pending)");

      out.push(section("Framework callbacks registered"));
      for (const name of CALLBACK_ARRAYS) {
        out.push(line(name, (state[name] || []).length));
      }

      out.push(section("Model size limits"));
      const limits = state.viewSizeLimits || {};
      const limitKeys = Object.keys(limits);
      if (!limitKeys.length) out.push("  (UI5 default everywhere)");
      for (const key of limitKeys) out.push(line(key, limits[key]));

      out.push(section("Backend events bound in the current views"));
      let any = false;
      for (const slot of ViewSlots.slots) {
        const events = scrapeEvents(SlotXml.slotXml(ctx, slot.key));
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
      return renderValue(arg, MAX_ARG_CHARS);
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
          // not an action payload - the frontend does not run it
          out.push(`${number}  [not run] ${truncate(item, MAX_ARG_CHARS)}`);
          return;
        }
        const [name, ...args] = item;
        out.push(`${number}  ${name}`);
        for (const arg of args) out.push(`       ${renderArg(arg)}`);
      });
      return out;
    }

    function formatActions(ctx) {
      const sAction = ctx.state.responseData?.S_FRONT?.S_ACTION;
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
          if (!isWordChar(before) && !isWordChar(after)) return i + 1;
          from = haystack.indexOf(needle, from + 1);
        }
      }
      return 0;
    }

    // ------------------------------------------------------------------
    // Error - the last fatal error the overlay showed
    // ------------------------------------------------------------------

    // Title + full text of the last fatal error, so the Error tab
    // reproduces the ErrorView overlay's content. Empty when the app has
    // not hit a fatal error this session.
    function formatError(ctx) {
      const err = ctx.state.lastError;
      if (!err) return "(no fatal error captured this session)";
      return err.title ? `${err.title}\n\n${err.text}` : err.text;
    }

    // ------------------------------------------------------------------
    // Overview - the landing tab
    // ------------------------------------------------------------------

    // Where the tools used to open: on the raw response JSON, which
    // answers no question anybody arrives with. This is the replacement -
    // which app, which roundtrip, is anything broken, and where to go
    // next. Every line is a summary of a tab that holds the detail, and
    // the pointer to that tab is part of the line.
    function formatOverview(ctx) {
      const state = ctx.state;
      const responseFront = state.responseData?.S_FRONT;
      const out = ["abap2UI5 Developer Tools"];

      out.push(section("App"));
      out.push(line("App class", responseFront?.APP));
      out.push(line("Draft id", responseFront?.ID));
      out.push(
        line("Last event", state.oBody?.S_FRONT?.EVENT || "(app start)"),
      );
      out.push(line("Roundtrip in flight", yesNo(state.isBusy)));

      out.push(section("Status"));

      // The one line that decides whether this session is worth looking
      // at at all, so it is first and it names the tab.
      out.push(
        line(
          "Fatal error",
          state.lastError
            ? `YES - "${truncate(state.lastError.title || state.lastError.text, 50)}" (Problems > Error)`
            : "none this session",
        ),
      );

      const counts = Log.countLevels(Log.collectLog(ctx));
      const loud = counts.error + counts.warn;
      out.push(
        line(
          "Log",
          `${counts.error} error, ${counts.warn} warn, ${counts.info} info` +
            (loud ? "  (Problems > Log)" : ""),
        ),
      );

      const records = Recorder.getRecords(ctx);
      const last = records[records.length - 1];
      out.push(
        line(
          "Roundtrips",
          last
            ? `${records.length} recorded, last ${formatOverviewMs(last)}` +
                " (Roundtrips > History)"
            : "none recorded yet",
        ),
      );
      out.push(
        line(
          "Payload recording",
          Recorder.isRecordingPayloads()
            ? "ON - Model Diff and View Diff work"
            : "OFF - switch it on in Roundtrips for the diffs",
        ),
      );

      out.push(section("UI5"));
      /* ui5lint-disable no-globals --
       sap.ui.version is the only way to read the running UI5 version; there
       is no injected/module equivalent (core/Lib.js reads it the same way). */
      out.push(line("Version", sap.ui.version));
      /* ui5lint-enable no-globals */
      out.push(line("Distribution", getDistribution(ctx.state.oConfig.S_UI5)));
      out.push(line("Theme", Env.getTheme()));

      out.push(section("View slots"));
      out.push(...formatSlots(ctx));

      out.push(section("Getting around"));
      out.push("  Ctrl+F12          open / close these tools");
      out.push("  Search field      one term across every tab at once");
      out.push("  (i) in the footer what every tab answers");
      out.push(
        "  Report a Bug      the whole session state as a GitHub issue body",
      );

      return out.join("\n");
    }

    // The timing of one roundtrip, in the shortest form that still says
    // where the time went.
    function formatOverviewMs(record) {
      const parts = [];
      if (record.totalMs !== null && record.totalMs !== undefined) {
        parts.push(`${Math.round(record.totalMs)} ms total`);
      }
      if (record.backendMs !== null && record.backendMs !== undefined) {
        parts.push(`${Math.round(record.backendMs)} ms backend`);
      }
      const timing = parts.length ? ` ${parts.join(", ")}` : "";
      return `"${record.event || "(start)"}"${timing}`;
    }

    return {
      formatEnvironment,
      formatError,
      formatOverview,
      formatRegistry,
      formatActions,
      findEventLine,
      // the inspectors that live in their own module, reachable here so
      // the tab registry and the dialog know one module for all of them
      // (ctx first, like everything above: formatLog(ctx),
      // formatBindings(ctx, slotKey))
      formatLog: Log.formatLog,
      formatBindings: Bindings.formatBindings,
      formatHelp: Help.formatHelp,
      // exposed for the unit specs
      _internals: { scrapeEvents, getDistribution },
    };
  },
);
