CLASS ltcl_unit_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_raise           FOR TESTING RAISING cx_static_check.
    METHODS test_raise_empty     FOR TESTING RAISING cx_static_check.
    METHODS test_raise_with_prev FOR TESTING RAISING cx_static_check.
    METHODS test_raise_with_cx   FOR TESTING RAISING cx_static_check.
    METHODS test_uuid_populated  FOR TESTING RAISING cx_static_check.
    METHODS test_chain_texts     FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.
  METHOD test_raise.
        DATA lx TYPE REF TO z2ui5_cx_util_error.

    TRY.

        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING val = `this is an error text`.

        
      CATCH z2ui5_cx_util_error INTO lx.
        cl_abap_unit_assert=>assert_equals( exp = `this is an error text`
                                            act = lx->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_raise_empty.
        DATA lx TYPE REF TO z2ui5_cx_util_error.

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error.
        
      CATCH z2ui5_cx_util_error INTO lx.
        cl_abap_unit_assert=>assert_bound( lx ).
        cl_abap_unit_assert=>assert_not_initial( lx->ms_error-uuid ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_raise_with_prev.

    DATA lx_prev TYPE REF TO z2ui5_cx_util_error.
        DATA lx TYPE REF TO z2ui5_cx_util_error.
        DATA lv_text TYPE string.
        DATA temp1 TYPE xsdboolean.
        DATA temp2 TYPE xsdboolean.
    CREATE OBJECT lx_prev TYPE z2ui5_cx_util_error EXPORTING val = `previous error`.

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING val      = `current error`
                    previous = lx_prev.
        
      CATCH z2ui5_cx_util_error INTO lx.
        
        lv_text = lx->get_text( ).
        
        temp1 = boolc( lv_text CS `current error` ).
        cl_abap_unit_assert=>assert_true(
          temp1 ).
        
        temp2 = boolc( lv_text CS `previous error` ).
        cl_abap_unit_assert=>assert_true(
          temp2 ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_raise_with_cx.
        DATA lv_val TYPE i.
        DATA lx_root TYPE REF TO cx_root.
        DATA lx TYPE REF TO z2ui5_cx_util_error.

    TRY.
        
        lv_val = 1 / 0.
        
      CATCH cx_root INTO lx_root.
    ENDTRY.

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING val = lx_root.
        
      CATCH z2ui5_cx_util_error INTO lx.
        cl_abap_unit_assert=>assert_not_initial( lx->get_text( ) ).
        cl_abap_unit_assert=>assert_bound( lx->ms_error-x_root ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_uuid_populated.
        DATA lx TYPE REF TO z2ui5_cx_util_error.

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING val = `test`.
        
      CATCH z2ui5_cx_util_error INTO lx.
        cl_abap_unit_assert=>assert_not_initial( lx->ms_error-uuid ).
        cl_abap_unit_assert=>assert_equals( exp = 32
                                            act = strlen( lx->ms_error-uuid ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_chain_texts.

    DATA lx_inner TYPE REF TO z2ui5_cx_util_error.
    DATA lx_middle TYPE REF TO z2ui5_cx_util_error.
    DATA lx_outer TYPE REF TO z2ui5_cx_util_error.
    DATA lv_text TYPE string.
    DATA temp3 TYPE xsdboolean.
    DATA temp4 TYPE xsdboolean.
    DATA temp5 TYPE xsdboolean.
    CREATE OBJECT lx_inner TYPE z2ui5_cx_util_error EXPORTING val = `inner`.
    
    CREATE OBJECT lx_middle TYPE z2ui5_cx_util_error EXPORTING val = `middle` previous = lx_inner.
    
    CREATE OBJECT lx_outer TYPE z2ui5_cx_util_error EXPORTING val = `outer` previous = lx_middle.

    
    lv_text = lx_outer->get_text( ).
    
    temp3 = boolc( lv_text CS `outer` ).
    cl_abap_unit_assert=>assert_true( temp3 ).
    
    temp4 = boolc( lv_text CS `middle` ).
    cl_abap_unit_assert=>assert_true( temp4 ).
    
    temp5 = boolc( lv_text CS `inner` ).
    cl_abap_unit_assert=>assert_true( temp5 ).

  ENDMETHOD.
ENDCLASS.
