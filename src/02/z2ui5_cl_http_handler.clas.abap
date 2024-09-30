CLASS z2ui5_cl_http_handler DEFINITION
  PUBLIC
  CREATE PROTECTED.

  PUBLIC SECTION.

    CLASS-METHODS factory_cloud
      IMPORTING
        req           TYPE REF TO object
        res           TYPE REF TO object
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_http_handler.

    CLASS-METHODS factory
      IMPORTING
        server        TYPE REF TO object
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_http_handler.

    METHODS main
      IMPORTING
        s_config TYPE z2ui5_if_types=>ty_s_http_config OPTIONAL.

  PROTECTED SECTION.

    CLASS-DATA so_sticky_handler TYPE REF TO z2ui5_cl_core_http_post.
    DATA mo_server TYPE REF TO z2ui5_cl_abap_api_http.
    DATA ms_session_attributes TYPE z2ui5_if_types=>ty_s_http_handler_attributes.

    TYPES:
      BEGIN OF ty_s_http_req,
        method TYPE string,
        body   TYPE string,
      END OF ty_s_http_req.

    TYPES:
      BEGIN OF ty_s_http_res,
        body          TYPE string,
        status_code   TYPE i,
        status_reason TYPE string,
        t_header      TYPE z2ui5_if_types=>ty_t_name_value,
      END OF ty_s_http_res.

    DATA ms_req TYPE ty_s_http_req.
    DATA ms_res TYPE ty_s_http_res.
    DATA ms_config TYPE z2ui5_if_types=>ty_s_http_config.

    METHODS set_config
      IMPORTING
        is_custom_config TYPE z2ui5_if_types=>ty_s_http_config.

    METHODS http_get
      IMPORTING
        is_custom_config TYPE z2ui5_if_types=>ty_s_http_config.

    METHODS http_post.

    METHODS session_handling
      IMPORTING
        attributes TYPE z2ui5_if_types=>ty_s_http_handler_attributes.

    METHODS get_index_html
      RETURNING
        VALUE(result) TYPE string
        ##CALLED.

  PRIVATE SECTION.


ENDCLASS.



CLASS z2ui5_cl_http_handler IMPLEMENTATION.


  METHOD set_config.

    ms_config = is_custom_config.

    IF ms_config-title IS INITIAL.
      ms_config-title = `abap2UI5`.
    ENDIF.

    IF ms_config-theme IS INITIAL.
      ms_config-theme = `sap_horizon`.
    ENDIF.

    IF ms_config-src IS INITIAL.
      ms_config-src     = `https://sdk.openui5.org/resources/sap-ui-cachebuster/sap-ui-core.js`.
*      ms_req_config-src     = `https://sdk.openui5.org/1.71.67/resources/sap-ui-core.js`.
*      ms_req_config-src     = `https://sdk.openui5.org/nightly/2/resources/sap-ui-core.js`.
    ENDIF.

    IF ms_config-content_security_policy IS INITIAL.
      ms_config-content_security_policy = `<meta http-equiv="Content-Security-Policy" content="default-src 'self' 'unsafe-inline' 'unsafe-eval' data: ` &&
     `ui5.sap.com *.ui5.sap.com sapui5.hana.ondemand.com *.sapui5.hana.ondemand.com openui5.hana.ondemand.com *.openui5.hana.ondemand.com ` &&
     `sdk.openui5.org *.sdk.openui5.org cdn.jsdelivr.net *.cdn.jsdelivr.net cdnjs.cloudflare.com *.cdnjs.cloudflare.com schemas *.schemas"/>`.
    ENDIF.

  ENDMETHOD.


  METHOD main.

    ms_req-body = mo_server->get_cdata( ).
    ms_req-method = mo_server->get_method( ).

    CASE ms_req-method.
      WHEN `GET`.
        http_get( s_config ).
      WHEN `POST`.
        http_post( ).
      WHEN `HEAD`.
        mo_server->set_session_stateful( 0 ).
        RETURN.
    ENDCASE.

    mo_server->set_cdata( ms_res-body ).
    mo_server->set_header_field( n = `cache-control` v = `no-cache` ).
    mo_server->set_status( code = 200 reason = `success` ).

    session_handling( ms_session_attributes ).

  ENDMETHOD.

  METHOD factory.

    result = NEW #( ).
    result->mo_server = z2ui5_cl_abap_api_http=>factory( server ).

  ENDMETHOD.

  METHOD factory_cloud.

    result = NEW #( ).
    result->mo_server = z2ui5_cl_abap_api_http=>factory_cloud(
        req = req
        res = res ).

  ENDMETHOD.

  METHOD http_get.

    set_config( is_custom_config ).

    ms_res-body = z2ui5_cl_ui5_index_html=>get( ms_config ).
*    ms_res-body = get_index_html(  ).

    NEW z2ui5_cl_core_draft_srv( )->cleanup( ).

  ENDMETHOD.


  METHOD http_post.

    IF so_sticky_handler IS NOT BOUND.
      DATA(lo_post) = NEW z2ui5_cl_core_http_post( ms_req-body  ).
    ELSE.
      lo_post = so_sticky_handler.
      lo_post->mv_request_json = ms_req-body.
    ENDIF.

    ms_res-body = lo_post->main(
      IMPORTING
        attributes = ms_session_attributes ).

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


  METHOD session_handling.

    "transform cookie to header based contextid handling
    IF attributes-stateful-switched = abap_true.
*      server->set_session_stateful( stateful = attributes-stateful-active ).
      mo_server->set_session_stateful( attributes-stateful-active  ).
      IF mo_server->get_header_field( 'sap-contextid-accept' ) = 'header'.
*        server->response->get_cookie(
*          EXPORTING
*            name  = 'sap-contextid'
*          IMPORTING
*            value = DATA(lv_contextid) ).
        DATA(lv_contextid) = mo_server->get_response_cookie( 'sap-contextid' ).
        IF lv_contextid IS NOT INITIAL.
*          server->response->delete_cookie( 'sap-contextid' ).
          mo_server->delete_response_cookie( 'sap-contextid' ).
*          server->response->set_header_field( name = 'sap-contextid' value = lv_contextid ).
          mo_server->set_header_field( n = 'sap-contextid' v = lv_contextid ).
        ENDIF.
      ENDIF.
    ELSE.
*      lv_contextid = server->request->get_header_field( 'sap-contextid' ).
      lv_contextid = mo_server->get_header_field( 'sap-contextid' ).
      IF lv_contextid IS NOT INITIAL.
*        server->response->set_header_field( name = 'sap-contextid' value = lv_contextid ).
        mo_server->set_header_field( n = 'sap-contextid' v = lv_contextid ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD get_index_html.

    IF ms_config-styles_css IS INITIAL.
      DATA(lv_style_css) = z2ui5_cl_ui5_style_css=>get( ).
    ELSE.
      lv_style_css = ms_config-styles_css.
    ENDIF.

    result = `<!DOCTYPE html>` && |\n| &&
               `<html lang="en">` && |\n| &&
               `<head>` && |\n| &&
                  ms_config-content_security_policy && |\n| &&
               `    <meta charset="UTF-8">` && |\n| &&
               `    <meta name="viewport" content="width=device-width, initial-scale=1.0">` && |\n| &&
               `    <meta http-equiv="X-UA-Compatible" content="IE=edge">` && |\n| &&
                | <title> { ms_config-title }</title> \n| &&
                | <style>        html, body, body > div, #container, #container-uiarea \{\n| &
                |            height: 100%;\n| &
                |        \}</style> \n| &&
                `<script>` && |\n| &&
             `  function onInitComponent(){` && |\n| &&
             `    sap.ui.require.preload({` && |\n| &&
             `      "z2ui5/manifest.json": '` && z2ui5_cl_app__manifest=>get( ) && ` ',` && |\n| &&
             `      "z2ui5/Component.js": function(){` &&  z2ui5_cl_app__component_js=>get( ) && ms_config-custom_js && ` },` && |\n| &&
             `      "z2ui5/css/style.css": '` && lv_style_css && `',` && |\n| &&
             `      "z2ui5/model/models.js": function(){` &&  z2ui5_cl_app_mode_models_js=>get( ) && `},` && |\n| &&
             `      "z2ui5/view/App.view.xml": '` && z2ui5_cl_app_view_app_xml=>get( ) && `' ,` && |\n| &&
             `      "z2ui5/controller/App.controller.js": function(){` && z2ui5_cl_app_cont_app_js=>get( ) && `},` && |\n| &&
             `      "z2ui5/view/View1.view.xml": '` && z2ui5_cl_app_view_view1_xml=>get( )  && `' ,` && |\n| &&
             `      "z2ui5/controller/View1.controller.js": function(){` && z2ui5_cl_app_cont_view1_js=>get( ) && `},` && |\n| &&
             `      "z2ui5/cc/Server.js": function(){` && z2ui5_cl_app_cc_server_js=>get( )    && `} ,` && |\n| &&
             `      "z2ui5/cc/DebugTool.fragment.xml": '` && z2ui5_cl_app_cc_debugtool_xml=>get( )   && `' ,` && |\n| &&
             `      "z2ui5/cc/DebugTool.js": function(){` && z2ui5_cl_app_cc_debugtool_js=>get( )  && `},` && |\n| &&
             `    });` && |\n| &&
             `    sap.ui.require(["sap/ui/core/ComponentSupport"], function(ComponentSupport){` && |\n| &&
             `     window.z2ui5 = {}; ComponentSupport.run();` && |\n| &&
             `    });` && |\n| &&
             `  }` && |\n| &&
             `</script>` && |\n| &&
                `<script id="sap-ui-bootstrap" data-sap-ui-resourceroots='{ "z2ui5": "./" }' data-sap-ui-oninit="onInitComponent" ` && |\n| &&
                 `data-sap-ui-compatVersion="edge" data-sap-ui-async="true" data-sap-ui-frameOptions="trusted" data-sap-ui-bindingSyntax="complex"` && |\n| &&
                 `data-sap-ui-theme="` &&  ms_config-theme   &&  `" src=" ` && ms_config-src && `"   `.

    LOOP AT ms_config-t_add_config REFERENCE INTO DATA(lr_config).
      result = result && | { lr_config->n }='{ lr_config->v }'|.
    ENDLOOP.

    result = result &&
        ` ></script></head>` && |\n| &&
        `<body class="sapUiBody sapUiSizeCompact" id="content">` && |\n| &&
        `    <div data-sap-ui-component data-name="z2ui5" data-id="container" data-settings='{"id" : "z2ui5"}' data-handle-validation="true"></div>` && |\n| &&
        ` </body></html>`.

  ENDMETHOD.

ENDCLASS.
