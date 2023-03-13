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

    DATA(lv_url) = client-t_header[ name = '~path' ]-value.
    TRY.
        DATA(lv_app) = client-t_param[ name = 'app' ]-value.
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
                           `                        if (oView.oResponse.FOCUS_POS) {` && |\n|  &&
                           `                            ofocus.cursorPos = oView.oResponse.FOCUS_POS;` && |\n|  &&
                           `                            ofocus.selectionStart = oView.oResponse.FOCUS_POS; ` && |\n|  &&
                           `                            ofocus.selectionEnd = oView.oResponse.FOCUS_POS;` && |\n|  &&
                           `                        }` && |\n|  &&
                           `                        oView.byId('focus').applyFocusInfo(ofocus);` && |\n|  &&
                           `                    } catch (error) { };` && |\n|  &&
                           `                    try {` && |\n|  &&
                           `                    oView.getContent()[0].getApp().scrollTo(oView.oResponse.PAGE_SCROLL_POS);` && |\n|  &&
                           `                     } catch (error) { };` && |\n|  &&
                           `                },` && |\n|  &&
                           |\n|  &&
                           `                onEvent: function (oEvent, oEvent2, oEvent3, oEvent4) {` && |\n|  &&
                           `                    this.oBody = this.oView.getModel().oData.oUpdate;` && |\n|  &&
                           `                    this.oBody.oEvent = oEvent;` && |\n|  &&
                  `                    try {                                                           ` && |\n| &&
                     `                     this.oBody.scrollPos =  parseInt( this.oView.getContent()[ 0 ].getApp().getScrollDelegate().getScrollTop() );  ` && |\n| &&
                     `                      } catch (exceptionVar) { };  ` && |\n|  &&
                           `                    if (!window.navigator.onLine) {` && |\n|  &&
                           `                        sap.m.MessageBox.alert('No internet connection! Please reconnect to the server and try again.');` && |\n|  &&
                           `                        return;` && |\n|  &&
                           `                    }` && |\n|  &&
                           `                    if (this.oView.getModel().oData.oUpdate.oSystem.CHECK_DEBUG_ACTIVE) {` && |\n|  &&
                           `                        console.log('Request Object:');` && |\n|  &&
                           `                        console.log(this.oBody);` && |\n|  &&
                           `                    }` && |\n|  &&
                           `                    this.Roundtrip();` && |\n|  &&
                           `                },` && |\n|  &&
                           `                Roundtrip: function () {` && |\n|  &&
                           `                    this.oView.destroy();` && |\n|  &&
                           `                    sap.ui.core.BusyIndicator.show();` && |\n|  &&
                           `                    if (this.getView().oPopup) {` && |\n|  &&
                           `                        //    if (this.getView( ).oPopup){ this.getView( ).oPopup.close(); }` && |\n|  &&
                           `                        this.getView().oPopup.destroy();` && |\n|  &&
                           `                    }` && |\n|  &&
                           `                    var xhr = new XMLHttpRequest();` && |\n|  &&
                                                 `    var url = '` && lv_url && `';` && |\n| &&
                           `                    xhr.open("POST", url, true);` && |\n|  &&
                           `                    xhr.onload = function (that) {` && |\n|  &&
                           `                        if (that.target.status !== 200) {` && |\n|  &&
                           `                            document.write(that.target.response);` && |\n|  &&
                           `                            return;` && |\n|  &&
                           `                        }` && |\n|  &&
                           `                        var oResponse = JSON.parse(that.target.response);` && |\n|  &&
                           `                        if (oResponse.oSystem.CHECK_DEBUG_ACTIVE) {` && |\n|  &&
                           `                            console.log('Response Object:');` && |\n|  &&
                           `                            console.log(oResponse);` && |\n|  &&
                           `                            console.log('UI5-XML-View:');` && |\n|  &&
                           `                            console.log(oResponse.vView);` && |\n|  &&
                           `                        }` && |\n|  &&
                           |\n|  &&
                           `                        if (oResponse.oAfter) {` && |\n|  &&
                           `                            oResponse.oAfter.forEach(item => sap.m[item[0]][item[1]](item[2]));` && |\n|  &&
                           `                        }` && |\n|  &&
                           `                        oResponse.oViewModel.oUpdate.oSystem = oResponse.oSystem;` && |\n|  &&
                           `                        var oModel = new JSONModel(oResponse.oViewModel);` && |\n|  &&
                           |\n|  &&
                           `                        if (oResponse.vViewPopup) {` && |\n|  &&
                           `                            const popup = new sap.ui.core.Fragment.load({` && |\n|  &&
                           `                                definition: oResponse.vViewPopup,` && |\n|  &&
                           `                                controller: this,` && |\n|  &&
                           `                            }).then(function (oFragment) {` && |\n|  &&
                           |\n|  &&
                           `                                //  oFragment.setModel(oModel);                                       ` && |\n|  &&
                           `                                this.getView().addDependent(oFragment);` && |\n|  &&
                           `                                oFragment.open();` && |\n|  &&
                           `                                this.getView().oPopup = oFragment;` && |\n|  &&
                           |\n|  &&
                           `                            }` && |\n|  &&
                           `                                .bind(this));` && |\n|  &&
                           `                        }` && |\n|  &&
                           `                        if (oResponse.vView) {` && |\n|  &&
                           |\n|  &&
                           `                            this.oReponse = oResponse;` && |\n|  &&
                           `                            var oView = new sap.ui.core.mvc.XMLView.create({` && |\n|  &&
                           `                                viewContent: oResponse.vView,` && |\n|  &&
                           `                                definition: oResponse.vView,` && |\n|  &&
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
                           `                                oView.oResponse = this.oReponse;` && |\n|  &&
                           `                                this.oView = oView;` && |\n|  &&
                           `                                ` && |\n|  &&
                           `                                try {` && |\n|  &&
                           `                                    setTimeout(() => {` && |\n|  &&
                           |\n|  &&
                           `                                    }, 200);` && |\n|  &&
                           `                                } catch (exceptionVar) { };` && |\n|  &&
                           `                                sap.ui.core.BusyIndicator.hide();` && |\n|  &&
                           `                            }` && |\n|  &&
                           `                            );` && |\n|  &&
                           `                        }` && |\n|  &&
                           `                    }` && |\n|  &&
                           `                        .bind(this);` && |\n|  &&
                           `                    xhr.send(JSON.stringify(this.oBody));` && |\n|  &&
                           `                },` && |\n|  &&
                           `            });` && |\n|  &&
                           `        });` && |\n|  &&
                           `        var oView = sap.ui.xmlview({` && |\n|  &&
                           `            viewContent: "<mvc:View controllerName='MyController' xmlns:mvc='sap.ui.core.mvc' />"` && |\n|  &&
                           `        });` && |\n|  &&
                           `        oView.getController().Roundtrip();` && |\n|  &&
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

    z2ui5_lcl_system_runtime=>client-t_header = client-t_header.
    z2ui5_lcl_system_runtime=>client-t_param  = client-t_param.
    z2ui5_lcl_system_runtime=>client-o_body   = z2ui5_lcl_utility_tree_json=>factory( client-body ).

    DATA(lo_runtime) = NEW z2ui5_lcl_system_runtime( ).
    result = lo_runtime->execute_init( ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    DO.

      TRY.

          lo_runtime->mv_event = ''.

          lo_runtime->set_get( ).

          ROLLBACK WORK.
          CAST z2ui5_if_app( lo_runtime->ms_db-o_app )->controller( NEW z2ui5_lcl_if_client( lo_runtime ) ).
          ROLLBACK WORK.

          lo_runtime->mv_event_custom = ''.

        CATCH cx_root INTO DATA(cx).
          DATA(lo_runtime_error) = lo_runtime->factory_new_error( kind = 'ON_EVENT' ix = cx ).
          z2ui5_lcl_db=>create(
                id       = lo_runtime->ms_db-id
                db       = lo_runtime->ms_db
                ).
          lo_runtime_error->ms_db-id_prev_app = lo_runtime->ms_db-id.
          lo_runtime = lo_runtime_error.
          CONTINUE.
      ENDTRY.

      IF lo_runtime->ms_leave_to_app IS NOT INITIAL.
        z2ui5_lcl_db=>create(
                id = lo_runtime->ms_db-id
                db = lo_runtime->ms_db ).
        DATA lo_runtime_new TYPE REF TO z2ui5_lcl_system_runtime.
        lo_runtime_new = lo_runtime->factory_new( CAST #( lo_runtime->ms_leave_to_app-o_app ) ).
        lo_runtime_new->ms_db-id_prev_app = lo_runtime->ms_db-id.
        lo_runtime_new->ms_db-screen = lo_runtime->ms_leave_to_app-screen.
        lo_runtime = lo_runtime_new.
        lo_runtime->ms_control-event_type = z2ui5_if_client=>cs-lifecycle_method-on_init.
        CONTINUE.
      ENDIF.


      IF lo_runtime->mv_nav_id IS NOT INITIAL.
        DATA(ls_db) = z2ui5_lcl_db=>load_app( lo_runtime->mv_nav_id ).
        lo_runtime->mv_nav_id = ``.
        DATA(Lv_event) = lo_runtime->mv_event.

        z2ui5_lcl_db=>create(
               id = lo_runtime->ms_db-id
               db = lo_runtime->ms_db ).

        lo_runtime = NEW #( ).
        lo_runtime->ms_db = ls_db.
        lo_runtime->mv_event_custom = lv_event.
        lo_runtime->ms_control-event_type = z2ui5_if_client=>cs-lifecycle_method-on_event.
        CONTINUE.
      ENDIF.


      TRY.
          ROLLBACK WORK.
          lo_runtime->ms_get-lifecycle_method = z2ui5_if_client=>cs-lifecycle_method-on_rendering.
          CAST z2ui5_if_app( lo_runtime->ms_db-o_app )->controller( NEW z2ui5_lcl_if_client( lo_runtime ) ).
          ROLLBACK WORK.


          result = lo_runtime->execute_finish( ).
          z2ui5_lcl_db=>create(
            id       = lo_runtime->ms_db-id
            response = result
            db       = lo_runtime->ms_db
          ).

          EXIT.

        CATCH cx_root INTO cx.
          lo_runtime_error = lo_runtime->factory_new_error( kind = 'ON_RENDERING' ix = cx ).
          lo_runtime_error->ms_db-id_prev_app = lo_runtime->ms_db-id_prev_app.
          lo_runtime = lo_runtime_error.
          CONTINUE.
      ENDTRY.

    ENDDO.
    " lo_runtime->db_save( result ).

  ENDMETHOD.
ENDCLASS.
