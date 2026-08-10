sap.ui.define(
  [
    "sap/ui/core/UIComponent",
    "z2ui5/model/models",
    "z2ui5/core/Server",
    "sap/ui/VersionInfo",
    "z2ui5/core/DeveloperTools",
    "z2ui5/core/Lib",
    "z2ui5/core/AppState",
    "z2ui5/Util",
    "z2ui5/model/formatter",
    "z2ui5/core/Router",
  ],
  (
    UIComponent,
    Models,
    Server,
    VersionInfo,
    DeveloperTools,
    Lib,
    AppState,
    DateUtil,
    Formatter,
    Router,
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

        // Two sibling BSPs carry frontend artefacts the framework itself does
        // not ship: z2ui5ccc (abap2UI5-addons/custom-controls) and z2ui5cci
        // (abap2UI5/customer-frontend-extension, the customer's own library).
        // Both are normally found through their reserved resourceRoot in
        // manifest.json ("z2ui5ccc": "../z2ui5ccc/", "z2ui5cci":
        // "../z2ui5cci/"), a sibling of THIS BSP. In the standalone HTTP
        // service there is no BSP for them to be a sibling of, so the backend
        // hands the absolute paths over on the global instead
        // (z2ui5_cl_http_handler=>_http_get).
        //
        // They have to be applied HERE and not in the page: the manifest
        // registers its own value while the component is being created, which
        // is after everything the shell can run, so a registration made there
        // is overwritten again. init() runs after manifest processing.
        // Absent in BSP and Launchpad mode, where the manifest entries are
        // right. Neither BSP is loaded from here - nothing is requested until
        // a view actually names the namespace - so a system that has only one
        // of them installed (or neither) never pays for the other.
        const ccResourceRoot = AppState.getGlobal("ccResourceRoot");
        if (ccResourceRoot) {
          sap.ui.loader.config({ paths: { z2ui5ccc: ccResourceRoot } });
        }
        const cciResourceRoot = AppState.getGlobal("cciResourceRoot");
        if (cciResourceRoot) {
          sap.ui.loader.config({ paths: { z2ui5cci: cciResourceRoot } });
        }

        UIComponent.prototype.init.call(this);

        AppState.getGlobal("oConfig").ComponentData = this.getComponentData();

        // The date helpers are a public contract: apps use them via the
        // z2ui5.Util global (XML view formatter strings) or via
        // core:require of the z2ui5/Util module. Publish the global here -
        // since the custom controls were split out of App.controller.js,
        // nothing else loads the module eagerly anymore.
        AppState.setGlobal("Util", DateUtil);

        // The curated formatter module in the standard app layout
        // (model/formatter.js): views wire it via core:require of
        // z2ui5/model/formatter; the global keeps binding strings working
        // on releases without core:require (< 1.74). It owns the date
        // helpers - Util above is the thin legacy alias re-exporting them.
        AppState.setGlobal("Formatter", Formatter);

        AppState.state.oDeviceModel = Models.createDeviceModel();
        this.setModel(AppState.state.oDeviceModel, "device");

        // Warm-load the messaging module so Lib.getMessaging's synchronous
        // sap.ui.require resolves it before the first view is displayed.
        // On UI5 2.x sap/ui/core/Messaging is the only messaging API (the
        // sap.ui.getCore().getMessageManager() fallback is gone), and
        // nothing else pulls the module into the graph - without this the
        // message> model and validation collection would silently no-op.
        // Only attempt it where the module exists (1.118+): on older releases
        // (e.g. 1.71) the require would 404 and make the ui5loader retry
        // loudly via synchronous XHR; there Lib.getMessaging falls back to
        // sap.ui.getCore().getMessageManager() instead.
        if (Lib.hasMessagingModule()) {
          sap.ui.require(
            ["sap/ui/core/Messaging"],
            () => {},
            () => {},
          );
        }

        this._initLaunchpad();
        this._initVersionInfo();

        this._installUnloadListener();
        this._installDeveloperToolsShortcut();
        this._installScrollListener();
        this._installRouterListener();
      },

      // ------------------------------------------------------------------
      // Event listeners installed in init() and removed in exit()
      // ------------------------------------------------------------------

      _installUnloadListener() {
        this._boundUnload = this._onUnload.bind(this);
        // "pagehide", not "beforeunload": pagehide fires only after the
        // navigation is committed (any "leave page?" prompt was answered),
        // so tearing the app down here can neither swallow the cc/Dirty
        // unsaved-changes prompt (destroying the app mid-beforeunload
        // removed its window.onbeforeunload handler before the browser
        // invoked it) nor kill the live session when the user chooses to
        // stay. It is also the reliable event on iOS Safari, which never
        // fired beforeunload dependably.
        this._unloadEvent = "pagehide";
        window.addEventListener(this._unloadEvent, this._boundUnload);
      },

      _installDeveloperToolsShortcut() {
        // Ctrl + F12 opens / closes the in-app developer tools.
        this._boundKeydown = (event) => {
          if (event.ctrlKey && event.key === "F12") {
            const state = AppState.state;
            if (!state.developerTools)
              state.developerTools = new DeveloperTools();
            state.developerTools.toggle();
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

      _installRouterListener() {
        // Hash-based app routing (UI5 Router style), owned by core/Router.js.
        // It sits on the HashChanger - the same engine
        // sap.ui.core.routing.Router uses, and inside the FLP the shell's own
        // one - so the native browser Back/Forward buttons and the launchpad
        // back button drive navigation. Only apps that opted in via
        // client->set_nav_routing( ) act on it, so apps that manage their own
        // hash are unaffected. Server does the actual restore roundtrip; it is
        // injected here so the router stays free of a Server dependency.
        Router.init(() => Server.restoreFromRoute());
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

      _onUnload(event) {
        // pagehide with persisted = true means the page enters the browser's
        // back/forward cache and may be shown again - keep the app alive.
        if (event?.persisted) return;
        // destroy() runs exit(), which removes the unload listener (and every
        // other one) - no need to remove it here too.
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
        Router.exit();

        // The developer tools control is created lazily by the Ctrl+F12
        // shortcut - destroy it (which also closes its dialog) so a re-launch
        // (FLP) does not leak the control instance.
        if (AppState.state.developerTools) {
          AppState.state.developerTools.destroy();
          AppState.state.developerTools = null;
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
