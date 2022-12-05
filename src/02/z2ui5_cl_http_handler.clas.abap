CLASS z2ui5_cl_http_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

      types:
      BEGIN OF ty_s_client,
        o_body   TYPE REF TO z2ui5_cl_hlp_tree_json,
        t_header TYPE if_web_http_request=>name_value_pairs,
        t_param  TYPE if_web_http_request=>name_value_pairs,
      END OF ty_s_client.

      CLASS-METHODS main_index_html
      RETURNING
        VALUE(r_result) TYPE string.

    CLASS-METHODS main_roundtrip
      IMPORTING
        client        type ty_S_client
      RETURNING
        VALUE(rv_resp) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_http_handler IMPLEMENTATION.

METHOD main_roundtrip.

    DATA(lo_server) = NEW lcl_2ui5_server(  ).
    lo_server->ms_client = client.
    lo_server->execute_init(  ).

    DO.

      TRY.
          ROLLBACK WORK.
          cast zif_2ui5_app( lo_server->ms_db-o_app )->on_event( NEW lcl_2ui5_client( lo_server )  ) .
          ROLLBACK WORK.

        CATCH cx_root INTO DATA(cx).
          lo_server = lo_server->init_new_server(
            zzcl_app_system=>factory_error(  server = lo_server error = cx app = cast #( lo_server->ms_db-o_app ) kind = 'ON_EVENT' ) ).

          CONTINUE.
      ENDTRY.

      IF lo_server->mo_leave_to_app IS BOUND.
        lo_server = lo_server->init_new_server( lo_server->mo_leave_to_app ).
        CONTINUE.
      ENDIF.

      TRY.

          lo_server->mo_ui5_model = z2ui5_cl_hlp_tree_json=>factory( ).
          lo_server->mo_view_model = lo_server->mo_ui5_model->add_attribute_object( 'oViewModel' ).

          ROLLBACK WORK.
          cast zif_2ui5_app( lo_server->ms_db-O_app )->set_view( NEW lcl_2ui5_view( lo_server ) ).
          ROLLBACK WORK.

        CATCH cx_root INTO cx.
          lo_server = lo_server->init_new_server(
            zzcl_app_system=>factory_error( server = lo_server error = cx app = cast #( lo_server->ms_db-o_app ) kind = 'SET_SCREEN' )
             ).
          CONTINUE.
      ENDTRY.

      EXIT.
    ENDDO.

    rv_resp = lo_server->execute_finish( ).

  ENDMETHOD.

  METHOD main_index_html.

    r_result = `<html>` && |\n|  &&
               `<head>` && |\n|  &&
               `    <meta charset="utf-8">` && |\n|  &&
               `    <title>` && zif_2ui5_config=>s_config-browser_title && `</title>` && |\n|  &&
               `    <script src="` && zif_2ui5_config=>s_config-repository && `" ` &&
               ` id="sap-ui-bootstrap" data-sap-ui-theme="` && zif_2ui5_config=>s_config-theme && `"` && |\n|  &&
               `        data-sap-ui-libs="sap.m" data-sap-ui-bindingSyntax="complex" data-sap-ui-compatVersion="edge"` && |\n|  &&
               `        data-sap-ui-preload="async">` && |\n|  &&
               `     </script>` && |\n|  &&
               `  </head><body class="sapUiBody">  <div id="content"></div></body></html>` && |\n|  &&
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
               `                       console.log(oEvent);` && |\n|  &&
                  `                            } ` && |\n|  &&
               `                        this.Roundtrip();` && |\n|  &&
               `                    },` && |\n|  &&
               `                    Roundtrip: function () {` && |\n|  &&
               `                        sap.ui.core.BusyIndicator.show();` && |\n|  &&
               `                        this.oView.destroy();` && |\n|  &&
               `                        var xhr = new XMLHttpRequest();` && |\n|  &&
               `                        var url = window.location.pathname + window.location.search;` && |\n|  &&
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

ENDCLASS.
