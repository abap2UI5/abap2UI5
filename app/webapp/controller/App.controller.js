// Controller of the outer shell view (App.view.xml). Runs once at startup:
// stores the backend URL, creates the five View1 controller instances (one
// per view slot) and kicks off the initial roundtrip when the URL already
// carries an app-state hash.
sap.ui.define(
  [
    "sap/ui/core/mvc/Controller",
    "z2ui5/controller/View1.controller",
    "z2ui5/core/Server",
    "sap/ui/core/routing/HashChanger",
    "z2ui5/core/AppState",
  ],
  (BaseController, Controller, Server, HashChanger, AppState) => {
    "use strict";
    return BaseController.extend("z2ui5.controller.App", {
      onInit() {
        const state = AppState.state;
        state.oOwnerComponent = this.getOwnerComponent();

        // Read the backend URI from the manifest; optional chaining keeps a
        // missing entry from blowing up. checkLocal and url are public
        // contract fields on the z2ui5 global (the backend GET page sets
        // checkLocal), so they go through the AppState facade.
        const manifest = state.oOwnerComponent.getManifest();
        const uri = manifest?.["sap.app"]?.dataSources?.http?.uri;
        AppState.setGlobal(
          "url",
          AppState.getGlobal("checkLocal") ? window.location.href : uri,
        );

        // Wire up the controller instances and the app container. All other
        // shared state (callback arrays, error log, roundtrip flags, ...)
        // starts from the defaults that core/AppState set during
        // Component.init.
        state.oController = new Controller();
        state.oApp = this.getView().byId("app");
        state.oControllerNest = new Controller();
        state.oControllerNest2 = new Controller();
        state.oControllerPopup = new Controller();
        state.oControllerPopover = new Controller();

        // If the URL already contains a hash, kick off the initial roundtrip
        // so the backend can restore that state.
        if (HashChanger.getInstance().getHash()) {
          Server.roundtrip();
        }
      },
    });
  },
);
