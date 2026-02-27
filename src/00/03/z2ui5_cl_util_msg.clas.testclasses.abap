CLASS ltcl_unit_test_msg_mapper DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_bal            FOR TESTING RAISING cx_static_check.
    METHODS test_cx             FOR TESTING RAISING cx_static_check.
    METHODS test_bapiret        FOR TESTING RAISING cx_static_check.
    METHODS test_bapirettab     FOR TESTING RAISING cx_static_check.
    METHODS test_sy             FOR TESTING RAISING cx_static_check.
    METHODS test_get_text_cx    FOR TESTING RAISING cx_static_check.
    METHODS test_get_text_str   FOR TESTING RAISING cx_static_check.
    METHODS test_get_text_empty FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS ltcl_unit_test_msg_mapper IMPLEMENTATION.

  METHOD test_sy.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA(lv_dummy2) = `NET`.
    MESSAGE ID lv_dummy2 TYPE `I` NUMBER `001` INTO DATA(lv_dummy).
    DATA(lt_result) = z2ui5_cl_util_msg=>msg_get_by_sy( ).

    cl_abap_unit_assert=>assert_equals( exp = `NET`
                                        act = lt_result[ 1 ]-id ).

    cl_abap_unit_assert=>assert_equals( exp = `001`
                                        act = lt_result[ 1 ]-no ).

    cl_abap_unit_assert=>assert_equals( exp = `I`
                                        act = lt_result[ 1 ]-type ).

  ENDMETHOD.

  METHOD test_bapiret.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA(lt_msg) = VALUE bapirettab(
      ( type = `E` id = `MSG1` number = `001` message = `An empty Report field causes an empty XML Message to be sent` )
     ).

    DATA(lt_result) = z2ui5_cl_util_msg=>msg_get( lt_msg[ 1 ] ).

    cl_abap_unit_assert=>assert_equals( exp = `MSG1`
                                        act = lt_result[ 1 ]-id ).

    cl_abap_unit_assert=>assert_equals( exp = `001`
                                        act = lt_result[ 1 ]-no ).

    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = lt_result[ 1 ]-type ).

  ENDMETHOD.

  METHOD test_bapirettab.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA(lt_msg) = VALUE bapirettab(
      ( type = `E` id = `MSG1` number = `001` message = `An empty Report field causes an empty XML Message to be sent` )
      ( type = `I` id = `MSG2` number = `002` message = `Product already in use` ) ).

    DATA(lt_result) = z2ui5_cl_util_msg=>msg_get( lt_msg ).

    cl_abap_unit_assert=>assert_equals( exp = `MSG1`
                                        act = lt_result[ 1 ]-id ).

    cl_abap_unit_assert=>assert_equals( exp = `001`
                                        act = lt_result[ 1 ]-no ).

    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = lt_result[ 1 ]-type ).

  ENDMETHOD.

  METHOD test_cx.

    TRY.
        DATA(lv_val) = 1 / 0.
      CATCH cx_root INTO DATA(lx).
        DATA(lt_result) = z2ui5_cl_util_msg=>msg_get( lx ).
    ENDTRY.

    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = lt_result[ 1 ]-type ).

  ENDMETHOD.

  METHOD test_get_text_cx.

    TRY.
        DATA(lv_val) = 1 / 0.
      CATCH cx_root INTO DATA(lx).
        DATA(lv_text) = z2ui5_cl_util_msg=>msg_get_text( lx ).
    ENDTRY.

    cl_abap_unit_assert=>assert_not_initial( lv_text ).

  ENDMETHOD.

  METHOD test_get_text_str.

    DATA(lv_text) = z2ui5_cl_util_msg=>msg_get_text( `Hello World` ).

    cl_abap_unit_assert=>assert_equals( exp = `Hello World` act = lv_text ).

  ENDMETHOD.

  METHOD test_get_text_empty.

    DATA ls_empty TYPE z2ui5_cl_util=>ty_s_msg.
    DATA(lv_text) = z2ui5_cl_util_msg=>msg_get_text( ls_empty ).

    cl_abap_unit_assert=>assert_initial( lv_text ).

  ENDMETHOD.

  METHOD test_bal.

    TYPES: BEGIN OF ty_log_entry,
           msgnumber   TYPE n LENGTH 6,
           msgty       TYPE c LENGTH 1,
           msgid       TYPE c LENGTH 20,
           msgno       TYPE n LENGTH 3,
           msgv1       TYPE c LENGTH 50,
           msgv2       TYPE c LENGTH 50,
           msgv3       TYPE c LENGTH 50,
           msgv4       TYPE c LENGTH 50,
           msgv1_src   TYPE c LENGTH 15,
           msgv2_src   TYPE c LENGTH 15,
           msgv3_src   TYPE c LENGTH 15,
           msgv4_src   TYPE c LENGTH 15,
           detlevel    TYPE c LENGTH 1,
           probclass   TYPE c LENGTH 1,
           alsort      TYPE c LENGTH 3,
           time_stmp   TYPE p LENGTH 8 DECIMALS 7,
           msg_count   TYPE i,
           context     TYPE c LENGTH 255,
           params      TYPE c LENGTH 255,
           msg_txt     TYPE string,
         END OF ty_log_entry.

  ENDMETHOD.

ENDCLASS.
