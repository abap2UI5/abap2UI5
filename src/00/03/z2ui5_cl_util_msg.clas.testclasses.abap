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
    METHODS test_rap_via_get    FOR TESTING RAISING cx_static_check.
    METHODS test_collect        FOR TESTING RAISING cx_static_check.
    METHODS test_collect_empty  FOR TESTING RAISING cx_static_check.
    METHODS test_rap_other      FOR TESTING RAISING cx_static_check.
    METHODS test_fallback       FOR TESTING RAISING cx_static_check.
    METHODS test_fallback_skip  FOR TESTING RAISING cx_static_check.
    METHODS test_rap_element    FOR TESTING RAISING cx_static_check.

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

  METHOD test_rap_via_get.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    " Dynamically build a RAP-shaped `failed` structure (one entity table whose
    " row carries `%FAIL-CAUSE`) and verify the auto-detection branch in msg_get.
    " Component names with `%` are created dynamically - ABAP TYPES does not
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

  METHOD test_collect.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA(lt_msg) = VALUE bapirettab(
      ( type = `E` id = `MSG1` number = `001` message = `first error` )
      ( type = `W` id = `MSG2` number = `002` message = `second warning` ) ).

    DATA(lv_collected) = z2ui5_cl_util_msg=>msg_get_collect( lt_msg ).

    cl_abap_unit_assert=>assert_char_cp( exp = `*first error*`     act = lv_collected ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*second warning*`  act = lv_collected ).

  ENDMETHOD.

  METHOD test_collect_empty.

    DATA lt_empty TYPE bapirettab.
    DATA(lv_collected) = z2ui5_cl_util_msg=>msg_get_collect( lt_empty ).

    cl_abap_unit_assert=>assert_initial( lv_collected ).

  ENDMETHOD.

  METHOD test_rap_other.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    " Simulate `reported-%other`: a TABLE OF REF TO cx_root (stand-in for
    " if_abap_behv_message) sitting on a struct with a `%OTHER` component name.
    DATA lo_ref     TYPE REF TO cl_abap_refdescr.
    DATA lo_tab     TYPE REF TO cl_abap_tabledescr.
    DATA lo_top     TYPE REF TO cl_abap_structdescr.
    DATA lr_data    TYPE REF TO data.

    TRY.
        lo_ref = cl_abap_refdescr=>create(
          CAST cl_abap_classdescr( cl_abap_typedescr=>describe_by_name( `CX_ROOT` ) ) ).
        lo_tab = cl_abap_tabledescr=>create( lo_ref ).
        lo_top = cl_abap_structdescr=>create(
          VALUE #( ( name = `%OTHER` type = lo_tab ) ) ).
      CATCH cx_root.
        RETURN.
    ENDTRY.

    CREATE DATA lr_data TYPE HANDLE lo_top.
    ASSIGN lr_data->* TO FIELD-SYMBOL(<reported>).

    ASSIGN COMPONENT `%OTHER` OF STRUCTURE <reported> TO FIELD-SYMBOL(<tab>).
    FIELD-SYMBOLS <ftab> TYPE STANDARD TABLE.
    ASSIGN <tab> TO <ftab>.

    TRY.
        DATA(lv_x) = 1 / 0.
      CATCH cx_root INTO DATA(lx).
        INSERT lx INTO TABLE <ftab>.
    ENDTRY.

    DATA(lt_result) = z2ui5_cl_util_msg=>msg_get( <reported> ).

    cl_abap_unit_assert=>assert_not_initial( lt_result ).

  ENDMETHOD.

  METHOD test_fallback.

    " val empty, val2 has content -> result comes from val2
    DATA lt_empty TYPE bapirettab.
    DATA(lt_full) = VALUE bapirettab(
      ( type = `E` id = `MSG` number = `001` message = `fallback hit` ) ).

    DATA(lt_result) = z2ui5_cl_util_msg=>msg_get( val = lt_empty val2 = lt_full ).

    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_result ) ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*fallback hit*` act = lt_result[ 1 ]-text ).

  ENDMETHOD.

  METHOD test_fallback_skip.

    " val has content -> val2 is ignored
    DATA(lt_first)  = VALUE bapirettab( ( type = `E` id = `A` number = `001` message = `first` ) ).
    DATA(lt_second) = VALUE bapirettab( ( type = `E` id = `B` number = `001` message = `second` ) ).

    DATA(lt_result) = z2ui5_cl_util_msg=>msg_get( val = lt_first val2 = lt_second ).

    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_result ) ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*first*`     act = lt_result[ 1 ]-text ).
    cl_abap_unit_assert=>assert_char_np( exp = `*second*`    act = lt_result[ 1 ]-text ).

  ENDMETHOD.

  METHOD test_rap_element.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    " Build a RAP-shaped failed row carrying %FAIL-CAUSE plus all metadata fields
    " the util surfaces: %ELEMENT-<X>, %STATE_AREA, %OP-%ACTION-<X>, %PID, %CID, %TKY.
    DATA lo_key_struct  TYPE REF TO cl_abap_structdescr.
    DATA lo_tky_struct  TYPE REF TO cl_abap_structdescr.
    DATA lo_fail_struct TYPE REF TO cl_abap_structdescr.
    DATA lo_row_struct  TYPE REF TO cl_abap_structdescr.
    DATA lo_row_tab     TYPE REF TO cl_abap_tabledescr.
    DATA lo_top_struct  TYPE REF TO cl_abap_structdescr.
    DATA lr_data        TYPE REF TO data.
    DATA lo_c1          TYPE REF TO cl_abap_elemdescr.
    DATA lo_str         TYPE REF TO cl_abap_elemdescr.

    TRY.
        lo_c1  = cl_abap_elemdescr=>get_c( p_length = 1 ).
        lo_str = cl_abap_elemdescr=>get_string( ).

        lo_key_struct = cl_abap_structdescr=>create(
          VALUE #( ( name = `BANKCOUNTRY`    type = lo_str )
                   ( name = `BANKINTERNALID` type = lo_str ) ) ).

        lo_tky_struct = cl_abap_structdescr=>create(
          VALUE #( ( name = `%KEY` type = lo_key_struct ) ) ).

        lo_fail_struct = cl_abap_structdescr=>create(
          VALUE #( ( name = `CAUSE` type = cl_abap_elemdescr=>get_i( ) ) ) ).

        lo_row_struct = cl_abap_structdescr=>create(
          VALUE #(
            ( name = `%FAIL`                   type = lo_fail_struct )
            ( name = `%TKY`                    type = lo_tky_struct )
            ( name = `%ELEMENT-CUSTOMERID`     type = lo_c1 )
            ( name = `%STATE_AREA`             type = lo_str )
            ( name = `%OP-%ACTION-DEDUCTDISCOUNT` type = lo_c1 )
            ( name = `%PID`                    type = lo_str )
            ( name = `%CID`                    type = lo_str ) ) ).

        lo_row_tab = cl_abap_tabledescr=>create( lo_row_struct ).

        lo_top_struct = cl_abap_structdescr=>create(
          VALUE #( ( name = `TRAVEL` type = lo_row_tab ) ) ).
      CATCH cx_root.
        RETURN.
    ENDTRY.

    CREATE DATA lr_data TYPE HANDLE lo_top_struct.
    ASSIGN lr_data->* TO FIELD-SYMBOL(<failed>).

    ASSIGN COMPONENT `TRAVEL` OF STRUCTURE <failed> TO FIELD-SYMBOL(<tab>).
    FIELD-SYMBOLS <ftab> TYPE STANDARD TABLE.
    ASSIGN <tab> TO <ftab>.

    DATA lr_row TYPE REF TO data.
    CREATE DATA lr_row TYPE HANDLE lo_row_struct.
    ASSIGN lr_row->* TO FIELD-SYMBOL(<row>).

    ASSIGN COMPONENT `%FAIL` OF STRUCTURE <row> TO FIELD-SYMBOL(<fail>).
    ASSIGN COMPONENT `CAUSE` OF STRUCTURE <fail> TO FIELD-SYMBOL(<cause>).
    <cause> = 1.

    ASSIGN COMPONENT `%TKY` OF STRUCTURE <row> TO FIELD-SYMBOL(<tky>).
    ASSIGN COMPONENT `%KEY` OF STRUCTURE <tky> TO FIELD-SYMBOL(<key>).
    ASSIGN COMPONENT `BANKCOUNTRY`    OF STRUCTURE <key> TO FIELD-SYMBOL(<bc>).
    ASSIGN COMPONENT `BANKINTERNALID` OF STRUCTURE <key> TO FIELD-SYMBOL(<bid>).
    <bc>  = `DE`.
    <bid> = `50070010`.

    ASSIGN COMPONENT `%ELEMENT-CUSTOMERID` OF STRUCTURE <row> TO FIELD-SYMBOL(<el>).
    <el> = `X`.

    ASSIGN COMPONENT `%STATE_AREA` OF STRUCTURE <row> TO FIELD-SYMBOL(<sa>).
    <sa> = `VALIDATE_CUSTOMER`.

    ASSIGN COMPONENT `%OP-%ACTION-DEDUCTDISCOUNT` OF STRUCTURE <row> TO FIELD-SYMBOL(<act>).
    <act> = `X`.

    ASSIGN COMPONENT `%PID` OF STRUCTURE <row> TO FIELD-SYMBOL(<pid>).
    <pid> = `req-42`.

    ASSIGN COMPONENT `%CID` OF STRUCTURE <row> TO FIELD-SYMBOL(<cid>).
    <cid> = `EDIT_BANK`.

    INSERT <row> INTO TABLE <ftab>.

    DATA(lt_result) = z2ui5_cl_util_msg=>msg_get( <failed> ).

    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_result ) ).
    DATA(lt_meta) = lt_result[ 1 ]-t_meta.

    cl_abap_unit_assert=>assert_equals( exp = `CUSTOMERID`
                                        act = lt_meta[ n = `element`    ]-v ).
    cl_abap_unit_assert=>assert_equals( exp = `VALIDATE_CUSTOMER`
                                        act = lt_meta[ n = `state_area` ]-v ).
    cl_abap_unit_assert=>assert_equals( exp = `DEDUCTDISCOUNT`
                                        act = lt_meta[ n = `action`     ]-v ).
    cl_abap_unit_assert=>assert_equals( exp = `req-42`
                                        act = lt_meta[ n = `pid`        ]-v ).
    cl_abap_unit_assert=>assert_equals( exp = `EDIT_BANK`
                                        act = lt_meta[ n = `cid`        ]-v ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*BANKCOUNTRY=DE*`
                                         act = lt_meta[ n = `tky`       ]-v ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*BANKINTERNALID=50070010*`
                                         act = lt_meta[ n = `tky`       ]-v ).

  ENDMETHOD.

ENDCLASS.
