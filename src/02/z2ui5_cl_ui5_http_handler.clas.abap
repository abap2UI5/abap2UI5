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

    " The exit's own security headers, guarded like the config read in
    " _error_response. set_response runs AFTER the outer TRY of main( ), on
    " the error path too, and config_http_get( ) latches its cache only once
    " the exit returned: a GET whose set_config_http_get raised inside
    " _http_get (a 500 by now) asked the exit a second time here, it raised
    " again, and the ICF stack dumped with no body and no status; on a POST
    " the GET exit ran here for the first time, unguarded. A raising exit now
    " costs its headers, not the response.
    METHODS set_response_exit_headers.

    " The CSRF gate over THIS request: reads the headers the decision needs
    " and hands them to _check_csrf_rejected. Split off so the reads happen
    " only when the gate is active and only as far as the rule looks -
    " origin, referer just when origin is absent, the host only when there
    " is a source to compare it with. Each read is a dynamic call into the
    " ICF request, and every POST used to pay all four up front
    METHODS check_csrf_rejected_request
      IMPORTING
        is_config     TYPE z2ui5_if_ui5_exit=>ty_s_http_config_post
      RETURNING
        VALUE(result) TYPE abap_bool.

    " Cache of the assembled GET shell, per internal session. The body is a
    " pure function of the embedded frontend (constant per class load) and
    " the exit-supplied config parts, so it is rebuilt only when those parts
    " change - a system whose exit answers per-user (theme by user) simply
    " thrashes the key back to the rebuild that ran on every GET before the
    " cache existed. CLASS-DATA dies with the internal session, and on
    " stateless ICF (the overwhelming deployment) every GET IS a fresh
    " session: the cache hits inside a stateful session only, everywhere
    " else the miss path runs per page load - which is why nothing on it
    " may cost more than the rebuild itself (see _get_etag).
    " sv_get_etag doubles as the ETag set_response sends with the page and
    " compares against If-None-Match: version constant, build hash of the
    " embedded frontend and a digest of the cache key, so a redeployed
    " frontend (new embedded classes, same version constant) changes it
    " even between releases - a version-only tag would 304 a browser into
    " keeping a stale shell.
    CLASS-DATA sv_get_cache_key  TYPE string.
    CLASS-DATA sv_get_cache_body TYPE string.
    CLASS-DATA sv_get_etag       TYPE string.

    " a cache validator, not a cryptographic hash - see the method
    CLASS-METHODS _get_etag
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE string.

    " If-None-Match against the current tag, RFC 7232 weak comparison over a
    " list - see the method
    CLASS-METHODS _check_etag_match
      IMPORTING
        iv_header     TYPE string
        iv_etag       TYPE string
      RETURNING
        VALUE(result) TYPE abap_bool.

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

    " Outer top-level catch. _main( ) carries one of its own and is where a
    " failing app lands, but three things run OUTSIDE it and used to be
    " unprotected: get_req_info( ), init_context( ) and the CSRF gate's call
    " into the user exit - arbitrary customer code. An exception in any of
    " them left the ICF stack to dump: no body, no status code and none of
    " the security headers - the state the WHEN OTHERS branch of _main( )
    " exists to prevent. set_response( ) sits after ENDTRY so it runs on both
    " paths; this TRY does not cover it, and its own call into the user exit
    " (the security headers) is guarded where it happens.
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
            DATA(ls_config_post) = VALUE z2ui5_if_ui5_exit=>ty_s_http_config_post( ).
            z2ui5_cl_ui5_user_exit=>get_instance( )->set_config_http_post( CHANGING cs_config = ls_config_post ).

            IF check_csrf_rejected_request( ls_config_post ) = abap_true.
              ms_res = VALUE #( body          = `CSRF validation failed - cross-origin request rejected`
                                status_code   = 403
                                status_reason = `Forbidden` ).
            ELSEIF ms_req-method = `HEAD`.
              " the session-terminate ping from the frontend (core/Server.js
              " endSession). It used to RETURN before set_response( ), which
              " sent the reply with status code 0 and none of the security
              " headers. An empty 200 through the normal tail keeps status and
              " headers consistent with every other reply.
              "
              " Deliberate conflation, worth stating: to HTTP, HEAD on this
              " URL is "GET without a body" and should answer with the GET
              " shell's headers (a cache may fold a HEAD reply into its
              " stored GET entry). Here it is not - HEAD is repurposed as the
              " terminate ping, and set_response( ) answers it through the
              " no-store branch (no ETag, no revalidation), NOT with the
              " shell's cache headers. That is the wanted behaviour: a
              " terminate ping answered from a cache terminates nothing, and
              " a no-store HEAD reply is what keeps intermediaries from
              " updating their stored GET shell from it. Nothing but the
              " framework's own frontend sends HEAD to this node, so the
              " generic-client reading of HEAD has no consumer to serve.
              mo_server->set_session_stateful( 0 ).
              ms_res = VALUE #( status_code   = 200
                                status_reason = `OK` ).
            ELSE.
              ms_res = _main( ms_req ).
            ENDIF.
          WHEN OTHERS.
            ms_res = _main( ms_req ).
        ENDCASE.

      CATCH cx_root INTO DATA(lx_fatal).
        ms_res = _error_response( val    = lx_fatal
                                  method = ms_req-method ).
    ENDTRY.

    set_response( ).

  ENDMETHOD.

  METHOD check_csrf_rejected_request.

    IF is_config-check_csrf_active = abap_false.
      RETURN.
    ENDIF.

    " prefer Origin, fall back to Referer - the same order as the rule
    " below, so the second header is read only when the first is absent
    DATA(lv_origin) = mo_server->get_header_field( `origin` ).
    DATA lv_referer TYPE string.
    IF lv_origin IS INITIAL.
      lv_referer = mo_server->get_header_field( `referer` ).
    ENDIF.
    " nothing to compare -> the rule allows the request (lenient by design,
    " see _check_csrf_rejected), so the host is not asked for either
    IF lv_origin IS INITIAL AND lv_referer IS INITIAL.
      RETURN.
    ENDIF.

    " behind a reverse proxy / web dispatcher that rewrites Host to the
    " internal name, Origin still carries the EXTERNAL one - comparing
    " against Host would then 403 every legitimate request. The proxy
    " puts the external authority into X-Forwarded-Host; prefer it when
    " present (first entry - each hop may append its own). The header
    " is client-suppliable, so an installation without such a proxy
    " can stop trusting it via the exit (check_trust_forwarded_host)
    DATA(lv_host) = COND string(
        WHEN is_config-check_trust_forwarded_host = abap_true
        THEN mo_server->get_header_field( `x-forwarded-host` ) ).
    IF lv_host IS INITIAL.
      lv_host = mo_server->get_header_field( `host` ).
    ELSE.
      SPLIT lv_host AT `,` INTO lv_host DATA(lv_rest_hosts) ##NEEDED.
    ENDIF.

    result = _check_csrf_rejected( active  = abap_true
                                   origin  = lv_origin
                                   referer = lv_referer
                                   host    = lv_host ).

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

    IF server IS BOUND.
      result = NEW #( ).
      result->mo_server = z2ui5_cl_ui5_util_http=>factory( server ).
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
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING
          val = `EMPTY_HTTP_HANDLER_CALL_ERROR`.
    ENDIF.

  ENDMETHOD.

  METHOD factory_cloud.

    result = NEW #( ).
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

    DATA(ls_config) = config_http_get( ).

    " every config part the body is built from, length-prefixed so two
    " different configs can never concatenate to the same key. The embedded
    " frontend needs no key part: it is constant for the life of this class
    " load, and the cache does not outlive it
    DATA(lv_cache_key) = |{ strlen( ls_config-theme ) }:{ ls_config-theme }| &&
                         |{ strlen( ls_config-src ) }:{ ls_config-src }| &&
                         |{ strlen( ls_config-content_security_policy ) }:{ ls_config-content_security_policy }| &&
                         |{ strlen( ls_config-styles_css ) }:{ ls_config-styles_css }| &&
                         |{ strlen( ls_config-custom_js ) }:{ ls_config-custom_js }|.
    LOOP AT ls_config-t_add_config REFERENCE INTO DATA(lr_config_key).
      lv_cache_key = lv_cache_key &&
                     |{ strlen( lr_config_key->n ) }:{ lr_config_key->n }| &&
                     |{ strlen( lr_config_key->v ) }:{ lr_config_key->v }|.
    ENDLOOP.

    IF sv_get_cache_body IS NOT INITIAL AND sv_get_cache_key = lv_cache_key.
      result-body          = sv_get_cache_body.
      result-status_code   = 200.
      result-status_reason = `OK`.
      RETURN.
    ENDIF.

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
    DATA(lv_add_config) = ``.
    LOOP AT ls_config-t_add_config REFERENCE INTO DATA(lr_config).
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

    sv_get_cache_key  = lv_cache_key.
    sv_get_cache_body = result-body.
    sv_get_etag       = _get_etag( lv_cache_key ).

  ENDMETHOD.

  METHOD _get_etag.

    " a cache VALIDATOR, not a cryptographic hash: three modular
    " accumulators over the UTF-8 bytes of the CACHE KEY plus its byte count,
    " joined with the version constant and the build hash of the embedded
    " frontend (z2ui5_cl_ui5f_preload=>build_hash, a digest of every
    " embedded source computed once at generation time). It used to hash
    " the assembled BODY instead - the same guarantee, but paid per page
    " load: the cache in _http_get lives in CLASS-DATA and dies with the
    " internal session, so on stateless ICF "once per cache fill" was every
    " GET, ~700 KB through an interpreted byte loop before set_response
    " could even decide on a 304. The key is the exit config the body is
    " built from (a few KB), and the build hash carries what the body hash
    " carried: a redeployed frontend between releases changes the tag with
    " the version constant unchanged. Plain ABAP so the method downports to
    " 7.02 and transpiles. On a stack where the byte conversion is
    " unavailable the method answers empty and set_response skips ETag/304
    " - conditional GET degrades, nothing breaks.
    DATA lv_xstr TYPE xstring.
    TRY.
        lv_xstr = z2ui5_cl_ui5_util_context=>conv_get_xstring_by_string( val ).
      CATCH cx_root.
        RETURN.
    ENDTRY.

    " Three accumulators, not two: with the version constant, the build
    " hash and the byte count equal (two exit configs of the same length),
    " the two 16-bit accumulators alone left ~2^32 states - enough for a
    " same-length collision to 304 a browser into keeping a stale shell.
    " The third mixes with a larger modulus AND weighs every byte by its
    " position, so a pair that collides in h1/h2 still separates in h3
    " unless it also collides under a structurally different mix -
    " implausible for a cache validator's job, still no cryptographic claim
    DATA(lv_len) = xstrlen( lv_xstr ).
    DATA lv_h1 TYPE i VALUE 5381.
    DATA lv_h2 TYPE i VALUE 17.
    DATA lv_h3 TYPE i VALUE 104729.
    DATA lv_byte TYPE i.
    DATA lv_off TYPE i.
    WHILE lv_off < lv_len.
      lv_byte = lv_xstr+lv_off(1).
      lv_h1 = ( lv_h1 * 33 + lv_byte ) MOD 65521.
      lv_h2 = ( lv_h2 * 31 + lv_byte ) MOD 65519.
      lv_h3 = ( lv_h3 * 131 + lv_byte * ( lv_off MOD 251 + 1 ) ) MOD 1000003.
      lv_off = lv_off + 1.
    ENDWHILE.

    " quoted, as the ETag header syntax demands; the version constant and
    " the build hash ride along so a release or a redeployed frontend always
    " changes the tag even if the accumulators ever collided across it
    result = |"{ z2ui5_if_app=>version }-{ z2ui5_cl_ui5f_preload=>build_hash }-{ lv_len }-{ lv_h1 }-{ lv_h2 }-{ lv_h3 }"|.

  ENDMETHOD.

  METHOD _check_etag_match.

    " RFC 7232: If-None-Match is a LIST of validators, compared weakly - a
    " proxy that recompresses the page weak-marks the tag (nginx gzip sends
    " W/"tag" back), a browser may echo several, and `*` matches whatever is
    " current. Apache mod_deflate (DeflateAlterETag AddSuffix, its default)
    " instead appends `-gzip` INSIDE the quotes and passes the browser's
    " echo through untouched, so that suffix is accepted too - no tag of
    " this class ever carries it by itself. Exact string equality answered
    " none of the four, and behind such a proxy the conditional GET quietly
    " degraded to a full shell transfer on every reload for every user
    IF iv_header IS INITIAL OR iv_etag IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_gzip) = substring( val = iv_etag
                               len = strlen( iv_etag ) - 1 ) && `-gzip"`.
    SPLIT iv_header AT `,` INTO TABLE DATA(lt_candidate).
    LOOP AT lt_candidate INTO DATA(lv_candidate).
      CONDENSE lv_candidate.
      IF strlen( lv_candidate ) > 2 AND substring( val = lv_candidate
                                                   len = 2 ) = `W/`.
        lv_candidate = substring( val = lv_candidate
                                  off = 2 ).
      ENDIF.
      IF lv_candidate = `*` OR lv_candidate = iv_etag OR lv_candidate = lv_gzip.
        result = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD run.

    DATA(lo_handler) = factory( server = server
                                req    = req
                                res    = res ).

    lo_handler->main( ).

  ENDMETHOD.

  METHOD set_response.

    " Conditional GET: the shell page travels with an ETag (see _get_etag)
    " and revalidation instead of no-store, so a browser that
    " still holds the current page gets a bodyless 304 instead of the whole
    " embedded frontend on every reload / FLP re-entry. Only the 200 shell -
    " the roundtrip data itself always travels via POST, which stays no-store
    " below, and an error body must never be revalidated into staying.
    " GET exactly, not HEAD: HEAD of this URL is the session-terminate ping,
    " deliberately answered no-store rather than as "GET without a body" -
    " the reasoning sits at the HEAD branch in main( ).
    DATA(lv_etag_get) = ``.
    IF ms_req-method = `GET` AND ms_res-status_code = 200 AND sv_get_etag IS NOT INITIAL.
      lv_etag_get = sv_get_etag.
      IF _check_etag_match( iv_header = mo_server->get_header_field( `if-none-match` )
                            iv_etag   = sv_get_etag ) = abap_true.
        ms_res-status_code   = 304.
        ms_res-status_reason = `Not Modified`.
        CLEAR ms_res-body.
      ENDIF.
    ENDIF.

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

    " Cache policy, per verb, BEFORE the exit's own headers below - so an
    " exit that sets cache-control itself still wins. The GET shell carries
    " no user or app data (everything the app shows travels via POST), so it
    " may be stored but must be revalidated - the ETag above turns that into
    " a 304. Every other response is roundtrip data, a 500 dump or a 403 and
    " stays no-store, exactly the trio the exit default used to carry for
    " ALL responses (z2ui5_cl_ui5_user_exit leaves it to this method now).
    IF lv_etag_get IS NOT INITIAL.
      mo_server->set_header_field( n = `cache-control`
                                   v = `private, no-cache` ).
      mo_server->set_header_field( n = `etag`
                                   v = lv_etag_get ).
    ELSE.
      mo_server->set_header_field( n = `cache-control`
                                   v = `no-cache, no-store, must-revalidate` ).
      mo_server->set_header_field( n = `Pragma`
                                   v = `no-cache` ).
      mo_server->set_header_field( n = `Expires`
                                   v = `0` ).
    ENDIF.

    " the exit's own headers (see set_response_exit_headers)
    set_response_exit_headers( ).

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

  METHOD set_response_exit_headers.

    DATA ls_config TYPE z2ui5_if_ui5_exit=>ty_s_http_config.
    TRY.
        ls_config = config_http_get( ).
      CATCH cx_root ##NO_HANDLER.
        " a raising exit costs its headers, not the response
    ENDTRY.

    LOOP AT ls_config-t_security_header INTO DATA(ls_header).
      mo_server->set_header_field( n = ls_header-n
                                   v = ls_header-v ).
    ENDLOOP.

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
    "
    " A sticky handler answers the NEXT request from whatever action it
    " holds when this one ends. main( ) replaces the action on every nav
    " hop, so an exception mid-hop used to leave the CALLED app's action in
    " place - the next request (factory_by_frontend ignores the id while
    " the sticky container holds an app) then ran against an app the
    " frontend never saw, with the state main( ) had left it in. The action
    " the request started with is put back and its queues cleared before
    " the exception travels on to _main( )'s single catch; the app's own
    " state stays what main( ) made of it, like in any stateful ABAP session.
    " CLEANUP, not CATCH-and-RAISE: re-raising a variable typed cx_root is
    " "CX_STATIC_CHECK not caught or declared" for the extended check (the
    " static type could be one), while CLEANUP runs on the way out to the
    " handler in _main( ) and lets the original exception pass untouched
    DATA(lo_action_before) = lo_post->mo_action.
    TRY.
        MOVE-CORRESPONDING lo_post->main( ) TO result.
      CLEANUP.
        IF so_sticky_handler IS BOUND.
          lo_post->mo_action = lo_action_before.
          CLEAR lo_post->mo_action->ms_next.
        ENDIF.
    ENDTRY.

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
            result = VALUE #( body          = `Method Not Allowed`
                              status_code   = 405
                              status_reason = `Method Not Allowed` ).
        ENDCASE.

      CATCH cx_root INTO DATA(lx).
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
    DATA(ls_config_post) = VALUE z2ui5_if_ui5_exit=>ty_s_http_config_post( ).
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
    DATA lv_body TYPE string.
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

    result = VALUE #( body          = lv_body
                      status_code   = 500
                      status_reason = `Internal Server Error` ).

  ENDMETHOD.

  METHOD _error_body.

    DATA(lv_nl) = z2ui5_cl_ui5_util_context=>cv_char_util_newline.

    result = |abap2UI5 { z2ui5_if_app=>version } - unhandled exception in a { method } request| &&
             lv_nl && lv_nl && z2ui5_cx_ui5_util_error=>get_text_full( val ).

  ENDMETHOD.

  METHOD get_request.

    DATA(lo_handler) = factory( server = server
                                req    = req
                                res    = res ).

    " the same one-liner main( ) uses - get_req_info( ) fills all four fields.
    " Reading only body and method left path and t_params blank, and t_params
    " is where app_start and every other URL parameter lives: the two fields
    " app code reading the raw request is most likely after
    MOVE-CORRESPONDING lo_handler->mo_server->get_req_info( ) TO result.

  ENDMETHOD.

ENDCLASS.
