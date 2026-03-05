
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory_empty    FOR TESTING RAISING cx_static_check.
    METHODS test_factory_w_range  FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial   FOR TESTING RAISING cx_static_check.

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

ENDCLASS.
