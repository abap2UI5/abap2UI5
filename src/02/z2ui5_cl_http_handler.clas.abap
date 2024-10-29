CLASS z2ui5_cl_http_handler DEFINITION
  PUBLIC
  CREATE PROTECTED.

  PUBLIC SECTION.
    CLASS-METHODS run
      IMPORTING
        server TYPE REF TO object                    OPTIONAL
        req    TYPE REF TO object                    OPTIONAL
        res    TYPE REF TO object                    OPTIONAL
        config TYPE z2ui5_if_types=>ty_s_http_config OPTIONAL
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
        is_req        TYPE z2ui5_if_core_types=>ty_s_http_req
      RETURNING
        VALUE(result) TYPE z2ui5_if_core_types=>ty_s_http_res.

    CLASS-METHODS _http_get
      IMPORTING
        VALUE(is_config) TYPE  z2ui5_if_types=>ty_s_http_config
      RETURNING
        VALUE(result)    TYPE string.

    METHODS main
      IMPORTING
        s_config TYPE z2ui5_if_types=>ty_s_http_config OPTIONAL.

    CLASS-METHODS _main
      IMPORTING
        is_config     TYPE  z2ui5_if_types=>ty_s_http_config
        is_req        TYPE z2ui5_if_core_types=>ty_s_http_req
      RETURNING
        VALUE(result) TYPE z2ui5_if_core_types=>ty_s_http_res.

    CLASS-METHODS get_request
      IMPORTING
        server        TYPE REF TO object OPTIONAL
        req           TYPE REF TO object OPTIONAL
        res           TYPE REF TO object OPTIONAL
          PREFERRED PARAMETER server
      RETURNING
        VALUE(result) TYPE z2ui5_if_core_types=>ty_s_http_req.

    CLASS-METHODS get_response
      IMPORTING
        server TYPE REF TO object OPTIONAL
        req    TYPE REF TO object OPTIONAL
        res    TYPE REF TO object OPTIONAL
        is_res TYPE z2ui5_if_core_types=>ty_s_http_res.

  PROTECTED SECTION.
    CLASS-DATA so_sticky_handler TYPE REF TO z2ui5_cl_core_handler.

    DATA mo_server TYPE REF TO z2ui5_cl_abap_api_http.

    DATA ms_req    TYPE z2ui5_if_core_types=>ty_s_http_req.
    DATA ms_res    TYPE z2ui5_if_core_types=>ty_s_http_res.
    DATA ms_config TYPE z2ui5_if_types=>ty_s_http_config.

    METHODS set_request.
    METHODS set_response.

  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_cl_http_handler IMPLEMENTATION.

  METHOD main.

    ms_config = s_config.

    set_request( ).

    CASE ms_req-method.
      WHEN `HEAD`.
        mo_server->set_session_stateful( 0 ).
        RETURN.
      WHEN OTHERS.
        ms_res = _main( is_req    = ms_req
                        is_config = ms_config ).
    ENDCASE.

    set_response( ).

  ENDMETHOD.

  METHOD factory.

    result = NEW #( ).

    IF server IS BOUND.
      result->mo_server = z2ui5_cl_abap_api_http=>factory( server ).
    ELSEIF req IS BOUND AND res IS BOUND.
      result = factory_cloud( req = req
                              res = res ).
    ELSE.
      ASSERT 1 = `EMPTY_HTTP_HANDLER_CALL_ERROR`.
    ENDIF.

  ENDMETHOD.

  METHOD factory_cloud.

    result = NEW #( ).
    result->mo_server = z2ui5_cl_abap_api_http=>factory_cloud( req = req
                                                               res = res ).

  ENDMETHOD.

  METHOD _http_get.

    IF is_config-title IS INITIAL.
      is_config-title = `abap2UI5`.
    ENDIF.

    IF is_config-theme IS INITIAL.
      is_config-theme = `sap_horizon`.
    ENDIF.

    IF is_config-src IS INITIAL.
      is_config-src = `https://sdk.openui5.org/resources/sap-ui-cachebuster/sap-ui-core.js`.
*      ms_req_config-src     = `https://sdk.openui5.org/1.71.67/resources/sap-ui-core.js`.
*      ms_req_config-src     = `https://sdk.openui5.org/nightly/2/resources/sap-ui-core.js`.
    ENDIF.

    IF is_config-content_security_policy IS INITIAL.
      is_config-content_security_policy = |<meta http-equiv="Content-Security-Policy" content="default-src 'self' 'unsafe-inline' 'unsafe-eval' data: | &&
     |ui5.sap.com *.ui5.sap.com sapui5.hana.ondemand.com *.sapui5.hana.ondemand.com openui5.hana.ondemand.com *.openui5.hana.ondemand.com | &&
     |sdk.openui5.org *.sdk.openui5.org cdn.jsdelivr.net *.cdn.jsdelivr.net cdnjs.cloudflare.com *.cdnjs.cloudflare.com schemas *.schemas"/>|.
    ENDIF.

    IF is_config-styles_css IS INITIAL.
      DATA(lv_style_css) = z2ui5_cl_app_style_css=>get( ).
    ELSE.
      lv_style_css = is_config-styles_css.
    ENDIF.

    result = |<!DOCTYPE html>| && |\n| &&
               |<html lang="en">| && |\n| &&
               |<head>| && |\n| &&
                  |{ is_config-content_security_policy }\n| &&
               |    <meta charset="UTF-8">| && |\n| &&
               |    <meta name="viewport" content="width=device-width, initial-scale=1.0">| && |\n| &&
               |    <meta http-equiv="X-UA-Compatible" content="IE=edge">| && |\n| &&
                | <title> { is_config-title }</title> \n| &&
                | <style>        html, body, body > div, #container, #container-uiarea \{\n| &
                |            height: 100%;\n| &
                |        \}</style> \n| &&
                |<script>| && |\n| &&
             |  function onInitComponent()\{| && |\n| &&
             |    sap.ui.require.preload(\{| && |\n| &&
             |      "z2ui5/manifest.json": '{ z2ui5_cl_app_manifest_json=>get( ) }',| && |\n| &&
             |      "z2ui5/Component.js": function()\{{ z2ui5_cl_app_component_js=>get( ) }{ is_config-custom_js }\},| && |\n| &&
             |      "z2ui5/css/style.css": '{ lv_style_css }',| && |\n| &&
             |      "z2ui5/model/models.js": function()\{{  z2ui5_cl_app_models_js=>get( ) }\},| && |\n| &&
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
                 |data-sap-ui-theme="{ is_config-theme  }" src=" { is_config-src }"   |.

    LOOP AT is_config-t_add_config REFERENCE INTO DATA(lr_config).
      result = |{ result } { lr_config->n }='{ lr_config->v }'|.
    ENDLOOP.

    result = result &&
        | ></script></head>| && |\n| &&
        |<body class="sapUiBody sapUiSizeCompact" id="content">| && |\n| &&
        |    <div data-sap-ui-component data-name="z2ui5" data-id="container" data-settings='\{"id" : "z2ui5"\}' data-handle-validation="true"></div>| && |\n| &&
        | </body></html>|.

  ENDMETHOD.

  METHOD run.

    DATA(lo_handler) = factory( server = server
                                req    = req
                                res    = res
         ).

    lo_handler->main( config ).

  ENDMETHOD.

  METHOD set_request.

    ms_req-body   = mo_server->get_cdata( ).
    ms_req-method = mo_server->get_method( ).

  ENDMETHOD.

  METHOD set_response.

    mo_server->set_cdata( ms_res-body ).
    mo_server->set_header_field( n = `cache-control`
                                 v = `no-cache` ).
    mo_server->set_status( code   = 200
                           reason = `success` ).

    " transform cookie to header based contextid handling
    IF ms_res-s_stateful-switched = abap_true.
      mo_server->set_session_stateful( ms_res-s_stateful-active  ).
      IF mo_server->get_header_field( 'sap-contextid-accept' ) = 'header'.
        DATA(lv_contextid) = mo_server->get_response_cookie( 'sap-contextid' ).
        IF lv_contextid IS NOT INITIAL.
          mo_server->delete_response_cookie( 'sap-contextid' ).
          mo_server->set_header_field( n = 'sap-contextid'
                                       v = lv_contextid ).
        ENDIF.
      ENDIF.
    ELSE.
      lv_contextid = mo_server->get_header_field( 'sap-contextid' ).
      IF lv_contextid IS NOT INITIAL.
        mo_server->set_header_field( n = 'sap-contextid'
                                     v = lv_contextid ).
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD _http_post.

    IF so_sticky_handler IS NOT BOUND.
      DATA(lo_post) = NEW z2ui5_cl_core_handler( is_req-body ).
    ELSE.
      lo_post = so_sticky_handler.
      lo_post->mv_request_json = is_req-body.
    ENDIF.

    result = lo_post->main( ).

    TRY.
        IF lo_post IS BOUND.
          DATA(li_app) = CAST z2ui5_if_app( lo_post->mo_action->mo_app->mo_app ).
          IF li_app->check_sticky = abap_true.
            so_sticky_handler = lo_post.
          ELSE.
            CLEAR so_sticky_handler.
          ENDIF.
        ENDIF.
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

  METHOD _main.

    CASE is_req-method.
      WHEN `GET`.
        result-body = _http_get( is_config ).
      WHEN `POST`.
        result = _http_post( is_req ).
    ENDCASE.

  ENDMETHOD.

  METHOD get_request.

    DATA(lo_handler) = factory( server = server
                                req    = req
                                res    = res
     ).

    result-body   = lo_handler->mo_server->get_cdata( ).
    result-method = lo_handler->mo_server->get_method( ).

  ENDMETHOD.

  METHOD get_response.

    DATA(lo_handler) = factory( server = server
                                req    = req
                                res    = res
     ).

    lo_handler->mo_server->set_cdata( is_res-body ).
    lo_handler->mo_server->set_header_field( n = `cache-control`
                                             v = `no-cache` ).
    lo_handler->mo_server->set_status( code   = 200
                                       reason = `success` ).

    " transform cookie to header based contextid handling
    IF is_res-s_stateful-switched = abap_true.
      lo_handler->mo_server->set_session_stateful( is_res-s_stateful-active  ).
      IF lo_handler->mo_server->get_header_field( 'sap-contextid-accept' ) = 'header'.
        DATA(lv_contextid) = lo_handler->mo_server->get_response_cookie( 'sap-contextid' ).
        IF lv_contextid IS NOT INITIAL.
          lo_handler->mo_server->delete_response_cookie( 'sap-contextid' ).
          lo_handler->mo_server->set_header_field( n = 'sap-contextid'
                                                   v = lv_contextid ).
        ENDIF.
      ENDIF.
    ELSE.
      lv_contextid = lo_handler->mo_server->get_header_field( 'sap-contextid' ).
      IF lv_contextid IS NOT INITIAL.
        lo_handler->mo_server->set_header_field( n = 'sap-contextid'
                                                 v = lv_contextid ).
      ENDIF.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
