sap.ui.define(
  [
    "sap/ui/core/UIComponent",
    "z2ui5/model/models",
    "z2ui5/core/Server",
    "sap/ui/VersionInfo",
    "z2ui5/core/DebugTool",
    "z2ui5/core/Lib",
    "z2ui5/core/AppState",
    "z2ui5/Util",
    "sap/ui/core/routing/HashChanger",
  ],
  (
    UIComponent,
    Models,
    Server,
    VersionInfo,
    DebugTool,
    Lib,
    AppState,
    DateUtil,
    HashChanger,
  ) => {
    "use strict";

    return UIComponent.extend("z2ui5.Component", {
      metadata: {
        manifest: "json",
        interfaces: ["sap.ui.core.IAsyncContentCreation"],
      },

      init() {
        // The global "z2ui5" object holds the shared state for the whole
        // app; core/AppState owns it. initGlobal() creates the global if
        // needed, resets the internal state to clean defaults and provides
        // a fresh oConfig - so the base init() and all helpers can rely on
        // a fully initialized global from here on.
        AppState.initGlobal();

        UIComponent.prototype.init.call(this);

        AppState.getGlobal("oConfig").ComponentData = this.getComponentData();

        // The date helpers are a public contract: apps use them via the
        // z2ui5.Util global (XML view formatter strings) or via
        // core:require of the z2ui5/Util module. Publish the global here -
        // since the custom controls were split out of App.controller.js,
        // nothing else loads the module eagerly anymore.
        AppState.setGlobal("Util", DateUtil);

        AppState.state.oDeviceModel = Models.createDeviceModel();
        this.setModel(AppState.state.oDeviceModel, "device");

        this._initLaunchpad();
        this._initVersionInfo();

        this._installUnloadListener();
        this._installDebugToolShortcut();
        this._installScrollListener();

        // The stopped router removed with the manifest routing section used
        // to initialize the HashChanger (and its underlying hasher
        // singleton) as a side effect. Without that init hasher never
        // learns the URL's current hash, so the app-state cleanup after
        // every roundtrip (View1._updateBrowserHistory calling
        // replaceHash("")) is treated as a change and rewrites the URL to
        // "...#" - every app start ended with a dangling "#". Initialize it
        // explicitly; inside the FLP the shell has already done this and
        // init() is a guarded no-op.
        HashChanger.getInstance().init();
      },

      // ------------------------------------------------------------------
      // Event listeners installed in init() and removed in exit()
      // ------------------------------------------------------------------

      _installUnloadListener() {
        this._boundUnload = this._onUnload.bind(this);
        // Safari on iOS does not fire "beforeunload" reliably, so we use
        // "pagehide" there. iPads on iPadOS 13+ report a Mac user agent
        // ("desktop site" default) - the touch-point probe catches those,
        // while real Macs report 0 touch points.
        const isIos =
          /iPad|iPhone/.test(navigator.userAgent) ||
          (navigator.userAgent.includes("Mac") && navigator.maxTouchPoints > 1);
        this._unloadEvent = isIos ? "pagehide" : "beforeunload";
        window.addEventListener(this._unloadEvent, this._boundUnload);
      },

      _installDebugToolShortcut() {
        // Ctrl + F12 opens / closes the in-app debug tool.
        this._boundKeydown = (event) => {
          if (event.ctrlKey && event.key === "F12") {
            const state = AppState.state;
            if (!state.debugTool) state.debugTool = new DebugTool();
            state.debugTool.toggle();
          }
        };
        document.addEventListener("keydown", this._boundKeydown);
      },

      _installScrollListener() {
        // Scroll events do not bubble, but they do trigger capture-phase
        // listeners on ancestors - a single document-level listener observes
        // every scrollable container. Server.onScrollCapture records the
        // last scrolled element per view slot for the S_SCROLL request info.
        this._boundScroll = (event) => Server.onScrollCapture(event);
        document.addEventListener("scroll", this._boundScroll, {
          capture: true,
          passive: true,
        });
      },

      // ------------------------------------------------------------------
      // SAP Fiori Launchpad integration (only when running inside FLP)
      // ------------------------------------------------------------------

      _initLaunchpad() {
        const Container = sap.ui.require("sap/ushell/Container");
        if (!Container) return; // not running inside the launchpad -> nothing to do

        const launchpad = { Container };
        this._launchpad = launchpad;
        AppState.state.oLaunchpad = launchpad;

        // The FLP services load asynchronously. By the time they resolve, the
        // component may already have been destroyed (e.g. user navigated away
        // before the services were ready). setIfAlive guards against writing
        // to a stale launchpad object in that case.
        const setIfAlive = (key, value) => {
          if (Lib.isAlive(this) && this._launchpad === launchpad) {
            launchpad[key] = value;
          }
        };

        // ShellUIService is a UI5 service (factory
        // sap.ushell.ui5service.ShellUIService, declared in manifest.json),
        // not a Container service. Requesting it via Container.getServiceAsync
        // resolves to sap/ushell/services/ShellUIService.js, which does not
        // exist in the (ABAP) launchpad and fails with a 404. The component's
        // getService() honors the manifest declaration and returns the
        // correctly scoped instance.
        this.getService("ShellUIService")
          .then((s) => setIfAlive("ShellUIService", s))
          .catch((e) =>
            Lib.logError("Component: ShellUIService init failed", e),
          );

        Container.getServiceAsync("CrossApplicationNavigation")
          .then((s) => setIfAlive("CrossAppNavigator", s))
          .catch((e) =>
            Lib.logError(
              "Component: CrossApplicationNavigation init failed",
              e,
            ),
          );

        sap.ui.require(
          ["sap/ushell/services/AppConfiguration"],
          (ac) => setIfAlive("AppConfiguration", ac),
          (e) => Lib.logError("Component: AppConfiguration init failed", e),
        );
      },

      async _initVersionInfo() {
        try {
          const info = await VersionInfo.load();
          if (Lib.isAlive(this)) {
            AppState.getGlobal("oConfig").S_UI5 = {
              VERSION: info.version,
              BUILDTIMESTAMP: info.buildTimestamp,
              GAV: info.gav,
              THEME: this._getTheme(),
            };
          }
        } catch (e) {
          Lib.logError("Component: VersionInfo load failed", e);
        }
      },

      _getTheme() {
        // sap/ui/core/Theming only exists since UI5 1.118, so it must not be
        // a hard dependency of this module - older bootstraps (e.g. 1.108)
        // would fail to load the component. On 1.118+ the core itself loads
        // Theming, so the probing require finds it; otherwise fall back to
        // the legacy Configuration API.
        try {
          const Theming = sap.ui.require("sap/ui/core/Theming");
          if (Theming?.getTheme) return Theming.getTheme();
          /* ui5lint-disable no-globals, no-deprecated-api --
             deliberate fallback for UI5 releases without sap/ui/core/Theming
             (added in 1.118); the modern API is used in the branch above. */
          if (sap.ui.getCore) {
            return sap.ui.getCore().getConfiguration().getTheme();
          }
          /* ui5lint-enable no-globals, no-deprecated-api */
        } catch (e) {
          Lib.logError("Component: reading theme failed", e);
        }
        return "";
      },

      _onUnload() {
        window.removeEventListener(this._unloadEvent, this._boundUnload);
        this.destroy();
      },

      // ------------------------------------------------------------------
      // Component teardown
      // ------------------------------------------------------------------

      exit() {
        window.removeEventListener(this._unloadEvent, this._boundUnload);
        document.removeEventListener("keydown", this._boundKeydown);
        document.removeEventListener("scroll", this._boundScroll, {
          capture: true,
        });

        // The debug tool is created lazily by the Ctrl+F12 shortcut -
        // destroy it (which also closes its dialog) so a re-launch (FLP)
        // does not leak the control instance.
        if (AppState.state.debugTool) {
          AppState.state.debugTool.destroy();
          AppState.state.debugTool = null;
        }

        Server.endSession();

        // Robust launchpad teardown:
        //  1. Clear the FLP dirty flag so it does not carry over into the
        //     next app the user opens.
        //  2. Detach the shared launchpad object so a subsequent re-launch
        //     starts from a clean state and any still-pending init Promises
        //     become no-ops via setIfAlive().
        try {
          this._launchpad?.Container?.setDirtyFlag?.(false);
        } catch (e) {
          Lib.logError("Component: clearing FLP dirty flag failed", e);
        }
        if (AppState.state.oLaunchpad === this._launchpad) {
          AppState.state.oLaunchpad = null;
        }
        this._launchpad = null;

        if (UIComponent.prototype.exit) UIComponent.prototype.exit.call(this);
      },
    });
  },
);
