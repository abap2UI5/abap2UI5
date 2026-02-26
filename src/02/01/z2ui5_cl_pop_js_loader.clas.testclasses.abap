CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_factory             FOR TESTING RAISING cx_static_check.
    METHODS test_factory_open_ui5    FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial      FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.
    DATA(lo_pop) = z2ui5_cl_pop_js_loader=>factory(
      i_js     = `console.log("hello");`
      i_result = `DONE` ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_equals( exp = `DONE`
                                        act = lo_pop->result( ) ).
  ENDMETHOD.

  METHOD test_factory_open_ui5.
    DATA(lo_pop) = z2ui5_cl_pop_js_loader=>factory_check_open_ui5( ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
  ENDMETHOD.

  METHOD test_result_initial.
    DATA(lo_pop) = z2ui5_cl_pop_js_loader=>factory( `alert(1);` ).

    cl_abap_unit_assert=>assert_equals( exp = `LOADED`
                                        act = lo_pop->result( ) ).
  ENDMETHOD.

ENDCLASS.
