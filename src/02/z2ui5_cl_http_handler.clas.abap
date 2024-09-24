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

    METHODS get_js_cc_startup
      RETURNING
        VALUE(result) TYPE string.

    METHODS set_config
      IMPORTING
        is_custom_config TYPE z2ui5_if_types=>ty_s_http_config.

    METHODS http_get
      IMPORTING
        is_custom_config TYPE z2ui5_if_types=>ty_s_http_config.

    METHODS http_post
       EXPORTING
        attributes    TYPE z2ui5_if_types=>ty_s_http_handler_attributes.

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

    ms_config-custom_js = ms_config-custom_js && get_js_cc_startup( ).

  ENDMETHOD.


  METHOD get_js_cc_startup.

    result = ` ` &&
        z2ui5_cl_cc_timer=>get_js( ) &&
        z2ui5_cl_cc_focus=>get_js( ) &&
        z2ui5_cl_cc_title=>get_js( ) &&
        z2ui5_cl_cc_lp_title=>get_js( ) &&
        z2ui5_cl_cc_history=>get_js( ) &&
        z2ui5_cl_cc_scrolling=>get_js( ) &&
        z2ui5_cl_cc_info=>get_js( ) &&
        z2ui5_cl_cc_geoloc=>get_js( ) &&
        z2ui5_cl_cc_file_upl=>get_js( ) &&
        z2ui5_cl_cc_multiinput=>get_js( ) &&
        z2ui5_cl_cc_uitable=>get_js( ) &&
        z2ui5_cl_cc_util=>get_js( ) &&
        z2ui5_cl_cc_favicon=>get_js( ) &&
        z2ui5_cl_cc_dirty=>get_js( ) &&
       `  `.

  ENDMETHOD.


  METHOD main.

    ms_req-body = mo_server->get_cdata( ).
    ms_req-method = mo_server->get_method( ).

    CASE ms_req-method.
      WHEN `GET`.
        http_get( s_config ).
      WHEN `POST`.
        http_post(
            IMPORTING
            attributes = data(attributes)
        ).
      WHEN `HEAD`.
        mo_server->set_session_stateful( 0 ).
        RETURN.
    ENDCASE.

    mo_server->set_cdata( ms_res-body ).
    mo_server->set_header_field( n = `cache-control` v = `no-cache` ).
    mo_server->set_status( code = 200 reason = `success`).

    session_handling( attributes ).

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

    DATA(lo_app) = NEW z2ui5_cl_core_ui5_app( ).
    ms_res-body = lo_app->index_html( ms_config ).

    NEW z2ui5_cl_core_draft_srv( )->cleanup( ).

  ENDMETHOD.


  METHOD http_post.

    IF so_sticky_handler IS NOT BOUND.
      DATA(lo_post) = NEW z2ui5_cl_core_http_post( ms_req-body  ).
    ELSE.
      lo_post = so_sticky_handler.
      lo_post->mv_request_json = ms_req-body.
    ENDIF.

*    DATA attributes    TYPE z2ui5_if_types=>ty_s_http_handler_attributes.
    ms_res-body = lo_post->main(
      IMPORTING
        attributes = attributes ).

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

    IF attributes-stateful-switched = abap_true.

      mo_server->set_session_stateful( attributes-stateful-active  ).

      IF mo_server->get_header_field( 'sap-contextid-accept' ) = 'header'.
        DATA(lv_contextid) = mo_server->get_cookie( 'sap-contextid' ).
        IF lv_contextid IS NOT INITIAL.
          mo_server->delete_cookie( 'sap-contextid' ).
          mo_server->set_header_field( n = 'sap-contextid' v = lv_contextid ).
        ENDIF.
      ENDIF.

    ELSE.
      lv_contextid = mo_server->get_header_field( 'sap-contextid' ).
      IF lv_contextid IS NOT INITIAL.
        mo_server->set_header_field( n = 'sap-contextid' v = lv_contextid ).
      ENDIF.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
