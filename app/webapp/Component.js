sap.ui.define(
  [
    "sap/ui/core/UIComponent",
    "z2ui5/model/models",
    "z2ui5/core/Server",
    "z2ui5/core/Session",
    "sap/ui/VersionInfo",
    "z2ui5/devtools/DevTools",
    "z2ui5/core/Lib",
    "z2ui5/core/Env",
    "z2ui5/core/Context",
    "z2ui5/core/Router",
    "z2ui5/core/ScrollFocus",
    "z2ui5/core/ViewSlots",
    "z2ui5/core/actions/Shortcuts",
  ],
  (
    UIComponent,
    Models,
    Server,
    Session,
    VersionInfo,
    DevTools,
    Lib,
    Env,
    Context,
    Router,
    ScrollFocus,
    ViewSlots,
    Shortcuts,
  ) => {
    "use strict";

    return UIComponent.extend("z2ui5.Component", {
      metadata: {
        manifest: "json",
        interfaces: ["sap.ui.core.IAsyncContentCreation"],
      },

      init() {
        // The context of THIS component (core/Context.js): its state, its
        // request bookkeeping, its listeners. Nothing of it is shared with
        // another z2ui5.Component on the page - several can run side by
        // side since 2026-09-23 - and every module below the component
        // reaches it through the controllers App.controller creates, or
        // through Context.of for a control. Fresh defaults, also on an FLP
        // re-launch, so the base init() and all helpers can rely on a fully
        // initialized state from here on.
        this.ctx = Context.create(this);
        const state = this.ctx.state;

        // The backend GET page (z2ui5_cl_ui5_http_handler=>_http_get) passes
        // its settings as component data, and so does a host app that
        // embeds this component (endpoint, see below); they configure the
        // frontend and are not app data, so they are split off here and
        // never travel to the backend with the rest of the component data.
        // In BSP and Launchpad mode none of them is present.
        const {
          checkLocal,
          ccResourceRoot,
          cccResourceRoot,
          endpoint,
          ...componentData
        } = this.getComponentData() || {};
        state.checkLocal = checkLocal === true;
        state.ccResourceRoot = ccResourceRoot || null;
        state.cccResourceRoot = cccResourceRoot || null;

        // The backend URL of a host app that embeds this component, e.g.
        // new ComponentContainer({ name: "z2ui5", settings: { componentData:
        // { endpoint: "/sap/bc/z2ui5_other" } } }) - for a service node not
        // at the manifest's /sap/bc/z2ui5. It wins over the manifest and the
        // page URL (App.controller). Only the TOP level of the component data
        // is read: in the launchpad the URL's parameters arrive under
        // startupParameters, and a link must never be able to point the
        // roundtrips - and the data they carry - at another server.
        state.endpoint =
          typeof endpoint === "string" && endpoint.trim()
            ? endpoint.trim()
            : null;

        // Two sibling BSPs carry frontend artefacts the framework itself does
        // not ship: z2ui5_cci (abap2UI5-addons/custom-controls) and z2ui5_ccc
        // (abap2UI5/customer-frontend-extension, the customer's own library).
        // The two roots differ in one letter and are NOT the same BSP - each
        // matches the ABAP prefix of its repository (z2ui5_cl_cci for the
        // community controls, z2ui5_cl_ccc for the customer extension).
        // Both are normally found through their reserved resourceRoot in
        // manifest.json ("z2ui5_cci": "../z2ui5_cci/", "z2ui5_ccc":
        // "../z2ui5_ccc/"), a sibling of THIS BSP. In the standalone HTTP
        // service there is no BSP for them to be a sibling of, so the backend
        // hands the absolute paths over as component data instead
        // (z2ui5_cl_ui5_http_handler=>_http_get).
        //
        // They have to be applied HERE and not in the page: the manifest
        // registers its own value while the component is being created, which
        // is after everything the shell can run, so a registration made there
        // is overwritten again. init() runs after manifest processing.
        // Absent in BSP and Launchpad mode, where the manifest entries are
        // right. Neither BSP is loaded from here - nothing is requested until
        // a view actually names the namespace - so a system that has only one
        // of them installed (or neither) never pays for the other.
        // one loader.config( ) for both roots - each call re-runs the
        // loader's whole configuration merge
        const paths = {};
        if (state.ccResourceRoot) paths.z2ui5_cci = state.ccResourceRoot;
        if (state.cccResourceRoot) paths.z2ui5_ccc = state.cccResourceRoot;
        if (Object.keys(paths).length) sap.ui.loader.config({ paths });

        UIComponent.prototype.init.call(this);

        // absent (as before the split) when nothing but the page settings
        // was passed, so a standalone request carries no empty object
        state.oConfig.ComponentData = Object.keys(componentData).length
          ? componentData
          : undefined;

        state.oDeviceModel = Models.createDeviceModel();
        this.setModel(state.oDeviceModel, "device");

        // Warm-load the messaging module so Env.getMessaging's synchronous
        // sap.ui.require resolves it before the first view is displayed.
        // On UI5 2.x sap/ui/core/Messaging is the only messaging API (the
        // sap.ui.getCore().getMessageManager() fallback is gone), and
        // nothing else pulls the module into the graph - without this the
        // message> model and validation collection would silently no-op.
        // Only attempt it where the module exists (1.118+): on older releases
        // (e.g. 1.71) the require would 404 and make the ui5loader retry
        // loudly via synchronous XHR; there Env.getMessaging falls back to
        // sap.ui.getCore().getMessageManager() instead.
        if (Env.hasMessagingModule()) {
          sap.ui.require(
            ["sap/ui/core/Messaging"],
            () => {},
            () => {},
          );
        }

        this._initLaunchpad();
        this._initVersionInfo();

        this._installUnloadListener();
        // The developer tools own everything of their own: the Ctrl+F12
        // shortcut, the dialog instance, the roundtrip recorder and the
        // "?z2ui5-devtools=" auto open. This call and the exit() below are
        // the framework's ENTIRE coupling to devtools/ - keep it that
        // way (see the module header there).
        DevTools.install(this.ctx);
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

      _installScrollListener() {
        // Scroll events do not bubble, but they do trigger capture-phase
        // listeners on ancestors - a single document-level listener observes
        // every scrollable container. ScrollFocus.onScrollCapture records the
        // last scrolled element per view slot for the S_SCROLL request info -
        // of THIS component's slots only, so a second component's listener
        // records its own and ignores ours.
        const ctx = this.ctx;
        this._boundScroll = (event) => ScrollFocus.onScrollCapture(ctx, event);
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
        // follow_up_action( cs_event-hash_routing ) act on it, so apps that
        // manage their own hash are unaffected. Server does the actual
        // restore roundtrip; it is injected here so the router stays free of
        // a Server dependency.
        const ctx = this.ctx;
        Router.init(ctx, () => Server.restoreFromRoute(ctx));
      },

      // ------------------------------------------------------------------
      // SAP Fiori Launchpad integration (only when running inside FLP)
      // ------------------------------------------------------------------

      _initLaunchpad() {
        const Container = sap.ui.require("sap/ushell/Container");
        if (!Container) return; // not running inside the launchpad -> nothing to do

        const launchpad = { Container };
        this._launchpad = launchpad;
        this.ctx.state.oLaunchpad = launchpad;

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
            this.ctx.state.oConfig.S_UI5 = {
              VERSION: info.version,
              BUILDTIMESTAMP: info.buildTimestamp,
              GAV: info.gav,
              THEME: Env.getTheme(),
            };
          }
        } catch (e) {
          Lib.logError("Component: VersionInfo load failed", e);
        }
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
        const ctx = this.ctx;
        window.removeEventListener(this._unloadEvent, this._boundUnload);
        document.removeEventListener("scroll", this._boundScroll, {
          capture: true,
        });
        Router.exit(ctx);

        // Drops the shortcut, the dialog instance and the recorded history
        // of this context's developer tools.
        DevTools.exit(ctx);

        // The same for the APP's keyboard shortcuts, which are a different
        // module: the registry is app-scoped and the state rebuild below
        // empties it, but the `document` keydown listener behind it has to
        // come off explicitly - see core/actions/Shortcuts.reset.
        Shortcuts.reset(ctx);

        Server.endSession(ctx);
        // and drop the request bookkeeping with it - see Server.reset
        Server.reset(ctx);
        // ... and the once-per-page-load send latches of the session block
        // - see Session.reset
        Session.reset(ctx);

        // The two STANDALONE view slots. MAIN and its nested views sit in the
        // component's own control tree and fall with it; a popup and a
        // popover are opened outside it (UI5 puts them in the static area),
        // so nothing here reached them: an FLP re-launch keeps the page
        // alive, and the dialog of the app that just ended stayed on screen
        // over the one that replaced it. Everything inside them stayed alive
        // with it - no inner control ran its exit( ), so a Websocket kept its
        // connection, a Timer kept ticking, and cc/Dirty kept
        // window.onbeforeunload installed for unsaved changes of an app that
        // no longer exists (its reset( ) below is the symptom patch that
        // predates this line, and stays as the backstop for a Dirty control
        // in a slot this does not cover). ViewSlots.destroy( ) closes the
        // fragment first and unregisters the view from the messaging facade,
        // the same way an app switch and a MAIN rebuild take them down.
        ViewSlots.destroy(ctx, "POPUP");
        ViewSlots.destroy(ctx, "POPOVER");

        // What would outlive the component (FLP keeps the page alive). Only
        // what Context.destroy( ) at the end of this method cannot do is
        // done here: destroy REBUILDS the state object, so every plain
        // field (the timer handles, the shortcut registry, the model
        // reference) is back at its default by itself - but a pending
        // timeout keeps firing and a device model keeps its handlers on the
        // Device singleton unless they are cancelled and destroyed first.
        Lib.cancelPendingTimers(ctx);
        if (ctx.state.oDeviceModel) {
          ctx.state.oDeviceModel.destroy();
        }

        // The unsaved-changes guard of cc/Dirty is MODULE state (one page
        // prompt, one FLP dirty flag, so the control has to know about every
        // live instance at once) and no teardown path destroys the POPUP and
        // POPOVER slots - a Dirty control inside a dialog never runs its own
        // exit( ), and its entry kept the prompt installed for an app that
        // is already gone. Only THIS context's instances are dropped.
        // Resolved lazily: an app that uses no Dirty control has not loaded
        // the module, and then there is nothing to reset.
        sap.ui.require("z2ui5/cc/Dirty")?.reset?.(ctx);

        // The OData clients the framework created for MAIN (the inventory
        // AppState.state.odataClients documents): a model is no aggregation,
        // so neither the view's destroy nor AppState.reset( ) below releases
        // one - reset only drops the inventory - and an FLP re-launch kept
        // every client that was open alive, $metadata request, caches and
        // queues included. Each destroy on its own: one that throws must not
        // stop the rest of this teardown.
        for (const oClient of ctx.state.odataClients) {
          try {
            oClient.destroy();
          } catch (e) {
            Lib.logError("Component: destroying an OData client failed", e);
          }
        }

        // Robust launchpad teardown:
        //  1. Clear the FLP dirty flag so it does not carry over into the
        //     next app the user opens.
        //  2. Drop this component's own reference to the shared launchpad
        //     object, which is what turns every still-pending init Promise
        //     into a no-op (setIfAlive compares against it). The state's
        //     field is not nulled here - Context.destroy( ) below rebuilds
        //     the state and with it that field.
        try {
          this._launchpad?.Container?.setDirtyFlag?.(false);
        } catch (e) {
          Lib.logError("Component: clearing FLP dirty flag failed", e);
        }
        this._launchpad = null;

        // Last: the scroll cache and the context itself. ScrollFocus keeps
        // the DOM node and the control of the last scroll gesture until the
        // NEXT roundtrip releases them, and there is no next roundtrip after
        // an exit. Context.destroy( ) is what Lib.isControllerAlive documents
        // as the end of a controller's life: the context reads dead and its
        // state is rebuilt with the slot fields null, so every guard on it
        // (timers, shortcuts, variant polls, the hash dispatcher) answers
        // "dead" from here on - instead of the state holding the five views,
        // their controllers and the last response's model for as long as
        // something still referenced it.
        ScrollFocus.reset(ctx);
        Context.destroy(ctx);

        if (UIComponent.prototype.exit) UIComponent.prototype.exit.call(this);
      },
    });
  },
);
