CLASS lcl_ui5_app DEFINITION.

  PUBLIC SECTION.

    METHODS controller_app_js
      RETURNING
        VALUE(result) TYPE string.

    METHODS view_app_xml
      RETURNING
        VALUE(result) TYPE string.

    METHODS controller_view1_js
      RETURNING
        VALUE(result) TYPE string.

    METHODS view_view1_xml
      RETURNING
        VALUE(result) TYPE string.

    METHODS manifest_json
      RETURNING
        VALUE(result) TYPE string.

    METHODS component_js
      RETURNING
        VALUE(result) TYPE string.

    METHODS model_models_js
      RETURNING
        VALUE(result) TYPE string.

ENDCLASS.

CLASS lcl_ui5_app IMPLEMENTATION.

  METHOD component_js.

    result =     `          sap.ui.define(` && |\n| &&
                 ` [` && |\n| &&
                 `       "sap/ui/core/UIComponent",` && |\n|  &&
                 `                "sap/ui/Device",` && |\n|  &&
*             `                "z2ui5/model/models" ` && |\n|  &&
                 ` ], ` &&
                 `     function (UIComponent, Device ) {` && |\n|  &&
                 `              return UIComponent.extend("z2ui5.Component", {` && |\n|  &&
                 `                  metadata: { manifest: "json" },` && |\n|  &&
                 `                  init: function(){` && |\n|  &&
                `                UIComponent.prototype.init.apply(this, arguments);` && |\n|  &&
*             `                this.getRouter().initialize();` && |\n|  &&
*             `                this.setModel(models.createDeviceModel(), "device");  ` && |\n|  &&
                `` && |\n|  &&
                    ` sap.z2ui5 = sap.z2ui5 || {} ; if ( typeof z2ui5 == "undefined" ) { var z2ui5 = {}; };` && |\n|  &&
                    ` sap.z2ui5.pathname = sap.z2ui5.pathname || this.getManifestEntry("/sap.app/dataSources/mainService/uri");` && |\n| &&
                `` && |\n|  &&
                 `               sap.z2ui5 = sap.z2ui5 || {} ; if ( typeof z2ui5 == "undefined" ) { var z2ui5 = {}; };  ` && |\n|  &&
                                        "only pagehide for ios devices, for all others use beforeunload
                 `                      if (/iPad|iPhone/.test(navigator.platform)){` && |\n|  &&
                 `                        window.addEventListener("pagehide", this.__pagehide.bind(this));` && |\n|  &&
                 `                      }` && |\n|  &&
                 `                      else{` && |\n|  &&
                 `                        window.addEventListener("beforeunload", this.__beforeunload.bind(this));` && |\n|  &&
                 `                      }` && |\n|  &&
                 `                  },` && |\n|  &&
                 `                  __beforeunload: function(){` && |\n|  &&
                 `                      window.removeEventListener("__beforeunload", this.__beforeunload.bind(this));` && |\n| &&
                 `                      this.destroy(); //manually call destroy as it is only fired in FLP` && |\n|  &&
                 `                  },` && |\n|  &&
                 `                  __pagehide: function(){` && |\n|  &&
                 `                      window.removeEventListener("pagehide", this.__pagehide.bind(this));` && |\n| &&
                 `                      this.destroy(); //manually call destroy as it is only fired in FLP` && |\n|  &&
                 `                  },` && |\n|  &&
                 `                  exit: function(){` && |\n|  &&
                 `                      if(sap.z2ui5.contextId){` && |\n| &&
                 `                          fetch(sap.z2ui5.pathname, {` && |\n| &&
                 `                              method: 'HEAD',` && |\n| &&
                 `                              keepalive: true,` && |\n| &&
                 `                              headers: {` && |\n| &&
                 `                                  'sap-terminate': 'session',` && |\n| &&
                 `                                  'sap-contextid': sap.z2ui5.contextId,` && |\n| &&
                 `                                  'sap-contextid-accept': 'header'` && |\n| &&
                 `                              }` && |\n| &&
                 `                          });` && |\n| &&
                 `                      }` && |\n| &&
                 `                      if(UIComponent.prototype.exit) UIComponent.prototype.exit.apply(this, arguments);` && |\n|  &&
                 `                  },` && |\n|  &&
                 `              });` && |\n|  &&
                 `          });`.


  ENDMETHOD.

  METHOD controller_app_js.

    result =  `          sap.ui.define(["sap/ui/core/mvc/Controller", "z2ui5/Controller", "sap/ui/core/BusyIndicator"], function(BaseController, Controller, BusyIndicator){` && |\n| &&
                 `              return BaseController.extend("z2ui5.controller.App", {` && |\n| &&
                 `                  onInit: function(){` && |\n| &&
                 `                      BusyIndicator.show();` && |\n| &&
                 `                     ` && |\n| &&
                 `                      sap.z2ui5.oController = new Controller();` && |\n| &&
                 `                      sap.z2ui5.oControllerNest = new Controller();` && |\n| &&
                 `                      sap.z2ui5.oControllerNest2 = new Controller();` && |\n| &&
                 `                      sap.z2ui5.oControllerPopup = new Controller();` && |\n| &&
                 `                      sap.z2ui5.oControllerPopover = new Controller();` && |\n| &&
                 `                      sap.z2ui5.checkNestAfter = false;` && |\n| &&
                 `                      sap.z2ui5.oBody = { };` && |\n| &&
                 `                      sap.z2ui5.oController.setApp(this.getView());` && |\n| &&
                 `                      sap.z2ui5.oController.Roundtrip();` && |\n| &&
                 `                      sap.z2ui5.onBeforeRoundtrip = [];` && |\n| &&
                 `                      sap.z2ui5.onAfterRendering = [];` && |\n| &&
                 `                      sap.z2ui5.onBeforeEventFrontend = [];` && |\n| &&
                 `                      sap.z2ui5.onAfterRoundtrip = []; ` && |\n| &&
                 `                  }` && |\n| &&
                 `              });` && |\n| &&
                 `          });`.

  ENDMETHOD.

  METHOD controller_view1_js.

  ENDMETHOD.

  METHOD manifest_json.

    result = ` {` &&
                            `"sap.app": { "id": "z2ui5", "type": "application" }, ` &&
                            `"sap.ui": { "technology": "ui5", "deviceTypes": { "desktop": true, "tablet": true, "phone": true } }, ` &&
                            `"sap.ui5": { "flexEnabled": true, "contentDensities": { "compact": true, "cozy": true }, ` &&
                              `"rootView": { "id": "viewContainer", "viewName": "z2ui5.view.App", "type": "XML", "async": true } } ` &&
                         `} `.
  ENDMETHOD.

  METHOD view_app_xml.

    result = `<mvc:View xmlns:mvc="sap.ui.core.mvc" displayBlock="true" xmlns="sap.m" controllerName="z2ui5.controller.App">` &&
            ` <App id="viewContainer"></App>` &&
            `</mvc:View>`.

  ENDMETHOD.

  METHOD view_view1_xml.

  ENDMETHOD.

  METHOD model_models_js.

  ENDMETHOD.

ENDCLASS.
