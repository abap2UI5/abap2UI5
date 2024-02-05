
CLASS ltcl_post_handler_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS:
      load_startup_app FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS z2ui5_cl_fw_http_post DEFINITION LOCAL FRIENDS ltcl_post_handler_test.

CLASS ltcl_post_handler_test IMPLEMENTATION.

  METHOD load_startup_app.

*    DATA(lv_payload) = `{"S_FRONTEND":{"ORIGIN":"ORIGIN","PATHNAME":"PATHNAME","SEARCH":""}}`.
*    DATA(lo_post) = NEW z2ui5_cl_fw_http_post( lv_payload ).
*    lo_post->main_begin( ).
*
*    cl_abap_unit_assert=>assert_bound( lo_post->cntrl ).
*
*    cl_abap_unit_assert=>assert_equals(
*      act = lo_post->ms_request-s_frontend-origin
*      exp = `ORIGIN` ).
*
*    cl_abap_unit_assert=>assert_equals(
*      act = lo_post->ms_request-s_frontend-pathname
*      exp = `PATHNAME` ).
*
*    DATA(lo_startup) = CAST z2ui5_cl_fw_app_startup( lo_post->cntrl->ms_draft-app ) ##NEEDED.

  ENDMETHOD.

ENDCLASS.
