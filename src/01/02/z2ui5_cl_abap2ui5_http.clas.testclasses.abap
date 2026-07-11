CLASS ltcl_fake_request DEFINITION FINAL.
  PUBLIC SECTION.
    DATA mv_cdata  TYPE string.
    DATA mt_header TYPE z2ui5_cl_abap2ui5_context=>ty_t_name_value.

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

    TRY.
        value = mt_header[ n = name ]-v.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_fake_response DEFINITION FINAL.
  PUBLIC SECTION.
    DATA mv_cdata          TYPE string.
    DATA mt_header         TYPE z2ui5_cl_abap2ui5_context=>ty_t_name_value.
    DATA mt_cookie         TYPE z2ui5_cl_abap2ui5_context=>ty_t_name_value.
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

    INSERT VALUE #( n = name
                    v = value ) INTO TABLE mt_header.

  ENDMETHOD.

  METHOD get_cookie.

    CLEAR value.
    TRY.
        value = mt_cookie[ n = name ]-v.
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

    request  = NEW #( ).
    response = NEW #( ).

  ENDMETHOD.

  METHOD set_session_stateful.

    mv_stateful = stateful.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_server TYPE REF TO ltcl_fake_server.
    DATA mo_cut    TYPE REF TO z2ui5_cl_abap2ui5_http.

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

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD setup.

    mo_server = NEW #( ).
    mo_cut = z2ui5_cl_abap2ui5_http=>factory( mo_server ).

  ENDMETHOD.

  METHOD test_factory.

    cl_abap_unit_assert=>assert_bound( mo_cut ).
    cl_abap_unit_assert=>assert_bound( mo_cut->mo_server_onprem ).

  ENDMETHOD.

  METHOD test_factory_cloud.

    DATA(lo_cut) = z2ui5_cl_abap2ui5_http=>factory_cloud( req = NEW ltcl_fake_request( )
                                                      res     = NEW ltcl_fake_response( ) ).

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

    INSERT VALUE #( n = `~path`
                    v = `/sap/bc/z2ui5` ) INTO TABLE mo_server->request->mt_header.

    cl_abap_unit_assert=>assert_equals( exp = `/sap/bc/z2ui5`
                                        act = mo_cut->get_header_field( `~path` ) ).

  ENDMETHOD.

  METHOD test_set_cdata.

    mo_cut->set_cdata( `<html>hello</html>` ).

    cl_abap_unit_assert=>assert_equals( exp = `<html>hello</html>`
                                        act = mo_server->response->mv_cdata ).

  ENDMETHOD.

  METHOD test_set_header_field.

    mo_cut->set_header_field( n = `content-type`
                              v = `application/json` ).

    cl_abap_unit_assert=>assert_equals(
        exp = `application/json`
        act = mo_server->response->mt_header[ n = `content-type` ]-v ).

  ENDMETHOD.

  METHOD test_get_response_cookie.

    INSERT VALUE #( n = `sap-sessionid`
                    v = `ABC123` ) INTO TABLE mo_server->response->mt_cookie.

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

ENDCLASS.
