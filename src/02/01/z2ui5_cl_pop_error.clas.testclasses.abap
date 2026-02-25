
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory        FOR TESTING RAISING cx_static_check.
    METHODS test_factory_div    FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.

    TRY.
        DATA(lv_val) = 1 / 0 ##NEEDED.
      CATCH cx_root INTO DATA(lx).
    ENDTRY.

    DATA(lo_pop) = z2ui5_cl_pop_error=>factory( lx ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_div.

    DATA(lx) = NEW z2ui5_cx_util_error( val = `test error` ).
    DATA(lo_pop) = z2ui5_cl_pop_error=>factory( lx ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

ENDCLASS.
