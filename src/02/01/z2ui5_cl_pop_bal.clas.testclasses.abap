CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_factory FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.
    DATA lt_msg TYPE z2ui5_cl_pop_bal=>ty_t_msg.
    lt_msg = VALUE #( ( type = `E` title = `Error msg` message = `Something failed` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_bal=>factory( lt_msg ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
  ENDMETHOD.

ENDCLASS.
