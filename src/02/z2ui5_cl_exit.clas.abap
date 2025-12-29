CLASS z2ui5_cl_exit DEFINITION PUBLIC FINAL.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_exit.

    CLASS-METHODS init_context
      IMPORTING
        http_info TYPE z2ui5_cl_util_http=>ty_s_http_req.

    CLASS-METHODS get_instance
      RETURNING
        VALUE(ri_exit) TYPE REF TO z2ui5_if_exit.

    CLASS-METHODS get_user_exit_class
      RETURNING
        VALUE(r_class_name) TYPE string.

  PROTECTED SECTION.
    CLASS-DATA gi_me        TYPE REF TO z2ui5_if_exit.
    CLASS-DATA gi_user_exit TYPE REF TO z2ui5_if_exit.
    CLASS-DATA context      TYPE z2ui5_if_types=>ty_s_http_context.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_exit IMPLEMENTATION.

  METHOD get_instance.
    DATA lv_class_name TYPE string.

    IF gi_me IS NOT INITIAL.
      ri_exit = gi_me.
      RETURN.
    ENDIF.

    
    lv_class_name = get_user_exit_class( ).

    IF lv_class_name IS NOT INITIAL.
      TRY.
          CREATE OBJECT gi_user_exit TYPE (lv_class_name).
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
    ENDIF.

    CREATE OBJECT gi_me TYPE z2ui5_cl_exit.
    ri_exit = gi_me.

  ENDMETHOD.

  METHOD get_user_exit_class.

    DATA exit_classes TYPE z2ui5_cl_util_api=>ty_t_classes.
      DATA temp1 LIKE LINE OF exit_classes.
      DATA temp2 LIKE sy-tabix.
    exit_classes = z2ui5_cl_util=>rtti_get_classes_impl_intf( `Z2UI5_IF_EXIT` ).
    DELETE exit_classes WHERE classname = `Z2UI5_CL_EXIT`.

    IF exit_classes IS NOT INITIAL.
      
      
      temp2 = sy-tabix.
      READ TABLE exit_classes INDEX 1 INTO temp1.
      sy-tabix = temp2.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      r_class_name = temp1-classname.
    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_exit~set_config_http_get.
    DATA temp3 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp4 LIKE LINE OF temp3.

    cs_config-title = `abap2UI5`.
    cs_config-theme = `sap_horizon`.

    cs_config-src = `https://sdk.openui5.org/resources/sap-ui-cachebuster/sap-ui-core.js`.
*      ms_req_config-src     = `https://sdk.openui5.org/1.71.67/resources/sap-ui-core.js`.
*      ms_req_config-src     = `https://sdk.openui5.org/nightly/2/resources/sap-ui-core.js`.

    " before 21.11.2025
*      cs_config-content_security_policy = |<meta http-equiv="Content-Security-Policy" content="default-src 'self' 'unsafe-inline' 'unsafe-eval' data: | &&
*        |ui5.sap.com *.ui5.sap.com sapui5.hana.ondemand.com *.sapui5.hana.ondemand.com openui5.hana.ondemand.com *.openui5.hana.ondemand.com | &&
*        |sdk.openui5.org *.sdk.openui5.org cdn.jsdelivr.net *.cdn.jsdelivr.net cdnjs.cloudflare.com *.cdnjs.cloudflare.com schemas *.schemas; worker-src 'self' blob:; "/>|.

    " after 21.11.2025 unsafe-inline, unsafe-eval deleted
    cs_config-content_security_policy =
      |<meta http-equiv="Content-Security-Policy" | &&
      |content="default-src 'self' 'unsafe-inline' data: | &&
      |ui5.sap.com *.ui5.sap.com | &&
      |sapui5.hana.ondemand.com *.sapui5.hana.ondemand.com | &&
      |openui5.hana.ondemand.com *.openui5.hana.ondemand.com | &&
      |sdk.openui5.org *.sdk.openui5.org | &&
      |cdn.jsdelivr.net *.cdn.jsdelivr.net | &&
      |cdnjs.cloudflare.com *.cdnjs.cloudflare.com schemas *.schemas; | &&
      |connect-src 'self' | &&
      |  ui5.sap.com *.ui5.sap.com | &&
      |  sapui5.hana.ondemand.com *.sapui5.hana.ondemand.com | &&
      |  openui5.hana.ondemand.com *.openui5.hana.ondemand.com | &&
      |  sdk.openui5.org *.sdk.openui5.org | &&
      |  cdn.jsdelivr.net *.cdn.jsdelivr.net | &&
      |  cdnjs.cloudflare.com *.cdnjs.cloudflare.com; | &&
      |worker-src 'self' blob:; "/>|.

    
    CLEAR temp3.
    
    temp4-n = `cache-control`.
    temp4-v = `no-cache, no-store, must-revalidate`.
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `Pragma`.
    temp4-v = `no-cache`.
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `Expires`.
    temp4-v = `0`.
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `X-Content-Type-Options`.
    temp4-v = `nosniff`.
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `X-Frame-Options`.
    temp4-v = `SAMEORIGIN`.
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `Referrer-Policy`.
    temp4-v = `strict-origin-when-cross-origin`.
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `Permissions-Policy`.
    temp4-v = `geolocation=(self), microphone=(self), camera=(self), payment=(), usb=()`.
    INSERT temp4 INTO TABLE temp3.
    cs_config-t_security_header = temp3.

    IF gi_user_exit IS NOT INITIAL.
      gi_user_exit->set_config_http_get( EXPORTING is_context = context
                                         CHANGING  cs_config  = cs_config ).
    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_exit~set_config_http_post.

    cs_config-draft_exp_time_in_hours = 4.

    IF gi_user_exit IS NOT INITIAL.
      gi_user_exit->set_config_http_post( EXPORTING is_context = me->context
                                          CHANGING  cs_config  = cs_config ).
    ENDIF.

    IF cs_config-draft_exp_time_in_hours IS INITIAL
        OR cs_config-draft_exp_time_in_hours <= 0.
      cs_config-draft_exp_time_in_hours = 4.
    ENDIF.

  ENDMETHOD.

  METHOD init_context.
    DATA temp5 TYPE z2ui5_if_types=>ty_s_http_context-app_start.
    DATA temp6 TYPE z2ui5_cl_util=>ty_s_name_value.

    MOVE-CORRESPONDING http_info TO context.
    
    CLEAR temp5.
    
    READ TABLE http_info-t_params INTO temp6 WITH KEY n = `app_start`.
    IF sy-subrc = 0.
      temp5 = temp6-v.
    ENDIF.
    context-app_start = temp5.

  ENDMETHOD.

ENDCLASS.
