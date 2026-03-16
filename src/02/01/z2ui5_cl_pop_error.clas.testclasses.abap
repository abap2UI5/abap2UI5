
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory        FOR TESTING RAISING cx_static_check.
    METHODS test_factory_div    FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.
        DATA lv_val TYPE i.
        DATA lx TYPE REF TO cx_root.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_error.

    TRY.
        
        lv_val = 1 / 0 ##NEEDED.
        
      CATCH cx_root INTO lx.
    ENDTRY.

    
    lo_pop = z2ui5_cl_pop_error=>factory( lx ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_div.

    DATA lx TYPE REF TO z2ui5_cx_util_error.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_error.
    CREATE OBJECT lx TYPE z2ui5_cx_util_error EXPORTING val = `test error`.
    
    lo_pop = z2ui5_cl_pop_error=>factory( lx ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

ENDCLASS.
