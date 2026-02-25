
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory          FOR TESTING RAISING cx_static_check.
    METHODS test_factory_with_val FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial   FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.

    DATA(lo_pop) = z2ui5_cl_pop_input_val=>factory( ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_with_val.

    DATA(lo_pop) = z2ui5_cl_pop_input_val=>factory(
      val   = `initial value`
      title = `Custom Title`
      text  = `Enter value` ).

    DATA(ls_result) = lo_pop->result( ).
    cl_abap_unit_assert=>assert_equals( exp = `initial value`
                                        act = ls_result-value ).
    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).

  ENDMETHOD.

  METHOD test_result_initial.

    DATA(lo_pop) = z2ui5_cl_pop_input_val=>factory( ).
    DATA(ls_result) = lo_pop->result( ).
    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).
    cl_abap_unit_assert=>assert_initial( ls_result-value ).

  ENDMETHOD.

ENDCLASS.
