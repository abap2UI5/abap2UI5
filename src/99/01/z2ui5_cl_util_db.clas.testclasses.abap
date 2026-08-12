CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_s_data,
        name  TYPE string,
        count TYPE i,
      END OF ty_s_data.

    METHODS test_save_returns_id      FOR TESTING RAISING cx_static_check.
    METHODS test_save_load_by_id      FOR TESTING RAISING cx_static_check.
    METHODS test_save_load_by_handle  FOR TESTING RAISING cx_static_check.
    METHODS test_save_updates_entry   FOR TESTING RAISING cx_static_check.
    METHODS test_load_multi_by_handle FOR TESTING RAISING cx_static_check.
    METHODS test_delete_by_handle     FOR TESTING RAISING cx_static_check.
    METHODS test_load_by_id_not_found FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_save_returns_id.

    DATA(ls_data) = VALUE ty_s_data( name  = `test`
                                     count = 1 ).

    DATA(lv_id) = z2ui5_cl_util_db=>save( uname        = `TESTUSER`
                                          handle       = `HANDLE_SAVE`
                                          data         = ls_data
                                          check_commit = abap_false ).

    cl_abap_unit_assert=>assert_not_initial( lv_id ).

  ENDMETHOD.

  METHOD test_save_load_by_id.

    DATA ls_loaded TYPE ty_s_data.

    DATA(ls_data) = VALUE ty_s_data( name  = `by id`
                                     count = 42 ).

    DATA(lv_id) = z2ui5_cl_util_db=>save( uname        = `TESTUSER`
                                          handle       = `HANDLE_BY_ID`
                                          data         = ls_data
                                          check_commit = abap_false ).

    z2ui5_cl_util_db=>load_by_id( EXPORTING id     = lv_id
                                  IMPORTING result = ls_loaded ).

    cl_abap_unit_assert=>assert_equals( exp = ls_data
                                        act = ls_loaded ).

  ENDMETHOD.

  METHOD test_save_load_by_handle.

    DATA ls_loaded TYPE ty_s_data.

    DATA(ls_data) = VALUE ty_s_data( name  = `by handle`
                                     count = 7 ).

    z2ui5_cl_util_db=>save( uname        = `TESTUSER`
                            handle       = `HANDLE_A`
                            handle2      = `HANDLE_B`
                            data         = ls_data
                            check_commit = abap_false ).

    z2ui5_cl_util_db=>load_by_handle( EXPORTING uname   = `TESTUSER`
                                                handle  = `HANDLE_A`
                                                handle2 = `HANDLE_B`
                                      IMPORTING result  = ls_loaded ).

    cl_abap_unit_assert=>assert_equals( exp = ls_data
                                        act = ls_loaded ).

  ENDMETHOD.

  METHOD test_save_updates_entry.

    DATA ls_loaded TYPE ty_s_data.

    DATA(lv_id_first) = z2ui5_cl_util_db=>save( uname        = `TESTUSER`
                                                handle       = `HANDLE_UPDATE`
                                                data         = VALUE ty_s_data( name = `first` )
                                                check_commit = abap_false ).

    DATA(lv_id_second) = z2ui5_cl_util_db=>save( uname        = `TESTUSER`
                                                 handle       = `HANDLE_UPDATE`
                                                 data         = VALUE ty_s_data( name = `second` )
                                                 check_commit = abap_false ).

    cl_abap_unit_assert=>assert_equals( exp = lv_id_first
                                        act = lv_id_second ).

    z2ui5_cl_util_db=>load_by_handle( EXPORTING uname  = `TESTUSER`
                                                handle = `HANDLE_UPDATE`
                                      IMPORTING result = ls_loaded ).

    cl_abap_unit_assert=>assert_equals( exp = `second`
                                        act = ls_loaded-name ).

  ENDMETHOD.

  METHOD test_load_multi_by_handle.

    z2ui5_cl_util_db=>save( uname        = `TESTUSER`
                            handle       = `HANDLE_MULTI`
                            handle2      = `ONE`
                            data         = VALUE ty_s_data( name = `one` )
                            check_commit = abap_false ).

    z2ui5_cl_util_db=>save( uname        = `TESTUSER`
                            handle       = `HANDLE_MULTI`
                            handle2      = `TWO`
                            data         = VALUE ty_s_data( name = `two` )
                            check_commit = abap_false ).

    DATA(lt_result) = z2ui5_cl_util_db=>load_multi_by_handle( uname  = `TESTUSER`
                                                              handle = `HANDLE_MULTI` ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_result ) ).

  ENDMETHOD.

  METHOD test_delete_by_handle.

    z2ui5_cl_util_db=>save( uname        = `TESTUSER`
                            handle       = `HANDLE_DELETE`
                            data         = VALUE ty_s_data( name = `to delete` )
                            check_commit = abap_false ).

    z2ui5_cl_util_db=>delete_by_handle( uname        = `TESTUSER`
                                        handle       = `HANDLE_DELETE`
                                        check_commit = abap_false ).

    TRY.
        DATA ls_loaded TYPE ty_s_data.
        z2ui5_cl_util_db=>load_by_handle( EXPORTING uname  = `TESTUSER`
                                                    handle = `HANDLE_DELETE`
                                          IMPORTING result = ls_loaded ).
        cl_abap_unit_assert=>fail( `NO_EXCEPTION_AFTER_DELETE` ).
      CATCH z2ui5_cx_util_error ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD test_load_by_id_not_found.

    TRY.
        DATA ls_loaded TYPE ty_s_data.
        z2ui5_cl_util_db=>load_by_id( EXPORTING id     = `DOES_NOT_EXIST`
                                      IMPORTING result = ls_loaded ).
        cl_abap_unit_assert=>fail( `NO_EXCEPTION_FOR_UNKNOWN_ID` ).
      CATCH z2ui5_cx_util_error ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
