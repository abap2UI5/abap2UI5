CLASS z2ui5_cl_http_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-DATA:
      BEGIN OF client,
        body     TYPE string,
        t_header TYPE z2ui5_if_client=>ty_t_name_value,
        t_param  TYPE z2ui5_if_client=>ty_t_name_value,
      END OF client.

    CLASS-METHODS main_index_html
      IMPORTING
        library_path    TYPE clike     DEFAULT `https://sdk.openui5.org/resources/sap-ui-core.js`
        theme           TYPE clike     DEFAULT `sap_horizon`
        title           TYPE clike     DEFAULT `abap2UI5`
        check_logging   TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(r_result) TYPE string ##NEEDED.

    CLASS-METHODS main_roundtrip
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS z2ui5_cl_http_handler IMPLEMENTATION.


  METHOD main_roundtrip.

    DATA(lo_runtime) = z2ui5_lcl_system_runtime=>request_begin( ).

    DO.
      TRY.
          ROLLBACK WORK.
          CAST z2ui5_if_app( lo_runtime->ms_db-o_app )->controller( NEW z2ui5_lcl_if_client( lo_runtime ) ).
          ROLLBACK WORK.

          IF lo_runtime->ms_next-check_app_leave IS NOT INITIAL.
            lo_runtime = lo_runtime->set_app_leave( ).
            CONTINUE.
          ENDIF.

          IF lo_runtime->ms_next-o_call_app IS NOT INITIAL.
            lo_runtime = lo_runtime->set_app_call( ).
            CONTINUE.
          ENDIF.

          result = lo_runtime->request_end( ).

        CATCH cx_root INTO DATA(x).
          lo_runtime = lo_runtime->set_app_system( x ).
          CONTINUE.
      ENDTRY.

      EXIT.
    ENDDO.

  ENDMETHOD.


  METHOD main_index_html.

    DATA(lv_url) = _=>get_header_val( '~path' ).
    DATA(lv_app) = _=>get_param_val( 'app' ).
    z2ui5_lcl_db=>cleanup( ).

    r_result = `<html>` && |\n| &&
               `<head>` && |\n| &&
               `    <meta charset="UTF-8">` && |\n|  &&
               `    <meta name="viewport" content="width=device-width, initial-scale=1.0">` && |\n|  &&
               `    <meta http-equiv="X-UA-Compatible" content="IE=edge">` && |\n| &&
               `    <title>` && title && `</title>` && |\n| &&
               `    <style>` && |\n|  &&
               `        html, body, body > div, #container, #container-uiarea {` && |\n|  &&
               `            height: 100%;` && |\n|  &&
               `        }` && |\n|  &&
               `    </style> ` &&
               `    <script src="` && library_path && `" ` &&
               ` id="sap-ui-bootstrap" data-sap-ui-theme="` && theme && `"` && |\n| &&
               `        data-sap-ui-libs="sap.m" data-sap-ui-bindingSyntax="complex" data-sap-ui-frameOptions="trusted" data-sap-ui-compatVersion="edge"` && |\n| &&
               `        >` && |\n| &&
               `     </script></head>` && |\n| &&
               `<body class="sapUiBody sapUiSizeCompact" >` && |\n| &&
               `    <div id="content"  data-handle-validation="true" ></div>` && |\n| &&
               `</body>` && |\n| &&
               `</html>` && |\n|.

    r_result = r_result && `<script id="z2ui5">` && |\n|  &&
                           `    sap.ui.getCore().attachInit(function () {` && |\n|  &&
                           `        "use strict";` && |\n|  &&
                           |\n|  &&
                           `            sap.ui.controller("z2ui5_controller", {` && |\n|  &&
                           |\n|  &&
                           `                onAfterRendering: function () {` && |\n|  &&
                           `                    var oView = this.getView();` && |\n|  &&
                           `                    try {` && |\n|  &&
                           `                        if (sap.z2ui5.oResponse.oCursor) {` && |\n|  &&
                           `                            var ofocus = oView.byId(sap.z2ui5.oResponse.oCursor.id).getFocusInfo();` && |\n|  &&
                           `                            ofocus.cursorPos = sap.z2ui5.oResponse.oCursor.cursorPos;` && |\n|  &&
                           `                            ofocus.selectionStart = sap.z2ui5.oResponse.oCursor.selectionStart;` && |\n|  &&
                           `                            ofocus.selectionEnd = sap.z2ui5.oResponse.oCursor.selectionEnd;` && |\n|  &&
                           `                        }` && |\n|  &&
                           `                        oView.byId(sap.z2ui5.oResponse.oCursor.id).applyFocusInfo(ofocus);` && |\n|  &&
                           `                    } catch (error) { };` && |\n|  &&
                           `                    try {` && |\n|  &&
                           `                        //     oView.getContent()[0].getApp().scrollTo(sap.z2ui5.oResponse.PAGE_SCROLL_POS);` && |\n|  &&
                           `                    } catch (error) { };` && |\n|  &&
                           `                    //todo` && |\n|  &&
                           `                    if (sap.z2ui5.oResponse.oScroll) {` && |\n|  &&
                           `                        sap.z2ui5.oResponse.oScroll.forEach(item => Object.keys(item).forEach(function (key, index) {` && |\n|  &&
                           `                            try {` && |\n|  &&
                           `                                oView.byId(key).scrollTo(item[key]);` && |\n|  &&
                           `                            } catch (e) {` && |\n|  &&
                           `                                var ele = '#' + oView.byId(key).getId() + '-inner';` && |\n|  &&
                           `                                $(ele).scrollTop(item[key]);` && |\n|  &&
                           `                            }` && |\n|  &&
                           `                            // index: the ordinal position of the key within the object ` && |\n|  &&
                           `                        }));` && |\n|  &&
                           `                    }` && |\n|  &&
                           `                    if (sap.z2ui5.oResponse.vViewPopup) {` && |\n|  &&
                           `     ` && |\n|  &&
                           `                        ` && |\n|  &&
                           `                         sap.ui.core.Fragment.load({` && |\n|  &&
                           `                            definition: sap.z2ui5.oResponse.vViewPopup,` && |\n|  &&
                           `                            controller: this,` && |\n|  &&
                           `                        }).then(function (oFragment) {` && |\n|  &&
                           `                            oFragment.setModel(new sap.ui.model.json.JSONModel(sap.z2ui5.oResponse.oViewModel))` && |\n|  &&
                           `                            this.getView().addDependent(oFragment);` && |\n|  &&
                           `                            if (!sap.z2ui5.oResponse.OPENBY) { oFragment.open(); } else {` && |\n|  &&
                           `                                oFragment.openBy(this.getView().byId(sap.z2ui5.oResponse.OPENBY))` && |\n|  &&
                           `                            }` && |\n|  &&
                           `                            sap.z2ui5.oResponse.oViewPopup = oFragment;` && |\n|  &&
                           `                            sap.ui.core.BusyIndicator.hide();` && |\n|  &&
                           `                        }.bind(this));` && |\n|  &&
                           `                    }` && |\n|  &&
                           `                    if (sap.z2ui5.oResponse.oTimer){ ` && |\n|  &&
                           `                    var oEvent = { 'EVENT' : 'BUTTON_CHECK', 'METHOD' : 'UPDATE' };` && |\n|  &&
                           `                    oEvent.EVENT = sap.z2ui5.oResponse.oTimer.eventFinished;` && |\n|  &&
                           `                    setTimeout( sap.z2ui5.oView.getController().onEvent, sap.z2ui5.oResponse.oTimer.intervalMs, oEvent );` && |\n|  &&
                           `                    }` && |\n|  &&
                           `                    sap.ui.core.BusyIndicator.hide();` && |\n|  &&
                           `                },` && |\n|  &&
                           |\n|  &&
                           `                onEventFrontend: function (vAction) {` && |\n|  &&
                           |\n|  &&
                           `                    if (vAction == 'POPUP_CLOSE') {` && |\n|  &&
                           `                        if (sap.z2ui5.oResponse.oViewPopup.close) {` && |\n|  &&
                           `                            sap.z2ui5.oResponse.oViewPopup.close();` && |\n|  &&
                           `                        }` && |\n|  &&
                           `                        sap.z2ui5.oResponse.oViewPopup.destroy();` && |\n|  &&
                           `                        delete sap.z2ui5.oResponse.oViewPopup;` && |\n|  &&
                           `                        delete sap.z2ui5.oResponse.oSystem.VIEW_POPUP;` && |\n|  &&
                           `                    }` && |\n|  &&
                           |\n|  &&
                           `                },` && |\n|  &&
                           |\n|  &&
                           `                onEvent: function (oEvent, vData) {` && |\n|  &&
                           |\n|  &&
                           `                    if (!window.navigator.onLine) {` && |\n|  &&
                           `                        sap.m.MessageBox.alert('No internet connection! Please reconnect to the server and try again.');` && |\n|  &&
                           `                        return;` && |\n|  &&
                           `                    }` && |\n|  &&
                           |\n|  &&
                           `                    sap.ui.core.BusyIndicator.show();` && |\n|  &&
                           `                    this.oBody = {};` && |\n|  &&
                           |\n|  &&
                           `                    if (sap.z2ui5.oResponse.oViewPopup) {` && |\n|  &&
                           `                        this.oBody.oUpdate = sap.z2ui5.oResponse.oViewPopup.getModel().oData.oUpdate;` && |\n|  &&
                           `                        if (sap.z2ui5.oResponse.oViewPopup.close) {` && |\n|  &&
                           `                            sap.z2ui5.oResponse.oViewPopup.close();` && |\n|  &&
                           `                        }` && |\n|  &&
                           `                        sap.z2ui5.oResponse.oViewPopup.destroy();` && |\n|  &&
                           `                    } else {` && |\n|  &&
                           `                        this.oBody.oUpdate = sap.z2ui5.oView.getModel().oData.oUpdate;` && |\n|  &&
                           `                    }` && |\n|  &&
                           |\n|  &&
                           `                    this.oBody.oSystem = sap.z2ui5.oResponse.oSystem;` && |\n|  &&
                           `                    this.oBody.oEvent = oEvent;` && |\n|  &&
                           `                    this.oBody.oEvent.vData = vData;` && |\n|  &&
                           |\n|  &&
                           `                    if (this.oBody.oSystem.CHECK_DEBUG_ACTIVE) {` && |\n|  &&
                           `                        console.log('Request Object:');` && |\n|  &&
                           `                        console.log(this.oBody);` && |\n|  &&
                           `                    }` && |\n|  &&
                           |\n|  &&
                           `                    sap.z2ui5.oResponseOld = sap.z2ui5.oResponse;` && |\n|  &&
                           `                    sap.z2ui5.oResponse = {};` && |\n|  &&
                           `                    sap.z2ui5.oBody = this.oBody;` && |\n|  &&
                           `                    sap.z2ui5.oView.getController( ).Roundtrip();` && |\n|  &&
                           `                    sap.z2ui5.oView.destroy();` && |\n|  &&
                           `                },` && |\n|  &&
                           |\n|  &&
                           `                Roundtrip: function () {` && |\n|  &&
                           |\n|  &&
                           `                    if (sap.z2ui5.oView){ sap.z2ui5.oView.destroy( ); }` && |\n|  &&
                           `                    var xhr = new XMLHttpRequest();` && |\n|  &&
                           `                   if ( sap.startApp ) { var app = sap.startApp;   }else` && |\n|  &&
                           `                      {   ` && |\n|  &&
                           `                         app = ' ` && lv_app && `'; ` && |\n|  &&
                           `                         }` && |\n|  &&
                           `                    var url = '` && lv_url && `?app=' + app;` && |\n|  &&
                           `                    xhr.open("POST", url, true);` && |\n|  &&
                           `                    xhr.onload = function (that) {` && |\n|  &&
                           |\n|  &&
                           `                        if (that.target.status !== 200) {` && |\n|  &&
                           `                            document.write(that.target.response);` && |\n|  &&
                           `                            return;` && |\n|  &&
                           `                        }` && |\n|  &&
                           `                        sap.z2ui5.oResponse = JSON.parse(that.target.response);` && |\n|  &&
                           |\n|  &&
                           `                        if (sap.z2ui5.oResponse.oSystem.CHECK_DEBUG_ACTIVE) {` && |\n|  &&
                           `                            console.log('Response Object:');` && |\n|  &&
                           `                            console.log(sap.z2ui5.oResponse);` && |\n|  &&
                           `                            if (sap.z2ui5.oResponse.vView) {` && |\n|  &&
                           `                                console.log('UI5-XML-View:');` && |\n|  &&
                           `                                console.log(sap.z2ui5.oResponse.vView);` && |\n|  &&
                           `                            }` && |\n|  &&
                           `                            if (sap.z2ui5.oResponse.vViewPopup) {` && |\n|  &&
                           `                                console.log('UI5-XML-Popup:');` && |\n|  &&
                           `                                console.log(sap.z2ui5.oResponse.vViewPopup);` && |\n|  &&
                           `                            }` && |\n|  &&
                           `                        }` && |\n|  &&
                           |\n|  &&
                           `                        if (sap.z2ui5.oResponse.oAfter) {` && |\n|  &&
                           `                            sap.z2ui5.oResponse.oAfter.forEach(item => sap.m[item[0]][item[1]](item[2]));` && |\n|  &&
                           `                        }` && |\n|  &&
                           |\n|  &&
                           `                        if (sap.z2ui5.oResponse.vView) {` && |\n|  &&
                           `                            var oModel = new sap.ui.model.json.JSONModel(sap.z2ui5.oResponse.oViewModel);` && |\n|  &&
                           `                            var oView = new sap.ui.core.mvc.XMLView.create({` && |\n|  &&
                           `                                definition: sap.z2ui5.oResponse.vView,` && |\n|  &&
                           `                            }).then(oView => {` && |\n|  &&
                           `                                oView.setModel(oModel);` && |\n|  &&
                           `                                oView.placeAt("content");` && |\n|  &&
                           `                                this.oView = oView;` && |\n|  &&
                           `                                sap.z2ui5.oView = oView;` && |\n|  &&
                           `                            });` && |\n|  &&
                           `                        } else if (sap.z2ui5.oResponse.SET_PREV_VIEW == true) {` && |\n|  &&
                           `                            var oModel = new sap.ui.model.json.JSONModel(sap.z2ui5.oResponseOld.oViewModel);` && |\n|  &&
                           `                            var oView = new sap.ui.core.mvc.XMLView.create({` && |\n|  &&
                           `                                definition: sap.z2ui5.oResponseOld.vView` && |\n|  &&
                           `                            }).then(oView => {` && |\n|  &&
                           `                                oView.setModel(oModel);` && |\n|  &&
                           `                                oView.placeAt("content");` && |\n|  &&
                           `                                this.oView = oView;` && |\n|  &&
                           `                                sap.z2ui5.oView = oView;` && |\n|  &&
                           `                            });` && |\n|  &&
                           `                        }` && |\n|  &&
                           `                    }.bind(this);` && |\n|  &&
                           `                    xhr.send(JSON.stringify(sap.z2ui5.oBody));` && |\n|  &&
                           `                },` && |\n|  &&
                           `            });` && |\n|  &&
                           |\n|  &&
                           `        if (!sap.z2ui5) {sap.z2ui5 = {}; };` && |\n|  &&
                           `        var xml = '<mvc:View controllerName="z2ui5_controller" xmlns:mvc="sap.ui.core.mvc" />';` && |\n|  &&
                           `        if (xml == '') { xml = '&lt;mvc:View controllerName="z2ui5_controller" xmlns:mvc="sap.ui.core.mvc" />' };` && |\n|  &&
                           |\n|  &&
                           `        jQuery.sap.require("sap.ui.core.Fragment");` && |\n|  &&
                           `        jQuery.sap.require("sap.m.MessageToast");` && |\n|  &&
                           `        jQuery.sap.require("sap.m.MessageBox");` && |\n|  &&
                           `        var oView  = sap.ui.xmlview({viewContent:xml});` && |\n|  &&
                           `        oView.getController().Roundtrip();` && |\n|  &&
                           |\n|  &&
                           `    });` && |\n|  &&
                           `</script>` && |\n|  &&
                           `</html>`.

  ENDMETHOD.

ENDCLASS.
