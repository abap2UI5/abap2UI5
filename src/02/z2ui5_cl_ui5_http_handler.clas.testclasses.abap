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
