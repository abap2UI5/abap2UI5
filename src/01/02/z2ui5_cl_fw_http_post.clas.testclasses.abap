
CLASS ltcl_unit_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS:
      test_main_begin_01 FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS z2ui5_cl_fw_http_post DEFINITION LOCAL FRIENDS ltcl_unit_test.

CLASS ltcl_unit_test IMPLEMENTATION.

  METHOD test_main_begin_01.

    DATA(lv_payload) = `{"S_FRONTEND":{"ORIGIN":"ORIGIN","PATHNAME":"PATHNAME","SEARCH":""}}`.
    DATA(lo_post) = NEW z2ui5_cl_fw_http_post( lv_payload ).
    lo_post->main_begin( ).

    cl_abap_unit_assert=>assert_bound( lo_post->mo_app ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_post->ms_request-s_frontend-origin
      exp = `ORIGIN` ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_post->ms_request-s_frontend-pathname
      exp = `PATHNAME` ).

    DATA(lo_startup) = CAST z2ui5_cl_fw_app_startup( lo_post->mo_app->ms_db-app ) ##NEEDED.

  ENDMETHOD.

ENDCLASS.
