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
//   loading           the load of the dialog's module in flight (the
//                     devtools bundle, see below), null when none is
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
// LAZY here means the dialog control AND the modules behind it. This
// module, Console and Recorder are the EAGER half of the developer
// tools - they ride in the shell's inline preload (and in the embed
// bundle), because a roundtrip history and a console capture are worth
// something only if they were collected BEFORE the problem, so they
// cannot wait for the first Ctrl+F12. Everything else under devtools/ -
// the dialog (DeveloperTools.js and its fragment), the inspectors, the
// tabs, the picker, the live editor, the report - is the DEVTOOLS
// BUNDLE: a second generated script the backend serves on
// GET <node>?z2ui5-bundle=devtools (z2ui5_cl_ui5f_preload=>get_devtools,
// z2ui5_cl_ui5_http_handler=>_http_get_devtools - the same
// sap.ui.require.preload( ) shape as the embed bundle, with an ETag of
// its own), which requireDialog( ) below loads with a <script> element
// the first time the tools are opened. Which files are which is decided
// in tools/app2abap/trans2abap.js (DEVTOOLS_EAGER), and the generation
// refuses a module of the shell that names a bundled one as a
// sap.ui.define dependency: on an ICF deployment the resource root is
// the node, which answers every GET with the page, so a module the page
// did not carry can only arrive through that bundle - that is why the
// dependencies below name none of them, and why the dialog's class is
// reached with sap.ui.require( ) after the bundle is in. Measured
// 2026-10-10: the bundle is ~102 KB of the ~400 KB inline script
// (comment-stripped, uncompressed).
//
// Where the modules come from, by deployment (requireDialog):
//   - the page served by the backend (state.checkLocal) and an embedded
//     component (state.embedded, loaded through ?z2ui5-bundle): the
//     bundle first, from the endpoint the roundtrips go to (state.url),
//     then sap.ui.require( ) finds the modules registered;
//   - a BSP, the launchpad, `fiori run`, the standalone build: the
//     modules are there to require (the BSP serves them, the
//     Component-preload carries them) - sap.ui.require( ) first, and
//     the bundle from the manifest's endpoint only when that fails.
// A module that is loaded already (sap.ui.require( id ) answers) is
// never asked for again. Rule 13 holds either way: the bundle is a file
// of the backend's origin, allowed by script-src 'self' - no inline
// script, no eval - and the shell's CSP hash is taken over the inline
// script alone, which the bundle is not part of.
sap.ui.define(
  ["z2ui5/core/Lib", "z2ui5/devtools/Console", "z2ui5/devtools/Recorder"],
  (Lib, Console, Recorder) => {
    "use strict";

    // Query parameter that opens the developer tools on page load, so a
    // problem that happens during startup can be looked at at all - by
    // then Ctrl+F12 is too late. "?z2ui5-devtools=1" opens the default
    // tab, "?z2ui5-devtools=HISTORY" (any tab key) opens that one.
    const AUTO_OPEN_PARAM = "z2ui5-devtools";

    // The URL parameter of the backend's bundles, and the value that picks
    // the devtools bundle (z2ui5_cl_ui5_http_handler=>c_bundle_param,
    // c_bundle_devtools). Not a parameter of its own: AUTO_OPEN_PARAM is
    // on the PAGE's URL, and the page URL is the endpoint of the page the
    // backend serves, so "?z2ui5-devtools" could not have meant both.
    const BUNDLE_PARAM = "z2ui5-bundle";
    const BUNDLE_DEVTOOLS = "devtools";

    // The dialog's module, and the picker's - both in the bundle, neither
    // a dependency of this module (see the header)
    const DIALOG_MODULE = "z2ui5/devtools/DeveloperTools";
    const PICKER_MODULE = "z2ui5/devtools/Picker";

    // The record of a context's tools - see the module header. `null` for
    // a context that has none (a spec context built without one, or no
    // context at all), which every entry point below treats as "nothing
    // installed".
    function recordOf(ctx) {
      return ctx?.devtools || null;
    }

    // ------------------------------------------------------------------
    // The devtools bundle
    // ------------------------------------------------------------------

    // The URL the bundle is loaded from: the endpoint the roundtrips go to
    // (state.url - the page itself, a host's endpoint, the manifest's data
    // source), with the parameter and without the page's hash. Null when
    // no endpoint is known yet.
    function bundleUrl(ctx) {
      const base = ctx?.state?.url;
      if (!base) return null;
      try {
        const url = new URL(base, window.location.href);
        url.hash = "";
        url.searchParams.set(BUNDLE_PARAM, BUNDLE_DEVTOOLS);
        return url.href;
      } catch {
        return null;
      }
    }

    // A script of the backend's origin, loaded with a <script> element -
    // the way the embed control loads ?z2ui5-bundle. Resolves once it ran,
    // rejects when it could not be fetched.
    /** @returns {Promise<void>} */
    function loadScript(url) {
      return new Promise((resolve, reject) => {
        const script = document.createElement("script");
        script.src = url;
        script.async = true;
        script.onload = () => resolve();
        script.onerror = () =>
          reject(new Error(`the devtools bundle could not be loaded: ${url}`));
        document.head.appendChild(script);
      });
    }

    /** @returns {Promise<any[]>} */
    function requireModules(names) {
      return new Promise((resolve, reject) => {
        sap.ui.require(names, (...modules) => resolve(modules), reject);
      });
    }

    // Whether the modules have to come from the bundle BEFORE they can be
    // required: on the page the backend serves and in an embedded
    // component the resource root is the ICF node, which answers a module
    // request with the page (see the header). Everywhere else the modules
    // are served or preloaded as every other one.
    function bundleFirst(ctx) {
      const state = ctx?.state;
      return Boolean(state?.checkLocal || state?.embedded);
    }

    // The dialog's class: as it is when it is loaded already, else through
    // the bundle and sap.ui.require( ) in the order bundleFirst decides.
    // One load per context at a time (record.loading); a failed one is
    // logged, answers null, and the next open tries again.
    /** @returns {Promise<any>} */
    function requireDialog(ctx) {
      const record = recordOf(ctx);
      if (!record) return Promise.resolve(null);
      const loaded = sap.ui.require(DIALOG_MODULE);
      if (loaded) return Promise.resolve(loaded);
      if (!record.loading) {
        const fromBundle = () => {
          const url = bundleUrl(ctx);
          return url
            ? loadScript(url)
            : Promise.reject(
                new Error("no endpoint to load the devtools bundle from"),
              );
        };
        const plain = () =>
          requireModules([DIALOG_MODULE]).then(([Dialog]) => Dialog);
        const load = bundleFirst(ctx)
          ? fromBundle().then(plain)
          : plain().catch(() => fromBundle().then(plain));
        record.loading = load
          .catch((e) => {
            Lib.logError("DevTools: loading the developer tools failed", e);
            return null;
          })
          .then((Dialog) => {
            record.loading = null;
            return Dialog;
          });
      }
      return record.loading;
    }

    // The control instance of a context, created on first use and handed
    // its context before anything else touches it - the dialog reads
    // `this.ctx` for everything it shows. Null when the tools are not
    // installed (or were torn down while the bundle was loading), or when
    // the bundle could not be loaded.
    /** @returns {Promise<any>} */
    function get(ctx) {
      const record = recordOf(ctx);
      if (!record) return Promise.resolve(null);
      if (record.tools) return Promise.resolve(record.tools);
      return requireDialog(ctx).then((DeveloperTools) => {
        if (!DeveloperTools || !record.keydown) return null;
        if (!record.tools) {
          const tools = new DeveloperTools();
          tools.ctx = ctx;
          record.tools = tools;
        }
        return record.tools;
      });
    }

    // Every entry point answers the promise of its open, for a caller
    // that waits (the specs do); the shortcut and the hooks do not.
    function toggle(ctx) {
      return get(ctx).then((tools) => tools?.toggle());
    }

    function show(ctx, tabKey) {
      return get(ctx).then((tools) => tools?.show(tabKey));
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
      return get(ctx).then((dialog) => {
        if (!dialog) return;
        dialog.reopenErrorOnClose = true;
        dialog.show("ERROR");
      });
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
      //
      // Not for an EMBEDDED component (state.embedded): the capture wraps
      // the page's console and listens to the page's window, and that page
      // is a HOST's - a console line names no component, so what the tools
      // caught there was the host's own output and the host's uncaught
      // errors (secrets in a message included). They filled this app's Log
      // tab and bug report, and with "open on error" a host error opened
      // this app's tools over the host. Embedded, the Log tab has the
      // framework's own error log and the backend messages.
      if (!ctx.state?.embedded) {
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
      }

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
      // context's pick: a second component's pick is not ours to end. The
      // picker is in the bundle: a pick can only run once it is loaded,
      // and then the one-id require answers it.
      sap.ui.require(PICKER_MODULE)?.stop(ctx);
      // a bundle still loading when the tools went down creates nothing
      // (get asks for the install marker) - the next install starts over
      record.loading = null;
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
