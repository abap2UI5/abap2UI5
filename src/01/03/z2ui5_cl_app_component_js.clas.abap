CLASS z2ui5_cl_app_component_js DEFINITION
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


CLASS z2ui5_cl_app_component_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    "sap/ui/core/UIComponent",` && |\n| &&
             `    "z2ui5/model/models",` && |\n| &&
             `    "z2ui5/core/Server",` && |\n| &&
             `    "sap/ui/VersionInfo",` && |\n| &&
             `    "z2ui5/core/DeveloperTools",` && |\n| &&
             `    "z2ui5/core/Lib",` && |\n| &&
             `    "z2ui5/core/AppState",` && |\n| &&
             `    "z2ui5/Util",` && |\n| &&
             `    "z2ui5/model/formatter",` && |\n| &&
             `    "sap/ui/core/routing/HashChanger",` && |\n| &&
             `  ],` && |\n| &&
             `  (` && |\n| &&
             `    UIComponent,` && |\n| &&
             `    Models,` && |\n| &&
             `    Server,` && |\n| &&
             `    VersionInfo,` && |\n| &&
             `    DeveloperTools,` && |\n| &&
             `    Lib,` && |\n| &&
             `    AppState,` && |\n| &&
             `    DateUtil,` && |\n| &&
             `    Formatter,` && |\n| &&
             `    HashChanger,` && |\n| &&
             `  ) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    return UIComponent.extend("z2ui5.Component", {` && |\n| &&
             `      metadata: {` && |\n| &&
             `        manifest: "json",` && |\n| &&
             `        interfaces: ["sap.ui.core.IAsyncContentCreation"],` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      init() {` && |\n| &&
             `        // The global "z2ui5" object holds the shared state for the whole` && |\n| &&
             `        // app; core/AppState owns it. initGlobal() creates the global if` && |\n| &&
             `        // needed, resets the internal state to clean defaults and provides` && |\n| &&
             `        // a fresh oConfig - so the base init() and all helpers can rely on` && |\n| &&
             `        // a fully initialized global from here on.` && |\n| &&
             `        AppState.initGlobal();` && |\n| &&
             `` && |\n| &&
             `        UIComponent.prototype.init.call(this);` && |\n| &&
             `` && |\n| &&
             `        AppState.getGlobal("oConfig").ComponentData = this.getComponentData();` && |\n| &&
             `` && |\n| &&
             `        // The date helpers are a public contract: apps use them via the` && |\n| &&
             `        // z2ui5.Util global (XML view formatter strings) or via` && |\n| &&
             `        // core:require of the z2ui5/Util module. Publish the global here -` && |\n| &&
             `        // since the custom controls were split out of App.controller.js,` && |\n| &&
             `        // nothing else loads the module eagerly anymore.` && |\n| &&
             `        AppState.setGlobal("Util", DateUtil);` && |\n| &&
             `` && |\n| &&
             `        // The curated formatter module in the standard app layout` && |\n| &&
             `        // (model/formatter.js): views wire it via core:require of` && |\n| &&
             `        // z2ui5/model/formatter; the global keeps binding strings working` && |\n| &&
             `        // on releases without core:require (< 1.74). It owns the date` && |\n| &&
             `        // helpers - Util above is the thin legacy alias re-exporting them.` && |\n| &&
             `        AppState.setGlobal("Formatter", Formatter);` && |\n| &&
             `` && |\n| &&
             `        AppState.state.oDeviceModel = Models.createDeviceModel();` && |\n| &&
             `        this.setModel(AppState.state.oDeviceModel, "device");` && |\n| &&
             `` && |\n| &&
             `        // Warm-load the messaging module so Lib.getMessaging's synchronous` && |\n| &&
             `        // sap.ui.require resolves it before the first view is displayed.` && |\n| &&
             `        // On UI5 2.x sap/ui/core/Messaging is the only messaging API (the` && |\n| &&
             `        // sap.ui.getCore().getMessageManager() fallback is gone), and` && |\n| &&
             `        // nothing else pulls the module into the graph - without this the` && |\n| &&
             `        // message> model and validation collection would silently no-op.` && |\n| &&
             `        // Only attempt it where the module exists (1.118+): on older releases` && |\n| &&
             `        // (e.g. 1.71) the require would 404 and make the ui5loader retry` && |\n| &&
             `        // loudly via synchronous XHR; there Lib.getMessaging falls back to` && |\n| &&
             `        // sap.ui.getCore().getMessageManager() instead.` && |\n| &&
             `        if (Lib.hasMessagingModule()) {` && |\n| &&
             `          sap.ui.require(` && |\n| &&
             `            ["sap/ui/core/Messaging"],` && |\n| &&
             `            () => {},` && |\n| &&
             `            () => {},` && |\n| &&
             `          );` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        this._initLaunchpad();` && |\n| &&
             `        this._initVersionInfo();` && |\n| &&
             `` && |\n| &&
             `        this._installUnloadListener();` && |\n| &&
             `        this._installDeveloperToolsShortcut();` && |\n| &&
             `        this._installScrollListener();` && |\n| &&
             `` && |\n| &&
             `        // The stopped router removed with the manifest routing section used` && |\n| &&
             `        // to initialize the HashChanger (and its underlying hasher` && |\n| &&
             `        // singleton) as a side effect. Without that init hasher never` && |\n| &&
             `        // learns the URL's current hash, so the app-state cleanup after` && |\n| &&
             `        // every roundtrip (View1._updateBrowserHistory calling` && |\n| &&
             `        // replaceHash("")) is treated as a change and rewrites the URL to` && |\n| &&
             `        // "...#" - every app start ended with a dangling "#". Initialize it` && |\n| &&
             `        // explicitly; inside the FLP the shell has already done this and` && |\n| &&
             `        // init() is a guarded no-op.` && |\n| &&
             `        HashChanger.getInstance().init();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      // Event listeners installed in init() and removed in exit()` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `      _installUnloadListener() {` && |\n| &&
             `        this._boundUnload = this._onUnload.bind(this);` && |\n| &&
             `        // Safari on iOS does not fire "beforeunload" reliably, so we use` && |\n| &&
             `        // "pagehide" there. iPads on iPadOS 13+ report a Mac user agent` && |\n| &&
             `        // ("desktop site" default) - the touch-point probe catches those,` && |\n| &&
             `        // while real Macs report 0 touch points.` && |\n| &&
             `        const isIos =` && |\n| &&
             `          /iPad|iPhone/.test(navigator.userAgent) ||` && |\n| &&
             `          (navigator.userAgent.includes("Mac") && navigator.maxTouchPoints > 1);` && |\n| &&
             `        this._unloadEvent = isIos ? "pagehide" : "beforeunload";` && |\n| &&
             `        window.addEventListener(this._unloadEvent, this._boundUnload);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _installDeveloperToolsShortcut() {` && |\n| &&
             `        // Ctrl + F12 opens / closes the in-app developer tools.` && |\n| &&
             `        this._boundKeydown = (event) => {` && |\n| &&
             `          if (event.ctrlKey && event.key === "F12") {` && |\n| &&
             `            const state = AppState.state;` && |\n| &&
             `            if (!state.developerTools)` && |\n| &&
             `              state.developerTools = new DeveloperTools();` && |\n| &&
             `            state.developerTools.toggle();` && |\n| &&
             `          }` && |\n| &&
             `        };` && |\n| &&
             `        document.addEventListener("keydown", this._boundKeydown);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _installScrollListener() {` && |\n| &&
             `        // Scroll events do not bubble, but they do trigger capture-phase` && |\n| &&
             `        // listeners on ancestors - a single document-level listener observes` && |\n| &&
             `        // every scrollable container. Server.onScrollCapture records the` && |\n| &&
             `        // last scrolled element per view slot for the S_SCROLL request info.` && |\n| &&
             `        this._boundScroll = (event) => Server.onScrollCapture(event);` && |\n| &&
             `        document.addEventListener("scroll", this._boundScroll, {` && |\n| &&
             `          capture: true,` && |\n| &&
             `          passive: true,` && |\n| &&
             `        });` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      // SAP Fiori Launchpad integration (only when running inside FLP)` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `      _initLaunchpad() {` && |\n| &&
             `        const Container = sap.ui.require("sap/ushell/Container");` && |\n| &&
             `        if (!Container) return; // not running inside the launchpad -> nothing to do` && |\n| &&
             `` && |\n| &&
             `        const launchpad = { Container };` && |\n| &&
             `        this._launchpad = launchpad;` && |\n| &&
             `        AppState.state.oLaunchpad = launchpad;` && |\n| &&
             `` && |\n| &&
             `        // The FLP services load asynchronously. By the time they resolve, the` && |\n| &&
             `        // component may already have been destroyed (e.g. user navigated away` && |\n| &&
             `        // before the services were ready). setIfAlive guards against writing` && |\n| &&
             `        // to a stale launchpad object in that case.` && |\n| &&
             `        const setIfAlive = (key, value) => {` && |\n| &&
             `          if (Lib.isAlive(this) && this._launchpad === launchpad) {` && |\n| &&
             `            launchpad[key] = value;` && |\n| &&
             `          }` && |\n| &&
             `        };` && |\n| &&
             `` && |\n| &&
             `        // ShellUIService is a UI5 service (factory` && |\n| &&
             `        // sap.ushell.ui5service.ShellUIService, declared in manifest.json),` && |\n| &&
             `        // not a Container service. Requesting it via Container.getServiceAsync` && |\n| &&
             `        // resolves to sap/ushell/services/ShellUIService.js, which does not` && |\n| &&
             `        // exist in the (ABAP) launchpad and fails with a 404. The component's` && |\n| &&
             `        // getService() honors the manifest declaration and returns the` && |\n| &&
             `        // correctly scoped instance.` && |\n| &&
             `        this.getService("ShellUIService")` && |\n| &&
             `          .then((s) => setIfAlive("ShellUIService", s))` && |\n| &&
             `          .catch((e) =>` && |\n| &&
             `            Lib.logError("Component: ShellUIService init failed", e),` && |\n| &&
             `          );` && |\n| &&
             `` && |\n| &&
             `        Container.getServiceAsync("CrossApplicationNavigation")` && |\n| &&
             `          .then((s) => setIfAlive("CrossAppNavigator", s))` && |\n| &&
             `          .catch((e) =>` && |\n| &&
             `            Lib.logError(` && |\n| &&
             `              "Component: CrossApplicationNavigation init failed",` && |\n| &&
             `              e,` && |\n| &&
             `            ),` && |\n| &&
             `          );` && |\n| &&
             `` && |\n| &&
             `        sap.ui.require(` && |\n| &&
             `          ["sap/ushell/services/AppConfiguration"],` && |\n| &&
             `          (ac) => setIfAlive("AppConfiguration", ac),` && |\n| &&
             `          (e) => Lib.logError("Component: AppConfiguration init failed", e),` && |\n| &&
             `        );` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      async _initVersionInfo() {` && |\n| &&
             `        try {` && |\n| &&
             `          const info = await VersionInfo.load();` && |\n| &&
             `          if (Lib.isAlive(this)) {` && |\n| &&
             `            AppState.getGlobal("oConfig").S_UI5 = {` && |\n| &&
             `              VERSION: info.version,` && |\n| &&
             `              BUILDTIMESTAMP: info.buildTimestamp,` && |\n| &&
             `              GAV: info.gav,` && |\n| &&
             `              THEME: this._getTheme(),` && |\n| &&
             `            };` && |\n| &&
             `          }` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("Component: VersionInfo load failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _getTheme() {` && |\n| &&
             `        // sap/ui/core/Theming only exists since UI5 1.118, so it must not be` && |\n| &&
             `        // a hard dependency of this module - older bootstraps (e.g. 1.108)` && |\n| &&
             `        // would fail to load the component. On 1.118+ the core itself loads` && |\n| &&
             `        // Theming, so the probing require finds it; otherwise fall back to` && |\n| &&
             `        // the legacy Configuration API.` && |\n| &&
             `        try {` && |\n| &&
             `          const Theming = sap.ui.require("sap/ui/core/Theming");` && |\n| &&
             `          if (Theming?.getTheme) return Theming.getTheme();` && |\n| &&
             `          /* ui5lint-disable no-globals, no-deprecated-api --` && |\n| &&
             `             deliberate fallback for UI5 releases without sap/ui/core/Theming` && |\n| &&
             `             (added in 1.118); the modern API is used in the branch above. */` && |\n| &&
             `          if (sap.ui.getCore) {` && |\n| &&
             `            return sap.ui.getCore().getConfiguration().getTheme();` && |\n| &&
             `          }` && |\n| &&
             `          /* ui5lint-enable no-globals, no-deprecated-api */` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("Component: reading theme failed", e);` && |\n| &&
             `        }` && |\n| &&
             `        return "";` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _onUnload() {` && |\n| &&
             `        window.removeEventListener(this._unloadEvent, this._boundUnload);` && |\n| &&
             `        this.destroy();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      // Component teardown` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `      exit() {` && |\n| &&
             `        window.removeEventListener(this._unloadEvent, this._boundUnload);` && |\n| &&
             `        document.removeEventListener("keydown", this._boundKeydown);` && |\n| &&
             `        document.removeEventListener("scroll", this._boundScroll, {` && |\n| &&
             `          capture: true,` && |\n| &&
             `        });` && |\n| &&
             `` && |\n| &&
             `        // The developer tools control is created lazily by the Ctrl+F12` && |\n| &&
             `        // shortcut - destroy it (which also closes its dialog) so a re-launch` && |\n| &&
             `        // (FLP) does not leak the control instance.` && |\n| &&
             `        if (AppState.state.developerTools) {` && |\n| &&
             `          AppState.state.developerTools.destroy();` && |\n| &&
             `          AppState.state.developerTools = null;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        Server.endSession();` && |\n| &&
             `` && |\n| &&
             `        // Robust launchpad teardown:` && |\n| &&
             `        //  1. Clear the FLP dirty flag so it does not carry over into the` && |\n| &&
             `        //     next app the user opens.` && |\n| &&
             `        //  2. Detach the shared launchpad object so a subsequent re-launch` && |\n| &&
             `        //     starts from a clean state and any still-pending init Promises` && |\n| &&
             `        //     become no-ops via setIfAlive().` && |\n| &&
             `        try {` && |\n| &&
             `          this._launchpad?.Container?.setDirtyFlag?.(false);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("Component: clearing FLP dirty flag failed", e);` && |\n| &&
             `        }` && |\n| &&
             `        if (AppState.state.oLaunchpad === this._launchpad) {` && |\n| &&
             `          AppState.state.oLaunchpad = null;` && |\n| &&
             `        }` && |\n| &&
             `        this._launchpad = null;` && |\n| &&
             `` && |\n| &&
             `        if (UIComponent.prototype.exit) UIComponent.prototype.exit.call(this);` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
