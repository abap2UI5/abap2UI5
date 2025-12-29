CLASS z2ui5_cl_http_handler DEFINITION
  PUBLIC
  CREATE PROTECTED.

  PUBLIC SECTION.
    CLASS-METHODS run
      IMPORTING
        server TYPE REF TO object                    OPTIONAL
        req    TYPE REF TO object                    OPTIONAL
        res    TYPE REF TO object                    OPTIONAL
          PREFERRED PARAMETER server.

    CLASS-METHODS factory_cloud
      IMPORTING
        req           TYPE REF TO object
        res           TYPE REF TO object
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_http_handler.

    CLASS-METHODS factory
      IMPORTING
        server        TYPE REF TO object OPTIONAL
        req           TYPE REF TO object OPTIONAL
        res           TYPE REF TO object OPTIONAL
          PREFERRED PARAMETER server
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_http_handler.

    CLASS-METHODS _http_post
      IMPORTING
        is_req        TYPE z2ui5_cl_util_http=>ty_s_http_req
      RETURNING
        VALUE(result) TYPE z2ui5_if_core_types=>ty_s_http_res.

    CLASS-METHODS _http_get
      RETURNING
        VALUE(result) TYPE z2ui5_if_core_types=>ty_s_http_res.

    METHODS main.

    CLASS-METHODS _main
      IMPORTING
        is_req        TYPE z2ui5_cl_util_http=>ty_s_http_req
      RETURNING
        VALUE(result) TYPE z2ui5_if_core_types=>ty_s_http_res.

    CLASS-METHODS get_request
      IMPORTING
        server        TYPE REF TO object OPTIONAL
        req           TYPE REF TO object OPTIONAL
        res           TYPE REF TO object OPTIONAL
          PREFERRED PARAMETER server
      RETURNING
        VALUE(result) TYPE z2ui5_cl_util_http=>ty_s_http_req.

  PROTECTED SECTION.
    CLASS-DATA so_sticky_handler TYPE REF TO z2ui5_cl_core_handler.

    DATA mo_server TYPE REF TO z2ui5_cl_util_http.
    DATA ms_req    TYPE z2ui5_cl_util_http=>ty_s_http_req.
    DATA ms_res    TYPE z2ui5_if_core_types=>ty_s_http_res.

    METHODS set_response.

  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_cl_http_handler IMPLEMENTATION.

  METHOD main.

    ms_req = mo_server->get_req_info( ).

    CASE ms_req-method.
      WHEN `HEAD`.
        mo_server->set_session_stateful( 0 ).
        RETURN.
      WHEN OTHERS.
        ms_res = _main( ms_req ).
    ENDCASE.

    set_response( ).

  ENDMETHOD.

  METHOD factory.

    CREATE OBJECT result.

    IF server IS BOUND.
      result->mo_server = z2ui5_cl_util_http=>factory( server ).
    ELSEIF req IS BOUND AND res IS BOUND.
      result = factory_cloud( req = req
                              res = res ).
    ELSE.
      ASSERT 1 = `EMPTY_HTTP_HANDLER_CALL_ERROR`.
    ENDIF.

  ENDMETHOD.

  METHOD factory_cloud.

    CREATE OBJECT result.
    result->mo_server = z2ui5_cl_util_http=>factory_cloud( req = req
                                                           res = res ).

  ENDMETHOD.

  METHOD _http_get.

    DATA temp1 TYPE z2ui5_if_types=>ty_s_http_config.
    DATA ls_config LIKE temp1.
      DATA lv_style_css TYPE string.
    DATA temp2 LIKE LINE OF ls_config-t_add_config.
    DATA lr_config LIKE REF TO temp2.
    CLEAR temp1.
    
    ls_config = temp1.
    z2ui5_cl_exit=>get_instance( )->set_config_http_get( CHANGING cs_config = ls_config ).

    IF ls_config-styles_css IS INITIAL.
      
      lv_style_css = z2ui5_cl_app_style_css=>get( ).
    ELSE.
      lv_style_css = ls_config-styles_css.
    ENDIF.

    result-body = |<!DOCTYPE html>| && |\n| &&
               |<html lang="en">| && |\n| &&
               |<head>| && |\n| &&
                  |{ ls_config-content_security_policy }\n| &&
               |    <meta charset="UTF-8">| && |\n| &&
               |    <meta name="viewport" content="width=device-width, initial-scale=1.0">| && |\n| &&
               |    <meta http-equiv="X-UA-Compatible" content="IE=edge">| && |\n| &&
                | <title> { ls_config-title }</title> \n| &&
                | <style>        html, body, body > div, #container, #container-uiarea \{\n| &
                |            height: 100%;\n| &
                |        \}</style> \n| &&
                |<script>| && |\n| &&
             |  function onInitComponent()\{| && |\n| &&
             |    sap.ui.require.preload(\{| && |\n| &&
             |      "z2ui5/css/style.css": '{ lv_style_css }',| && |\n| &&
             |      "z2ui5/manifest.json": '{ z2ui5_cl_app_manifest_json=>get( ) }',| && |\n| &&
             |      "z2ui5/Component.js": function()\{{ z2ui5_cl_app_component_js=>get( ) }{ ls_config-custom_js }\},| && |\n| &&
             |      "z2ui5/model/models.js": function()\{{ z2ui5_cl_app_models_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/view/App.view.xml": '{ z2ui5_cl_app_app_xml=>get( ) }',| && |\n| &&
             |      "z2ui5/controller/App.controller.js": function()\{{ z2ui5_cl_app_app_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/view/View1.view.xml": '{ z2ui5_cl_app_view1_xml=>get( ) }',| && |\n| &&
             |      "z2ui5/controller/View1.controller.js": function()\{{ z2ui5_cl_app_view1_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/Server.js": function()\{{ z2ui5_cl_app_server_js=>get( ) }\},| && |\n| &&
             |      "z2ui5/cc/DebugTool.fragment.xml": '{ z2ui5_cl_app_debugtool_xml=>get( ) }',| && |\n| &&
             |      "z2ui5/cc/DebugTool.js": function()\{{ z2ui5_cl_app_debugtool_js=>get( ) }\},| && |\n| &&
             |    \});| && |\n| &&
             |    sap.ui.require(["sap/ui/core/ComponentSupport"], function(ComponentSupport)\{| && |\n| &&
             |     window.z2ui5 = \{ checkLocal : true \}; ComponentSupport.run();| && |\n| &&
             |    \});| && |\n| &&
             |  \}| && |\n| &&
             |</script>| && |\n| &&
                |<script id="sap-ui-bootstrap" data-sap-ui-resourceroots='\{ "z2ui5": "./" \}' data-sap-ui-oninit="onInitComponent" | && |\n| &&
                 |data-sap-ui-compatVersion="edge" data-sap-ui-async="true" data-sap-ui-frameOptions="trusted" data-sap-ui-bindingSyntax="complex"| && |\n| &&
                 |data-sap-ui-theme="{ ls_config-theme  }" src=" { ls_config-src }"   |.

    
    
    LOOP AT ls_config-t_add_config REFERENCE INTO lr_config.
      result-body = |{ result-body } { lr_config->n }='{ lr_config->v }'|.
    ENDLOOP.

    result-body          = result-body &&
                 | ></script></head>| && |\n| &&
                 |<body class="sapUiBody sapUiSizeCompact" id="content">| && |\n| &&
                 |    <div data-sap-ui-component data-name="z2ui5" data-id="container" data-settings='\{"id" : "z2ui5"\}' data-handle-validation="true"></div>| && |\n| &&
                 | </body></html>|.

    result-status_code   = 200.
    result-status_reason = `success`.

  ENDMETHOD.

  METHOD run.

    DATA lo_handler TYPE REF TO z2ui5_cl_http_handler.
    lo_handler = factory( server = server
                                req    = req
                                res    = res ).

    lo_handler->main( ).

  ENDMETHOD.

  METHOD set_response.
    DATA temp3 TYPE z2ui5_if_types=>ty_s_http_config.
    DATA ls_config LIKE temp3.
    DATA ls_header LIKE LINE OF ls_config-t_security_header.
        DATA lv_contextid TYPE string.

    mo_server->set_cdata( ms_res-body ).

    
    CLEAR temp3.
    
    ls_config = temp3.
    z2ui5_cl_exit=>get_instance( )->set_config_http_get( CHANGING cs_config = ls_config ).

    
    LOOP AT ls_config-t_security_header INTO ls_header.
      mo_server->set_header_field( n = ls_header-n
                                   v = ls_header-v ).
    ENDLOOP.

    mo_server->set_status( code   = ms_res-status_code
                           reason = ms_res-status_reason ).

    " transform cookie to header based contextid handling
    IF ms_res-s_stateful-switched = abap_true.
      mo_server->set_session_stateful( ms_res-s_stateful-active ).
      IF mo_server->get_header_field( `sap-contextid-accept` ) = `header`.
        
        lv_contextid = mo_server->get_response_cookie( `sap-contextid` ).
        IF lv_contextid IS NOT INITIAL.
          mo_server->delete_response_cookie( `sap-contextid` ).
          mo_server->set_header_field( n = `sap-contextid`
                                       v = lv_contextid ).
        ENDIF.
      ENDIF.
    ELSE.
      lv_contextid = mo_server->get_header_field( `sap-contextid` ).
      IF lv_contextid IS NOT INITIAL.
        mo_server->set_header_field( n = `sap-contextid`
                                     v = lv_contextid ).
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD _http_post.
          DATA lo_post TYPE REF TO z2ui5_cl_core_handler.
              DATA temp4 TYPE REF TO z2ui5_if_app.
              DATA li_app LIKE temp4.
        DATA x TYPE REF TO cx_root.
    TRY.

        IF so_sticky_handler IS NOT BOUND.
          
          CREATE OBJECT lo_post TYPE z2ui5_cl_core_handler EXPORTING VAL = is_req-body.
        ELSE.
          lo_post = so_sticky_handler.
          lo_post->mv_request_json = is_req-body.
        ENDIF.

        result = lo_post->main( ).

        TRY.
            IF lo_post IS BOUND.
              
              temp4 ?= lo_post->mo_action->mo_app->mo_app.
              
              li_app = temp4.
              IF li_app->check_sticky = abap_true.
                so_sticky_handler = lo_post.
              ELSE.
                CLEAR so_sticky_handler.
              ENDIF.
            ENDIF.
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.

        
      CATCH cx_root INTO x.

        CLEAR result.
        result-body = |abap2UI5 Error:{ x->get_text( ) }|.
        result-status_code = 500.
        result-status_reason = `error`.
    ENDTRY.
  ENDMETHOD.

  METHOD _main.

    z2ui5_cl_exit=>init_context( is_req ).

    CASE is_req-method.
      WHEN `GET`.
        result = _http_get( ).
      WHEN `POST`.
        result = _http_post( is_req ).
    ENDCASE.

  ENDMETHOD.

  METHOD get_request.

    DATA lo_handler TYPE REF TO z2ui5_cl_http_handler.
    lo_handler = factory( server = server
                                req    = req
                                res    = res ).

    result-body   = lo_handler->mo_server->get_cdata( ).
    result-method = lo_handler->mo_server->get_method( ).

  ENDMETHOD.

ENDCLASS.
