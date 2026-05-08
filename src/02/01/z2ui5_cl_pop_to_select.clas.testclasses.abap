
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory              FOR TESTING RAISING cx_static_check.
    METHODS test_factory_multi        FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial       FOR TESTING RAISING cx_static_check.
    METHODS test_factory_title        FOR TESTING RAISING cx_static_check.
    METHODS test_factory_refs_bound   FOR TESTING RAISING cx_static_check.
    METHODS test_factory_data_count   FOR TESTING RAISING cx_static_check.
    METHODS test_factory_default_title FOR TESTING RAISING cx_static_check.

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
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_to_select.
    CLEAR temp1.
    
    temp2-name = `A`.
    temp2-value = `1`.
    INSERT temp2 INTO TABLE temp1.
    temp2-name = `B`.
    temp2-value = `2`.
    INSERT temp2 INTO TABLE temp1.
    lt_tab = temp1.

    
    lo_pop = z2ui5_cl_pop_to_select=>factory( lt_tab ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_multi.

    TYPES:
      BEGIN OF ty_row,
        name TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
    DATA temp3 LIKE lt_tab.
    DATA temp4 LIKE LINE OF temp3.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_to_select.
    CLEAR temp3.
    
    temp4-name = `X`.
    INSERT temp4 INTO TABLE temp3.
    lt_tab = temp3.

    
    lo_pop = z2ui5_cl_pop_to_select=>factory(
      i_tab         = lt_tab
      i_multiselect = abap_true ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_result_initial.

    TYPES:
      BEGIN OF ty_row,
        name TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
    DATA temp5 LIKE lt_tab.
    DATA temp6 LIKE LINE OF temp5.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_to_select.
    DATA ls_result TYPE z2ui5_cl_pop_to_select=>ty_s_result.
    CLEAR temp5.
    
    temp6-name = `A`.
    INSERT temp6 INTO TABLE temp5.
    lt_tab = temp5.

    
    lo_pop = z2ui5_cl_pop_to_select=>factory( lt_tab ).
    
    ls_result = lo_pop->result( ).
    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).

  ENDMETHOD.

  METHOD test_factory_title.

    TYPES:
      BEGIN OF ty_row,
        name TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
    DATA temp7 LIKE lt_tab.
    DATA temp8 LIKE LINE OF temp7.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_to_select.
    CLEAR temp7.
    
    temp8-name = `A`.
    INSERT temp8 INTO TABLE temp7.
    lt_tab = temp7.

    
    lo_pop = z2ui5_cl_pop_to_select=>factory(
      i_tab   = lt_tab
      i_title = `Custom` ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_refs_bound.

    TYPES:
      BEGIN OF ty_row,
        name TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
    DATA temp9 LIKE lt_tab.
    DATA temp10 LIKE LINE OF temp9.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_to_select.
    DATA ls_result TYPE z2ui5_cl_pop_to_select=>ty_s_result.
    CLEAR temp9.
    
    temp10-name = `X`.
    INSERT temp10 INTO TABLE temp9.
    lt_tab = temp9.

    
    lo_pop = z2ui5_cl_pop_to_select=>factory( lt_tab ).
    
    ls_result = lo_pop->result( ).

    cl_abap_unit_assert=>assert_bound( lo_pop->mr_tab ).
    cl_abap_unit_assert=>assert_bound( ls_result-row ).
    cl_abap_unit_assert=>assert_bound( ls_result-table ).

  ENDMETHOD.

  METHOD test_factory_data_count.

    TYPES:
      BEGIN OF ty_row,
        name TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
    DATA temp11 LIKE lt_tab.
    DATA temp12 LIKE LINE OF temp11.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_to_select.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    CLEAR temp11.
    
    temp12-name = `A`.
    INSERT temp12 INTO TABLE temp11.
    temp12-name = `B`.
    INSERT temp12 INTO TABLE temp11.
    temp12-name = `C`.
    INSERT temp12 INTO TABLE temp11.
    lt_tab = temp11.

    
    lo_pop = z2ui5_cl_pop_to_select=>factory( lt_tab ).

    
    ASSIGN lo_pop->mr_tab->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( <tab> ) ).

  ENDMETHOD.

  METHOD test_factory_default_title.

    TYPES:
      BEGIN OF ty_row,
        name TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.

    DATA lo_single TYPE REF TO z2ui5_cl_pop_to_select.
    DATA lo_multi TYPE REF TO z2ui5_cl_pop_to_select.
    lo_single = z2ui5_cl_pop_to_select=>factory( lt_tab ).
    
    lo_multi  = z2ui5_cl_pop_to_select=>factory(
      i_tab         = lt_tab
      i_multiselect = abap_true ).

    cl_abap_unit_assert=>assert_bound( lo_single ).
    cl_abap_unit_assert=>assert_bound( lo_multi ).

  ENDMETHOD.

ENDCLASS.
