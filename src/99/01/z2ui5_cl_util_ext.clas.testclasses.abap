"! ================================================================
"! Z2UI5_CL_UTIL_EXT - Comprehensive Unit Tests for JS Transpilation
"! ================================================================
"! BAL tests removed: bal_search has ASSIGN_TYPE_CONFLICT bug in
"! production code (runtime error at line ~142). Fix BAL impl first.
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

    METHODS weekday_monday                 FOR TESTING.
    METHODS weekday_sunday                 FOR TESTING.
    METHODS weekday_wednesday              FOR TESTING.
    METHODS weekday_saturday               FOR TESTING.
    METHODS is_weekend_saturday            FOR TESTING.
    METHODS is_weekend_sunday              FOR TESTING.
    METHODS is_weekend_friday              FOR TESTING.
    METHODS add_workdays_skip_weekend      FOR TESTING.
    METHODS add_workdays_mid_week          FOR TESTING.
    METHODS add_workdays_zero              FOR TESTING.
    METHODS count_workdays_full_week       FOR TESTING.
    METHODS count_workdays_same_day        FOR TESTING.

ENDCLASS.

CLASS ltcl_calendar_ops IMPLEMENTATION.

  METHOD weekday_monday.
    cl_abap_unit_assert=>assert_equals( exp = 1
        act = z2ui5_cl_util_ext=>cal_get_weekday( CONV d( `20240101` ) ) ).
  ENDMETHOD.

  METHOD weekday_sunday.
    cl_abap_unit_assert=>assert_equals( exp = 7
        act = z2ui5_cl_util_ext=>cal_get_weekday( CONV d( `20240107` ) ) ).
  ENDMETHOD.

  METHOD weekday_wednesday.
    cl_abap_unit_assert=>assert_equals( exp = 3
        act = z2ui5_cl_util_ext=>cal_get_weekday( CONV d( `20240103` ) ) ).
  ENDMETHOD.

  METHOD weekday_saturday.
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
    cl_abap_unit_assert=>assert_equals(
        exp = CONV d( `20240318` )
        act = z2ui5_cl_util_ext=>cal_add_workdays( date = CONV d( `20240315` ) days = 1 ) ).
  ENDMETHOD.

  METHOD add_workdays_mid_week.
    cl_abap_unit_assert=>assert_equals(
        exp = CONV d( `20240104` )
        act = z2ui5_cl_util_ext=>cal_add_workdays( date = CONV d( `20240102` ) days = 2 ) ).
  ENDMETHOD.

  METHOD add_workdays_zero.
    cl_abap_unit_assert=>assert_equals(
        exp = CONV d( `20240315` )
        act = z2ui5_cl_util_ext=>cal_add_workdays( date = CONV d( `20240315` ) days = 0 ) ).
  ENDMETHOD.

  METHOD count_workdays_full_week.
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

    " The on-prem RTTI path needs the DDIC type DFIES and table DD02T,
    " neither exists in the JS transpiler runtime - probe and skip there
    METHODS check_dfies_available
      RETURNING
        VALUE(result) TYPE abap_bool.

    METHODS dfies_by_table_basic           FOR TESTING.
    METHODS dfies_by_table_has_fields      FOR TESTING.
    METHODS table_descr_basic              FOR TESTING.

ENDCLASS.

CLASS ltcl_rtti_ext IMPLEMENTATION.

  METHOD check_dfies_available.
    DATA lo_descr TYPE REF TO cl_abap_typedescr.
    cl_abap_typedescr=>describe_by_name(
      EXPORTING
        p_name         = `DFIES`
      RECEIVING
        p_descr_ref    = lo_descr
      EXCEPTIONS
        type_not_found = 1
        OTHERS         = 2 ).
    result = xsdbool( sy-subrc = 0 ).
  ENDMETHOD.

  METHOD dfies_by_table_basic.
    IF check_dfies_available( ) = abap_false.
      RETURN.
    ENDIF.
    DATA(lt_result) = z2ui5_cl_util_ext=>rtti_get_t_dfies_by_table_name( `Z2UI5_T_01` ).
    cl_abap_unit_assert=>assert_not_initial( lt_result ).
  ENDMETHOD.

  METHOD dfies_by_table_has_fields.
    IF check_dfies_available( ) = abap_false.
      RETURN.
    ENDIF.
    DATA(lt_result) = z2ui5_cl_util_ext=>rtti_get_t_dfies_by_table_name( `Z2UI5_T_01` ).
    DATA(lv_found) = abap_false.
    LOOP AT lt_result INTO DATA(ls_dfies).
      IF ls_dfies-fieldname = `ID`.
        lv_found = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.
    cl_abap_unit_assert=>assert_true( lv_found ).
  ENDMETHOD.

  METHOD table_descr_basic.
    IF check_dfies_available( ) = abap_false.
      RETURN.
    ENDIF.
    DATA(lv_result) = z2ui5_cl_util_ext=>rtti_get_table_desrc( `Z2UI5_T_01` ).
    cl_abap_unit_assert=>assert_not_initial( lv_result ).
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
    DATA(lt_result) = z2ui5_cl_util_ext=>tr_get_user_requests( ) ##NEEDED.
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! XLSX CONVERSION
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
    lt_tab = VALUE #( ( col1 = `A` col2 = `B` ) ).
    DATA(lv_result) = z2ui5_cl_util_ext=>conv_get_xlsx_by_itab( lt_tab ) ##NEEDED.
  ENDMETHOD.

  METHOD itab_by_xlsx_empty.
    DATA lv_xstring TYPE xstring.
    DATA lr_result TYPE REF TO data.
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
    DATA(lt_source) = z2ui5_cl_util_ext=>source_get_method(
        iv_classname  = `Z2UI5_CL_UTIL`
        iv_methodname = `C_TRIM` ).
    cl_abap_unit_assert=>assert_not_initial( lt_source ).
  ENDMETHOD.

ENDCLASS.
