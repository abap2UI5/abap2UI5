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

    result = `// Controller of the outer shell view (App.view.xml). Runs once at startup:` && |\n| &&
             `// stores the backend URL, creates the five View1 controller instances (one` && |\n| &&
             `// per view slot) and kicks off the initial roundtrip when the URL already` && |\n| &&
             `// carries an app-state hash.` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    "sap/ui/core/mvc/Controller",` && |\n| &&
             `    "z2ui5/controller/View1.controller",` && |\n| &&
             `    "z2ui5/core/Server",` && |\n| &&
             `    "sap/ui/core/routing/HashChanger",` && |\n| &&
             `  ],` && |\n| &&
             `  (BaseController, Controller, Server, HashChanger) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `    return BaseController.extend("z2ui5.controller.App", {` && |\n| &&
             `      onInit() {` && |\n| &&
             `        const oOwnerComponent = this.getOwnerComponent();` && |\n| &&
             `        z2ui5.oOwnerComponent = oOwnerComponent;` && |\n| &&
             `` && |\n| &&
             `        // Read the backend URI from the manifest; optional chaining keeps a` && |\n| &&
             `        // missing entry from blowing up.` && |\n| &&
             `        const manifest = oOwnerComponent.getManifest();` && |\n| &&
             `        const uri = manifest?.["sap.app"]?.dataSources?.http?.uri;` && |\n| &&
             `        z2ui5.url = z2ui5.checkLocal ? window.location.href : uri;` && |\n| &&
             `` && |\n| &&
             `        // Wire up the controller instances and the app container. All other` && |\n| &&
             `        // shared state (callback arrays, error log, roundtrip flags, ...)` && |\n| &&
             `        // starts from the defaults that core/AppState set during` && |\n| &&
             `        // Component.init.` && |\n| &&
             `        z2ui5.oController = new Controller();` && |\n| &&
             `        z2ui5.oApp = this.getView().byId("app");` && |\n| &&
             `        z2ui5.oControllerNest = new Controller();` && |\n| &&
             `        z2ui5.oControllerNest2 = new Controller();` && |\n| &&
             `        z2ui5.oControllerPopup = new Controller();` && |\n| &&
             `        z2ui5.oControllerPopover = new Controller();` && |\n| &&
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
