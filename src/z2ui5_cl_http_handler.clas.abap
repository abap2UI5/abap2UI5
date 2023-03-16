CLASS z2ui5_cl_http_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      BEGIN OF cs_config,
        theme            TYPE string    VALUE 'sap_horizon',
        browser_title    TYPE string    VALUE 'abap2UI5',
        repository       TYPE string    VALUE 'https://ui5.sap.com/resources/sap-ui-core.js',
        letterboxing     TYPE abap_bool VALUE abap_true,
        check_debug_mode TYPE abap_bool VALUE abap_true,
      END OF cs_config.

    TYPES:
      BEGIN OF ty_S_name_value,
        name  TYPE string,
        value TYPE string,
      END OF ty_S_name_value.
    TYPES ty_t_name_value TYPE STANDARD TABLE OF ty_S_name_value.

    CLASS-DATA:
      BEGIN OF client,
        body     TYPE string,
        t_header TYPE ty_t_name_value,
        t_param  TYPE ty_t_name_value,
      END OF client.

    CLASS-METHODS main_index_html
      RETURNING
        VALUE(r_result) TYPE string.

    CLASS-METHODS main_roundtrip
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS z2ui5_cl_http_handler IMPLEMENTATION.


  METHOD main_index_html.

    client-t_param = VALUE #( LET tab = client-t_param IN FOR row IN tab
                                 ( name = to_upper( row-name ) value = to_upper( row-value ) ) ).

    DATA(lv_url) = client-t_header[ name = '~path' ]-value.
    TRY.
        DATA(lv_app) = client-t_param[ name = 'APP' ]-value.
        lv_url = lv_url && `?app=` && lv_app.
      CATCH cx_root.
    ENDTRY.

    z2ui5_lcl_db=>cleanup( ).

    r_result = `<html>` && |\n| &&
               `<head>` && |\n| &&
               `    <meta charset="utf-8">` && |\n| &&
               `    <title>` && cs_config-browser_title && `</title>` && |\n| &&
               `    <script src="` && cs_config-repository && `" ` &&
               ` id="sap-ui-bootstrap" data-sap-ui-theme="` && cs_config-theme && `"` && |\n| &&
               `        data-sap-ui-libs="sap.m" data-sap-ui-bindingSyntax="complex" data-sap-ui-compatVersion="edge"` && |\n| &&
               `        data-sap-ui-preload="async">` && |\n| &&
               `     </script></head>` && |\n|  &&
               `<body class="sapUiBody">` && |\n|  &&
               `    <div id="content"></div>` && |\n|  &&
               `</body>` && |\n|  &&
               `</html>` && |\n|.

    r_result = r_result && `<script>` && |\n|  &&
                           `    sap.ui.getCore().attachInit(function () {` && |\n|  &&
                           `        "use strict";` && |\n|  &&

`        sap.ui.define(["sap/ui/core/mvc/Controller", "sap/ui/model/odata/v2/ODataModel", "sap/ui/model/json/JSONModel", "sap/m/MessageBox", "sap/ui/core/Fragment"], function (Controller, ODataModel, JSONModel, MessageBox, Fragment) {` && |\n|  &&
                           `            "use strict";` && |\n|  &&
                           `            return Controller.extend("MyController", {` && |\n|  &&
                           |\n|  &&
                           `                onAfterRendering: function () {` && |\n|  &&
                           `                    var oView = this.getView();` && |\n|  &&
                           `                    try {` && |\n|  &&
                           `                        var ofocus = oView.byId('focus').getFocusInfo();` && |\n|  &&
                           `                        if (sap.z2ui5.oResponse.FOCUS_POS) {` && |\n|  &&
                           `                            ofocus.cursorPos = sap.z2ui5.oResponse.FOCUS_POS;` && |\n|  &&
                           `                            ofocus.selectionStart = sap.z2ui5.oResponse.FOCUS_POS;` && |\n|  &&
                           `                            ofocus.selectionEnd = sap.z2ui5.oResponse.FOCUS_POS;` && |\n|  &&
                           `                        }` && |\n|  &&
                           `                        oView.byId('focus').applyFocusInfo(ofocus);` && |\n|  &&
                           `                    } catch (error) { };` && |\n|  &&
                           `                    try {` && |\n|  &&
                           `                        oView.getContent()[0].getApp().scrollTo(sap.z2ui5.oResponse.PAGE_SCROLL_POS);` && |\n|  &&
                           `                    } catch (error) { };` && |\n|  &&
                           |\n|  &&
                           `                },` && |\n|  &&
                           |\n|  &&
                           `                onEventFrontend: function (vAction) {` && |\n|  &&
                           |\n|  &&
                           `                    if (vAction == 'POPUP_CLOSE' ){` && |\n|  &&
                           `                        sap.z2ui5.oResponse.oViewPopup.close();` && |\n|  &&
                           `                        sap.z2ui5.oResponse.oViewPopup.destroy();` && |\n|  &&
                           `                        delete sap.z2ui5.oResponse.oViewPopup;` && |\n|  &&
                           `                        delete sap.z2ui5.oResponse.oSystem.VIEW_POPUP;` && |\n|  &&
                           `                    }` && |\n|  &&
                           |\n|  &&
                           `                },` && |\n|  &&
                           |\n|  &&
                           `                onEvent: function (oEvent, oEvent2, oEvent3, oEvent4) {` && |\n|  &&
                           |\n|  &&
                           `                    if (!window.navigator.onLine) {` && |\n|  &&
                           `                        sap.m.MessageBox.alert('No internet connection! Please reconnect to the server and try again.');` && |\n|  &&
                           `                        return;` && |\n|  &&
                           `                    }` && |\n|  &&
                           |\n|  &&
                           `                    sap.ui.core.BusyIndicator.show();` && |\n|  &&
                           |\n|  &&
                           `                    this.oBody = this.oView.getModel().oData.oUpdate;` && |\n|  &&
                           `                    this.oBody.oSystem = sap.z2ui5.oResponse.oSystem;` && |\n|  &&
                           `                    this.oBody.oEvent = oEvent;` && |\n|  &&
                           |\n|  &&
                           `                    if (sap.z2ui5.oResponse.oViewPopup) {` && |\n|  &&
                           `                        sap.z2ui5.oResponse.oViewPopup.close();` && |\n|  &&
                           `                        sap.z2ui5.oResponse.oViewPopup.destroy();` && |\n|  &&
                           `                        this.oBody.oPopup = sap.z2ui5.oResponse.oViewPopup.getModel().oData.oUpdate;` && |\n|  &&
                           `                    }` && |\n|  &&
                           |\n|  &&
                           `                    try {` && |\n|  &&
                           `                        this.oBody.scrollPos = parseInt(this.oView.getContent()[0].getApp().getScrollDelegate().getScrollTop());` && |\n|  &&
                           `                    } catch (e) { };` && |\n|  &&
                           |\n|  &&
                           `                    if (this.oView.getModel().oData.oUpdate.oSystem.CHECK_DEBUG_ACTIVE) {` && |\n|  &&
                           `                        console.log('Request Object:');` && |\n|  &&
                           `                        console.log(this.oBody);` && |\n|  &&
                           `                    }` && |\n|  &&
                           `                    sap.z2ui5.oResponseOld = sap.z2ui5.oResponse;` && |\n|  &&
                           `                    sap.z2ui5.oResponse = {};` && |\n|  &&
                           `                    this.oView.destroy();` && |\n| && |\n|  &&
                           `                    this.Roundtrip();` && |\n|  &&
                           `                },` && |\n|  &&
                           `                Roundtrip: function () {` && |\n|  &&
                           |\n|  &&
                           `                    var xhr = new XMLHttpRequest();` && |\n|  &&
                                                    `    var url = '` && lv_url && `';` && |\n| &&
                           `                    xhr.open("POST", url, true);` && |\n|  &&
                           `                    xhr.onload = function (that) {` && |\n|  &&
                           `                        if (that.target.status !== 200) {` && |\n|  &&
                           `                            document.write(that.target.response);` && |\n|  &&
                           `                            return;` && |\n|  &&
                           `                        }` && |\n|  &&
                           `                        sap.z2ui5.oResponse = JSON.parse(that.target.response);` && |\n|  &&
                           `                        if (sap.z2ui5.oResponse.oSystem.CHECK_DEBUG_ACTIVE) {` && |\n|  &&
                           `                            console.log('Response Object:');` && |\n|  &&
                           `                            console.log(sap.z2ui5.oResponse);` && |\n|  &&
                           `                            console.log('UI5-XML-View:');` && |\n|  &&
                           `                            console.log(sap.z2ui5.oResponse.vView);` && |\n|  &&
                           `                        }` && |\n|  &&
                           |\n|  &&
                           `                        if (sap.z2ui5.oResponse.oAfter) {` && |\n|  &&
                           `                            sap.z2ui5.oResponse.oAfter.forEach(item => sap.m[item[0]][item[1]](item[2]));` && |\n|  &&
                           `                        }` && |\n|  &&
                           |\n|  &&
                           `                        // sap.z2ui5.oResponse.oViewModel.oUpdate.oSystem = sap.z2ui5.oResponse.oSystem;` && |\n|  &&
                           |\n|  &&
                           `                        if (sap.z2ui5.oResponse.vViewPopup) {` && |\n|  &&
                           `                            var oModelPopup = new JSONModel(sap.z2ui5.oResponse.oViewModelPopup);` && |\n|  &&
                           `                            new sap.ui.core.Fragment.load({` && |\n|  &&
                           `                                definition: sap.z2ui5.oResponse.vViewPopup,` && |\n|  &&
                           `                                controller: this,` && |\n|  &&
                           `                            }).then(function (oFragment) {` && |\n|  &&
                           `                                oFragment.setModel(oModelPopup);` && |\n|  &&
                           `                                this.getView().addDependent(oFragment);` && |\n|  &&
                           `                                oFragment.open();` && |\n|  &&
                           `                                sap.z2ui5.oResponse.oViewPopup = oFragment;` && |\n|  &&
                           `                                sap.ui.core.BusyIndicator.hide();` && |\n|  &&
                           `                            }.bind(this));` && |\n|  &&
                           `                        }` && |\n|  &&
                           |\n|  &&
                           `                        if (sap.z2ui5.oResponse.vView) {` && |\n|  &&
                           `                            var oModel = new JSONModel(sap.z2ui5.oResponse.oViewModel);` && |\n|  &&
                           `                            var oView = new sap.ui.core.mvc.XMLView.create({` && |\n|  &&
                           `                                viewContent: sap.z2ui5.oResponse.vView,` && |\n|  &&
                           `                                definition: sap.z2ui5.oResponse.vView,` && |\n|  &&
                           `                                preprocessors: {` && |\n|  &&
                           `                                    xml: {` && |\n|  &&
                           `                                        models: {` && |\n|  &&
                           `                                            meta: oModel` && |\n|  &&
                           `                                        }` && |\n|  &&
                           `                                    }` && |\n|  &&
                           `                                },` && |\n|  &&
                           `                            }).then(oView => {` && |\n|  &&
                           `                                oView.setModel(oModel);` && |\n|  &&
                           `                                oView.placeAt("content");` && |\n|  &&
                           `                                this.oView = oView;` && |\n|  &&
                           `                                sap.ui.core.BusyIndicator.hide();` && |\n|  &&
                           `                            }` && |\n|  &&
                           `                            );` && |\n|  &&
                           `                        } else if ( sap.z2ui5.oResponse.SET_PREV_VIEW == true ){` && |\n|  &&
                           |\n|  &&
                           `                            var oModel = new JSONModel(sap.z2ui5.oResponseOld.oViewModel);` && |\n|  &&
                           `                            var oView = new sap.ui.core.mvc.XMLView.create({` && |\n|  &&
                           `                                viewContent: sap.z2ui5.oResponseOld.vView,` && |\n|  &&
                           `                                definition: sap.z2ui5.oResponseOld.vView,` && |\n|  &&
                           `                                preprocessors: {` && |\n|  &&
                           `                                    xml: {` && |\n|  &&
                           `                                        models: {` && |\n|  &&
                           `                                            meta: oModel` && |\n|  &&
                           `                                        }` && |\n|  &&
                           `                                    }` && |\n|  &&
                           `                                },` && |\n|  &&
                           `                            }).then( oView => {` && |\n|  &&
                           `                                oView.setModel(oModel);` && |\n|  &&
                           `                                oView.placeAt("content");` && |\n|  &&
                           `                                this.oView = oView;` && |\n|  &&
                           `                                sap.ui.core.BusyIndicator.hide();` && |\n|  &&
                           `                            } );` && |\n|  &&
                           `                        }` && |\n|  &&
                           `                    }.bind(this);` && |\n|  &&
                           `                    xhr.send(JSON.stringify(this.oBody));` && |\n|  &&
                           `                },` && |\n|  &&
                           `            });` && |\n|  &&
                           `        });` && |\n|  &&
                           `        var oView = sap.ui.xmlview({` && |\n|  &&
                           `            viewContent: "<mvc:View controllerName='MyController' xmlns:mvc='sap.ui.core.mvc' />"` && |\n|  &&
                           `        });` && |\n|  &&
                           `        sap.z2ui5 = {};` && |\n|  &&
                           `        oView.getController().Roundtrip();` && |\n|  &&
                           |\n|  &&
                           |\n|  &&
                           `        jQuery.sap.declare("my.library");` && |\n|  &&
                           `        jQuery.sap.require("sap.ui.core.Core");` && |\n|  &&
                           `        jQuery.sap.require("sap.ui.core.library");` && |\n|  &&
                           |\n|  &&
                           `        sap.ui.getCore().initLibrary({` && |\n|  &&
                           `            name: "z2ui5",` && |\n|  &&
                           `            dependencies: ["sap.ui.core"],` && |\n|  &&
                           `            types: [],` && |\n|  &&
                           `            interfaces: [],` && |\n|  &&
                           `            controls: ["z2ui5.FileUploader"],` && |\n|  &&
                           `            elements: [],` && |\n|  &&
                           `            version: "0.0.1-SNAPSHOT"` && |\n|  &&
                           `        });` && |\n|  &&
                           |\n|  &&
                           `        jQuery.sap.declare("z2ui5.FileUploader");` && |\n|  &&
                           |\n|  &&
                           `        sap.ui.define([` && |\n|  &&
                           `            "sap/ui/core/Control",` && |\n|  &&
                           `            "sap/m/Button",` && |\n|  &&
                           `            "sap/ui/unified/FileUploader"` && |\n|  &&
                           `        ], function (Control, Button, FileUploader) {` && |\n|  &&
                           `            "use strict";` && |\n|  &&
                           |\n|  &&
                           `            return Control.extend("z2ui5.FileUploader", {` && |\n|  &&
                           |\n|  &&
                           `                metadata: {` && |\n|  &&
                           `                    properties: {` && |\n|  &&
                           `                        value: {` && |\n|  &&
                           `                            type: "string",` && |\n|  &&
                           `                            defaultValue: ""` && |\n|  &&
                           `                        },` && |\n|  &&
                           `                        path: {` && |\n|  &&
                           `                            type: "string",` && |\n|  &&
                           `                            defaultValue: ""` && |\n|  &&
                           `                        },` && |\n|  &&
                           `                        tooltip: {` && |\n|  &&
                           `                            type: "string",` && |\n|  &&
                           `                            defaultValue: ""` && |\n|  &&
                           `                        },` && |\n|  &&
                           `                        fileType: {` && |\n|  &&
                           `                            type: "string",` && |\n|  &&
                           `                            defaultValue: ""` && |\n|  &&
                           `                        },` && |\n|  &&
                           `                        placeholder: {` && |\n|  &&
                           `                            type: "string",` && |\n|  &&
                           `                            defaultValue: ""` && |\n|  &&
                           `                        },` && |\n|  &&
                           `                        buttonText: {` && |\n|  &&
                           `                            type: "string",` && |\n|  &&
                           `                            defaultValue: "Upload"` && |\n|  &&
                           `                        },` && |\n|  &&
                           `                        enabled: {` && |\n|  &&
                           `                            type: "boolean",` && |\n|  &&
                           `                            defaultValue: true` && |\n|  &&
                           `                        },` && |\n|  &&
                           `                        multiple: {` && |\n|  &&
                           `                            type: "boolean",` && |\n|  &&
                           `                            defaultValue: false` && |\n|  &&
                           `                        }` && |\n|  &&
                           `                    },` && |\n|  &&
                           |\n|  &&
                           |\n|  &&
                           `                    aggregations: {` && |\n|  &&
                           `                    },` && |\n|  &&
                           `                    events: {` && |\n|  &&
                           `                        "upload": {` && |\n|  &&
                           `                            allowPreventDefault: true,` && |\n|  &&
                           `                            parameters: {}` && |\n|  &&
                           `                        }` && |\n|  &&
                           `                    },` && |\n|  &&
                           `                    renderer: null` && |\n|  &&
                           `                },` && |\n|  &&
                           |\n|  &&
                           `                renderer: function (oRm, oControl) {` && |\n|  &&
                           |\n|  &&
                           `                    oControl.oUploadButton = new Button({` && |\n|  &&
                           `                        text: oControl.getProperty("buttonText"),` && |\n|  &&
                           `                        enabled: oControl.getProperty("path") !== "",` && |\n|  &&
                           `                        press: function (oEvent) {` && |\n|  &&
                           |\n|  &&
                           `                            this.setProperty("path", this.oFileUploader.getProperty("value"));` && |\n|  &&
                           |\n|  &&
                           `                            var file = this.oFileUploader.oFileUpload.files[0];` && |\n|  &&
                           `                            var reader = new FileReader();` && |\n|  &&
                           |\n|  &&
                           `                            reader.onload = function (evt) {` && |\n|  &&
                           `                                var vContent = evt.currentTarget.result;` && |\n|  &&
                           `                                this.setProperty("value", vContent);` && |\n|  &&
                           `                                this.fireUpload();` && |\n|  &&
                           `                                //this.getView().byId('picture' ).getDomRef().src = vContent;` && |\n|  &&
                           `                            }.bind(this)` && |\n|  &&
                           |\n|  &&
                           `                            reader.readAsDataURL(file);` && |\n|  &&
                           `                        }.bind(oControl)` && |\n|  &&
                           `                    });` && |\n|  &&
                           |\n|  &&
                           `                    oControl.oFileUploader = new FileUploader({` && |\n|  &&
                           `                        icon: "sap-icon://browse-folder",` && |\n|  &&
                           `                        iconOnly: true,` && |\n|  &&
                           `                        value: oControl.getProperty("path"),` && |\n|  &&
                           `                        placeholder: oControl.getProperty("placeholder"),` && |\n|  &&
                           `                        change: function (oEvent) {` && |\n|  &&
                           `                            var value = oEvent.getSource().getProperty("value");` && |\n|  &&
                           `                            this.setProperty("path", value);` && |\n|  &&
                           `                            if (value) {` && |\n|  &&
                           `                                this.oUploadButton.setEnabled();` && |\n|  &&
                           `                            } else {` && |\n|  &&
                           `                                this.oUploadButton.setEnabled(false);` && |\n|  &&
                           `                            }` && |\n|  &&
                           `                            this.oUploadButton.rerender();` && |\n|  &&
                           `                        }.bind(oControl)` && |\n|  &&
                           `                    });` && |\n|  &&
                           |\n|  &&
                           `                    var hbox = new sap.m.HBox();` && |\n|  &&
                           `                    hbox.addItem(oControl.oFileUploader);` && |\n|  &&
                           `                    hbox.addItem(oControl.oUploadButton);` && |\n|  &&
                           `                    oRm.renderControl(hbox);` && |\n|  &&
                           `                }` && |\n|  &&
                           `            });` && |\n|  &&
                           `        });` && |\n|  &&
                           `    });` && |\n|  &&
                           `</script>` && |\n|  &&
                           |\n|  &&
                           `</html>`.
  ENDMETHOD.


  METHOD main_roundtrip.

    DATA(lo_runtime) = z2ui5_lcl_system_runtime=>execute_init( ).

    DO.
      TRY.

          DATA(li_client) = lo_runtime->execute_before_app( ).

          IF lo_runtime->ms_actual-lifecycle_method = z2ui5_if_client=>cs-lifecycle_method-on_init.
            ROLLBACK WORK.
            CAST z2ui5_if_app( lo_runtime->ms_db-o_app )->controller( li_client ).
            ROLLBACK WORK.
            lo_runtime->ms_actual-lifecycle_method = z2ui5_if_client=>cs-lifecycle_method-on_event.
          ENDIF.

          ROLLBACK WORK.
          CAST z2ui5_if_app( lo_runtime->ms_db-o_app )->controller( li_client ).
          ROLLBACK WORK.

        CATCH cx_root INTO DATA(cx).
          lo_runtime = lo_runtime->set_app_system_error( kind = 'ON_EVENT' ix = cx ).
          CONTINUE.
      ENDTRY.


      IF lo_runtime->ms_next-s_nav_app_call_new IS NOT INITIAL.
        lo_runtime = lo_runtime->set_app_call_new( ).
        CONTINUE.
      ENDIF.

      IF lo_runtime->ms_next-nav_app_leave_to_id IS NOT INITIAL.
        lo_runtime = lo_runtime->set_app_leave_to_id( ).
        CONTINUE.
      ENDIF.


      TRY.

          li_client = lo_runtime->execute_before_app( z2ui5_if_client=>cs-lifecycle_method-on_rendering ).
          ROLLBACK WORK.
          CAST z2ui5_if_app( lo_runtime->ms_db-o_app )->controller( li_client ).
          ROLLBACK WORK.

          result = lo_runtime->execute_finish( ).


        CATCH cx_root INTO cx.
          lo_runtime = lo_runtime->set_app_system_error( kind = 'ON_RENDERING' ix = cx ).
          CONTINUE.
      ENDTRY.

      RETURN.
    ENDDO.

  ENDMETHOD.
ENDCLASS.
