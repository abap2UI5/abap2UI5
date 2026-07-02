CLASS z2ui5_cl_exit DEFINITION PUBLIC.

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

    IF gi_me IS BOUND.
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
        DATA temp3 TYPE string.
        DATA temp4 TYPE z2ui5_cl_util_api=>ty_s_class_descr.

    TRY.

        exit_classes = z2ui5_cl_util=>rtti_get_classes_impl_intf( `Z2UI5_IF_EXIT` ).
        DELETE exit_classes WHERE classname = `Z2UI5_CL_EXIT`.


        CLEAR temp3.

        READ TABLE exit_classes INTO temp4 INDEX 1.
        IF sy-subrc = 0.
          temp3 = temp4-classname.
        ENDIF.
        r_class_name = temp3.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD z2ui5_if_exit~set_config_http_get.
    DATA temp5 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp6 LIKE LINE OF temp5.

    cs_config-title = `abap2UI5`.
    cs_config-theme = `sap_horizon`.

    cs_config-src = `https://sdk.openui5.org/resources/sap-ui-cachebuster/sap-ui-core.js`.

    " since 21.11.2025 without unsafe-eval
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


    CLEAR temp5.

    temp6-n = `cache-control`.
    temp6-v = `no-cache, no-store, must-revalidate`.
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `Pragma`.
    temp6-v = `no-cache`.
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `Expires`.
    temp6-v = `0`.
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `X-Content-Type-Options`.
    temp6-v = `nosniff`.
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `X-Frame-Options`.
    temp6-v = `SAMEORIGIN`.
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `Referrer-Policy`.
    temp6-v = `strict-origin-when-cross-origin`.
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `Permissions-Policy`.
    temp6-v = `geolocation=(self), microphone=(self), camera=(self), payment=(), usb=()`.
    INSERT temp6 INTO TABLE temp5.
    cs_config-t_security_header = temp5.

    IF gi_user_exit IS BOUND.
      gi_user_exit->set_config_http_get( EXPORTING is_context = context
                                         CHANGING  cs_config  = cs_config ).
    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_exit~set_config_http_post.

    cs_config-draft_exp_time_in_hours = 4.

    IF gi_user_exit IS BOUND.
      gi_user_exit->set_config_http_post( EXPORTING is_context = context
                                          CHANGING  cs_config  = cs_config ).
    ENDIF.

    IF cs_config-draft_exp_time_in_hours <= 0.
      cs_config-draft_exp_time_in_hours = 4.
    ENDIF.

  ENDMETHOD.

  METHOD init_context.
    DATA temp7 TYPE z2ui5_if_types=>ty_s_http_context-app_start.
    DATA temp8 TYPE z2ui5_cl_util=>ty_s_name_value.

    MOVE-CORRESPONDING http_info TO context.

    CLEAR temp7.

    READ TABLE http_info-t_params INTO temp8 WITH KEY n = `app_start`.
    IF sy-subrc = 0.
      temp7 = temp8-v.
    ENDIF.
    context-app_start = temp7.

  ENDMETHOD.

ENDCLASS.
