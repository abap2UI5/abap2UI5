CLASS ltcl_unit_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_bal_read                  FOR TESTING RAISING cx_static_check.
    METHODS test_bal_create                FOR TESTING RAISING cx_static_check.
    METHODS test_bal_update                FOR TESTING RAISING cx_static_check.
    METHODS test_bal_delete                FOR TESTING RAISING cx_static_check.
    METHODS test_lock_get_dequeue        FOR TESTING RAISING cx_static_check.
    METHODS test_source_get_method         FOR TESTING RAISING cx_static_check.
    METHODS test_cal_weekday             FOR TESTING RAISING cx_static_check.
    METHODS test_cal_workdays            FOR TESTING RAISING cx_static_check.
    METHODS test_zip_pack                FOR TESTING RAISING cx_static_check.
    METHODS test_zip_unpack              FOR TESTING RAISING cx_static_check.
    METHODS test_conv_get_xlsx_by_itab     FOR TESTING RAISING cx_static_check.
    METHODS test_conv_get_itab_by_xlsx     FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.

  METHOD test_bal_read.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA lt_msg TYPE z2ui5_cl_util=>ty_t_msg.
    DATA(lt_result) = z2ui5_cl_util_ext=>bal_read( object    = `TEST`
                                                    subobject = `TEST`
                                                    id        = `TEST` ) ##NEEDED.

  ENDMETHOD.

  METHOD test_bal_create.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA lt_log TYPE z2ui5_cl_util=>ty_t_msg.
    z2ui5_cl_util_ext=>bal_create( object    = `TEST`
                                   subobject = `TEST`
                                   id        = `TEST`
                                   t_log     = lt_log ).

  ENDMETHOD.

  METHOD test_bal_update.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA lt_log TYPE z2ui5_cl_util=>ty_t_msg.
    z2ui5_cl_util_ext=>bal_update( object    = `TEST`
                                   subobject = `TEST`
                                   id        = `TEST`
                                   t_log     = lt_log ).

  ENDMETHOD.

  METHOD test_bal_delete.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    z2ui5_cl_util_ext=>bal_delete( object    = `TEST`
                                   subobject = `TEST`
                                   id        = `TEST` ).

  ENDMETHOD.


  METHOD test_lock_get_dequeue.

    DATA lv_result TYPE string.

    lv_result = z2ui5_cl_util_ext=>lock_get_dequeue_by_enqueue( `ENQUEUE_EVVBAKE` ).
    cl_abap_unit_assert=>assert_equals( exp = `DEQUEUE_EVVBAKE`
                                        act = lv_result ).

    lv_result = z2ui5_cl_util_ext=>lock_get_dequeue_by_enqueue( `enqueue_evvbake` ).
    cl_abap_unit_assert=>assert_equals( exp = `DEQUEUE_EVVBAKE`
                                        act = lv_result ).

    lv_result = z2ui5_cl_util_ext=>lock_get_dequeue_by_enqueue( `DEQUEUE_EVVBAKE` ).
    cl_abap_unit_assert=>assert_equals( exp = `DEQUEUE_EVVBAKE`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_source_get_method.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA(lt_source) = z2ui5_cl_util_ext=>source_get_method(
      iv_classname  = `Z2UI5_CL_UTIL`
      iv_methodname = `UUID_GET_C32` ) ##NEEDED.

  ENDMETHOD.


  METHOD test_cal_weekday.

    " 2024-01-01 was a Monday, 2024-01-07 a Sunday
    cl_abap_unit_assert=>assert_equals(
        exp = 1
        act = z2ui5_cl_util_ext=>cal_get_weekday( CONV d( `20240101` ) ) ).
    cl_abap_unit_assert=>assert_false(
        z2ui5_cl_util_ext=>cal_is_weekend( CONV d( `20240101` ) ) ).

    cl_abap_unit_assert=>assert_equals(
        exp = 7
        act = z2ui5_cl_util_ext=>cal_get_weekday( CONV d( `20240107` ) ) ).
    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_util_ext=>cal_is_weekend( CONV d( `20240107` ) ) ).

  ENDMETHOD.

  METHOD test_cal_workdays.

    " Friday 2024-03-15 + 1 workday skips the weekend -> Monday 2024-03-18
    cl_abap_unit_assert=>assert_equals(
        exp = CONV d( `20240318` )
        act = z2ui5_cl_util_ext=>cal_add_workdays( date = CONV d( `20240315` )
                                               days = 1 ) ).

    " Monday 2024-01-01 to Monday 2024-01-08 -> 5 workdays
    cl_abap_unit_assert=>assert_equals(
        exp = 5
        act = z2ui5_cl_util_ext=>cal_count_workdays( date_from = CONV d( `20240101` )
                                                 date_to   = CONV d( `20240108` ) ) ).

  ENDMETHOD.

  METHOD test_zip_pack.

    " Skip when the runtime (e.g. the transpiler) does not provide CL_ABAP_ZIP
    DATA lo_probe TYPE REF TO object.
    TRY.
        CREATE OBJECT lo_probe TYPE ('CL_ABAP_ZIP').
      CATCH cx_root.
        RETURN.
    ENDTRY.

    DATA(lt_in) = VALUE z2ui5_cl_util_ext=>ty_t_zip_file(
        ( name = `hello.txt` content = CONV xstring( `48656C6C6F` ) )
        ( name = `world.txt` content = CONV xstring( `576F726C64` ) ) ).

    DATA(lv_archive) = z2ui5_cl_util_ext=>zip_pack( lt_in ).
    cl_abap_unit_assert=>assert_not_initial( lv_archive ).

  ENDMETHOD.

  METHOD test_zip_unpack.

    " Note: this full round-trip relies on CL_ABAP_ZIP=>LOAD, which the
    " open-abap transpiler runtime does not implement - the method is therefore
    " listed in the transpiler skip list (node/setup/abap_transpile.json).
    DATA(lt_in) = VALUE z2ui5_cl_util_ext=>ty_t_zip_file(
        ( name = `hello.txt` content = CONV xstring( `48656C6C6F` ) )
        ( name = `world.txt` content = CONV xstring( `576F726C64` ) ) ).

    DATA(lv_archive) = z2ui5_cl_util_ext=>zip_pack( lt_in ).
    DATA(lt_out) = z2ui5_cl_util_ext=>zip_unpack( lv_archive ).

    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_out ) ).

    LOOP AT lt_in INTO DATA(ls_in).
      DATA(ls_out) = VALUE #( lt_out[ name = ls_in-name ] OPTIONAL ).
      cl_abap_unit_assert=>assert_equals( exp = ls_in-content
                                          act = ls_out-content ).
    ENDLOOP.

  ENDMETHOD.

  METHOD test_conv_get_xlsx_by_itab.

    TYPES:
      BEGIN OF ty_row,
        col1 TYPE string,
        col2 TYPE string,
      END OF ty_row.

    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_tab = VALUE #( ( col1 = `A` col2 = `B` ) ).

    DATA(lv_result) = z2ui5_cl_util_ext=>conv_get_xlsx_by_itab( lt_tab ) ##NEEDED.

  ENDMETHOD.

  METHOD test_conv_get_itab_by_xlsx.

    DATA lv_xstring TYPE xstring.
    DATA lr_result TYPE REF TO data.

    z2ui5_cl_util_ext=>conv_get_itab_by_xlsx( EXPORTING val    = lv_xstring
                                              IMPORTING result = lr_result ) ##NEEDED.

  ENDMETHOD.

ENDCLASS.
