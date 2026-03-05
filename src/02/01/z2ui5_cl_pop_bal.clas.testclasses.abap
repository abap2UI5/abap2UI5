CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_factory FOR TESTING RAISING cx_static_check.
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

ENDCLASS.
