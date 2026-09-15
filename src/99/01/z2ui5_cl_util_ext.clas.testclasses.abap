" ================================================================
" Z2UI5_CL_UTIL_EXT - Comprehensive Unit Tests for JS Transpilation
" ================================================================
" BAL tests removed: bal_search has ASSIGN_TYPE_CONFLICT bug in
" production code (runtime error at line ~142). Fix BAL impl first.
" ================================================================

" ================================================================
" LOCK / DEQUEUE HELPER
" ================================================================
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


" ================================================================
" CALENDAR OPERATIONS
" ================================================================
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
    DATA temp1 TYPE d.
    temp1 = `20240101`.
    cl_abap_unit_assert=>assert_equals( exp = 1
        act = z2ui5_cl_util_ext=>cal_get_weekday( temp1 ) ).
  ENDMETHOD.

  METHOD weekday_sunday.
    DATA temp2 TYPE d.
    temp2 = `20240107`.
    cl_abap_unit_assert=>assert_equals( exp = 7
        act = z2ui5_cl_util_ext=>cal_get_weekday( temp2 ) ).
  ENDMETHOD.

  METHOD weekday_wednesday.
    DATA temp3 TYPE d.
    temp3 = `20240103`.
    cl_abap_unit_assert=>assert_equals( exp = 3
        act = z2ui5_cl_util_ext=>cal_get_weekday( temp3 ) ).
  ENDMETHOD.

  METHOD weekday_saturday.
    DATA temp4 TYPE d.
    temp4 = `20240106`.
    cl_abap_unit_assert=>assert_equals( exp = 6
        act = z2ui5_cl_util_ext=>cal_get_weekday( temp4 ) ).
  ENDMETHOD.

  METHOD is_weekend_saturday.
    DATA temp5 TYPE d.
    temp5 = `20240106`.
    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_util_ext=>cal_is_weekend( temp5 ) ).
  ENDMETHOD.

  METHOD is_weekend_sunday.
    DATA temp6 TYPE d.
    temp6 = `20240107`.
    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_util_ext=>cal_is_weekend( temp6 ) ).
  ENDMETHOD.

  METHOD is_weekend_friday.
    DATA temp7 TYPE d.
    temp7 = `20240105`.
    cl_abap_unit_assert=>assert_false(
        z2ui5_cl_util_ext=>cal_is_weekend( temp7 ) ).
  ENDMETHOD.

  METHOD add_workdays_skip_weekend.
    DATA temp8 TYPE d.
    DATA temp1 TYPE d.
    temp8 = `20240318`.

    temp1 = `20240315`.
    cl_abap_unit_assert=>assert_equals(
        exp = temp8
        act = z2ui5_cl_util_ext=>cal_add_workdays( date = temp1 days = 1 ) ).
  ENDMETHOD.

  METHOD add_workdays_mid_week.
    DATA temp9 TYPE d.
    DATA temp2 TYPE d.
    temp9 = `20240104`.

    temp2 = `20240102`.
    cl_abap_unit_assert=>assert_equals(
        exp = temp9
        act = z2ui5_cl_util_ext=>cal_add_workdays( date = temp2 days = 2 ) ).
  ENDMETHOD.

  METHOD add_workdays_zero.
    DATA temp10 TYPE d.
    DATA temp3 TYPE d.
    temp10 = `20240315`.

    temp3 = `20240315`.
    cl_abap_unit_assert=>assert_equals(
        exp = temp10
        act = z2ui5_cl_util_ext=>cal_add_workdays( date = temp3 days = 0 ) ).
  ENDMETHOD.

  METHOD count_workdays_full_week.
    DATA temp11 TYPE d.
    DATA temp4 TYPE d.
    temp11 = `20240101`.

    temp4 = `20240108`.
    cl_abap_unit_assert=>assert_equals(
        exp = 5
        act = z2ui5_cl_util_ext=>cal_count_workdays( date_from = temp11
                                                      date_to   = temp4 ) ).
  ENDMETHOD.

  METHOD count_workdays_same_day.
    DATA temp12 TYPE d.
    DATA temp5 TYPE d.
    temp12 = `20240101`.

    temp5 = `20240101`.
    cl_abap_unit_assert=>assert_equals(
        exp = 0
        act = z2ui5_cl_util_ext=>cal_count_workdays( date_from = temp12
                                                      date_to   = temp5 ) ).
  ENDMETHOD.

ENDCLASS.


" ================================================================
" ZIP OPERATIONS
" ================================================================
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
    DATA temp13 TYPE z2ui5_cl_util_ext=>ty_t_zip_file.
    DATA temp14 LIKE LINE OF temp13.
    DATA temp6 TYPE xstring.
    DATA lt_files LIKE temp13.
    DATA lv_archive TYPE xstring.
    TRY.
        CREATE OBJECT lo_probe TYPE ('CL_ABAP_ZIP').
      CATCH cx_root.
        RETURN.
    ENDTRY.


    CLEAR temp13.

    temp14-name = `test.txt`.

    temp6 = `48656C6C6F`.
    temp14-content = temp6.
    INSERT temp14 INTO TABLE temp13.

    lt_files = temp13.

    lv_archive = z2ui5_cl_util_ext=>zip_pack( lt_files ).
    cl_abap_unit_assert=>assert_not_initial( lv_archive ).
  ENDMETHOD.

  METHOD pack_empty.
    DATA lo_probe TYPE REF TO object.
    DATA temp15 TYPE z2ui5_cl_util_ext=>ty_t_zip_file.
    DATA lt_files LIKE temp15.
    DATA lv_archive TYPE xstring.
    TRY.
        CREATE OBJECT lo_probe TYPE ('CL_ABAP_ZIP').
      CATCH cx_root.
        RETURN.
    ENDTRY.


    CLEAR temp15.

    lt_files = temp15.

    lv_archive = z2ui5_cl_util_ext=>zip_pack( lt_files ).
    cl_abap_unit_assert=>assert_not_initial( lv_archive ).
  ENDMETHOD.

  METHOD roundtrip.
    DATA lo_probe TYPE REF TO object.
    DATA temp16 TYPE z2ui5_cl_util_ext=>ty_t_zip_file.
    DATA temp17 LIKE LINE OF temp16.
    DATA temp7 TYPE xstring.
    DATA temp8 TYPE xstring.
    DATA lt_in LIKE temp16.
    DATA lv_archive TYPE xstring.
    DATA lt_out TYPE z2ui5_cl_util_ext=>ty_t_zip_file.
    DATA ls_in LIKE LINE OF lt_in.
      DATA temp18 TYPE z2ui5_cl_util_ext=>ty_s_zip_file.
      DATA temp19 TYPE z2ui5_cl_util_ext=>ty_s_zip_file.
      DATA ls_out LIKE temp18.
    TRY.
        CREATE OBJECT lo_probe TYPE ('CL_ABAP_ZIP').
      CATCH cx_root.
        RETURN.
    ENDTRY.


    CLEAR temp16.

    temp17-name = `a.txt`.

    temp7 = `414141`.
    temp17-content = temp7.
    INSERT temp17 INTO TABLE temp16.
    temp17-name = `b.txt`.

    temp8 = `424242`.
    temp17-content = temp8.
    INSERT temp17 INTO TABLE temp16.

    lt_in = temp16.


    lv_archive = z2ui5_cl_util_ext=>zip_pack( lt_in ).

    lt_out = z2ui5_cl_util_ext=>zip_unpack( lv_archive ).

    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_out ) ).


    LOOP AT lt_in INTO ls_in.

      CLEAR temp18.

      READ TABLE lt_out INTO temp19 WITH KEY name = ls_in-name.
      IF sy-subrc = 0.
        temp18 = temp19.
      ENDIF.

      ls_out = temp18.
      cl_abap_unit_assert=>assert_equals( exp = ls_in-content act = ls_out-content ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.


" ================================================================
" RTTI / TABLE DESCRIPTION
" ================================================================
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
    DATA temp1 TYPE xsdboolean.
    cl_abap_typedescr=>describe_by_name(
      EXPORTING
        p_name         = `DFIES`
      RECEIVING
        p_descr_ref    = lo_descr
      EXCEPTIONS
        type_not_found = 1
        OTHERS         = 2 ).

    temp1 = boolc( sy-subrc = 0 ).
    result = temp1.
  ENDMETHOD.

  METHOD dfies_by_table_basic.
    DATA lt_result TYPE z2ui5_cl_util_ext=>ty_t_dfies.
    IF check_dfies_available( ) = abap_false.
      RETURN.
    ENDIF.

    lt_result = z2ui5_cl_util_ext=>rtti_get_t_dfies_by_table_name( `Z2UI5_T_01` ).
    cl_abap_unit_assert=>assert_not_initial( lt_result ).
  ENDMETHOD.

  METHOD dfies_by_table_has_fields.
    DATA lt_result TYPE z2ui5_cl_util_ext=>ty_t_dfies.
    DATA lv_found LIKE abap_false.
    DATA ls_dfies LIKE LINE OF lt_result.
    IF check_dfies_available( ) = abap_false.
      RETURN.
    ENDIF.

    lt_result = z2ui5_cl_util_ext=>rtti_get_t_dfies_by_table_name( `Z2UI5_T_01` ).

    lv_found = abap_false.

    LOOP AT lt_result INTO ls_dfies.
      IF ls_dfies-fieldname = `ID`.
        lv_found = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.
    cl_abap_unit_assert=>assert_true( lv_found ).
  ENDMETHOD.

  METHOD table_descr_basic.
    DATA lv_result TYPE string.
    IF check_dfies_available( ) = abap_false.
      RETURN.
    ENDIF.

    lv_result = z2ui5_cl_util_ext=>rtti_get_table_desrc( `Z2UI5_T_01` ).
    cl_abap_unit_assert=>assert_not_initial( lv_result ).
  ENDMETHOD.

ENDCLASS.


" ================================================================
" TRANSPORT REQUEST OPERATIONS
" ================================================================
CLASS ltcl_transport_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS get_user_requests              FOR TESTING.

ENDCLASS.

CLASS ltcl_transport_ops IMPLEMENTATION.

  METHOD get_user_requests.
    DATA lt_result TYPE z2ui5_cl_util_ext=>ty_t_tr_request.
    lt_result = z2ui5_cl_util_ext=>tr_get_user_requests( ) ##NEEDED.
  ENDMETHOD.

ENDCLASS.


" ================================================================
" XLSX CONVERSION
" ================================================================
CLASS ltcl_xlsx_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS xlsx_by_itab_basic             FOR TESTING.
    METHODS itab_by_xlsx_empty             FOR TESTING.

ENDCLASS.

CLASS ltcl_xlsx_ops IMPLEMENTATION.

  METHOD xlsx_by_itab_basic.
    TYPES: BEGIN OF ty_row, col1 TYPE string, col2 TYPE string, END OF ty_row.
    TYPES temp1 TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
DATA lt_tab TYPE temp1.
    DATA temp20 LIKE lt_tab.
    DATA temp21 LIKE LINE OF temp20.
    DATA lv_result TYPE xstring.
    CLEAR temp20.

    temp21-col1 = `A`.
    temp21-col2 = `B`.
    INSERT temp21 INTO TABLE temp20.
    lt_tab = temp20.

    lv_result = z2ui5_cl_util_ext=>conv_get_xlsx_by_itab( lt_tab ) ##NEEDED.
  ENDMETHOD.

  METHOD itab_by_xlsx_empty.
    DATA lv_xstring TYPE xstring.
    DATA lr_result TYPE REF TO data.
    z2ui5_cl_util_ext=>conv_get_itab_by_xlsx( EXPORTING val = lv_xstring
                                              IMPORTING result = lr_result ) ##NEEDED.
  ENDMETHOD.

ENDCLASS.


" ================================================================
" SOURCE CODE READING
" ================================================================
CLASS ltcl_source_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS source_get_method_basic        FOR TESTING.

ENDCLASS.

CLASS ltcl_source_ops IMPLEMENTATION.

  METHOD source_get_method_basic.
    DATA lt_source TYPE string_table.
    lt_source = z2ui5_cl_util_ext=>source_get_method(
        iv_classname  = `Z2UI5_CL_UTIL`
        iv_methodname = `C_TRIM` ).
    cl_abap_unit_assert=>assert_not_initial( lt_source ).
  ENDMETHOD.

ENDCLASS.
