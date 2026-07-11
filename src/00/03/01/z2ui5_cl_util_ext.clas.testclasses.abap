"! ================================================================
"! Z2UI5_CL_UTIL_EXT - Comprehensive Unit Tests for JS Transpilation
"! ================================================================

"! ================================================================
"! LOCK / DEQUEUE HELPER
"! ================================================================
CLASS ltcl_lock_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS dequeue_from_enqueue           FOR TESTING.
    METHODS dequeue_from_lower             FOR TESTING.
    METHODS dequeue_already_dequeue        FOR TESTING.
    METHODS dequeue_short_name             FOR TESTING.

ENDCLASS.

CLASS ltcl_lock_ops IMPLEMENTATION.

  METHOD dequeue_from_enqueue.
    cl_abap_unit_assert=>assert_equals(
        exp = `DEQUEUE_EVVBAKE`
        act = z2ui5_cl_util_ext=>lock_get_dequeue_by_enqueue( `ENQUEUE_EVVBAKE` ) ).
  ENDMETHOD.

  METHOD dequeue_from_lower.
    cl_abap_unit_assert=>assert_equals(
        exp = `DEQUEUE_EVVBAKE`
        act = z2ui5_cl_util_ext=>lock_get_dequeue_by_enqueue( `enqueue_evvbake` ) ).
  ENDMETHOD.

  METHOD dequeue_already_dequeue.
    cl_abap_unit_assert=>assert_equals(
        exp = `DEQUEUE_EVVBAKE`
        act = z2ui5_cl_util_ext=>lock_get_dequeue_by_enqueue( `DEQUEUE_EVVBAKE` ) ).
  ENDMETHOD.

  METHOD dequeue_short_name.
    cl_abap_unit_assert=>assert_equals(
        exp = `DEQUEUE_EMARA`
        act = z2ui5_cl_util_ext=>lock_get_dequeue_by_enqueue( `ENQUEUE_EMARA` ) ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! CALENDAR OPERATIONS
"! ================================================================
CLASS ltcl_calendar_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    " cal_get_weekday
    METHODS weekday_monday                 FOR TESTING.
    METHODS weekday_sunday                 FOR TESTING.
    METHODS weekday_wednesday              FOR TESTING.
    METHODS weekday_saturday               FOR TESTING.

    " cal_is_weekend
    METHODS is_weekend_saturday            FOR TESTING.
    METHODS is_weekend_sunday              FOR TESTING.
    METHODS is_weekend_friday              FOR TESTING.

    " cal_add_workdays
    METHODS add_workdays_skip_weekend      FOR TESTING.
    METHODS add_workdays_mid_week          FOR TESTING.
    METHODS add_workdays_zero              FOR TESTING.

    " cal_count_workdays
    METHODS count_workdays_full_week       FOR TESTING.
    METHODS count_workdays_same_day        FOR TESTING.

ENDCLASS.

CLASS ltcl_calendar_ops IMPLEMENTATION.

  METHOD weekday_monday.
    " 2024-01-01 was Monday
    cl_abap_unit_assert=>assert_equals( exp = 1
        act = z2ui5_cl_util_ext=>cal_get_weekday( CONV d( `20240101` ) ) ).
  ENDMETHOD.

  METHOD weekday_sunday.
    " 2024-01-07 was Sunday
    cl_abap_unit_assert=>assert_equals( exp = 7
        act = z2ui5_cl_util_ext=>cal_get_weekday( CONV d( `20240107` ) ) ).
  ENDMETHOD.

  METHOD weekday_wednesday.
    " 2024-01-03 was Wednesday
    cl_abap_unit_assert=>assert_equals( exp = 3
        act = z2ui5_cl_util_ext=>cal_get_weekday( CONV d( `20240103` ) ) ).
  ENDMETHOD.

  METHOD weekday_saturday.
    " 2024-01-06 was Saturday
    cl_abap_unit_assert=>assert_equals( exp = 6
        act = z2ui5_cl_util_ext=>cal_get_weekday( CONV d( `20240106` ) ) ).
  ENDMETHOD.

  METHOD is_weekend_saturday.
    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_util_ext=>cal_is_weekend( CONV d( `20240106` ) ) ).
  ENDMETHOD.

  METHOD is_weekend_sunday.
    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_util_ext=>cal_is_weekend( CONV d( `20240107` ) ) ).
  ENDMETHOD.

  METHOD is_weekend_friday.
    cl_abap_unit_assert=>assert_false(
        z2ui5_cl_util_ext=>cal_is_weekend( CONV d( `20240105` ) ) ).
  ENDMETHOD.

  METHOD add_workdays_skip_weekend.
    " Friday 2024-03-15 + 1 workday = Monday 2024-03-18
    cl_abap_unit_assert=>assert_equals(
        exp = CONV d( `20240318` )
        act = z2ui5_cl_util_ext=>cal_add_workdays( date = CONV d( `20240315` ) days = 1 ) ).
  ENDMETHOD.

  METHOD add_workdays_mid_week.
    " Tuesday 2024-01-02 + 2 workdays = Thursday 2024-01-04
    cl_abap_unit_assert=>assert_equals(
        exp = CONV d( `20240104` )
        act = z2ui5_cl_util_ext=>cal_add_workdays( date = CONV d( `20240102` ) days = 2 ) ).
  ENDMETHOD.

  METHOD add_workdays_zero.
    " Adding 0 workdays returns same date
    cl_abap_unit_assert=>assert_equals(
        exp = CONV d( `20240315` )
        act = z2ui5_cl_util_ext=>cal_add_workdays( date = CONV d( `20240315` ) days = 0 ) ).
  ENDMETHOD.

  METHOD count_workdays_full_week.
    " Mon 2024-01-01 to Mon 2024-01-08 = 5 workdays
    cl_abap_unit_assert=>assert_equals(
        exp = 5
        act = z2ui5_cl_util_ext=>cal_count_workdays( date_from = CONV d( `20240101` )
                                                      date_to   = CONV d( `20240108` ) ) ).
  ENDMETHOD.

  METHOD count_workdays_same_day.
    cl_abap_unit_assert=>assert_equals(
        exp = 0
        act = z2ui5_cl_util_ext=>cal_count_workdays( date_from = CONV d( `20240101` )
                                                      date_to   = CONV d( `20240101` ) ) ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! ZIP OPERATIONS
"! ================================================================
CLASS ltcl_zip_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS pack_basic                     FOR TESTING.
    METHODS pack_empty                     FOR TESTING.
    METHODS roundtrip                      FOR TESTING.

ENDCLASS.

CLASS ltcl_zip_ops IMPLEMENTATION.

  METHOD pack_basic.
    " Skip when CL_ABAP_ZIP not available
    DATA lo_probe TYPE REF TO object.
    TRY.
        CREATE OBJECT lo_probe TYPE ('CL_ABAP_ZIP').
      CATCH cx_root.
        RETURN.
    ENDTRY.

    DATA(lt_files) = VALUE z2ui5_cl_util_ext=>ty_t_zip_file(
        ( name = `test.txt` content = CONV xstring( `48656C6C6F` ) ) ).
    DATA(lv_archive) = z2ui5_cl_util_ext=>zip_pack( lt_files ).
    cl_abap_unit_assert=>assert_not_initial( lv_archive ).
  ENDMETHOD.

  METHOD pack_empty.
    DATA lo_probe TYPE REF TO object.
    TRY.
        CREATE OBJECT lo_probe TYPE ('CL_ABAP_ZIP').
      CATCH cx_root.
        RETURN.
    ENDTRY.

    DATA(lt_files) = VALUE z2ui5_cl_util_ext=>ty_t_zip_file( ).
    DATA(lv_archive) = z2ui5_cl_util_ext=>zip_pack( lt_files ).
    cl_abap_unit_assert=>assert_not_initial( lv_archive ).
  ENDMETHOD.

  METHOD roundtrip.
    DATA lo_probe TYPE REF TO object.
    TRY.
        CREATE OBJECT lo_probe TYPE ('CL_ABAP_ZIP').
      CATCH cx_root.
        RETURN.
    ENDTRY.

    DATA(lt_in) = VALUE z2ui5_cl_util_ext=>ty_t_zip_file(
        ( name = `a.txt` content = CONV xstring( `414141` ) )
        ( name = `b.txt` content = CONV xstring( `424242` ) ) ).

    DATA(lv_archive) = z2ui5_cl_util_ext=>zip_pack( lt_in ).
    DATA(lt_out) = z2ui5_cl_util_ext=>zip_unpack( lv_archive ).

    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_out ) ).

    LOOP AT lt_in INTO DATA(ls_in).
      DATA(ls_out) = VALUE #( lt_out[ name = ls_in-name ] OPTIONAL ).
      cl_abap_unit_assert=>assert_equals( exp = ls_in-content act = ls_out-content ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! RTTI / TABLE DESCRIPTION
"! ================================================================
CLASS ltcl_rtti_ext DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS dfies_by_table_basic           FOR TESTING.
    METHODS dfies_by_table_has_fields      FOR TESTING.
    METHODS table_descr_basic              FOR TESTING.

ENDCLASS.

CLASS ltcl_rtti_ext IMPLEMENTATION.

  METHOD dfies_by_table_basic.
    DATA(lt_result) = z2ui5_cl_util_ext=>rtti_get_t_dfies_by_table_name( `MARA` ).
    cl_abap_unit_assert=>assert_not_initial( lt_result ).
  ENDMETHOD.

  METHOD dfies_by_table_has_fields.
    DATA(lt_result) = z2ui5_cl_util_ext=>rtti_get_t_dfies_by_table_name( `MARA` ).
    " MARA must have MATNR field
    DATA(lv_found) = abap_false.
    LOOP AT lt_result INTO DATA(ls_dfies).
      IF ls_dfies-fieldname = `MATNR`.
        lv_found = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.
    cl_abap_unit_assert=>assert_true( lv_found ).
  ENDMETHOD.

  METHOD table_descr_basic.
    DATA(lv_result) = z2ui5_cl_util_ext=>rtti_get_table_desrc( `MARA` ).
    cl_abap_unit_assert=>assert_not_initial( lv_result ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! BAL (Business Application Log)
"! ================================================================
CLASS ltcl_bal_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS bal_read_empty                 FOR TESTING.
    METHODS bal_create_empty               FOR TESTING.
    METHODS bal_update_empty               FOR TESTING.
    METHODS bal_delete_nonexist            FOR TESTING.
    METHODS bal_search_empty               FOR TESTING.
    METHODS bal_count_zero                 FOR TESTING.

ENDCLASS.

CLASS ltcl_bal_ops IMPLEMENTATION.

  METHOD bal_read_empty.
    " Reading non-existent log should return empty
    DATA(lt_result) = z2ui5_cl_util_ext=>bal_read(
        object    = `ZTEST_NOVA`
        subobject = `ZTEST_NOVA`
        id        = `NONEXIST_12345` ).
    cl_abap_unit_assert=>assert_initial( lt_result ).
  ENDMETHOD.

  METHOD bal_create_empty.
    " Creating log with empty messages should not dump
    DATA lt_log TYPE z2ui5_cl_util=>ty_t_msg.
    z2ui5_cl_util_ext=>bal_create(
        object    = `ZTEST_NOVA`
        subobject = `ZTEST_NOVA`
        id        = `UNIT_TEST_001`
        t_log     = lt_log ).
    " Clean up
    z2ui5_cl_util_ext=>bal_delete(
        object    = `ZTEST_NOVA`
        subobject = `ZTEST_NOVA`
        id        = `UNIT_TEST_001` ).
  ENDMETHOD.

  METHOD bal_update_empty.
    DATA lt_log TYPE z2ui5_cl_util=>ty_t_msg.
    z2ui5_cl_util_ext=>bal_update(
        object    = `ZTEST_NOVA`
        subobject = `ZTEST_NOVA`
        id        = `NONEXIST_12345`
        t_log     = lt_log ).
  ENDMETHOD.

  METHOD bal_delete_nonexist.
    " Deleting non-existent log should not dump
    z2ui5_cl_util_ext=>bal_delete(
        object    = `ZTEST_NOVA`
        subobject = `ZTEST_NOVA`
        id        = `NONEXIST_12345` ).
  ENDMETHOD.

  METHOD bal_search_empty.
    DATA(lt_result) = z2ui5_cl_util_ext=>bal_search( object = `ZTEST_NOVA_99` ).
    cl_abap_unit_assert=>assert_initial( lt_result ).
  ENDMETHOD.

  METHOD bal_count_zero.
    DATA(lv_count) = z2ui5_cl_util_ext=>bal_count(
        object    = `ZTEST_NOVA`
        subobject = `ZTEST_NOVA`
        id        = `NONEXIST_12345` ).
    cl_abap_unit_assert=>assert_equals( exp = 0 act = lv_count ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! TRANSPORT REQUEST OPERATIONS
"! ================================================================
CLASS ltcl_transport_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS get_user_requests              FOR TESTING.

ENDCLASS.

CLASS ltcl_transport_ops IMPLEMENTATION.

  METHOD get_user_requests.
    " Should not dump - may return empty if user has no transports
    DATA(lt_result) = z2ui5_cl_util_ext=>tr_get_user_requests( ) ##NEEDED.
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! XLSX CONVERSION (requires CL_EHFND_XLSX)
"! ================================================================
CLASS ltcl_xlsx_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS xlsx_by_itab_basic             FOR TESTING.
    METHODS itab_by_xlsx_empty             FOR TESTING.

ENDCLASS.

CLASS ltcl_xlsx_ops IMPLEMENTATION.

  METHOD xlsx_by_itab_basic.
    TYPES: BEGIN OF ty_row, col1 TYPE string, col2 TYPE string, END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_tab = VALUE #( ( col1 = `A` col2 = `B` ) ( col1 = `C` col2 = `D` ) ).

    DATA(lv_result) = z2ui5_cl_util_ext=>conv_get_xlsx_by_itab( lt_tab ) ##NEEDED.
    " Result may be initial if CL_EHFND_XLSX is not available
  ENDMETHOD.

  METHOD itab_by_xlsx_empty.
    DATA lv_xstring TYPE xstring.
    DATA lr_result TYPE REF TO data.
    " Empty xstring should not dump
    z2ui5_cl_util_ext=>conv_get_itab_by_xlsx( EXPORTING val = lv_xstring
                                              IMPORTING result = lr_result ) ##NEEDED.
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! SOURCE CODE READING
"! ================================================================
CLASS ltcl_source_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS source_get_method_basic        FOR TESTING.

ENDCLASS.

CLASS ltcl_source_ops IMPLEMENTATION.

  METHOD source_get_method_basic.
    " Reading source of a known method
    DATA(lt_source) = z2ui5_cl_util_ext=>source_get_method(
        iv_classname  = `Z2UI5_CL_UTIL`
        iv_methodname = `C_TRIM` ).
    cl_abap_unit_assert=>assert_not_initial( lt_source ).
  ENDMETHOD.

ENDCLASS.
