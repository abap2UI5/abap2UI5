CLASS z2ui5_cl_http_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

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

    DATA mo_v1 TYPE REF TO object.
    DATA mo_v2 TYPE REF TO object.

    TYPES:
      BEGIN OF ty_s_http_req,
        body TYPE string,
      END OF ty_s_http_req.

    TYPES:
      BEGIN OF ty_s_http_res,
        body TYPE string,
      END OF ty_s_http_res.

    CLASS-METHODS set_abap_res
      IMPORTING
        v1    TYPE REF TO object
        v2    TYPE REF TO object
        s_res TYPE ty_s_http_res.

    CLASS-METHODS get_abap_req
      IMPORTING
        v               TYPE REF TO object
        v2              TYPE REF TO object OPTIONAL
      RETURNING
        VALUE(r_result) TYPE ty_s_http_req.

    DATA ms_req TYPE ty_s_http_req.
    DATA ms_res TYPE ty_s_http_res.
    DATA ms_config TYPE z2ui5_if_types=>ty_s_http_config.

    METHODS get_js_cc_startup
      RETURNING
        VALUE(result) TYPE string.

    METHODS set_config
      IMPORTING
        is_custom_config TYPE z2ui5_if_types=>ty_s_http_config.
    METHODS set_response.
    METHODS set_request.

    METHODS set_abap_req
      IMPORTING
        v     TYPE REF TO object
        v2    TYPE REF TO object
        s_res TYPE z2ui5_cl_http_handler=>ty_s_http_req.

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


*    z2ui5_cl_http_handler=>factory( server )->main( value #(
*        content_security_policy = ``
*        title = ``
*        ).
*    z2ui5_cl_http_handler=>factory_cloud( )->main( ).


    set_request(  ).



*    DATA(ls_config) = main_get_config( ).
*    result = main_get_index_html( ls_config ).
*    NEW z2ui5_cl_core_draft_srv( )->cleanup( ).


    set_response( ).

  ENDMETHOD.


  METHOD get_abap_req.

    IF z2ui5_cl_util=>context_check_abap_cloud( ).

    ELSE.

    ENDIF.

  ENDMETHOD.


  METHOD set_abap_res.

  ENDMETHOD.

  METHOD factory.

    result = NEW z2ui5_cl_http_handler( ).
    result->mo_v1 = server.

  ENDMETHOD.

  METHOD factory_cloud.

    result = NEW z2ui5_cl_http_handler( ).
    result->mo_v1 = req.
    result->mo_v2 = res.

  ENDMETHOD.


  METHOD set_response.

    set_abap_res( v1 = mo_v1 v2 = mo_v2 s_res = ms_res ).

  ENDMETHOD.


  METHOD set_abap_req.

  ENDMETHOD.


  METHOD set_request.

    set_abap_req( v = mo_v1 v2 = mo_v2 s_res = ms_req ).

  ENDMETHOD.

ENDCLASS.
