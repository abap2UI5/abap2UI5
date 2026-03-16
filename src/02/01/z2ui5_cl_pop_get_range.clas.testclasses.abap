
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory_empty       FOR TESTING RAISING cx_static_check.
    METHODS test_factory_w_range     FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial      FOR TESTING RAISING cx_static_check.
    METHODS test_factory_range_count FOR TESTING RAISING cx_static_check.
    METHODS test_factory_empty_row   FOR TESTING RAISING cx_static_check.
    METHODS test_factory_multi_range FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory_empty.

    DATA(lo_pop) = z2ui5_cl_pop_get_range=>factory( ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_w_range.

    DATA(lt_range) = VALUE z2ui5_cl_util=>ty_t_range(
      ( sign = `I` option = `EQ` low = `100` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_get_range=>factory( lt_range ).
    DATA(ls_result) = lo_pop->result( ).

    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).
    cl_abap_unit_assert=>assert_not_initial( ls_result-t_range ).

  ENDMETHOD.

  METHOD test_result_initial.

    DATA(lo_pop) = z2ui5_cl_pop_get_range=>factory( ).
    DATA(ls_result) = lo_pop->result( ).
    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).

  ENDMETHOD.

  METHOD test_factory_range_count.

    DATA(lt_range) = VALUE z2ui5_cl_util=>ty_t_range(
      ( sign = `I` option = `EQ` low = `100` )
      ( sign = `I` option = `BT` low = `200` high = `300` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_get_range=>factory( lt_range ).
    DATA(ls_result) = lo_pop->result( ).

    " factory appends one empty row to the range for new entries
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( ls_result-t_range ) ).

  ENDMETHOD.

  METHOD test_factory_empty_row.

    DATA(lo_pop) = z2ui5_cl_pop_get_range=>factory( ).
    DATA(ls_result) = lo_pop->result( ).

    " factory always inserts one empty row even for empty input
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( ls_result-t_range ) ).

  ENDMETHOD.

  METHOD test_factory_multi_range.

    DATA(lt_range) = VALUE z2ui5_cl_util=>ty_t_range(
      ( sign = `I` option = `EQ` low = `A` )
      ( sign = `E` option = `EQ` low = `B` )
      ( sign = `I` option = `GE` low = `C` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_get_range=>factory( lt_range ).
    DATA(ls_result) = lo_pop->result( ).

    " 3 input rows + 1 empty row appended by factory
    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = lines( ls_result-t_range ) ).

  ENDMETHOD.

ENDCLASS.
