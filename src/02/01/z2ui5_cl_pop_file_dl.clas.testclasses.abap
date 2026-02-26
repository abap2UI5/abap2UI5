
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory        FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.

    DATA(lo_pop) = z2ui5_cl_pop_file_dl=>factory( `test_content` ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_result_initial.

    DATA(lo_pop) = z2ui5_cl_pop_file_dl=>factory( `abc` ).
    cl_abap_unit_assert=>assert_false( lo_pop->result( ) ).

  ENDMETHOD.

ENDCLASS.
