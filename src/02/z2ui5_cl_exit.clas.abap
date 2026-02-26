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

    IF gi_me IS NOT INITIAL.
      ri_exit = gi_me.
      RETURN.
    ENDIF.

    DATA(lv_class_name) = get_user_exit_class( ).

    IF lv_class_name IS NOT INITIAL.
      TRY.
          CREATE OBJECT gi_user_exit TYPE (lv_class_name).
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
    ENDIF.

    gi_me = NEW z2ui5_cl_exit( ).
    ri_exit = gi_me.

  ENDMETHOD.

  METHOD get_user_exit_class.

    TRY.
        DATA(exit_classes) = z2ui5_cl_util=>rtti_get_classes_impl_intf( `Z2UI5_IF_EXIT` ).
        DELETE exit_classes WHERE classname = `Z2UI5_CL_EXIT`.

        IF exit_classes IS NOT INITIAL.
          r_class_name = exit_classes[ 1 ]-classname.
        ENDIF.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD z2ui5_if_exit~set_config_http_get.

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

    cs_config-t_security_header = VALUE #(
        ( n = `cache-control`          v = `no-cache, no-store, must-revalidate` )
        ( n = `Pragma`                 v = `no-cache` )
        ( n = `Expires`                v = `0` )
        ( n = `X-Content-Type-Options` v = `nosniff` )
        ( n = `X-Frame-Options`        v = `SAMEORIGIN` )
        ( n = `Referrer-Policy`        v = `strict-origin-when-cross-origin` )
        ( n = `Permissions-Policy`     v = `geolocation=(self), microphone=(self), camera=(self), payment=(), usb=()` ) ).

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

    context = CORRESPONDING #( http_info ).
    context-app_start = VALUE #( http_info-t_params[ n = `app_start` ]-v OPTIONAL ).

  ENDMETHOD.

ENDCLASS.
