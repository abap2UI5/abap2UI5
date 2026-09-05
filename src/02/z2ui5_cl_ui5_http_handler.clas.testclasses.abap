CLASS ltcl_test_http_handler DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION LONG.

  PRIVATE SECTION.
    METHODS test_http_get_status   FOR TESTING RAISING cx_static_check.
    METHODS test_http_get_html     FOR TESTING RAISING cx_static_check.
    METHODS test_http_get_ui5_boot FOR TESTING RAISING cx_static_check.
    METHODS test_http_get_title    FOR TESTING RAISING cx_static_check.
    METHODS test_http_post_ok      FOR TESTING RAISING cx_static_check.
    METHODS test_http_post_error   FOR TESTING RAISING cx_static_check.
    METHODS test_main_post_no_app  FOR TESTING RAISING cx_static_check.
    METHODS test_main_get_routing  FOR TESTING RAISING cx_static_check.
    METHODS test_main_post_routing FOR TESTING RAISING cx_static_check.
    METHODS test_main_unsupported  FOR TESTING RAISING cx_static_check.
    METHODS test_post_no_s_front   FOR TESTING RAISING cx_static_check.
    METHODS test_csrf_inactive     FOR TESTING RAISING cx_static_check.
    METHODS test_csrf_same_origin  FOR TESTING RAISING cx_static_check.
    METHODS test_csrf_cross_origin FOR TESTING RAISING cx_static_check.
    METHODS test_csrf_no_headers   FOR TESTING RAISING cx_static_check.
    METHODS test_csrf_referer      FOR TESTING RAISING cx_static_check.
    METHODS test_preload_escaping  FOR TESTING RAISING cx_static_check.
    METHODS test_preload_literals  FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_test_http_handler IMPLEMENTATION.

  METHOD test_http_get_status.

    DATA ls_result TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_res.

    ls_result = z2ui5_cl_ui5_http_handler=>_http_get( ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = ls_result-status_code ).

    cl_abap_unit_assert=>assert_equals( exp = `OK`
                                        act = ls_result-status_reason ).

  ENDMETHOD.

  METHOD test_http_get_html.

    DATA ls_result TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_res.
    DATA temp1 TYPE xsdboolean.
    DATA temp2 TYPE xsdboolean.
    DATA temp3 TYPE xsdboolean.

    ls_result = z2ui5_cl_ui5_http_handler=>_http_get( ).

    cl_abap_unit_assert=>assert_not_initial( ls_result-body ).

    temp1 = xsdbool( ls_result-body CS `<!DOCTYPE html>` ).
    cl_abap_unit_assert=>assert_true( temp1 ).

    temp2 = xsdbool( ls_result-body CS `<html` ).
    cl_abap_unit_assert=>assert_true( temp2 ).

    temp3 = xsdbool( ls_result-body CS `</html>` ).
    cl_abap_unit_assert=>assert_true( temp3 ).

  ENDMETHOD.

  METHOD test_http_get_ui5_boot.

    DATA ls_result TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_res.
    DATA temp4 TYPE xsdboolean.
    DATA temp5 TYPE xsdboolean.

    ls_result = z2ui5_cl_ui5_http_handler=>_http_get( ).

    temp4 = xsdbool( ls_result-body CS `sap-ui-bootstrap` ).
    cl_abap_unit_assert=>assert_true( temp4 ).

    temp5 = xsdbool( ls_result-body CS `z2ui5` ).
    cl_abap_unit_assert=>assert_true( temp5 ).

  ENDMETHOD.

  METHOD test_http_get_title.

    " The tab title is constant: `cs_config-title` is not read any more, and an
    " app that wants its own title sets it while it runs, with
    " cs_event-set_title. Pinned as the literal tag, because a <title> holding
    " whatever the exit happened to assign is exactly what changed here - and
    " an empty one would leave the URL in the tab during the UI5 boot.

    DATA ls_result TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_res.
    DATA temp7 TYPE xsdboolean.

    ls_result = z2ui5_cl_ui5_http_handler=>_http_get( ).

    temp7 = xsdbool( ls_result-body CS `<title>abap2UI5</title>` ).
    cl_abap_unit_assert=>assert_true( temp7 ).

  ENDMETHOD.

  METHOD test_http_post_ok.

    DATA ls_req TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_req.
    DATA ls_result TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_res.
    DATA temp6 TYPE xsdboolean.

    ls_req-method = `POST`.
    ls_req-body = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":""}}}`.

    ls_result = z2ui5_cl_ui5_http_handler=>_http_post( ls_req ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = ls_result-status_code ).

    temp6 = xsdbool( ls_result-body CS `S_FRONT` ).
    cl_abap_unit_assert=>assert_true( temp6 ).

  ENDMETHOD.

  METHOD test_http_post_error.

    DATA ls_req TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_req.
    DATA lv_raised TYPE abap_bool.

    ls_req-method = `POST`.
    ls_req-body = `not valid json at all!!!`.

    " _http_post itself does not catch - the exception propagates to the caller
    " (the single catch lives one level up in _main, see test_main_post_no_app)
    TRY.
        z2ui5_cl_ui5_http_handler=>_http_post( ls_req ).
      CATCH cx_root.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).

  ENDMETHOD.

  METHOD test_main_post_no_app.

    " a wrong/mistyped app name in the URL raises in the framework; the single
    " top-level catch in _main turns it into a 500 whose body states the reason
    DATA ls_req TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_req.
    DATA ls_result TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_res.

    ls_req-method = `POST`.
    ls_req-body = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":"?app_start=Z2UI5_CL_APP_DOES_NOT_EXIST"}}}`.

    ls_result = z2ui5_cl_ui5_http_handler=>_main( ls_req ).

    cl_abap_unit_assert=>assert_equals( exp = 500
                                        act = ls_result-status_code ).
    cl_abap_unit_assert=>assert_char_cp( act = ls_result-body
                                         exp = `*Z2UI5_CL_APP_DOES_NOT_EXIST*does not exist*` ).

  ENDMETHOD.

  METHOD test_main_unsupported.

    " OPTIONS/PUT/... must answer 405, not fall through with status code 0
    DATA ls_req TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_req.
    DATA ls_result TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_res.

    ls_req-method = `OPTIONS`.

    ls_result = z2ui5_cl_ui5_http_handler=>_main( ls_req ).

    cl_abap_unit_assert=>assert_equals( exp = 405
                                        act = ls_result-status_code ).
    cl_abap_unit_assert=>assert_equals( exp = `Method Not Allowed`
                                        act = ls_result-status_reason ).

  ENDMETHOD.

  METHOD test_post_no_s_front.

    " valid JSON without an S_FRONT container (health-check POST, rewrapping
    " proxy) must take the system-startup path, not answer 500
    DATA ls_req TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_req.
    DATA ls_result TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_res.

    ls_req-method = `POST`.
    ls_req-body = `{"value":{}}`.

    ls_result = z2ui5_cl_ui5_http_handler=>_main( ls_req ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = ls_result-status_code ).

  ENDMETHOD.

  METHOD test_main_get_routing.

    DATA ls_req TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_req.
    DATA ls_result TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_res.
    DATA temp8 TYPE xsdboolean.

    ls_req-method = `GET`.

    ls_result = z2ui5_cl_ui5_http_handler=>_main( ls_req ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = ls_result-status_code ).

    temp8 = xsdbool( ls_result-body CS `<!DOCTYPE html>` ).
    cl_abap_unit_assert=>assert_true( temp8 ).

  ENDMETHOD.

  METHOD test_main_post_routing.

    DATA ls_req TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_req.
    DATA ls_result TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_res.

    ls_req-method = `POST`.
    ls_req-body = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":""}}}`.

    ls_result = z2ui5_cl_ui5_http_handler=>_main( ls_req ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = ls_result-status_code ).

  ENDMETHOD.

  METHOD test_csrf_inactive.

    " opt-out: with csrf disabled even a cross-origin request is allowed
    DATA(lv_rejected) = z2ui5_cl_ui5_http_handler=>_check_csrf_rejected(
                            active  = abap_false
                            origin  = `https://evil.example.com`
                            referer = ``
                            host    = `app.corp:44300` ).

    cl_abap_unit_assert=>assert_false( lv_rejected ).

  ENDMETHOD.

  METHOD test_csrf_same_origin.

    " same host authority (scheme/case ignored) -> allowed
    DATA(lv_rejected) = z2ui5_cl_ui5_http_handler=>_check_csrf_rejected(
                            active  = abap_true
                            origin  = `https://App.Corp:44300`
                            referer = ``
                            host    = `app.corp:44300` ).

    cl_abap_unit_assert=>assert_false( lv_rejected ).

  ENDMETHOD.

  METHOD test_csrf_cross_origin.

    " different host authority -> rejected
    DATA(lv_rejected) = z2ui5_cl_ui5_http_handler=>_check_csrf_rejected(
                            active  = abap_true
                            origin  = `https://evil.example.com`
                            referer = ``
                            host    = `app.corp:44300` ).

    cl_abap_unit_assert=>assert_true( lv_rejected ).

  ENDMETHOD.

  METHOD test_csrf_no_headers.

    " lenient: no Origin and no Referer -> allowed (proxies / old clients)
    DATA(lv_rejected) = z2ui5_cl_ui5_http_handler=>_check_csrf_rejected(
                            active  = abap_true
                            origin  = ``
                            referer = ``
                            host    = `app.corp:44300` ).

    cl_abap_unit_assert=>assert_false( lv_rejected ).

  ENDMETHOD.

  METHOD test_csrf_referer.

    " Origin absent -> fall back to Referer (with a path), cross-site -> rejected
    DATA(lv_rejected) = z2ui5_cl_ui5_http_handler=>_check_csrf_rejected(
                            active  = abap_true
                            origin  = ``
                            referer = `https://evil.example.com/attack?x=1`
                            host    = `app.corp:44300` ).

    cl_abap_unit_assert=>assert_true( lv_rejected ).

  ENDMETHOD.

  " The next two tests exercise z2ui5_cl_ui5f_preload rather than this class.
  " That class is generated (see .github/app2abap/trans2abap.js) and its
  " package is wiped on every regeneration, so it cannot carry a test include
  " of its own - and _http_get( ) above is the consumer that breaks: it drops
  " the preload into the one <script> block that defines onInitComponent.

  METHOD test_preload_escaping.

    " styles_css comes from the exit unfiltered and lands inside a JS
    " single-quoted string literal, so an apostrophe, a backslash or a line
    " break in a customer's own CSS has to arrive escaped.
    DATA lv_css TYPE string.
    DATA temp30 TYPE xsdboolean.
    DATA temp31 TYPE xsdboolean.
    DATA temp32 TYPE xsdboolean.
    DATA temp33 TYPE xsdboolean.

    lv_css = `.a::after { content: 'x'; }` && |\n| && `.b { background: url("i\c.png"); }`.

    DATA(lv_preload) = z2ui5_cl_ui5f_preload=>get( styles_css = lv_css
                                                  custom_js   = `` ).

    temp30 = xsdbool( lv_preload CS `content: \'x\';` ).
    cl_abap_unit_assert=>assert_true( temp30 ).

    temp31 = xsdbool( lv_preload CS `}\n.b` ).
    cl_abap_unit_assert=>assert_true( temp31 ).

    temp32 = xsdbool( lv_preload CS `url("i\\c.png")` ).
    cl_abap_unit_assert=>assert_true( temp32 ).

    " and nothing raw survives next to the escaped copies
    temp33 = xsdbool( lv_preload CS `content: 'x';` ).
    cl_abap_unit_assert=>assert_false( temp33 ).

  ENDMETHOD.

  METHOD test_preload_literals.

    " Every non-.js resource is embedded as a JS single-quoted string literal.
    " On such a line, once the escaped apostrophes are taken out, the only ones
    " left must be the two delimiters - one extra ends its literal early, and
    " that is a syntax error for the whole <script> block, so onInitComponent
    " is never defined and the page stays blank. A UI5 expression binding is
    " the everyday source of such an apostrophe:
    "   title="{= ${/appName} ? 'a' : 'b' }"
    " The .js entries are skipped on purpose: their content is the function
    " body, JavaScript rather than a string, and its apostrophes are its own.
    DATA lt_lines  TYPE string_table.
    DATA lt_quotes TYPE string_table.
    DATA lv_rest   TYPE string.
    DATA lv_checked TYPE i.

    DATA(lv_preload) = z2ui5_cl_ui5f_preload=>get( styles_css = `.a { content: 'x'; }`
                                                  custom_js   = `` ).

    SPLIT lv_preload AT |\n| INTO TABLE lt_lines.

    LOOP AT lt_lines INTO DATA(lv_line).

      IF lv_line NP `      "z2ui5/*": '*',`.
        CONTINUE.
      ENDIF.

      lv_rest = replace( val  = lv_line
                         sub  = `\'`
                         with = ``
                         occ  = 0 ).

      " n separators produce n + 1 parts, so two delimiters leave three parts
      SPLIT lv_rest AT `'` INTO TABLE lt_quotes.
      cl_abap_unit_assert=>assert_equals(
          exp = 3
          act = lines( lt_quotes )
          msg = `a preload text resource carries an unescaped apostrophe` ).

      lv_checked = lv_checked + 1.

    ENDLOOP.

    " guard the guard: the entries have to be there at all
    cl_abap_unit_assert=>assert_differs( exp = 0
                                         act = lv_checked ).

  ENDMETHOD.

ENDCLASS.


" Recording double for the layer-0 HTTP wrapper. set_response( ) and main( )
" talk to the stack only through z2ui5_cl_ui5_util_http, whose methods are
" all redefinable - so the double records what the handler sends (headers,
" status, body) and answers the request headers a test seeded, and the
" response path runs without any ICF stack behind it.
CLASS ltcl_http_mock DEFINITION INHERITING FROM z2ui5_cl_ui5_util_http
  FINAL FOR TESTING.

  PUBLIC SECTION.
    DATA ms_req_info   TYPE ty_s_http_req.
    DATA mt_req_header TYPE z2ui5_if_client=>ty_t_name_value.
    DATA mt_res_header TYPE z2ui5_if_client=>ty_t_name_value.
    DATA mv_cdata      TYPE string.
    DATA mv_status     TYPE i.
    DATA mv_reason     TYPE string.

    METHODS get_req_info           REDEFINITION.
    METHODS get_header_field       REDEFINITION.
    METHODS set_header_field       REDEFINITION.
    METHODS set_cdata              REDEFINITION.
    METHODS set_status             REDEFINITION.
    METHODS set_session_stateful   REDEFINITION.
    METHODS get_response_cookie    REDEFINITION.
    METHODS delete_response_cookie REDEFINITION.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_http_mock IMPLEMENTATION.

  METHOD get_req_info.
    result = ms_req_info.
  ENDMETHOD.

  METHOD get_header_field.
    DATA(lv_name) = to_lower( val ).
    READ TABLE mt_req_header INTO DATA(ls_header) WITH KEY n = lv_name.
    IF sy-subrc = 0.
      result = ls_header-v.
    ENDIF.
  ENDMETHOD.

  METHOD set_header_field.
    " last write wins, like the real stack - replace an existing entry
    DATA(lv_name) = to_lower( n ).
    DELETE mt_res_header WHERE n = lv_name.
    INSERT VALUE #( n = lv_name
                    v = v ) INTO TABLE mt_res_header.
  ENDMETHOD.

  METHOD set_cdata.
    mv_cdata = val.
  ENDMETHOD.

  METHOD set_status.
    mv_status = code.
    mv_reason = reason.
  ENDMETHOD.

  METHOD set_session_stateful.
    " stateless double - nothing to record for these tests
  ENDMETHOD.

  METHOD get_response_cookie.
    CLEAR result.
  ENDMETHOD.

  METHOD delete_response_cookie.
    " no cookie store in the double
  ENDMETHOD.

ENDCLASS.


" Exit stub for the CSRF/forwarded-host tests: the seeded defaults the real
" z2ui5_cl_ui5_user_exit=>set_config_http_post would provide, with the
" trust-forwarded-host switch under test control.
CLASS ltcl_exit_stub DEFINITION FINAL FOR TESTING.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_ui5_exit.
    DATA mv_trust_forwarded TYPE abap_bool.
    " a customer exit whose GET config raises - the shape set_response has
    " to survive (test_exit_get_raises_answers)
    DATA mv_raise_get       TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_exit_stub IMPLEMENTATION.

  METHOD z2ui5_if_ui5_exit~set_config_http_get.
    IF mv_raise_get = abap_true.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING
          val = `EXIT_GET_BROKEN`.
    ENDIF.
    cs_config-theme = `sap_horizon`.
  ENDMETHOD.

  METHOD z2ui5_if_ui5_exit~set_config_http_post.
    cs_config-draft_exp_time_in_hours    = 4.
    cs_config-check_csrf_active          = abap_true.
    cs_config-check_trust_forwarded_host = mv_trust_forwarded.
  ENDMETHOD.

ENDCLASS.


" The exit singleton (gi_me) is PROTECTED class-data of the default exit, so
" a subclass is the smallest door for swapping in the stub above - the tests
" cannot be LOCAL FRIENDS of a class in another pool.
CLASS ltcl_exit_injector DEFINITION INHERITING FROM z2ui5_cl_ui5_user_exit
  FINAL FOR TESTING.

  PUBLIC SECTION.
    CLASS-METHODS inject
      IMPORTING
        ii_exit TYPE REF TO z2ui5_if_ui5_exit.

    CLASS-METHODS reset.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_exit_injector IMPLEMENTATION.

  METHOD inject.
    gi_me = ii_exit.
  ENDMETHOD.

  METHOD reset.
    CLEAR gi_me.
    CLEAR gi_user_exit.
    CLEAR gi_user_exit_dep.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_http_response DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION LONG.

  PRIVATE SECTION.
    DATA mo_handler TYPE REF TO z2ui5_cl_ui5_http_handler.
    DATA mo_mock    TYPE REF TO ltcl_http_mock.

    METHODS setup.
    METHODS teardown.

    "! Reset the per-work-process caches so every test starts from a cold
    "! shell cache and the default exit - and leaves the other test classes
    "! the same state.
    METHODS caches_clear.

    METHODS handler_create.

    METHODS header_value
      IMPORTING
        name          TYPE string
      RETURNING
        VALUE(result) TYPE string.

    "! Run _http_get( ) against exactly this exit config (the per-request
    "! config cache is pre-filled, so the user exit is never asked) and hand
    "! back the shell body; the cache key is read off the class afterwards.
    METHODS shell_for_config
      IMPORTING
        is_config     TYPE z2ui5_if_ui5_exit=>ty_s_http_config
      RETURNING
        VALUE(result) TYPE string.

    METHODS test_cache_key_covers_inputs FOR TESTING RAISING cx_static_check.
    METHODS test_cache_hit_same_config   FOR TESTING RAISING cx_static_check.
    METHODS test_get_304_on_if_none_match FOR TESTING RAISING cx_static_check.
    METHODS test_get_304_weak_tag FOR TESTING RAISING cx_static_check.
    METHODS test_etag_match_rules FOR TESTING RAISING cx_static_check.
    METHODS test_get_no_304_on_stale_tag FOR TESTING RAISING cx_static_check.
    METHODS test_cache_control_post      FOR TESTING RAISING cx_static_check.
    METHODS test_cache_control_error     FOR TESTING RAISING cx_static_check.
    METHODS test_cache_control_head      FOR TESTING RAISING cx_static_check.
    METHODS test_fwd_host_trusted        FOR TESTING RAISING cx_static_check.
    METHODS test_fwd_host_opt_out        FOR TESTING RAISING cx_static_check.
    METHODS test_etag_equal_length       FOR TESTING RAISING cx_static_check.
    METHODS test_etag_position_mix       FOR TESTING RAISING cx_static_check.
    METHODS test_etag_follows_cache_key  FOR TESTING RAISING cx_static_check.
    METHODS test_exit_get_raises_answers FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS z2ui5_cl_ui5_http_handler DEFINITION LOCAL FRIENDS ltcl_test_http_response.

CLASS ltcl_test_http_response IMPLEMENTATION.

  METHOD setup.
    caches_clear( ).
  ENDMETHOD.

  METHOD teardown.
    caches_clear( ).
    ltcl_exit_injector=>reset( ).
  ENDMETHOD.

  METHOD caches_clear.
    CLEAR z2ui5_cl_ui5_http_handler=>ss_config_http_get.
    CLEAR z2ui5_cl_ui5_http_handler=>sv_config_http_get_set.
    CLEAR z2ui5_cl_ui5_http_handler=>sv_get_cache_key.
    CLEAR z2ui5_cl_ui5_http_handler=>sv_get_cache_body.
    CLEAR z2ui5_cl_ui5_http_handler=>sv_get_etag.
  ENDMETHOD.

  METHOD handler_create.
    mo_handler = NEW #( ).
    mo_mock    = NEW #( ).
    mo_handler->mo_server = mo_mock.
  ENDMETHOD.

  METHOD header_value.
    READ TABLE mo_mock->mt_res_header INTO DATA(ls_header) WITH KEY n = name.
    IF sy-subrc = 0.
      result = ls_header-v.
    ENDIF.
  ENDMETHOD.

  METHOD shell_for_config.
    z2ui5_cl_ui5_http_handler=>ss_config_http_get     = is_config.
    z2ui5_cl_ui5_http_handler=>sv_config_http_get_set = abap_true.
    DATA(ls_res) = z2ui5_cl_ui5_http_handler=>_http_get( ).
    result = ls_res-body.
  ENDMETHOD.

  METHOD test_cache_key_covers_inputs.

    " every input the shell body is built from must be part of the cache
    " key: a changed input that leaves the key unchanged would serve the
    " previous page to the whole work process
    DATA(ls_base) = VALUE z2ui5_if_ui5_exit=>ty_s_http_config(
        theme                   = `sap_horizon`
        src                     = `https://sdk.example/sap-ui-core.js`
        content_security_policy = `<meta http-equiv="Content-Security-Policy" content="default-src 'self'"/>` ).

    DATA(lv_body_base) = shell_for_config( ls_base ).
    DATA(lv_key_base)  = z2ui5_cl_ui5_http_handler=>sv_get_cache_key.
    cl_abap_unit_assert=>assert_not_initial( lv_key_base ).

    DATA(ls_config) = ls_base.
    ls_config-theme = `sap_fiori_3`.
    DATA(lv_body) = shell_for_config( ls_config ).
    cl_abap_unit_assert=>assert_differs( exp = lv_key_base
                                         act = z2ui5_cl_ui5_http_handler=>sv_get_cache_key ).
    cl_abap_unit_assert=>assert_differs( exp = lv_body_base
                                         act = lv_body ).

    ls_config = ls_base.
    ls_config-src = `https://other.example/sap-ui-core.js`.
    lv_body = shell_for_config( ls_config ).
    cl_abap_unit_assert=>assert_differs( exp = lv_key_base
                                         act = z2ui5_cl_ui5_http_handler=>sv_get_cache_key ).
    cl_abap_unit_assert=>assert_differs( exp = lv_body_base
                                         act = lv_body ).

    ls_config = ls_base.
    ls_config-content_security_policy = `<meta http-equiv="Content-Security-Policy" content="default-src 'none'"/>`.
    lv_body = shell_for_config( ls_config ).
    cl_abap_unit_assert=>assert_differs( exp = lv_key_base
                                         act = z2ui5_cl_ui5_http_handler=>sv_get_cache_key ).
    cl_abap_unit_assert=>assert_differs( exp = lv_body_base
                                         act = lv_body ).

    ls_config = ls_base.
    ls_config-styles_css = `.z2ui5-test { color: red; }`.
    lv_body = shell_for_config( ls_config ).
    cl_abap_unit_assert=>assert_differs( exp = lv_key_base
                                         act = z2ui5_cl_ui5_http_handler=>sv_get_cache_key ).
    cl_abap_unit_assert=>assert_differs( exp = lv_body_base
                                         act = lv_body ).

    ls_config = ls_base.
    ls_config-custom_js = `console.log(1);`.
    lv_body = shell_for_config( ls_config ).
    cl_abap_unit_assert=>assert_differs( exp = lv_key_base
                                         act = z2ui5_cl_ui5_http_handler=>sv_get_cache_key ).
    cl_abap_unit_assert=>assert_differs( exp = lv_body_base
                                         act = lv_body ).

    ls_config = ls_base.
    ls_config-t_add_config = VALUE #( ( n = `data-sap-ui-language`
                                        v = `EN` ) ).
    lv_body = shell_for_config( ls_config ).
    cl_abap_unit_assert=>assert_differs( exp = lv_key_base
                                         act = z2ui5_cl_ui5_http_handler=>sv_get_cache_key ).
    cl_abap_unit_assert=>assert_differs( exp = lv_body_base
                                         act = lv_body ).

  ENDMETHOD.

  METHOD test_cache_hit_same_config.

    DATA(ls_config) = VALUE z2ui5_if_ui5_exit=>ty_s_http_config(
        theme = `sap_horizon`
        src   = `https://sdk.example/sap-ui-core.js` ).

    shell_for_config( ls_config ).

    " prove the second call is answered from the cache, not rebuilt: plant a
    " sentinel as the cached body - an unchanged key must hand it back
    z2ui5_cl_ui5_http_handler=>sv_get_cache_body = `CACHED_SENTINEL`.
    DATA(lv_body) = shell_for_config( ls_config ).

    cl_abap_unit_assert=>assert_equals( exp = `CACHED_SENTINEL`
                                        act = lv_body ).

  ENDMETHOD.

  METHOD test_get_304_on_if_none_match.

    handler_create( ).
    mo_handler->ms_req-method = `GET`.
    mo_handler->ms_res = VALUE #( body          = `<html>shell</html>`
                                  status_code   = 200
                                  status_reason = `OK` ).
    z2ui5_cl_ui5_http_handler=>sv_get_etag = `"1.0-11-22-33"`.
    INSERT VALUE #( n = `if-none-match`
                    v = `"1.0-11-22-33"` ) INTO TABLE mo_mock->mt_req_header.

    mo_handler->set_response( ).

    " matching validator: bodyless 304 with the ETag and revalidation policy
    cl_abap_unit_assert=>assert_equals( exp = 304
                                        act = mo_mock->mv_status ).
    cl_abap_unit_assert=>assert_initial( mo_mock->mv_cdata ).
    cl_abap_unit_assert=>assert_equals( exp = `"1.0-11-22-33"`
                                        act = header_value( `etag` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `private, no-cache`
                                        act = header_value( `cache-control` ) ).

  ENDMETHOD.

  METHOD test_get_304_weak_tag.

    " the validator as a recompressing proxy hands it back: weak-marked, in
    " a list, with whitespace - still the bodyless 304 of an exact match
    handler_create( ).
    mo_handler->ms_req-method = `GET`.
    mo_handler->ms_res = VALUE #( body          = `<html>shell</html>`
                                  status_code   = 200
                                  status_reason = `OK` ).
    z2ui5_cl_ui5_http_handler=>sv_get_etag = `"1.0-11-22-33"`.
    INSERT VALUE #( n = `if-none-match`
                    v = `"1.0-00-00-00", W/"1.0-11-22-33"` ) INTO TABLE mo_mock->mt_req_header.

    mo_handler->set_response( ).

    cl_abap_unit_assert=>assert_equals( exp = 304
                                        act = mo_mock->mv_status ).
    cl_abap_unit_assert=>assert_initial( mo_mock->mv_cdata ).
    cl_abap_unit_assert=>assert_equals( exp = `"1.0-11-22-33"`
                                        act = header_value( `etag` ) ).

  ENDMETHOD.

  METHOD test_etag_match_rules.

    DATA(lv_tag) = `"1.0-11-22-33"`.

    " exact, weak, listed, any, the Apache suffix - all a match
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_http_handler=>_check_etag_match(
        iv_header = `"1.0-11-22-33"`
        iv_etag   = lv_tag ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_http_handler=>_check_etag_match(
        iv_header = `W/"1.0-11-22-33"`
        iv_etag   = lv_tag ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_http_handler=>_check_etag_match(
        iv_header = `"a" , "1.0-11-22-33" ,"b"`
        iv_etag   = lv_tag ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_http_handler=>_check_etag_match(
        iv_header = `*`
        iv_etag   = lv_tag ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_http_handler=>_check_etag_match(
        iv_header = `"1.0-11-22-33-gzip"`
        iv_etag   = lv_tag ) ).

    " another tag, a tag that merely starts like ours, nothing at all
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_http_handler=>_check_etag_match(
        iv_header = `"1.0-99-99-99"`
        iv_etag   = lv_tag ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_http_handler=>_check_etag_match(
        iv_header = `"1.0-11-22-33-x"`
        iv_etag   = lv_tag ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_http_handler=>_check_etag_match(
        iv_header = ``
        iv_etag   = lv_tag ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_http_handler=>_check_etag_match(
        iv_header = `*`
        iv_etag   = `` ) ).

  ENDMETHOD.

  METHOD test_get_no_304_on_stale_tag.

    handler_create( ).
    mo_handler->ms_req-method = `GET`.
    mo_handler->ms_res = VALUE #( body          = `<html>shell</html>`
                                  status_code   = 200
                                  status_reason = `OK` ).
    z2ui5_cl_ui5_http_handler=>sv_get_etag = `"1.0-11-22-33"`.
    INSERT VALUE #( n = `if-none-match`
                    v = `"1.0-99-99-99"` ) INTO TABLE mo_mock->mt_req_header.

    mo_handler->set_response( ).

    " stale validator: the full 200 travels, carrying the CURRENT tag
    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = mo_mock->mv_status ).
    cl_abap_unit_assert=>assert_equals( exp = `<html>shell</html>`
                                        act = mo_mock->mv_cdata ).
    cl_abap_unit_assert=>assert_equals( exp = `"1.0-11-22-33"`
                                        act = header_value( `etag` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `private, no-cache`
                                        act = header_value( `cache-control` ) ).

  ENDMETHOD.

  METHOD test_cache_control_post.

    handler_create( ).
    mo_handler->ms_req-method = `POST`.
    mo_handler->ms_res = VALUE #( body          = `{}`
                                  status_code   = 200
                                  status_reason = `OK` ).
    " even with a shell tag cached, a POST reply must never carry it
    z2ui5_cl_ui5_http_handler=>sv_get_etag = `"1.0-11-22-33"`.

    mo_handler->set_response( ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = mo_mock->mv_status ).
    cl_abap_unit_assert=>assert_equals( exp = `no-cache, no-store, must-revalidate`
                                        act = header_value( `cache-control` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `no-cache`
                                        act = header_value( `pragma` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `0`
                                        act = header_value( `expires` ) ).
    cl_abap_unit_assert=>assert_initial( header_value( `etag` ) ).

  ENDMETHOD.

  METHOD test_cache_control_error.

    handler_create( ).
    mo_handler->ms_req-method = `GET`.
    mo_handler->ms_res = VALUE #( body          = `Internal Server Error`
                                  status_code   = 500
                                  status_reason = `Internal Server Error` ).
    z2ui5_cl_ui5_http_handler=>sv_get_etag = `"1.0-11-22-33"`.
    INSERT VALUE #( n = `if-none-match`
                    v = `"1.0-11-22-33"` ) INTO TABLE mo_mock->mt_req_header.

    mo_handler->set_response( ).

    " an error body must never be revalidated into staying: no 304, no ETag,
    " the no-store trio
    cl_abap_unit_assert=>assert_equals( exp = 500
                                        act = mo_mock->mv_status ).
    cl_abap_unit_assert=>assert_equals( exp = `no-cache, no-store, must-revalidate`
                                        act = header_value( `cache-control` ) ).
    cl_abap_unit_assert=>assert_initial( header_value( `etag` ) ).

  ENDMETHOD.

  METHOD test_cache_control_head.

    handler_create( ).
    " HEAD is the session-terminate ping, deliberately answered no-store and
    " never through the ETag/304 path - see the HEAD branch in main( )
    mo_handler->ms_req-method = `HEAD`.
    mo_handler->ms_res = VALUE #( status_code   = 200
                                  status_reason = `OK` ).
    z2ui5_cl_ui5_http_handler=>sv_get_etag = `"1.0-11-22-33"`.
    INSERT VALUE #( n = `if-none-match`
                    v = `"1.0-11-22-33"` ) INTO TABLE mo_mock->mt_req_header.

    mo_handler->set_response( ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = mo_mock->mv_status ).
    cl_abap_unit_assert=>assert_equals( exp = `no-cache, no-store, must-revalidate`
                                        act = header_value( `cache-control` ) ).
    cl_abap_unit_assert=>assert_initial( header_value( `etag` ) ).

  ENDMETHOD.

  METHOD test_fwd_host_trusted.

    " default posture: behind a proxy the external authority arrives in
    " X-Forwarded-Host (first entry), and comparing Origin against it lets
    " the legitimate request through although Host names the internal server
    DATA(lo_exit) = NEW ltcl_exit_stub( ).
    lo_exit->mv_trust_forwarded = abap_true.
    ltcl_exit_injector=>inject( lo_exit ).

    handler_create( ).
    mo_mock->ms_req_info = VALUE #( method = `POST`
                                    body   = `{"value":{}}` ).
    mo_mock->mt_req_header = VALUE #( ( n = `origin`
                                        v = `https://portal.corp` )
                                      ( n = `host`
                                        v = `internal.host:8000` )
                                      ( n = `x-forwarded-host`
                                        v = `portal.corp, internal.host:8000` ) ).

    mo_handler->main( ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = mo_mock->mv_status ).

  ENDMETHOD.

  METHOD test_fwd_host_opt_out.

    " hardened posture: an installation without a proxy stops trusting the
    " client-suppliable X-Forwarded-Host via the exit - the same request is
    " then compared against the transport-level Host and rejected
    DATA(lo_exit) = NEW ltcl_exit_stub( ).
    lo_exit->mv_trust_forwarded = abap_false.
    ltcl_exit_injector=>inject( lo_exit ).

    handler_create( ).
    mo_mock->ms_req_info = VALUE #( method = `POST`
                                    body   = `{"value":{}}` ).
    mo_mock->mt_req_header = VALUE #( ( n = `origin`
                                        v = `https://portal.corp` )
                                      ( n = `host`
                                        v = `internal.host:8000` )
                                      ( n = `x-forwarded-host`
                                        v = `portal.corp, internal.host:8000` ) ).

    mo_handler->main( ).

    cl_abap_unit_assert=>assert_equals( exp = 403
                                        act = mo_mock->mv_status ).
    cl_abap_unit_assert=>assert_char_cp( act = mo_mock->mv_cdata
                                         exp = `*CSRF*` ).

  ENDMETHOD.

  METHOD test_etag_equal_length.

    " the tag carries the version constant, the build hash and the byte
    " count, and all three are EQUAL for two exit configs of the same length
    " - so the accumulators alone must separate two different keys of equal
    " length, or a changed config 304s the browser into keeping the old shell
    DATA(lv_tag_a) = z2ui5_cl_ui5_http_handler=>_get_etag( `<html>shell content A</html>` ).
    DATA(lv_tag_b) = z2ui5_cl_ui5_http_handler=>_get_etag( `<html>shell content B</html>` ).

    cl_abap_unit_assert=>assert_not_initial( lv_tag_a ).
    cl_abap_unit_assert=>assert_not_initial( lv_tag_b ).
    cl_abap_unit_assert=>assert_differs( exp = lv_tag_a
                                         act = lv_tag_b ).

    " and the same body twice is the same tag - a validator that drifts on
    " its own input would kill every 304
    cl_abap_unit_assert=>assert_equals(
        exp = lv_tag_a
        act = z2ui5_cl_ui5_http_handler=>_get_etag( `<html>shell content A</html>` ) ).

  ENDMETHOD.

  METHOD test_etag_position_mix.

    " same bytes, different order, equal length - a sum-style validator
    " cannot tell them apart, the position-weighted accumulator must
    DATA(lv_tag_a) = z2ui5_cl_ui5_http_handler=>_get_etag( `abcdefgh` ).
    DATA(lv_tag_b) = z2ui5_cl_ui5_http_handler=>_get_etag( `hgfedcba` ).

    cl_abap_unit_assert=>assert_not_initial( lv_tag_a ).
    cl_abap_unit_assert=>assert_differs( exp = lv_tag_a
                                         act = lv_tag_b ).

  ENDMETHOD.

  METHOD test_etag_follows_cache_key.

    " the tag is derived from the cache key and the build hash, not from
    " the assembled body: it changes with the config, comes back for the
    " same config, and names the embedded frontend's build
    DATA(ls_config_a) = VALUE z2ui5_if_ui5_exit=>ty_s_http_config(
        theme = `sap_horizon`
        src   = `https://sdk.example/sap-ui-core.js` ).
    shell_for_config( ls_config_a ).
    DATA(lv_tag_a) = z2ui5_cl_ui5_http_handler=>sv_get_etag.

    cl_abap_unit_assert=>assert_not_initial( lv_tag_a ).
    cl_abap_unit_assert=>assert_char_cp( act = lv_tag_a
                                         exp = |*-{ z2ui5_cl_ui5f_preload=>build_hash }-*| ).

    DATA(ls_config_b) = ls_config_a.
    ls_config_b-theme = `sap_fiori_3`.
    shell_for_config( ls_config_b ).
    cl_abap_unit_assert=>assert_differs( exp = lv_tag_a
                                         act = z2ui5_cl_ui5_http_handler=>sv_get_etag ).

    shell_for_config( ls_config_a ).
    cl_abap_unit_assert=>assert_equals( exp = lv_tag_a
                                        act = z2ui5_cl_ui5_http_handler=>sv_get_etag ).

  ENDMETHOD.

  METHOD test_exit_get_raises_answers.

    " a customer exit whose set_config_http_get raises: the GET is a 500
    " WITH a status and a body. It used to raise a second time out of
    " set_response( ) - after the outer catch had already produced the 500 -
    " and left the ICF stack to dump with neither.
    DATA(lo_exit) = NEW ltcl_exit_stub( ).
    lo_exit->mv_raise_get = abap_true.
    ltcl_exit_injector=>inject( lo_exit ).

    handler_create( ).
    mo_mock->ms_req_info = VALUE #( method = `GET` ).

    mo_handler->main( ).

    cl_abap_unit_assert=>assert_equals( exp = 500
                                        act = mo_mock->mv_status ).
    cl_abap_unit_assert=>assert_not_initial( mo_mock->mv_cdata ).
    cl_abap_unit_assert=>assert_equals( exp = `text/plain; charset=UTF-8`
                                        act = header_value( `content-type` ) ).

  ENDMETHOD.

ENDCLASS.
