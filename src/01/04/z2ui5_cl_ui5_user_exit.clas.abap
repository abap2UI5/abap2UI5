CLASS z2ui5_cl_ui5_user_exit DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_ui5_exit.

    CLASS-METHODS init_context
      IMPORTING
        http_info TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_req.

    CLASS-METHODS get_instance
      RETURNING
        VALUE(ri_exit) TYPE REF TO z2ui5_if_ui5_exit.

    CLASS-METHODS get_user_exit_class
      RETURNING
        VALUE(r_class_name) TYPE string.

  PROTECTED SECTION.
    CLASS-DATA gi_me            TYPE REF TO z2ui5_if_ui5_exit.
    CLASS-DATA gi_user_exit     TYPE REF TO z2ui5_if_ui5_exit.
    " the same exit found under the superseded interface - only one of the two
    " is ever bound, see get_instance
    CLASS-DATA gi_user_exit_dep TYPE REF TO z2ui5_if_exit.
    CLASS-DATA context          TYPE z2ui5_if_ui5_exit=>ty_s_http_context.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_ui5_user_exit IMPLEMENTATION.

  METHOD get_instance.

    IF gi_me IS BOUND.
      ri_exit = gi_me.
      RETURN.
    ENDIF.

    DATA(lv_class_name) = get_user_exit_class( ).

    IF lv_class_name IS NOT INITIAL.
      TRY.
          DATA lo_exit TYPE REF TO object.
          CREATE OBJECT lo_exit TYPE (lv_class_name).

          " Which interface the class implements decides how it is called, and
          " the cast is what asks the object rather than the class list. A
          " class implementing BOTH lands in gi_user_exit and is therefore
          " called once, through the current interface - never twice.
          TRY.
              gi_user_exit ?= lo_exit.
            CATCH cx_sy_move_cast_error.
              gi_user_exit_dep ?= lo_exit.
          ENDTRY.
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
    ENDIF.

    gi_me = NEW z2ui5_cl_ui5_user_exit( ).
    ri_exit = gi_me.

  ENDMETHOD.

  METHOD get_user_exit_class.

    TRY.
        " the interface is Z2UI5_IF_UI5_EXIT - the class around it is the user
        " exit, the interface is not. #2564 renamed z2ui5_cl_exit to
        " z2ui5_cl_ui5_user_exit and carried the rename into this literal, which
        " left the lookup asking for an interface that does not exist: no class
        " implements it, so every user exit in every system silently stopped
        " being found. A dynamic name is not a reference the compiler checks -
        " .github/scripts/dynamic-name-gate.mjs does it instead
        DATA(exit_classes) = z2ui5_cl_ui5_util_context=>rtti_get_classes_impl_intf( `Z2UI5_IF_UI5_EXIT` ).

        " The superseded interface is looked up too, for as long as it ships:
        " an exit written against Z2UI5_IF_EXIT is found exactly as before, and
        " a class implementing both appears in both lists - hence the dedup
        " below, and the cast order in get_instance that calls it once.
        DATA(exit_classes_dep) = z2ui5_cl_ui5_util_context=>rtti_get_classes_impl_intf( `Z2UI5_IF_EXIT` ).
        APPEND LINES OF exit_classes_dep TO exit_classes.

        DELETE exit_classes WHERE classname = `Z2UI5_CL_UI5_USER_EXIT`.

        " only one user exit can be active, so the pick must not depend on the
        " order the class lookup happens to return (SEOCLASS select order on
        " standard ABAP, XCO order on cloud) - a system with two implementing
        " classes would otherwise silently run a different exit after a
        " transport or a system copy. Sorting makes it reproducible.
        SORT exit_classes BY classname.
        DELETE ADJACENT DUPLICATES FROM exit_classes COMPARING classname.

        r_class_name = VALUE #( exit_classes[ 1 ]-classname OPTIONAL ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_exit~set_config_http_get.

    " No title here: the page carries a constant <title> (see
    " z2ui5_cl_ui5_http_handler), and an app that wants its own tab title sets
    " it while it runs, with cs_event-set_title.
    cs_config-theme = `sap_horizon`.

    cs_config-src = `https://sdk.openui5.org/resources/sap-ui-cachebuster/sap-ui-core.js`.

    " 'unsafe-eval' is required by the OpenUI5 1.71 ui5loader (it evaluates
    " module source as a string); without it the 1.71 bootstrap fails with a
    " CSP EvalError. Modern UI5 does not use eval, so keeping it here only
    " affects older releases, and 'unsafe-inline' is already allowed so the
    " delta is marginal. Apps pinning a modern UI5 can drop it via their exit.
    cs_config-content_security_policy =
      |<meta http-equiv="Content-Security-Policy" | &&
      |content="default-src 'self' 'unsafe-inline' 'unsafe-eval' data: | &&
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
      |worker-src 'self' blob:; | &&
      " Hardening directives (no runtime cost for a UI5 app): block plugin
      " content and pin <base> to the app origin. NO frame-ancestors here:
      " browsers IGNORE that directive in a <meta> CSP (and log a console
      " warning) - cross-origin framing is forbidden by the real
      " X-Frame-Options: SAMEORIGIN response header set below instead.
      |object-src 'none'; base-uri 'self'; "/>|.

    cs_config-t_security_header = VALUE #(
        ( n = `cache-control`          v = `no-cache, no-store, must-revalidate` )
        ( n = `Pragma`                 v = `no-cache` )
        ( n = `Expires`                v = `0` )
        ( n = `X-Content-Type-Options` v = `nosniff` )
        ( n = `X-Frame-Options`        v = `SAMEORIGIN` )
        ( n = `Referrer-Policy`        v = `strict-origin-when-cross-origin` )
        ( n = `Permissions-Policy`     v = `geolocation=(self), microphone=(self), camera=(self), payment=(), usb=()` ) ).

    IF gi_user_exit IS BOUND.
      gi_user_exit->set_config_http_get( EXPORTING is_context = context
                                         CHANGING  cs_config  = cs_config ).
    ELSEIF gi_user_exit_dep IS BOUND.
      gi_user_exit_dep->set_config_http_get( EXPORTING is_context = context
                                             CHANGING  cs_config  = cs_config ).
    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_exit~set_config_http_post.

    CONSTANTS lc_default_exp_time_in_hours TYPE i VALUE 4.

    cs_config-draft_exp_time_in_hours = lc_default_exp_time_in_hours.

    " CSRF protection is on by default: the whole state machine hangs off the
    " POST, so out of the box a cross-origin POST must be rejected rather than
    " relying on a fronting SAP ICF/CSRF layer that may or may not be there.
    " Seeded before the user exit runs, so an app that must accept cross-origin
    " POSTs still has the escape hatch of setting it back to abap_false in its
    " own set_config_http_post.
    cs_config-check_csrf_active = abap_true.

    IF gi_user_exit IS BOUND.
      gi_user_exit->set_config_http_post( EXPORTING is_context = context
                                          CHANGING  cs_config  = cs_config ).
    ELSEIF gi_user_exit_dep IS BOUND.
      gi_user_exit_dep->set_config_http_post( EXPORTING is_context = context
                                              CHANGING  cs_config  = cs_config ).
    ENDIF.

    IF cs_config-draft_exp_time_in_hours <= 0.
      cs_config-draft_exp_time_in_hours = lc_default_exp_time_in_hours.
    ENDIF.

  ENDMETHOD.

  METHOD init_context.

    context = CORRESPONDING #( http_info ).
    context-app_start = VALUE #( http_info-t_params[ n = `app_start` ]-v OPTIONAL ).

  ENDMETHOD.

ENDCLASS.
