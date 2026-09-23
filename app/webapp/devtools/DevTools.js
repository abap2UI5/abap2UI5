// Lifecycle facade of the developer tools - THE single entry point the
// framework touches.
//
// Everything the developer tools need in order to exist lives here: the
// Ctrl+F12 shortcut, the lazy creation of the dialog control, the
// roundtrip recorder's install/uninstall, the "?z2ui5-devtools=" auto
// open, and the handler that the fatal-error overlay's Details action
// runs. None of that is in a framework module any more.
//
// The whole coupling to the framework is therefore:
//
//   Component.init()  ->  DevTools.install(ctx)
//   Component.exit()  ->  DevTools.exit(ctx)
//
// and nothing else. No framework module names a developer-tools module,
// no framework state field holds a developer-tools object, and
// core/ErrorView.js reaches the Details action through the generic
// `onErrorDetails` callback array (ctx.state) that this module registers
// into - the overlay hides its Details button when nothing registered,
// so removing this folder degrades the framework gracefully instead of
// breaking it.
//
// PER COMPONENT CONTEXT (core/Context.js): a page with two z2ui5
// components gets two independent sets of tools, and exit(ctx) tears
// down only its own. What install(ctx) owns sits on `ctx.devtools`, the
// plain record Context.create gives every context:
//
//   tools             the DeveloperTools control, null until the first
//                     open (Ctrl+F12, auto open, Details, open-on-error)
//   keydown           the Ctrl+F12 document keydown listener - also the
//                     marker that install(ctx) ran
//   errorDetailsHook  the callback registered on ctx.state.onErrorDetails
//                     for the fatal-error overlay's Details action
//   console           true while this context holds one use of the
//                     page-wide console capture (Console.install), so
//                     exit( ) gives back exactly what install( ) took
//   onConsoleError    the subscriber registered with Console.addOnError
//                     for the "open on error" option
//   recorder          the roundtrip recorder's record (devtools/Recorder.js
//                     documents its fields)
//   pickReport        the report of the last picked control of this
//                     context (devtools/Picker.js)
//
// The console capture (devtools/Console.js) is the one part that stays
// PAGE-WIDE: there is one window.console to patch, so Console counts its
// users - every install( ) here adds one, every exit( ) removes one, and
// only the first patches and the last un-patches.
//
// LAZY here means the DIALOG CONTROL, not the modules. The dependencies
// below are hard `sap.ui.define` deps on purpose, and moving them behind
// `sap.ui.require([...], cb)` would not make the cold load smaller - it
// would break the tools on every ICF deployment. Three separate reasons,
// in the order they bite:
//
//  1. There is no second delivery path. On an ABAP system every frontend
//     file arrives in ONE `sap.ui.require.preload` block inside the GET
//     response (`z2ui5_cl_ui5f_preload`, generated from this folder), and
//     the bootstrap sets `resourceroots {"z2ui5": "./"}` - the ICF node
//     itself. A module dropped from that block is then fetched from the
//     node, which answers every GET with the shell page: the loader gets
//     `text/html` where it wanted a module, the define never runs and the
//     require callback never fires. The tools would simply not open, with
//     nothing naming the cause. That frontend files are NOT served as ICF
//     resources at their raw URLs is AGENTS.md rule 18, and it is what
//     makes lazy loading a delivery question rather than a loader one.
//  2. Requiring lazily WITHOUT dropping them from the preload saves
//     nothing that is being paid - the bytes have already travelled, and
//     only the factory execution moves.
//  3. Two of the three deps have to be eager anyway, and install() says
//     why: a roundtrip history and a console capture are worth something
//     only if they were collected BEFORE the problem, so they cannot wait
//     for the first Ctrl+F12.
//
// Measured 2026-08-28: devtools/ is 32.7% of the preload's bytes, and at
// best 23.2% of it could ever be deferred (everything except Console,
// Recorder and this file). Making that real needs an on-demand delivery
// path for a module the page did not receive - a design change to the
// handler, not an edit here.
sap.ui.define(
  [
    "z2ui5/core/Lib",
    "z2ui5/devtools/Console",
    "z2ui5/devtools/DeveloperTools",
    "z2ui5/devtools/Picker",
    "z2ui5/devtools/Recorder",
  ],
  (Lib, Console, DeveloperTools, Picker, Recorder) => {
    "use strict";

    // Query parameter that opens the developer tools on page load, so a
    // problem that happens during startup can be looked at at all - by
    // then Ctrl+F12 is too late. "?z2ui5-devtools=1" opens the default
    // tab, "?z2ui5-devtools=HISTORY" (any tab key) opens that one.
    const AUTO_OPEN_PARAM = "z2ui5-devtools";

    // The record of a context's tools - see the module header. `null` for
    // a context that has none (a spec context built without one, or no
    // context at all), which every entry point below treats as "nothing
    // installed".
    function recordOf(ctx) {
      return ctx?.devtools || null;
    }

    // The control instance of a context, created on first use and handed
    // its context before anything else touches it - the dialog reads
    // `this.ctx` for everything it shows.
    function get(ctx) {
      const record = recordOf(ctx);
      if (!record) return null;
      if (!record.tools) {
        const tools = new DeveloperTools();
        tools.ctx = ctx;
        record.tools = tools;
      }
      return record.tools;
    }

    function toggle(ctx) {
      get(ctx)?.toggle();
    }

    function show(ctx, tabKey) {
      get(ctx)?.show(tabKey);
    }

    // ------------------------------------------------------------------
    // Auto open
    // ------------------------------------------------------------------

    function searchParams() {
      try {
        return new URLSearchParams(window.location.search);
      } catch {
        return null;
      }
    }

    function isAutoOpenRequested() {
      return Boolean(searchParams()?.has(AUTO_OPEN_PARAM));
    }

    // The requested tab key, or "" for "just open it". Deliberately
    // tolerant: an unknown tab key falls back to the default tab in
    // DeveloperTools.show().
    function autoOpenTab() {
      const value = searchParams()?.get(AUTO_OPEN_PARAM);
      if (value === null || value === undefined) return "";
      const key = value.toUpperCase();
      return key === "1" || key === "X" ? "" : key;
    }

    // ------------------------------------------------------------------
    // Install / exit
    // ------------------------------------------------------------------

    // The fatal-error overlay's Details action. Registered as a plain
    // callback so core/ErrorView.js needs no knowledge of this folder:
    // it runs whatever is registered and hides the button when nothing
    // is. Reopening the overlay when the dialog closes keeps the user
    // from landing on the dismissed, broken app.
    function onErrorDetails(ctx) {
      const dialog = get(ctx);
      if (!dialog) return;
      dialog.reopenErrorOnClose = true;
      dialog.show("ERROR");
    }

    function install(ctx) {
      const record = recordOf(ctx);
      if (!record || record.keydown) return;

      // Start recording roundtrips right away - a history is only worth
      // anything if it was collected BEFORE the problem happened, so it
      // cannot wait for the first Ctrl+F12. Metadata only (kilobytes)
      // unless the developer opts into payloads.
      Recorder.install(ctx);

      // Same reason as the recorder: a console message is only useful if
      // it was captured BEFORE the problem, so this cannot wait for the
      // first Ctrl+F12 either. Bounded ring of short strings, page-wide
      // and use-counted (see the module header).
      Console.install();
      record.console = true;

      // Console only announces an error when its "open on error" option
      // is on (it owns that setting), so this handler is unconditional -
      // except for the one guard that matters: never fight the user for
      // the dialog when it is already open.
      record.onConsoleError = () => {
        if (record.tools?.oDialog?.isOpen?.()) return;
        show(ctx, "LOG");
      };
      Console.addOnError(record.onConsoleError);

      record.errorDetailsHook = () => onErrorDetails(ctx);
      Lib.registerCallback(ctx, "onErrorDetails", record.errorDetailsHook);

      record.keydown = (event) => {
        if (event.ctrlKey && event.key === "F12") toggle(ctx);
      };
      document.addEventListener("keydown", record.keydown);

      if (isAutoOpenRequested()) show(ctx, autoOpenTab() || undefined);
    }

    function exit(ctx) {
      const record = recordOf(ctx);
      if (!record) return;
      if (record.keydown) {
        document.removeEventListener("keydown", record.keydown);
        record.keydown = null;
      }
      if (record.errorDetailsHook) {
        Lib.unregisterCallback(ctx, "onErrorDetails", record.errorDetailsHook);
        record.errorDetailsHook = null;
      }
      if (record.onConsoleError) {
        Console.removeOnError(record.onConsoleError);
        record.onConsoleError = null;
      }
      // The dialog is not an aggregation of anything the component owns,
      // so it would survive an FLP re-launch together with this record -
      // destroy it explicitly.
      if (record.tools) {
        record.tools.destroy();
        record.tools = null;
      }
      // Give back THIS context's use of the page-wide capture, and only
      // that: an exit that never installed must not take a use off another
      // context's install. The recorder's uninstall is per context and
      // idempotent, so a partially failed install still gets cleaned up.
      if (record.console) {
        record.console = false;
        Console.uninstall();
      }
      Recorder.uninstall(ctx);
      // A pick still running at teardown left its three capture listeners
      // (mousemove/click/keydown) on document, and the click one calls
      // preventDefault + stopPropagation - the NEXT app was then dead for
      // exactly one click, with nothing naming the cause. Only THIS
      // context's pick: a second component's pick is not ours to end.
      Picker.stop(ctx);
    }

    return {
      install,
      exit,
      toggle,
      show,
      isAutoOpenRequested,
      autoOpenTab,
    };
  },
);
