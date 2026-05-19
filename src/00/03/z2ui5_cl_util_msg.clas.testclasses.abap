CLASS ltcl_unit_test_msg_mapper DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_cx             FOR TESTING RAISING cx_static_check.
    METHODS test_bapiret        FOR TESTING RAISING cx_static_check.
    METHODS test_bapirettab     FOR TESTING RAISING cx_static_check.
    METHODS test_sy             FOR TESTING RAISING cx_static_check.
    METHODS test_get_text_cx    FOR TESTING RAISING cx_static_check.
    METHODS test_get_text_str   FOR TESTING RAISING cx_static_check.
    METHODS test_get_text_empty FOR TESTING RAISING cx_static_check.
    METHODS test_rap_empty      FOR TESTING RAISING cx_static_check.
    METHODS test_rap_failed     FOR TESTING RAISING cx_static_check.
    METHODS test_rap_via_get    FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS ltcl_unit_test_msg_mapper IMPLEMENTATION.

  METHOD test_sy.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA(lv_msg_id) = `NET`.
    MESSAGE ID lv_msg_id TYPE `I` NUMBER `001` INTO DATA(lv_msg_text) ##NEEDED.
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

  METHOD test_rap_empty.

    DATA(lt_result) = z2ui5_cl_util_msg=>msg_get_by_rap( ).

    cl_abap_unit_assert=>assert_initial( lt_result ).

  ENDMETHOD.

  METHOD test_rap_failed.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    " Simulate a RAP failed response: one entity table with a %FAIL-CAUSE = 1 row.
    " Component names %FAIL / CAUSE are created dynamically - ABAP TYPES does not
    " accept `%` in static declarations.
    DATA lo_fail_struct TYPE REF TO cl_abap_structdescr.
    DATA lo_row_struct  TYPE REF TO cl_abap_structdescr.
    DATA lo_row_tab     TYPE REF TO cl_abap_tabledescr.
    DATA lo_top_struct  TYPE REF TO cl_abap_structdescr.
    DATA lr_data        TYPE REF TO data.

    TRY.
        lo_fail_struct = cl_abap_structdescr=>create(
          VALUE #( ( name = `CAUSE` type = cl_abap_elemdescr=>get_i( ) ) ) ).

        lo_row_struct = cl_abap_structdescr=>create(
          VALUE #( ( name = `%FAIL` type = lo_fail_struct ) ) ).

        lo_row_tab = cl_abap_tabledescr=>create( lo_row_struct ).

        lo_top_struct = cl_abap_structdescr=>create(
          VALUE #( ( name = `ENTITY1` type = lo_row_tab ) ) ).
      CATCH cx_root.
        " runtime does not allow `%` in dynamic component names - skip
        RETURN.
    ENDTRY.

    CREATE DATA lr_data TYPE HANDLE lo_top_struct.
    ASSIGN lr_data->* TO FIELD-SYMBOL(<failed>).

    ASSIGN COMPONENT `ENTITY1` OF STRUCTURE <failed> TO FIELD-SYMBOL(<tab>).
    FIELD-SYMBOLS <ftab> TYPE STANDARD TABLE.
    ASSIGN <tab> TO <ftab>.

    DATA lr_row TYPE REF TO data.
    CREATE DATA lr_row TYPE HANDLE lo_row_struct.
    ASSIGN lr_row->* TO FIELD-SYMBOL(<row>).

    ASSIGN COMPONENT `%FAIL` OF STRUCTURE <row> TO FIELD-SYMBOL(<fail>).
    ASSIGN COMPONENT `CAUSE` OF STRUCTURE <fail> TO FIELD-SYMBOL(<cause>).
    <cause> = 1.

    INSERT <row> INTO TABLE <ftab>.

    DATA(lt_result) = z2ui5_cl_util_msg=>msg_get_by_rap( failed = <failed> ).

    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_result ) ).
    cl_abap_unit_assert=>assert_equals( exp = `E` act = lt_result[ 1 ]-type ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*not found*` act = lt_result[ 1 ]-text ).

  ENDMETHOD.

  METHOD test_rap_via_get.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    " Same setup as test_rap_failed, but routed through msg_get (not msg_get_by_rap)
    " to verify the auto-detection branch in msg_get.
    DATA lo_fail_struct TYPE REF TO cl_abap_structdescr.
    DATA lo_row_struct  TYPE REF TO cl_abap_structdescr.
    DATA lo_row_tab     TYPE REF TO cl_abap_tabledescr.
    DATA lo_top_struct  TYPE REF TO cl_abap_structdescr.
    DATA lr_data        TYPE REF TO data.

    TRY.
        lo_fail_struct = cl_abap_structdescr=>create(
          VALUE #( ( name = `CAUSE` type = cl_abap_elemdescr=>get_i( ) ) ) ).

        lo_row_struct = cl_abap_structdescr=>create(
          VALUE #( ( name = `%FAIL` type = lo_fail_struct ) ) ).

        lo_row_tab = cl_abap_tabledescr=>create( lo_row_struct ).

        lo_top_struct = cl_abap_structdescr=>create(
          VALUE #( ( name = `BOOKINGS` type = lo_row_tab ) ) ).
      CATCH cx_root.
        RETURN.
    ENDTRY.

    CREATE DATA lr_data TYPE HANDLE lo_top_struct.
    ASSIGN lr_data->* TO FIELD-SYMBOL(<failed>).

    ASSIGN COMPONENT `BOOKINGS` OF STRUCTURE <failed> TO FIELD-SYMBOL(<tab>).
    FIELD-SYMBOLS <ftab> TYPE STANDARD TABLE.
    ASSIGN <tab> TO <ftab>.

    DATA lr_row TYPE REF TO data.
    CREATE DATA lr_row TYPE HANDLE lo_row_struct.
    ASSIGN lr_row->* TO FIELD-SYMBOL(<row>).

    ASSIGN COMPONENT `%FAIL` OF STRUCTURE <row> TO FIELD-SYMBOL(<fail>).
    ASSIGN COMPONENT `CAUSE` OF STRUCTURE <fail> TO FIELD-SYMBOL(<cause>).
    <cause> = 2.

    INSERT <row> INTO TABLE <ftab>.

    " Auto-detection: msg_get( <failed> ) recognises the RAP shape and extracts.
    DATA(lt_result) = z2ui5_cl_util_msg=>msg_get( <failed> ).

    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_result ) ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*BOOKINGS*locked*` act = lt_result[ 1 ]-text ).

    " msg_get_text should produce the same string content directly.
    DATA(lv_text) = z2ui5_cl_util_msg=>msg_get_text( <failed> ).
    cl_abap_unit_assert=>assert_not_initial( lv_text ).

  ENDMETHOD.

ENDCLASS.
