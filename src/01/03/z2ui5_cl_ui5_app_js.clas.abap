CLASS z2ui5_cl_ui5_app_js DEFINITION
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



CLASS z2ui5_cl_ui5_app_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(["sap/ui/core/mvc/Controller",` && |\n|  &&
             `  "z2ui5/controller/View1.controller",` && |\n|  &&
             `], function (BaseController, Controller) {` && |\n|  &&
             `  return BaseController.extend("z2ui5.controller.App", {` && |\n|  &&
             |\n|  &&
             `    onInit: async function () {` && |\n|  &&
             |\n|  &&
             `      z2ui5.oController = new Controller();` && |\n|  &&
             `      z2ui5.oController.setApp(this.getView().byId("app"));` && |\n|  &&
             |\n|  &&
             `      z2ui5.oControllerNest = new Controller();` && |\n|  &&
             `      z2ui5.oControllerNest2 = new Controller();` && |\n|  &&
             `      z2ui5.oControllerPopup = new Controller();` && |\n|  &&
             `      z2ui5.oControllerPopover = new Controller();` && |\n|  &&
             |\n|  &&
             `      z2ui5.onBeforeRoundtrip = [];` && |\n|  &&
             `      z2ui5.onAfterRendering = [];` && |\n|  &&
             `      z2ui5.onBeforeEventFrontend = [];` && |\n|  &&
             `      z2ui5.onAfterRoundtrip = [];` && |\n|  &&
             |\n|  &&
             `      z2ui5.checkNestAfter = false;` && |\n|  &&
             |\n|  &&
             `    }` && |\n|  &&
             `  });` && |\n|  &&
             `});`.

  ENDMETHOD.

ENDCLASS.
