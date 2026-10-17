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
    METHODS test_post_no_body      FOR TESTING RAISING cx_static_check.
    METHODS test_post_blank_body   FOR TESTING RAISING cx_static_check.
    METHODS test_csrf_inactive     FOR TESTING RAISING cx_static_check.
    METHODS test_csrf_same_origin  FOR TESTING RAISING cx_static_check.
    METHODS test_csrf_cross_origin FOR TESTING RAISING cx_static_check.
    METHODS test_csrf_no_headers   FOR TESTING RAISING cx_static_check.
    METHODS test_csrf_referer      FOR TESTING RAISING cx_static_check.
    METHODS test_csrf_default_port FOR TESTING RAISING cx_static_check.
    METHODS test_preload_literals  FOR TESTING RAISING cx_static_check.
    " GET ?z2ui5-bundle is the frontend as a script, every other GET the page
    METHODS test_main_get_bundle   FOR TESTING RAISING cx_static_check.
    METHODS test_main_get_bundle_path FOR TESTING RAISING cx_static_check.
    METHODS test_main_get_no_bundle FOR TESTING RAISING cx_static_check.
    " GET ?z2ui5-bundle=devtools is the developer tools as a script; the
    " page's own ?z2ui5-devtools (the auto open) stays the page
    METHODS test_main_get_devtools  FOR TESTING RAISING cx_static_check.
    METHODS test_devtools_not_in_shell FOR TESTING RAISING cx_static_check.
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


    temp1 = boolc( ls_result-body CS `<!DOCTYPE html>` ).
    cl_abap_unit_assert=>assert_true( temp1 ).


    temp2 = boolc( ls_result-body CS `<html` ).
    cl_abap_unit_assert=>assert_true( temp2 ).


    temp3 = boolc( ls_result-body CS `</html>` ).
    cl_abap_unit_assert=>assert_true( temp3 ).

  ENDMETHOD.

  METHOD test_http_get_ui5_boot.

    DATA ls_result TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_res.
    DATA temp4 TYPE xsdboolean.
    DATA temp5 TYPE xsdboolean.

    ls_result = z2ui5_cl_ui5_http_handler=>_http_get( ).


    temp4 = boolc( ls_result-body CS `sap-ui-bootstrap` ).
    cl_abap_unit_assert=>assert_true( temp4 ).


    temp5 = boolc( ls_result-body CS `z2ui5` ).
    cl_abap_unit_assert=>assert_true( temp5 ).

  ENDMETHOD.

  METHOD test_http_get_title.

    " The tab title is constant: the exit has no title field any more, and an
    " app that wants its own title sets it while it runs, with
    " cs_event-set_title. Pinned as the literal tag, because a <title> holding
    " whatever the exit happened to assign is exactly what changed here - and
    " an empty one would leave the URL in the tab during the UI5 boot.

    DATA ls_result TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_res.
    DATA temp6 TYPE xsdboolean.

    ls_result = z2ui5_cl_ui5_http_handler=>_http_get( ).


    temp6 = boolc( ls_result-body CS `<title>abap2UI5</title>` ).
    cl_abap_unit_assert=>assert_true( temp6 ).

  ENDMETHOD.

  METHOD test_http_post_ok.

    DATA ls_req TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_req.
    DATA ls_result TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_res.
    DATA temp7 TYPE xsdboolean.

    ls_req-method = `POST`.
    ls_req-body = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":""}}}`.

    ls_result = z2ui5_cl_ui5_http_handler=>_http_post( ls_req ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = ls_result-status_code ).


    temp7 = boolc( ls_result-body CS `S_FRONT` ).
    cl_abap_unit_assert=>assert_true( temp7 ).

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

  METHOD test_post_no_body.

    " ...and a POST with NO body at all is the same request: it names no
    " S_FRONT either, so it takes the same system-startup path. It used to
    " reach the JSON parse, which refuses an empty string, so the
    " availability probe a monitor or a load balancer sends was answered
    " with the framework's own 500 - while `{}`, `null` and even `42` all
    " rendered the start page. node/srv/express.mjs produces exactly this
    " shape (an empty buffer for a missing body)
    DATA ls_req TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_req.
    DATA ls_result TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_res.

    ls_req-method = `POST`.

    ls_result = z2ui5_cl_ui5_http_handler=>_main( ls_req ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = ls_result-status_code ).

  ENDMETHOD.

  METHOD test_post_blank_body.

    " a body of blanks is the same thing one proxy further on
    DATA ls_req TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_req.
    DATA ls_result TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_res.

    ls_req-method = `POST`.
    ls_req-body = `   `.

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


    temp8 = boolc( ls_result-body CS `<!DOCTYPE html>` ).
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
    DATA lv_rejected TYPE abap_bool.
    lv_rejected = z2ui5_cl_ui5_http_handler=>_check_csrf_rejected(
                            active  = abap_false
                            origin  = `https://evil.example.com`
                            referer = ``
                            host    = `app.corp:44300` ).

    cl_abap_unit_assert=>assert_false( lv_rejected ).

  ENDMETHOD.

  METHOD test_csrf_same_origin.

    " same host authority (scheme/case ignored) -> allowed
    DATA lv_rejected TYPE abap_bool.
    lv_rejected = z2ui5_cl_ui5_http_handler=>_check_csrf_rejected(
                            active  = abap_true
                            origin  = `https://App.Corp:44300`
                            referer = ``
                            host    = `app.corp:44300` ).

    cl_abap_unit_assert=>assert_false( lv_rejected ).

  ENDMETHOD.

  METHOD test_csrf_cross_origin.

    " different host authority -> rejected
    DATA lv_rejected TYPE abap_bool.
    lv_rejected = z2ui5_cl_ui5_http_handler=>_check_csrf_rejected(
                            active  = abap_true
                            origin  = `https://evil.example.com`
                            referer = ``
                            host    = `app.corp:44300` ).

    cl_abap_unit_assert=>assert_true( lv_rejected ).

  ENDMETHOD.

  METHOD test_csrf_no_headers.

    " lenient: no Origin and no Referer -> allowed (proxies / old clients)
    DATA lv_rejected TYPE abap_bool.
    lv_rejected = z2ui5_cl_ui5_http_handler=>_check_csrf_rejected(
                            active  = abap_true
                            origin  = ``
                            referer = ``
                            host    = `app.corp:44300` ).

    cl_abap_unit_assert=>assert_false( lv_rejected ).

  ENDMETHOD.

  METHOD test_csrf_referer.

    " Origin absent -> fall back to Referer (with a path), cross-site -> rejected
    DATA lv_rejected TYPE abap_bool.
    lv_rejected = z2ui5_cl_ui5_http_handler=>_check_csrf_rejected(
                            active  = abap_true
                            origin  = ``
                            referer = `https://evil.example.com/attack?x=1`
                            host    = `app.corp:44300` ).

    cl_abap_unit_assert=>assert_true( lv_rejected ).

  ENDMETHOD.

  METHOD test_csrf_default_port.

    " the port a scheme implies is no difference in authority: the browser
    " writes the Origin without it, a proxy forwards the Host with it
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_http_handler=>_check_csrf_rejected(
                            active  = abap_true
                            origin  = `https://app.corp`
                            referer = ``
                            host    = `app.corp:443` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_http_handler=>_check_csrf_rejected(
                            active  = abap_true
                            origin  = `http://app.corp:80`
                            referer = ``
                            host    = `app.corp` ) ).
    " ...while a real port still counts
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_http_handler=>_check_csrf_rejected(
                            active  = abap_true
                            origin  = `https://app.corp:8443`
                            referer = ``
                            host    = `app.corp` ) ).
    " and a host that merely ENDS in the digits is not a default port
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_http_handler=>_check_csrf_rejected(
                            active  = abap_true
                            origin  = `https://App443/x`
                            referer = ``
                            host    = `app443` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_http_handler=>_check_csrf_rejected(
                            active  = abap_true
                            origin  = `https://app443`
                            referer = ``
                            host    = `app` ) ).

  ENDMETHOD.

  " The next test exercises z2ui5_cl_ui5f_preload rather than this class.
  " That class is generated (see tools/app2abap/trans2abap.js) and its
  " package is wiped on every regeneration, so it cannot carry a test include
  " of its own - and _http_get( ) above is the consumer that breaks: it drops
  " the preload into the one <script> block that defines onInitComponent.

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

    DATA lv_preload TYPE string.
    DATA lv_line LIKE LINE OF lt_lines.
    lv_preload = z2ui5_cl_ui5f_preload=>get( ).

    SPLIT lv_preload AT |\n| INTO TABLE lt_lines.


    LOOP AT lt_lines INTO lv_line.

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

  METHOD test_main_get_bundle.

    DATA temp1 TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_req.
    DATA temp2 TYPE z2ui5_if_client=>ty_t_name_value.
    DATA temp3 LIKE LINE OF temp2.
    DATA ls_result TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_res.
    DATA temp9 TYPE xsdboolean.
    DATA temp10 TYPE xsdboolean.
    DATA temp11 TYPE xsdboolean.
    DATA temp12 TYPE xsdboolean.
    DATA temp13 TYPE xsdboolean.
    DATA temp14 TYPE xsdboolean.
    DATA temp15 TYPE xsdboolean.
    DATA temp16 TYPE xsdboolean.
    DATA temp17 TYPE xsdboolean.
    DATA temp18 TYPE xsdboolean.
    DATA temp19 TYPE xsdboolean.
    DATA temp20 TYPE xsdboolean.
    CLEAR temp1.
    temp1-method = `GET`.
    temp1-path = `/sap/bc/z2ui5`.

    CLEAR temp2.

    temp3-n = `z2ui5-bundle`.
    INSERT temp3 INTO TABLE temp2.
    temp1-t_params = temp2.

    ls_result = z2ui5_cl_ui5_http_handler=>_main( temp1 ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = ls_result-status_code ).
    " the page's preload registration and nothing of the page around it

    temp9 = boolc( find( val = ls_result-body sub = z2ui5_cl_ui5f_preload=>get_bundle( ) ) = 0 ).
    cl_abap_unit_assert=>assert_true(
        temp9 ).

    temp10 = boolc( ls_result-body CS `"z2ui5/Component.js": function()` ).
    cl_abap_unit_assert=>assert_true(
        temp10 ).
    " ...the component a second time, under the name the control creates it
    " by when the page's own component is z2ui5 (abap2UI5/frontend, the
    " branches standard_new and cloud_new)

    temp11 = boolc( ls_result-body CS `"z2ui5/embed/frontend/Component.js": entries["z2ui5/Component.js"]` ).
    cl_abap_unit_assert=>assert_true(
        temp11 ).

    temp12 = boolc( ls_result-body CS `componentName: "z2ui5.embed.frontend",` ).
    cl_abap_unit_assert=>assert_true(
        temp12 ).

    temp13 = boolc( ls_result-body CS `<!DOCTYPE` ).
    cl_abap_unit_assert=>assert_false( temp13 ).

    temp14 = boolc( ls_result-body CS `onInitComponent` ).
    cl_abap_unit_assert=>assert_false( temp14 ).

    temp15 = boolc( ls_result-body CS `ComponentSupport` ).
    cl_abap_unit_assert=>assert_false( temp15 ).
    " ...and the module the embedding page recognises it by, with the
    " sibling BSPs the page itself hands the component as well

    temp16 = boolc( ls_result-body CS `sap.ui.define("z2ui5/embed", function () {` ).
    cl_abap_unit_assert=>assert_true(
        temp16 ).

    temp17 = boolc( ls_result-body CS `ccResourceRoot: "/sap/bc/ui5_ui5/sap/z2ui5_cci",` ).
    cl_abap_unit_assert=>assert_true(
        temp17 ).

    temp18 = boolc( ls_result-body CS `cccResourceRoot: "/sap/bc/ui5_ui5/sap/z2ui5_ccc"` ).
    cl_abap_unit_assert=>assert_true(
        temp18 ).
    " ...and that the page is the embedding page's, not the component's: the
    " router leaves its hash alone (a Fiori elements host routes by it)

    temp19 = boolc( ls_result-body CS `embedded: true,` ).
    cl_abap_unit_assert=>assert_true(
        temp19 ).
    " ...and the path the node has on the system, for a page that reaches
    " it through a proxy's prefix (Component.init rebases the roots by it)

    temp20 = boolc( ls_result-body CS `nodePath: "/sap/bc/z2ui5",` ).
    cl_abap_unit_assert=>assert_true(
        temp20 ).

  ENDMETHOD.

  METHOD test_main_get_bundle_path.

    " the path reaches the module as it came - a node under another name, a
    " trailing slash - so the embedding page can compare it with the
    " endpoint it loaded the bundle from
    DATA temp2 TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_req.
    DATA temp5 TYPE z2ui5_if_client=>ty_t_name_value.
    DATA temp6 LIKE LINE OF temp5.
    DATA ls_result TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_res.
    DATA temp21 TYPE xsdboolean.
    DATA temp3 TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_req.
    DATA temp7 TYPE z2ui5_if_client=>ty_t_name_value.
    DATA temp8 LIKE LINE OF temp7.
    DATA temp22 TYPE xsdboolean.
    DATA temp4 TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_req.
    DATA temp9 TYPE z2ui5_if_client=>ty_t_name_value.
    DATA temp10 LIKE LINE OF temp9.
    DATA temp23 TYPE xsdboolean.
    DATA temp24 TYPE xsdboolean.
    CLEAR temp2.
    temp2-method = `GET`.
    temp2-path = `/sap/bc/z2ui5_other/`.

    CLEAR temp5.

    temp6-n = `z2ui5-bundle`.
    INSERT temp6 INTO TABLE temp5.
    temp2-t_params = temp5.

    ls_result = z2ui5_cl_ui5_http_handler=>_main( temp2 ).

    temp21 = boolc( ls_result-body CS `nodePath: "/sap/bc/z2ui5_other/",` ).
    cl_abap_unit_assert=>assert_true(
        temp21 ).

    " a stack that reports no path - a direct call, a shim without the
    " header - leaves the field empty rather than out; Component.init reads
    " an empty one as none and keeps the roots as they are

    CLEAR temp3.
    temp3-method = `GET`.

    CLEAR temp7.

    temp8-n = `z2ui5-bundle`.
    INSERT temp8 INTO TABLE temp7.
    temp3-t_params = temp7.
    ls_result = z2ui5_cl_ui5_http_handler=>_main( temp3 ).

    temp22 = boolc( ls_result-body CS `nodePath: "",` ).
    cl_abap_unit_assert=>assert_true(
        temp22 ).

    " the path is what the stack reports of the request URL, and an ICF node
    " matches on its prefix - what could end the string literal of a script
    " the host's page runs cannot

    CLEAR temp4.
    temp4-method = `GET`.
    temp4-path = `/sap/bc/z2ui5/a"b\c</script>`.

    CLEAR temp9.

    temp10-n = `z2ui5-bundle`.
    INSERT temp10 INTO TABLE temp9.
    temp4-t_params = temp9.
    ls_result = z2ui5_cl_ui5_http_handler=>_main( temp4 ).

    temp23 = boolc( ls_result-body CS `nodePath: "/sap/bc/z2ui5/a\"b\\c<\/script>",` ).
    cl_abap_unit_assert=>assert_true(
        temp23 ).

    temp24 = boolc( ls_result-body CS `a"b\c</script>` ).
    cl_abap_unit_assert=>assert_false(
        temp24 ).

  ENDMETHOD.

  METHOD test_main_get_devtools.

    DATA temp5 TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_req.
    DATA temp11 TYPE z2ui5_if_client=>ty_t_name_value.
    DATA temp12 LIKE LINE OF temp11.
    DATA ls_result TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_res.
    DATA temp25 TYPE xsdboolean.
    DATA temp26 TYPE xsdboolean.
    DATA temp27 TYPE xsdboolean.
    DATA temp28 TYPE xsdboolean.
    DATA temp29 TYPE xsdboolean.
    DATA temp30 TYPE xsdboolean.
    DATA temp6 TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_req.
    DATA temp13 TYPE z2ui5_if_client=>ty_t_name_value.
    DATA temp14 LIKE LINE OF temp13.
    DATA temp31 TYPE xsdboolean.
    DATA temp7 TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_req.
    DATA temp15 TYPE z2ui5_if_client=>ty_t_name_value.
    DATA temp16 LIKE LINE OF temp15.
    DATA temp32 TYPE xsdboolean.
    CLEAR temp5.
    temp5-method = `GET`.
    temp5-path = `/sap/bc/z2ui5`.

    CLEAR temp11.

    temp12-n = `z2ui5-bundle`.
    temp12-v = `devtools`.
    INSERT temp12 INTO TABLE temp11.
    temp5-t_params = temp11.

    ls_result = z2ui5_cl_ui5_http_handler=>_main( temp5 ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = ls_result-status_code ).
    " the devtools bundle, as generated, and nothing of the page or of the
    " embed module around it
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_ui5f_preload=>get_devtools( )
                                        act = ls_result-body ).

    temp25 = boolc( ls_result-body CS `"z2ui5/devtools/DeveloperTools.js": function()` ).
    cl_abap_unit_assert=>assert_true(
        temp25 ).

    temp26 = boolc( ls_result-body CS `"z2ui5/devtools/DeveloperTools.fragment.xml": '` ).
    cl_abap_unit_assert=>assert_true(
        temp26 ).

    temp27 = boolc( ls_result-body CS `<!DOCTYPE` ).
    cl_abap_unit_assert=>assert_false( temp27 ).

    temp28 = boolc( ls_result-body CS `z2ui5/embed` ).
    cl_abap_unit_assert=>assert_false( temp28 ).
    " the eager half of the tools is the shell's, not the bundle's

    temp29 = boolc( ls_result-body CS `"z2ui5/devtools/DevTools.js"` ).
    cl_abap_unit_assert=>assert_false(
        temp29 ).

    temp30 = boolc( ls_result-body CS `"z2ui5/devtools/Recorder.js"` ).
    cl_abap_unit_assert=>assert_false(
        temp30 ).

    " the page's auto-open parameter is not the bundle's

    CLEAR temp6.
    temp6-method = `GET`.
    temp6-path = `/sap/bc/z2ui5`.

    CLEAR temp13.

    temp14-n = `z2ui5-devtools`.
    temp14-v = `1`.
    INSERT temp14 INTO TABLE temp13.
    temp6-t_params = temp13.
    ls_result = z2ui5_cl_ui5_http_handler=>_main( temp6 ).

    temp31 = boolc( ls_result-body CS `<!DOCTYPE html>` ).
    cl_abap_unit_assert=>assert_true( temp31 ).

    " any other value of the parameter is the frontend bundle

    CLEAR temp7.
    temp7-method = `GET`.
    temp7-path = `/sap/bc/z2ui5`.

    CLEAR temp15.

    temp16-n = `z2ui5-bundle`.
    temp16-v = `x`.
    INSERT temp16 INTO TABLE temp15.
    temp7-t_params = temp15.
    ls_result = z2ui5_cl_ui5_http_handler=>_main( temp7 ).

    temp32 = boolc( ls_result-body CS `sap.ui.define("z2ui5/embed", function () {` ).
    cl_abap_unit_assert=>assert_true(
        temp32 ).

  ENDMETHOD.

  METHOD test_devtools_not_in_shell.

    " the shell's inline script and the frontend bundle carry the eager
    " half of the developer tools and none of the bundled files - and the
    " devtools bundle carries exactly the rest, under its own digest
    DATA lv_shell TYPE string.
    DATA lv_bundle TYPE string.
    DATA temp33 TYPE xsdboolean.
    DATA temp34 TYPE xsdboolean.
    DATA temp35 TYPE xsdboolean.
    DATA temp36 TYPE xsdboolean.
    DATA temp37 TYPE xsdboolean.
    DATA temp38 TYPE xsdboolean.
    DATA temp39 TYPE xsdboolean.
    lv_shell  = z2ui5_cl_ui5f_preload=>get( ).

    lv_bundle = z2ui5_cl_ui5f_preload=>get_bundle( ).

    temp33 = boolc( lv_shell CS `"z2ui5/devtools/DevTools.js"` ).
    cl_abap_unit_assert=>assert_true( temp33 ).

    temp34 = boolc( lv_shell CS `"z2ui5/devtools/Console.js"` ).
    cl_abap_unit_assert=>assert_true( temp34 ).

    temp35 = boolc( lv_shell CS `"z2ui5/devtools/Recorder.js"` ).
    cl_abap_unit_assert=>assert_true( temp35 ).

    temp36 = boolc( lv_shell CS `"z2ui5/devtools/DeveloperTools.js"` ).
    cl_abap_unit_assert=>assert_false( temp36 ).

    temp37 = boolc( lv_shell CS `"z2ui5/devtools/Picker.js"` ).
    cl_abap_unit_assert=>assert_false( temp37 ).

    temp38 = boolc( lv_bundle CS `"z2ui5/devtools/DeveloperTools.js"` ).
    cl_abap_unit_assert=>assert_false( temp38 ).

    temp39 = boolc( lv_bundle CS `"z2ui5/devtools/DevTools.js"` ).
    cl_abap_unit_assert=>assert_true( temp39 ).
    cl_abap_unit_assert=>assert_not_initial( z2ui5_cl_ui5f_preload=>devtools_hash ).
    cl_abap_unit_assert=>assert_differs( exp = z2ui5_cl_ui5f_preload=>build_hash
                                         act = z2ui5_cl_ui5f_preload=>devtools_hash ).

  ENDMETHOD.

  METHOD test_main_get_no_bundle.

    " any other parameter - an app_start above all - keeps the page: the node
    " stays the direct way into abap2UI5
    DATA temp8 TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_req.
    DATA temp17 TYPE z2ui5_if_client=>ty_t_name_value.
    DATA temp18 LIKE LINE OF temp17.
    DATA ls_result TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_res.
    DATA temp40 TYPE xsdboolean.
    DATA temp41 TYPE xsdboolean.
    CLEAR temp8.
    temp8-method = `GET`.

    CLEAR temp17.

    temp18-n = `app_start`.
    temp18-v = `z2ui5_cl_ui5_app_hi_world`.
    INSERT temp18 INTO TABLE temp17.
    temp8-t_params = temp17.

    ls_result = z2ui5_cl_ui5_http_handler=>_main( temp8 ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = ls_result-status_code ).

    temp40 = boolc( ls_result-body CS `<!DOCTYPE html>` ).
    cl_abap_unit_assert=>assert_true( temp40 ).

    temp41 = boolc( ls_result-body CS `z2ui5/embed` ).
    cl_abap_unit_assert=>assert_false( temp41 ).

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
    " the contextid handover: the cookie the stack would have set, whether
    " the handler took it off again, and what it asked for statefulness
    DATA mv_res_cookie     TYPE string.
    DATA mv_cookie_deleted TYPE abap_bool.
    DATA mv_stateful       TYPE i.
    DATA mv_stateful_set   TYPE abap_bool.

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
    DATA lv_name TYPE string.
    DATA ls_header TYPE z2ui5_if_client=>ty_s_name_value.
    lv_name = to_lower( val ).

    READ TABLE mt_req_header INTO ls_header WITH KEY n = lv_name.
    IF sy-subrc = 0.
      result = ls_header-v.
    ENDIF.
  ENDMETHOD.

  METHOD set_header_field.
    " last write wins, like the real stack - replace an existing entry
    DATA lv_name TYPE string.
    DATA temp9 TYPE z2ui5_if_client=>ty_s_name_value.
    lv_name = to_lower( n ).
    DELETE mt_res_header WHERE n = lv_name.

    CLEAR temp9.
    temp9-n = lv_name.
    temp9-v = v.
    INSERT temp9 INTO TABLE mt_res_header.
  ENDMETHOD.

  METHOD set_cdata.
    mv_cdata = val.
  ENDMETHOD.

  METHOD set_status.
    mv_status = code.
    mv_reason = reason.
  ENDMETHOD.

  METHOD set_session_stateful.
    mv_stateful     = val.
    mv_stateful_set = abap_true.
  ENDMETHOD.

  METHOD get_response_cookie.
    IF to_lower( val ) = `sap-contextid`.
      result = mv_res_cookie.
    ENDIF.
  ENDMETHOD.

  METHOD delete_response_cookie.
    IF to_lower( val ) = `sap-contextid`.
      CLEAR mv_res_cookie.
      mv_cookie_deleted = abap_true.
    ENDIF.
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


" the server object an ICF handler hands over, reduced to what factory( )
" reads from it: a RESPONSE attribute. The request side is not touched by
" factory( ) itself
CLASS ltcl_server_shape DEFINITION FINAL.
  PUBLIC SECTION.
    DATA response TYPE REF TO object.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_server_shape IMPLEMENTATION.
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
    METHODS test_get_no_304_on_stale_tag FOR TESTING RAISING cx_static_check.
    METHODS test_cache_control_post      FOR TESTING RAISING cx_static_check.
    METHODS test_cache_control_error     FOR TESTING RAISING cx_static_check.
    METHODS test_cache_control_head      FOR TESTING RAISING cx_static_check.
    " the two HEADs: only the terminate ping ends the stateful session, the
    " X-CSRF-Token fetch a token layer forwards leaves it running
    METHODS test_head_terminate_ping     FOR TESTING RAISING cx_static_check.
    METHODS test_head_token_fetch_keeps  FOR TESTING RAISING cx_static_check.
    METHODS test_fwd_host_trusted        FOR TESTING RAISING cx_static_check.
    " the contextid handover, cookie -> header and back
    METHODS test_ctxid_cookie_to_header  FOR TESTING RAISING cx_static_check.
    METHODS test_ctxid_cookie_kept       FOR TESTING RAISING cx_static_check.
    METHODS test_ctxid_echoed            FOR TESTING RAISING cx_static_check.
    METHODS test_ctxid_absent_no_header  FOR TESTING RAISING cx_static_check.
    METHODS test_fwd_host_opt_out        FOR TESTING RAISING cx_static_check.
    METHODS test_etag_equal_length       FOR TESTING RAISING cx_static_check.
    METHODS test_etag_position_mix       FOR TESTING RAISING cx_static_check.
    METHODS test_etag_follows_cache_key  FOR TESTING RAISING cx_static_check.
    METHODS test_exit_get_raises_answers FOR TESTING RAISING cx_static_check.
    METHODS test_get_304_skips_build     FOR TESTING RAISING cx_static_check.
    METHODS test_get_stale_tag_builds    FOR TESTING RAISING cx_static_check.
    METHODS test_get_304_end_to_end      FOR TESTING RAISING cx_static_check.
    METHODS test_etag_after_304_of_other FOR TESTING RAISING cx_static_check.
    " the inline script of the shell is allowed by its hash, not by
    " 'unsafe-inline' - see _csp_add_script_hash
    METHODS test_csp_hash_default        FOR TESTING RAISING cx_static_check.
    METHODS test_csp_hash_unsafe_inline  FOR TESTING RAISING cx_static_check.
    METHODS test_csp_hash_directives     FOR TESTING RAISING cx_static_check.
    METHODS test_csp_hash_header_value   FOR TESTING RAISING cx_static_check.
    METHODS test_csp_hash_once           FOR TESTING RAISING cx_static_check.
    METHODS test_csp_hash_security_hdr   FOR TESTING RAISING cx_static_check.
    METHODS test_shell_script_is_preload FOR TESTING RAISING cx_static_check.
    METHODS test_style_exit_element      FOR TESTING RAISING cx_static_check.
    " the preconnect to the UI5 origin: for an absolute src only, outside
    " the hashed script
    METHODS test_preconnect_cdn          FOR TESTING RAISING cx_static_check.
    METHODS test_preconnect_relative     FOR TESTING RAISING cx_static_check.
    " the bundle: sent as JavaScript under a tag of its own, revalidated to a
    " bodyless 304, and without touching the page's tag
    METHODS test_bundle_response         FOR TESTING RAISING cx_static_check.
    METHODS test_bundle_304              FOR TESTING RAISING cx_static_check.
    " the devtools bundle: the same headers, a tag of its own that is not
    " the frontend bundle's
    METHODS test_devtools_response       FOR TESTING RAISING cx_static_check.
    METHODS test_devtools_304            FOR TESTING RAISING cx_static_check.
    METHODS test_factory_onprem      FOR TESTING RAISING cx_static_check.
    METHODS test_factory_cloud       FOR TESTING RAISING cx_static_check.
    METHODS test_factory_nothing     FOR TESTING RAISING cx_static_check.
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
    CLEAR z2ui5_cl_ui5_http_handler=>sv_get_etag_key.
    CLEAR z2ui5_cl_ui5_http_handler=>sv_if_none_match.
  ENDMETHOD.

  METHOD handler_create.
    CREATE OBJECT mo_handler.
    CREATE OBJECT mo_mock.
    mo_handler->mo_server = mo_mock.
  ENDMETHOD.

  METHOD header_value.
    DATA ls_header TYPE z2ui5_if_client=>ty_s_name_value.
    READ TABLE mo_mock->mt_res_header INTO ls_header WITH KEY n = name.
    IF sy-subrc = 0.
      result = ls_header-v.
    ENDIF.
  ENDMETHOD.

  METHOD shell_for_config.
    DATA ls_res TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_res.
    z2ui5_cl_ui5_http_handler=>ss_config_http_get     = is_config.
    z2ui5_cl_ui5_http_handler=>sv_config_http_get_set = abap_true.

    ls_res = z2ui5_cl_ui5_http_handler=>_http_get( ).
    result = ls_res-body.
  ENDMETHOD.

  METHOD test_cache_key_covers_inputs.

    " every input the shell body is built from must be part of the cache
    " key: a changed input that leaves the key unchanged would serve the
    " previous page to the whole work process
    DATA temp10 TYPE z2ui5_if_ui5_exit=>ty_s_http_config.
    DATA ls_base LIKE temp10.
    DATA lv_body_base TYPE string.
    DATA lv_key_base LIKE z2ui5_cl_ui5_http_handler=>sv_get_cache_key.
    DATA ls_config LIKE ls_base.
    DATA lv_body TYPE string.
    DATA temp11 TYPE z2ui5_if_client=>ty_t_name_value.
    DATA temp12 LIKE LINE OF temp11.
    CLEAR temp10.
    temp10-theme = `sap_horizon`.
    temp10-src = `https://sdk.example/sap-ui-core.js`.
    temp10-content_security_policy = `<meta http-equiv="Content-Security-Policy" content="default-src 'self'"/>`.

    ls_base = temp10.


    lv_body_base = shell_for_config( ls_base ).

    lv_key_base = z2ui5_cl_ui5_http_handler=>sv_get_cache_key.
    cl_abap_unit_assert=>assert_not_initial( lv_key_base ).


    ls_config = ls_base.
    ls_config-theme = `sap_fiori_3`.

    lv_body = shell_for_config( ls_config ).
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

    CLEAR temp11.

    temp12-n = `data-sap-ui-language`.
    temp12-v = `EN`.
    INSERT temp12 INTO TABLE temp11.
    ls_config-t_add_config = temp11.
    lv_body = shell_for_config( ls_config ).
    cl_abap_unit_assert=>assert_differs( exp = lv_key_base
                                         act = z2ui5_cl_ui5_http_handler=>sv_get_cache_key ).
    cl_abap_unit_assert=>assert_differs( exp = lv_body_base
                                         act = lv_body ).

  ENDMETHOD.

  METHOD test_cache_hit_same_config.

    DATA temp13 TYPE z2ui5_if_ui5_exit=>ty_s_http_config.
    DATA ls_config LIKE temp13.
    DATA lv_body TYPE string.
    CLEAR temp13.
    temp13-theme = `sap_horizon`.
    temp13-src = `https://sdk.example/sap-ui-core.js`.

    ls_config = temp13.

    shell_for_config( ls_config ).

    " prove the second call is answered from the cache, not rebuilt: plant a
    " sentinel as the cached body - an unchanged key must hand it back
    z2ui5_cl_ui5_http_handler=>sv_get_cache_body = `CACHED_SENTINEL`.

    lv_body = shell_for_config( ls_config ).

    cl_abap_unit_assert=>assert_equals( exp = `CACHED_SENTINEL`
                                        act = lv_body ).

  ENDMETHOD.

  METHOD test_get_304_on_if_none_match.
    DATA temp14 TYPE z2ui5_if_client=>ty_s_name_value.

    handler_create( ).
    mo_handler->ms_req-method = `GET`.
    CLEAR mo_handler->ms_res.
    mo_handler->ms_res-body = `<html>shell</html>`.
    mo_handler->ms_res-status_code = 200.
    mo_handler->ms_res-status_reason = `OK`.
    z2ui5_cl_ui5_http_handler=>sv_get_etag = `"1.0-11-22-33"`.

    CLEAR temp14.
    temp14-n = `if-none-match`.
    temp14-v = `"1.0-11-22-33"`.
    INSERT temp14 INTO TABLE mo_mock->mt_req_header.

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
    DATA temp15 TYPE z2ui5_if_client=>ty_s_name_value.

    " the validator as a recompressing proxy hands it back: weak-marked, in
    " a list, with whitespace - still the bodyless 304 of an exact match
    handler_create( ).
    mo_handler->ms_req-method = `GET`.
    CLEAR mo_handler->ms_res.
    mo_handler->ms_res-body = `<html>shell</html>`.
    mo_handler->ms_res-status_code = 200.
    mo_handler->ms_res-status_reason = `OK`.
    z2ui5_cl_ui5_http_handler=>sv_get_etag = `"1.0-11-22-33"`.

    CLEAR temp15.
    temp15-n = `if-none-match`.
    temp15-v = `"1.0-00-00-00", W/"1.0-11-22-33"`.
    INSERT temp15 INTO TABLE mo_mock->mt_req_header.

    mo_handler->set_response( ).

    cl_abap_unit_assert=>assert_equals( exp = 304
                                        act = mo_mock->mv_status ).
    cl_abap_unit_assert=>assert_initial( mo_mock->mv_cdata ).
    cl_abap_unit_assert=>assert_equals( exp = `"1.0-11-22-33"`
                                        act = header_value( `etag` ) ).

  ENDMETHOD.

  METHOD test_get_no_304_on_stale_tag.
    DATA temp16 TYPE z2ui5_if_client=>ty_s_name_value.

    handler_create( ).
    mo_handler->ms_req-method = `GET`.
    CLEAR mo_handler->ms_res.
    mo_handler->ms_res-body = `<html>shell</html>`.
    mo_handler->ms_res-status_code = 200.
    mo_handler->ms_res-status_reason = `OK`.
    z2ui5_cl_ui5_http_handler=>sv_get_etag = `"1.0-11-22-33"`.

    CLEAR temp16.
    temp16-n = `if-none-match`.
    temp16-v = `"1.0-99-99-99"`.
    INSERT temp16 INTO TABLE mo_mock->mt_req_header.

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
    CLEAR mo_handler->ms_res.
    mo_handler->ms_res-body = `{}`.
    mo_handler->ms_res-status_code = 200.
    mo_handler->ms_res-status_reason = `OK`.
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
    DATA temp17 TYPE z2ui5_if_client=>ty_s_name_value.

    handler_create( ).
    mo_handler->ms_req-method = `GET`.
    CLEAR mo_handler->ms_res.
    mo_handler->ms_res-body = `Internal Server Error`.
    mo_handler->ms_res-status_code = 500.
    mo_handler->ms_res-status_reason = `Internal Server Error`.
    z2ui5_cl_ui5_http_handler=>sv_get_etag = `"1.0-11-22-33"`.

    CLEAR temp17.
    temp17-n = `if-none-match`.
    temp17-v = `"1.0-11-22-33"`.
    INSERT temp17 INTO TABLE mo_mock->mt_req_header.

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
    DATA temp18 TYPE z2ui5_if_client=>ty_s_name_value.

    handler_create( ).
    " HEAD is the session-terminate ping, deliberately answered no-store and
    " never through the ETag/304 path - see the HEAD branch in main( )
    mo_handler->ms_req-method = `HEAD`.
    CLEAR mo_handler->ms_res.
    mo_handler->ms_res-status_code = 200.
    mo_handler->ms_res-status_reason = `OK`.
    z2ui5_cl_ui5_http_handler=>sv_get_etag = `"1.0-11-22-33"`.

    CLEAR temp18.
    temp18-n = `if-none-match`.
    temp18-v = `"1.0-11-22-33"`.
    INSERT temp18 INTO TABLE mo_mock->mt_req_header.

    mo_handler->set_response( ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = mo_mock->mv_status ).
    cl_abap_unit_assert=>assert_equals( exp = `no-cache, no-store, must-revalidate`
                                        act = header_value( `cache-control` ) ).
    cl_abap_unit_assert=>assert_initial( header_value( `etag` ) ).

  ENDMETHOD.

  METHOD test_head_terminate_ping.
    DATA temp19 TYPE z2ui5_if_client=>ty_t_name_value.
    DATA temp20 LIKE LINE OF temp19.

    " core/Server.js endSession: the ping carries `sap-terminate: session`
    " and ends the stateful session, answered with an empty 200
    handler_create( ).
    CLEAR mo_mock->ms_req_info.
    mo_mock->ms_req_info-method = `HEAD`.

    CLEAR temp19.

    temp20-n = `sap-terminate`.
    temp20-v = `session`.
    INSERT temp20 INTO TABLE temp19.
    mo_mock->mt_req_header = temp19.

    mo_handler->main( ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = mo_mock->mv_status ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = mo_mock->mv_stateful_set ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = mo_mock->mv_stateful ).

  ENDMETHOD.

  METHOD test_head_token_fetch_keeps.
    DATA temp21 TYPE z2ui5_if_client=>ty_t_name_value.
    DATA temp22 LIKE LINE OF temp21.

    " the X-CSRF-Token fetch of core/Server.js, which a token layer in front
    " (an SAP approuter) answers and then forwards here: an empty 200, and
    " the stateful session is not touched - ending it would drop a stateful
    " app's session in the middle of the handshake
    handler_create( ).
    CLEAR mo_mock->ms_req_info.
    mo_mock->ms_req_info-method = `HEAD`.

    CLEAR temp21.

    temp22-n = `x-csrf-token`.
    temp22-v = `Fetch`.
    INSERT temp22 INTO TABLE temp21.
    mo_mock->mt_req_header = temp21.

    mo_handler->main( ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = mo_mock->mv_status ).
    cl_abap_unit_assert=>assert_initial( mo_mock->mv_stateful_set ).

  ENDMETHOD.

  METHOD test_ctxid_cookie_to_header.
    DATA temp23 TYPE z2ui5_if_client=>ty_s_name_value.

    " The stateful handover. ICF answers a stateful switch with a
    " `sap-contextid` COOKIE, and the framework's own frontend cannot read
    " one: a cookie set on the BSP path is not sent back by a fetch from
    " another path, and reading it from JS is not possible under HttpOnly.
    " So when the client says it accepts the id as a header
    " (`sap-contextid-accept: header`, which core/Server.js always sends),
    " the cookie is taken OFF the response and re-sent as a header. Both
    " halves matter: leaving the cookie on would hand the browser a second,
    " competing carrier of the same session id
    handler_create( ).
    CLEAR mo_handler->ms_res.
    mo_handler->ms_res-body = `{}`.
    mo_handler->ms_res-status_code = 200.
    mo_handler->ms_res-status_reason = `OK`.
    CLEAR mo_handler->ms_res-s_stateful.
    mo_handler->ms_res-s_stateful-active = 1.
    mo_handler->ms_res-s_stateful-switched = abap_true.
    mo_mock->mv_res_cookie = `SID:ANON:srv_A4H_00_abcdef`.

    CLEAR temp23.
    temp23-n = `sap-contextid-accept`.
    temp23-v = `header`.
    INSERT temp23 INTO TABLE mo_mock->mt_req_header.

    mo_handler->set_response( ).

    cl_abap_unit_assert=>assert_equals( exp = `SID:ANON:srv_A4H_00_abcdef`
                                        act = header_value( `sap-contextid` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = mo_mock->mv_cookie_deleted ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = mo_mock->mv_stateful ).

  ENDMETHOD.

  METHOD test_ctxid_cookie_kept.

    " a client that did NOT ask for the header form keeps the cookie: an
    " ordinary browser navigation to the BSP path carries it back by itself,
    " and deleting it there would end the session on the next request
    handler_create( ).
    CLEAR mo_handler->ms_res.
    mo_handler->ms_res-body = `{}`.
    mo_handler->ms_res-status_code = 200.
    mo_handler->ms_res-status_reason = `OK`.
    CLEAR mo_handler->ms_res-s_stateful.
    mo_handler->ms_res-s_stateful-active = 1.
    mo_handler->ms_res-s_stateful-switched = abap_true.
    mo_mock->mv_res_cookie = `SID:ANON:srv_A4H_00_abcdef`.

    mo_handler->set_response( ).

    cl_abap_unit_assert=>assert_initial( header_value( `sap-contextid` ) ).
    cl_abap_unit_assert=>assert_initial( mo_mock->mv_cookie_deleted ).
    cl_abap_unit_assert=>assert_equals( exp = `SID:ANON:srv_A4H_00_abcdef`
                                        act = mo_mock->mv_res_cookie ).

  ENDMETHOD.

  METHOD test_ctxid_echoed.
    DATA temp24 TYPE z2ui5_if_client=>ty_s_name_value.

    " no switch on THIS response: the session id the request carried is
    " echoed so the frontend can keep sending it. Nothing else does that -
    " the cookie branch above only runs on the roundtrip that switched
    handler_create( ).
    CLEAR mo_handler->ms_res.
    mo_handler->ms_res-body = `{}`.
    mo_handler->ms_res-status_code = 200.
    mo_handler->ms_res-status_reason = `OK`.

    CLEAR temp24.
    temp24-n = `sap-contextid`.
    temp24-v = `SID:ANON:srv_A4H_00_abcdef`.
    INSERT temp24 INTO TABLE mo_mock->mt_req_header.

    mo_handler->set_response( ).

    cl_abap_unit_assert=>assert_equals( exp = `SID:ANON:srv_A4H_00_abcdef`
                                        act = header_value( `sap-contextid` ) ).
    " statefulness is not touched on a response that did not switch
    cl_abap_unit_assert=>assert_initial( mo_mock->mv_stateful_set ).

  ENDMETHOD.

  METHOD test_ctxid_absent_no_header.

    " a stateless request carries no id, and none is invented: an empty
    " `sap-contextid` header would be sent back by core/Server.js on the
    " next request (isValidContextId refuses `` and `undefined` for exactly
    " that reason) and asked ICF to resume a session that does not exist
    handler_create( ).
    CLEAR mo_handler->ms_res.
    mo_handler->ms_res-body = `{}`.
    mo_handler->ms_res-status_code = 200.
    mo_handler->ms_res-status_reason = `OK`.

    mo_handler->set_response( ).

    cl_abap_unit_assert=>assert_initial( header_value( `sap-contextid` ) ).

  ENDMETHOD.

  METHOD test_fwd_host_trusted.

    " default posture: behind a proxy the external authority arrives in
    " X-Forwarded-Host (first entry), and comparing Origin against it lets
    " the legitimate request through although Host names the internal server
    DATA lo_exit TYPE REF TO ltcl_exit_stub.
    DATA temp25 TYPE z2ui5_if_client=>ty_t_name_value.
    DATA temp26 LIKE LINE OF temp25.
    CREATE OBJECT lo_exit TYPE ltcl_exit_stub.
    lo_exit->mv_trust_forwarded = abap_true.
    ltcl_exit_injector=>inject( lo_exit ).

    handler_create( ).
    CLEAR mo_mock->ms_req_info.
    mo_mock->ms_req_info-method = `POST`.
    mo_mock->ms_req_info-body = `{"value":{}}`.

    CLEAR temp25.

    temp26-n = `origin`.
    temp26-v = `https://portal.corp`.
    INSERT temp26 INTO TABLE temp25.
    temp26-n = `host`.
    temp26-v = `internal.host:8000`.
    INSERT temp26 INTO TABLE temp25.
    temp26-n = `x-forwarded-host`.
    temp26-v = `portal.corp, internal.host:8000`.
    INSERT temp26 INTO TABLE temp25.
    mo_mock->mt_req_header = temp25.

    mo_handler->main( ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = mo_mock->mv_status ).

  ENDMETHOD.

  METHOD test_fwd_host_opt_out.

    " hardened posture: an installation without a proxy stops trusting the
    " client-suppliable X-Forwarded-Host via the exit - the same request is
    " then compared against the transport-level Host and rejected
    DATA lo_exit TYPE REF TO ltcl_exit_stub.
    DATA temp27 TYPE z2ui5_if_client=>ty_t_name_value.
    DATA temp28 LIKE LINE OF temp27.
    CREATE OBJECT lo_exit TYPE ltcl_exit_stub.
    lo_exit->mv_trust_forwarded = abap_false.
    ltcl_exit_injector=>inject( lo_exit ).

    handler_create( ).
    CLEAR mo_mock->ms_req_info.
    mo_mock->ms_req_info-method = `POST`.
    mo_mock->ms_req_info-body = `{"value":{}}`.

    CLEAR temp27.

    temp28-n = `origin`.
    temp28-v = `https://portal.corp`.
    INSERT temp28 INTO TABLE temp27.
    temp28-n = `host`.
    temp28-v = `internal.host:8000`.
    INSERT temp28 INTO TABLE temp27.
    temp28-n = `x-forwarded-host`.
    temp28-v = `portal.corp, internal.host:8000`.
    INSERT temp28 INTO TABLE temp27.
    mo_mock->mt_req_header = temp27.

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
    DATA lv_tag_a TYPE string.
    DATA lv_tag_b TYPE string.
    lv_tag_a = z2ui5_cl_ui5_http_handler=>_get_etag( `<html>shell content A</html>` ).

    lv_tag_b = z2ui5_cl_ui5_http_handler=>_get_etag( `<html>shell content B</html>` ).

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
    DATA lv_tag_a TYPE string.
    DATA lv_tag_b TYPE string.
    lv_tag_a = z2ui5_cl_ui5_http_handler=>_get_etag( `abcdefgh` ).

    lv_tag_b = z2ui5_cl_ui5_http_handler=>_get_etag( `hgfedcba` ).

    cl_abap_unit_assert=>assert_not_initial( lv_tag_a ).
    cl_abap_unit_assert=>assert_differs( exp = lv_tag_a
                                         act = lv_tag_b ).

  ENDMETHOD.

  METHOD test_etag_follows_cache_key.

    " the tag is derived from the cache key and the build hash, not from
    " the assembled body: it changes with the config, comes back for the
    " same config, and names the embedded frontend's build
    DATA temp29 TYPE z2ui5_if_ui5_exit=>ty_s_http_config.
    DATA ls_config_a LIKE temp29.
    DATA lv_tag_a LIKE z2ui5_cl_ui5_http_handler=>sv_get_etag.
    DATA ls_config_b LIKE ls_config_a.
    CLEAR temp29.
    temp29-theme = `sap_horizon`.
    temp29-src = `https://sdk.example/sap-ui-core.js`.

    ls_config_a = temp29.
    shell_for_config( ls_config_a ).

    lv_tag_a = z2ui5_cl_ui5_http_handler=>sv_get_etag.

    cl_abap_unit_assert=>assert_not_initial( lv_tag_a ).
    cl_abap_unit_assert=>assert_char_cp( act = lv_tag_a
                                         exp = |*-{ z2ui5_cl_ui5f_preload=>build_hash }-*| ).


    ls_config_b = ls_config_a.
    ls_config_b-theme = `sap_fiori_3`.
    shell_for_config( ls_config_b ).
    cl_abap_unit_assert=>assert_differs( exp = lv_tag_a
                                         act = z2ui5_cl_ui5_http_handler=>sv_get_etag ).

    shell_for_config( ls_config_a ).
    cl_abap_unit_assert=>assert_equals( exp = lv_tag_a
                                        act = z2ui5_cl_ui5_http_handler=>sv_get_etag ).

  ENDMETHOD.

  METHOD test_etag_after_304_of_other.

    " A 304 RETURNS before the body cache is written, so it leaves
    " sv_get_cache_key naming the config of the last BUILT page while
    " sv_get_etag names the config that was just revalidated. Reusing the
    " tag off the BODY key therefore shipped the wrong validator with the
    " right page - and a browser that stores a page under another page's
    " tag is 304'd into keeping it once that other config is current, which
    " is the stale shell the tag exists to prevent.
    DATA temp30 TYPE z2ui5_if_ui5_exit=>ty_s_http_config.
    DATA ls_config_a LIKE temp30.
    DATA ls_config_b LIKE ls_config_a.
    DATA lv_tag_a LIKE z2ui5_cl_ui5_http_handler=>sv_get_etag.
    DATA lv_body_b TYPE string.
    DATA lv_tag_b LIKE z2ui5_cl_ui5_http_handler=>sv_get_etag.
    DATA ls_res_304 TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_res.
    DATA temp31 TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_res.
    DATA ls_res_b LIKE temp31.
    CLEAR temp30.
    temp30-theme = `sap_horizon`.
    temp30-src = `https://sdk.example/sap-ui-core.js`.

    ls_config_a = temp30.

    ls_config_b = ls_config_a.
    ls_config_b-theme = `sap_fiori_3`.

    shell_for_config( ls_config_a ).

    lv_tag_a = z2ui5_cl_ui5_http_handler=>sv_get_etag.

    lv_body_b = shell_for_config( ls_config_b ).

    lv_tag_b = z2ui5_cl_ui5_http_handler=>sv_get_etag.
    cl_abap_unit_assert=>assert_differs( exp = lv_tag_a
                                         act = lv_tag_b ).

    " a conditional GET of config A that matches - answered 304, and the
    " body cache still holds B
    z2ui5_cl_ui5_http_handler=>sv_if_none_match       = lv_tag_a.
    z2ui5_cl_ui5_http_handler=>ss_config_http_get     = ls_config_a.
    z2ui5_cl_ui5_http_handler=>sv_config_http_get_set = abap_true.

    ls_res_304 = z2ui5_cl_ui5_http_handler=>_http_get( ).
    cl_abap_unit_assert=>assert_equals( exp = 304
                                        act = ls_res_304-status_code ).

    " ...and now config B again, unconditional: the cached body comes back
    " and it has to carry B's tag, not the one the 304 left behind

    CLEAR temp31.

    ls_res_b = temp31.
    z2ui5_cl_ui5_http_handler=>ss_config_http_get     = ls_config_b.
    z2ui5_cl_ui5_http_handler=>sv_config_http_get_set = abap_true.
    ls_res_b = z2ui5_cl_ui5_http_handler=>_http_get( ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = ls_res_b-status_code ).
    cl_abap_unit_assert=>assert_equals( exp = lv_body_b
                                        act = ls_res_b-body ).
    cl_abap_unit_assert=>assert_equals( exp = lv_tag_b
                                        act = z2ui5_cl_ui5_http_handler=>sv_get_etag ).

  ENDMETHOD.

  METHOD test_get_304_skips_build.

    " the browser still holds the current shell: _http_get answers the
    " conditional GET BEFORE the page is assembled - a bodyless 304, and
    " the body cache stays empty because nothing was built. The validator
    " is a function of the config, the version and the build hash, so a
    " fresh work process (no cached body, the cache cleared below) computes
    " the same tag the previous one sent
    DATA temp32 TYPE z2ui5_if_ui5_exit=>ty_s_http_config.
    DATA ls_config LIKE temp32.
    DATA lv_tag LIKE z2ui5_cl_ui5_http_handler=>sv_get_etag.
    DATA ls_res TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_res.
    CLEAR temp32.
    temp32-theme = `sap_horizon`.
    temp32-src = `https://sdk.example/sap-ui-core.js`.

    ls_config = temp32.
    shell_for_config( ls_config ).

    lv_tag = z2ui5_cl_ui5_http_handler=>sv_get_etag.
    cl_abap_unit_assert=>assert_not_initial( lv_tag ).

    caches_clear( ).
    z2ui5_cl_ui5_http_handler=>sv_if_none_match       = lv_tag.
    z2ui5_cl_ui5_http_handler=>ss_config_http_get     = ls_config.
    z2ui5_cl_ui5_http_handler=>sv_config_http_get_set = abap_true.


    ls_res = z2ui5_cl_ui5_http_handler=>_http_get( ).

    cl_abap_unit_assert=>assert_equals( exp = 304
                                        act = ls_res-status_code ).
    cl_abap_unit_assert=>assert_equals( exp = `Not Modified`
                                        act = ls_res-status_reason ).
    cl_abap_unit_assert=>assert_initial( ls_res-body ).
    " the proof that the build was skipped, not thrown away
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_http_handler=>sv_get_cache_body ).
    " the tag set_response sends with the 304 is the one that matched
    cl_abap_unit_assert=>assert_equals( exp = lv_tag
                                        act = z2ui5_cl_ui5_http_handler=>sv_get_etag ).
    " consumed: a later direct _main( ) call meets no validator of this
    " request
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_http_handler=>sv_if_none_match ).

  ENDMETHOD.

  METHOD test_get_stale_tag_builds.

    " a validator of another shell: the full page is built and travels,
    " and the body cache is filled by it
    DATA temp33 TYPE z2ui5_if_ui5_exit=>ty_s_http_config.
    DATA ls_config LIKE temp33.
    DATA ls_res TYPE z2ui5_cl_ui5_http_handler=>ty_s_http_res.
    CLEAR temp33.
    temp33-theme = `sap_horizon`.
    temp33-src = `https://sdk.example/sap-ui-core.js`.

    ls_config = temp33.
    z2ui5_cl_ui5_http_handler=>sv_if_none_match       = `"1.0-stale-tag"`.
    z2ui5_cl_ui5_http_handler=>ss_config_http_get     = ls_config.
    z2ui5_cl_ui5_http_handler=>sv_config_http_get_set = abap_true.


    ls_res = z2ui5_cl_ui5_http_handler=>_http_get( ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = ls_res-status_code ).
    cl_abap_unit_assert=>assert_not_initial( ls_res-body ).
    cl_abap_unit_assert=>assert_not_initial( z2ui5_cl_ui5_http_handler=>sv_get_cache_body ).
    cl_abap_unit_assert=>assert_not_initial( z2ui5_cl_ui5_http_handler=>sv_get_etag ).
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_http_handler=>sv_if_none_match ).

  ENDMETHOD.

  METHOD test_get_304_end_to_end.
    DATA lv_tag TYPE string.
    DATA temp34 TYPE z2ui5_if_client=>ty_s_name_value.

    " the two requests of a reload as the stack sees them: the first GET
    " answers 200 with a tag, the second - in a NEW work process, so the
    " caches are cleared in between - carries that tag back and gets the
    " bodyless 304 with the tag and the revalidation policy, without the
    " shell ever having been assembled
    handler_create( ).
    CLEAR mo_mock->ms_req_info.
    mo_mock->ms_req_info-method = `GET`.

    mo_handler->main( ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = mo_mock->mv_status ).
    cl_abap_unit_assert=>assert_not_initial( mo_mock->mv_cdata ).

    lv_tag = header_value( `etag` ).
    cl_abap_unit_assert=>assert_not_initial( lv_tag ).

    caches_clear( ).
    handler_create( ).
    CLEAR mo_mock->ms_req_info.
    mo_mock->ms_req_info-method = `GET`.

    CLEAR temp34.
    temp34-n = `if-none-match`.
    temp34-v = lv_tag.
    INSERT temp34 INTO TABLE mo_mock->mt_req_header.

    mo_handler->main( ).

    cl_abap_unit_assert=>assert_equals( exp = 304
                                        act = mo_mock->mv_status ).
    cl_abap_unit_assert=>assert_initial( mo_mock->mv_cdata ).
    cl_abap_unit_assert=>assert_equals( exp = lv_tag
                                        act = header_value( `etag` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `private, no-cache`
                                        act = header_value( `cache-control` ) ).
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_http_handler=>sv_get_cache_body ).

  ENDMETHOD.

  METHOD test_exit_get_raises_answers.

    " a customer exit whose set_config_http_get raises: the GET is a 500
    " WITH a status and a body. It used to raise a second time out of
    " set_response( ) - after the outer catch had already produced the 500 -
    " and left the ICF stack to dump with neither.
    DATA lo_exit TYPE REF TO ltcl_exit_stub.
    CREATE OBJECT lo_exit TYPE ltcl_exit_stub.
    lo_exit->mv_raise_get = abap_true.
    ltcl_exit_injector=>inject( lo_exit ).

    handler_create( ).
    CLEAR mo_mock->ms_req_info.
    mo_mock->ms_req_info-method = `GET`.

    mo_handler->main( ).

    cl_abap_unit_assert=>assert_equals( exp = 500
                                        act = mo_mock->mv_status ).
    cl_abap_unit_assert=>assert_not_initial( mo_mock->mv_cdata ).
    cl_abap_unit_assert=>assert_equals( exp = `text/plain; charset=UTF-8`
                                        act = header_value( `content-type` ) ).

  ENDMETHOD.

  METHOD test_csp_hash_default.

    " the default policy: the hash lands in script-src and nowhere else -
    " default-src and style-src cover UI5's inline styles, and a hash there
    " would switch 'unsafe-inline' off for them
    DATA lt_directive TYPE string_table.
    DATA lv_checked TYPE i.
    DATA temp35 TYPE z2ui5_if_ui5_exit=>ty_s_http_config.
    DATA ls_config LIKE temp35.
    DATA lv_source TYPE string.
    DATA lv_policy TYPE string.
    DATA lv_directive LIKE LINE OF lt_directive.
        DATA temp42 TYPE xsdboolean.
        DATA temp43 TYPE xsdboolean.
    DATA temp44 TYPE xsdboolean.
    CLEAR temp35.

    ls_config = temp35.
    z2ui5_cl_ui5_user_exit=>get_instance( )->set_config_http_get( CHANGING cs_config = ls_config ).

    lv_source = |'{ z2ui5_cl_ui5f_preload=>script_hash }'|.


    lv_policy = z2ui5_cl_ui5_http_handler=>_csp_add_script_hash( ls_config-content_security_policy ).

    SPLIT lv_policy AT `;` INTO TABLE lt_directive.

    LOOP AT lt_directive INTO lv_directive.
      IF lv_directive CS `script-src`.

        temp42 = boolc( lv_directive CS lv_source ).
        cl_abap_unit_assert=>assert_true( temp42 ).
        lv_checked = lv_checked + 1.
      ELSE.

        temp43 = boolc( lv_directive CS lv_source ).
        cl_abap_unit_assert=>assert_false( temp43 ).
      ENDIF.
    ENDLOOP.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lv_checked ).
    " the tag around the policy is untouched

    temp44 = boolc( lv_policy CP `<meta http-equiv="Content-Security-Policy" content="*"/>` ).
    cl_abap_unit_assert=>assert_true( temp44 ).

  ENDMETHOD.

  METHOD test_csp_hash_unsafe_inline.

    DATA lv_source TYPE string.
    DATA lv_policy TYPE string.
    lv_source = |'{ z2ui5_cl_ui5f_preload=>script_hash }'|.

    " a script-src that says 'unsafe-inline' is the exit's decision that
    " inline script runs - a hash next to it would take that back

    lv_policy = `default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self'`.
    cl_abap_unit_assert=>assert_equals( exp = lv_policy
                                        act = z2ui5_cl_ui5_http_handler=>_csp_add_script_hash( lv_policy ) ).

    " ...unless a hash or a nonce already switched it off: then the shell's
    " script needs its own hash like anywhere else
    lv_policy = `script-src 'self' 'unsafe-inline' 'nonce-abc'`.
    cl_abap_unit_assert=>assert_equals(
        exp = |script-src 'self' 'unsafe-inline' 'nonce-abc' { lv_source }|
        act = z2ui5_cl_ui5_http_handler=>_csp_add_script_hash( lv_policy ) ).

  ENDMETHOD.

  METHOD test_csp_hash_directives.

    DATA lv_source TYPE string.
    lv_source = |'{ z2ui5_cl_ui5f_preload=>script_hash }'|.

    " script-src-elem governs <script> elements too and gets the hash;
    " script-src-attr governs handler attributes, which no hash allows
    cl_abap_unit_assert=>assert_equals(
        exp = |script-src-attr 'none'; script-src-elem 'self' { lv_source }; script-src 'self' { lv_source }|
        act = z2ui5_cl_ui5_http_handler=>_csp_add_script_hash(
                  `script-src-attr 'none'; script-src-elem 'self'; script-src 'self'` ) ).

    " the name has to stand alone - a host or another directive that only
    " contains it is no script-src
    cl_abap_unit_assert=>assert_equals(
        exp = `img-src my-script-src.example; x-script-src 'self'`
        act = z2ui5_cl_ui5_http_handler=>_csp_add_script_hash(
                  `img-src my-script-src.example; x-script-src 'self'` ) ).

    " no script-src at all: default-src decides and is left alone (it
    " covers styles as well)
    cl_abap_unit_assert=>assert_equals(
        exp = `default-src 'self' 'unsafe-inline'`
        act = z2ui5_cl_ui5_http_handler=>_csp_add_script_hash( `default-src 'self' 'unsafe-inline'` ) ).

    " the names are case-insensitive, and nothing else changes case
    cl_abap_unit_assert=>assert_equals(
        exp = |Script-Src 'self' Host.Example { lv_source }|
        act = z2ui5_cl_ui5_http_handler=>_csp_add_script_hash( `Script-Src 'self' Host.Example` ) ).

    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_http_handler=>_csp_add_script_hash( `` ) ).

  ENDMETHOD.

  METHOD test_csp_hash_header_value.

    DATA lv_source TYPE string.
    lv_source = |'{ z2ui5_cl_ui5f_preload=>script_hash }'|.

    " a header value ends without a quote or a semicolon
    cl_abap_unit_assert=>assert_equals(
        exp = |default-src 'self'; script-src 'self' { lv_source }|
        act = z2ui5_cl_ui5_http_handler=>_csp_add_script_hash( `default-src 'self'; script-src 'self'` ) ).

    " in a meta tag the content attribute's quote ends the last directive
    cl_abap_unit_assert=>assert_equals(
        exp = |<meta http-equiv="Content-Security-Policy" content="script-src 'self' { lv_source }"/>|
        act = z2ui5_cl_ui5_http_handler=>_csp_add_script_hash(
                  `<meta http-equiv="Content-Security-Policy" content="script-src 'self'"/>` ) ).

  ENDMETHOD.

  METHOD test_csp_hash_once.

    " an exit that listed the hash itself gets no second copy
    DATA lv_policy TYPE string.
    lv_policy = |script-src 'self' '{ z2ui5_cl_ui5f_preload=>script_hash }'|.
    cl_abap_unit_assert=>assert_equals( exp = lv_policy
                                        act = z2ui5_cl_ui5_http_handler=>_csp_add_script_hash( lv_policy ) ).

  ENDMETHOD.

  METHOD test_csp_hash_security_hdr.

    " a policy the exit sends as a response header needs the hash as much as
    " the meta tag - the enforcing header and the report-only one alike
    DATA lv_source TYPE string.
    DATA temp36 TYPE z2ui5_if_ui5_exit=>ty_s_http_config.
    DATA temp19 TYPE z2ui5_if_client=>ty_t_name_value.
    DATA temp20 LIKE LINE OF temp19.
    lv_source = |'{ z2ui5_cl_ui5f_preload=>script_hash }'|.
    handler_create( ).
    mo_handler->ms_req-method = `GET`.
    CLEAR mo_handler->ms_res.
    mo_handler->ms_res-body = `<html></html>`.
    mo_handler->ms_res-status_code = 200.
    mo_handler->ms_res-status_reason = `OK`.

    CLEAR temp36.

    CLEAR temp19.

    temp20-n = `Content-Security-Policy`.
    temp20-v = `script-src 'self'`.
    INSERT temp20 INTO TABLE temp19.
    temp20-n = `Content-Security-Policy-Report-Only`.
    temp20-v = `script-src 'none'`.
    INSERT temp20 INTO TABLE temp19.
    temp20-n = `X-Frame-Options`.
    temp20-v = `SAMEORIGIN`.
    INSERT temp20 INTO TABLE temp19.
    temp36-t_security_header = temp19.
    z2ui5_cl_ui5_http_handler=>ss_config_http_get = temp36.
    z2ui5_cl_ui5_http_handler=>sv_config_http_get_set = abap_true.

    mo_handler->set_response( ).

    cl_abap_unit_assert=>assert_equals( exp = |script-src 'self' { lv_source }|
                                        act = header_value( `content-security-policy` ) ).
    cl_abap_unit_assert=>assert_equals( exp = |script-src 'none' { lv_source }|
                                        act = header_value( `content-security-policy-report-only` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `SAMEORIGIN`
                                        act = header_value( `x-frame-options` ) ).

  ENDMETHOD.

  METHOD test_shell_script_is_preload.

    " the page's one inline script is exactly the generated text its hash was
    " taken over - one character between the tags and the browser refuses it
    DATA temp37 TYPE z2ui5_if_ui5_exit=>ty_s_http_config.
    DATA lv_body TYPE string.
    DATA temp45 TYPE xsdboolean.
    DATA temp46 TYPE xsdboolean.
    DATA lv_rest TYPE string.
    TYPES temp1 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_part TYPE temp1.
    CLEAR temp37.
    temp37-theme = `sap_horizon`.
    temp37-src = `https://sdk.example/sap-ui-core.js`.
    temp37-content_security_policy = `<meta http-equiv="Content-Security-Policy" content="script-src 'self'"/>`.

    lv_body = shell_for_config( temp37 ).


    temp45 = boolc( find( val = lv_body sub = |<script>{ z2ui5_cl_ui5f_preload=>get( ) }</script>| ) >= 0 ).
    cl_abap_unit_assert=>assert_true(
        temp45 ).

    temp46 = boolc( find( val = lv_body sub = |script-src 'self' '{ z2ui5_cl_ui5f_preload=>script_hash }'"| ) >= 0 ).
    cl_abap_unit_assert=>assert_true(
        temp46 ).
    " and it is the only inline script: the other tag is the bootstrap,
    " which loads UI5 by src (the preload itself is taken out first - an
    " embedded .js file may well spell <script in a string)

    lv_rest = replace( val  = lv_body
                             sub  = z2ui5_cl_ui5f_preload=>get( )
                             with = `` ).


    SPLIT lv_rest AT `<script` INTO TABLE lt_part.
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lt_part ) ).

  ENDMETHOD.

  METHOD test_style_exit_element.

    " the exit's styles_css is a <style> element of its own - outside the
    " hashed script, so the hash stays fixed - and a < in it cannot end the
    " element: it becomes the CSS escape \3c
    DATA temp38 TYPE z2ui5_if_ui5_exit=>ty_s_http_config.
    DATA lv_body TYPE string.
    DATA temp47 TYPE xsdboolean.
    DATA temp48 TYPE xsdboolean.
    DATA temp39 TYPE z2ui5_if_ui5_exit=>ty_s_http_config.
    TYPES temp2 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_part TYPE temp2.
    CLEAR temp38.
    temp38-theme = `sap_horizon`.
    temp38-src = `https://sdk.example/sap-ui-core.js`.
    temp38-styles_css = `.a::after { content: '</style><script>x()</script>'; }`.

    lv_body = shell_for_config( temp38 ).


    temp47 = boolc( find( val = lv_body sub = `<style>.a::after { content: '\3c /style>\3c script>x()\3c /script>'; }</style>` ) >= 0 ).
    cl_abap_unit_assert=>assert_true(
        temp47 ).

    temp48 = boolc( find( val = lv_body sub = `x()</script>` ) >= 0 ).
    cl_abap_unit_assert=>assert_false( temp48 ).

    " no styles_css, no element: the page's own <style> is the only one

    CLEAR temp39.
    temp39-theme = `sap_horizon`.
    temp39-src = `https://sdk.example/sap-ui-core.js`.
    lv_body = shell_for_config( temp39 ).


    SPLIT lv_body AT `<style>` INTO TABLE lt_part.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_part ) ).

  ENDMETHOD.

  METHOD test_preconnect_cdn.

    " an absolute src: the two hints, in the head, in front of the title -
    " and outside the inline script, whose text (and so its CSP hash) is
    " the generated preload alone
    DATA temp40 TYPE z2ui5_if_ui5_exit=>ty_s_http_config.
    DATA lv_body TYPE string.
    DATA lv_hints TYPE string.
    DATA temp49 TYPE xsdboolean.
    DATA temp50 TYPE xsdboolean.
    DATA temp51 TYPE xsdboolean.
    DATA temp41 TYPE z2ui5_if_ui5_exit=>ty_s_http_config.
    DATA temp52 TYPE xsdboolean.
    CLEAR temp40.
    temp40-theme = `sap_horizon`.
    temp40-src = `https://sdk.example/resources/sap-ui-core.js`.

    lv_body = shell_for_config( temp40 ).


    lv_hints = |<link rel="preconnect" href="https://sdk.example">\n| &&
                     |<link rel="preconnect" href="https://sdk.example" crossorigin>\n| &&
                     |<title>abap2UI5</title>|.

    temp49 = boolc( find( val = lv_body sub = lv_hints ) >= 0 ).
    cl_abap_unit_assert=>assert_true( temp49 ).

    temp50 = boolc( find( val = lv_body sub = lv_hints ) < find( val = lv_body sub = `<script>` ) ).
    cl_abap_unit_assert=>assert_true( temp50 ).

    temp51 = boolc( find( val = lv_body sub = |<script>{ z2ui5_cl_ui5f_preload=>get( ) }</script>| ) >= 0 ).
    cl_abap_unit_assert=>assert_true( temp51 ).

    " an origin out of the exit is attribute-escaped like the src itself

    CLEAR temp41.
    temp41-theme = `sap_horizon`.
    temp41-src = `https://a"b.example/x.js`.
    lv_body = shell_for_config( temp41 ).

    temp52 = boolc( find( val = lv_body sub = `href="https://a&quot;b.example"` ) >= 0 ).
    cl_abap_unit_assert=>assert_true( temp52 ).

  ENDMETHOD.

  METHOD test_preconnect_relative.

    " a UI5 served by the system itself: no hint at all
    DATA temp42 TYPE z2ui5_if_ui5_exit=>ty_s_http_config.
    DATA lv_body TYPE string.
    DATA temp53 TYPE xsdboolean.
    DATA temp54 TYPE xsdboolean.
    CLEAR temp42.
    temp42-theme = `sap_horizon`.
    temp42-src = `/sap/public/bc/ui5_ui5/1/resources/sap-ui-core.js`.

    lv_body = shell_for_config( temp42 ).


    temp53 = boolc( find( val = lv_body sub = `rel="preconnect"` ) >= 0 ).
    cl_abap_unit_assert=>assert_false( temp53 ).

    temp54 = boolc( find( val = lv_body sub = |<meta http-equiv="X-UA-Compatible" content="IE=edge">\n<title>abap2UI5</title>| ) >= 0 ).
    cl_abap_unit_assert=>assert_true( temp54 ).

  ENDMETHOD.

  METHOD test_bundle_response.
    DATA temp21 TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    DATA temp22 LIKE LINE OF temp21.
    DATA temp55 TYPE xsdboolean.
    DATA temp56 TYPE xsdboolean.

    handler_create( ).
    CLEAR mo_mock->ms_req_info.
    mo_mock->ms_req_info-method = `GET`.
    mo_mock->ms_req_info-path = `/sap/bc/z2ui5`.

    CLEAR temp21.

    temp22-n = `z2ui5-bundle`.
    INSERT temp22 INTO TABLE temp21.
    mo_mock->ms_req_info-t_params = temp21.

    mo_handler->main( ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = mo_mock->mv_status ).

    temp55 = boolc( find( val = mo_mock->mv_cdata sub = z2ui5_cl_ui5f_preload=>get_bundle( ) ) = 0 ).
    cl_abap_unit_assert=>assert_true(
        temp55 ).
    " the path the stack reported (get_req_info, ~path) is the one the
    " module tells the embedding page

    temp56 = boolc( mo_mock->mv_cdata CS `nodePath: "/sap/bc/z2ui5",` ).
    cl_abap_unit_assert=>assert_true(
        temp56 ).
    cl_abap_unit_assert=>assert_equals( exp = `application/javascript; charset=UTF-8`
                                        act = header_value( `content-type` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `nosniff`
                                        act = header_value( `x-content-type-options` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `private, no-cache`
                                        act = header_value( `cache-control` ) ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_ui5_http_handler=>_get_etag( `z2ui5-bundle` )
                                        act = header_value( `etag` ) ).
    " the page's tag and cache are not the bundle's business
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_http_handler=>sv_get_etag ).
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_http_handler=>sv_get_cache_body ).

  ENDMETHOD.

  METHOD test_devtools_response.
    DATA temp23 TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    DATA temp24 LIKE LINE OF temp23.

    handler_create( ).
    CLEAR mo_mock->ms_req_info.
    mo_mock->ms_req_info-method = `GET`.
    mo_mock->ms_req_info-path = `/sap/bc/z2ui5`.

    CLEAR temp23.

    temp24-n = `z2ui5-bundle`.
    temp24-v = `devtools`.
    INSERT temp24 INTO TABLE temp23.
    mo_mock->ms_req_info-t_params = temp23.

    mo_handler->main( ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = mo_mock->mv_status ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_ui5f_preload=>get_devtools( )
                                        act = mo_mock->mv_cdata ).
    cl_abap_unit_assert=>assert_equals( exp = `application/javascript; charset=UTF-8`
                                        act = header_value( `content-type` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `nosniff`
                                        act = header_value( `x-content-type-options` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `private, no-cache`
                                        act = header_value( `cache-control` ) ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_ui5_http_handler=>_bundle_etag( abap_true )
                                        act = header_value( `etag` ) ).
    cl_abap_unit_assert=>assert_differs( exp = z2ui5_cl_ui5_http_handler=>_bundle_etag( abap_false )
                                         act = header_value( `etag` ) ).
    " the page's tag and cache are not the bundle's business
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_http_handler=>sv_get_etag ).
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_http_handler=>sv_get_cache_body ).

  ENDMETHOD.

  METHOD test_devtools_304.
    DATA temp25 TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    DATA temp26 LIKE LINE OF temp25.
    DATA lv_tag TYPE string.
    DATA temp27 TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    DATA temp28 LIKE LINE OF temp27.
    DATA temp43 TYPE z2ui5_if_client=>ty_s_name_value.
    DATA temp29 TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    DATA temp30 LIKE LINE OF temp29.
    DATA temp44 TYPE z2ui5_if_client=>ty_s_name_value.

    handler_create( ).
    CLEAR mo_mock->ms_req_info.
    mo_mock->ms_req_info-method = `GET`.

    CLEAR temp25.

    temp26-n = `z2ui5-bundle`.
    temp26-v = `devtools`.
    INSERT temp26 INTO TABLE temp25.
    mo_mock->ms_req_info-t_params = temp25.
    mo_handler->main( ).

    lv_tag = header_value( `etag` ).
    cl_abap_unit_assert=>assert_not_initial( lv_tag ).

    " the reload, in a new work process: the tag comes back, the script not
    caches_clear( ).
    handler_create( ).
    CLEAR mo_mock->ms_req_info.
    mo_mock->ms_req_info-method = `GET`.

    CLEAR temp27.

    temp28-n = `z2ui5-bundle`.
    temp28-v = `devtools`.
    INSERT temp28 INTO TABLE temp27.
    mo_mock->ms_req_info-t_params = temp27.

    CLEAR temp43.
    temp43-n = `if-none-match`.
    temp43-v = lv_tag.
    INSERT temp43 INTO TABLE mo_mock->mt_req_header.

    mo_handler->main( ).

    cl_abap_unit_assert=>assert_equals( exp = 304
                                        act = mo_mock->mv_status ).
    cl_abap_unit_assert=>assert_initial( mo_mock->mv_cdata ).
    cl_abap_unit_assert=>assert_equals( exp = lv_tag
                                        act = header_value( `etag` ) ).

    " the frontend bundle's tag is another one - it does not 304 the devtools
    caches_clear( ).
    handler_create( ).
    CLEAR mo_mock->ms_req_info.
    mo_mock->ms_req_info-method = `GET`.

    CLEAR temp29.

    temp30-n = `z2ui5-bundle`.
    temp30-v = `devtools`.
    INSERT temp30 INTO TABLE temp29.
    mo_mock->ms_req_info-t_params = temp29.

    CLEAR temp44.
    temp44-n = `if-none-match`.
    temp44-v = z2ui5_cl_ui5_http_handler=>_bundle_etag( abap_false ).
    INSERT temp44 INTO TABLE mo_mock->mt_req_header.

    mo_handler->main( ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = mo_mock->mv_status ).

  ENDMETHOD.

  METHOD test_bundle_304.
    DATA temp31 TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    DATA temp32 LIKE LINE OF temp31.
    DATA lv_tag TYPE string.
    DATA temp33 TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    DATA temp34 LIKE LINE OF temp33.
    DATA temp45 TYPE z2ui5_if_client=>ty_s_name_value.
    DATA temp46 TYPE z2ui5_if_client=>ty_s_name_value.
    DATA temp57 TYPE xsdboolean.

    handler_create( ).
    CLEAR mo_mock->ms_req_info.
    mo_mock->ms_req_info-method = `GET`.

    CLEAR temp31.

    temp32-n = `z2ui5-bundle`.
    INSERT temp32 INTO TABLE temp31.
    mo_mock->ms_req_info-t_params = temp31.
    mo_handler->main( ).

    lv_tag = header_value( `etag` ).
    cl_abap_unit_assert=>assert_not_initial( lv_tag ).

    " the reload, in a new work process: the tag comes back, the script not
    caches_clear( ).
    handler_create( ).
    CLEAR mo_mock->ms_req_info.
    mo_mock->ms_req_info-method = `GET`.

    CLEAR temp33.

    temp34-n = `z2ui5-bundle`.
    INSERT temp34 INTO TABLE temp33.
    mo_mock->ms_req_info-t_params = temp33.

    CLEAR temp45.
    temp45-n = `if-none-match`.
    temp45-v = lv_tag.
    INSERT temp45 INTO TABLE mo_mock->mt_req_header.

    mo_handler->main( ).

    cl_abap_unit_assert=>assert_equals( exp = 304
                                        act = mo_mock->mv_status ).
    cl_abap_unit_assert=>assert_initial( mo_mock->mv_cdata ).
    cl_abap_unit_assert=>assert_equals( exp = lv_tag
                                        act = header_value( `etag` ) ).

    " the page's tag is another one - it does not 304 the page
    caches_clear( ).
    handler_create( ).
    CLEAR mo_mock->ms_req_info.
    mo_mock->ms_req_info-method = `GET`.

    CLEAR temp46.
    temp46-n = `if-none-match`.
    temp46-v = lv_tag.
    INSERT temp46 INTO TABLE mo_mock->mt_req_header.

    mo_handler->main( ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = mo_mock->mv_status ).

    temp57 = boolc( mo_mock->mv_cdata CS `<!DOCTYPE html>` ).
    cl_abap_unit_assert=>assert_true( temp57 ).

  ENDMETHOD.

  METHOD test_factory_onprem.

    " an ICF server object: the layer-0 wrapper is built around it and its
    " RESPONSE is kept at hand for the compression switch set_response( )
    " flips - a server without one simply has nothing to flip
    DATA lo_server TYPE REF TO ltcl_server_shape.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_http_handler.
    DATA temp58 TYPE xsdboolean.
    CREATE OBJECT lo_server TYPE ltcl_server_shape.
    CREATE OBJECT lo_server->response TYPE ltcl_server_shape.


    lo_handler = z2ui5_cl_ui5_http_handler=>factory( lo_server ).

    cl_abap_unit_assert=>assert_bound( lo_handler->mo_server ).
    cl_abap_unit_assert=>assert_bound( lo_handler->mo_server->mo_server_onprem ).

    temp58 = boolc( lo_handler->mo_response_onprem = lo_server->response ).
    cl_abap_unit_assert=>assert_true( temp58 ).

  ENDMETHOD.

  METHOD test_factory_cloud.

    " the cloud pair: request and response objects, no server, so nothing
    " on-premise to keep
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_http_handler.
    DATA temp35 TYPE REF TO ltcl_server_shape.
    DATA temp1 TYPE REF TO ltcl_server_shape.
    CREATE OBJECT temp35 TYPE ltcl_server_shape.

    CREATE OBJECT temp1 TYPE ltcl_server_shape.
    lo_handler = z2ui5_cl_ui5_http_handler=>factory( req = temp35
                                                           res = temp1 ).

    cl_abap_unit_assert=>assert_bound( lo_handler->mo_server ).
    cl_abap_unit_assert=>assert_bound( lo_handler->mo_server->mo_request_cloud ).
    cl_abap_unit_assert=>assert_bound( lo_handler->mo_server->mo_response_cloud ).
    cl_abap_unit_assert=>assert_not_bound( lo_handler->mo_server->mo_server_onprem ).
    cl_abap_unit_assert=>assert_not_bound( lo_handler->mo_response_onprem ).

  ENDMETHOD.

  METHOD test_factory_nothing.
        DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.

    " neither a server nor the cloud pair is a programming error of the
    " caller, named as such
    TRY.
        z2ui5_cl_ui5_http_handler=>factory( ).
        cl_abap_unit_assert=>fail( `factory( ) without any object must raise` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx.
        cl_abap_unit_assert=>assert_char_cp( exp = `*EMPTY_HTTP_HANDLER_CALL_ERROR*`
                                             act = lx->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
