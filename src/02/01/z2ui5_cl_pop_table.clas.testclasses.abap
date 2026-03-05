CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_factory         FOR TESTING RAISING cx_static_check.
    METHODS test_factory_title   FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial  FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.
    TYPES:
      BEGIN OF ty_row,
        name  TYPE string,
        value TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
    DATA temp1 LIKE lt_tab.
    DATA temp2 LIKE LINE OF temp1.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_table.
    CLEAR temp1.
    
    temp2-name = `A`.
    temp2-value = `1`.
    INSERT temp2 INTO TABLE temp1.
    temp2-name = `B`.
    temp2-value = `2`.
    INSERT temp2 INTO TABLE temp1.
    lt_tab = temp1.

    
    lo_pop = z2ui5_cl_pop_table=>factory( lt_tab ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_bound( lo_pop->mr_tab ).
  ENDMETHOD.

  METHOD test_factory_title.
    TYPES:
      BEGIN OF ty_row,
        col TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
    DATA temp3 LIKE lt_tab.
    DATA temp4 LIKE LINE OF temp3.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_table.
    CLEAR temp3.
    
    temp4-col = `X`.
    INSERT temp4 INTO TABLE temp3.
    lt_tab = temp3.

    
    lo_pop = z2ui5_cl_pop_table=>factory( i_tab   = lt_tab
                                                i_title = `Custom Title` ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
  ENDMETHOD.

  METHOD test_result_initial.
    TYPES:
      BEGIN OF ty_row,
        col TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_table.
    DATA ls_result TYPE z2ui5_cl_pop_table=>ty_s_result.
    lo_pop = z2ui5_cl_pop_table=>factory( lt_tab ).
    
    ls_result = lo_pop->result( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = ls_result-check_confirmed ).
  ENDMETHOD.

ENDCLASS.
