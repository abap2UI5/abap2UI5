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
//   Component.init()  ->  DevTools.install()
//   Component.exit()  ->  DevTools.exit()
//
// and nothing else. No framework module names a developer-tools module,
// no framework state field holds a developer-tools object, and
// core/ErrorView.js reaches the Details action through the generic
// `onErrorDetails` callback array (AppState) that this module registers
// into - the overlay hides its Details button when nothing registered,
// so removing this folder degrades the framework gracefully instead of
// breaking it.
sap.ui.define(
  [
    "z2ui5/core/AppState",
    "z2ui5/core/ErrorView",
    "z2ui5/core/Lib",
    "z2ui5/core/devtools/Console",
    "z2ui5/core/devtools/DeveloperTools",
    "z2ui5/core/devtools/Recorder",
  ],
  (AppState, ErrorView, Lib, Console, DeveloperTools, Recorder) => {
    "use strict";

    // Query parameter that opens the developer tools on page load, so a
    // problem that happens during startup can be looked at at all - by
    // then Ctrl+F12 is too late. "?z2ui5-devtools=1" opens the default
    // tab, "?z2ui5-devtools=HISTORY" (any tab key) opens that one.
    const AUTO_OPEN_PARAM = "z2ui5-devtools";

    // The control instance, owned HERE rather than on AppState: the
    // framework's state inventory has no business carrying a diagnostic
    // object. It is still mirrored onto the z2ui5 global under its old
    // name, because apps have been able to reach it there (the js_loader
    // popup pokes at internals) and that should keep working.
    let instance = null;
    let boundKeydown = null;
    let errorDetailsHook = null;

    function publish(value) {
      // The public global facade is the supported way for a devtools
      // module to expose something to apps (core/AppState.js documents
      // getGlobal/setGlobal as exactly that).
      AppState.setGlobal("developerTools", value);
    }

    function get() {
      if (!instance) {
        instance = new DeveloperTools();
        publish(instance);
      }
      return instance;
    }

    function toggle() {
      get().toggle();
    }

    function show(tabKey) {
      get().show(tabKey);
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
    function onErrorDetails() {
      const dialog = get();
      dialog.reopenErrorOnClose = true;
      dialog.show("ERROR");
    }

    function install() {
      if (boundKeydown) return;

      // Start recording roundtrips right away - a history is only worth
      // anything if it was collected BEFORE the problem happened, so it
      // cannot wait for the first Ctrl+F12. Metadata only (kilobytes)
      // unless the developer opts into payloads.
      Recorder.install();

      // Same reason as the recorder: a console message is only useful if
      // it was captured BEFORE the problem, so this cannot wait for the
      // first Ctrl+F12 either. Bounded ring of short strings.
      Console.install();

      // Console only announces an error when its "open on error" option
      // is on (it owns that setting), so this handler is unconditional -
      // except for the one guard that matters: never fight the user for
      // the dialog when it is already open.
      Console.setOnError(() => {
        if (instance?.oDialog?.isOpen?.()) return;
        show("LOG");
      });

      errorDetailsHook = onErrorDetails;
      Lib.registerCallback("onErrorDetails", errorDetailsHook);

      boundKeydown = (event) => {
        if (event.ctrlKey && event.key === "F12") toggle();
      };
      document.addEventListener("keydown", boundKeydown);

      if (isAutoOpenRequested()) show(autoOpenTab() || undefined);
    }

    function exit() {
      if (boundKeydown) {
        document.removeEventListener("keydown", boundKeydown);
        boundKeydown = null;
      }
      if (errorDetailsHook) {
        Lib.unregisterCallback("onErrorDetails", errorDetailsHook);
        errorDetailsHook = null;
      }
      // The dialog is not an aggregation of anything the component owns,
      // so it would survive an FLP re-launch together with this module's
      // state - destroy it explicitly.
      if (instance) {
        instance.destroy();
        instance = null;
      }
      publish(null);
      Console.uninstall();
      Recorder.uninstall();
    }

    return {
      install,
      exit,
      toggle,
      show,
      isAutoOpenRequested,
      autoOpenTab,
      // exposed for the specs
      _peek: () => instance,
    };
  },
);
