CLASS z2ui5_cl_app_app_js DEFINITION
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


CLASS z2ui5_cl_app_app_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    "sap/ui/core/mvc/Controller",` && |\n| &&
             `    "z2ui5/controller/View1.controller",` && |\n| &&
             `    "z2ui5/cc/Server",` && |\n| &&
             `    "sap/ui/core/routing/HashChanger",` && |\n| &&
             `  ],` && |\n| &&
             `  (BaseController, Controller, Server, HashChanger) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `    return BaseController.extend("z2ui5.controller.App", {` && |\n| &&
             `      onInit() {` && |\n| &&
             `        const oOwnerComponent = this.getOwnerComponent();` && |\n| &&
             `        z2ui5.oOwnerComponent = oOwnerComponent;` && |\n| &&
             `` && |\n| &&
             `        // Read the backend URI from the manifest, falling back step by step` && |\n| &&
             `        // so a missing entry doesn't blow up.` && |\n| &&
             `        const manifest = oOwnerComponent.getManifest();` && |\n| &&
             `        const sapApp = manifest?.["sap.app"];` && |\n| &&
             `        const dataSources = sapApp?.dataSources;` && |\n| &&
             `        const http = dataSources?.http;` && |\n| &&
             `        const uri = http?.uri;` && |\n| &&
             `        z2ui5.url = z2ui5.checkLocal ? window.location.href : uri;` && |\n| &&
             `` && |\n| &&
             `        // Set up the shared z2ui5 state used by the whole app.` && |\n| &&
             `        z2ui5.oController = new Controller();` && |\n| &&
             `        z2ui5.oApp = this.getView().byId("app");` && |\n| &&
             `        z2ui5.oControllerNest = new Controller();` && |\n| &&
             `        z2ui5.oControllerNest2 = new Controller();` && |\n| &&
             `        z2ui5.oControllerPopup = new Controller();` && |\n| &&
             `        z2ui5.oControllerPopover = new Controller();` && |\n| &&
             `        z2ui5.onBeforeRoundtrip = [];` && |\n| &&
             `        z2ui5.onAfterRendering = [];` && |\n| &&
             `        z2ui5.onBeforeEventFrontend = [];` && |\n| &&
             `        z2ui5.onAfterRoundtrip = [];` && |\n| &&
             `        z2ui5.errors = [];` && |\n| &&
             `        z2ui5.checkNestAfter = false;` && |\n| &&
             `        z2ui5.checkNestAfter2 = false;` && |\n| &&
             `` && |\n| &&
             `        // If the URL already contains a hash, kick off the initial roundtrip` && |\n| &&
             `        // so the backend can restore that state.` && |\n| &&
             `        if (HashChanger.getInstance().getHash()) {` && |\n| &&
             `          Server.roundtrip();` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
