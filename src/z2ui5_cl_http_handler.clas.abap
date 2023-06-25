CLASS z2ui5_cl_http_handler DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.

    CLASS-METHODS http_get
      IMPORTING
        t_config                TYPE z2ui5_if_client=>ty_t_name_value OPTIONAL
        content_security_policy TYPE clike                            OPTIONAL
        check_logging           TYPE abap_bool                        DEFAULT abap_false
      RETURNING
        VALUE(r_result)         TYPE string ##NEEDED.

    CLASS-METHODS http_post
      IMPORTING
        body          TYPE string
        path_info     TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_cl_http_handler IMPLEMENTATION.


  METHOD http_get.

    DATA(lt_Config) = t_config.




    IF lt_config IS INITIAL.
      lt_config = VALUE #(
          (  name = `data-sap-ui-theme`         value = `sap_horizon` )
          (  name = `src`                       value = `https://sdk.openui5.org/resources/sap-ui-cachebuster/sap-ui-core.js` )
          (  name = `data-sap-ui-libs`          value = `sap.m` )
          (  name = `data-sap-ui-bindingSyntax` value = `complex` )
          (  name = `data-sap-ui-frameOptions`  value = `trusted` )
          (  name = `data-sap-ui-compatVersion` value = `edge` ) ).
    ENDIF.

    IF content_security_policy IS NOT SUPPLIED.
      DATA(lv_sec_policy) = `<meta http-equiv="Content-Security-Policy" content="default-src 'self' 'unsafe-inline' 'unsafe-eval' data: ` &&
        `ui5.sap.com *.ui5.sap.com sapui5.hana.ondemand.com *.sapui5.hana.ondemand.com sdk.openui5.org *.sdk.openui5.org cdn.jsdelivr.net *.cdn.jsdelivr.net"/>`.
    ELSE.
      lv_sec_policy = content_security_policy.
    ENDIF.
    z2ui5_lcl_fw_db=>cleanup( ).

    r_result = `<html>` && |\n| &&
               `<head>` && |\n| &&
                  lv_sec_policy && |\n| &&
               `    <meta charset="UTF-8">` && |\n| &&
               `    <meta name="viewport" content="width=device-width, initial-scale=1.0">` && |\n| &&
               `    <meta http-equiv="X-UA-Compatible" content="IE=edge">` && |\n| &&
               `    <title>abap2UI5</title>` && |\n| &&
               `    <style>` && |\n| &&
               `        html, body, body > div, #container, #container-uiarea {` && |\n| &&
               `            height: 100%;` && |\n| &&
               `        }` && |\n| &&
               `    </style> ` &&
               `    <script id="sap-ui-bootstrap"`.

    LOOP AT lt_config REFERENCE INTO DATA(lr_config).
      r_result = r_result && | { lr_config->name }="{ lr_config->value }"|.
    ENDLOOP.

    r_result = r_result &&
        ` ></script></head>` && |\n| &&
        `<body class="sapUiBody sapUiSizeCompact" >` && |\n| &&
        `    <div id="content"  data-handle-validation="true" ></div>` && |\n| &&
        `</body>` && |\n| &&
        `</html>` && |\n|.
    r_result = r_result && `<abc/>` && |\n|  &&
                           `<script id="z2ui5">` && |\n|  &&
                           `    sap.ui.getCore().attachInit(function () {` && |\n|  &&
                           `        "use strict";` && |\n|  &&
                           |\n|  &&
                           `        sap.ui.controller("z2ui5_controller", {` && |\n|  &&
                           |\n|  &&
                           `            onAfterRendering: function () {` && |\n|  &&
                           `                sap.z2ui5.onAfter();` && |\n|  &&
                           `            },` && |\n|  &&
                           `            onEventFrontend: function (oEvent) {` && |\n|  &&
                           |\n|  &&
                           `                switch (oEvent.EVENT) {` && |\n|  &&
                           |\n|  &&
                           `                    case 'LEAVE_HOME':` && |\n|  &&
                           `                       window.location = window.location.href.split( sap.z2ui5.oResponse.PARAMS.PATH )[ 0 ];` && |\n|  &&
                           `                        break;` && |\n|  &&
                           `                    case 'POPUP_CLOSE':` && |\n|  &&
                           `                        if (sap.z2ui5.oViewPopup.close) {` && |\n|  &&
                           `                            sap.z2ui5.oViewPopup.close();` && |\n|  &&
                           `                        }` && |\n|  &&
                           `                        sap.z2ui5.oViewPopup.destroy();` && |\n|  &&
                           `                        delete sap.z2ui5.oViewPopup;` && |\n|  &&
                           `                        break;` && |\n|  &&
                           `                    case 'POPOVER_CLOSE':` && |\n|  &&
                           `                        if (sap.z2ui5.oViewPopover.close) {` && |\n|  &&
                           `                            sap.z2ui5.oViewPopover.close();` && |\n|  &&
                           `                        }` && |\n|  &&
                           `                        sap.z2ui5.oViewPopover.destroy();` && |\n|  &&
                           `                        delete sap.z2ui5.oViewPopover;` && |\n|  &&
                           `                        break;` && |\n|  &&
                           `                }` && |\n|  &&
                           `            },` && |\n|  &&
                           |\n|  &&
                           `        onEvent: function (oEvent) {` && |\n|  &&
                           |\n|  &&
                           `            if (!window.navigator.onLine) {` && |\n|  &&
                           `                sap.m.MessageBox.alert('No internet connection! Please reconnect to the server and try again.');` && |\n|  &&
                           `                return;` && |\n|  &&
                           `            }` && |\n|  &&
                           |\n|  &&
                           `            sap.ui.core.BusyIndicator.show();` && |\n|  &&
                           `            this.oBody = {};` && |\n|  &&
                           |\n|  &&
                           `            //       if (sap.z2ui5.oResponse.oViewPopup) {` && |\n|  &&
                           `            //           this.oBody.oUpdate = sap.z2ui5.oResponse.oViewPopup.getModel().oData.oUpdate;` && |\n|  &&
                           `            //          if (sap.z2ui5.oResponse.oViewPopup.close) {` && |\n|  &&
                           `            //               sap.z2ui5.oResponse.oViewPopup.close();` && |\n|  &&
                           `            //          }` && |\n|  &&
                           `            //          sap.z2ui5.oResponse.oViewPopup.destroy();` && |\n|  &&
                           `            //      } else {` && |\n|  &&
                           `            //        ` && |\n|  &&
                           `            //      }` && |\n|  &&
                           |\n|  &&
                           `            this.oBody.oUpdate = sap.z2ui5.oView.getModel().oData.oUpdate;` && |\n|  &&
                           |\n|  &&
                           `            if (sap.z2ui5.oResponse.PARAMS.T_SCROLL) {` && |\n|  &&
                           `                this.oBody.oScroll = sap.z2ui5.oResponse.PARAMS.T_SCROLL;` && |\n|  &&
                           `                this.oBody.oScroll.forEach(item => {` && |\n|  &&
                           `                    try {` && |\n|  &&
                           `                        item.VALUE = this.getView().byId(item.NAME).getScrollDelegate().getScrollTop();` && |\n|  &&
                           `                    } catch (e) {` && |\n|  &&
                           `                        try {` && |\n|  &&
                           `                            var ele = '#' + this.getView().byId(item.NAME).getId() + '-inner';` && |\n|  &&
                           `                            item.VALUE = $(ele).scrollTop();` && |\n|  &&
                           `                        } catch (e) { }` && |\n|  &&
                           `                    }` && |\n|  &&
                           `                });` && |\n|  &&
                           `            }` && |\n|  &&
                           `            this.oBody.ID = sap.z2ui5.oResponse.ID;` && |\n|  &&
                           `            this.oBody.CHECKLAUNCHPADACTIVE = false;` && |\n|  &&
                           `            if (sap.z2ui5.checkLaunchpadActive) {` && |\n|  &&
                           `                if (sap.z2ui5.checkLaunchpadActive == true) {` && |\n|  &&
                           `                    this.oBody.CHECKLAUNCHPADACTIVE = true;` && |\n|  &&
                           `                }` && |\n|  &&
                           `            }` && |\n|  &&
                           `            this.oBody.ARGUMENTS = arguments;` && |\n|  &&
                           `            try { this.oBody.OCURSOR = sap.ui.getCore().byId(sap.ui.getCore().getCurrentFocusedControlId()).getFocusInfo(); } catch (e) { }` && |\n|  &&
                           |\n|  &&
                           `            if (sap.z2ui5.checkLogActive) {` && |\n|  &&
                           `                console.log('Request Object:');` && |\n|  &&
                           `                console.log(this.oBody);` && |\n|  &&
                           `            }` && |\n|  &&
                           `            sap.z2ui5.oResponseOld = sap.z2ui5.oResponse;` && |\n|  &&
                           `            sap.z2ui5.oResponse = {};` && |\n|  &&
                           `            sap.z2ui5.oBody = this.oBody;` && |\n|  &&
                           `            sap.z2ui5.isHoldView = oEvent.isHoldView;` && |\n|  &&
                           `            sap.z2ui5.Roundtrip(oEvent.isHoldView);` && |\n|  &&
                           `        },` && |\n|  &&
                           |\n|  &&
                           `        responseError: function (response) {` && |\n|  &&
                           `            document.write(response);` && |\n|  &&
                           `        },` && |\n|  &&
                           |\n|  &&
                           `        responseSuccess: function (response) {` && |\n|  &&
                           |\n|  &&
                           `            sap.z2ui5.oResponse = JSON.parse(response);` && |\n|  &&
                           |\n|  &&
                           `            if (sap.z2ui5.checkLogActive) {` && |\n|  &&
                           `                console.log('Response Object:');` && |\n|  &&
                           `                console.log(sap.z2ui5.oResponse);` && |\n|  &&
                           `                if (sap.z2ui5.oResponse.PARAMS.XML_VIEW !== '') {` && |\n|  &&
                           `                    console.log('UI5-XML-View:');` && |\n|  &&
                           `                    console.log(sap.z2ui5.oResponse.PARAMS.XML_MAIN);` && |\n|  &&
                           `                }` && |\n|  &&
                           `                if (sap.z2ui5.oResponse.PARAMS.XML_POPUP !== '') {` && |\n|  &&
                           `                    console.log('UI5-XML-Popup:');` && |\n|  &&
                           `                    console.log(sap.z2ui5.oResponse.PARAMS.XML_POPUP);` && |\n|  &&
                           `                }` && |\n|  &&
                           `            }` && |\n|  &&
                           `            if (sap.z2ui5.oResponse.S_MSG.CONTROL !== '') {` && |\n|  &&
                           `                sap.m[sap.z2ui5.oResponse.S_MSG.CONTROL][sap.z2ui5.oResponse.S_MSG.TYPE](sap.z2ui5.oResponse.S_MSG.TEXT);` && |\n|  &&
                           `            }` && |\n|  &&
                           |\n|  &&
                           `            if (!sap.z2ui5.oResponse.PARAMS.XML_MAIN) {` && |\n|  &&
                           `                if (sap.z2ui5.isHoldView) {` && |\n|  &&
                           `                    var oModel = new sap.ui.model.json.JSONModel(sap.z2ui5.oResponse.OVIEWMODEL);` && |\n|  &&
                           `                    sap.z2ui5.oView.setModel(oModel);` && |\n|  &&
                           `                    sap.z2ui5.onAfter();` && |\n|  &&
                           `                    return;` && |\n|  &&
                           `                }` && |\n|  &&
                           `            }` && |\n|  &&
                           `            if (sap.z2ui5.isHoldView) { sap.z2ui5.oView.destroy(); }` && |\n|  &&
                           |\n|  &&
                           `            var oModel = new sap.ui.model.json.JSONModel(sap.z2ui5.oResponse.OVIEWMODEL);` && |\n|  &&
                           `            var oView = new sap.ui.core.mvc.XMLView.create({` && |\n|  &&
                           `                definition: sap.z2ui5.oResponse.PARAMS.XML_MAIN,` && |\n|  &&
                           `            }).then(oView => {` && |\n|  &&
                           `                oView.setModel(oModel);` && |\n|  &&
                           `                if (sap.z2ui5.oParent) {` && |\n|  &&
                           `                    sap.z2ui5.oParent.removeAllPages();` && |\n|  &&
                           `                    sap.z2ui5.oParent.insertPage(oView);` && |\n|  &&
                           `                } else {` && |\n|  &&
                           `                    oView.placeAt("content")` && |\n|  &&
                           `                };` && |\n|  &&
                           `                sap.z2ui5.oView = oView;` && |\n|  &&
                           `            },` && |\n|  &&
                           `            );` && |\n|  &&
                           `        },` && |\n|  &&
                           |\n|  &&
                           `        readHttp: function () {` && |\n|  &&
                           |\n|  &&
                           `            var xhr = new XMLHttpRequest();` && |\n|  &&
                           `            xhr.open("POST", sap.z2ui5.pathname, true);` && |\n|  &&
                           `            xhr.onload = function (that) {` && |\n|  &&
                           |\n|  &&
                           `                if (that.target.status !== 200) {` && |\n|  &&
                           `                    sap.z2ui5.oController.responseError(that.target.response);` && |\n|  &&
                           `                } else {` && |\n|  &&
                           `                    sap.z2ui5.oController.responseSuccess(that.target.response);` && |\n|  &&
                           `                }` && |\n|  &&
                           `            }` && |\n|  &&
                           `            xhr.send(JSON.stringify(sap.z2ui5.oBody));` && |\n|  &&
                           `        },` && |\n|  &&
                           |\n|  &&
                           `        Roundtrip: function (isHoldView) {` && |\n|  &&
                           `            sap.z2ui5.checkTimerActive = false;` && |\n|  &&
                           `            if (sap.z2ui5.oView) {` && |\n|  &&
                           `                if (!isHoldView) {` && |\n|  &&
                           `                    sap.z2ui5.oView.destroy();` && |\n|  &&
                           `                }` && |\n|  &&
                           `            }` && |\n|  &&
                           `            if (!sap.z2ui5.oBody) { sap.z2ui5.oBody = {}; };` && |\n|  &&
                           `            sap.z2ui5.oBody.OLOCATION = {};` && |\n|  &&
                           `            sap.z2ui5.oBody.OLOCATION.ORIGIN = window.location.origin;` && |\n|  &&
                           `            sap.z2ui5.oBody.OLOCATION.PATHNAME = sap.z2ui5.pathname;` && |\n|  &&
                           `            sap.z2ui5.oBody.OLOCATION.SEARCH = window.location.search;` && |\n|  &&
                           |\n|  &&
                           `            if (sap.z2ui5.readOData) {` && |\n|  &&
                           `                sap.z2ui5.readOData();` && |\n|  &&
                           `            } else {` && |\n|  &&
                           `                oView.getController().readHttp();` && |\n|  &&
                           `            }` && |\n|  &&
                           `        },` && |\n|  &&
                           `        });` && |\n|  &&
                           |\n|  &&
*                           `    debugger;` && |\n|  &&
                           `    if (!sap.z2ui5) {` && |\n|  &&
                           `        sap.z2ui5 = {};` && |\n|  &&
                           `    }` && |\n|  &&
                           `    if (!sap.z2ui5.pathname) {` && |\n|  &&
                           `        sap.z2ui5.pathname = window.location.pathname;` && |\n|  &&
*                           `        sap.z2ui5.pathname = '/sap/bc/http/sap/y2ui5_http_handler';` && |\n|  &&
                           `    }` && |\n|  &&
                           `    var xml = atob('PA==') + 'mvc:View controllerName="z2ui5_controller" xmlns:mvc="sap.ui.core.mvc" /' + atob('Pg==');` && |\n|  &&
                           `    jQuery.sap.require("sap.ui.core.Fragment");` && |\n|  &&
                           `    jQuery.sap.require("sap.m.MessageToast");` && |\n|  &&
                           `    jQuery.sap.require("sap.m.MessageBox");` && |\n|  &&
                           `    jQuery.sap.require("sap.ui.model.json.JSONModel");` && |\n|  &&
                           `    var oView = sap.ui.xmlview({ viewContent: xml });` && |\n|  &&
                           `    sap.z2ui5.Roundtrip = oView.getController().Roundtrip;` && |\n|  &&
                           `    sap.z2ui5.oController = oView.getController();` && |\n|  &&
                           `    sap.z2ui5.Roundtrip(false);` && |\n|  &&
                           `    sap.z2ui5.onAfter = () => {` && |\n|  &&
                           `        if (sap.z2ui5.oResponse.PARAMS.TITLE != "") {` && |\n|  &&
                           `            document.title = sap.z2ui5.oResponse.PARAMS.TITLE;` && |\n|  &&
                           `        }` && |\n|  &&
                           `        if (sap.z2ui5.oResponse.PARAMS.PATH != "") {` && |\n|  &&
                           `            //    window.history.replaceState("", "", window.location.origin + sap.z2ui5.oResponse.PARAMS.PATH + window.location.search);` && |\n|  &&
                           `        }` && |\n|  &&
                           `        var oView = sap.z2ui5.oView;` && |\n|  &&
                           `        try {` && |\n|  &&
                           `            if (sap.z2ui5.oResponse.PARAMS.S_CURSOR.ID !== '') {` && |\n|  &&
                           `                jQuery.sap.delayedCall(50, this, function () {` && |\n|  &&
                           `                    var ofocus = sap.z2ui5.oView.byId(sap.z2ui5.oResponse.PARAMS.S_CURSOR.ID).getFocusInfo();` && |\n|  &&
                           `                    ofocus.selectionStart = parseInt(sap.z2ui5.oResponse.PARAMS.S_CURSOR.SELECTIONSTART);` && |\n|  &&
                           `                    ofocus.selectionEnd = parseInt(sap.z2ui5.oResponse.PARAMS.S_CURSOR.SELECTIONEND);` && |\n|  &&
                           `                    sap.z2ui5.oView.byId(sap.z2ui5.oResponse.PARAMS.S_CURSOR.ID).applyFocusInfo(ofocus);` && |\n|  &&
                           `                });` && |\n|  &&
                           `            }` && |\n|  &&
                           `        } catch (error) { }` && |\n|  &&
                           `        ; try { } catch (error) { }` && |\n|  &&
                           `        ; if (sap.z2ui5.oResponse.PARAMS.T_SCROLL) {` && |\n|  &&
                           `            sap.z2ui5.oResponse.PARAMS.T_SCROLL.forEach(item => {` && |\n|  &&
                           `                try {` && |\n|  &&
                           `                    oView.byId(item.NAME).scrollTo(parseInt(item.VALUE));` && |\n|  &&
                           `                } catch (e) {` && |\n|  &&
                           `                    try {` && |\n|  &&
                           `                        var ele = '#' + oView.byId(item.NAME).getId() + '-inner';` && |\n|  &&
                           `                        $(ele).scrollTop(item.VALUE);` && |\n|  &&
                           `                    } catch (e) { }` && |\n|  &&
                           `                }` && |\n|  &&
                           `            }` && |\n|  &&
                           `            );` && |\n|  &&
                           `        }` && |\n|  &&
                           `        if (sap.z2ui5.oResponse.PARAMS.S_POPUP.XML) {` && |\n|  &&
                           `            sap.ui.core.Fragment.load({` && |\n|  &&
                           `                definition: sap.z2ui5.oResponse.PARAMS.S_POPUP.XML,` && |\n|  &&
                           `                controller: sap.z2ui5.oController,` && |\n|  &&
                           `            }).then(function (oFragment) {` && |\n|  &&
                           `                oFragment.setModel(new sap.ui.model.json.JSONModel(sap.z2ui5.oResponse.OVIEWMODEL))` && |\n|  &&
                           `                sap.z2ui5.oView.addDependent(oFragment);` && |\n|  &&
                           `                if (sap.z2ui5.oResponse.PARAMS.POPOVER_OPEN_BY_ID == '') {` && |\n|  &&
                           `                    oFragment.open();` && |\n|  &&
                           `                } else {` && |\n|  &&
                           `                    var oControl = sap.ui.getCore().byId(sap.z2ui5.oResponse.PARAMS.POPOVER_OPEN_BY_ID);` && |\n|  &&
                           `                    if (oControl === undefined) {` && |\n|  &&
                           `                        oControl = sap.z2ui5.oView.byId(sap.z2ui5.oResponse.PARAMS.POPOVER_OPEN_BY_ID);` && |\n|  &&
                           `                    }` && |\n|  &&
                           `                    oFragment.openBy(oControl);` && |\n|  &&
                           `                }` && |\n|  &&
                           `                sap.z2ui5.oViewPopup = oFragment;` && |\n|  &&
                           `                sap.ui.core.BusyIndicator.hide();` && |\n|  &&
                           `            }` && |\n|  &&
                           `                .bind(this));` && |\n|  &&
                           `        } else if (sap.z2ui5.oResponse.PARAMS.S_POPUP.CHECK_CLOSE == true) {` && |\n|  &&
                           |\n|  &&
                           `            if (sap.z2ui5.oViewPopup.close) {` && |\n|  &&
                           `                sap.z2ui5.oViewPopup.close();` && |\n|  &&
                           `            }` && |\n|  &&
                           `            sap.z2ui5.oViewPopup.destroy();` && |\n|  &&
                           `            delete sap.z2ui5.oViewPopup;` && |\n|  &&
                           |\n|  &&
                           `        }` && |\n|  &&
                           |\n|  &&
                           `        if (sap.z2ui5.oResponse.PARAMS.S_POPOVER.XML) {` && |\n|  &&
                           `            sap.ui.core.Fragment.load({` && |\n|  &&
                           `                definition: sap.z2ui5.oResponse.PARAMS.S_POPOVER.XML,` && |\n|  &&
                           `                controller: sap.z2ui5.oController,` && |\n|  &&
                           `            }).then(function (oFragment) {` && |\n|  &&
                           `                oFragment.setModel(new sap.ui.model.json.JSONModel(sap.z2ui5.oResponse.OVIEWMODEL))` && |\n|  &&
                           `                sap.z2ui5.oView.addDependent(oFragment);` && |\n|  &&
                           |\n|  &&
                           `                var oControl = sap.ui.getCore().byId(sap.z2ui5.oResponse.PARAMS.S_POPOVER.OPEN_BY_ID);` && |\n|  &&
                           `                if (oControl === undefined) {` && |\n|  &&
                           `                    oControl = sap.z2ui5.oView.byId(sap.z2ui5.oResponse.PARAMS.S_POPOVER.OPEN_BY_ID);` && |\n|  &&
                           `                }` && |\n|  &&
                           `                oFragment.openBy(oControl);` && |\n|  &&
                           |\n|  &&
                           `                sap.z2ui5.oViewPopover = oFragment;` && |\n|  &&
                           `                sap.ui.core.BusyIndicator.hide();` && |\n|  &&
                           `            }` && |\n|  &&
                           `                .bind(this));` && |\n|  &&
                           `        } else if (sap.z2ui5.oResponse.PARAMS.S_POPOVER.CHECK_CLOSE == true) {` && |\n|  &&
                           |\n|  &&
                           `            if (sap.z2ui5.oViewPopover.close) {` && |\n|  &&
                           `                sap.z2ui5.oViewPopover.close();` && |\n|  &&
                           `            }` && |\n|  &&
                           `            sap.z2ui5.oViewPopover.destroy();` && |\n|  &&
                           `            delete sap.z2ui5.oViewPopover;` && |\n|  &&
                           |\n|  &&
                           `        }` && |\n|  &&
                           |\n|  &&
                           `        if (sap.z2ui5.oResponse.PARAMS.S_TIMER.INTERVAL_MS !== '') {` && |\n|  &&
                           `            var oEvent = { 'EVENT': 'BUTTON_CHECK', 'METHOD': 'UPDATE' };` && |\n|  &&
                           `            oEvent.EVENT = sap.z2ui5.oResponse.PARAMS.S_TIMER.EVENT_FINISHED;` && |\n|  &&
                           `            sap.z2ui5.checkTimerActive = true;` && |\n|  &&
                           `            setTimeout(() => {` && |\n|  &&
                           `                if (sap.z2ui5.checkTimerActive) {` && |\n|  &&
                           `                    sap.z2ui5.oView.getController().onEvent(oEvent);` && |\n|  &&
                           `                }` && |\n|  &&
                           `            }, parseInt(sap.z2ui5.oResponse.PARAMS.S_TIMER.INTERVAL_MS), oEvent);` && |\n|  &&
                           `        }` && |\n|  &&
                           `        sap.ui.core.BusyIndicator.hide();` && |\n|  &&
                           `    };` && |\n|  &&
                          `  sap.z2ui5.checkLogActive = ` && z2ui5_lcl_utility=>get_json_boolean( check_logging ) && `;` && |\n| &&
                           `    });` && |\n|  &&
                           `</script>` && |\n|  &&
                           `<abc/>` && |\n|  &&
                           `</html>`.

*        `        sap.z2ui5.checkLogActive = ` && z2ui5_lcl_utility=>get_json_boolean( check_logging ) && `;` && |\n| &&
  ENDMETHOD.


  METHOD http_post.

    z2ui5_lcl_fw_handler=>ss_config = VALUE #(
      controller_name = `z2ui5_controller`
      path_info       = path_info
      body            = body ).

    DATA(lo_handler) = z2ui5_lcl_fw_handler=>request_begin( ).

    DO.
      TRY.
          ROLLBACK WORK.
          CAST z2ui5_if_app( lo_handler->ms_db-o_app )->main( NEW z2ui5_lcl_fw_client( lo_handler ) ).
          ROLLBACK WORK.

          IF lo_handler->ms_next-check_app_leave IS NOT INITIAL.
            lo_handler = lo_handler->set_app_leave( ).
            CONTINUE.
          ENDIF.

          IF lo_handler->ms_next-o_call_app IS NOT INITIAL.
            lo_handler = lo_handler->set_app_call( ).
            CONTINUE.
          ENDIF.

          result = lo_handler->request_end( ).

        CATCH cx_root INTO DATA(x).
          lo_handler = lo_handler->set_app_system( x ).
          CONTINUE.
      ENDTRY.

      EXIT.
    ENDDO.

  ENDMETHOD.
ENDCLASS.
