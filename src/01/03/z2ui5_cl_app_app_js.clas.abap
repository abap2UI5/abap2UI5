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
             `// per view slot) and kicks off the initial roundtrip.` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    "sap/ui/core/mvc/Controller",` && |\n| &&
             `    "z2ui5/controller/View1.controller",` && |\n| &&
             `    "z2ui5/core/Server",` && |\n| &&
             `    "z2ui5/core/AppState",` && |\n| &&
             `  ],` && |\n| &&
             `  (BaseController, Controller, Server, AppState) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `    return BaseController.extend("z2ui5.controller.App", {` && |\n| &&
             `      onInit() {` && |\n| &&
             `        const state = AppState.state;` && |\n| &&
             `        state.oOwnerComponent = this.getOwnerComponent();` && |\n| &&
             `` && |\n| &&
             `        // Read the backend URI from the manifest; optional chaining keeps a` && |\n| &&
             `        // missing entry from blowing up. checkLocal and url are public` && |\n| &&
             `        // contract fields on the z2ui5 global (the backend GET page sets` && |\n| &&
             `        // checkLocal), so they go through the AppState facade.` && |\n| &&
             `        const manifest = state.oOwnerComponent.getManifest();` && |\n| &&
             `        const uri = manifest?.["sap.app"]?.dataSources?.http?.uri;` && |\n| &&
             `        AppState.setGlobal(` && |\n| &&
             `          "url",` && |\n| &&
             `          AppState.getGlobal("checkLocal") ? window.location.href : uri,` && |\n| &&
             `        );` && |\n| &&
             `` && |\n| &&
             `        // Wire up the controller instances and the app container. All other` && |\n| &&
             `        // shared state (callback arrays, error log, roundtrip flags, ...)` && |\n| &&
             `        // starts from the defaults that core/AppState set during` && |\n| &&
             `        // Component.init.` && |\n| &&
             `        state.oController = new Controller();` && |\n| &&
             `        state.oApp = this.getView().byId("app");` && |\n| &&
             `        state.oControllerNest = new Controller();` && |\n| &&
             `        state.oControllerNest2 = new Controller();` && |\n| &&
             `        state.oControllerPopup = new Controller();` && |\n| &&
             `        state.oControllerPopover = new Controller();` && |\n| &&
             `` && |\n| &&
             `        // Kick off the initial roundtrip. Historically a stopped router's` && |\n| &&
             `        // initial routeMatched event triggered this; the manifest carries no` && |\n| &&
             `        // routing section anymore (the legacy-free UI5 2.x manifest schema` && |\n| &&
             `        // rejects the classic routing options), so the shell controller` && |\n| &&
             `        // starts the app directly. When the URL carries an app-state hash,` && |\n| &&
             `        // the backend restores that state from S_FRONT.` && |\n| &&
             `        Server.roundtrip();` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
