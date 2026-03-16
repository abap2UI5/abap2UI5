CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_factory               FOR TESTING RAISING cx_static_check.
    METHODS test_factory_empty_msgs    FOR TESTING RAISING cx_static_check.
    METHODS test_factory_msg_count     FOR TESTING RAISING cx_static_check.
    METHODS test_factory_msg_type      FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.
    DATA lt_msg TYPE z2ui5_cl_pop_bal=>ty_t_msg.
    DATA temp1 TYPE z2ui5_cl_pop_bal=>ty_t_msg.
    DATA temp2 LIKE LINE OF temp1.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_bal.
    CLEAR temp1.
    
    temp2-type = `E`.
    temp2-title = `Error msg`.
    temp2-message = `Something failed`.
    INSERT temp2 INTO TABLE temp1.
    lt_msg = temp1.

    
    lo_pop = z2ui5_cl_pop_bal=>factory( lt_msg ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
  ENDMETHOD.

  METHOD test_factory_empty_msgs.
    DATA lt_msg TYPE z2ui5_cl_pop_bal=>ty_t_msg.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_bal.
    lo_pop = z2ui5_cl_pop_bal=>factory( lt_msg ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lo_pop->mt_msg )
      exp = 0 ).
  ENDMETHOD.

  METHOD test_factory_msg_count.
    DATA lt_msg TYPE z2ui5_cl_pop_bal=>ty_t_msg.
    DATA temp3 TYPE z2ui5_cl_pop_bal=>ty_t_msg.
    DATA temp4 LIKE LINE OF temp3.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_bal.
    CLEAR temp3.
    
    temp4-type = `E`.
    temp4-title = `Error msg`.
    temp4-message = `Something failed`.
    INSERT temp4 INTO TABLE temp3.
    temp4-type = `W`.
    temp4-title = `Warn msg`.
    temp4-message = `Watch out`.
    INSERT temp4 INTO TABLE temp3.
    lt_msg = temp3.

    
    lo_pop = z2ui5_cl_pop_bal=>factory( lt_msg ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lo_pop->mt_msg )
      exp = 2 ).
  ENDMETHOD.

  METHOD test_factory_msg_type.
    DATA lt_msg TYPE z2ui5_cl_pop_bal=>ty_t_msg.
    DATA temp5 TYPE z2ui5_cl_pop_bal=>ty_t_msg.
    DATA temp6 LIKE LINE OF temp5.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_bal.
    DATA temp7 LIKE LINE OF lo_pop->mt_msg.
    DATA temp8 LIKE sy-tabix.
    CLEAR temp5.
    
    temp6-type = `E`.
    temp6-title = `Error msg`.
    temp6-message = `Something failed`.
    INSERT temp6 INTO TABLE temp5.
    lt_msg = temp5.

    
    lo_pop = z2ui5_cl_pop_bal=>factory( lt_msg ).

    
    
    temp8 = sy-tabix.
    READ TABLE lo_pop->mt_msg INDEX 1 INTO temp7.
    sy-tabix = temp8.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
      act = temp7-message
      exp = `Something failed` ).
  ENDMETHOD.

ENDCLASS.
