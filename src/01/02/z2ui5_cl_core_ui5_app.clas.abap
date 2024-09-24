CLASS z2ui5_cl_core_ui5_app DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

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

    METHODS index_html
      IMPORTING
        is_config     TYPE z2ui5_if_types=>ty_s_http_config
      RETURNING
        VALUE(result) TYPE string.

ENDCLASS.

CLASS z2ui5_cl_core_ui5_app IMPLEMENTATION.

  METHOD index_html.

    IF is_config-styles_css IS INITIAL.
      DATA(lv_style_css) = NEW z2ui5_cl_core_ui5_app( )->css_style_css( ).
    ELSE.
      lv_style_css = is_config-styles_css.
    ENDIF.

    result = `<!DOCTYPE html>` && |\n| &&
               `<html lang="en">` && |\n| &&
               `<head>` && |\n| &&
                  is_config-content_security_policy && |\n| &&
               `    <meta charset="UTF-8">` && |\n| &&
               `    <meta name="viewport" content="width=device-width, initial-scale=1.0">` && |\n| &&
               `    <meta http-equiv="X-UA-Compatible" content="IE=edge">` && |\n| &&
                | <title> { is_config-title }</title> \n| &&
                | <style>        html, body, body > div, #container, #container-uiarea \{\n| &
                |            height: 100%;\n| &
                |        \}</style> \n| &&
                `<script>` && |\n| &&
             `  function onInitComponent(){` && |\n| &&
             `    sap.ui.require.preload({` && |\n| &&
             `      "z2ui5/manifest.json": '` && NEW z2ui5_cl_core_ui5_app( )->manifest_json( ) && ` ',` && |\n| &&
             `      "z2ui5/Component.js": function(){` && NEW z2ui5_cl_core_ui5_app( )->component_js( ) && is_config-custom_js && ` },` && |\n| &&
             `      "z2ui5/css/style.css": '` && lv_style_css && `',` && |\n| &&
             `      "z2ui5/model/models.js": function(){` && NEW z2ui5_cl_core_ui5_app( )->model_models_js( ) && `},` && |\n| &&
             `      "z2ui5/i18n/i18n.properties": '` && NEW z2ui5_cl_core_ui5_app( )->i18n_i18n_properties( ) && `' ,` && |\n| &&
             `      "z2ui5/view/App.view.xml": '` && NEW z2ui5_cl_core_ui5_app( )->view_app_xml( )  && `' ,` && |\n| &&
             `      "z2ui5/controller/App.controller.js": function(){` && NEW z2ui5_cl_core_ui5_app( )->controller_app_js( ) && `},` && |\n| &&
             `      "z2ui5/view/View1.view.xml": '` && NEW z2ui5_cl_core_ui5_app( )->view_view1_xml( )  && `' ,` && |\n| &&
             `      "z2ui5/controller/View1.controller.js": function(){` && NEW z2ui5_cl_core_ui5_app( )->controller_view1_js( ) && `},` && |\n| &&
             `      "z2ui5/cc/DebugTool.fragment.xml": '` && z2ui5_cl_cc_debug_tool=>get_xml( )  && `' ,` && |\n| &&
             `      "z2ui5/cc/DebugTool.js": function(){` && z2ui5_cl_cc_debug_tool=>get_js( ) && `},` && |\n| &&
             `    });` && |\n| &&
             `    sap.ui.require(["sap/ui/core/ComponentSupport"], function(ComponentSupport){` && |\n| &&
             `      ComponentSupport.run();` && |\n| &&
             `    });` && |\n| &&
             `  }` && |\n| &&
             `</script>` && |\n| &&
                `<script id="sap-ui-bootstrap" data-sap-ui-resourceroots='{ "z2ui5": "./" }' data-sap-ui-oninit="onInitComponent" ` && |\n| &&
                 `data-sap-ui-compatVersion="edge" data-sap-ui-async="true" data-sap-ui-frameOptions="trusted" data-sap-ui-bindingSyntax="complex"` && |\n| &&
                 `data-sap-ui-theme="` &&  is_config-theme   &&  `" src=" ` && is_config-src && `"   `.

    LOOP AT is_config-t_add_config REFERENCE INTO DATA(lr_config).
      result = result && | { lr_config->n }='{ lr_config->v }'|.
    ENDLOOP.

    result = result &&
        ` ></script></head>` && |\n| &&
        `<body class="sapUiBody sapUiSizeCompact" id="content">` && |\n| &&
        `    <div data-sap-ui-component data-name="z2ui5" data-id="container" data-settings='{"id" : "z2ui5"}' data-handle-validation="true"></div>` && |\n| &&
        ` </body></html>`.

  ENDMETHOD.

  METHOD component_js.

    result =
                 |  sap.z2ui5 = sap.z2ui5 \|\| \{\} ; if ( typeof z2ui5 == "undefined" ) \{ var z2ui5 = \{\}; \}; \n| &&
                 |  sap.z2ui5.pathname = window.location.pathname; | &&
                 `sap.ui.define(["sap/ui/core/UIComponent", "sap/ui/Device" , "z2ui5/model/models" ], function(UIComponent, Device, models) {` && |\n| &&
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

    result =  `          sap.ui.define(["sap/ui/core/mvc/Controller",  "z2ui5/controller/View1.controller", "sap/ui/core/BusyIndicator" , "z2ui5/cc/DebugTool" ], function(BaseController, Controller, BusyIndicator, DebugTool){` && |\n| &&
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
                 `                      sap.z2ui5.onBeforeRoundtrip = [];` && |\n| &&
                 `                      sap.z2ui5.onAfterRendering = [];` && |\n| &&
                 `                      sap.z2ui5.onBeforeEventFrontend = [];` && |\n| &&
                 `                      sap.z2ui5.onAfterRoundtrip = []; ` && |\n| &&
                 `                      sap.z2ui5.DebugTool = new DebugTool()` && |\n| &&
                 `                      sap.z2ui5.oController.Roundtrip();` && |\n| &&
                 `                  }` && |\n| &&
                 `              });` && |\n| &&
                 `          });`.

  ENDMETHOD.

  METHOD controller_view1_js.

    result = `` && |\n|  &&
`sap.ui.define(["sap/ui/core/mvc/Controller", "sap/ui/core/mvc/XMLView", "sap/ui/model/json/JSONModel", "sap/ui/core/BusyIndicator", "sap/m/MessageBox", "sap/m/MessageToast", "sap/ui/core/Fragment", "sap/m/BusyDialog", "sap/ui/VersionInfo"],` && |\n|  &&
            `    function (Controller, XMLView, JSONModel, BusyIndicator, MessageBox, MessageToast, Fragment, mBusyDialog, VersionInfo) {` && |\n|  &&
            `        "use strict";` && |\n|  &&
            `        return Controller.extend("z2ui5.controller.View1", {` && |\n|  &&
            `            async onAfterRendering() {` && |\n|  &&
            `                try {` && |\n|  &&
            `                    if (!sap.z2ui5.oResponse.PARAMS) {` && |\n|  &&
            `                        BusyIndicator.hide();` && |\n|  &&
            `                        sap.z2ui5.isBusy = false;` && |\n|  &&
            `                        return;` && |\n|  &&
            `                    }` && |\n|  &&
            |\n|  &&
            `                    const { S_POPUP, S_VIEW_NEST, S_VIEW_NEST2, S_POPOVER } = sap.z2ui5.oResponse.PARAMS;` && |\n|  &&
            `                    if (S_POPUP?.CHECK_DESTROY) {` && |\n|  &&
            `                        sap.z2ui5.oController.PopupDestroy();` && |\n|  &&
            `                    }` && |\n|  &&
            `                    if (S_POPOVER?.CHECK_DESTROY) {` && |\n|  &&
            `                        sap.z2ui5.oController.PopoverDestroy();` && |\n|  &&
            `                    }` && |\n|  &&
            `                    if (S_POPUP?.XML) {` && |\n|  &&
            `                        sap.z2ui5.oController.PopupDestroy();` && |\n|  &&
            `                        await this.displayFragment(S_POPUP.XML, 'oViewPopup');` && |\n|  &&
            `                    }` && |\n|  &&
            `                    if (!sap.z2ui5.checkNestAfter) {` && |\n|  &&
            `                        if (S_VIEW_NEST?.XML) {` && |\n|  &&
            `                            sap.z2ui5.oController.NestViewDestroy();` && |\n|  &&
            `                            await this.displayNestedView(S_VIEW_NEST.XML, 'oViewNest', 'S_VIEW_NEST');` && |\n|  &&
            `                            sap.z2ui5.checkNestAfter = true;` && |\n|  &&
            `                        }` && |\n|  &&
            `                    }` && |\n|  &&
            `                    if (!sap.z2ui5.checkNestAfter2) {` && |\n|  &&
            `                        if (S_VIEW_NEST2?.XML) {` && |\n|  &&
            `                            sap.z2ui5.oController.NestViewDestroy2();` && |\n|  &&
            `                            await this.displayNestedView2(S_VIEW_NEST2.XML, 'oViewNest2', 'S_VIEW_NEST2');` && |\n|  &&
            `                            sap.z2ui5.checkNestAfter2 = true;` && |\n|  &&
            `                        }` && |\n|  &&
            `                    }` && |\n|  &&
            `                    if (S_POPOVER?.XML) {` && |\n|  &&
            `                        await this.displayPopover(S_POPOVER.XML, 'oViewPopover', S_POPOVER.OPEN_BY_ID);` && |\n|  &&
            `                    }` && |\n|  &&
            `                    BusyIndicator.hide();` && |\n|  &&
            `                    sap.z2ui5.isBusy = false;` && |\n|  &&
            `                    sap.z2ui5.onAfterRendering.forEach(item => {` && |\n|  &&
            `                        if (item !== undefined) {` && |\n|  &&
            `                            item();` && |\n|  &&
            `                        }` && |\n|  &&
            `                    }` && |\n|  &&
            `                    )` && |\n|  &&
            `                } catch (e) {` && |\n|  &&
            `                    BusyIndicator.hide(); sap.z2ui5.isBusy = false; MessageBox.error(e.toLocaleString(), {` && |\n|  &&
            `                        title: "Unexpected Error Occured - App Terminated", actions: [], onClose: () => {` && |\n|  &&
            `                            new mBusyDialog({` && |\n|  &&
            `                                text: "Please Restart the App"` && |\n|  &&
            `                            }).open();` && |\n|  &&
            `                        }` && |\n|  &&
            `                    })` && |\n|  &&
            `                }` && |\n|  &&
            `            },` && |\n|  &&
            |\n|  &&
            `            async displayFragment(xml, viewProp) {` && |\n|  &&
            `                let oview_model = new JSONModel(sap.z2ui5.oResponse.OVIEWMODEL);` && |\n|  &&
            `                const oFragment = await Fragment.load({` && |\n|  &&
            `                    definition: xml,` && |\n|  &&
            `                    controller: sap.z2ui5.oControllerPopup,` && |\n|  &&
            `                    id: "popupId"` && |\n|  &&
            `                });` && |\n|  &&
            `            //   oview_model.setSizeLimit(sap.z2ui5.JSON_MODEL_LIMIT);` && |\n|  &&
            `                oFragment.setModel(oview_model);` && |\n|  &&
            `                sap.z2ui5[viewProp] = oFragment;` && |\n|  &&
            `                sap.z2ui5[viewProp].Fragment = Fragment;` && |\n|  &&
            `                oFragment.open();` && |\n|  &&
            `            },` && |\n|  &&
            `            async displayPopover(xml, viewProp, openById) {` && |\n|  &&
            `                // let sapUiCore = sap.ui.require('sap/ui/core/Core');` && |\n|  &&
            `                sap.ui.require(["sap/ui/core/Element"], async function (Element) {` && |\n|  &&
            `                    const oFragment = await Fragment.load({` && |\n|  &&
            `                        definition: xml,` && |\n|  &&
            `                        controller: sap.z2ui5.oControllerPopover,` && |\n|  &&
            `                        id: "popoverId"` && |\n|  &&
            `                    });` && |\n|  &&
            `                    let oview_model = new JSONModel(sap.z2ui5.oResponse.OVIEWMODEL);` && |\n|  &&
            `           //         oview_model.setSizeLimit(sap.z2ui5.JSON_MODEL_LIMIT);` && |\n|  &&
            `                    oFragment.setModel(oview_model);` && |\n|  &&
            `                    sap.z2ui5[viewProp] = oFragment;` && |\n|  &&
            `                    sap.z2ui5[viewProp].Fragment = Fragment;` && |\n|  &&
            `                    let oControl = {};` && |\n|  &&
            `                    if (sap.z2ui5.oView?.byId(openById)) {` && |\n|  &&
            `                        oControl = sap.z2ui5.oView.byId(openById);` && |\n|  &&
            `                    } else if (sap.z2ui5.oViewPopup?.Fragment.byId('popupId', openById)) {` && |\n|  &&
            `                        oControl = sap.z2ui5.oViewPopup.Fragment.byId('popupId', openById);` && |\n|  &&
            `                    } else if (sap.z2ui5.oViewNest?.byId(openById)) {` && |\n|  &&
            `                        oControl = sap.z2ui5.oViewNest.byId(openById);` && |\n|  &&
            `                    } else if (sap.z2ui5.oViewNest2?.byId(openById)) {` && |\n|  &&
            `                        oControl = sap.z2ui5.oViewNest2.byId(openById);` && |\n|  &&
            `                    } else {` && |\n|  &&
            `                        if (sapUiCore.byId(openById)) {` && |\n|  &&
            `                            //   oControl = sapUiCore.byId(openById);` && |\n|  &&
            `                            oControl = Element.getElementById(openById);` && |\n|  &&
            `                        } else {` && |\n|  &&
            `                            oControl = null;` && |\n|  &&
            `                        };` && |\n|  &&
            `                    }` && |\n|  &&
            `                    oFragment.openBy(oControl);` && |\n|  &&
            `                });` && |\n|  &&
            `            },` && |\n|  &&
            `            async displayNestedView(xml, viewProp, viewNestId) {` && |\n|  &&
            `                let oview_model = new JSONModel(sap.z2ui5.oResponse.OVIEWMODEL);` && |\n|  &&
            `                const oView = await XMLView.create({` && |\n|  &&
            `                    definition: xml,` && |\n|  &&
            `                    controller: sap.z2ui5.oControllerNest,` && |\n|  &&
            `                    preprocessors: { xml: { models: { template: oview_model } } }` && |\n|  &&
            `                });` && |\n|  &&
            `       //         oview_model.setSizeLimit(sap.z2ui5.JSON_MODEL_LIMIT);` && |\n|  &&
            `                oView.setModel(oview_model);` && |\n|  &&
            `                let oParent = sap.z2ui5.oView.byId(sap.z2ui5.oResponse.PARAMS[viewNestId].ID);` && |\n|  &&
            `                if (oParent) {` && |\n|  &&
            `                    try {` && |\n|  &&
            `                        oParent[sap.z2ui5.oResponse.PARAMS[viewNestId].METHOD_DESTROY]();` && |\n|  &&
            `                    } catch { }` && |\n|  &&
            `                    oParent[sap.z2ui5.oResponse.PARAMS[viewNestId].METHOD_INSERT](oView);` && |\n|  &&
            `                }` && |\n|  &&
            `                sap.z2ui5[viewProp] = oView;` && |\n|  &&
            `            },` && |\n|  &&
            `            async displayNestedView2(xml, viewProp, viewNestId) {` && |\n|  &&
            `                let oview_model = new JSONModel(sap.z2ui5.oResponse.OVIEWMODEL);` && |\n|  &&
            `                const oView = await XMLView.create({` && |\n|  &&
            `                    definition: xml,` && |\n|  &&
            `                    controller: sap.z2ui5.oControllerNest2,` && |\n|  &&
            `                    preprocessors: { xml: { models: { template: oview_model } } }` && |\n|  &&
            `                });` && |\n|  &&
            `      //          oview_model.setSizeLimit(sap.z2ui5.JSON_MODEL_LIMIT);` && |\n|  &&
            `                oView.setModel(oview_model);` && |\n|  &&
            `                let oParent = sap.z2ui5.oView.byId(sap.z2ui5.oResponse.PARAMS[viewNestId].ID);` && |\n|  &&
            `                if (oParent) {` && |\n|  &&
            `                    try {` && |\n|  &&
            `                        oParent[sap.z2ui5.oResponse.PARAMS[viewNestId].METHOD_DESTROY]();` && |\n|  &&
            `                    } catch { }` && |\n|  &&
            `                    oParent[sap.z2ui5.oResponse.PARAMS[viewNestId].METHOD_INSERT](oView);` && |\n|  &&
            `                }` && |\n|  &&
            `                sap.z2ui5[viewProp] = oView;` && |\n|  &&
            `            },` && |\n|  &&
            `            PopupDestroy() {` && |\n|  &&
            `                if (!sap.z2ui5.oViewPopup) {` && |\n|  &&
            `                    return;` && |\n|  &&
            `                }` && |\n|  &&
            `                if (sap.z2ui5.oViewPopup.close) {` && |\n|  &&
            `                    try {` && |\n|  &&
            `                        sap.z2ui5.oViewPopup.close();` && |\n|  &&
            `                    } catch { }` && |\n|  &&
            `                }` && |\n|  &&
            `                sap.z2ui5.oViewPopup.destroy();` && |\n|  &&
            `            },` && |\n|  &&
            `            PopoverDestroy() {` && |\n|  &&
            `                if (!sap.z2ui5.oViewPopover) {` && |\n|  &&
            `                    return;` && |\n|  &&
            `                }` && |\n|  &&
            `                if (sap.z2ui5.oViewPopover.close) {` && |\n|  &&
            `                    try {` && |\n|  &&
            `                        sap.z2ui5.oViewPopover.close();` && |\n|  &&
            `                    } catch { }` && |\n|  &&
            `                }` && |\n|  &&
            `                sap.z2ui5.oViewPopover.destroy();` && |\n|  &&
            `            },` && |\n|  &&
            `            NestViewDestroy() {` && |\n|  &&
            `                if (!sap.z2ui5.oViewNest) {` && |\n|  &&
            `                    return;` && |\n|  &&
            `                }` && |\n|  &&
            `                sap.z2ui5.oViewNest.destroy();` && |\n|  &&
            `            },` && |\n|  &&
            `            NestViewDestroy2() {` && |\n|  &&
            `                if (!sap.z2ui5.oViewNest2) {` && |\n|  &&
            `                    return;` && |\n|  &&
            `                }` && |\n|  &&
            `                sap.z2ui5.oViewNest2.destroy();` && |\n|  &&
            `            },` && |\n|  &&
            `            ViewDestroy() {` && |\n|  &&
            `                if (!sap.z2ui5.oView) {` && |\n|  &&
            `                    return;` && |\n|  &&
            `                }` && |\n|  &&
            `                sap.z2ui5.oView.destroy();` && |\n|  &&
            `            },` && |\n|  &&
            `            eF(...args) {` && |\n|  &&
            `                sap.z2ui5.onBeforeEventFrontend.forEach(item => {` && |\n|  &&
            `                    if (item !== undefined) {` && |\n|  &&
            `                        item(args);` && |\n|  &&
            `                    }` && |\n|  &&
            `                }` && |\n|  &&
            `                )` && |\n|  &&
            `                let oCrossAppNavigator;` && |\n|  &&
            `                switch (args[0]) {` && |\n|  &&
            `                    case 'SET_SIZE_LIMIT':` && |\n|  &&
            `                       switch (args[2]) { ` && |\n|  &&
            `                        case 'MAIN': sap.z2ui5.oView.getModel().setSizeLimit( parseInt( args[1] ) ); sap.z2ui5.oView.getModel().refresh(true); break; ` && |\n|  &&
            `                        case 'NEST': sap.z2ui5.oViewNest.getModel().setSizeLimit( parseInt( args[1] ) ); sap.z2ui5.oViewNest.getModel().refresh(true); break; ` && |\n|  &&
            `                        case 'NEST2': sap.z2ui5.oViewNest2.getModel().setSizeLimit( parseInt( args[1] ) ); sap.z2ui5.oViewNest2.getModel().refresh(true); break; ` && |\n|  &&
            `                        case 'POPUP': sap.z2ui5.oPopup.getModel().setSizeLimit( parseInt( args[1] ) ); sap.z2ui5.oPopup.getModel().refresh(true); break; ` && |\n|  &&
            `                        case 'POPOVER': sap.z2ui5.oPopover.getModel().setSizeLimit( parseInt( args[1] ) ); sap.z2ui5.oPopover.getModel().refresh(true); break; ` && |\n|  &&
            `                        }` && |\n|  &&
            `                        break;` && |\n|  &&
            `                    case 'DOWNLOAD_B64_FILE':` && |\n|  &&
            `                        var a = document.createElement("a");` && |\n|  &&
            `                        a.href = args[1];` && |\n|  &&
            `                        a.download = args[2];` && |\n|  &&
            `                        a.click();` && |\n|  &&
            `                        break;` && |\n|  &&
            `                    case 'CROSS_APP_NAV_TO_PREV_APP':` && |\n|  &&
            `                        oCrossAppNavigator = sap.ushell.Container.getService("CrossApplicationNavigation");` && |\n|  &&
            `                        oCrossAppNavigator.backToPreviousApp();` && |\n|  &&
            `                        break;` && |\n|  &&
            `                    case 'CROSS_APP_NAV_TO_EXT':` && |\n|  &&
            `                        oCrossAppNavigator = sap.ushell.Container.getService("CrossApplicationNavigation");` && |\n|  &&
            `                        const hash = (oCrossAppNavigator.hrefForExternal({` && |\n|  &&
            `                            target: args[1],` && |\n|  &&
            `                            params: args[2]` && |\n|  &&
            `                        })) || "";` && |\n|  &&
            `                        if (args[3] === 'EXT') {` && |\n|  &&
            `                            let url = window.location.href.split('#')[0] + hash;` && |\n|  &&
            `                            sap.m.URLHelper.redirect(url, true);` && |\n|  &&
            `                        } else {` && |\n|  &&
            `                            oCrossAppNavigator.toExternal({` && |\n|  &&
            `                                target: {` && |\n|  &&
            `                                    shellHash: hash` && |\n|  &&
            `                                }` && |\n|  &&
            `                            });` && |\n|  &&
            `                        }` && |\n|  &&
            `                        break;` && |\n|  &&
            `                    case 'LOCATION_RELOAD':` && |\n|  &&
            `                        window.location = args[1];` && |\n|  &&
            `                        break;` && |\n|  &&
            `                    case 'OPEN_NEW_TAB':` && |\n|  &&
            `                        window.open(args[1], '_blank');` && |\n|  &&
            `                        break;` && |\n|  &&
            `                    case 'POPUP_CLOSE':` && |\n|  &&
            `                        sap.z2ui5.oController.PopupDestroy();` && |\n|  &&
            `                        break;` && |\n|  &&
            `                    case 'POPOVER_CLOSE':` && |\n|  &&
            `                        sap.z2ui5.oController.PopoverDestroy();` && |\n|  &&
            `                        break;` && |\n|  &&
            `                    case 'NAV_CONTAINER_TO':` && |\n|  &&
            `                        var navCon = sap.z2ui5.oView.byId(args[1]);` && |\n|  &&
            `                        var navConTo = sap.z2ui5.oView.byId(args[2]);` && |\n|  &&
            `                        navCon.to(navConTo);` && |\n|  &&
            `                        break;` && |\n|  &&
            `                    case 'NEST_NAV_CONTAINER_TO':` && |\n|  &&
            `                        navCon = sap.z2ui5.oViewNest.byId(args[1]);` && |\n|  &&
            `                        navConTo = sap.z2ui5.oViewNest.byId(args[2]);` && |\n|  &&
            `                        navCon.to(navConTo);` && |\n|  &&
            `                        break;` && |\n|  &&
            `                    case 'NEST2_NAV_CONTAINER_TO':` && |\n|  &&
            `                        navCon = sap.z2ui5.oViewNest2.byId(args[1]);` && |\n|  &&
            `                        navConTo = sap.z2ui5.oViewNest2.byId(args[2]);` && |\n|  &&
            `                        navCon.to(navConTo);` && |\n|  &&
            `                        break;` && |\n|  &&
            `                    case 'POPUP_NAV_CONTAINER_TO':` && |\n|  &&
            `                        navCon = Fragment.byId("popupId", args[1]);` && |\n|  &&
            `                        navConTo = Fragment.byId("popupId", args[2]);` && |\n|  &&
            `                        navCon.to(navConTo);` && |\n|  &&
            `                        break;` && |\n|  &&
            `                }` && |\n|  &&
            `            },` && |\n|  &&
            `            eB(...args) {` && |\n|  &&
            `                if (!window.navigator.onLine) {` && |\n|  &&
            `                    MessageBox.alert('No internet connection! Please reconnect to the server and try again.');` && |\n|  &&
            `                    return;` && |\n|  &&
            `                }` && |\n|  &&
            `                if (sap.z2ui5.isBusy == true) {` && |\n|  &&
            `                    if (!args[0][2]) {` && |\n|  &&
            `                        let oBusyDialog = new mBusyDialog();` && |\n|  &&
            `                        oBusyDialog.open();` && |\n|  &&
            `                        setTimeout((oBusyDialog) => { oBusyDialog.close() }, 100, oBusyDialog);` && |\n|  &&
            `                        return;` && |\n|  &&
            `                    }` && |\n|  &&
            `                }` && |\n|  &&
            `                sap.z2ui5.isBusy = true;` && |\n|  &&
            `                BusyIndicator.show();` && |\n|  &&
            `                sap.z2ui5.oBody = {};` && |\n|  &&
            `                if (args[0][3]) {` && |\n|  &&
            `                    sap.z2ui5.oBody.XX = sap.z2ui5.oView.getModel().getData().XX;` && |\n|  &&
            `                    sap.z2ui5.oBody.VIEWNAME = 'MAIN';` && |\n|  &&
            `                }` && |\n|  &&
            `                else if (sap.z2ui5.oController == this) {` && |\n|  &&
            `                    sap.z2ui5.oBody.XX = sap.z2ui5.oView.getModel().getData().XX;` && |\n|  &&
            `                    sap.z2ui5.oBody.VIEWNAME = 'MAIN';` && |\n|  &&
            `                } else if` && |\n|  &&
            `                    (sap.z2ui5.oControllerPopup == this) {` && |\n|  &&
            `                    if (sap.z2ui5.oViewPopup) {` && |\n|  &&
            `                        sap.z2ui5.oBody.XX = sap.z2ui5.oViewPopup.getModel().getData().XX;` && |\n|  &&
            `                    }` && |\n|  &&
            `                    sap.z2ui5.oBody.VIEWNAME = 'MAIN';` && |\n|  &&
            `                } else if (` && |\n|  &&
            `                    sap.z2ui5.oControllerPopover == this) {` && |\n|  &&
            `                    sap.z2ui5.oBody.XX = sap.z2ui5.oViewPopover.getModel().getData().XX;` && |\n|  &&
            `                    sap.z2ui5.oBody.VIEWNAME = 'MAIN';` && |\n|  &&
            `                } else if (` && |\n|  &&
            `                    sap.z2ui5.oControllerNest == this) {` && |\n|  &&
            `                    sap.z2ui5.oBody.XX = sap.z2ui5.oViewNest.getModel().getData().XX;` && |\n|  &&
            `                    sap.z2ui5.oBody.VIEWNAME = 'NEST';` && |\n|  &&
            `                } else if (` && |\n|  &&
            `                    sap.z2ui5.oControllerNest2 == this) {` && |\n|  &&
            `                    sap.z2ui5.oBody.XX = sap.z2ui5.oViewNest2.getModel().getData().XX;` && |\n|  &&
            `                    sap.z2ui5.oBody.VIEWNAME = 'NEST2';` && |\n|  &&
            `                }` && |\n|  &&
            `                sap.z2ui5.onBeforeRoundtrip.forEach(item => {` && |\n|  &&
            `                    if (item !== undefined) {` && |\n|  &&
            `                        item();` && |\n|  &&
            `                    }` && |\n|  &&
            `                })` && |\n|  &&
            `                if (args[0][1]) {` && |\n|  &&
            `                    sap.z2ui5.oController.ViewDestroy();` && |\n|  &&
            `                }` && |\n|  &&
            `                sap.z2ui5.oBody.ID = sap.z2ui5.oResponse.ID;` && |\n|  &&
            `                sap.z2ui5.oBody.ARGUMENTS = args;` && |\n|  &&
            `                sap.z2ui5.oBody.ARGUMENTS.forEach((item, i) => {` && |\n|  &&
            `                    if (i == 0) { return; } if (typeof item === 'object') {` && |\n|  &&
            `                        sap.z2ui5.oBody.ARGUMENTS[i] = JSON.stringify(item);` && |\n|  &&
            `                    }` && |\n|  &&
            `                });` && |\n|  &&
            `                sap.z2ui5.oResponseOld = sap.z2ui5.oResponse;` && |\n|  &&
            `                sap.z2ui5.oController.Roundtrip();` && |\n|  &&
            `            },` && |\n|  &&
            `            responseError(response) {` && |\n|  &&
            `                document.write(response);` && |\n|  &&
            `            },` && |\n|  &&
            `            updateModelIfRequired(paramKey, oView) {` && |\n|  &&
            `                if (sap.z2ui5.oResponse.PARAMS == undefined) { return; }` && |\n|  &&
            `                if (sap.z2ui5.oResponse.PARAMS[paramKey]?.CHECK_UPDATE_MODEL) {` && |\n|  &&
            `                    let model = new JSONModel(sap.z2ui5.oResponse.OVIEWMODEL);` && |\n|  &&
            `      //              model.setSizeLimit(sap.z2ui5.JSON_MODEL_LIMIT);` && |\n|  &&
            `                    if (oView) { oView.setModel(model); }` && |\n|  &&
            `                }` && |\n|  &&
            `            },` && |\n|  &&
            `            async responseSuccess(response) {` && |\n|  &&
            `                try {` && |\n|  &&
            `                    sap.z2ui5.oResponse = response;` && |\n|  &&
            `                    if (sap.z2ui5.oResponse.PARAMS?.S_VIEW?.CHECK_DESTROY) {` && |\n|  &&
            `                        sap.z2ui5.oController.ViewDestroy();` && |\n|  &&
            `                    };` && |\n|  &&
            `                    if (sap.z2ui5.oResponse.PARAMS?.S_FOLLOW_UP_ACTION?.CUSTOM_JS) {` && |\n|  &&
            `                        setTimeout(() => {` && |\n|  &&
            `                            let mParams = sap.z2ui5.oResponse?.PARAMS.S_FOLLOW_UP_ACTION.CUSTOM_JS.split("'");` && |\n|  &&
            `                            let mParamsEF = mParams.filter((val, index) => index % 2)` && |\n|  &&
            `                            if (mParamsEF.length) {` && |\n|  &&
            `                                sap.z2ui5.oController.eF.apply(undefined, mParamsEF);` && |\n|  &&
            `                            } else {` && |\n|  &&
            `                                Function("return " + mParams[0])();` && |\n|  &&
            `                            }` && |\n|  &&
            `                        }, 100);` && |\n|  &&
            `                    };` && |\n|  &&
            |\n|  &&
            `                    sap.z2ui5.oController.showMessage('S_MSG_TOAST', sap.z2ui5.oResponse.PARAMS);` && |\n|  &&
            `                    sap.z2ui5.oController.showMessage('S_MSG_BOX', sap.z2ui5.oResponse.PARAMS);` && |\n|  &&
            `                    if (sap.z2ui5.oResponse.PARAMS?.S_VIEW?.XML) {` && |\n|  &&
            `                        if (sap.z2ui5.oResponse.PARAMS?.S_VIEW?.XML !== '') {` && |\n|  &&
            `                            sap.z2ui5.oController.ViewDestroy();` && |\n|  &&
            `                            await sap.z2ui5.oController.createView(sap.z2ui5.oResponse.PARAMS.S_VIEW.XML, sap.z2ui5.oResponse.OVIEWMODEL);` && |\n|  &&
            `                            return;` && |\n|  &&
            `                        }` && |\n|  &&
            `                    }` && |\n|  &&
            `                    this.updateModelIfRequired('S_VIEW', sap.z2ui5.oView);` && |\n|  &&
            `                    this.updateModelIfRequired('S_VIEW_NEST', sap.z2ui5.oViewNest);` && |\n|  &&
            `                    this.updateModelIfRequired('S_VIEW_NEST2', sap.z2ui5.oViewNest2);` && |\n|  &&
            `                    this.updateModelIfRequired('S_POPUP', sap.z2ui5.oViewPopup);` && |\n|  &&
            `                    this.updateModelIfRequired('S_POPOVER', sap.z2ui5.oViewPopover);` && |\n|  &&
            `                    sap.z2ui5.oController.onAfterRendering();` && |\n|  &&
            `                } catch (e) {` && |\n|  &&
            `                    BusyIndicator.hide(); if (e.message.includes("openui5")) { if (e.message.includes("script load error")) { sap.z2ui5.oController.checkSDKcompatibility(e) } } else {` && |\n|  &&
            `                        MessageBox.error(e.toLocaleString());` && |\n|  &&
            `                    }` && |\n|  &&
            `                }` && |\n|  &&
            `            },` && |\n|  &&
            `            async checkSDKcompatibility(err) {` && |\n|  &&
            `                let oCurrentVersionInfo = await VersionInfo.load();` && |\n|  &&
            `                var ui5_sdk = oCurrentVersionInfo.gav.includes('com.sap.ui5') ? true : false;` && |\n|  &&
            `                if (!ui5_sdk) {` && |\n|  &&
            `                    if (err) {` && |\n|  &&
            `                        MessageBox.error("openui5 SDK is loaded, module: " + err._modules + " is not availabe in openui5");` && |\n|  &&
            `                        return;` && |\n|  &&
            `                    };` && |\n|  &&
            `                };` && |\n|  &&
            `                MessageBox.error(err.toLocaleString());` && |\n|  &&
            `            },` && |\n|  &&
            `            showMessage(msgType, params) {` && |\n|  &&
            `                if (params == undefined) { return; }` && |\n|  &&
            `                if (params[msgType]?.TEXT !== undefined) {` && |\n|  &&
            `                    if (msgType === 'S_MSG_TOAST') {` && |\n|  &&
            `                        MessageToast.show(params[msgType].TEXT, {` && |\n|  &&
            `                            duration: params[msgType].DURATION ? parseInt(params[msgType].DURATION) : 3000,` && |\n|  &&
            `                            width: params[msgType].WIDTH ? params[msgType].WIDTH : '15em',` && |\n|  &&
            `                            onClose: params[msgType].ONCLOSE ? params[msgType].ONCLOSE : null,` && |\n|  &&
            `                            autoClose: params[msgType].AUTOCLOSE ? true : false,` && |\n|  &&
            `                            animationTimingFunction: params[msgType].ANIMATIONTIMINGFUNCTION ? params[msgType].ANIMATIONTIMINGFUNCTION : 'ease',` && |\n|  &&
            `                            animationDuration: params[msgType].ANIMATIONDURATION ? parseInt(params[msgType].ANIMATIONDURATION) : 1000,` && |\n|  &&
            `                            closeonBrowserNavigation: params[msgType].CLOSEONBROWSERNAVIGATION ? true : false` && |\n|  &&
            `                        });` && |\n|  &&
            `                        if (params[msgType].CLASS) {` && |\n|  &&
            `                            let mtoast = {};` && |\n|  &&
            `                            mtoast = document.getElementsByClassName("sapMMessageToast")[0];` && |\n|  &&
            `                            if (mtoast) { mtoast.classList.add(params[msgType].CLASS); }` && |\n|  &&
            `                        };` && |\n|  &&
            `                    } else if (msgType === 'S_MSG_BOX') {` && |\n|  &&
            `                        if (params[msgType].TYPE) {` && |\n|  &&
            `                            MessageBox[params[msgType].TYPE](params[msgType].TEXT);` && |\n|  &&
            `                        } else {` && |\n|  &&
            `                            MessageBox.show(params[msgType].TEXT, {` && |\n|  &&
            `                                styleClass: params[msgType].STYLECLASS ? params[msgType].STYLECLASS : '',` && |\n|  &&
            `                                title: params[msgType].TITLE ? params[msgType].TITLE : '',` && |\n|  &&
            `                                onClose: params[msgType].ONCLOSE ? Function("sAction", "return " + params[msgType].ONCLOSE) : null,` && |\n|  &&
            `                                actions: params[msgType].ACTIONS ? params[msgType].ACTIONS : 'OK',` && |\n|  &&
            `                                emphasizedAction: params[msgType].EMPHASIZEDACTION ? params[msgType].EMPHASIZEDACTION : 'OK',` && |\n|  &&
            `                                initialFocus: params[msgType].INITIALFOCUS ? params[msgType].INITIALFOCUS : null,` && |\n|  &&
            `                                textDirection: params[msgType].TEXTDIRECTION ? params[msgType].TEXTDIRECTION : 'Inherit',` && |\n|  &&
            `                                icon: params[msgType].ICON ? params[msgType].ICON : 'NONE',` && |\n|  &&
            `                                details: params[msgType].DETAILS ? params[msgType].DETAILS : '',` && |\n|  &&
            `                                closeOnNavigation: params[msgType].CLOSEONNAVIGATION ? true : false` && |\n|  &&
            `                            }` && |\n|  &&
            `                            )` && |\n|  &&
            `                        }` && |\n|  &&
            `                    }` && |\n|  &&
            `                }` && |\n|  &&
            `            },` && |\n|  &&
            `            setApp(oApp) {` && |\n|  &&
            `                this._oApp = oApp;` && |\n|  &&
            `            },` && |\n|  &&
            `            async createView(xml, viewModel) {` && |\n|  &&
            `                let oview_model = new JSONModel(viewModel);` && |\n|  &&
            `             //   oview_model.setSizeLimit(sap.z2ui5.JSON_MODEL_LIMIT);` && |\n|  &&
            `                sap.z2ui5.oView = await XMLView.create({` && |\n|  &&
            `                    definition: xml,` && |\n|  &&
            `                    models: oview_model,` && |\n|  &&
            `                    controller: sap.z2ui5.oController,` && |\n|  &&
            `                    id: 'mainView',` && |\n|  &&
            `                    preprocessors: { xml: { models: { template: oview_model } } }` && |\n|  &&
            `                });` && |\n|  &&
            `                sap.z2ui5.oView.setModel(sap.z2ui5.oDeviceModel, "device");` && |\n|  &&
            `        //        if (sap.z2ui5.oParent) {` && |\n|  &&
            `        //            sap.z2ui5.oParent.removeAllPages();` && |\n|  &&
            `        //            sap.z2ui5.oParent.insertPage(sap.z2ui5.oView);` && |\n|  &&
            `        //        } else {` && |\n|  &&
            `                    this._oApp.byId("viewContainer").insertPage(sap.z2ui5.oView);` && |\n|  &&
            `                    //  this._oApp.byId("viewContainer").addItem(sap.z2ui5.oView);` && |\n|  &&
            `        //        }` && |\n|  &&
            `            },` && |\n|  &&
            `            async readHttp() {` && |\n|  &&
            |\n|  &&
            `                const response = await fetch(sap.z2ui5.pathname, {` && |\n|  &&
            `                    method: 'POST',` && |\n|  &&
            `                    headers: {` && |\n|  &&
            `                        'Content-Type': 'application/json',` && |\n|  &&
            `                        'sap-contextid-accept': 'header',` && |\n|  &&
            `                        'sap-contextid': sap.z2ui5.contextId` && |\n|  &&
            `                    },` && |\n|  &&
            `                    body: JSON.stringify(sap.z2ui5.oBody)` && |\n|  &&
            `                });` && |\n|  &&
            `                sap.z2ui5.contextId = response.headers.get("sap-contextid");` && |\n|  &&
            `                if (!response.ok) {` && |\n|  &&
            `                    const responseText = await response.text();` && |\n|  &&
            `                    sap.z2ui5.oController.responseError(responseText);` && |\n|  &&
            `                } else {` && |\n|  &&
            `                    const responseData = await response.json();` && |\n|  &&
            `                    sap.z2ui5.responseData = responseData;` && |\n|  &&
            `                    sap.z2ui5.oController.responseSuccess({` && |\n|  &&
            `                        ID: responseData.S_FRONT.ID,` && |\n|  &&
            `                        PARAMS: responseData.S_FRONT.PARAMS,` && |\n|  &&
            `                        OVIEWMODEL: responseData.MODEL,` && |\n|  &&
            `                    });` && |\n|  &&
            `                }` && |\n|  &&
            `            },` && |\n|  &&
            `            Roundtrip() {` && |\n|  &&
            `                sap.z2ui5.checkTimerActive = false;` && |\n|  &&
            `                sap.z2ui5.checkNestAfter = false;` && |\n|  &&
            `                sap.z2ui5.checkNestAfter2 = false;` && |\n|  &&
            `                let event = (args) => { if (args != undefined) { return args[0][0]; } };` && |\n|  &&
            `                sap.z2ui5.oBody.S_FRONT = {` && |\n|  &&
            `                    ID: sap.z2ui5?.oBody?.ID,` && |\n|  &&
            `                    COMPDATA: (sap.z2ui5.ComponentData) ? sap.z2ui5.ComponentData : {},` && |\n|  &&
            `                    XX: sap.z2ui5?.oBody?.XX,` && |\n|  &&
            `                    ORIGIN: window.location.origin,` && |\n|  &&
            `                    PATHNAME: window.location.pathname, // sap.z2ui5.pathname,` && |\n|  &&
            `                    SEARCH: (sap.z2ui5.search) ? sap.z2ui5.search : window.location.search,` && |\n|  &&
            `                    VIEW: sap.z2ui5.oBody?.VIEWNAME,` && |\n|  &&
            `                    T_STARTUP_PARAMETERS: sap.z2ui5.startupParameters,` && |\n|  &&
            `                    EVENT: event(sap.z2ui5.oBody?.ARGUMENTS),` && |\n|  &&
            `                };` && |\n|  &&
            `                if (sap.z2ui5.oBody?.ARGUMENTS != undefined) { if (sap.z2ui5.oBody?.ARGUMENTS.length > 0) { sap.z2ui5.oBody?.ARGUMENTS.shift(); } }` && |\n|  &&
            `                sap.z2ui5.oBody.S_FRONT.T_EVENT_ARG = sap.z2ui5.oBody?.ARGUMENTS;` && |\n|  &&
            `                delete sap.z2ui5.oBody.ID;` && |\n|  &&
            `                delete sap.z2ui5.oBody?.VIEWNAME;` && |\n|  &&
            `                delete sap.z2ui5.oBody?.S_FRONT.XX;` && |\n|  &&
            `                delete sap.z2ui5.oBody?.ARGUMENTS;` && |\n|  &&
            `                if (!sap.z2ui5.oBody.S_FRONT.T_EVENT_ARG) { delete sap.z2ui5.oBody.S_FRONT.T_EVENT_ARG; }` && |\n|  &&
            `                if (sap.z2ui5.oBody.S_FRONT.T_EVENT_ARG) { if (sap.z2ui5.oBody.S_FRONT.T_EVENT_ARG.length == 0) { delete sap.z2ui5.oBody.S_FRONT.T_EVENT_ARG; } }` && |\n|  &&
            `                if (sap.z2ui5.oBody.S_FRONT.T_STARTUP_PARAMETERS == undefined) { delete sap.z2ui5.oBody.S_FRONT.T_STARTUP_PARAMETERS; }` && |\n|  &&
            `                if (sap.z2ui5.oBody.S_FRONT.SEARCH == '') { delete sap.z2ui5.oBody.S_FRONT.SEARCH; }` && |\n|  &&
            `                if (!sap.z2ui5.oBody.XX) { delete sap.z2ui5.oBody.XX; }` && |\n|  &&
            `                sap.z2ui5.oController.readHttp();` && |\n|  &&
            `            },` && |\n|  &&
            `        })` && |\n|  &&
            `    });`.

  ENDMETHOD.

  METHOD manifest_json.

    result = `{` &&
             `    "_version": "1.50.0",` &&
             `    "sap.app": {` &&
             `        "id": "z2ui5",` &&
             `        "type": "application",` &&
             `        "i18n": "i18n/i18n.properties",` &&
             `        "applicationVersion": {` &&
             `            "version": "0.0.2"` &&
             `        },` &&
*             `        "title": "{{appTitle}}",` &&
*             `        "description": "{{appDescription}}",` &&
*             `        "resources": "resources.json",` &&
             `        "sourceTemplate": {` &&
             `            "id": "@sap/generator-fiori:basic",` &&
             `            "version": "1.10.4",` &&
             `            "toolsId": "45f51711-e1b8-4fc4-bc1b-9e341941c532"` &&
             `        },` &&
             `        "dataSources": {` &&
             `            "mainService": {` &&
             `                "uri": "/sap/bc/z2ui5",` &&
             `                "type": "http"` &&
             `            }` &&
             `        }` &&
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
             `                "sap.m": {},` &&
             `                "sap.ui.core": {},` &&
             `                "sap.f": {},` &&
             `                "sap.ui.table": {}` &&
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
             `        "models": {` &&
             `            "i18n": {` &&
             `                "type": "sap.ui.model.resource.ResourceModel",` &&
             `                "settings": {` &&
             `                    "bundleName": "z2ui5.i18n.i18n"` &&
             `                }` &&
             `            }` &&
             `        },` &&
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
             `}`.

  ENDMETHOD.

  METHOD view_app_xml.

    result = `<mvc:View xmlns:mvc="sap.ui.core.mvc" displayBlock="true" xmlns="sap.m" controllerName="z2ui5.controller.App">` &&
            ` <App id="viewContainer"></App>` &&
            `</mvc:View>`.

  ENDMETHOD.

  METHOD view_view1_xml.

    result = `<mvc:View controllerName="z2ui5.controller.View1"`  &&
             `    xmlns:mvc="sap.ui.core.mvc" displayBlock="true"`  &&
             `    xmlns="sap.m">`  &&
             `</mvc:View>`.

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
