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
        VALUE(r_result) TYPE string.

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
            lo_runtime = lo_runtime->set_app_leave_to_id( ).
            CONTINUE.
          ENDIF.

          IF lo_runtime->ms_next-s_nav_app_call_new IS NOT INITIAL.
            lo_runtime = lo_runtime->set_app_call_new( ).
            CONTINUE.
          ENDIF.

          result = lo_runtime->request_end( ).

        CATCH cx_root INTO DATA(x).
          lo_runtime = lo_runtime->set_app_system_error( x ).
          CONTINUE.
      ENDTRY.

      EXIT.
    ENDDO.

  ENDMETHOD.


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



    r_result = r_result && `<script>` && |\n|  &&
                           `    sap.ui.getCore().attachInit(function () {` && |\n|  &&
                           `        "use strict";` && |\n|  &&

`        sap.ui.define(["sap/ui/core/mvc/Controller", "sap/ui/model/odata/v2/ODataModel", "sap/ui/model/json/JSONModel", "sap/m/MessageBox", "sap/ui/core/Fragment"], function (Controller, ODataModel, JSONModel, MessageBox, Fragment) {` && |\n|  &&
                           `            "use strict";` && |\n|  &&
                           `            return Controller.extend("z2ui5_controller", {` && |\n|  &&
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
                                         ` if (sap.z2ui5.oResponse.vViewPopup) {` && |\n|  &&
                           `                            new sap.ui.core.Fragment.load({` && |\n|  &&
                           `                                definition: sap.z2ui5.oResponse.vViewPopup,` && |\n|  &&
                           `                                controller: this,` && |\n|  &&
                           `                            }).then(function (oFragment) {` && |\n|  &&
                           `                                oFragment.setModel(new JSONModel(sap.z2ui5.oResponse.oViewModel))` && |\n|  &&
                           `                                this.getView().addDependent(oFragment);` && |\n|  &&
                           `                                if (!sap.z2ui5.oResponse.OPENBY){ oFragment.open(); }else{` && |\n|  &&
                           `                               oFragment.openBy( this.getView().byId( sap.z2ui5.oResponse.OPENBY )       )          } ` && |\n|  &&
                           `                                sap.z2ui5.oResponse.oViewPopup = oFragment;` && |\n|  &&
                           `                                sap.ui.core.BusyIndicator.hide();` && |\n|  &&
                           `                            }.bind(this)); }` && |\n|  &&
                           `                    sap.ui.core.BusyIndicator.hide();` && |\n|  &&
                           `                },` && |\n|  &&
                           |\n|  &&
                           `                onEventFrontend: function (vAction) {` && |\n|  &&
                           |\n|  &&
                           `                    if (vAction == 'POPUP_CLOSE') {` && |\n|  &&
                           `                        sap.z2ui5.oResponse.oViewPopup.close();` && |\n|  &&
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
                           `                    ` && |\n|  &&
                           `                    if (sap.z2ui5.oResponse.oViewPopup) {` && |\n|  &&
                           `                        this.oBody.oUpdate = sap.z2ui5.oResponse.oViewPopup.getModel().oData.oUpdate;` && |\n|  &&
                           `                        sap.z2ui5.oResponse.oViewPopup.close();` && |\n|  &&
                           `                        sap.z2ui5.oResponse.oViewPopup.destroy();` && |\n|  &&
                           `                    } else {` && |\n|  &&
                           `                        this.oBody.oUpdate = this.oView.getModel().oData.oUpdate;` && |\n|  &&
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
                           `                    this.oView.destroy();` && |\n|  &&
                           `                    this.Roundtrip();` && |\n|  &&
                           `                },` && |\n|  &&
                           |\n|  &&
                           `                Roundtrip: function () {` && |\n|  &&
                           |\n|  &&
                           `                    var xhr = new XMLHttpRequest();` && |\n|  &&
                                                     `    var url = '` && lv_url && `';` && |\n| &&
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

                           |\n|  &&
                           `                        if (sap.z2ui5.oResponse.vView) {` && |\n|  &&
                           `                            var oModel = new JSONModel(sap.z2ui5.oResponse.oViewModel);` && |\n|  &&
                           `                            var oView = new sap.ui.core.mvc.XMLView.create({` && |\n|  &&
                           `                                definition: sap.z2ui5.oResponse.vView,` && |\n|  &&
                           `                            }).then(oView => {` && |\n|  &&
                           `                                oView.setModel(oModel);` && |\n|  &&
                           `                                oView.placeAt("content");` && |\n|  &&
                           `                                this.oView = oView;` && |\n|  &&
                           `                                sap.z2ui5.oView = oView;` && |\n|  &&
                           `                            } ); ` && |\n|  &&
                           `                        } else if (sap.z2ui5.oResponse.SET_PREV_VIEW == true) {` && |\n|  &&
                           |\n|  &&
                           `                            var oModel = new JSONModel(sap.z2ui5.oResponseOld.oViewModel);` && |\n|  &&
                           `                            var oView = new sap.ui.core.mvc.XMLView.create({ ` && |\n|  &&
                           `                                definition: sap.z2ui5.oResponseOld.vView` && |\n|  &&
                           `                            }).then(oView => {` && |\n|  &&
                           `                                oView.setModel(oModel);` && |\n|  &&
                           `                                oView.placeAt("content");` && |\n|  &&
                           `                                this.oView = oView;` && |\n|  &&
                           `                                sap.z2ui5.oView = oView;` && |\n|  &&
                           `                            });` && |\n|  &&
                           `                        } }.bind(this);` && |\n|  &&
                           `                    xhr.send(JSON.stringify(this.oBody));` && |\n|  &&
                           `                },` && |\n|  &&
                           `            });` && |\n|  &&
                           `        });` && |\n|  &&
                           `        var oView = sap.ui.xmlview({` && |\n|  &&
                           `            viewContent: "<mvc:View controllerName='z2ui5_controller' xmlns:mvc='sap.ui.core.mvc' />"` && |\n|  &&
                           `        });` && |\n|  &&
                           `        sap.z2ui5 = {};` && |\n|  &&
                           `        oView.getController().Roundtrip();`.





    r_result = r_result &&   `        jQuery.sap.declare("my.library");` && |\n| &&
                `        jQuery.sap.require("sap.ui.core.Core");` && |\n| &&
                `        jQuery.sap.require("sap.ui.core.library");` && |\n| &&
                |\n| &&
                `        sap.ui.getCore().initLibrary({` && |\n| &&
                `            name: "z2ui5",` && |\n| &&
                `            dependencies: ["sap.ui.core"],` && |\n| &&
                `            types: [],` && |\n| &&
                `            interfaces: [],` && |\n| &&
                `            controls: ["z2ui5.FileUploader"],` && |\n| &&
                `            elements: [],` && |\n| &&
                `            version: "0.0.1-SNAPSHOT"` && |\n| &&
                `        });` && |\n| &&
                |\n| &&
                `        jQuery.sap.declare("z2ui5.FileUploader");` && |\n| &&
                |\n| &&
                `        sap.ui.define([` && |\n| &&
                `            "sap/ui/core/Control",` && |\n| &&
                `            "sap/m/Button",` && |\n| &&
                `            "sap/ui/unified/FileUploader"` && |\n| &&
                `        ], function (Control, Button, FileUploader) {` && |\n| &&
                `            "use strict";` && |\n| &&
                |\n| &&
                `            return Control.extend("z2ui5.FileUploader", {` && |\n| &&
                |\n| &&
                `                metadata: {` && |\n| &&
                `                    properties: {` && |\n| &&
                `                        value: {` && |\n| &&
                `                            type: "string",` && |\n| &&
                `                            defaultValue: ""` && |\n| &&
                `                        },` && |\n| &&
                `                        path: {` && |\n| &&
                `                            type: "string",` && |\n| &&
                `                            defaultValue: ""` && |\n| &&
                `                        },` && |\n| &&
                `                        tooltip: {` && |\n| &&
                `                            type: "string",` && |\n| &&
                `                            defaultValue: ""` && |\n| &&
                `                        },` && |\n| &&
                `                        fileType: {` && |\n| &&
                `                            type: "string",` && |\n| &&
                `                            defaultValue: ""` && |\n| &&
                `                        },` && |\n| &&
                `                        placeholder: {` && |\n| &&
                `                            type: "string",` && |\n| &&
                `                            defaultValue: ""` && |\n| &&
                `                        },` && |\n| &&
                `                        buttonText: {` && |\n| &&
                `                            type: "string",` && |\n| &&
                `                            defaultValue: "Upload"` && |\n| &&
                `                        },` && |\n| &&
                `                        enabled: {` && |\n| &&
                `                            type: "boolean",` && |\n| &&
                `                            defaultValue: true` && |\n| &&
                `                        },` && |\n| &&
                `                        multiple: {` && |\n| &&
                `                            type: "boolean",` && |\n| &&
                `                            defaultValue: false` && |\n| &&
                `                        }` && |\n| &&
                `                    },` && |\n| &&
                |\n| &&
                |\n| &&
                `                    aggregations: {` && |\n| &&
                `                    },` && |\n| &&
                `                    events: {` && |\n| &&
                `                        "upload": {` && |\n| &&
                `                            allowPreventDefault: true,` && |\n| &&
                `                            parameters: {}` && |\n| &&
                `                        }` && |\n| &&
                `                    },` && |\n| &&
                `                    renderer: null` && |\n| &&
                `                },` && |\n| &&
                |\n| &&
                `                renderer: function (oRm, oControl) {` && |\n| &&
                |\n| &&
                `                    oControl.oUploadButton = new Button({` && |\n| &&
                `                        text: oControl.getProperty("buttonText"),` && |\n| &&
                `                        enabled: oControl.getProperty("path") !== "",` && |\n| &&
                `                        press: function (oEvent) {` && |\n| &&
                |\n| &&
                `                            this.setProperty("path", this.oFileUploader.getProperty("value"));` && |\n| &&
                |\n| &&
                `                            var file = this.oFileUploader.oFileUpload.files[0];` && |\n| &&
                `                            var reader = new FileReader();` && |\n| &&
                |\n| &&
                `                            reader.onload = function (evt) {` && |\n| &&
                `                                var vContent = evt.currentTarget.result;` && |\n| &&
                `                                this.setProperty("value", vContent);` && |\n| &&
                `                                this.fireUpload();` && |\n| &&
                `                                //this.getView().byId('picture' ).getDomRef().src = vContent;` && |\n| &&
                `                            }.bind(this)` && |\n| &&
                |\n| &&
                `                            reader.readAsDataURL(file);` && |\n| &&
                `                        }.bind(oControl)` && |\n| &&
                `                    });` && |\n| &&
                |\n| &&
                `                    oControl.oFileUploader = new FileUploader({` && |\n| &&
                `                        icon: "sap-icon://browse-folder",` && |\n| &&
                `                        iconOnly: true,` && |\n| &&
                `                        value: oControl.getProperty("path"),` && |\n| &&
                `                        placeholder: oControl.getProperty("placeholder"),` && |\n| &&
                `                        change: function (oEvent) {` && |\n| &&
                `                            var value = oEvent.getSource().getProperty("value");` && |\n| &&
                `                            this.setProperty("path", value);` && |\n| &&
                `                            if (value) {` && |\n| &&
                `                                this.oUploadButton.setEnabled();` && |\n| &&
                `                            } else {` && |\n| &&
                `                                this.oUploadButton.setEnabled(false);` && |\n| &&
                `                            }` && |\n| &&
                `                            this.oUploadButton.rerender();` && |\n| &&
                `                        }.bind(oControl)` && |\n| &&
                `                    });` && |\n| &&
                |\n| &&
                `                    var hbox = new sap.m.HBox();` && |\n| &&
                `                    hbox.addItem(oControl.oFileUploader);` && |\n| &&
                `                    hbox.addItem(oControl.oUploadButton);` && |\n| &&
                `                    oRm.renderControl(hbox);` && |\n| &&
                `                }` && |\n| &&
                `            });` && |\n| &&
                `        });` && |\n| &&
                `    });` && |\n| &&
                `</script>` && |\n| &&
                |\n| &&
                `</html>`.
  ENDMETHOD.
ENDCLASS.
