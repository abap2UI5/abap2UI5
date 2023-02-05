CLASS z2ui5_cl_http_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      BEGIN OF cs_config,
        theme         TYPE string    VALUE 'sap_horizon',
        browser_title TYPE string    VALUE 'ABAP2UI5',
        repository    TYPE string    VALUE 'https://ui5.sap.com/resources/sap-ui-core.js',
        letterboxing  TYPE abap_bool VALUE abap_true,
        debug_mode_on TYPE abap_bool VALUE abap_false,
      END OF cs_config.

    CLASS-DATA:
      BEGIN OF client,
        o_body   TYPE REF TO z2ui5_cl_hlp_tree_json,
        t_header TYPE if_web_http_request=>name_value_pairs,
        t_param  TYPE if_web_http_request=>name_value_pairs,
      END OF client.

    CLASS-METHODS main_index_html
      RETURNING
        VALUE(r_result) TYPE string.

    CLASS-METHODS main_roundtrip
      RETURNING
        VALUE(rv_resp) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_HTTP_HANDLER IMPLEMENTATION.


  METHOD main_index_html.


    DATA(lv_url) = client-t_header[ name = '~path' ]-value.
    TRY.
        DATA(lv_app) = client-t_param[ name = 'app' ]-value.
        lv_url &&= `?app=` && lv_app.
      CATCH cx_sy_itab_line_not_found.
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


*    r_result &&= `<style>` && |\n|  &&
*                 `#customers {` && |\n|  &&
*                 `  font-family: Arial, Helvetica, sans-serif;` && |\n|  &&
*                 `  border-collapse: collapse;` && |\n|  &&
*                 `  width: 100%;` && |\n|  &&
*                 `}` && |\n|  &&
*                 |\n|  &&
*                 `#customers td, #customers th {` && |\n|  &&
*                 `  border: 1px solid #ddd;` && |\n|  &&
*                 `  padding: 8px;` && |\n|  &&
*                 `}` && |\n|  &&
*                 |\n|  &&
*                 `#customers tr:nth-child(even){background-color: #f2f2f2;}` && |\n|  &&
*                 |\n|  &&
*                 `#customers tr:hover {background-color: #ddd;}` && |\n|  &&
*                 |\n|  &&
*                 `#customers th {` && |\n|  &&
*                 `  padding-top: 12px;` && |\n|  &&
*                 `  padding-bottom: 12px;` && |\n|  &&
*                 `  text-align: left;` && |\n|  &&
*                 `  background-color: #04AA6D;` && |\n|  &&
*                 `  color: white;` && |\n|  &&
*                 `}` && |\n|  &&
*                 `</style>`     .


     r_result &&=          `  </head><body class="sapUiBody">  <div id="content"></div></body></html>` && |\n|  &&
               `    <script>` && |\n|  &&
               `        sap.ui.getCore().attachInit(function () {` && |\n|  &&
               `            "use strict";` && |\n|  &&
               `            sap.ui.define([` && |\n|  &&
               `                "sap/ui/core/mvc/Controller",` && |\n|  &&
               `                "sap/ui/model/odata/v2/ODataModel",` && |\n|  &&
               `                "sap/ui/model/json/JSONModel", ` && |\n|  &&
               `                "sap/m/MessageBox"     ` && |\n|  &&
               `            ], function (Controller, ODataModel, JSONModel, MessageBox) {` && |\n|  &&
               `                "use strict";` && |\n|  &&
               `                return Controller.extend("MyController", {` && |\n|  &&
               `                    onEventBackend: function (oEvent) {` && |\n|  &&
               `                        this.oBody = this.oView.getModel().oData.oUpdate;` && |\n|  &&
               `                        this.oBody.oEvent = oEvent;` && |\n|  &&
               `                   if ( this.oView.getModel().oData.debug ) {` && |\n|  &&
               `                       console.log(this.oBody);` && |\n|  &&
                  `                            } ` && |\n|  &&
               `                        this.Roundtrip();` && |\n|  &&
               `                    },` && |\n|  &&
               `                    Roundtrip: function () {` && |\n|  &&
               `                        sap.ui.core.BusyIndicator.show();` && |\n|  &&
               `                        this.oView.destroy();` && |\n|  &&
               `                        var xhr = new XMLHttpRequest();` && |\n|  &&
               `              //          var url = window.location.pathname + window.location.search;` && |\n|  &&
               `                        var url = '` && lv_url && `'; // + window.location.search;` && |\n|  &&
               `                        xhr.open("POST", url, true);` && |\n|  &&
               `                        xhr.onload = function (that) {` && |\n|  &&
               `                        if ( that.target.status == 500 ) {` && |\n|  &&
               `                            document.write( that.target.response ); ` && |\n|  &&
               `                            return; ` && |\n|  &&
                `                        }` && |\n|  &&
               `                            var oResponse = JSON.parse(that.target.response);` && |\n|  &&
               `                            if ( oResponse.oViewModel.debug ) {` && |\n|  &&
               `                            console.log(oResponse);` && |\n|  &&
               `                            console.log(oResponse.vView);` && |\n|  &&
               `                            } ` && |\n|  &&

                       `          if ( oResponse.oAfter ){ ` && |\n|  &&
                        `               oResponse.oAfter.forEach( item => sap.m[ item[0] ][ item[1] ]( item[2]) );  ` && |\n|  &&
                          `            }   ` && |\n|  &&
                       `       var oModel = new JSONModel(oResponse.oViewModel);` && |\n|  &&
               `                            var oView = new sap.ui.core.mvc.XMLView.create({` && |\n|  &&
               `                                viewContent: oResponse.vView,` && |\n|  &&
               `                                definition: oResponse.vView,` && |\n|  &&
               `                                preprocessors: {` && |\n|  &&
               `                                    xml: {` && |\n|  &&
               `                                        models: { meta: oModel }` && |\n|  &&
               `                                    }` && |\n|  &&
               `                                },` && |\n|  &&
               `                            }).then(oView => {` && |\n|  &&
               `                                oView.setModel(oModel);` && |\n|  &&
               `                                oView.placeAt("content");` && |\n|  &&
               `                                sap.ui.core.BusyIndicator.hide();` && |\n|  &&
               `                            });` && |\n|  &&
               `                        }.bind(this);` && |\n|  &&
               `                        xhr.send(JSON.stringify(this.oBody));` && |\n|  &&
               `                    },` && |\n|  &&
               `                });` && |\n|  &&
               `            });` && |\n|  &&
               `                var oView = sap.ui.xmlview({ viewContent: "<mvc:View controllerName='MyController' xmlns:mvc='sap.ui.core.mvc' />" });` && |\n|  &&
               `                oView.getController().Roundtrip();` && |\n|  &&
               `        });` && |\n|  &&
               `    </script>` && |\n|  &&
               |\n|  &&
               `</html>`.

  ENDMETHOD.


  METHOD main_roundtrip.
    TRY.

        DATA(lo_runtime) = NEW z2ui5_lcl_runtime(  ).
        lo_runtime->execute_init(  ).

        DO.

          TRY.
              ROLLBACK WORK.
              CAST z2ui5_if_app( lo_runtime->ms_db-o_app )->on_event( NEW z2ui5_lcl_app_client( lo_runtime )  ) .
              ROLLBACK WORK.

            CATCH cx_root INTO DATA(cx).
              lo_runtime = lo_runtime->factory_new_error( kind = 'ON_EVENT' ix = cx ).
              CONTINUE.
          ENDTRY.

          IF lo_runtime->ms_leave_to_app IS not INITIAL.
            lo_runtime->db_save( ).
            data(lo_runtime_new) = lo_runtime->factory_new( cast #( lo_runtime->ms_leave_to_app-o_app ) ).
            lo_runtime_new->ms_db-id_prev_app = lo_runtime->ms_db-id.
            lo_runtime_new->ms_db-screen = lo_runtime->ms_leave_to_app-screen.
            lo_runtime = lo_runtime_new.
            CONTINUE.
          ENDIF.

          TRY.
              lo_runtime->mo_ui5_model = z2ui5_cl_hlp_tree_json=>factory( ).
              lo_runtime->mo_view_model = lo_runtime->mo_ui5_model->add_attribute_object( 'oViewModel' ).

              ROLLBACK WORK.
              CAST z2ui5_if_app( lo_runtime->ms_db-o_app )->set_view( NEW z2ui5_lcl_app_view( lo_runtime ) ).
              ROLLBACK WORK.

            CATCH cx_root INTO cx.
              lo_runtime = lo_runtime->factory_new_error( kind = 'ON_SCREEN' ix = cx ).
              CONTINUE.
          ENDTRY.

          EXIT.
        ENDDO.

        rv_resp = lo_runtime->execute_finish( ).

      CATCH cx_uuid_error INTO cx.
        rv_resp = cx->get_text( ).
    ENDTRY.


  ENDMETHOD.
ENDCLASS.
