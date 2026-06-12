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
    lt_msg = VALUE #( ( type = `E` title = `Error msg` message = `Something failed` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_bal=>factory( lt_msg ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
  ENDMETHOD.

  METHOD test_factory_empty_msgs.
    DATA lt_msg TYPE z2ui5_cl_pop_bal=>ty_t_msg.

    DATA(lo_pop) = z2ui5_cl_pop_bal=>factory( lt_msg ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lo_pop->mt_msg )
      exp = 0 ).
  ENDMETHOD.

  METHOD test_factory_msg_count.
    DATA lt_msg TYPE z2ui5_cl_pop_bal=>ty_t_msg.
    lt_msg = VALUE #( ( type = `E` title = `Error msg` message = `Something failed` )
                      ( type = `W` title = `Warn msg`  message = `Watch out` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_bal=>factory( lt_msg ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lo_pop->mt_msg )
      exp = 2 ).
  ENDMETHOD.

  METHOD test_factory_msg_type.
    DATA lt_msg TYPE z2ui5_cl_pop_bal=>ty_t_msg.
    lt_msg = VALUE #( ( type = `E` title = `Error msg` message = `Something failed` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_bal=>factory( lt_msg ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_pop->mt_msg[ 1 ]-message
      exp = `Something failed` ).
  ENDMETHOD.

  METHOD test_factory_w_cx.

    TRY.
        DATA(lv_val) = 1 / 0 ##NEEDED.
      CATCH cx_root INTO DATA(lx).
    ENDTRY.

    DATA(lo_pop) = z2ui5_cl_pop_bal=>factory( lx ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_not_initial( lo_pop->mt_msg ).

  ENDMETHOD.

  METHOD test_factory_save_key.

    DATA lt_msg TYPE z2ui5_cl_pop_bal=>ty_t_msg.
    lt_msg = VALUE #( ( type = `E` title = `Error msg` message = `Something failed` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_bal=>factory( i_messages   = lt_msg
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
    lt_msg = VALUE #( ( type = `E` id = `MSG_ID` no = `001` text = `Something failed` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_bal=>factory( lt_msg ).

    cl_abap_unit_assert=>assert_equals( act = lines( lo_pop->mt_msg_bal )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lo_pop->mt_msg_bal[ 1 ]-text
                                        exp = `Something failed` ).
    cl_abap_unit_assert=>assert_equals( act = lo_pop->mv_check_save
                                        exp = abap_false ).

  ENDMETHOD.

  METHOD test_factory_by_db.

    DATA(lo_pop) = z2ui5_cl_pop_bal=>factory_by_db( i_object     = `TEST`
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
