CLASS ltcl_test_http_handler DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION LONG.

  PRIVATE SECTION.
    METHODS test_http_get_status   FOR TESTING RAISING cx_static_check.
    METHODS test_http_get_html     FOR TESTING RAISING cx_static_check.
    METHODS test_http_get_ui5_boot FOR TESTING RAISING cx_static_check.
    METHODS test_http_post_ok      FOR TESTING RAISING cx_static_check.
    METHODS test_http_post_error   FOR TESTING RAISING cx_static_check.
    METHODS test_main_get_routing  FOR TESTING RAISING cx_static_check.
    METHODS test_main_post_routing FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_test_http_handler IMPLEMENTATION.

  METHOD test_http_get_status.

    DATA ls_result TYPE z2ui5_if_core_types=>ty_s_http_res.

    ls_result = z2ui5_cl_http_handler=>_http_get( ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = ls_result-status_code ).

    cl_abap_unit_assert=>assert_equals( exp = `success`
                                        act = ls_result-status_reason ).

  ENDMETHOD.

  METHOD test_http_get_html.

    DATA ls_result TYPE z2ui5_if_core_types=>ty_s_http_res.
    DATA temp1 TYPE xsdboolean.
    DATA temp2 TYPE xsdboolean.
    DATA temp3 TYPE xsdboolean.
    DATA temp4 TYPE xsdboolean.
    DATA temp5 TYPE xsdboolean.
    DATA temp6 TYPE xsdboolean.

    ls_result = z2ui5_cl_http_handler=>_http_get( ).

    cl_abap_unit_assert=>assert_not_initial( ls_result-body ).

    
    temp4 = boolc( ls_result-body CS `<!DOCTYPE html>` ).
    temp1 = temp4.
    cl_abap_unit_assert=>assert_true( temp1 ).

    
    temp5 = boolc( ls_result-body CS `<html` ).
    temp2 = temp5.
    cl_abap_unit_assert=>assert_true( temp2 ).

    
    temp6 = boolc( ls_result-body CS `</html>` ).
    temp3 = temp6.
    cl_abap_unit_assert=>assert_true( temp3 ).

  ENDMETHOD.

  METHOD test_http_get_ui5_boot.

    DATA ls_result TYPE z2ui5_if_core_types=>ty_s_http_res.
    DATA temp4 TYPE xsdboolean.
    DATA temp5 TYPE xsdboolean.
    DATA temp7 TYPE xsdboolean.
    DATA temp8 TYPE xsdboolean.

    ls_result = z2ui5_cl_http_handler=>_http_get( ).

    
    temp7 = boolc( ls_result-body CS `sap-ui-bootstrap` ).
    temp4 = temp7.
    cl_abap_unit_assert=>assert_true( temp4 ).

    
    temp8 = boolc( ls_result-body CS `z2ui5` ).
    temp5 = temp8.
    cl_abap_unit_assert=>assert_true( temp5 ).

  ENDMETHOD.

  METHOD test_http_post_ok.

    DATA ls_req TYPE z2ui5_cl_util_http=>ty_s_http_req.
    DATA ls_result TYPE z2ui5_if_core_types=>ty_s_http_res.
    DATA temp6 TYPE xsdboolean.
    DATA temp9 TYPE xsdboolean.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    ls_req-method = `POST`.
    ls_req-body = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":""}}}`.

    ls_result = z2ui5_cl_http_handler=>_http_post( ls_req ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = ls_result-status_code ).

    
    temp9 = boolc( ls_result-body CS `S_FRONT` ).
    temp6 = temp9.
    cl_abap_unit_assert=>assert_true( temp6 ).

  ENDMETHOD.

  METHOD test_http_post_error.

    DATA ls_req TYPE z2ui5_cl_util_http=>ty_s_http_req.
    DATA ls_result TYPE z2ui5_if_core_types=>ty_s_http_res.
    DATA temp7 TYPE xsdboolean.
    DATA temp10 TYPE xsdboolean.

    ls_req-method = `POST`.
    ls_req-body = `not valid json at all!!!`.

    ls_result = z2ui5_cl_http_handler=>_http_post( ls_req ).

    cl_abap_unit_assert=>assert_equals( exp = 500
                                        act = ls_result-status_code ).

    
    temp10 = boolc( ls_result-body CS `abap2UI5 Error` ).
    temp7 = temp10.
    cl_abap_unit_assert=>assert_true( temp7 ).

  ENDMETHOD.

  METHOD test_main_get_routing.

    DATA ls_req TYPE z2ui5_cl_util_http=>ty_s_http_req.
    DATA ls_result TYPE z2ui5_if_core_types=>ty_s_http_res.
    DATA temp8 TYPE xsdboolean.
    DATA temp11 TYPE xsdboolean.

    ls_req-method = `GET`.

    ls_result = z2ui5_cl_http_handler=>_main( ls_req ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = ls_result-status_code ).

    
    temp11 = boolc( ls_result-body CS `<!DOCTYPE html>` ).
    temp8 = temp11.
    cl_abap_unit_assert=>assert_true( temp8 ).

  ENDMETHOD.

  METHOD test_main_post_routing.

    DATA ls_req TYPE z2ui5_cl_util_http=>ty_s_http_req.
    DATA ls_result TYPE z2ui5_if_core_types=>ty_s_http_res.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    ls_req-method = `POST`.
    ls_req-body = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":""}}}`.

    ls_result = z2ui5_cl_http_handler=>_main( ls_req ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = ls_result-status_code ).

  ENDMETHOD.

ENDCLASS.
