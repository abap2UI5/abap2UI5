CLASS z2ui5_cl_http_handler DEFINITION PUBLIC.

  PUBLIC SECTION.
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
        VALUE(result) TYPE REF TO z2ui5_cl_http_handler.

    CLASS-METHODS factory
      IMPORTING
        server        TYPE REF TO object OPTIONAL
        req           TYPE REF TO object OPTIONAL
        res           TYPE REF TO object OPTIONAL
          PREFERRED PARAMETER server
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_http_handler.

    CLASS-METHODS _http_post
      IMPORTING
        is_req        TYPE z2ui5_cl_a2ui5_http=>ty_s_http_req
      RETURNING
        VALUE(result) TYPE z2ui5_if_core_types=>ty_s_http_res.

    CLASS-METHODS _http_get
      RETURNING
        VALUE(result) TYPE z2ui5_if_core_types=>ty_s_http_res.

    METHODS main.

    CLASS-METHODS _main
      IMPORTING
        is_req        TYPE z2ui5_cl_a2ui5_http=>ty_s_http_req
      RETURNING
        VALUE(result) TYPE z2ui5_if_core_types=>ty_s_http_res.

    CLASS-METHODS get_request
      IMPORTING
        server        TYPE REF TO object OPTIONAL
        req           TYPE REF TO object OPTIONAL
        res           TYPE REF TO object OPTIONAL
          PREFERRED PARAMETER server
      RETURNING
        VALUE(result) TYPE z2ui5_cl_a2ui5_http=>ty_s_http_req.

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
    CLASS-DATA so_sticky_handler TYPE REF TO z2ui5_cl_core_handler.

    DATA mo_server TYPE REF TO z2ui5_cl_a2ui5_http.
    DATA ms_req    TYPE z2ui5_cl_a2ui5_http=>ty_s_http_req.
    DATA ms_res    TYPE z2ui5_if_core_types=>ty_s_http_res.

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

    " reduce an Origin/Referer/Host value to its bare host[:port] authority
    " (lower-cased, scheme and path/query/fragment stripped) for same-origin
    " comparison in _check_csrf_rejected
    CLASS-METHODS _csrf_host_authority
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

ENDCLASS.


CLASS z2ui5_cl_http_handler IMPLEMENTATION.

  METHOD main.

    ms_req = mo_server->get_req_info( ).

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
      result->mo_server = z2ui5_cl_a2ui5_http=>factory( server ).
    ELSEIF req IS BOUND AND res IS BOUND.
      result = factory_cloud( req = req
                              res = res ).
    ELSE.
      RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
        EXPORTING val = `EMPTY_HTTP_HANDLER_CALL_ERROR`.
    ENDIF.

  ENDMETHOD.

  METHOD factory_cloud.

    result = NEW #( ).
    result->mo_server = z2ui5_cl_a2ui5_http=>factory_cloud( req = req
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

    IF ls_config-styles_css IS INITIAL.
      DATA(lv_style_css) = z2ui5_cl_app_style_css=>get( ).
    ELSE.
      lv_style_css = ls_config-styles_css.
    ENDIF.

    result-body = |<!DOCTYPE html>| && |\n| &&
               |<html lang="en">| && |\n| &&
               |<head>| && |\n| &&
                  |{ ls_config-content_security_policy }\n| &&
               |    <meta charset="UTF-8">| && |\n| &&
               |    <meta name="viewport" content="width=device-width, initial-scale=1.0">| && |\n| &&
               |    <meta http-equiv="X-UA-Compatible" content="IE=edge">| && |\n| &&
                |<title>{ ls_config-title }</title>\n| &&
                | <style>        html, body, body > div, #container, #container-uiarea \{\n| &&
                |            height: 100%;\n| &&
                |        \}</style> \n| &&
                |<script>| && |\n| &&
             |  function onInitComponent()\{| && |\n| &&
             |    sap.ui.require.preload(\{| && |\n| &&
             " The entries for all embedded frontend files come from the
             " generated preload mapping (see .github/app2abap/trans2abap.js),
             " so the list can never run out of sync with app/webapp.
             z2ui5_cl_app_preload=>get( styles_css = lv_style_css
                                        custom_js  = ls_config-custom_js ) &&
             |    \});| && |\n| &&
             |    sap.ui.require(["sap/ui/core/ComponentSupport"], function(ComponentSupport)\{| && |\n| &&
             |     window.z2ui5 = \{ checkLocal : true \}; ComponentSupport.run();| && |\n| &&
             |    \});| && |\n| &&
             |  \}| && |\n| &&
             |</script>| && |\n| &&
                |<script id="sap-ui-bootstrap" data-sap-ui-resourceroots='\{ "z2ui5": "./" \}' data-sap-ui-oninit="onInitComponent" | && |\n| &&
                 |data-sap-ui-compatVersion="edge" data-sap-ui-async="true" data-sap-ui-frameOptions="trusted" data-sap-ui-bindingSyntax="complex"| && |\n| &&
                 |data-sap-ui-theme="{ ls_config-theme }" src="{ ls_config-src }"|.

    LOOP AT ls_config-t_add_config REFERENCE INTO DATA(lr_config).
      result-body = |{ result-body } { lr_config->n }='{ lr_config->v }'|.
    ENDLOOP.

    result-body          = result-body &&
                 | ></script></head>| && |\n| &&
                 |<body class="sapUiBody sapUiSizeCompact" id="content">| && |\n| &&
                 |    <div data-sap-ui-component data-name="z2ui5" data-id="container" data-settings='\{"id" : "z2ui5"\}' data-handle-validation="true"></div>| && |\n| &&
                 | </body></html>|.

    result-status_code   = 200.
    result-status_reason = `success`.

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
      DATA(lo_post) = NEW z2ui5_cl_core_handler( is_req-body ).
    ELSE.
      lo_post = so_sticky_handler.
      lo_post->mv_request_json = is_req-body.
    ENDIF.

    result = lo_post->main( ).

    TRY.
        DATA(li_app) = CAST z2ui5_if_app( lo_post->mo_action->mo_app->mo_app ).
        IF li_app->check_sticky = abap_true.
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
        " the raw exception text (RTTI/class/DDIC names, dynamic-call failures)
        " is replaced by a generic message instead of leaking to the client.
        " Default is abap_false -> the real reason is returned as before.
        DATA(ls_config_post) = VALUE z2ui5_if_types=>ty_s_http_config_post( ).
        z2ui5_cl_exit=>get_instance( )->set_config_http_post( CHANGING cs_config = ls_config_post ).

        result = VALUE #( body          = COND #( WHEN ls_config_post-check_hide_error_details = abap_true
                                                  THEN `Internal Server Error`
                                                  ELSE lx->get_text( ) )
                          status_code   = 500
                          status_reason = `Internal Server Error` ).
    ENDTRY.

  ENDMETHOD.

  METHOD get_request.

    DATA(lo_handler) = factory( server = server
                                req    = req
                                res    = res ).

    result-body   = lo_handler->mo_server->get_cdata( ).
    result-method = lo_handler->mo_server->get_method( ).

  ENDMETHOD.

ENDCLASS.
