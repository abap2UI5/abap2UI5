sap.ui.define(
  [
    "sap/ui/core/UIComponent",
    "z2ui5/model/models",
    "z2ui5/cc/Server",
    "sap/ui/VersionInfo",
    "z2ui5/cc/DebugTool",
    "sap/ui/core/Theming",
  ],
  (UIComponent, Models, Server, VersionInfo, DebugTool, Theming) => {
    "use strict";

    // Append an entry to the global error log. We create the array on first use.
    function logError(message, error) {
      if (!z2ui5.errors) z2ui5.errors = [];
      z2ui5.errors.push({
        message: message,
        error: error,
        ts: new Date().toISOString(),
      });
    }

    return UIComponent.extend("z2ui5.Component", {
      metadata: {
        manifest: "json",
        interfaces: ["sap.ui.core.IAsyncContentCreation"],
      },

      init() {
        // The global "z2ui5" object holds shared state for the whole app. When
        // the component is (re-)initialized we make sure oConfig exists so the
        // base init() and our helpers can rely on it.
        if (typeof z2ui5 !== "undefined") z2ui5.oConfig = {};

        UIComponent.prototype.init.call(this);

        // After the base init, ensure z2ui5 / z2ui5.oConfig still exist. When
        // running locally without the SAP launchpad the global is re-created.
        if (typeof z2ui5 === "undefined") z2ui5 = {};
        if (z2ui5.checkLocal === false) z2ui5 = {};
        if (typeof z2ui5.oConfig === "undefined") z2ui5.oConfig = {};
        z2ui5.oConfig.ComponentData = this.getComponentData();

        z2ui5.oDeviceModel = Models.createDeviceModel();
        this.setModel(z2ui5.oDeviceModel, "device");

        this._initLaunchpad();
        this._initVersionInfo();

        this._installUnloadListener();
        this._installDebugToolShortcut();
        this._installPopstateListener();

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

      _installPopstateListener() {
        // The browser's back/forward buttons restore a previously displayed
        // view from history.state without doing a backend roundtrip.
        this._boundPopstate = (event) => {
          const state = event && event.state;
          if (!state) return;

          // These flags only apply once when the state was first pushed; on
          // restore we strip them so they don't trigger again.
          if (state.response && state.response.PARAMS) {
            delete state.response.PARAMS.SET_PUSH_STATE;
            delete state.response.PARAMS.SET_APP_STATE_ACTIVE;
          }

          if (!state.view) return;

          if (z2ui5.oController) z2ui5.oController.ViewDestroy();
          z2ui5.oResponse = state.response;

          const displayPromise =
            z2ui5.oController &&
            z2ui5.oController.displayView(state.view, state.model);
          if (displayPromise && displayPromise.catch) {
            displayPromise.catch((e) =>
              logError("popstate: displayView failed", e),
            );
          }
        };
        window.addEventListener("popstate", this._boundPopstate);
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
          const stillAlive = !this.isDestroyed || !this.isDestroyed();
          if (stillAlive && this._launchpad === launchpad) {
            launchpad[key] = value;
          }
        };

        Container.getServiceAsync("ShellUIService")
          .then((s) => setIfAlive("ShellUIService", s))
          .catch((e) => logError("Component: ShellUIService init failed", e));

        Container.getServiceAsync("CrossApplicationNavigation")
          .then((s) => setIfAlive("CrossAppNavigator", s))
          .catch((e) =>
            logError("Component: CrossApplicationNavigation init failed", e),
          );

        sap.ui.require(
          ["sap/ushell/services/AppConfiguration"],
          (ac) => setIfAlive("AppConfiguration", ac),
          (e) => logError("Component: AppConfiguration init failed", e),
        );
      },

      async _initVersionInfo() {
        try {
          const info = await VersionInfo.load();
          const stillAlive = !this.isDestroyed || !this.isDestroyed();
          if (stillAlive) {
            z2ui5.oConfig.S_UI5 = {
              VERSION: info.version,
              BUILDTIMESTAMP: info.buildTimestamp,
              GAV: info.gav,
              THEME: Theming ? Theming.getTheme() : "",
            };
          }
        } catch (e) {
          logError("Component: VersionInfo load failed", e);
        }
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
        window.removeEventListener("popstate", this._boundPopstate);

        Server.endSession();

        // Robust launchpad teardown:
        //  1. Clear the FLP dirty flag so it does not carry over into the
        //     next app the user opens.
        //  2. Detach the shared launchpad object so a subsequent re-launch
        //     starts from a clean state and any still-pending init Promises
        //     become no-ops via setIfAlive().
        try {
          const setDirtyFlag =
            this._launchpad &&
            this._launchpad.Container &&
            this._launchpad.Container.setDirtyFlag;
          if (setDirtyFlag) setDirtyFlag.call(this._launchpad.Container, false);
        } catch (e) {
          logError("Component: clearing FLP dirty flag failed", e);
        }
        if (z2ui5.oLaunchpad === this._launchpad) z2ui5.oLaunchpad = null;
        this._launchpad = null;

        if (UIComponent.prototype.exit) UIComponent.prototype.exit.call(this);
      },
    });
  },
);
