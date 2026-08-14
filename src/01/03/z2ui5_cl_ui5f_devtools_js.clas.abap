* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Embedded frontend resource, generated from app/webapp/ by
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
CLASS z2ui5_cl_ui5f_devtools_js DEFINITION
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


CLASS z2ui5_cl_ui5f_devtools_js IMPLEMENTATION.

  METHOD get.

    result = `// Lifecycle facade of the developer tools - THE single entry point the` && |\n| &&
             `// framework touches.` && |\n| &&
             `//` && |\n| &&
             `// Everything the developer tools need in order to exist lives here: the` && |\n| &&
             `// Ctrl+F12 shortcut, the lazy creation of the dialog control, the` && |\n| &&
             `// roundtrip recorder's install/uninstall, the "?z2ui5-devtools=" auto` && |\n| &&
             `// open, and the handler that the fatal-error overlay's Details action` && |\n| &&
             `// runs. None of that is in a framework module any more.` && |\n| &&
             `//` && |\n| &&
             `// The whole coupling to the framework is therefore:` && |\n| &&
             `//` && |\n| &&
             `//   Component.init()  ->  DevTools.install()` && |\n| &&
             `//   Component.exit()  ->  DevTools.exit()` && |\n| &&
             `//` && |\n| &&
             `// and nothing else. No framework module names a developer-tools module,` && |\n| &&
             `// no framework state field holds a developer-tools object, and` && |\n| &&
             `// core/ErrorView.js reaches the Details action through the generic` && |\n| &&
             `// ``onErrorDetails`` callback array (AppState) that this module registers` && |\n| &&
             `// into - the overlay hides its Details button when nothing registered,` && |\n| &&
             `// so removing this folder degrades the framework gracefully instead of` && |\n| &&
             `// breaking it.` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    "z2ui5/core/AppState",` && |\n| &&
             `    "z2ui5/core/ErrorView",` && |\n| &&
             `    "z2ui5/core/Lib",` && |\n| &&
             `    "z2ui5/core/devtools/DeveloperTools",` && |\n| &&
             `    "z2ui5/core/devtools/Recorder",` && |\n| &&
             `  ],` && |\n| &&
             `  (AppState, ErrorView, Lib, DeveloperTools, Recorder) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // Query parameter that opens the developer tools on page load, so a` && |\n| &&
             `    // problem that happens during startup can be looked at at all - by` && |\n| &&
             `    // then Ctrl+F12 is too late. "?z2ui5-devtools=1" opens the default` && |\n| &&
             `    // tab, "?z2ui5-devtools=HISTORY" (any tab key) opens that one.` && |\n| &&
             `    const AUTO_OPEN_PARAM = "z2ui5-devtools";` && |\n| &&
             `` && |\n| &&
             `    // The control instance, owned HERE rather than on AppState: the` && |\n| &&
             `    // framework's state inventory has no business carrying a diagnostic` && |\n| &&
             `    // object. It is still mirrored onto the z2ui5 global under its old` && |\n| &&
             `    // name, because apps have been able to reach it there (the js_loader` && |\n| &&
             `    // popup pokes at internals) and that should keep working.` && |\n| &&
             `    let instance = null;` && |\n| &&
             `    let boundKeydown = null;` && |\n| &&
             `    let errorDetailsHook = null;` && |\n| &&
             `` && |\n| &&
             `    function publish(value) {` && |\n| &&
             `      // The public global facade is the supported way for a devtools` && |\n| &&
             `      // module to expose something to apps (core/AppState.js documents` && |\n| &&
             `      // getGlobal/setGlobal as exactly that).` && |\n| &&
             `      AppState.setGlobal("developerTools", value);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function get() {` && |\n| &&
             `      if (!instance) {` && |\n| &&
             `        instance = new DeveloperTools();` && |\n| &&
             `        publish(instance);` && |\n| &&
             `      }` && |\n| &&
             `      return instance;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function toggle() {` && |\n| &&
             `      get().toggle();` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function show(tabKey) {` && |\n| &&
             `      get().show(tabKey);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Auto open` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    function searchParams() {` && |\n| &&
             `      try {` && |\n| &&
             `        return new URLSearchParams(window.location.search);` && |\n| &&
             `      } catch {` && |\n| &&
             `        return null;` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function isAutoOpenRequested() {` && |\n| &&
             `      return Boolean(searchParams()?.has(AUTO_OPEN_PARAM));` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // The requested tab key, or "" for "just open it". Deliberately` && |\n| &&
             `    // tolerant: an unknown tab key falls back to the default tab in` && |\n| &&
             `    // DeveloperTools.show().` && |\n| &&
             `    function autoOpenTab() {` && |\n| &&
             `      const value = searchParams()?.get(AUTO_OPEN_PARAM);` && |\n| &&
             `      if (value === null || value === undefined) return "";` && |\n| &&
             `      const key = value.toUpperCase();` && |\n| &&
             `      return key === "1" || key === "X" ? "" : key;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Install / exit` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    // The fatal-error overlay's Details action. Registered as a plain` && |\n| &&
             `    // callback so core/ErrorView.js needs no knowledge of this folder:` && |\n| &&
             `    // it runs whatever is registered and hides the button when nothing` && |\n| &&
             `    // is. Reopening the overlay when the dialog closes keeps the user` && |\n| &&
             `    // from landing on the dismissed, broken app.` && |\n| &&
             `    function onErrorDetails() {` && |\n| &&
             `      const dialog = get();` && |\n| &&
             `      dialog.reopenErrorOnClose = true;` && |\n| &&
             `      dialog.show("ERROR");` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function install() {` && |\n| &&
             `      if (boundKeydown) return;` && |\n| &&
             `` && |\n| &&
             `      // Start recording roundtrips right away - a history is only worth` && |\n| &&
             `      // anything if it was collected BEFORE the problem happened, so it` && |\n| &&
             `      // cannot wait for the first Ctrl+F12. Metadata only (kilobytes)` && |\n| &&
             `      // unless the developer opts into payloads.` && |\n| &&
             `      Recorder.install();` && |\n| &&
             `` && |\n| &&
             `      errorDetailsHook = onErrorDetails;` && |\n| &&
             `      Lib.registerCallback("onErrorDetails", errorDetailsHook);` && |\n| &&
             `` && |\n| &&
             `      boundKeydown = (event) => {` && |\n| &&
             `        if (event.ctrlKey && event.key === "F12") toggle();` && |\n| &&
             `      };` && |\n| &&
             `      document.addEventListener("keydown", boundKeydown);` && |\n| &&
             `` && |\n| &&
             `      if (isAutoOpenRequested()) show(autoOpenTab() || undefined);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function exit() {` && |\n| &&
             `      if (boundKeydown) {` && |\n| &&
             `        document.removeEventListener("keydown", boundKeydown);` && |\n| &&
             `        boundKeydown = null;` && |\n| &&
             `      }` && |\n| &&
             `      if (errorDetailsHook) {` && |\n| &&
             `        Lib.unregisterCallback("onErrorDetails", errorDetailsHook);` && |\n| &&
             `        errorDetailsHook = null;` && |\n| &&
             `      }` && |\n| &&
             `      // The dialog is not an aggregation of anything the component owns,` && |\n| &&
             `      // so it would survive an FLP re-launch together with this module's` && |\n| &&
             `      // state - destroy it explicitly.` && |\n| &&
             `      if (instance) {` && |\n| &&
             `        instance.destroy();` && |\n| &&
             `        instance = null;` && |\n| &&
             `      }` && |\n| &&
             `      publish(null);` && |\n| &&
             `      Recorder.uninstall();` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    return {` && |\n| &&
             `      install,` && |\n| &&
             `      exit,` && |\n| &&
             `      toggle,` && |\n| &&
             `      show,` && |\n| &&
             `      isAutoOpenRequested,` && |\n| &&
             `      autoOpenTab,` && |\n| &&
             `      // exposed for the specs` && |\n| &&
             `      _peek: () => instance,` && |\n| &&
             `    };` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
