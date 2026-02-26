CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_factory          FOR TESTING RAISING cx_static_check.
    METHODS test_factory_defaults FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial   FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.
    DATA(lo_pop) = z2ui5_cl_pop_pdf=>factory(
      i_title = `My PDF`
      i_pdf   = `data:application/pdf;base64,AAAA` ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_equals( exp = `data:application/pdf;base64,AAAA`
                                        act = lo_pop->mv_pdf ).
  ENDMETHOD.

  METHOD test_factory_defaults.
    DATA(lo_pop) = z2ui5_cl_pop_pdf=>factory( `test_data` ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_equals( exp = `test_data`
                                        act = lo_pop->mv_pdf ).
  ENDMETHOD.

  METHOD test_result_initial.
    DATA(lo_pop) = z2ui5_cl_pop_pdf=>factory( `test` ).
    DATA(ls_result) = lo_pop->result( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = ls_result-check_confirmed ).
    cl_abap_unit_assert=>assert_initial( ls_result-text ).
  ENDMETHOD.

ENDCLASS.
