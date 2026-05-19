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

ENDCLASS.
