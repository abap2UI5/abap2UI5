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
  ],
  (BaseController, Controller, Server, HashChanger) => {
    "use strict";
    return BaseController.extend("z2ui5.controller.App", {
      onInit() {
        const oOwnerComponent = this.getOwnerComponent();
        z2ui5.oOwnerComponent = oOwnerComponent;

        // Read the backend URI from the manifest; optional chaining keeps a
        // missing entry from blowing up.
        const manifest = oOwnerComponent.getManifest();
        const uri = manifest?.["sap.app"]?.dataSources?.http?.uri;
        z2ui5.url = z2ui5.checkLocal ? window.location.href : uri;

        // Wire up the controller instances and the app container. All other
        // shared state (callback arrays, error log, roundtrip flags, ...)
        // starts from the defaults that core/AppState set during
        // Component.init.
        z2ui5.oController = new Controller();
        z2ui5.oApp = this.getView().byId("app");
        z2ui5.oControllerNest = new Controller();
        z2ui5.oControllerNest2 = new Controller();
        z2ui5.oControllerPopup = new Controller();
        z2ui5.oControllerPopover = new Controller();

        // If the URL already contains a hash, kick off the initial roundtrip
        // so the backend can restore that state.
        if (HashChanger.getInstance().getHash()) {
          Server.roundtrip();
        }
      },
    });
  },
);
