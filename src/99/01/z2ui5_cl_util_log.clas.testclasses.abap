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

    DATA(lo_log) = NEW z2ui5_cl_util_log( ).
    lo_log->info( `Test info` ).

    DATA(lt_msg) = lo_log->to_msg( ).

    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_msg ) ).
    cl_abap_unit_assert=>assert_equals( exp = `I` act = lt_msg[ 1 ]-type ).
    cl_abap_unit_assert=>assert_equals( exp = `Test info` act = lt_msg[ 1 ]-text ).

  ENDMETHOD.

  METHOD test_error.

    DATA(lo_log) = NEW z2ui5_cl_util_log( ).
    lo_log->error( `Something failed` ).

    DATA(lt_msg) = lo_log->to_msg( ).

    cl_abap_unit_assert=>assert_equals( exp = `E` act = lt_msg[ 1 ]-type ).

  ENDMETHOD.

  METHOD test_warning.

    DATA(lo_log) = NEW z2ui5_cl_util_log( ).
    lo_log->warning( `Be careful` ).

    DATA(lt_msg) = lo_log->to_msg( ).

    cl_abap_unit_assert=>assert_equals( exp = `W` act = lt_msg[ 1 ]-type ).

  ENDMETHOD.

  METHOD test_success.

    DATA(lo_log) = NEW z2ui5_cl_util_log( ).
    lo_log->success( `All good` ).

    DATA(lt_msg) = lo_log->to_msg( ).

    cl_abap_unit_assert=>assert_equals( exp = `S` act = lt_msg[ 1 ]-type ).

  ENDMETHOD.

  METHOD test_chaining.

    DATA(lo_log) = NEW z2ui5_cl_util_log( ).
    lo_log->info( `Step 1`
      )->info( `Step 2`
      )->error( `Step 3` ).

    cl_abap_unit_assert=>assert_equals( exp = 3 act = lo_log->count( ) ).

  ENDMETHOD.

  METHOD test_has_error.

    DATA(lo_log) = NEW z2ui5_cl_util_log( ).
    lo_log->info( `OK` )->error( `Fail` ).

    cl_abap_unit_assert=>assert_true( lo_log->has_error( ) ).

  ENDMETHOD.

  METHOD test_has_no_error.

    DATA(lo_log) = NEW z2ui5_cl_util_log( ).
    lo_log->info( `OK` )->success( `Done` ).

    cl_abap_unit_assert=>assert_false( lo_log->has_error( ) ).

  ENDMETHOD.

  METHOD test_count.

    DATA(lo_log) = NEW z2ui5_cl_util_log( ).

    cl_abap_unit_assert=>assert_equals( exp = 0 act = lo_log->count( ) ).

    lo_log->info( `One` )->info( `Two` ).

    cl_abap_unit_assert=>assert_equals( exp = 2 act = lo_log->count( ) ).

  ENDMETHOD.

  METHOD test_clear.

    DATA(lo_log) = NEW z2ui5_cl_util_log( ).
    lo_log->info( `One` )->info( `Two` )->clear( ).

    cl_abap_unit_assert=>assert_equals( exp = 0 act = lo_log->count( ) ).

  ENDMETHOD.

  METHOD test_to_msg.

    DATA(lo_log) = NEW z2ui5_cl_util_log( ).
    lo_log->info( `A` )->error( `B` ).

    DATA(lt_msg) = lo_log->to_msg( ).

    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_msg ) ).
    cl_abap_unit_assert=>assert_equals( exp = `A` act = lt_msg[ 1 ]-text ).
    cl_abap_unit_assert=>assert_equals( exp = `B` act = lt_msg[ 2 ]-text ).

  ENDMETHOD.

  METHOD test_to_string.

    DATA(lo_log) = NEW z2ui5_cl_util_log( ).
    lo_log->info( `Hello` )->error( `World` ).

    DATA(lv_str) = lo_log->to_string( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_str CS `[I] Hello` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_str CS `[E] World` ) ).

  ENDMETHOD.

  METHOD test_add_cx.

    TRY.
        DATA(lv_val) = 1 / 0.
      CATCH cx_root INTO DATA(lx).
        DATA(lo_log) = NEW z2ui5_cl_util_log( ).
        lo_log->add( lx ).
    ENDTRY.

    cl_abap_unit_assert=>assert_equals( exp = 1 act = lo_log->count( ) ).
    cl_abap_unit_assert=>assert_true( lo_log->has_error( ) ).

  ENDMETHOD.

ENDCLASS.
