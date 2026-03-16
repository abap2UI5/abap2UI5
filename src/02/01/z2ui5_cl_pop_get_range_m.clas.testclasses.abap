
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory          FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial   FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.

    DATA temp1 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp2 LIKE LINE OF temp1.
    DATA temp3 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp4 LIKE LINE OF temp3.
    DATA lt_filter LIKE temp1.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_get_range_m.
    CLEAR temp1.
    
    temp2-name = `CARRID`.
    
    CLEAR temp3.
    
    temp4-sign = `I`.
    temp4-option = `EQ`.
    temp4-low = `AA`.
    INSERT temp4 INTO TABLE temp3.
    temp2-t_range = temp3.
    INSERT temp2 INTO TABLE temp1.
    temp2-name = `CONNID`.
    INSERT temp2 INTO TABLE temp1.
    
    lt_filter = temp1.

    
    lo_pop = z2ui5_cl_pop_get_range_m=>factory( lt_filter ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_result_initial.

    DATA temp3 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp4 LIKE LINE OF temp3.
    DATA lt_filter LIKE temp3.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_get_range_m.
    DATA ls_result TYPE z2ui5_cl_pop_get_range_m=>ty_s_result.
    CLEAR temp3.
    
    temp4-name = `FIELD1`.
    INSERT temp4 INTO TABLE temp3.
    
    lt_filter = temp3.

    
    lo_pop = z2ui5_cl_pop_get_range_m=>factory( lt_filter ).
    
    ls_result = lo_pop->result( ).
    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( ls_result-t_filter ) ).

  ENDMETHOD.

ENDCLASS.
