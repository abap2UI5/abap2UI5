CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_factory               FOR TESTING RAISING cx_static_check.
    METHODS test_factory_empty_msgs    FOR TESTING RAISING cx_static_check.
    METHODS test_factory_msg_count     FOR TESTING RAISING cx_static_check.
    METHODS test_factory_msg_type      FOR TESTING RAISING cx_static_check.
    METHODS test_factory_w_cx          FOR TESTING RAISING cx_static_check.
    METHODS test_factory_save_key      FOR TESTING RAISING cx_static_check.
    METHODS test_factory_msg_bal       FOR TESTING RAISING cx_static_check.
    METHODS test_factory_by_db         FOR TESTING RAISING cx_static_check.
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

  METHOD test_factory_w_cx.
        DATA lv_val TYPE i.
        DATA lx TYPE REF TO cx_root.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_bal.

    TRY.

        lv_val = 1 / 0 ##NEEDED.

      CATCH cx_root INTO lx.
    ENDTRY.


    lo_pop = z2ui5_cl_pop_bal=>factory( lx ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_not_initial( lo_pop->mt_msg ).

  ENDMETHOD.

  METHOD test_factory_save_key.

    DATA lt_msg TYPE z2ui5_cl_pop_bal=>ty_t_msg.
    DATA temp9 TYPE z2ui5_cl_pop_bal=>ty_t_msg.
    DATA temp10 LIKE LINE OF temp9.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_bal.
    CLEAR temp9.

    temp10-type = `E`.
    temp10-title = `Error msg`.
    temp10-message = `Something failed`.
    INSERT temp10 INTO TABLE temp9.
    lt_msg = temp9.


    lo_pop = z2ui5_cl_pop_bal=>factory( i_messages   = lt_msg
                                              i_object     = `TEST`
                                              i_subobject  = `SUB`
                                              i_extnumber  = `EXT`
                                              i_check_save = abap_true ).

    cl_abap_unit_assert=>assert_equals( act = lo_pop->mv_object
                                        exp = `TEST` ).
    cl_abap_unit_assert=>assert_equals( act = lo_pop->mv_subobject
                                        exp = `SUB` ).
    cl_abap_unit_assert=>assert_equals( act = lo_pop->mv_extnumber
                                        exp = `EXT` ).
    cl_abap_unit_assert=>assert_equals( act = lo_pop->mv_check_save
                                        exp = abap_true ).

  ENDMETHOD.

  METHOD test_factory_msg_bal.

    DATA lt_msg TYPE z2ui5_cl_util=>ty_t_msg.
    DATA temp11 TYPE z2ui5_cl_util=>ty_t_msg.
    DATA temp12 LIKE LINE OF temp11.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_bal.
    DATA temp13 LIKE LINE OF lo_pop->mt_msg_bal.
    DATA temp14 LIKE sy-tabix.
    CLEAR temp11.

    temp12-type = `E`.
    temp12-id = `MSG_ID`.
    temp12-no = `001`.
    temp12-text = `Something failed`.
    INSERT temp12 INTO TABLE temp11.
    lt_msg = temp11.


    lo_pop = z2ui5_cl_pop_bal=>factory( lt_msg ).

    cl_abap_unit_assert=>assert_equals( act = lines( lo_pop->mt_msg_bal )
                                        exp = 1 ).


    temp14 = sy-tabix.
    READ TABLE lo_pop->mt_msg_bal INDEX 1 INTO temp13.
    sy-tabix = temp14.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( act = temp13-text
                                        exp = `Something failed` ).
    cl_abap_unit_assert=>assert_equals( act = lo_pop->mv_check_save
                                        exp = abap_false ).

  ENDMETHOD.

  METHOD test_factory_by_db.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_bal.
    lo_pop = z2ui5_cl_pop_bal=>factory_by_db( i_object     = `TEST`
                                                    i_subobject  = `SUB`
                                                    i_extnumber  = `EXT`
                                                    i_check_save = abap_true ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_equals( act = lo_pop->mv_object
                                        exp = `TEST` ).
    cl_abap_unit_assert=>assert_equals( act = lo_pop->mv_check_save
                                        exp = abap_true ).

  ENDMETHOD.

ENDCLASS.
