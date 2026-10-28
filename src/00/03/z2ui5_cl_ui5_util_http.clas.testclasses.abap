" client_target( ) is PRIVATE - the URL arithmetic it does is what the
" tests below assert on, so the test class needs friendship (checked by
" npm run check_visibility).
CLASS ltcl_test DEFINITION DEFERRED.
CLASS z2ui5_cl_ui5_util_http DEFINITION LOCAL FRIENDS ltcl_test.

" a server object that carries neither REQUEST nor RESPONSE - what the
" wrapper meets when a host hands it the wrong object
CLASS ltcl_fake_bare_server DEFINITION FINAL.
  PUBLIC SECTION.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_fake_bare_server IMPLEMENTATION.
ENDCLASS.

CLASS ltcl_fake_request DEFINITION FINAL.
  PUBLIC SECTION.
    DATA mv_cdata  TYPE string.
    DATA mt_header TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.

    METHODS get_cdata
      RETURNING
        VALUE(data) TYPE string.

    METHODS get_header_field
      IMPORTING
        !name        TYPE clike
      RETURNING
        VALUE(value) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_fake_request IMPLEMENTATION.

  METHOD get_cdata.

    data = mv_cdata.

  ENDMETHOD.

  METHOD get_header_field.
        FIELD-SYMBOLS <temp1> LIKE LINE OF mt_header.
        DATA temp2 LIKE sy-tabix.

    TRY.


        temp2 = sy-tabix.
        READ TABLE mt_header WITH KEY n = name ASSIGNING <temp1>.
        sy-tabix = temp2.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        value = <temp1>-v.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_fake_response DEFINITION FINAL.
  PUBLIC SECTION.
    DATA mv_cdata          TYPE string.
    DATA mt_header         TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    DATA mt_cookie         TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    DATA mv_cookie_deleted TYPE string.

    METHODS set_cdata
      IMPORTING
        !data TYPE clike.

    METHODS set_header_field
      IMPORTING
        !name  TYPE clike
        !value TYPE clike.

    METHODS get_cookie
      IMPORTING
        !name  TYPE clike
      EXPORTING
        !value TYPE any.

    METHODS delete_cookie
      IMPORTING
        !name TYPE clike.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_fake_response IMPLEMENTATION.

  METHOD set_cdata.

    mv_cdata = data.

  ENDMETHOD.

  METHOD set_header_field.

    DATA temp3 TYPE z2ui5_cl_ui5_util_context=>ty_s_name_value.
    CLEAR temp3.
    temp3-n = name.
    temp3-v = value.
    INSERT temp3 INTO TABLE mt_header.

  ENDMETHOD.

  METHOD get_cookie.
        FIELD-SYMBOLS <temp4> LIKE LINE OF mt_cookie.
        DATA temp5 LIKE sy-tabix.

    CLEAR value.
    TRY.


        temp5 = sy-tabix.
        READ TABLE mt_cookie WITH KEY n = name ASSIGNING <temp4>.
        sy-tabix = temp5.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        value = <temp4>-v.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD delete_cookie.

    mv_cookie_deleted = name.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_fake_server DEFINITION FINAL.
  PUBLIC SECTION.
    DATA request     TYPE REF TO ltcl_fake_request.
    DATA response    TYPE REF TO ltcl_fake_response.
    DATA mv_stateful TYPE i VALUE -1.

    METHODS constructor.

    METHODS set_session_stateful
      IMPORTING
        stateful TYPE i.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_fake_server IMPLEMENTATION.

  METHOD constructor.

    CREATE OBJECT request.
    CREATE OBJECT response.

  ENDMETHOD.

  METHOD set_session_stateful.

    mv_stateful = stateful.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_server TYPE REF TO ltcl_fake_server.
    DATA mo_cut    TYPE REF TO z2ui5_cl_ui5_util_http.

    METHODS setup.

    METHODS test_factory              FOR TESTING RAISING cx_static_check.
    METHODS test_factory_cloud        FOR TESTING RAISING cx_static_check.
    METHODS test_get_cdata            FOR TESTING RAISING cx_static_check.
    METHODS test_get_header_field     FOR TESTING RAISING cx_static_check.
    METHODS test_set_cdata            FOR TESTING RAISING cx_static_check.
    METHODS test_set_header_field     FOR TESTING RAISING cx_static_check.
    METHODS test_get_response_cookie  FOR TESTING RAISING cx_static_check.
    METHODS test_delete_resp_cookie   FOR TESTING RAISING cx_static_check.
    METHODS test_set_session_stateful FOR TESTING RAISING cx_static_check.
    METHODS test_request_cached       FOR TESTING RAISING cx_static_check.
    METHODS test_get_query            FOR TESTING RAISING cx_static_check.
    METHODS test_get_query_none       FOR TESTING RAISING cx_static_check.
    METHODS test_target_no_query      FOR TESTING RAISING cx_static_check.
    METHODS test_target_destination   FOR TESTING RAISING cx_static_check.
    METHODS test_target_url_query     FOR TESTING RAISING cx_static_check.
    METHODS test_target_url_has_query FOR TESTING RAISING cx_static_check.
    METHODS test_target_none_is_url   FOR TESTING RAISING cx_static_check.
    METHODS test_client_create_url    FOR TESTING RAISING cx_static_check.
    METHODS test_request_missing      FOR TESTING RAISING cx_static_check.
    METHODS test_response_missing     FOR TESTING RAISING cx_static_check.
    METHODS test_header_strips_crlf   FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD setup.

    CREATE OBJECT mo_server.
    mo_cut = z2ui5_cl_ui5_util_http=>factory( mo_server ).

  ENDMETHOD.

  METHOD test_factory.

    cl_abap_unit_assert=>assert_bound( mo_cut ).
    cl_abap_unit_assert=>assert_bound( mo_cut->mo_server_onprem ).

  ENDMETHOD.

  METHOD test_factory_cloud.

    DATA lo_cut TYPE REF TO z2ui5_cl_ui5_util_http.
    DATA temp1 TYPE REF TO ltcl_fake_request.
    DATA temp2 TYPE REF TO ltcl_fake_response.
    CREATE OBJECT temp1 TYPE ltcl_fake_request.

    CREATE OBJECT temp2 TYPE ltcl_fake_response.
    lo_cut = z2ui5_cl_ui5_util_http=>factory_cloud( req = temp1
                                                      res     = temp2 ).

    cl_abap_unit_assert=>assert_bound( lo_cut->mo_request_cloud ).
    cl_abap_unit_assert=>assert_bound( lo_cut->mo_response_cloud ).
    cl_abap_unit_assert=>assert_initial( lo_cut->mo_server_onprem ).

  ENDMETHOD.

  METHOD test_get_cdata.

    mo_server->request->mv_cdata = `{"value":"payload"}`.

    cl_abap_unit_assert=>assert_equals( exp = `{"value":"payload"}`
                                        act = mo_cut->get_cdata( ) ).

  ENDMETHOD.

  METHOD test_get_header_field.

    DATA temp6 TYPE z2ui5_cl_ui5_util_context=>ty_s_name_value.
    CLEAR temp6.
    temp6-n = `~path`.
    temp6-v = `/sap/bc/z2ui5`.
    INSERT temp6 INTO TABLE mo_server->request->mt_header.

    cl_abap_unit_assert=>assert_equals( exp = `/sap/bc/z2ui5`
                                        act = mo_cut->get_header_field( `~path` ) ).

  ENDMETHOD.

  METHOD test_set_cdata.

    mo_cut->set_cdata( `<html>hello</html>` ).

    cl_abap_unit_assert=>assert_equals( exp = `<html>hello</html>`
                                        act = mo_server->response->mv_cdata ).

  ENDMETHOD.

  METHOD test_set_header_field.
    FIELD-SYMBOLS <temp7> LIKE LINE OF mo_server->response->mt_header.
    DATA temp8 LIKE sy-tabix.

    mo_cut->set_header_field( n = `content-type`
                              v = `application/json` ).



    temp8 = sy-tabix.
    READ TABLE mo_server->response->mt_header WITH KEY n = `content-type` ASSIGNING <temp7>.
    sy-tabix = temp8.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `application/json`
        act = <temp7>-v ).

  ENDMETHOD.

  METHOD test_get_response_cookie.

    DATA temp9 TYPE z2ui5_cl_ui5_util_context=>ty_s_name_value.
    CLEAR temp9.
    temp9-n = `sap-sessionid`.
    temp9-v = `ABC123`.
    INSERT temp9 INTO TABLE mo_server->response->mt_cookie.

    cl_abap_unit_assert=>assert_equals( exp = `ABC123`
                                        act = mo_cut->get_response_cookie( `sap-sessionid` ) ).

  ENDMETHOD.

  METHOD test_delete_resp_cookie.

    mo_cut->delete_response_cookie( `sap-contextid` ).

    cl_abap_unit_assert=>assert_equals( exp = `sap-contextid`
                                        act = mo_server->response->mv_cookie_deleted ).

  ENDMETHOD.

  METHOD test_set_session_stateful.

    mo_cut->set_session_stateful( 1 ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = mo_server->mv_stateful ).

  ENDMETHOD.

  METHOD test_request_cached.

    mo_server->request->mv_cdata = `first`.

    cl_abap_unit_assert=>assert_equals( exp = `first`
                                        act = mo_cut->get_cdata( ) ).

    " the resolved request object is cached per instance - a wrapper
    " always serves exactly one request, so swapping the server's
    " request object afterwards has no effect anymore
    CREATE OBJECT mo_server->request.
    mo_server->request->mv_cdata = `second`.

    cl_abap_unit_assert=>assert_equals( exp = `first`
                                        act = mo_cut->get_cdata( ) ).

  ENDMETHOD.

  METHOD test_get_query.

    " cut at the FIRST `?` and left encoded - a later `?` is part of a value,
    " and sap-startup-params keeps its %26 / %3D exactly as they came
    DATA temp10 TYPE z2ui5_cl_ui5_util_context=>ty_s_name_value.
    CLEAR temp10.
    temp10-n = `~request_uri`.
    temp10-v = `/sap/bc/z2ui5?app_start=z&title=why?&sap-startup-params=a%3D1%26b%3D2`.
    INSERT temp10
           INTO TABLE mo_server->request->mt_header.

    cl_abap_unit_assert=>assert_equals( exp = `app_start=z&title=why?&sap-startup-params=a%3D1%26b%3D2`
                                        act = mo_cut->get_query( ) ).

  ENDMETHOD.

  METHOD test_get_query_none.

    DATA temp11 TYPE z2ui5_cl_ui5_util_context=>ty_s_name_value.
    CLEAR temp11.
    temp11-n = `~request_uri`.
    temp11-v = `/sap/bc/z2ui5`.
    INSERT temp11 INTO TABLE mo_server->request->mt_header.

    cl_abap_unit_assert=>assert_initial( mo_cut->get_query( ) ).

  ENDMETHOD.

  METHOD test_target_no_query.

    " no query: the url as given, no request_uri to override
    DATA ls_target TYPE z2ui5_cl_ui5_util_http=>ty_s_client_target.
    ls_target = z2ui5_cl_ui5_util_http=>client_target( destination = ``
                                                           url           = `https://host/path`
                                                           query         = `` ).

    cl_abap_unit_assert=>assert_equals( exp = `https://host/path`
                                        act = ls_target-url ).
    cl_abap_unit_assert=>assert_initial( ls_target-request_uri ).

  ENDMETHOD.

  METHOD test_target_destination.

    " through an RFC destination the url is the destination's: the query
    " travels as the ~request_uri header, with the leading ? the caller may
    " or may not have written
    DATA ls_target TYPE z2ui5_cl_ui5_util_http=>ty_s_client_target.
    ls_target = z2ui5_cl_ui5_util_http=>client_target( destination = `MY_DEST`
                                                           url           = ``
                                                           query         = `?a=1&b=2` ).

    cl_abap_unit_assert=>assert_initial( ls_target-url ).
    cl_abap_unit_assert=>assert_equals( exp = `?a=1&b=2`
                                        act = ls_target-request_uri ).

    ls_target = z2ui5_cl_ui5_util_http=>client_target( destination = `MY_DEST`
                                                     url           = ``
                                                     query         = `a=1` ).

    cl_abap_unit_assert=>assert_equals( exp = `?a=1`
                                        act = ls_target-request_uri ).

  ENDMETHOD.

  METHOD test_target_url_query.

    " by url the query is appended to the url itself
    DATA ls_target TYPE z2ui5_cl_ui5_util_http=>ty_s_client_target.
    ls_target = z2ui5_cl_ui5_util_http=>client_target( destination = ``
                                                           url           = `https://host/path`
                                                           query         = `?a=1` ).

    cl_abap_unit_assert=>assert_equals( exp = `https://host/path?a=1`
                                        act = ls_target-url ).
    cl_abap_unit_assert=>assert_initial( ls_target-request_uri ).

  ENDMETHOD.

  METHOD test_target_url_has_query.

    " a url that already carries a query takes the next one with &
    DATA ls_target TYPE z2ui5_cl_ui5_util_http=>ty_s_client_target.
    ls_target = z2ui5_cl_ui5_util_http=>client_target( destination = ``
                                                           url           = `https://host/path?x=0`
                                                           query         = `a=1` ).

    cl_abap_unit_assert=>assert_equals( exp = `https://host/path?x=0&a=1`
                                        act = ls_target-url ).

  ENDMETHOD.

  METHOD test_target_none_is_url.

    " the destination NONE means "by url", like no destination at all
    DATA ls_target TYPE z2ui5_cl_ui5_util_http=>ty_s_client_target.
    ls_target = z2ui5_cl_ui5_util_http=>client_target( destination = `NONE`
                                                           url           = `https://host/path`
                                                           query         = `a=1` ).

    cl_abap_unit_assert=>assert_equals( exp = `https://host/path?a=1`
                                        act = ls_target-url ).
    cl_abap_unit_assert=>assert_initial( ls_target-request_uri ).

  ENDMETHOD.

  METHOD test_client_create_url.

    " by url: a client comes back without the call going anywhere - the
    " dynamic CL_HTTP_CLIENT=>create_by_url only builds the object
    DATA lo_client TYPE REF TO object.
    lo_client = z2ui5_cl_ui5_util_http=>client_create( url = `https://localhost/never-called` ).

    cl_abap_unit_assert=>assert_bound( lo_client ).

  ENDMETHOD.

  METHOD test_request_missing.

    " a server object without a REQUEST attribute is refused with the
    " wrapper's own error, not with a dynamic ASSIGN surprise later
    DATA lo_cut TYPE REF TO z2ui5_cl_ui5_util_http.
    DATA temp2 TYPE REF TO ltcl_fake_bare_server.
        DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
    CREATE OBJECT temp2 TYPE ltcl_fake_bare_server.
    lo_cut = z2ui5_cl_ui5_util_http=>factory( temp2 ).

    TRY.
        lo_cut->get_cdata( ).
        cl_abap_unit_assert=>fail( `a server without REQUEST must raise` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx.
        cl_abap_unit_assert=>assert_char_cp( exp = `*HTTP_SERVER_REQUEST_NOT_FOUND*`
                                             act = lx->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_response_missing.

    DATA lo_cut TYPE REF TO z2ui5_cl_ui5_util_http.
    DATA temp3 TYPE REF TO ltcl_fake_bare_server.
        DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
    CREATE OBJECT temp3 TYPE ltcl_fake_bare_server.
    lo_cut = z2ui5_cl_ui5_util_http=>factory( temp3 ).

    TRY.
        lo_cut->set_cdata( `x` ).
        cl_abap_unit_assert=>fail( `a server without RESPONSE must raise` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx.
        cl_abap_unit_assert=>assert_char_cp( exp = `*HTTP_SERVER_RESPONSE_NOT_FOUND*`
                                             act = lx->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_header_strips_crlf.

    " a header name or value carrying CR/LF would split the header - both
    " characters are dropped before the stack sees them
    DATA temp12 TYPE string.
    DATA lv_cr LIKE temp12.
    DATA temp13 TYPE string.
    DATA lv_lf LIKE temp13.
    DATA ls_header TYPE z2ui5_cl_ui5_util_context=>ty_s_name_value.
    FIELD-SYMBOLS <temp4> LIKE LINE OF mo_server->response->mt_header.
    DATA temp5 LIKE sy-tabix.
    temp12 = z2ui5_cl_ui5_util_context=>cv_char_util_cr_lf(1).

    lv_cr = temp12.

    temp13 = z2ui5_cl_ui5_util_context=>cv_char_util_cr_lf+1(1).

    lv_lf = temp13.

    mo_cut->set_header_field( n = |x-{ lv_cr }test|
                              v = |one{ lv_lf }two| ).




    temp5 = sy-tabix.
    READ TABLE mo_server->response->mt_header INDEX 1 ASSIGNING <temp4>.
    sy-tabix = temp5.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_header = <temp4>.
    cl_abap_unit_assert=>assert_equals( exp = `x-test`
                                        act = ls_header-n ).
    cl_abap_unit_assert=>assert_equals( exp = `onetwo`
                                        act = ls_header-v ).

  ENDMETHOD.

ENDCLASS.
