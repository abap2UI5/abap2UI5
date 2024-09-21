CLASS lcl_ui5_app DEFINITION.

  PUBLIC SECTION.

    METHODS controller_app_js
      RETURNING
        VALUE(result) TYPE string.

    METHODS view_app_xml
      RETURNING
        VALUE(result) TYPE string.

    METHODS i18n_i18n_properties
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

    METHODS css_style_css
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

    result =     `sap.ui.define(["sap/ui/core/UIComponent", "sap/ui/Device" , "z2ui5/model/models" ], function(UIComponent, Device, models) {` && |\n| &&
                 `    return UIComponent.extend("z2ui5.Component", {` && |\n| &&
                 `        metadata: {` && |\n| &&
                 `            manifest: "json"` && |\n| &&
                 `        },` && |\n| &&
                 `        init: function() {` && |\n| &&
                 |\n|  && |\n| &&
                 `            UIComponent.prototype.init.apply(this, arguments);` && |\n| &&
                 `            this.getRouter().initialize();` && |\n| &&
                 `            this.setModel(models.createDeviceModel(), "device");` && |\n| &&
                 |\n|  && |\n| &&
                 `            sap.z2ui5 = sap.z2ui5 || {};` && |\n| &&
                 `            if (typeof z2ui5 == "undefined") {` && |\n| &&
                 `                var z2ui5 = {};` && |\n| &&
                 `            }` && |\n| &&
                 `            ;sap.z2ui5.pathname = sap.z2ui5.pathname || this.getManifestEntry("/sap.app/dataSources/mainService/uri");` && |\n| &&
                 |\n|  && |\n| &&
                 `            if (/iPad|iPhone/.test(navigator.platform)) {` && |\n| &&
                 `                window.addEventListener("pagehide", this.__pagehide.bind(this));` && |\n| &&
                 `            } else {` && |\n| &&
                 `                window.addEventListener("beforeunload", this.__beforeunload.bind(this));` && |\n| &&
                 `            }` && |\n| &&
                 |\n|  && |\n| &&
                 `        },` && |\n| &&
                 `        __beforeunload: function() {` && |\n| &&
                 `            window.removeEventListener("__beforeunload", this.__beforeunload.bind(this));` && |\n| &&
                 `            this.destroy();` && |\n| &&
                 `            //manually call destroy as it is only fired in FLP` && |\n| &&
                 `        },` && |\n| &&
                 `        __pagehide: function() {` && |\n| &&
                 `            window.removeEventListener("pagehide", this.__pagehide.bind(this));` && |\n| &&
                 `            this.destroy();` && |\n| &&
                 `            //manually call destroy as it is only fired in FLP` && |\n| &&
                 `        },` && |\n| &&
                 `        exit: function() {` && |\n| &&
                 `            if (sap.z2ui5.contextId) {` && |\n| &&
                 `                fetch(sap.z2ui5.pathname, {` && |\n| &&
                 `                    method: 'HEAD',` && |\n| &&
                 `                    keepalive: true,` && |\n| &&
                 `                    headers: {` && |\n| &&
                 `                        'sap-terminate': 'session',` && |\n| &&
                 `                        'sap-contextid': sap.z2ui5.contextId,` && |\n| &&
                 `                        'sap-contextid-accept': 'header'` && |\n| &&
                 `                    }` && |\n| &&
                 `                });` && |\n| &&
                 `            }` && |\n| &&
                 `            if (UIComponent.prototype.exit)` && |\n| &&
                 `                UIComponent.prototype.exit.apply(this, arguments);` && |\n| &&
                 `        },` && |\n| &&
                 `    });` && |\n| &&
                 `});`.


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

    "TODO
    result = ``.

  ENDMETHOD.

  METHOD manifest_json.

    result = `{` &&
             `    "_version": "1.50.0",` &&
             `    "sap.app": {` &&
             `        "id": "z2ui5",` &&
             `        "type": "application"` &&
*             `        "i18n": "i18n/i18n.properties",` &&
*             `        "applicationVersion": {` &&
*             `            "version": "0.0.2"` &&
*             `        },` &&
*             `        "title": "{{appTitle}}",` &&
*             `        "description": "{{appDescription}}",` &&
*             `        "resources": "resources.json",` &&
*             `        "sourceTemplate": {` &&
*             `            "id": "@sap/generator-fiori:basic",` &&
*             `            "version": "1.10.4",` &&
*             `            "toolsId": "45f51711-e1b8-4fc4-bc1b-9e341941c532"` &&
*             `        },` &&
*             `        "dataSources": {` &&
*             `            "mainService": {` &&
*             `                "uri": "/sap/bc/z2ui5/",` &&
*             `                "type": "http"` &&
*             `            }` &&
*             `        }` &&
             `    },` &&
             `    "sap.ui": {` &&
             `        "technology": "UI5",` &&
             `        "icons": {` &&
             `            "icon": "",` &&
             `            "favIcon": "",` &&
             `            "phone": "",` &&
             `            "phone@2": "",` &&
             `            "tablet": "",` &&
             `            "tablet@2": ""` &&
             `        },` &&
             `        "deviceTypes": {` &&
             `            "desktop": true,` &&
             `            "tablet": true,` &&
             `            "phone": true` &&
             `        },` &&
             `        "fullWidth": true` &&
              `    },` &&
              `    "sap.ui5": {` &&
             `        "flexEnabled": true,` &&
             `        "dependencies": {` &&
             `            "minUI5Version": "1.116.0",` &&
             `            "libs": {` &&
*             `                "sap.m": {},` &&
*             `                "sap.ui.core": {},` &&
*             `                "sap.f": {},` &&
*             `                "sap.suite.ui.generic.template": {},` &&
*             `                "sap.ui.comp": {},` &&
*             `                "sap.ui.generic.app": {},` &&
*             `                "sap.ui.table": {},` &&
*             `                "sap.ushell": {}` &&
             `            }` &&
             `        },` &&
             `        "contentDensities": {` &&
             `            "compact": true,` &&
             `            "cozy": true` &&
             `        },` &&
             `        "services": {` &&
             `            "ShellUIService": {` &&
             `                "factoryName": "sap.ushell.ui5service.ShellUIService"` &&
             `            }` &&
             `        },` &&
*             `        "models": {` &&
*             `            "i18n": {` &&
*             `                "type": "sap.ui.model.resource.ResourceModel",` &&
*             `                "settings": {` &&
*             `                    "bundleName": "z2ui5.i18n.i18n"` &&
*             `                }` &&
*             `            }` &&
*             `        },` &&
             `        "resources": {` &&
             `            "css": [` &&
             `                {` &&
             `                    "uri": "css/style.css"` &&
             `                }` &&
             `            ]` &&
             `        },` &&
             `        "routing": {` &&
             `            "config": {` &&
             `                "routerClass": "sap.m.routing.Router",` &&
             `                "viewType": "XML",` &&
             `                "async": true,` &&
             `                "viewPath": "z2ui5.view",` &&
             `                "controlAggregation": "pages",` &&
             `                "controlId": "viewContainer2",` &&
             `                "clearControlAggregation": false` &&
             `            },` &&
             `            "routes": [` &&
             `                {` &&
             `                    "name": "RouteView1",` &&
             `                    "pattern": ":?query:",` &&
             `                    "target": [` &&
             `                        "TargetView2"` &&
             `                    ]` &&
             `                }` &&
             `            ],` &&
             `            "targets": {` &&
             `                "TargetView1": {` &&
             `                    "viewType": "XML",` &&
             `                    "transition": "slide",` &&
             `                    "clearControlAggregation": false,` &&
             `                    "viewId": "View1",` &&
             `                    "viewName": "View1"` &&
             `                }` &&
             `            }` &&
             `        },` &&
             `        "rootView": {` &&
             `            "viewName": "z2ui5.view.App",` &&
             `            "type": "XML",` &&
             `            "async": true,` &&
             `            "id": "rootView"` &&
             `        }` &&
             `    }` &&
             `}` .

  ENDMETHOD.

  METHOD view_app_xml.

    result = `<mvc:View xmlns:mvc="sap.ui.core.mvc" displayBlock="true" xmlns="sap.m" controllerName="z2ui5.controller.App">` &&
            ` <App id="viewContainer"></App>` &&
            `</mvc:View>`.

  ENDMETHOD.

  METHOD view_view1_xml.

    "TODO
    result = ``.

  ENDMETHOD.

  METHOD model_models_js.

    result = `sap.ui.define(["sap/ui/model/json/JSONModel", "sap/ui/Device"], ` && |\n|  &&
             `              ` && |\n|  &&
             `function(JSONModel, Device) {` && |\n|  &&
             `    "use strict";` && |\n|  &&
             |\n|  &&
             `    return {` && |\n|  &&
             `        createDeviceModel: function() {` && |\n|  &&
             `            var oModel = new JSONModel(Device);` && |\n|  &&
             `            oModel.setDefaultBindingMode("OneWay");` && |\n|  &&
             `            return oModel;` && |\n|  &&
             `        }` && |\n|  &&
             `    };` && |\n|  &&
             `});`.

  ENDMETHOD.

  METHOD css_style_css.

    result = ``.

  ENDMETHOD.

  METHOD i18n_i18n_properties.

    "Do not use, makes no sense
    result = ``.

  ENDMETHOD.

ENDCLASS.
