CLASS z2ui5_cl_ui5_http_handler DEFINITION PUBLIC.

  PUBLIC SECTION.

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

    TYPES:
      BEGIN OF ty_s_http_req,
        method   TYPE string,
        body     TYPE string,
        path     TYPE string,
        t_params TYPE z2ui5_if_client=>ty_t_name_value,
      END OF ty_s_http_req.

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
        is_req        TYPE ty_s_http_req
      RETURNING
        VALUE(result) TYPE ty_s_http_res.

    CLASS-METHODS _http_get
      RETURNING
        VALUE(result) TYPE ty_s_http_res.

    METHODS main.

    CLASS-METHODS _main
      IMPORTING
        is_req        TYPE ty_s_http_req
      RETURNING
        VALUE(result) TYPE ty_s_http_res.

    " NO caller in this repository - public API kept for app code that reads
    " the raw request outside a roundtrip (rule 5 guards the signature).
    " Candidate for the next deliberate API revision if it stays unused
    CLASS-METHODS get_request
      IMPORTING
        server        TYPE REF TO object OPTIONAL
        req           TYPE REF TO object OPTIONAL
        res           TYPE REF TO object OPTIONAL
          PREFERRED PARAMETER server
      RETURNING
        VALUE(result) TYPE ty_s_http_req.

    " CSRF defense (on by default; an app can opt out via z2ui5_if_ui5_exit~
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

    DATA mo_server TYPE REF TO z2ui5_cl_ui5_util_http.
    DATA ms_req    TYPE ty_s_http_req.
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
    CLASS-DATA ss_config_http_get     TYPE z2ui5_if_ui5_exit=>ty_s_http_config.
    CLASS-DATA sv_config_http_get_set TYPE abap_bool.

    CLASS-METHODS config_http_get
      RETURNING
        VALUE(result) TYPE z2ui5_if_ui5_exit=>ty_s_http_config.

    " The plain-text body of a 500 response: one header line naming the
    " framework version and the request method, then the full exception dump
    " (see z2ui5_cx_ui5_util_error=>get_text_full). Only reached when the exit
    " did not ask for hidden error details.
    CLASS-METHODS _error_body
      IMPORTING
        !val          TYPE REF TO cx_root
        !method       TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    " The whole 500 response for an exception that reached one of the two
    " top-level catches - main( ) and _main( ) share it. Everything it does is
    " guarded, because it RUNS INSIDE A CATCH BLOCK and a raise there is not
    " caught by its own TRY: it would replace the error report with an
    " unhandled dump. Two things can fail here. Reading
    " check_hide_error_details calls the user exit, which is arbitrary customer
    " code and a plausible cause of the very exception being reported; and
    " rendering the dump walks the exception chain. Both fall back rather than
    " raise. Same belt-and-braces as z2ui5_cl_ui5_handler=>main around
    " request_context_info( ) - an annotation that fails must not replace the
    " error it was meant to describe.
    CLASS-METHODS _error_response
      IMPORTING
        !val          TYPE REF TO cx_root
        !method       TYPE clike
      RETURNING
        VALUE(result) TYPE ty_s_http_res.

    " reduce an Origin/Referer/Host value to its bare host[:port] authority
    " (lower-cased, scheme and path/query/fragment stripped) for same-origin
    " comparison in _check_csrf_rejected
    CLASS-METHODS _csrf_host_authority
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    " minimal HTML-attribute escaping for the exit-supplied values the GET
    " page interpolates into attribute positions (theme, src, t_add_config).
    " An exit deriving one of them from the request (t_params reaches it) is
    " otherwise a quote-breakout into the bootstrap script tag. The CSP value
    " stays raw on purpose - it is a whole meta TAG, not an attribute
    CLASS-METHODS _attr_escape
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE string.

ENDCLASS.


CLASS z2ui5_cl_ui5_http_handler IMPLEMENTATION.

  METHOD main.
            DATA temp1 TYPE z2ui5_if_ui5_exit=>ty_s_http_config_post.
            DATA ls_config_post LIKE temp1.
            DATA lv_host TYPE string.
              DATA lv_rest_hosts TYPE string.
        DATA lx_fatal TYPE REF TO cx_root.

    " Outer top-level catch. _main( ) carries one of its own and is where a
    " failing app lands, but four things run OUTSIDE it and used to be
    " unprotected: get_req_info( ), init_context( ), the CSRF gate's call into
    " the user exit - arbitrary customer code - and set_response( ) below.
    " An exception in any of them left the ICF stack to dump: no body, no
    " status code and none of the security headers, which is the exact state
    " the WHEN OTHERS branch of set_response documents as the thing to prevent.
    " set_response( ) sits after ENDTRY so it runs on both paths.
    TRY.
        " the one place the Layer 0 request type meets the public one - both are
        " structurally identical, and the public signature stays free of
        " z2ui5_cl_ui5_util_http (see ty_s_http_req above)
        MOVE-CORRESPONDING mo_server->get_req_info( ) TO ms_req.

        " initialize the exit context and reset the per-request GET-config cache
        " up front: the CSRF gate below already calls the user exit, and a
        " rejected POST never reaches _main( ) - without this the exit would see
        " the previous request's context and set_response( ) would emit the
        " previous request's cached security headers ( _main( ) repeats both,
        " harmlessly - they are idempotent )
        z2ui5_cl_ui5_user_exit=>init_context( ms_req ).
        CLEAR: ss_config_http_get, sv_config_http_get_set.

        CASE ms_req-method.
          WHEN `HEAD` OR `POST`.
            " CSRF gate. It covers BOTH state-changing verbs: a POST runs the
            " app, and the HEAD below terminates the stateful session. HEAD is
            " a CORS-simple method, so any page can send it with credentials
            " and the reply being opaque does not stop the call from executing
            " - gating only the POST would have left the one state change a
            " cross-origin page can still reach. Reading the config is cheap
            " (get_instance is cached); check_csrf_active defaults to abap_true
            " (seeded in z2ui5_cl_ui5_user_exit=>set_config_http_post), so a
            " cross-origin request is rejected unless an app opts out via its
            " own exit.

            CLEAR temp1.

            ls_config_post = temp1.
            z2ui5_cl_ui5_user_exit=>get_instance( )->set_config_http_post( CHANGING cs_config = ls_config_post ).

            " behind a reverse proxy / web dispatcher that rewrites Host to the
            " internal name, Origin still carries the EXTERNAL one - comparing
            " against Host would then 403 every legitimate request. The proxy
            " puts the external authority into X-Forwarded-Host; prefer it when
            " present (first entry - each hop may append its own)

            lv_host = mo_server->get_header_field( `x-forwarded-host` ).
            IF lv_host IS INITIAL.
              lv_host = mo_server->get_header_field( `host` ).
            ELSE.

              SPLIT lv_host AT `,` INTO lv_host lv_rest_hosts ##NEEDED.
            ENDIF.

            IF _check_csrf_rejected( active  = ls_config_post-check_csrf_active
                                     origin  = mo_server->get_header_field( `origin` )
                                     referer = mo_server->get_header_field( `referer` )
                                     host    = lv_host ) = abap_true.
              CLEAR ms_res.
              ms_res-body = `CSRF validation failed - cross-origin request rejected`.
              ms_res-status_code = 403.
              ms_res-status_reason = `Forbidden`.
            ELSEIF ms_req-method = `HEAD`.
              " the session-terminate ping from the frontend (core/Server.js
              " endSession). It used to RETURN before set_response( ), which
              " sent the reply with status code 0 and none of the security
              " headers. An empty 200 through the normal tail keeps status and
              " headers consistent with every other reply
              mo_server->set_session_stateful( 0 ).
              CLEAR ms_res.
              ms_res-status_code = 200.
              ms_res-status_reason = `OK`.
            ELSE.
              ms_res = _main( ms_req ).
            ENDIF.
          WHEN OTHERS.
            ms_res = _main( ms_req ).
        ENDCASE.


      CATCH cx_root INTO lx_fatal.
        ms_res = _error_response( val    = lx_fatal
                                  method = ms_req-method ).
    ENDTRY.

    set_response( ).

  ENDMETHOD.

  METHOD _check_csrf_rejected.
    DATA temp2 TYPE string.
    DATA lv_source LIKE temp2.
    DATA temp1 TYPE xsdboolean.

    IF active = abap_false.
      RETURN.
    ENDIF.

    " prefer Origin (sent on every cross-origin POST and on same-origin
    " fetch), fall back to Referer when Origin is absent

    IF origin IS NOT INITIAL.
      temp2 = origin.
    ELSE.
      temp2 = referer.
    ENDIF.

    lv_source = temp2.

    " lenient: nothing to compare -> allow (do not lock out proxies/old
    " clients that strip these headers); only an explicit mismatch is blocked
    IF lv_source IS INITIAL OR host IS INITIAL.
      RETURN.
    ENDIF.


    temp1 = boolc( _csrf_host_authority( lv_source ) <> _csrf_host_authority( host ) ).
    result = temp1.

  ENDMETHOD.

  METHOD _csrf_host_authority.

    DATA lv_val TYPE string.
    DATA lv_pos TYPE i.
    DATA lv_rest TYPE string.
    lv_val = to_lower( val ).

    " drop the scheme (e.g. `https://`)

    lv_pos = find( val = lv_val
                         sub = `://` ).
    IF lv_pos >= 0.
      lv_val = substring( val = lv_val
                          off = lv_pos + 3 ).
    ENDIF.

    " the authority ends at the first path / query / fragment separator

    SPLIT lv_val AT `/` INTO lv_val lv_rest.
    SPLIT lv_val AT `?` INTO lv_val lv_rest.
    SPLIT lv_val AT `#` INTO lv_val lv_rest.

    result = lv_val.

  ENDMETHOD.

  METHOD _attr_escape.

    result = val.
    " the common value carries none of these - skip the four copies then
    IF result NA `&<"'`.
      RETURN.
    ENDIF.
    result = replace( val  = result
                      sub  = `&`
                      with = `&amp;`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `<`
                      with = `&lt;`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `"`
                      with = `&quot;`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `'`
                      with = `&#39;`
                      occ  = 0 ).

  ENDMETHOD.

  METHOD factory.
      FIELD-SYMBOLS <response> TYPE any.

    IF server IS BOUND.
      CREATE OBJECT result.
      result->mo_server = z2ui5_cl_ui5_util_http=>factory( server ).
      " generic field symbol on purpose: a typed one (REF TO object) makes
      " the dynamic ASSIGN cast, and REF TO if_http_response is not
      " IDENTICAL to REF TO object - a real stack raises an uncatchable
      " casting error there, the MOVE below widens legally instead

      ASSIGN server->(`RESPONSE`) TO <response>.
      IF sy-subrc = 0.
        result->mo_response_onprem = <response>.
      ENDIF.
    ELSEIF req IS BOUND AND res IS BOUND.
      result = factory_cloud( req = req
                              res = res ).
    ELSE.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING
          val = `EMPTY_HTTP_HANDLER_CALL_ERROR`.
    ENDIF.

  ENDMETHOD.

  METHOD factory_cloud.

    CREATE OBJECT result.
    result->mo_server = z2ui5_cl_ui5_util_http=>factory_cloud( req = req
                                                            res    = res ).

  ENDMETHOD.

  METHOD config_http_get.

    IF sv_config_http_get_set = abap_false.
      z2ui5_cl_ui5_user_exit=>get_instance( )->set_config_http_get( CHANGING cs_config = ss_config_http_get ).
      sv_config_http_get_set = abap_true.
    ENDIF.
    result = ss_config_http_get.

  ENDMETHOD.

  METHOD _http_get.

    DATA ls_config TYPE z2ui5_if_ui5_exit=>ty_s_http_config.
    DATA temp3 TYPE string.
    DATA lv_style_css LIKE temp3.
    DATA lv_preload TYPE string.
    DATA lv_globals TYPE string.
    DATA lv_add_config TYPE string.
    DATA temp4 LIKE LINE OF ls_config-t_add_config.
    DATA lr_config LIKE REF TO temp4.
    ls_config = config_http_get( ).


    IF ls_config-styles_css IS INITIAL.
      temp3 = z2ui5_cl_ui5f_style_css=>get( ).
    ELSE.
      temp3 = ls_config-styles_css.
    ENDIF.

    lv_style_css = temp3.

    " The entries for all embedded frontend files come from the generated
    " preload mapping (see .github/app2abap/trans2abap.js), so the list can
    " never run out of sync with app/webapp.

    lv_preload = z2ui5_cl_ui5f_preload=>get( styles_css = lv_style_css
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

    lv_globals = |window.z2ui5 = \{ checkLocal : true, | &&
                       |ccResourceRoot : "/sap/bc/ui5_ui5/sap/z2ui5_cci", | &&
                       |cccResourceRoot : "/sap/bc/ui5_ui5/sap/z2ui5_ccc" \};|.

    " The tab title is a constant. It used to come from `cs_config-title`, and
    " that field is still on the structure - it is simply no longer read. The
    " tab title belongs to the running app, which sets it through
    " cs_event-set_title at any point in its life; two mechanisms for one
    " string meant the page and the app could disagree about what the tab says,
    " and only one of them can react to what the app is actually showing. What
    " is left here is the name the browser shows while UI5 boots, before any
    " app can speak - and a page whose <title> is empty shows the URL.
    result-body = |<!DOCTYPE html>\n| &&
                  |<html lang="en">\n| &&
                  |<head>\n| &&
                  |{ ls_config-content_security_policy }\n| &&
                  |    <meta charset="UTF-8">\n| &&
                  |    <meta name="viewport" content="width=device-width, initial-scale=1.0">\n| &&
                  |    <meta http-equiv="X-UA-Compatible" content="IE=edge">\n| &&
                  |<title>abap2UI5</title>\n| &&
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
                  |data-sap-ui-theme="{ _attr_escape( ls_config-theme ) }" src="{ _attr_escape( ls_config-src ) }"|.

    " built apart and appended once: result-body already carries the whole
    " embedded preload here, so appending per config row re-copied ~400KB
    " per entry. Name and value are both escaped - see _attr_escape

    lv_add_config = ``.


    LOOP AT ls_config-t_add_config REFERENCE INTO lr_config.
      lv_add_config = |{ lv_add_config } { _attr_escape( lr_config->n ) }='{ _attr_escape( lr_config->v ) }'|.
    ENDLOOP.
    result-body = result-body && lv_add_config.

    result-body = result-body &&
                  | ></script></head>\n| &&
                  |<body class="sapUiBody sapUiSizeCompact" id="content">\n| &&
                  |    <div data-sap-ui-component data-name="z2ui5" data-id="container" data-settings='\{"id" : "z2ui5"\}' data-handle-validation="true"></div>\n| &&
                  | </body></html>|.

    result-status_code   = 200.
    result-status_reason = `OK`.

  ENDMETHOD.

  METHOD run.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_http_handler.
    lo_handler = factory( server = server
                                req    = req
                                res    = res ).

    lo_handler->main( ).

  ENDMETHOD.

  METHOD set_response.
    DATA temp5 TYPE string.
    DATA lv_content_type LIKE temp5.
    DATA ls_config TYPE z2ui5_if_ui5_exit=>ty_s_http_config.
    DATA ls_header LIKE LINE OF ls_config-t_security_header.
    DATA lv_contextid TYPE string.

    mo_server->set_cdata( ms_res-body ).

    " Always send an explicit Content-Type. Error bodies (403/500) are plain
    " text - serving them as text/plain, together with the X-Content-Type-
    " Options: nosniff header below, stops a container that defaults to
    " text/html from rendering a reflected app name / exception text as markup
    " (reflected-XSS). Success bodies are HTML for the GET shell and JSON for
    " the POST roundtrip.

    IF ms_res-status_code >= 400.
      temp5 = `text/plain; charset=UTF-8`.
    ELSEIF ms_req-method = `GET`.
      temp5 = `text/html; charset=UTF-8`.
    ELSE.
      temp5 = `application/json; charset=UTF-8`.
    ENDIF.

    lv_content_type = temp5.
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


    ls_config = config_http_get( ).


    LOOP AT ls_config-t_security_header INTO ls_header.
      mo_server->set_header_field( n = ls_header-n
                                   v = ls_header-v ).
    ENDLOOP.

    mo_server->set_status( code   = ms_res-status_code
                           reason = ms_res-status_reason ).

    " transform cookie into header-based contextid handling

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
      DATA lo_post TYPE REF TO z2ui5_cl_ui5_handler.

    " the request itself is intentionally not wrapped - exceptions bubble up
    " to the single top-level catch in _main( ), which turns them into a 500.
    " Only the sticky-handler bookkeeping at the end has its own catch, which
    " must never turn an already successful response into a 500
    IF so_sticky_handler IS NOT BOUND.

      CREATE OBJECT lo_post TYPE z2ui5_cl_ui5_handler EXPORTING VAL = is_req-body.
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
        DATA lx TYPE REF TO cx_root.

    " Single top-level catch for the whole request. The framework may raise
    " anywhere (e.g. a wrong app name in the URL -> CREATE OBJECT of an unknown
    " class in factory_first_start); any unhandled exception is turned into a
    " 500 whose body carries the exception text, so the frontend shows the real
    " reason instead of the SAP ICF 500 page, which suppresses that text.
    TRY.
        z2ui5_cl_ui5_user_exit=>init_context( is_req ).
        CLEAR: ss_config_http_get, sv_config_http_get_set.

        CASE is_req-method.
          WHEN `GET`.
            result = _http_get( ).
          WHEN `POST`.
            result = _http_post( is_req ).
          WHEN OTHERS.
            " OPTIONS/PUT/DELETE/... - without this branch the response
            " would go out with status code 0
            CLEAR result.
            result-body = `Method Not Allowed`.
            result-status_code = 405.
            result-status_reason = `Method Not Allowed`.
        ENDCASE.


      CATCH cx_root INTO lx.
        result = _error_response( val    = lx
                                  method = is_req-method ).
    ENDTRY.

  ENDMETHOD.

  METHOD _error_response.

    " In hardened installations the exit sets check_hide_error_details, so the
    " raw exception text (RTTI/class/DDIC names, dynamic-call failures, and the
    " system/user context the full dump carries) is replaced by a generic
    " message instead of leaking to the client.
    " Default is abap_false -> the real reason is returned as before.
    DATA temp6 TYPE z2ui5_if_ui5_exit=>ty_s_http_config_post.
    DATA ls_config_post LIKE temp6.
    DATA lv_body TYPE string.
    CLEAR temp6.

    ls_config_post = temp6.
    TRY.
        z2ui5_cl_ui5_user_exit=>get_instance( )->set_config_http_post( CHANGING cs_config = ls_config_post ).
      CATCH cx_root ##NO_HANDLER.
        " the exit is customer code and may be what failed in the first place.
        " Falling through leaves check_hide_error_details at its abap_false
        " default, which is the pre-exit behaviour: report the real reason
    ENDTRY.

    " the body is the only diagnostic the developer gets - the browser shows it
    " in the fatal-error overlay and nothing of it survives the roundtrip
    " anywhere else. Ship the FULL dump (whole previous chain with class,
    " source position, kernel id and exception attributes), not just the
    " outermost message: a MOVE_CAST or a failed dynamic call says nothing
    " without the cause below it

    IF ls_config_post-check_hide_error_details = abap_true.
      lv_body = `Internal Server Error`.
    ELSE.
      TRY.
          lv_body = _error_body( val    = val
                                 method = method ).
        CATCH cx_root.
          " rendering the dump walks the chain and reads each entry's
          " attributes; if that is what breaks, the outermost message is still
          " worth more to the developer than a bare status code
          TRY.
              lv_body = |abap2UI5 - unhandled exception in a { method } request: { val->get_text( ) }|.
            CATCH cx_root.
              lv_body = `Internal Server Error`.
          ENDTRY.
      ENDTRY.
    ENDIF.

    CLEAR result.
    result-body = lv_body.
    result-status_code = 500.
    result-status_reason = `Internal Server Error`.

  ENDMETHOD.

  METHOD _error_body.

    DATA lv_nl LIKE z2ui5_cl_ui5_util_context=>cv_char_util_newline.
    lv_nl = z2ui5_cl_ui5_util_context=>cv_char_util_newline.

    result = |abap2UI5 { z2ui5_if_app=>version } - unhandled exception in a { method } request| &&
             lv_nl && lv_nl && z2ui5_cx_ui5_util_error=>get_text_full( val ).

  ENDMETHOD.

  METHOD get_request.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_http_handler.
    lo_handler = factory( server = server
                                req    = req
                                res    = res ).

    " the same one-liner main( ) uses - get_req_info( ) fills all four fields.
    " Reading only body and method left path and t_params blank, and t_params
    " is where app_start and every other URL parameter lives: the two fields
    " app code reading the raw request is most likely after
    MOVE-CORRESPONDING lo_handler->mo_server->get_req_info( ) TO result.

  ENDMETHOD.

ENDCLASS.
