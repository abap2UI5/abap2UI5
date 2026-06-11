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

        // Read the backend URI from the manifest, falling back step by step
        // so a missing entry doesn't blow up.
        const manifest = oOwnerComponent.getManifest();
        const sapApp = manifest?.["sap.app"];
        const dataSources = sapApp?.dataSources;
        const http = dataSources?.http;
        const uri = http?.uri;
        z2ui5.url = z2ui5.checkLocal ? window.location.href : uri;

        // Set up the shared z2ui5 state used by the whole app.
        z2ui5.oController = new Controller();
        z2ui5.oApp = this.getView().byId("app");
        z2ui5.oControllerNest = new Controller();
        z2ui5.oControllerNest2 = new Controller();
        z2ui5.oControllerPopup = new Controller();
        z2ui5.oControllerPopover = new Controller();
        z2ui5.onBeforeRoundtrip = [];
        z2ui5.onAfterRendering = [];
        z2ui5.onBeforeEventFrontend = [];
        z2ui5.onAfterRoundtrip = [];
        z2ui5.errors = [];
        z2ui5.checkNestAfter = false;
        z2ui5.checkNestAfter2 = false;

        // If the URL already contains a hash, kick off the initial roundtrip
        // so the backend can restore that state.
        if (HashChanger.getInstance().getHash()) {
          Server.roundtrip();
        }
      },
    });
  },
);
