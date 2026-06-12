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

        z2ui5.oConfig.ComponentData = this.getComponentData();

        // The date helpers are a public contract: apps use them via the
        // z2ui5.Util global (XML view formatter strings) or via
        // core:require of the z2ui5/Util module. Publish the global here -
        // since the custom controls were split out of App.controller.js,
        // nothing else loads the module eagerly anymore.
        z2ui5.Util = DateUtil;

        z2ui5.oDeviceModel = Models.createDeviceModel();
        this.setModel(z2ui5.oDeviceModel, "device");

        this._initLaunchpad();
        this._initVersionInfo();

        this._installUnloadListener();
        this._installDebugToolShortcut();
        this._installScrollListener();

        z2ui5.oRouter = this.getRouter();
        z2ui5.oRouter.initialize();
        z2ui5.oRouter.stop();
      },

      // ------------------------------------------------------------------
      // Event listeners installed in init() and removed in exit()
      // ------------------------------------------------------------------

      _installUnloadListener() {
        this._boundUnload = this._onUnload.bind(this);
        // Safari on iOS does not fire "beforeunload" reliably, so we use
        // "pagehide" there.
        const isIos = /iPad|iPhone/.test(navigator.userAgent);
        this._unloadEvent = isIos ? "pagehide" : "beforeunload";
        window.addEventListener(this._unloadEvent, this._boundUnload);
      },

      _installDebugToolShortcut() {
        // Ctrl + F12 opens / closes the in-app debug tool.
        this._boundKeydown = (zEvent) => {
          if (zEvent.ctrlKey && zEvent.key === "F12") {
            if (!z2ui5.debugTool) z2ui5.debugTool = new DebugTool();
            z2ui5.debugTool.toggle();
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
        z2ui5.oLaunchpad = launchpad;

        // The FLP services load asynchronously. By the time they resolve, the
        // component may already have been destroyed (e.g. user navigated away
        // before the services were ready). setIfAlive guards against writing
        // to a stale launchpad object in that case.
        const setIfAlive = (key, value) => {
          if (Lib.isAlive(this) && this._launchpad === launchpad) {
            launchpad[key] = value;
          }
        };

        Container.getServiceAsync("ShellUIService")
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
            z2ui5.oConfig.S_UI5 = {
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
          if (sap.ui.getCore) {
            return sap.ui.getCore().getConfiguration().getTheme();
          }
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

        Server.endSession();

        // Robust launchpad teardown:
        //  1. Clear the FLP dirty flag so it does not carry over into the
        //     next app the user opens.
        //  2. Detach the shared launchpad object so a subsequent re-launch
        //     starts from a clean state and any still-pending init Promises
        //     become no-ops via setIfAlive().
        try {
          const setDirtyFlag =
            this._launchpad?.Container &&
            this._launchpad.Container.setDirtyFlag;
          if (setDirtyFlag) setDirtyFlag.call(this._launchpad.Container, false);
        } catch (e) {
          Lib.logError("Component: clearing FLP dirty flag failed", e);
        }
        if (z2ui5.oLaunchpad === this._launchpad) z2ui5.oLaunchpad = null;
        this._launchpad = null;

        if (UIComponent.prototype.exit) UIComponent.prototype.exit.call(this);
      },
    });
  },
);
