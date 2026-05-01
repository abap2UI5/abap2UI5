
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

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_get_range.
    lo_pop = z2ui5_cl_pop_get_range=>factory( ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_w_range.

    DATA temp1 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp2 LIKE LINE OF temp1.
    DATA lt_range LIKE temp1.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_get_range.
    DATA ls_result TYPE z2ui5_cl_pop_get_range=>ty_s_result.
    CLEAR temp1.
    
    temp2-sign = `I`.
    temp2-option = `EQ`.
    temp2-low = `100`.
    INSERT temp2 INTO TABLE temp1.
    
    lt_range = temp1.

    
    lo_pop = z2ui5_cl_pop_get_range=>factory( lt_range ).
    
    ls_result = lo_pop->result( ).

    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).
    cl_abap_unit_assert=>assert_not_initial( ls_result-t_range ).

  ENDMETHOD.

  METHOD test_result_initial.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_get_range.
    DATA ls_result TYPE z2ui5_cl_pop_get_range=>ty_s_result.
    lo_pop = z2ui5_cl_pop_get_range=>factory( ).
    
    ls_result = lo_pop->result( ).
    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).

  ENDMETHOD.

  METHOD test_factory_range_count.

    DATA temp3 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp4 LIKE LINE OF temp3.
    DATA lt_range LIKE temp3.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_get_range.
    DATA ls_result TYPE z2ui5_cl_pop_get_range=>ty_s_result.
    CLEAR temp3.
    
    temp4-sign = `I`.
    temp4-option = `EQ`.
    temp4-low = `100`.
    INSERT temp4 INTO TABLE temp3.
    temp4-sign = `I`.
    temp4-option = `BT`.
    temp4-low = `200`.
    temp4-high = `300`.
    INSERT temp4 INTO TABLE temp3.
    
    lt_range = temp3.

    
    lo_pop = z2ui5_cl_pop_get_range=>factory( lt_range ).
    
    ls_result = lo_pop->result( ).

    " factory appends one empty row to the range for new entries
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( ls_result-t_range ) ).

  ENDMETHOD.

  METHOD test_factory_empty_row.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_get_range.
    DATA ls_result TYPE z2ui5_cl_pop_get_range=>ty_s_result.
    lo_pop = z2ui5_cl_pop_get_range=>factory( ).
    
    ls_result = lo_pop->result( ).

    " factory always inserts one empty row even for empty input
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( ls_result-t_range ) ).

  ENDMETHOD.

  METHOD test_factory_multi_range.

    DATA temp5 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp6 LIKE LINE OF temp5.
    DATA lt_range LIKE temp5.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_get_range.
    DATA ls_result TYPE z2ui5_cl_pop_get_range=>ty_s_result.
    CLEAR temp5.
    
    temp6-sign = `I`.
    temp6-option = `EQ`.
    temp6-low = `A`.
    INSERT temp6 INTO TABLE temp5.
    temp6-sign = `E`.
    temp6-option = `EQ`.
    temp6-low = `B`.
    INSERT temp6 INTO TABLE temp5.
    temp6-sign = `I`.
    temp6-option = `GE`.
    temp6-low = `C`.
    INSERT temp6 INTO TABLE temp5.
    
    lt_range = temp5.

    
    lo_pop = z2ui5_cl_pop_get_range=>factory( lt_range ).
    
    ls_result = lo_pop->result( ).

    " 3 input rows + 1 empty row appended by factory
    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = lines( ls_result-t_range ) ).

  ENDMETHOD.

ENDCLASS.
