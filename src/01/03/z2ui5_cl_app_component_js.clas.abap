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
             `    "z2ui5/cc/Server",` && |\n| &&
             `    "sap/ui/VersionInfo",` && |\n| &&
             `    "z2ui5/cc/DebugTool",` && |\n| &&
             `    "sap/ui/core/Theming",` && |\n| &&
             `  ],` && |\n| &&
             `  (UIComponent, Models, Server, VersionInfo, DebugTool, Theming) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // Append an entry to the global error log. We create the array on first use.` && |\n| &&
             `    function logError(message, error) {` && |\n| &&
             `      if (!z2ui5.errors) z2ui5.errors = [];` && |\n| &&
             `      z2ui5.errors.push({` && |\n| &&
             `        message: message,` && |\n| &&
             `        error: error,` && |\n| &&
             `        ts: new Date().toISOString(),` && |\n| &&
             `      });` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    return UIComponent.extend("z2ui5.Component", {` && |\n| &&
             `      metadata: {` && |\n| &&
             `        manifest: "json",` && |\n| &&
             `        interfaces: ["sap.ui.core.IAsyncContentCreation"],` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      init() {` && |\n| &&
             `        // The global "z2ui5" object holds shared state for the whole app. When` && |\n| &&
             `        // the component is (re-)initialized we make sure oConfig exists so the` && |\n| &&
             `        // base init() and our helpers can rely on it.` && |\n| &&
             `        if (typeof z2ui5 !== "undefined") z2ui5.oConfig = {};` && |\n| &&
             `` && |\n| &&
             `        UIComponent.prototype.init.call(this);` && |\n| &&
             `` && |\n| &&
             `        // After the base init, ensure z2ui5 / z2ui5.oConfig still exist. When` && |\n| &&
             `        // running locally without the SAP launchpad the global is re-created.` && |\n| &&
             `        if (typeof z2ui5 === "undefined") z2ui5 = {};` && |\n| &&
             `        if (z2ui5.checkLocal === false) z2ui5 = {};` && |\n| &&
             `        if (typeof z2ui5.oConfig === "undefined") z2ui5.oConfig = {};` && |\n| &&
             `` && |\n| &&
             `        z2ui5.oDeviceModel = Models.createDeviceModel();` && |\n| &&
             `        this.setModel(z2ui5.oDeviceModel, "device");` && |\n| &&
             `` && |\n| &&
             `        z2ui5.oConfig.ComponentData = this.getComponentData();` && |\n| &&
             `` && |\n| &&
             `        this._initLaunchpad();` && |\n| &&
             `        this._initVersionInfo();` && |\n| &&
             `` && |\n| &&
             `        this._installUnloadListener();` && |\n| &&
             `        this._installDebugToolShortcut();` && |\n| &&
             `        this._installPopstateListener();` && |\n| &&
             `` && |\n| &&
             `        z2ui5.oRouter = this.getRouter();` && |\n| &&
             `        z2ui5.oRouter.initialize();` && |\n| &&
             `        z2ui5.oRouter.stop();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      // Event listeners installed in init() and removed in exit()` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `      _installUnloadListener() {` && |\n| &&
             `        this._boundUnload = this._onUnload.bind(this);` && |\n| &&
             `        // Safari on iOS does not fire "beforeunload" reliably, so we use` && |\n| &&
             `        // "pagehide" there.` && |\n| &&
             `        const isIos = /iPad|iPhone/.test(navigator.userAgent);` && |\n| &&
             `        this._unloadEvent = isIos ? "pagehide" : "beforeunload";` && |\n| &&
             `        window.addEventListener(this._unloadEvent, this._boundUnload);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _installDebugToolShortcut() {` && |\n| &&
             `        // Ctrl + F12 opens / closes the in-app debug tool.` && |\n| &&
             `        this._boundKeydown = (zEvent) => {` && |\n| &&
             `          if (zEvent.ctrlKey && zEvent.key === "F12") {` && |\n| &&
             `            if (!z2ui5.debugTool) z2ui5.debugTool = new DebugTool();` && |\n| &&
             `            z2ui5.debugTool.toggle();` && |\n| &&
             `          }` && |\n| &&
             `        };` && |\n| &&
             `        document.addEventListener("keydown", this._boundKeydown);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _installPopstateListener() {` && |\n| &&
             `        // The browser's back/forward buttons restore a previously displayed` && |\n| &&
             `        // view from history.state without doing a backend roundtrip.` && |\n| &&
             `        this._boundPopstate = (event) => {` && |\n| &&
             `          const state = event && event.state;` && |\n| &&
             `          if (!state) return;` && |\n| &&
             `` && |\n| &&
             `          // These flags only apply once when the state was first pushed; on` && |\n| &&
             `          // restore we strip them so they don't trigger again.` && |\n| &&
             `          if (state.response && state.response.PARAMS) {` && |\n| &&
             `            delete state.response.PARAMS.SET_PUSH_STATE;` && |\n| &&
             `            delete state.response.PARAMS.SET_APP_STATE_ACTIVE;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          if (!state.view) return;` && |\n| &&
             `` && |\n| &&
             `          if (z2ui5.oController) z2ui5.oController.ViewDestroy();` && |\n| &&
             `          z2ui5.oResponse = state.response;` && |\n| &&
             `` && |\n| &&
             `          const displayPromise =` && |\n| &&
             `            z2ui5.oController &&` && |\n| &&
             `            z2ui5.oController.displayView(state.view, state.model);` && |\n| &&
             `          if (displayPromise && displayPromise.catch) {` && |\n| &&
             `            displayPromise.catch((e) =>` && |\n| &&
             `              logError("popstate: displayView failed", e),` && |\n| &&
             `            );` && |\n| &&
             `          }` && |\n| &&
             `        };` && |\n| &&
             `        window.addEventListener("popstate", this._boundPopstate);` && |\n| &&
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
             `        z2ui5.oLaunchpad = launchpad;` && |\n| &&
             `` && |\n| &&
             `        // The FLP services load asynchronously. By the time they resolve, the` && |\n| &&
             `        // component may already have been destroyed (e.g. user navigated away` && |\n| &&
             `        // before the services were ready). setIfAlive guards against writing` && |\n| &&
             `        // to a stale launchpad object in that case.` && |\n| &&
             `        const setIfAlive = (key, value) => {` && |\n| &&
             `          const stillAlive = !this.isDestroyed || !this.isDestroyed();` && |\n| &&
             `          if (stillAlive && this._launchpad === launchpad) {` && |\n| &&
             `            launchpad[key] = value;` && |\n| &&
             `          }` && |\n| &&
             `        };` && |\n| &&
             `` && |\n| &&
             `        Container.getServiceAsync("ShellUIService")` && |\n| &&
             `          .then((s) => setIfAlive("ShellUIService", s))` && |\n| &&
             `          .catch((e) => logError("Component: ShellUIService init failed", e));` && |\n| &&
             `` && |\n| &&
             `        Container.getServiceAsync("CrossApplicationNavigation")` && |\n| &&
             `          .then((s) => setIfAlive("CrossAppNavigator", s))` && |\n| &&
             `          .catch((e) =>` && |\n| &&
             `            logError("Component: CrossApplicationNavigation init failed", e),` && |\n| &&
             `          );` && |\n| &&
             `` && |\n| &&
             `        sap.ui.require(` && |\n| &&
             `          ["sap/ushell/services/AppConfiguration"],` && |\n| &&
             `          (ac) => setIfAlive("AppConfiguration", ac),` && |\n| &&
             `          (e) => logError("Component: AppConfiguration init failed", e),` && |\n| &&
             `        );` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      async _initVersionInfo() {` && |\n| &&
             `        try {` && |\n| &&
             `          const info = await VersionInfo.load();` && |\n| &&
             `          const stillAlive = !this.isDestroyed || !this.isDestroyed();` && |\n| &&
             `          if (stillAlive) {` && |\n| &&
             `            z2ui5.oConfig.UI5VersionInfo = {` && |\n| &&
             `              version: info.version,` && |\n| &&
             `              buildTimestamp: info.buildTimestamp,` && |\n| &&
             `              gav: info.gav,` && |\n| &&
             `              theme: Theming ? Theming.getTheme() : "",` && |\n| &&
             `            };` && |\n| &&
             `          }` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          logError("Component: VersionInfo load failed", e);` && |\n| &&
             `        }` && |\n| &&
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
             `        window.removeEventListener("popstate", this._boundPopstate);` && |\n| &&
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
             `          const setDirtyFlag =` && |\n| &&
             `            this._launchpad &&` && |\n| &&
             `            this._launchpad.Container &&` && |\n| &&
             `            this._launchpad.Container.setDirtyFlag;` && |\n| &&
             `          if (setDirtyFlag) setDirtyFlag.call(this._launchpad.Container, false);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          logError("Component: clearing FLP dirty flag failed", e);` && |\n| &&
             `        }` && |\n| &&
             `        if (z2ui5.oLaunchpad === this._launchpad) z2ui5.oLaunchpad = null;` && |\n| &&
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
