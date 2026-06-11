sap.ui.define(
  [
    "sap/ui/core/UIComponent",
    "z2ui5/model/models",
    "z2ui5/core/Server",
    "sap/ui/VersionInfo",
    "z2ui5/core/DebugTool",
    "sap/ui/core/Theming",
    "z2ui5/core/Lib",
    "z2ui5/Util",
  ],
  (
    UIComponent,
    Models,
    Server,
    VersionInfo,
    DebugTool,
    Theming,
    Lib,
    DateUtil,
  ) => {
    "use strict";

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

        this._ensureGlobalState();
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
        // Currently disabled: the popstate view restore. Its counterpart -
        // storing the rendered view/model in history.state on every
        // roundtrip (View1 _processAfterRendering) - is disabled for
        // performance reasons, so the listener would never fire with state.
        // this._installPopstateListener();

        z2ui5.oRouter = this.getRouter();
        z2ui5.oRouter.initialize();
        z2ui5.oRouter.stop();
      },

      // After the base init, ensure z2ui5 / z2ui5.oConfig exist. The
      // backend-generated HTML declares window.z2ui5 before the component
      // boots; when running standalone (local dev tooling) it does not
      // exist yet. Assign via window - a bare `z2ui5 = {}` would throw a
      // ReferenceError on an undeclared global in strict mode.
      _ensureGlobalState() {
        if (typeof z2ui5 === "undefined") window.z2ui5 = {};
        if (z2ui5.checkLocal === false) window.z2ui5 = {};
        if (typeof z2ui5.oConfig === "undefined") z2ui5.oConfig = {};
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

      // Currently not installed - see init(). Kept for re-enabling the
      // popstate view restore together with the history.state storing in
      // View1 _processAfterRendering.
      _installPopstateListener() {
        // The browser's back/forward buttons restore a previously displayed
        // view from history.state without doing a backend roundtrip.
        this._boundPopstate = (event) => {
          const state = event?.state;
          if (!state) return;

          // These flags only apply once when the state was first pushed; on
          // restore we strip them so they don't trigger again.
          if (state.response?.PARAMS) {
            delete state.response.PARAMS.SET_PUSH_STATE;
            delete state.response.PARAMS.SET_APP_STATE_ACTIVE;
          }

          if (!state.view) return;

          if (z2ui5.oController) z2ui5.oController.destroyView();
          z2ui5.oResponse = state.response;

          const displayPromise = z2ui5.oController?.displayView(
            state.view,
            state.model,
          );
          if (displayPromise?.catch) {
            displayPromise.catch((e) =>
              Lib.logError("popstate: displayView failed", e),
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
              THEME: Theming ? Theming.getTheme() : "",
            };
          }
        } catch (e) {
          Lib.logError("Component: VersionInfo load failed", e);
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
        document.removeEventListener("scroll", this._boundScroll, {
          capture: true,
        });
        // Disabled together with _installPopstateListener in init():
        // window.removeEventListener("popstate", this._boundPopstate);

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
