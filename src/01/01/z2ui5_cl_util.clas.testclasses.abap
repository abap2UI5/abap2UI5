CLASS ltcl_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS  test_db_handle FOR TESTING RAISING cx_static_check.
    METHODS  test_db_handle_read_id FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_db_handle.

    IF sy-sysid = 'ABC'.
      RETURN.
    ENDIF.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        selected TYPE abap_bool,
      END OF ty_row.

    DATA(ls_row) = VALUE ty_row(
        title    = `test`
        value    = `val`
        selected = abap_true ).
    DATA(ls_row_result) = VALUE ty_row( ).

    DATA(lv_id) = z2ui5_cl_util=>db_save(
        uname   = `name`
        handle  = `handle1`
        handle2 = `handle2`
        handle3 = `handle3`
        data    = ls_row ).

    z2ui5_cl_util=>db_load_by_id(
      EXPORTING
        id     = lv_id
      IMPORTING
        result = ls_row_result ).

    cl_abap_unit_assert=>assert_equals(
        act = ls_row_result
        exp = ls_row ).

    CLEAR ls_row_result.
    z2ui5_cl_util=>db_load_by_handle(
      EXPORTING
        uname   = `name`
        handle  = `handle1`
        handle2 = `handle2`
        handle3 = `handle3`
      IMPORTING
        result  = ls_row_result ).

    cl_abap_unit_assert=>assert_equals(
       act = ls_row_result
       exp = ls_row ).

  ENDMETHOD.

  METHOD test_db_handle_read_id.

    IF sy-sysid = 'ABC'.
      RETURN.
    ENDIF.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        selected TYPE abap_bool,
      END OF ty_row.

    DATA(ls_row) = VALUE ty_row(
        title    = `test`
        value    = `val`
        selected = abap_true ).

    DATA(lv_id) = z2ui5_cl_util=>db_save(
        uname   = `name`
        handle  = `handle1`
        handle2 = `handle2`
        handle3 = `handle3`
        data    = ls_row ).

    cl_abap_unit_assert=>assert_not_initial( lv_id ).

    DATA(lv_id2) = z2ui5_cl_util=>db_save(
        uname   = `name`
        handle  = `handle1`
        handle2 = `handle2`
        handle3 = `handle3`
        data    = ls_row ).

    cl_abap_unit_assert=>assert_equals(
        act = lv_id
        exp = lv_id2 ).

  ENDMETHOD.

ENDCLASS.
