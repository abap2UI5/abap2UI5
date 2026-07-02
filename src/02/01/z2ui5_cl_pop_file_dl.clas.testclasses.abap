
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory        FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_file_dl.
    lo_pop = z2ui5_cl_pop_file_dl=>factory( i_file = `test_content`
                                                  i_name = `test.csv` ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_equals( exp = `test_content`
                                        act = lo_pop->mv_value ).
    cl_abap_unit_assert=>assert_equals( exp = `data:text/csv;base64,`
                                        act = lo_pop->mv_type ).
    cl_abap_unit_assert=>assert_equals( exp = `test.csv`
                                        act = lo_pop->mv_name ).
    " 12 characters -> 0.01 kB, must not truncate to 0
    cl_abap_unit_assert=>assert_equals( exp = `0.01`
                                        act = lo_pop->mv_size ).

  ENDMETHOD.

  METHOD test_result_initial.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_file_dl.
    lo_pop = z2ui5_cl_pop_file_dl=>factory( `abc` ).
    cl_abap_unit_assert=>assert_false( lo_pop->result( ) ).

  ENDMETHOD.

ENDCLASS.
