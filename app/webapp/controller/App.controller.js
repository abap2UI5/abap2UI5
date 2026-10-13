// Controller of the outer shell view (App.view.xml). Runs once at startup:
// stores the backend URL, creates the root control and the five View1
// controller instances (one per view slot) and kicks off the initial roundtrip.
sap.ui.define(
  [
    "sap/ui/core/mvc/Controller",
    "sap/m/App",
    "sap/m/NavContainer",
    "z2ui5/controller/View1.controller",
    "z2ui5/core/Server",
    "z2ui5/core/Context",
    "z2ui5/core/ViewSlots",
    "z2ui5/core/Env",
  ],
  (
    BaseController,
    App,
    NavContainer,
    Controller,
    Server,
    Context,
    ViewSlots,
    Env,
  ) => {
    "use strict";

    // The root control that hosts the main view, id "app" in the shell view.
    // On a page of the app's own it is a sap.m.App: the full-screen root,
    // which sets the page up as a mobile app (sap/ui/util/Mobile), paints
    // the theme's background and gives every ancestor up to <html> a height
    // of 100% (App._adjustParentsHeight). On a host's page all three are the
    // host's, so an EMBEDDED component gets its base class instead, a
    // sap.m.NavContainer: the same pages and navigation API (actions/Slots),
    // the same autoFocus, and nothing beyond its own area - it fills the
    // height its host gives it, and the host gives it one (the
    // z2ui5.embed.Container control does). A host that hands the page back
    // (ownsPage - the page is this one component and nothing else) gets the
    // sap.m.App again, like everything else that belongs to the page.
    // Created under the component as owner, like everything else the
    // framework creates.
    function createRoot(ctx, oController) {
      const Root = ctx.state.ownsPage ? App : NavContainer;
      const oRoot = Context.runAsOwner(
        ctx,
        () => new Root(oController.createId("app")),
      );
      // the slot the shell view declares for it (core/RootSlot)
      oController.byId("rootSlot").setRoot(oRoot);
      return oRoot;
    }

    // An EMBEDDED component's root must not focus the first input of
    // the first page it renders (sap.m.NavContainer autoFocus): the page is
    // the host's, and on 1.136 every app - hello world included - took the
    // focus out of the host field the user was typing in. The property is
    // off until that first page has rendered and back on from there: the
    // root then moves the focus only on a page change, and only when it was
    // in the page being left (NavContainer._applyAutoFocus) - which keeps a
    // page transition (view_display( transition )) usable from the
    // keyboard. Set back without an invalidation: the property is read at
    // run time and renders nothing. The app's own focus actions have a
    // guard of their own (core/ScrollFocus.js, mayMoveFocus).
    function holdFirstAutoFocus(oApp) {
      if (!oApp?.getAutoFocus?.()) return;
      oApp.setAutoFocus(false);
      const delegate = {
        onAfterRendering() {
          if (!oApp.getCurrentPage()) return;
          oApp.removeEventDelegate(delegate);
          oApp.setProperty("autoFocus", true, true);
        },
      };
      oApp.addEventDelegate(delegate);
    }

    const AppController = BaseController.extend("z2ui5.controller.App", {
      onInit() {
        // the owner component's context - Component.init created it
        const ctx = Context.of(this.getOwnerComponent());
        const state = ctx.state;
        state.oOwnerComponent = this.getOwnerComponent();

        // The backend URL, first match wins:
        //  1. the endpoint a host app passed as component data (Component.init)
        //  2. the page itself when it was served by the backend GET page
        //     (checkLocal, see Component.init)
        //  3. the manifest's data source - BSP and launchpad; optional
        //     chaining keeps a missing entry from blowing up
        const manifest = state.oOwnerComponent.getManifest();
        const uri = manifest?.["sap.app"]?.dataSources?.http?.uri;
        state.url =
          state.endpoint || (state.checkLocal ? window.location.href : uri);

        state.oApp = createRoot(ctx, this);
        if (state.embedded) holdFirstAutoFocus(state.oApp);

        this.startApp();
      },

      // The controllers of the app and its first roundtrip - when the
      // component starts, and again when an embedded app restarts in place
      // (Component._restartApp, the Restart of the fatal-error overlay).
      startApp() {
        const ctx = Context.of(this.getOwnerComponent());
        const state = ctx.state;

        // One controller per view slot, driven by the slot table in
        // core/ViewSlots - the single place that knows which slots exist, so
        // adding one there does not need a matching line here. Each carries
        // the context: it is how every event handler and action reaches the
        // state (View1.controller). All other state (callback arrays,
        // roundtrip flags, ...) starts from the defaults Context.create gave
        // it during Component.init. NEW instances on a restart as well:
        // whatever the app before them left waiting - a timer, a deferred
        // focus - asks Lib.isControllerAlive, and its controller is not one
        // of these.
        for (const slot of ViewSlots.slots) {
          const oController = new Controller();
          oController.ctx = ctx;
          state[slot.controllerProp] = oController;
        }

        // Kick off the initial roundtrip. Historically a stopped router's
        // initial routeMatched event triggered this; the manifest carries no
        // routing section anymore (the legacy-free UI5 2.x manifest schema
        // rejects the classic routing options), so the shell controller
        // starts the app directly. When the URL carries an app-state hash,
        // the backend restores that state from S_FRONT.
        Server.roundtrip(ctx);
      },
    });
    return Env.ownClass(AppController);
  },
);
