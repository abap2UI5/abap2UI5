
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory_w_bapiret   FOR TESTING RAISING cx_static_check.
    METHODS test_factory_w_cx        FOR TESTING RAISING cx_static_check.
    METHODS test_factory_msg_type    FOR TESTING RAISING cx_static_check.
    METHODS test_factory_empty_input FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory_w_bapiret.
    DATA temp1 TYPE bapirettab.
    DATA temp2 LIKE LINE OF temp1.
    DATA lt_msg LIKE temp1.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_messages.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    
    CLEAR temp1.
    
    temp2-type = `E`.
    temp2-id = `MSG1`.
    temp2-number = `001`.
    temp2-message = `Error occurred`.
    INSERT temp2 INTO TABLE temp1.
    temp2-type = `I`.
    temp2-id = `MSG2`.
    temp2-number = `002`.
    temp2-message = `Info message`.
    INSERT temp2 INTO TABLE temp1.
    
    lt_msg = temp1.

    
    lo_pop = z2ui5_cl_pop_messages=>factory( lt_msg ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_pop->mt_msg ) ).

  ENDMETHOD.

  METHOD test_factory_w_cx.
        DATA lv_val TYPE i.
        DATA lx TYPE REF TO cx_root.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_messages.

    TRY.
        
        lv_val = 1 / 0 ##NEEDED.
        
      CATCH cx_root INTO lx.
    ENDTRY.

    
    lo_pop = z2ui5_cl_pop_messages=>factory( lx ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_not_initial( lo_pop->mt_msg ).

  ENDMETHOD.

  METHOD test_factory_msg_type.
    DATA temp3 TYPE bapirettab.
    DATA temp4 LIKE LINE OF temp3.
    DATA lt_msg LIKE temp3.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_messages.
    DATA temp5 LIKE LINE OF lo_pop->mt_msg.
    DATA temp6 LIKE sy-tabix.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    
    CLEAR temp3.
    
    temp4-type = `E`.
    temp4-message = `Error`.
    INSERT temp4 INTO TABLE temp3.
    temp4-type = `W`.
    temp4-message = `Warning`.
    INSERT temp4 INTO TABLE temp3.
    temp4-type = `S`.
    temp4-message = `Success`.
    INSERT temp4 INTO TABLE temp3.
    
    lt_msg = temp3.

    
    lo_pop = z2ui5_cl_pop_messages=>factory( lt_msg ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lo_pop->mt_msg ) ).
    
    
    temp6 = sy-tabix.
    READ TABLE lo_pop->mt_msg INDEX 1 INTO temp5.
    sy-tabix = temp6.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( temp5-type ).

  ENDMETHOD.

  METHOD test_factory_empty_input.

    DATA lx TYPE REF TO z2ui5_cx_util_error.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_messages.
    CREATE OBJECT lx TYPE z2ui5_cx_util_error EXPORTING val = `test`.
    
    lo_pop = z2ui5_cl_pop_messages=>factory( lx ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_not_initial( lo_pop->mt_msg ).

  ENDMETHOD.

ENDCLASS.
