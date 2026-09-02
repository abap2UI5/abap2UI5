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
    " the default CSP meta tag, assembled once per roll area. This method
    " runs on EVERY request - z2ui5_cl_ui5_http_handler=>set_response reads
    " the security headers from the GET config on a POST as well - and the
    " tag is a constant, so the seven-fragment template ran per roundtrip
    " for the same string. Lazily filled on first use, not in a class
    " constructor: a public class_constructor is what abap-check names a
    " trap, and the view builder's gv_escape_specials takes the same road
    CLASS-DATA gv_csp_default TYPE string.
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

    IF gv_csp_default IS INITIAL.
      " The UI5 CDN hosts a default installation may bootstrap from or fall
      " back to. Deliberately ONLY these: general-purpose CDNs (jsdelivr,
      " cdnjs) used to ride along although nothing the framework ships loads
      " from them, and every allowed script host is a host whose compromise is
      " script execution in an authenticated SAP session. An exit that needs
      " another host adds it - to the one directive that needs it.
      DATA(lv_ui5_hosts) =
        `ui5.sap.com *.ui5.sap.com ` &&
        `sapui5.hana.ondemand.com *.sapui5.hana.ondemand.com ` &&
        `openui5.hana.ondemand.com *.openui5.hana.ondemand.com ` &&
        `sdk.openui5.org *.sdk.openui5.org`.

      " 'unsafe-eval' is required by the OpenUI5 1.71 ui5loader (it evaluates
      " module source as a string); without it the 1.71 bootstrap fails with a
      " CSP EvalError. Modern UI5 does not use eval, so keeping it here only
      " affects older releases, and 'unsafe-inline' is already allowed so the
      " delta is marginal. Apps pinning a modern UI5 can drop it via their exit.
      "
      " script-src and style-src are EXPLICIT on purpose, not left to the
      " default-src fallback: default-src carries data:/blob: for images,
      " fonts and media, and a data: that falls through to script-src is a
      " textbook CSP bypass (any HTML-injection foothold escalates to script
      " execution via <script src="data:...">). The split keeps data:/blob:
      " and the unsafe-* keywords each confined to the directives that need
      " them.
      gv_csp_default =
        |<meta http-equiv="Content-Security-Policy" | &&
        |content="default-src 'self' data: blob: { lv_ui5_hosts } schemas *.schemas; | &&
        |script-src 'self' 'unsafe-inline' 'unsafe-eval' { lv_ui5_hosts }; | &&
        |style-src 'self' 'unsafe-inline' { lv_ui5_hosts }; | &&
        |connect-src 'self' { lv_ui5_hosts }; | &&
        |worker-src 'self' blob:; | &&
        " Hardening directives (no runtime cost for a UI5 app): block plugin
        " content and pin <base> to the app origin. NO frame-ancestors here:
        " browsers IGNORE that directive in a <meta> CSP (and log a console
        " warning) - cross-origin framing is forbidden by the real
        " X-Frame-Options: SAMEORIGIN response header set below instead.
        |object-src 'none'; base-uri 'self'; "/>|.
    ENDIF.
    cs_config-content_security_policy = gv_csp_default.

    " NO cache-control/Pragma/Expires here any more: the cache policy is
    " per verb and set by z2ui5_cl_ui5_http_handler=>set_response (the GET
    " shell revalidates via ETag/304, everything else stays no-store). An
    " exit that adds its own cache-control entry to this table still wins -
    " the table is applied after the handler's headers.
    " NO Strict-Transport-Security either, deliberately: many on-premise
    " systems serve plain HTTP, and HSTS belongs on the TLS terminator that
    " knows the deployment - an exit behind HTTPS adds it here.
    cs_config-t_security_header = VALUE #(
        ( n = `X-Content-Type-Options` v = `nosniff` )
        ( n = `X-Frame-Options`        v = `SAMEORIGIN` )
        ( n = `Referrer-Policy`        v = `strict-origin-when-cross-origin` )
        ( n = `Permissions-Policy`     v = `geolocation=(self), microphone=(self), camera=(self), payment=(), usb=()` )
        " sever cross-origin window references / cross-origin embedding of
        " the shell - both are cheap, and X-Frame-Options above already
        " forbids the framing case they would otherwise soften
        ( n = `Cross-Origin-Opener-Policy`   v = `same-origin` )
        ( n = `Cross-Origin-Resource-Policy` v = `same-origin` ) ).

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

    " trusted by default so proxy/web-dispatcher setups work out of the box;
    " an installation without such a proxy hardens the CSRF gate by setting
    " it to abap_false (reasoning at the field in z2ui5_if_ui5_exit)
    cs_config-check_trust_forwarded_host = abap_true.

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
    context-app_start = VALUE #( http_info-t_params[ n = `app_start` ]-v OPTIONAL ). "#EC CI_SORTSEQ

  ENDMETHOD.

ENDCLASS.
