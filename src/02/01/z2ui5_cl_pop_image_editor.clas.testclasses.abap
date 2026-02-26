CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_factory          FOR TESTING RAISING cx_static_check.
    METHODS test_factory_defaults FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial   FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.
    DATA(lo_pop) = z2ui5_cl_pop_image_editor=>factory(
      iv_image       = `data:image/png;base64,AAAA`
      iv_title       = `Edit`
      iv_save_text   = `Done`
      iv_cancel_text = `Abort` ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
  ENDMETHOD.

  METHOD test_factory_defaults.
    DATA(lo_pop) = z2ui5_cl_pop_image_editor=>factory( `test_img` ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
  ENDMETHOD.

  METHOD test_result_initial.
    DATA(lo_pop) = z2ui5_cl_pop_image_editor=>factory( `test_img` ).
    DATA(ls_result) = lo_pop->result( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = ls_result-check_confirmed ).
    cl_abap_unit_assert=>assert_equals( exp = `test_img`
                                        act = ls_result-image ).
  ENDMETHOD.

ENDCLASS.
