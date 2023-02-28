CLASS z2ui5_cl_http_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      BEGIN OF cs_config,
        theme            TYPE string    VALUE 'sap_horizon',
        browser_title    TYPE string    VALUE 'ABAP2UI5',
        repository       TYPE string    VALUE 'https://ui5.sap.com/resources/sap-ui-core.js',
        letterboxing     TYPE abap_bool VALUE abap_true,
        check_debug_mode TYPE abap_bool VALUE abap_true,
      END OF cs_config.

    types:
      begin of ty_S_name_value,
        name type string,
        value type string,
      end of ty_S_name_value.
    types ty_t_name_value type standard table of ty_S_name_value.

    CLASS-DATA:
      BEGIN OF client,
        body     TYPE string,
        t_header TYPE ty_t_name_value, "tihttpnvp,
        t_param  TYPE ty_t_name_value, "tihttpnvp,
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



CLASS Z2UI5_CL_HTTP_HANDLER IMPLEMENTATION.


  METHOD main_index_html.
    data lv_url type string.
    lv_url = client-t_header[ name = '~path' ]-value.
    TRY.
        data lv_app type string.
        lv_app = client-t_param[ name = 'app' ]-value.
        lv_url = lv_url && `?app=` && lv_app.
      CATCH cx_root.
    ENDTRY.

    r_result = `<html>` && |\n|  &&
               `<head>` && |\n|  &&
               `    <meta charset="utf-8">` && |\n|  &&
               `    <title>` && cs_config-browser_title && `</title>` && |\n|  &&
               `    <script src="` && cs_config-repository && `" ` &&
               ` id="sap-ui-bootstrap" data-sap-ui-theme="` && cs_config-theme && `"` && |\n|  &&
               `        data-sap-ui-libs="sap.m" data-sap-ui-bindingSyntax="complex" data-sap-ui-compatVersion="edge"` && |\n|  &&
               `        data-sap-ui-preload="async">` && |\n|  &&
               `     </script>` && |\n|.

    r_result = r_result && `</head>` && |\n|  &&
                 `    <body class="sapUiBody">` && |\n|  &&
                 `        <div id="content"></div>` && |\n|  &&
                 `    </body>` && |\n|  &&
                 `</html>` && |\n|  &&
                 `<script>` && |\n|  &&
                 `    sap.ui.getCore().attachInit(function() {` && |\n|  &&
                 `        "use strict";` && |\n|  &&
                 `        sap.ui.define(["sap/ui/core/mvc/Controller", "sap/ui/model/odata/v2/ODataModel", "sap/ui/model/json/JSONModel", "sap/m/MessageBox", "sap/ui/core/Fragment"], function(Controller, ODataModel, JSONModel, MessageBox, Fragment) {` &&
                 `            "use strict";` && |\n|  &&
                 `            return Controller.extend("MyController", {` && |\n|  &&
                 `                onEvent: function(oEvent, oEvent2, oEvent3, oEvent4) {` && |\n|  &&
                 `                    this.oBody = this.oView.getModel().oData.oUpdate;` && |\n|  &&
                 `                    this.oBody.oEvent = oEvent;` && |\n|  &&
                 `                    if (this.oView.getModel().oData.oUpdate.oSystem.CHECK_DEBUG_ACTIVE) {` && |\n|  &&
                 `                        console.log(this.oBody);` && |\n|  &&
                 `                    }` && |\n|  &&
                 `                    this.Roundtrip();` && |\n|  &&
                 `                },` && |\n|  &&
                 `                Roundtrip: function() {` && |\n|  &&
                 `                    this.oView.destroy();` && |\n|  &&
                 `                    sap.ui.core.BusyIndicator.show();` && |\n|  &&
                 `                    if (this.getView().oPopup) {` && |\n|  &&
                 `                        //    if (this.getView( ).oPopup){ this.getView( ).oPopup.close(); }` && |\n|  &&
                 `                        this.getView().oPopup.destroy();` && |\n|  &&
                 `                    }` && |\n|  &&
                 `                    var xhr = new XMLHttpRequest();` && |\n|  &&
                 `                    var url = '` && lv_url && `';` && |\n|  &&
                 `                    xhr.open("POST", url, true);` && |\n|  &&
                 `                    xhr.onload = function(that) {` && |\n|  &&
                 `                        if (that.target.status == 500) {` && |\n|  &&
                 `                            document.write(that.target.response);` && |\n|  &&
                 `                            return;` && |\n|  &&
                 `                        }` && |\n|  &&
                 `                        var oResponse = JSON.parse(that.target.response);` && |\n|  &&
                 `                        if (oResponse.oSystem.CHECK_DEBUG_ACTIVE) {` && |\n|  &&
                 `                            console.log(oResponse);` && |\n|  &&
                 `                            console.log(oResponse.vView);` && |\n|  &&
                 `                        }` && |\n|  &&
                 |\n|  &&
                 `                        if (oResponse.oAfter) {` && |\n|  &&
                 `                            oResponse.oAfter.forEach(item=>sap.m[item[0]][item[1]](item[2]));` && |\n|  &&
                 `                        }` && |\n|  &&
                 `                        oResponse.oViewModel.oUpdate.oSystem = oResponse.oSystem;` && |\n|  &&
                 `                        var oModel = new JSONModel(oResponse.oViewModel);` && |\n|  &&
                 |\n|  &&
                 `                        if (oResponse.vViewPopup) {` && |\n|  &&
                 `                            const popup = new sap.ui.core.Fragment.load({` && |\n|  &&
                 `                                definition: oResponse.vViewPopup,` && |\n|  &&
                 `                                controller: this,` && |\n|  &&
                 `                            }).then(function(oFragment) {` && |\n|  &&
                 |\n|  &&
                 `                                //  oFragment.setModel(oModel);                                       ` && |\n|  &&
                 `                                this.getView().addDependent(oFragment);` && |\n|  &&
                 `                                oFragment.open();` && |\n|  &&
                 `                                this.getView().oPopup = oFragment;` && |\n|  &&
                 |\n|  &&
                 `                            }` && |\n|  &&
                 `                            .bind(this));` && |\n|  &&
                 `                        }` && |\n|  &&
                 `                        //  this.oView.destroy();                                                     ` && |\n|  &&
                 `                        if (oResponse.vView) {` && |\n|  &&
                 |\n|  &&
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
                 `                            }).then(oView=>{` && |\n|  &&
                 `                                oView.setModel(oModel);` && |\n|  &&
                 `                                oView.placeAt("content");` && |\n|  &&
                 `                                this.oView = oView;` && |\n|  &&
                 `                                sap.ui.core.BusyIndicator.hide();` && |\n|  &&
                 `                            }` && |\n|  &&
                 `                            );` && |\n|  &&
                 `                        }` && |\n|  &&
                 `                    }` && |\n|  &&
                 `                    .bind(this);` && |\n|  &&
                 `                    xhr.send(JSON.stringify(this.oBody));` && |\n|  &&
                 `                },` && |\n|  &&
                 `            });` && |\n|  &&
                 `        });` && |\n|  &&
                 `        var oView = sap.ui.xmlview({` && |\n|  &&
                 `            viewContent: "<mvc:View controllerName='MyController' xmlns:mvc='sap.ui.core.mvc' />"` && |\n|  &&
                 `        });` && |\n|  &&
                 `        oView.getController().Roundtrip();` && |\n|  &&
                 `    });` && |\n|  &&
                 `</script>` && |\n|  &&
                 `</html>`.

  ENDMETHOD.


  METHOD main_roundtrip.

    z2ui5_lcl_system_runtime=>client-t_header = client-t_header.
    z2ui5_lcl_system_runtime=>client-t_param  = client-t_param.
    z2ui5_lcl_system_runtime=>client-o_body   = z2ui5_lcl_utility_tree_json=>factory( client-body ).

    data lo_runtime type ref to z2ui5_lcl_system_runtime.
    create object lo_runtime.
    result = lo_runtime->execute_init(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    DO.

      TRY.

          ROLLBACK WORK.
          CAST z2ui5_if_app( lo_runtime->ms_db-o_app )->controller( NEW z2ui5_lcl_if_client( lo_runtime ) ).
          ROLLBACK WORK.

          data cx type ref to cx_root.
        CATCH cx_root INTO cx.
          data lo_runtime_error type ref to z2ui5_lcl_system_runtime.
          lo_runtime_error = lo_runtime->factory_new_error( kind = 'ON_EVENT' ix = cx ).
          lo_runtime->db_save( ).
          lo_runtime_error->ms_db-id_prev_app = lo_runtime->ms_db-id.
          lo_runtime = lo_runtime_error.
          CONTINUE.
      ENDTRY.

      IF lo_runtime->ms_leave_to_app IS NOT INITIAL.
        lo_runtime->db_save( ).
        data lo_runtime_new type ref to z2ui5_lcl_system_runtime.
        lo_runtime_new = lo_runtime->factory_new( CAST #( lo_runtime->ms_leave_to_app-o_app ) ).
        lo_runtime_new->ms_db-id_prev_app = lo_runtime->ms_db-id.
        lo_runtime_new->ms_db-screen = lo_runtime->ms_leave_to_app-screen.
        lo_runtime = lo_runtime_new.
        lo_runtime->ms_control-event_type = z2ui5_if_client=>cs-lifecycle_method-on_init.
        CONTINUE.
      ENDIF.

      TRY.
          ROLLBACK WORK.
          lo_runtime->ms_control-event_type = z2ui5_if_client=>cs-lifecycle_method-on_rendering.
          CAST z2ui5_if_app( lo_runtime->ms_db-o_app )->controller( NEW z2ui5_lcl_if_client( lo_runtime ) ).
          ROLLBACK WORK.

        CATCH cx_root INTO cx.
          lo_runtime = lo_runtime->factory_new_error( kind = 'ON_SCREEN' ix = cx ).
          CONTINUE.
      ENDTRY.

      EXIT.
    ENDDO.

    result = lo_runtime->execute_finish( ).
    lo_runtime->db_save( result ).

  ENDMETHOD.
ENDCLASS.
