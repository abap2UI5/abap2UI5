
CLASS ltcl_unit_test_msg_mapper DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_bal            FOR TESTING RAISING cx_static_check.
    METHODS test_cx             FOR TESTING RAISING cx_static_check.
    METHODS test_bapiret        FOR TESTING RAISING cx_static_check.
    METHODS test_bapirettab     FOR TESTING RAISING cx_static_check.
    METHODS test_sy             FOR TESTING RAISING cx_static_check.

    METHODS test_msg_get_string FOR TESTING RAISING cx_static_check.
    METHODS test_msg_get_cx_util_error FOR TESTING RAISING cx_static_check.
    METHODS test_msg_get_empty_struc   FOR TESTING RAISING cx_static_check.

    METHODS test_msg_map_id     FOR TESTING RAISING cx_static_check.
    METHODS test_msg_map_no     FOR TESTING RAISING cx_static_check.
    METHODS test_msg_map_text   FOR TESTING RAISING cx_static_check.
    METHODS test_msg_map_type   FOR TESTING RAISING cx_static_check.
    METHODS test_msg_map_v1     FOR TESTING RAISING cx_static_check.
    METHODS test_msg_map_v2     FOR TESTING RAISING cx_static_check.
    METHODS test_msg_map_v3     FOR TESTING RAISING cx_static_check.
    METHODS test_msg_map_v4     FOR TESTING RAISING cx_static_check.
    METHODS test_msg_map_msgid  FOR TESTING RAISING cx_static_check.
    METHODS test_msg_map_msgno  FOR TESTING RAISING cx_static_check.
    METHODS test_msg_map_msgty  FOR TESTING RAISING cx_static_check.
    METHODS test_msg_map_msgv1  FOR TESTING RAISING cx_static_check.
    METHODS test_msg_map_message FOR TESTING RAISING cx_static_check.
    METHODS test_msg_map_unknown FOR TESTING RAISING cx_static_check.


ENDCLASS.

CLASS ltcl_unit_test_msg_mapper IMPLEMENTATION.

  METHOD test_sy.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    data(lv_dummy2) = `NET`.
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

  method test_bal.

  TYPES: BEGIN OF ty_log_entry,
         msgnumber   TYPE n LENGTH 6,      " Application Log: Internal Message Serial Number
         msgty       TYPE c LENGTH 1,      " Message Type
         msgid       TYPE c LENGTH 20,     " Message Class
         msgno       TYPE n LENGTH 3,      " Message Number
         msgv1       TYPE c LENGTH 50,     " Message Variable
         msgv2       TYPE c LENGTH 50,     " Message Variable
         msgv3       TYPE c LENGTH 50,     " Message Variable
         msgv4       TYPE c LENGTH 50,     " Message Variable
         msgv1_src   TYPE c LENGTH 15,     " Origin of a Message Variable
         msgv2_src   TYPE c LENGTH 15,     " Origin of a Message Variable
         msgv3_src   TYPE c LENGTH 15,     " Origin of a Message Variable
         msgv4_src   TYPE c LENGTH 15,     " Origin of a Message Variable
         detlevel    TYPE c LENGTH 1,      " Level of Detail
         probclass   TYPE c LENGTH 1,      " Problem Class
         alsort      TYPE c LENGTH 3,      " Sort Criterion/Grouping
         time_stmp   TYPE p LENGTH 8 DECIMALS 7, " Message Time Stamp
         msg_count   TYPE i,               " Cumulated Message Count
         context     TYPE c LENGTH 255,    " Context (Generic Placeholder)
         params      TYPE c LENGTH 255,    " Parameters (Generic Placeholder)
         msg_txt     TYPE string,          " Message Text
       END OF ty_log_entry.

  endmethod.

  METHOD test_msg_get_string.

    DATA(lt_result) = z2ui5_cl_util_msg=>msg_get( `This is a plain text message` ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_result ) ).

    cl_abap_unit_assert=>assert_equals( exp = `This is a plain text message`
                                        act = lt_result[ 1 ]-text ).

  ENDMETHOD.

  METHOD test_msg_get_cx_util_error.

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING val = `custom error msg`.
      CATCH z2ui5_cx_util_error INTO DATA(lx).
        DATA(lt_result) = z2ui5_cl_util_msg=>msg_get( lx ).
    ENDTRY.

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_result ) ).

    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = lt_result[ 1 ]-type ).

    cl_abap_unit_assert=>assert_char_cp(
        act = lt_result[ 1 ]-text
        exp = `*custom error msg*` ).

  ENDMETHOD.

  METHOD test_msg_get_empty_struc.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA(ls_msg) = VALUE bapiret1( ).

    DATA(lt_result) = z2ui5_cl_util_msg=>msg_get( ls_msg ).

    cl_abap_unit_assert=>assert_initial( lt_result ).

  ENDMETHOD.

  METHOD test_msg_map_id.

    DATA(ls_msg) = VALUE z2ui5_cl_util=>ty_s_msg( ).
    DATA(ls_result) = z2ui5_cl_util_msg=>msg_map( name = `ID` val = `TEST_ID` is_msg = ls_msg ).

    cl_abap_unit_assert=>assert_equals( exp = `TEST_ID`
                                        act = ls_result-id ).

  ENDMETHOD.

  METHOD test_msg_map_no.

    DATA(ls_msg) = VALUE z2ui5_cl_util=>ty_s_msg( ).
    DATA(ls_result) = z2ui5_cl_util_msg=>msg_map( name = `NUMBER` val = `042` is_msg = ls_msg ).

    cl_abap_unit_assert=>assert_equals( exp = `042`
                                        act = ls_result-no ).

  ENDMETHOD.

  METHOD test_msg_map_text.

    DATA(ls_msg) = VALUE z2ui5_cl_util=>ty_s_msg( ).
    DATA(ls_result) = z2ui5_cl_util_msg=>msg_map( name = `MESSAGE` val = `Hello World` is_msg = ls_msg ).

    cl_abap_unit_assert=>assert_equals( exp = `Hello World`
                                        act = ls_result-text ).

  ENDMETHOD.

  METHOD test_msg_map_type.

    DATA(ls_msg) = VALUE z2ui5_cl_util=>ty_s_msg( ).
    DATA(ls_result) = z2ui5_cl_util_msg=>msg_map( name = `TYPE` val = `E` is_msg = ls_msg ).

    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = ls_result-type ).

  ENDMETHOD.

  METHOD test_msg_map_v1.

    DATA(ls_msg) = VALUE z2ui5_cl_util=>ty_s_msg( ).
    DATA(ls_result) = z2ui5_cl_util_msg=>msg_map( name = `V1` val = `var1` is_msg = ls_msg ).

    cl_abap_unit_assert=>assert_equals( exp = `var1`
                                        act = ls_result-v1 ).

  ENDMETHOD.

  METHOD test_msg_map_v2.

    DATA(ls_msg) = VALUE z2ui5_cl_util=>ty_s_msg( ).
    DATA(ls_result) = z2ui5_cl_util_msg=>msg_map( name = `V2` val = `var2` is_msg = ls_msg ).

    cl_abap_unit_assert=>assert_equals( exp = `var2`
                                        act = ls_result-v2 ).

  ENDMETHOD.

  METHOD test_msg_map_v3.

    DATA(ls_msg) = VALUE z2ui5_cl_util=>ty_s_msg( ).
    DATA(ls_result) = z2ui5_cl_util_msg=>msg_map( name = `V3` val = `var3` is_msg = ls_msg ).

    cl_abap_unit_assert=>assert_equals( exp = `var3`
                                        act = ls_result-v3 ).

  ENDMETHOD.

  METHOD test_msg_map_v4.

    DATA(ls_msg) = VALUE z2ui5_cl_util=>ty_s_msg( ).
    DATA(ls_result) = z2ui5_cl_util_msg=>msg_map( name = `V4` val = `var4` is_msg = ls_msg ).

    cl_abap_unit_assert=>assert_equals( exp = `var4`
                                        act = ls_result-v4 ).

  ENDMETHOD.

  METHOD test_msg_map_msgid.

    DATA(ls_msg) = VALUE z2ui5_cl_util=>ty_s_msg( ).
    DATA(ls_result) = z2ui5_cl_util_msg=>msg_map( name = `MSGID` val = `ALT_ID` is_msg = ls_msg ).

    cl_abap_unit_assert=>assert_equals( exp = `ALT_ID`
                                        act = ls_result-id ).

  ENDMETHOD.

  METHOD test_msg_map_msgno.

    DATA(ls_msg) = VALUE z2ui5_cl_util=>ty_s_msg( ).
    DATA(ls_result) = z2ui5_cl_util_msg=>msg_map( name = `NO` val = `099` is_msg = ls_msg ).

    cl_abap_unit_assert=>assert_equals( exp = `099`
                                        act = ls_result-no ).

  ENDMETHOD.

  METHOD test_msg_map_msgty.

    DATA(ls_msg) = VALUE z2ui5_cl_util=>ty_s_msg( ).
    DATA(ls_result) = z2ui5_cl_util_msg=>msg_map( name = `MSGTY` val = `W` is_msg = ls_msg ).

    cl_abap_unit_assert=>assert_equals( exp = `W`
                                        act = ls_result-type ).

  ENDMETHOD.

  METHOD test_msg_map_msgv1.

    DATA(ls_msg) = VALUE z2ui5_cl_util=>ty_s_msg( ).
    DATA(ls_result) = z2ui5_cl_util_msg=>msg_map( name = `MSGV1` val = `alt_v1` is_msg = ls_msg ).

    cl_abap_unit_assert=>assert_equals( exp = `alt_v1`
                                        act = ls_result-v1 ).

  ENDMETHOD.

  METHOD test_msg_map_message.

    DATA(ls_msg) = VALUE z2ui5_cl_util=>ty_s_msg( ).
    DATA(ls_result) = z2ui5_cl_util_msg=>msg_map( name = `TEXT` val = `alt text` is_msg = ls_msg ).

    cl_abap_unit_assert=>assert_equals( exp = `alt text`
                                        act = ls_result-text ).

  ENDMETHOD.

  METHOD test_msg_map_unknown.

    DATA(ls_msg) = VALUE z2ui5_cl_util=>ty_s_msg( id = `KEEP` ).
    DATA(ls_result) = z2ui5_cl_util_msg=>msg_map( name = `UNKNOWN_FIELD` val = `something` is_msg = ls_msg ).

    " Unknown field names should not modify the message
    cl_abap_unit_assert=>assert_equals( exp = `KEEP`
                                        act = ls_result-id ).

  ENDMETHOD.

ENDCLASS.
