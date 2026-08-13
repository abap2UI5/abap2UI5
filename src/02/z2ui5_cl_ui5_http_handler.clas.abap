CLASS z2ui5_cl_ui5_http_handler DEFINITION PUBLIC.

  PUBLIC SECTION.
    " The HTTP response this handler hands back to the ICF/cloud stack. It is
    " declared HERE, on the public boundary, and not taken from a core
    " interface: the core types are Layer 1 internals and must not appear in a
    " public signature, or renaming an internal would break the contract of
    " src/02. The core carries its own structurally identical type; the two
    " meet once, in _http_post( ), via MOVE-CORRESPONDING.
    TYPES:
      BEGIN OF ty_s_http_res,
        body          TYPE string,
        status_code   TYPE i,
        status_reason TYPE string,
        BEGIN OF s_stateful,
          active   TYPE i,
          switched TYPE abap_bool,
        END OF s_stateful,
      END OF ty_s_http_res.

    CLASS-METHODS run
      IMPORTING
        server TYPE REF TO object                    OPTIONAL
        req    TYPE REF TO object                    OPTIONAL
        res    TYPE REF TO object                    OPTIONAL
          PREFERRED PARAMETER server.

    CLASS-METHODS factory_cloud
      IMPORTING
        req           TYPE REF TO object
        res           TYPE REF TO object
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_http_handler.

    CLASS-METHODS factory
      IMPORTING
        server        TYPE REF TO object OPTIONAL
        req           TYPE REF TO object OPTIONAL
        res           TYPE REF TO object OPTIONAL
          PREFERRED PARAMETER server
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_http_handler.

    CLASS-METHODS _http_post
      IMPORTING
        is_req        TYPE z2ui5_if_types=>ty_s_http_req
      RETURNING
        VALUE(result) TYPE ty_s_http_res.

    CLASS-METHODS _http_get
      RETURNING
        VALUE(result) TYPE ty_s_http_res.

    METHODS main.

    CLASS-METHODS _main
      IMPORTING
        is_req        TYPE z2ui5_if_types=>ty_s_http_req
      RETURNING
        VALUE(result) TYPE ty_s_http_res.

    CLASS-METHODS get_request
      IMPORTING
        server        TYPE REF TO object OPTIONAL
        req           TYPE REF TO object OPTIONAL
        res           TYPE REF TO object OPTIONAL
          PREFERRED PARAMETER server
      RETURNING
        VALUE(result) TYPE z2ui5_if_types=>ty_s_http_req.

    " CSRF defense (on by default; an app can opt out via z2ui5_if_exit~
    " set_config_http_post -> check_csrf_active = abap_false). Pure and
    " side-effect free so it is unit-testable
    " without a server mock: the caller reads the header values off the
    " request and passes them in. Returns abap_true only when the request is
    " to be rejected, i.e. csrf is active AND an Origin/Referer is present
    " AND its host authority differs from the app's own Host header.
    CLASS-METHODS _check_csrf_rejected
      IMPORTING
        active        TYPE abap_bool
        origin        TYPE clike
        referer       TYPE clike
        host          TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

  PROTECTED SECTION.
    CLASS-DATA so_sticky_handler TYPE REF TO z2ui5_cl_ui5_handler.

    DATA mo_server TYPE REF TO z2ui5_cl_ui5_http.
    DATA ms_req    TYPE z2ui5_if_types=>ty_s_http_req.
    DATA ms_res    TYPE ty_s_http_res.

    " the raw if_http_response of the ON-PREM ICF stack, captured dynamically
    " in factory( ) - only that stack carries the set_compression( ) hook
    " (see set_response). Stays unbound on the cloud stack, whose response
    " type does not exist in the cloud language version.
    DATA mo_response_onprem TYPE REF TO object.

    METHODS set_response.

  PRIVATE SECTION.
    " Per-request cache of the HTTP-GET exit config. Both _http_get (page body)
    " and set_response (security headers) need it; without the cache the user
    " exit set_config_http_get( ) would run twice on every GET. Reset in _main( )
    " after init_context( ), so the exit always sees the current request context.
    CLASS-DATA ss_config_http_get     TYPE z2ui5_if_types=>ty_s_http_config.
    CLASS-DATA sv_config_http_get_set TYPE abap_bool.

    CLASS-METHODS config_http_get
      RETURNING
        VALUE(result) TYPE z2ui5_if_types=>ty_s_http_config.

    " The plain-text body of a 500 response: one header line naming the
    " framework version and the request method, then the full exception dump
    " (see z2ui5_cx_ui5_error=>get_text_full). Only reached when the exit
    " did not ask for hidden error details.
    CLASS-METHODS _error_body
      IMPORTING
        !val          TYPE REF TO cx_root
        !method       TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    " reduce an Origin/Referer/Host value to its bare host[:port] authority
    " (lower-cased, scheme and path/query/fragment stripped) for same-origin
    " comparison in _check_csrf_rejected
    CLASS-METHODS _csrf_host_authority
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

ENDCLASS.


CLASS z2ui5_cl_ui5_http_handler IMPLEMENTATION.

  METHOD main.

    " the one place the Layer 0 request type meets the public one - both are
    " structurally identical, and the public signature stays free of
    " z2ui5_cl_ui5_http (see z2ui5_if_types=>ty_s_http_req)
    MOVE-CORRESPONDING mo_server->get_req_info( ) TO ms_req.

    " initialize the exit context and reset the per-request GET-config cache
    " up front: the CSRF gate below already calls the user exit, and a
    " rejected POST never reaches _main( ) - without this the exit would see
    " the previous request's context and set_response( ) would emit the
    " previous request's cached security headers ( _main( ) repeats both,
    " harmlessly - they are idempotent )
    z2ui5_cl_exit=>init_context( ms_req ).
    CLEAR: ss_config_http_get, sv_config_http_get_set.

    CASE ms_req-method.
      WHEN `HEAD`.
        mo_server->set_session_stateful( 0 ).
        RETURN.
      WHEN `POST`.
        " CSRF gate: only a POST can change state, so the check lives here.
        " Reading the config every POST is cheap (get_instance is cached);
        " check_csrf_active defaults to abap_true (seeded in z2ui5_cl_exit=>
        " set_config_http_post), so a cross-origin POST is rejected unless an
        " app opts out via its own exit.
        DATA(ls_config_post) = VALUE z2ui5_if_types=>ty_s_http_config_post( ).
        z2ui5_cl_exit=>get_instance( )->set_config_http_post( CHANGING cs_config = ls_config_post ).

        IF _check_csrf_rejected( active  = ls_config_post-check_csrf_active
                                 origin  = mo_server->get_header_field( `origin` )
                                 referer = mo_server->get_header_field( `referer` )
                                 host    = mo_server->get_header_field( `host` ) ) = abap_true.
          ms_res = VALUE #( body          = `CSRF validation failed - cross-origin POST rejected`
                            status_code   = 403
                            status_reason = `Forbidden` ).
        ELSE.
          ms_res = _main( ms_req ).
        ENDIF.
      WHEN OTHERS.
        ms_res = _main( ms_req ).
    ENDCASE.

    set_response( ).

  ENDMETHOD.

  METHOD _check_csrf_rejected.

    IF active = abap_false.
      RETURN.
    ENDIF.

    " prefer Origin (sent on every cross-origin POST and on same-origin
    " fetch), fall back to Referer when Origin is absent
    DATA(lv_source) = COND string( WHEN origin IS NOT INITIAL
                                   THEN origin
                                   ELSE referer ).

    " lenient: nothing to compare -> allow (do not lock out proxies/old
    " clients that strip these headers); only an explicit mismatch is blocked
    IF lv_source IS INITIAL OR host IS INITIAL.
      RETURN.
    ENDIF.

    result = xsdbool( _csrf_host_authority( lv_source ) <> _csrf_host_authority( host ) ).

  ENDMETHOD.

  METHOD _csrf_host_authority.

    DATA(lv_val) = to_lower( val ).

    " drop the scheme (e.g. `https://`)
    DATA(lv_pos) = find( val = lv_val
                         sub = `://` ).
    IF lv_pos >= 0.
      lv_val = substring( val = lv_val
                          off = lv_pos + 3 ).
    ENDIF.

    " the authority ends at the first path / query / fragment separator
    SPLIT lv_val AT `/` INTO lv_val DATA(lv_rest).
    SPLIT lv_val AT `?` INTO lv_val lv_rest.
    SPLIT lv_val AT `#` INTO lv_val lv_rest.

    result = lv_val.

  ENDMETHOD.

  METHOD factory.

    IF server IS BOUND.
      result = NEW #( ).
      result->mo_server = z2ui5_cl_ui5_http=>factory( server ).
      " generic field symbol on purpose: a typed one (REF TO object) makes
      " the dynamic ASSIGN cast, and REF TO if_http_response is not
      " IDENTICAL to REF TO object - a real stack raises an uncatchable
      " casting error there, the MOVE below widens legally instead
      FIELD-SYMBOLS <response> TYPE any.
      ASSIGN server->(`RESPONSE`) TO <response>.
      IF sy-subrc = 0.
        result->mo_response_onprem = <response>.
      ENDIF.
    ELSEIF req IS BOUND AND res IS BOUND.
      result = factory_cloud( req = req
                              res = res ).
    ELSE.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_error
        EXPORTING val = `EMPTY_HTTP_HANDLER_CALL_ERROR`.
    ENDIF.

  ENDMETHOD.

  METHOD factory_cloud.

    result = NEW #( ).
    result->mo_server = z2ui5_cl_ui5_http=>factory_cloud( req   = req
                                                            res = res ).

  ENDMETHOD.

  METHOD config_http_get.

    IF sv_config_http_get_set = abap_false.
      z2ui5_cl_exit=>get_instance( )->set_config_http_get( CHANGING cs_config = ss_config_http_get ).
      sv_config_http_get_set = abap_true.
    ENDIF.
    result = ss_config_http_get.

  ENDMETHOD.

  METHOD _http_get.

    DATA(ls_config) = config_http_get( ).

    DATA(lv_style_css) = COND string( WHEN ls_config-styles_css IS INITIAL
                                      THEN z2ui5_cl_ui5f_style_css=>get( )
                                      ELSE ls_config-styles_css ).

    " The entries for all embedded frontend files come from the generated
    " preload mapping (see .github/app2abap/trans2abap.js), so the list can
    " never run out of sync with app/webapp.
    DATA(lv_preload) = z2ui5_cl_ui5f_preload=>get( styles_css = lv_style_css
                                                   custom_js  = ls_config-custom_js ).

    " Custom controls (z2ui5_cci, abap2UI5-addons/custom-controls) and the
    " customer's own frontend artefacts (z2ui5_ccc,
    " abap2UI5/customer-frontend-extension) each live in their own BSP, which
    " the frontend finds through the reserved resourceRoots in manifest.json
    " ("z2ui5_cci": "../z2ui5_cci/", "z2ui5_ccc": "../z2ui5_ccc/"). Those paths are
    " siblings of the FRONTEND BSP, so they are only correct when the app is
    " served from it. Here the component base is this ICF node and the same
    " relative path resolves next to /sap/bc/, where nothing is.
    "
    " Hand the absolute BSP paths to the frontend instead. They cannot be
    " applied here: the manifest registers its own value during component
    " creation, which happens after everything this page can run, so it would
    " win. Component.js applies the fields in init( ), after manifest
    " processing. AppState~initGlobal keeps fields that are already on the
    " global when checkLocal is true, so they survive the component start. In
    " BSP and Launchpad mode the fields are absent and the manifest entries
    " stand. Registering a path costs nothing when the BSP is not installed -
    " nothing is requested from it until a view names the namespace.
    DATA(lv_globals) = |window.z2ui5 = \{ checkLocal : true, | &&
                       |ccResourceRoot : "/sap/bc/ui5_ui5/sap/z2ui5_cci", | &&
                       |cccResourceRoot : "/sap/bc/ui5_ui5/sap/z2ui5_ccc" \};|.

    result-body = |<!DOCTYPE html>\n| &&
                  |<html lang="en">\n| &&
                  |<head>\n| &&
                  |{ ls_config-content_security_policy }\n| &&
                  |    <meta charset="UTF-8">\n| &&
                  |    <meta name="viewport" content="width=device-width, initial-scale=1.0">\n| &&
                  |    <meta http-equiv="X-UA-Compatible" content="IE=edge">\n| &&
                  |<title>{ ls_config-title }</title>\n| &&
                  | <style>        html, body, body > div, #container, #container-uiarea \{\n| &&
                  |            height: 100%;\n| &&
                  |        \}</style> \n| &&
                  |<script>\n| &&
                  |  function onInitComponent()\{\n| &&
                  |    sap.ui.require.preload(\{\n| &&
                  lv_preload &&
                  |    \});\n| &&
                  |    sap.ui.require(["sap/ui/core/ComponentSupport"], function(ComponentSupport)\{\n| &&
                  |     { lv_globals } ComponentSupport.run();\n| &&
                  |    \});\n| &&
                  |  \}\n| &&
                  |</script>\n| &&
                  |<script id="sap-ui-bootstrap" data-sap-ui-resourceroots='\{ "z2ui5": "./" \}' data-sap-ui-oninit="onInitComponent" \n| &&
                  |data-sap-ui-compatVersion="edge" data-sap-ui-async="true" data-sap-ui-frameOptions="trusted" data-sap-ui-bindingSyntax="complex"\n| &&
                  |data-sap-ui-theme="{ ls_config-theme }" src="{ ls_config-src }"|.

    LOOP AT ls_config-t_add_config REFERENCE INTO DATA(lr_config).
      result-body = |{ result-body } { lr_config->n }='{ lr_config->v }'|.
    ENDLOOP.

    result-body = result-body &&
                  | ></script></head>\n| &&
                  |<body class="sapUiBody sapUiSizeCompact" id="content">\n| &&
                  |    <div data-sap-ui-component data-name="z2ui5" data-id="container" data-settings='\{"id" : "z2ui5"\}' data-handle-validation="true"></div>\n| &&
                  | </body></html>|.

    result-status_code   = 200.
    result-status_reason = `OK`.

  ENDMETHOD.

  METHOD run.

    DATA(lo_handler) = factory( server = server
                                req    = req
                                res    = res ).

    lo_handler->main( ).

  ENDMETHOD.

  METHOD set_response.

    mo_server->set_cdata( ms_res-body ).

    " Always send an explicit Content-Type. Error bodies (403/500) are plain
    " text - serving them as text/plain, together with the X-Content-Type-
    " Options: nosniff header below, stops a container that defaults to
    " text/html from rendering a reflected app name / exception text as markup
    " (reflected-XSS). Success bodies are HTML for the GET shell and JSON for
    " the POST roundtrip.
    DATA(lv_content_type) = COND string(
        WHEN ms_res-status_code >= 400 THEN `text/plain; charset=UTF-8`
        WHEN ms_req-method = `GET`     THEN `text/html; charset=UTF-8`
        ELSE `application/json; charset=UTF-8` ).
    mo_server->set_header_field( n = `content-type`
                                 v = lv_content_type ).

    " Ask the ICF runtime to gzip the response when the client accepts it.
    " Every body this handler sends is text (the GET shell carries the whole
    " embedded frontend, ~400KB; the POST roundtrip the model JSON), so this
    " is a 70-85% transfer cut on installations whose ICM profile does not
    " compress already - and a no-op on ones that do. Dynamic on purpose:
    " if_http_response does not exist in the cloud language version (the
    " platform router compresses there, mo_response_onprem stays unbound), and
    " the transpiled test backend's response shim simply lacks the method -
    " both must keep compiling and running, so a missing method is caught,
    " never declared. AFTER the content-type header: the default compression
    " mode decides based on the MIME type set at this point.
    IF mo_response_onprem IS BOUND.
      TRY.
          CALL METHOD mo_response_onprem->(`SET_COMPRESSION`).
        CATCH cx_root ##NO_HANDLER.
          " no compression support on this stack - the response stays plain
      ENDTRY.
    ENDIF.

    DATA(ls_config) = config_http_get( ).

    LOOP AT ls_config-t_security_header INTO DATA(ls_header).
      mo_server->set_header_field( n = ls_header-n
                                   v = ls_header-v ).
    ENDLOOP.

    mo_server->set_status( code   = ms_res-status_code
                           reason = ms_res-status_reason ).

    " transform cookie into header-based contextid handling
    DATA lv_contextid TYPE string.
    IF ms_res-s_stateful-switched = abap_true.
      mo_server->set_session_stateful( ms_res-s_stateful-active ).
      IF mo_server->get_header_field( `sap-contextid-accept` ) = `header`.
        lv_contextid = mo_server->get_response_cookie( `sap-contextid` ).
        IF lv_contextid IS NOT INITIAL.
          mo_server->delete_response_cookie( `sap-contextid` ).
          mo_server->set_header_field( n = `sap-contextid`
                                       v = lv_contextid ).
        ENDIF.
      ENDIF.
    ELSE.
      lv_contextid = mo_server->get_header_field( `sap-contextid` ).
      IF lv_contextid IS NOT INITIAL.
        mo_server->set_header_field( n = `sap-contextid`
                                     v = lv_contextid ).
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD _http_post.

    " the request itself is intentionally not wrapped - exceptions bubble up
    " to the single top-level catch in _main( ), which turns them into a 500.
    " Only the sticky-handler bookkeeping at the end has its own catch, which
    " must never turn an already successful response into a 500
    IF so_sticky_handler IS NOT BOUND.
      DATA(lo_post) = NEW z2ui5_cl_ui5_handler( is_req-body ).
    ELSE.
      lo_post = so_sticky_handler.
      lo_post->mv_request_json = is_req-body.
    ENDIF.

    " the only place the core's own response type meets the public one. Both
    " are structurally identical, so MOVE-CORRESPONDING carries every field
    " including s_stateful - and the public signature stays free of a Layer 1
    " type (see ty_s_http_res above).
    MOVE-CORRESPONDING lo_post->main( ) TO result.

    TRY.
        IF lo_post->mo_action->mo_app->mv_check_sticky = abap_true.
          so_sticky_handler = lo_post.
        ELSE.
          CLEAR so_sticky_handler.
        ENDIF.
      CATCH cx_root.
        CLEAR so_sticky_handler.
    ENDTRY.

  ENDMETHOD.

  METHOD _main.

    " Single top-level catch for the whole request. The framework may raise
    " anywhere (e.g. a wrong app name in the URL -> CREATE OBJECT of an unknown
    " class in factory_first_start); any unhandled exception is turned into a
    " 500 whose body carries the exception text, so the frontend shows the real
    " reason instead of the SAP ICF 500 page, which suppresses that text.
    TRY.
        z2ui5_cl_exit=>init_context( is_req ).
        CLEAR: ss_config_http_get, sv_config_http_get_set.

        CASE is_req-method.
          WHEN `GET`.
            result = _http_get( ).
          WHEN `POST`.
            result = _http_post( is_req ).
          WHEN OTHERS.
            " OPTIONS/PUT/DELETE/... - without this branch the response
            " would go out with status code 0
            result = VALUE #( body          = `Method Not Allowed`
                              status_code   = 405
                              status_reason = `Method Not Allowed` ).
        ENDCASE.

      CATCH cx_root INTO DATA(lx).
        " In hardened installations the exit sets check_hide_error_details, so
        " the raw exception text (RTTI/class/DDIC names, dynamic-call failures,
        " and the system/user context the full dump carries) is replaced by a
        " generic message instead of leaking to the client.
        " Default is abap_false -> the real reason is returned as before.
        DATA(ls_config_post) = VALUE z2ui5_if_types=>ty_s_http_config_post( ).
        z2ui5_cl_exit=>get_instance( )->set_config_http_post( CHANGING cs_config = ls_config_post ).

        " the body is the only diagnostic the developer gets - the browser
        " shows it in the fatal-error overlay and nothing of it survives the
        " roundtrip anywhere else. Ship the FULL dump (whole previous chain
        " with class, source position, kernel id and exception attributes),
        " not just the outermost message: a MOVE_CAST or a failed dynamic
        " call says nothing without the cause below it
        result = VALUE #( body          = COND #( WHEN ls_config_post-check_hide_error_details = abap_true
                                                  THEN `Internal Server Error`
                                                  ELSE _error_body( val    = lx
                                                                    method = is_req-method ) )
                          status_code   = 500
                          status_reason = `Internal Server Error` ).
    ENDTRY.

  ENDMETHOD.

  METHOD _error_body.

    DATA(lv_nl) = z2ui5_cl_ui5_context=>cv_char_util_newline.

    result = |abap2UI5 { z2ui5_if_app=>version } - unhandled exception in a { method } request| &&
             lv_nl && lv_nl && z2ui5_cx_ui5_error=>get_text_full( val ).

  ENDMETHOD.

  METHOD get_request.

    DATA(lo_handler) = factory( server = server
                                req    = req
                                res    = res ).

    result-body   = lo_handler->mo_server->get_cdata( ).
    result-method = lo_handler->mo_server->get_method( ).

  ENDMETHOD.

ENDCLASS.
