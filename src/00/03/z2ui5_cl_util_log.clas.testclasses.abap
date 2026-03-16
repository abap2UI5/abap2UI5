CLASS ltcl_unit_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_info              FOR TESTING RAISING cx_static_check.
    METHODS test_error             FOR TESTING RAISING cx_static_check.
    METHODS test_warning           FOR TESTING RAISING cx_static_check.
    METHODS test_success           FOR TESTING RAISING cx_static_check.
    METHODS test_chaining          FOR TESTING RAISING cx_static_check.
    METHODS test_has_error         FOR TESTING RAISING cx_static_check.
    METHODS test_has_no_error      FOR TESTING RAISING cx_static_check.
    METHODS test_count             FOR TESTING RAISING cx_static_check.
    METHODS test_clear             FOR TESTING RAISING cx_static_check.
    METHODS test_to_msg            FOR TESTING RAISING cx_static_check.
    METHODS test_to_string         FOR TESTING RAISING cx_static_check.
    METHODS test_add_cx            FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.

  METHOD test_info.

    DATA lo_log TYPE REF TO z2ui5_cl_util_log.
    DATA lt_msg TYPE z2ui5_cl_util=>ty_t_msg.
    DATA temp1 LIKE LINE OF lt_msg.
    DATA temp2 LIKE sy-tabix.
    DATA temp3 LIKE LINE OF lt_msg.
    DATA temp4 LIKE sy-tabix.
    CREATE OBJECT lo_log TYPE z2ui5_cl_util_log.
    lo_log->info( `Test info` ).

    
    lt_msg = lo_log->to_msg( ).

    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_msg ) ).
    
    
    temp2 = sy-tabix.
    READ TABLE lt_msg INDEX 1 INTO temp1.
    sy-tabix = temp2.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `I` act = temp1-type ).
    
    
    temp4 = sy-tabix.
    READ TABLE lt_msg INDEX 1 INTO temp3.
    sy-tabix = temp4.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Test info` act = temp3-text ).

  ENDMETHOD.

  METHOD test_error.

    DATA lo_log TYPE REF TO z2ui5_cl_util_log.
    DATA lt_msg TYPE z2ui5_cl_util=>ty_t_msg.
    DATA temp5 LIKE LINE OF lt_msg.
    DATA temp6 LIKE sy-tabix.
    CREATE OBJECT lo_log TYPE z2ui5_cl_util_log.
    lo_log->error( `Something failed` ).

    
    lt_msg = lo_log->to_msg( ).

    
    
    temp6 = sy-tabix.
    READ TABLE lt_msg INDEX 1 INTO temp5.
    sy-tabix = temp6.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `E` act = temp5-type ).

  ENDMETHOD.

  METHOD test_warning.

    DATA lo_log TYPE REF TO z2ui5_cl_util_log.
    DATA lt_msg TYPE z2ui5_cl_util=>ty_t_msg.
    DATA temp7 LIKE LINE OF lt_msg.
    DATA temp8 LIKE sy-tabix.
    CREATE OBJECT lo_log TYPE z2ui5_cl_util_log.
    lo_log->warning( `Be careful` ).

    
    lt_msg = lo_log->to_msg( ).

    
    
    temp8 = sy-tabix.
    READ TABLE lt_msg INDEX 1 INTO temp7.
    sy-tabix = temp8.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `W` act = temp7-type ).

  ENDMETHOD.

  METHOD test_success.

    DATA lo_log TYPE REF TO z2ui5_cl_util_log.
    DATA lt_msg TYPE z2ui5_cl_util=>ty_t_msg.
    DATA temp9 LIKE LINE OF lt_msg.
    DATA temp10 LIKE sy-tabix.
    CREATE OBJECT lo_log TYPE z2ui5_cl_util_log.
    lo_log->success( `All good` ).

    
    lt_msg = lo_log->to_msg( ).

    
    
    temp10 = sy-tabix.
    READ TABLE lt_msg INDEX 1 INTO temp9.
    sy-tabix = temp10.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `S` act = temp9-type ).

  ENDMETHOD.

  METHOD test_chaining.

    DATA lo_log TYPE REF TO z2ui5_cl_util_log.
    CREATE OBJECT lo_log TYPE z2ui5_cl_util_log.
    lo_log->info( `Step 1`
      )->info( `Step 2`
      )->error( `Step 3` ).

    cl_abap_unit_assert=>assert_equals( exp = 3 act = lo_log->count( ) ).

  ENDMETHOD.

  METHOD test_has_error.

    DATA lo_log TYPE REF TO z2ui5_cl_util_log.
    CREATE OBJECT lo_log TYPE z2ui5_cl_util_log.
    lo_log->info( `OK` )->error( `Fail` ).

    cl_abap_unit_assert=>assert_true( lo_log->has_error( ) ).

  ENDMETHOD.

  METHOD test_has_no_error.

    DATA lo_log TYPE REF TO z2ui5_cl_util_log.
    CREATE OBJECT lo_log TYPE z2ui5_cl_util_log.
    lo_log->info( `OK` )->success( `Done` ).

    cl_abap_unit_assert=>assert_false( lo_log->has_error( ) ).

  ENDMETHOD.

  METHOD test_count.

    DATA lo_log TYPE REF TO z2ui5_cl_util_log.
    CREATE OBJECT lo_log TYPE z2ui5_cl_util_log.

    cl_abap_unit_assert=>assert_equals( exp = 0 act = lo_log->count( ) ).

    lo_log->info( `One` )->info( `Two` ).

    cl_abap_unit_assert=>assert_equals( exp = 2 act = lo_log->count( ) ).

  ENDMETHOD.

  METHOD test_clear.

    DATA lo_log TYPE REF TO z2ui5_cl_util_log.
    CREATE OBJECT lo_log TYPE z2ui5_cl_util_log.
    lo_log->info( `One` )->info( `Two` )->clear( ).

    cl_abap_unit_assert=>assert_equals( exp = 0 act = lo_log->count( ) ).

  ENDMETHOD.

  METHOD test_to_msg.

    DATA lo_log TYPE REF TO z2ui5_cl_util_log.
    DATA lt_msg TYPE z2ui5_cl_util=>ty_t_msg.
    DATA temp11 LIKE LINE OF lt_msg.
    DATA temp12 LIKE sy-tabix.
    DATA temp13 LIKE LINE OF lt_msg.
    DATA temp14 LIKE sy-tabix.
    CREATE OBJECT lo_log TYPE z2ui5_cl_util_log.
    lo_log->info( `A` )->error( `B` ).

    
    lt_msg = lo_log->to_msg( ).

    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_msg ) ).
    
    
    temp12 = sy-tabix.
    READ TABLE lt_msg INDEX 1 INTO temp11.
    sy-tabix = temp12.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `A` act = temp11-text ).
    
    
    temp14 = sy-tabix.
    READ TABLE lt_msg INDEX 2 INTO temp13.
    sy-tabix = temp14.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `B` act = temp13-text ).

  ENDMETHOD.

  METHOD test_to_string.

    DATA lo_log TYPE REF TO z2ui5_cl_util_log.
    DATA lv_str TYPE string.
    DATA temp1 TYPE xsdboolean.
    DATA temp2 TYPE xsdboolean.
    CREATE OBJECT lo_log TYPE z2ui5_cl_util_log.
    lo_log->info( `Hello` )->error( `World` ).

    
    lv_str = lo_log->to_string( ).

    
    temp1 = boolc( lv_str CS `[I] Hello` ).
    cl_abap_unit_assert=>assert_true( temp1 ).
    
    temp2 = boolc( lv_str CS `[E] World` ).
    cl_abap_unit_assert=>assert_true( temp2 ).

  ENDMETHOD.

  METHOD test_add_cx.
        DATA lv_val TYPE i.
        DATA lx TYPE REF TO cx_root.
        DATA lo_log TYPE REF TO z2ui5_cl_util_log.

    TRY.
        
        lv_val = 1 / 0.
        
      CATCH cx_root INTO lx.
        
        CREATE OBJECT lo_log TYPE z2ui5_cl_util_log.
        lo_log->add( lx ).
    ENDTRY.

    cl_abap_unit_assert=>assert_equals( exp = 1 act = lo_log->count( ) ).
    cl_abap_unit_assert=>assert_true( lo_log->has_error( ) ).

  ENDMETHOD.

ENDCLASS.
