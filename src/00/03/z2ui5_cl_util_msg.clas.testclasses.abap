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
    DATA lv_msg_id TYPE string.
    DATA lv_msg_text TYPE string.
    DATA lt_result TYPE z2ui5_cl_util=>ty_t_msg.
    DATA temp1 LIKE LINE OF lt_result.
    DATA temp2 LIKE sy-tabix.
    DATA temp3 LIKE LINE OF lt_result.
    DATA temp4 LIKE sy-tabix.
    DATA temp5 LIKE LINE OF lt_result.
    DATA temp6 LIKE sy-tabix.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.


    lv_msg_id = `NET`.

    MESSAGE ID lv_msg_id TYPE `I` NUMBER `001` INTO lv_msg_text ##NEEDED.

    lt_result = z2ui5_cl_util_msg=>msg_get_by_sy( ).



    temp2 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp1.
    sy-tabix = temp2.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `NET`
                                        act = temp1-id ).



    temp4 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp3.
    sy-tabix = temp4.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `001`
                                        act = temp3-no ).



    temp6 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp5.
    sy-tabix = temp6.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `I`
                                        act = temp5-type ).

  ENDMETHOD.

  METHOD test_bapiret.
    DATA temp7 TYPE bapirettab.
    DATA temp8 LIKE LINE OF temp7.
    DATA lt_msg LIKE temp7.
    DATA lt_result TYPE z2ui5_cl_util=>ty_t_msg.
    DATA temp1 LIKE LINE OF lt_msg.
    DATA temp2 LIKE sy-tabix.
    DATA temp9 LIKE LINE OF lt_result.
    DATA temp10 LIKE sy-tabix.
    DATA temp11 LIKE LINE OF lt_result.
    DATA temp12 LIKE sy-tabix.
    DATA temp13 LIKE LINE OF lt_result.
    DATA temp14 LIKE sy-tabix.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.


    CLEAR temp7.

    temp8-type = `E`.
    temp8-id = `MSG1`.
    temp8-number = `001`.
    temp8-message = `An empty Report field causes an empty XML Message to be sent`.
    INSERT temp8 INTO TABLE temp7.

    lt_msg = temp7.




    temp2 = sy-tabix.
    READ TABLE lt_msg INDEX 1 INTO temp1.
    sy-tabix = temp2.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lt_result = z2ui5_cl_util_msg=>msg_get( temp1 ).



    temp10 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp9.
    sy-tabix = temp10.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MSG1`
                                        act = temp9-id ).



    temp12 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp11.
    sy-tabix = temp12.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `001`
                                        act = temp11-no ).



    temp14 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp13.
    sy-tabix = temp14.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = temp13-type ).

  ENDMETHOD.

  METHOD test_bapirettab.
    DATA temp15 TYPE bapirettab.
    DATA temp16 LIKE LINE OF temp15.
    DATA lt_msg LIKE temp15.
    DATA lt_result TYPE z2ui5_cl_util=>ty_t_msg.
    DATA temp17 LIKE LINE OF lt_result.
    DATA temp18 LIKE sy-tabix.
    DATA temp19 LIKE LINE OF lt_result.
    DATA temp20 LIKE sy-tabix.
    DATA temp21 LIKE LINE OF lt_result.
    DATA temp22 LIKE sy-tabix.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.


    CLEAR temp15.

    temp16-type = `E`.
    temp16-id = `MSG1`.
    temp16-number = `001`.
    temp16-message = `An empty Report field causes an empty XML Message to be sent`.
    INSERT temp16 INTO TABLE temp15.
    temp16-type = `I`.
    temp16-id = `MSG2`.
    temp16-number = `002`.
    temp16-message = `Product already in use`.
    INSERT temp16 INTO TABLE temp15.

    lt_msg = temp15.


    lt_result = z2ui5_cl_util_msg=>msg_get( lt_msg ).



    temp18 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp17.
    sy-tabix = temp18.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MSG1`
                                        act = temp17-id ).



    temp20 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp19.
    sy-tabix = temp20.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `001`
                                        act = temp19-no ).



    temp22 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp21.
    sy-tabix = temp22.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = temp21-type ).

  ENDMETHOD.

  METHOD test_cx.
        DATA lv_val TYPE i.
        DATA lx TYPE REF TO cx_root.
        DATA lt_result TYPE z2ui5_cl_util=>ty_t_msg.
    DATA temp23 LIKE LINE OF lt_result.
    DATA temp24 LIKE sy-tabix.

    TRY.

        lv_val = 1 / 0.

      CATCH cx_root INTO lx.

        lt_result = z2ui5_cl_util_msg=>msg_get( lx ).
    ENDTRY.



    temp24 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp23.
    sy-tabix = temp24.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = temp23-type ).

  ENDMETHOD.

  METHOD test_get_text_cx.
        DATA lv_val TYPE i.
        DATA lx TYPE REF TO cx_root.
        DATA lv_text TYPE string.

    TRY.

        lv_val = 1 / 0.

      CATCH cx_root INTO lx.

        lv_text = z2ui5_cl_util_msg=>msg_get_text( lx ).
    ENDTRY.

    cl_abap_unit_assert=>assert_not_initial( lv_text ).

  ENDMETHOD.

  METHOD test_get_text_str.

    DATA lv_text TYPE string.
    lv_text = z2ui5_cl_util_msg=>msg_get_text( `Hello World` ).

    cl_abap_unit_assert=>assert_equals( exp = `Hello World` act = lv_text ).

  ENDMETHOD.

  METHOD test_get_text_empty.

    DATA ls_empty TYPE z2ui5_cl_util=>ty_s_msg.
    DATA lv_text TYPE string.
    lv_text = z2ui5_cl_util_msg=>msg_get_text( ls_empty ).

    cl_abap_unit_assert=>assert_initial( lv_text ).

  ENDMETHOD.

  METHOD test_rap_via_get.
    DATA lo_fail_struct TYPE REF TO cl_abap_structdescr.
    DATA lo_row_struct TYPE REF TO cl_abap_structdescr.
    DATA lo_row_tab TYPE REF TO cl_abap_tabledescr.
    DATA lo_top_struct TYPE REF TO cl_abap_structdescr.
    DATA lr_data TYPE REF TO data.
        DATA temp25 TYPE abap_component_tab.
        DATA temp26 LIKE LINE OF temp25.
        DATA temp27 TYPE abap_component_tab.
        DATA temp28 LIKE LINE OF temp27.
        DATA temp29 TYPE abap_component_tab.
        DATA temp30 LIKE LINE OF temp29.
    FIELD-SYMBOLS <failed> TYPE data.
    FIELD-SYMBOLS <tab> TYPE any.
    FIELD-SYMBOLS <ftab> TYPE STANDARD TABLE.
    DATA lr_row TYPE REF TO data.
    FIELD-SYMBOLS <row> TYPE data.
    FIELD-SYMBOLS <fail> TYPE any.
    FIELD-SYMBOLS <cause> TYPE any.
    DATA lt_result TYPE z2ui5_cl_util=>ty_t_msg.
    DATA temp31 LIKE LINE OF lt_result.
    DATA temp32 LIKE sy-tabix.
    DATA lv_text TYPE string.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    " Dynamically build a RAP-shaped `failed` structure (one entity table whose
    " row carries `%FAIL-CAUSE`) and verify the auto-detection branch in msg_get.
    " Component names with `%` are created dynamically - ABAP TYPES does not
    " accept `%` in static declarations.






    TRY.

        CLEAR temp25.

        temp26-name = `CAUSE`.
        temp26-type = cl_abap_elemdescr=>get_i( ).
        INSERT temp26 INTO TABLE temp25.
        lo_fail_struct = cl_abap_structdescr=>create(
          temp25 ).


        CLEAR temp27.

        temp28-name = `%FAIL`.
        temp28-type = lo_fail_struct.
        INSERT temp28 INTO TABLE temp27.
        lo_row_struct = cl_abap_structdescr=>create(
          temp27 ).

        lo_row_tab = cl_abap_tabledescr=>create( lo_row_struct ).


        CLEAR temp29.

        temp30-name = `BOOKINGS`.
        temp30-type = lo_row_tab.
        INSERT temp30 INTO TABLE temp29.
        lo_top_struct = cl_abap_structdescr=>create(
          temp29 ).
      CATCH cx_root.
        RETURN.
    ENDTRY.

    CREATE DATA lr_data TYPE HANDLE lo_top_struct.

    ASSIGN lr_data->* TO <failed>.


    ASSIGN COMPONENT `BOOKINGS` OF STRUCTURE <failed> TO <tab>.

    ASSIGN <tab> TO <ftab>.


    CREATE DATA lr_row TYPE HANDLE lo_row_struct.

    ASSIGN lr_row->* TO <row>.


    ASSIGN COMPONENT `%FAIL` OF STRUCTURE <row> TO <fail>.

    ASSIGN COMPONENT `CAUSE` OF STRUCTURE <fail> TO <cause>.
    <cause> = 2.

    INSERT <row> INTO TABLE <ftab>.

    " Auto-detection: msg_get( <failed> ) recognises the RAP shape and extracts.

    lt_result = z2ui5_cl_util_msg=>msg_get( <failed> ).

    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_result ) ).


    temp32 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp31.
    sy-tabix = temp32.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_char_cp( exp = `*BOOKINGS*locked*` act = temp31-text ).

    " msg_get_text should produce the same string content directly.

    lv_text = z2ui5_cl_util_msg=>msg_get_text( <failed> ).
    cl_abap_unit_assert=>assert_not_initial( lv_text ).

  ENDMETHOD.

  METHOD test_collect.
    DATA temp33 TYPE bapirettab.
    DATA temp34 LIKE LINE OF temp33.
    DATA lt_msg LIKE temp33.
    DATA lv_collected TYPE string.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.


    CLEAR temp33.

    temp34-type = `E`.
    temp34-id = `MSG1`.
    temp34-number = `001`.
    temp34-message = `first error`.
    INSERT temp34 INTO TABLE temp33.
    temp34-type = `W`.
    temp34-id = `MSG2`.
    temp34-number = `002`.
    temp34-message = `second warning`.
    INSERT temp34 INTO TABLE temp33.

    lt_msg = temp33.


    lv_collected = z2ui5_cl_util_msg=>msg_get_collect( lt_msg ).

    cl_abap_unit_assert=>assert_char_cp( exp = `*first error*`     act = lv_collected ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*second warning*`  act = lv_collected ).

  ENDMETHOD.

  METHOD test_collect_empty.

    DATA lt_empty TYPE bapirettab.
    DATA lv_collected TYPE string.
    lv_collected = z2ui5_cl_util_msg=>msg_get_collect( lt_empty ).

    cl_abap_unit_assert=>assert_initial( lv_collected ).

  ENDMETHOD.

  METHOD test_rap_other.
    DATA lo_ref TYPE REF TO cl_abap_refdescr.
    DATA lo_tab TYPE REF TO cl_abap_tabledescr.
    DATA lo_top TYPE REF TO cl_abap_structdescr.
    DATA lr_data TYPE REF TO data.
        DATA temp35 TYPE REF TO cl_abap_classdescr.
        DATA temp36 TYPE abap_component_tab.
        DATA temp37 LIKE LINE OF temp36.
    FIELD-SYMBOLS <reported> TYPE data.
    FIELD-SYMBOLS <tab> TYPE any.
    FIELD-SYMBOLS <ftab> TYPE STANDARD TABLE.
        DATA lv_x TYPE i.
        DATA lx TYPE REF TO cx_root.
    DATA lt_result TYPE z2ui5_cl_util=>ty_t_msg.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    " Simulate `reported-%other`: a TABLE OF REF TO cx_root (stand-in for
    " if_abap_behv_message) sitting on a struct with a `%OTHER` component name.





    TRY.

        temp35 ?= cl_abap_typedescr=>describe_by_name( `CX_ROOT` ).
        lo_ref = cl_abap_refdescr=>create(
          temp35 ).
        lo_tab = cl_abap_tabledescr=>create( lo_ref ).

        CLEAR temp36.

        temp37-name = `%OTHER`.
        temp37-type = lo_tab.
        INSERT temp37 INTO TABLE temp36.
        lo_top = cl_abap_structdescr=>create(
          temp36 ).
      CATCH cx_root.
        RETURN.
    ENDTRY.

    CREATE DATA lr_data TYPE HANDLE lo_top.

    ASSIGN lr_data->* TO <reported>.


    ASSIGN COMPONENT `%OTHER` OF STRUCTURE <reported> TO <tab>.

    ASSIGN <tab> TO <ftab>.

    TRY.

        lv_x = 1 / 0.

      CATCH cx_root INTO lx.
        INSERT lx INTO TABLE <ftab>.
    ENDTRY.


    lt_result = z2ui5_cl_util_msg=>msg_get( <reported> ).

    cl_abap_unit_assert=>assert_not_initial( lt_result ).

  ENDMETHOD.

  METHOD test_fallback.

    " val empty, val2 has content -> result comes from val2
    DATA lt_empty TYPE bapirettab.
    DATA temp38 TYPE bapirettab.
    DATA temp39 LIKE LINE OF temp38.
    DATA lt_full LIKE temp38.
    DATA lt_result TYPE z2ui5_cl_util=>ty_t_msg.
    DATA temp40 LIKE LINE OF lt_result.
    DATA temp41 LIKE sy-tabix.
    CLEAR temp38.

    temp39-type = `E`.
    temp39-id = `MSG`.
    temp39-number = `001`.
    temp39-message = `fallback hit`.
    INSERT temp39 INTO TABLE temp38.

    lt_full = temp38.


    lt_result = z2ui5_cl_util_msg=>msg_get( val = lt_empty val2 = lt_full ).

    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_result ) ).


    temp41 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp40.
    sy-tabix = temp41.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_char_cp( exp = `*fallback hit*` act = temp40-text ).

  ENDMETHOD.

  METHOD test_fallback_skip.

    " val has content -> val2 is ignored
    DATA temp42 TYPE bapirettab.
    DATA temp43 LIKE LINE OF temp42.
    DATA lt_first LIKE temp42.
    DATA temp44 TYPE bapirettab.
    DATA temp45 LIKE LINE OF temp44.
    DATA lt_second LIKE temp44.
    DATA lt_result TYPE z2ui5_cl_util=>ty_t_msg.
    DATA temp46 LIKE LINE OF lt_result.
    DATA temp47 LIKE sy-tabix.
    DATA temp48 LIKE LINE OF lt_result.
    DATA temp49 LIKE sy-tabix.
    CLEAR temp42.

    temp43-type = `E`.
    temp43-id = `A`.
    temp43-number = `001`.
    temp43-message = `first`.
    INSERT temp43 INTO TABLE temp42.

    lt_first = temp42.

    CLEAR temp44.

    temp45-type = `E`.
    temp45-id = `B`.
    temp45-number = `001`.
    temp45-message = `second`.
    INSERT temp45 INTO TABLE temp44.

    lt_second = temp44.


    lt_result = z2ui5_cl_util_msg=>msg_get( val = lt_first val2 = lt_second ).

    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_result ) ).


    temp47 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp46.
    sy-tabix = temp47.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_char_cp( exp = `*first*`     act = temp46-text ).


    temp49 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp48.
    sy-tabix = temp49.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_char_np( exp = `*second*`    act = temp48-text ).

  ENDMETHOD.

  METHOD test_rap_element.
    DATA lo_key_struct TYPE REF TO cl_abap_structdescr.
    DATA lo_tky_struct TYPE REF TO cl_abap_structdescr.
    DATA lo_fail_struct TYPE REF TO cl_abap_structdescr.
    DATA lo_row_struct TYPE REF TO cl_abap_structdescr.
    DATA lo_row_tab TYPE REF TO cl_abap_tabledescr.
    DATA lo_top_struct TYPE REF TO cl_abap_structdescr.
    DATA lr_data TYPE REF TO data.
    DATA lo_c1 TYPE REF TO cl_abap_elemdescr.
    DATA lo_str TYPE REF TO cl_abap_elemdescr.
        DATA temp50 TYPE abap_component_tab.
        DATA temp51 LIKE LINE OF temp50.
        DATA temp52 TYPE abap_component_tab.
        DATA temp53 LIKE LINE OF temp52.
        DATA temp54 TYPE abap_component_tab.
        DATA temp55 LIKE LINE OF temp54.
        DATA temp56 TYPE abap_component_tab.
        DATA temp57 LIKE LINE OF temp56.
        DATA temp58 TYPE abap_component_tab.
        DATA temp59 LIKE LINE OF temp58.
    FIELD-SYMBOLS <failed> TYPE data.
    FIELD-SYMBOLS <tab> TYPE any.
    FIELD-SYMBOLS <ftab> TYPE STANDARD TABLE.
    DATA lr_row TYPE REF TO data.
    FIELD-SYMBOLS <row> TYPE data.
    FIELD-SYMBOLS <fail> TYPE any.
    FIELD-SYMBOLS <cause> TYPE any.
    FIELD-SYMBOLS <tky> TYPE any.
    FIELD-SYMBOLS <key> TYPE any.
    FIELD-SYMBOLS <bc> TYPE any.
    FIELD-SYMBOLS <bid> TYPE any.
    FIELD-SYMBOLS <el> TYPE any.
    FIELD-SYMBOLS <sa> TYPE any.
    FIELD-SYMBOLS <act> TYPE any.
    FIELD-SYMBOLS <pid> TYPE any.
    FIELD-SYMBOLS <cid> TYPE any.
    DATA lt_result TYPE z2ui5_cl_util=>ty_t_msg.
    DATA lt_meta TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp3 LIKE LINE OF lt_result.
    DATA temp4 LIKE sy-tabix.
    DATA temp60 LIKE LINE OF lt_meta.
    DATA temp61 LIKE sy-tabix.
    DATA temp62 LIKE LINE OF lt_meta.
    DATA temp63 LIKE sy-tabix.
    DATA temp64 LIKE LINE OF lt_meta.
    DATA temp65 LIKE sy-tabix.
    DATA temp66 LIKE LINE OF lt_meta.
    DATA temp67 LIKE sy-tabix.
    DATA temp68 LIKE LINE OF lt_meta.
    DATA temp69 LIKE sy-tabix.
    DATA temp70 LIKE LINE OF lt_meta.
    DATA temp71 LIKE sy-tabix.
    DATA temp72 LIKE LINE OF lt_meta.
    DATA temp73 LIKE sy-tabix.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    " Build a RAP-shaped failed row carrying %FAIL-CAUSE plus all metadata fields
    " the util surfaces: %ELEMENT-<X>, %STATE_AREA, %OP-%ACTION-<X>, %PID, %CID, %TKY.










    TRY.
        lo_c1  = cl_abap_elemdescr=>get_c( p_length = 1 ).
        lo_str = cl_abap_elemdescr=>get_string( ).


        CLEAR temp50.

        temp51-name = `BANKCOUNTRY`.
        temp51-type = lo_str.
        INSERT temp51 INTO TABLE temp50.
        temp51-name = `BANKINTERNALID`.
        temp51-type = lo_str.
        INSERT temp51 INTO TABLE temp50.
        lo_key_struct = cl_abap_structdescr=>create(
          temp50 ).


        CLEAR temp52.

        temp53-name = `%KEY`.
        temp53-type = lo_key_struct.
        INSERT temp53 INTO TABLE temp52.
        lo_tky_struct = cl_abap_structdescr=>create(
          temp52 ).


        CLEAR temp54.

        temp55-name = `CAUSE`.
        temp55-type = cl_abap_elemdescr=>get_i( ).
        INSERT temp55 INTO TABLE temp54.
        lo_fail_struct = cl_abap_structdescr=>create(
          temp54 ).


        CLEAR temp56.

        temp57-name = `%FAIL`.
        temp57-type = lo_fail_struct.
        INSERT temp57 INTO TABLE temp56.
        temp57-name = `%TKY`.
        temp57-type = lo_tky_struct.
        INSERT temp57 INTO TABLE temp56.
        temp57-name = `%ELEMENT-CUSTOMERID`.
        temp57-type = lo_c1.
        INSERT temp57 INTO TABLE temp56.
        temp57-name = `%STATE_AREA`.
        temp57-type = lo_str.
        INSERT temp57 INTO TABLE temp56.
        temp57-name = `%OP-%ACTION-DEDUCTDISCOUNT`.
        temp57-type = lo_c1.
        INSERT temp57 INTO TABLE temp56.
        temp57-name = `%PID`.
        temp57-type = lo_str.
        INSERT temp57 INTO TABLE temp56.
        temp57-name = `%CID`.
        temp57-type = lo_str.
        INSERT temp57 INTO TABLE temp56.
        lo_row_struct = cl_abap_structdescr=>create(
          temp56 ).

        lo_row_tab = cl_abap_tabledescr=>create( lo_row_struct ).


        CLEAR temp58.

        temp59-name = `TRAVEL`.
        temp59-type = lo_row_tab.
        INSERT temp59 INTO TABLE temp58.
        lo_top_struct = cl_abap_structdescr=>create(
          temp58 ).
      CATCH cx_root.
        RETURN.
    ENDTRY.

    CREATE DATA lr_data TYPE HANDLE lo_top_struct.

    ASSIGN lr_data->* TO <failed>.


    ASSIGN COMPONENT `TRAVEL` OF STRUCTURE <failed> TO <tab>.

    ASSIGN <tab> TO <ftab>.


    CREATE DATA lr_row TYPE HANDLE lo_row_struct.

    ASSIGN lr_row->* TO <row>.


    ASSIGN COMPONENT `%FAIL` OF STRUCTURE <row> TO <fail>.

    ASSIGN COMPONENT `CAUSE` OF STRUCTURE <fail> TO <cause>.
    <cause> = 1.


    ASSIGN COMPONENT `%TKY` OF STRUCTURE <row> TO <tky>.

    ASSIGN COMPONENT `%KEY` OF STRUCTURE <tky> TO <key>.

    ASSIGN COMPONENT `BANKCOUNTRY`    OF STRUCTURE <key> TO <bc>.

    ASSIGN COMPONENT `BANKINTERNALID` OF STRUCTURE <key> TO <bid>.
    <bc>  = `DE`.
    <bid> = `50070010`.


    ASSIGN COMPONENT `%ELEMENT-CUSTOMERID` OF STRUCTURE <row> TO <el>.
    <el> = `X`.


    ASSIGN COMPONENT `%STATE_AREA` OF STRUCTURE <row> TO <sa>.
    <sa> = `VALIDATE_CUSTOMER`.


    ASSIGN COMPONENT `%OP-%ACTION-DEDUCTDISCOUNT` OF STRUCTURE <row> TO <act>.
    <act> = `X`.


    ASSIGN COMPONENT `%PID` OF STRUCTURE <row> TO <pid>.
    <pid> = `req-42`.


    ASSIGN COMPONENT `%CID` OF STRUCTURE <row> TO <cid>.
    <cid> = `EDIT_BANK`.

    INSERT <row> INTO TABLE <ftab>.


    lt_result = z2ui5_cl_util_msg=>msg_get( <failed> ).

    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_result ) ).



    temp4 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp3.
    sy-tabix = temp4.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lt_meta = temp3-t_meta.



    temp61 = sy-tabix.
    READ TABLE lt_meta WITH KEY n = `element` INTO temp60.
    sy-tabix = temp61.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `CUSTOMERID`
                                        act = temp60-v ).


    temp63 = sy-tabix.
    READ TABLE lt_meta WITH KEY n = `state_area` INTO temp62.
    sy-tabix = temp63.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `VALIDATE_CUSTOMER`
                                        act = temp62-v ).


    temp65 = sy-tabix.
    READ TABLE lt_meta WITH KEY n = `action` INTO temp64.
    sy-tabix = temp65.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `DEDUCTDISCOUNT`
                                        act = temp64-v ).


    temp67 = sy-tabix.
    READ TABLE lt_meta WITH KEY n = `pid` INTO temp66.
    sy-tabix = temp67.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `req-42`
                                        act = temp66-v ).


    temp69 = sy-tabix.
    READ TABLE lt_meta WITH KEY n = `cid` INTO temp68.
    sy-tabix = temp69.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `EDIT_BANK`
                                        act = temp68-v ).


    temp71 = sy-tabix.
    READ TABLE lt_meta WITH KEY n = `tky` INTO temp70.
    sy-tabix = temp71.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_char_cp( exp = `*BANKCOUNTRY=DE*`
                                         act = temp70-v ).


    temp73 = sy-tabix.
    READ TABLE lt_meta WITH KEY n = `tky` INTO temp72.
    sy-tabix = temp73.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_char_cp( exp = `*BANKINTERNALID=50070010*`
                                         act = temp72-v ).

  ENDMETHOD.

ENDCLASS.
