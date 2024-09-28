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

ENDCLASS.
