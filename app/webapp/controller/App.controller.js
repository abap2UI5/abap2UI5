// Controller of the outer shell view (App.view.xml). Runs once at startup:
// stores the backend URL, creates the five View1 controller instances (one
// per view slot) and kicks off the initial roundtrip.
sap.ui.define(
  [
    "sap/ui/core/mvc/Controller",
    "z2ui5/controller/View1.controller",
    "z2ui5/core/Server",
    "z2ui5/core/Context",
    "z2ui5/core/ViewSlots",
  ],
  (BaseController, Controller, Server, Context, ViewSlots) => {
    "use strict";

    // An EMBEDDED component's sap.m.App must not focus the first input of
    // the first page it renders (sap.m.NavContainer autoFocus): the page is
    // the host's, and on 1.136 every app - hello world included - took the
    // focus out of the host field the user was typing in. The property is
    // off until that first page has rendered and back on from there: the
    // App then moves the focus only on a page change, and only when it was
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

    return BaseController.extend("z2ui5.controller.App", {
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

        // Wire up the controller instances and the app container. One
        // controller per view slot, driven by the slot table in
        // core/ViewSlots - the single place that knows which slots exist, so
        // adding one there does not need a matching line here. Each carries
        // the context: it is how every event handler and action reaches the
        // state (View1.controller). All other state (callback arrays,
        // roundtrip flags, ...) starts from the defaults Context.create gave
        // it during Component.init.
        for (const slot of ViewSlots.slots) {
          const oController = new Controller();
          oController.ctx = ctx;
          state[slot.controllerProp] = oController;
        }
        state.oApp = this.getView().byId("app");
        if (state.embedded) holdFirstAutoFocus(state.oApp);

        // Kick off the initial roundtrip. Historically a stopped router's
        // initial routeMatched event triggered this; the manifest carries no
        // routing section anymore (the legacy-free UI5 2.x manifest schema
        // rejects the classic routing options), so the shell controller
        // starts the app directly. When the URL carries an app-state hash,
        // the backend restores that state from S_FRONT.
        Server.roundtrip(ctx);
      },
    });
  },
);
