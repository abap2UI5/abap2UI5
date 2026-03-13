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

ENDCLASS.
