
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory_w_bapiret   FOR TESTING RAISING cx_static_check.
    METHODS test_factory_w_cx        FOR TESTING RAISING cx_static_check.
    METHODS test_factory_msg_type    FOR TESTING RAISING cx_static_check.
    METHODS test_factory_empty_input FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory_w_bapiret.
    DATA temp1 TYPE bapirettab.
    DATA temp2 LIKE LINE OF temp1.
    DATA lt_msg LIKE temp1.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_messages.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.


    CLEAR temp1.

    temp2-type = `E`.
    temp2-id = `MSG1`.
    temp2-number = `001`.
    temp2-message = `Error occurred`.
    INSERT temp2 INTO TABLE temp1.
    temp2-type = `I`.
    temp2-id = `MSG2`.
    temp2-number = `002`.
    temp2-message = `Info message`.
    INSERT temp2 INTO TABLE temp1.

    lt_msg = temp1.


    lo_pop = z2ui5_cl_pop_messages=>factory( lt_msg ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_pop->mt_msg ) ).

  ENDMETHOD.

  METHOD test_factory_w_cx.
        DATA lv_val TYPE i.
        DATA lx TYPE REF TO cx_root.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_messages.

    TRY.

        lv_val = 1 / 0 ##NEEDED.

      CATCH cx_root INTO lx.
    ENDTRY.


    lo_pop = z2ui5_cl_pop_messages=>factory( lx ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_not_initial( lo_pop->mt_msg ).

  ENDMETHOD.

  METHOD test_factory_msg_type.
    DATA temp3 TYPE bapirettab.
    DATA temp4 LIKE LINE OF temp3.
    DATA lt_msg LIKE temp3.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_messages.
    FIELD-SYMBOLS <temp5> LIKE LINE OF lo_pop->mt_msg.
    DATA temp6 LIKE sy-tabix.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.


    CLEAR temp3.

    temp4-type = `E`.
    temp4-message = `Error`.
    INSERT temp4 INTO TABLE temp3.
    temp4-type = `W`.
    temp4-message = `Warning`.
    INSERT temp4 INTO TABLE temp3.
    temp4-type = `S`.
    temp4-message = `Success`.
    INSERT temp4 INTO TABLE temp3.

    lt_msg = temp3.


    lo_pop = z2ui5_cl_pop_messages=>factory( lt_msg ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lo_pop->mt_msg ) ).


    temp6 = sy-tabix.
    READ TABLE lo_pop->mt_msg INDEX 1 ASSIGNING <temp5>.
    sy-tabix = temp6.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_not_initial( <temp5>-type ).

  ENDMETHOD.

  METHOD test_factory_empty_input.

    DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_messages.
    CREATE OBJECT lx TYPE z2ui5_cx_ui5_util_error EXPORTING val = `test`.

    lo_pop = z2ui5_cl_pop_messages=>factory( lx ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_not_initial( lo_pop->mt_msg ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_roundtrip DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA mi_client TYPE REF TO z2ui5_if_client.

    METHODS popup_displayed_xml
      RETURNING
        VALUE(result) TYPE string.

    METHODS popup_destroy_queued
      RETURNING
        VALUE(result) TYPE abap_bool.

    METHODS client_create
      IMPORTING
        io_app TYPE REF TO z2ui5_if_app.

    METHODS roundtrip_event
      IMPORTING
        io_app   TYPE REF TO z2ui5_if_app
        iv_event TYPE string.

    METHODS test_factory_maps_messages FOR TESTING RAISING cx_static_check.
    METHODS test_init_displays_popup   FOR TESTING RAISING cx_static_check.
    METHODS test_continue_closes       FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_roundtrip IMPLEMENTATION.

  METHOD popup_displayed_xml.

    DATA temp7 TYPE string.
    DATA temp8 TYPE z2ui5_if_ui5_types=>ty_s_system_action.
    CLEAR temp7.

    READ TABLE mo_action->ms_next-t_action_front INTO temp8 WITH KEY slot = z2ui5_if_client=>cs_view-popup method = z2ui5_if_ui5_types=>cs_slot_action-display.
    IF sy-subrc = 0.
      temp7 = temp8-xml.
    ENDIF.
    result = temp7.

  ENDMETHOD.


  METHOD popup_destroy_queued.

    DATA temp9 LIKE sy-subrc.
    DATA temp1 TYPE xsdboolean.
    READ TABLE mo_action->ms_next-t_action_front WITH KEY slot = z2ui5_if_client=>cs_view-popup method = z2ui5_if_ui5_types=>cs_slot_action-destroy TRANSPORTING NO FIELDS.
    temp9 = sy-subrc.

    temp1 = boolc( temp9 = 0 ).
    result = temp1.

  ENDMETHOD.


  METHOD client_create.

    DATA temp1 TYPE REF TO z2ui5_cl_ui5_handler.
    CREATE OBJECT temp1 TYPE z2ui5_cl_ui5_handler EXPORTING VAL = ``.
    CREATE OBJECT mo_action EXPORTING VAL = temp1.
    mo_action->mo_app->mo_app = io_app.
    CREATE OBJECT mi_client TYPE z2ui5_cl_ui5_client EXPORTING ACTION = mo_action.

  ENDMETHOD.

  METHOD roundtrip_event.

    client_create( io_app ).
    mo_action->mo_app->mv_check_initialized = abap_true.
    mo_action->ms_actual-event = iv_event.
    io_app->main( mi_client ).

  ENDMETHOD.

  METHOD test_factory_maps_messages.

    DATA temp10 TYPE string_table.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_messages.
    FIELD-SYMBOLS <temp12> LIKE LINE OF lo_pop->mt_msg.
    DATA temp13 LIKE sy-tabix.
    CLEAR temp10.
    INSERT `first message` INTO TABLE temp10.
    INSERT `second message` INTO TABLE temp10.

    lo_pop = z2ui5_cl_pop_messages=>factory(
        temp10 ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_pop->mt_msg ) ).


    temp13 = sy-tabix.
    READ TABLE lo_pop->mt_msg INDEX 1 ASSIGNING <temp12>.
    sy-tabix = temp13.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `first message`
                                        act = <temp12>-title ).

  ENDMETHOD.

  METHOD test_init_displays_popup.

    DATA temp14 TYPE string_table.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_messages.
    DATA lv_xml TYPE string.
    DATA temp2 TYPE xsdboolean.
    DATA temp3 TYPE xsdboolean.
    CLEAR temp14.
    INSERT `first message` INTO TABLE temp14.

    lo_pop = z2ui5_cl_pop_messages=>factory( i_messages = temp14
                                                   i_title    = `MSG Title` ).
    client_create( lo_pop ).

    lo_pop->z2ui5_if_app~main( mi_client ).


    lv_xml = popup_displayed_xml( ).

    temp2 = boolc( lv_xml CS `MSG Title` ).
    cl_abap_unit_assert=>assert_true( temp2 ).

    temp3 = boolc( lv_xml CS `MessageView` ).
    cl_abap_unit_assert=>assert_true( temp3 ).

  ENDMETHOD.

  METHOD test_continue_closes.

    DATA temp16 TYPE string_table.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_messages.
    CLEAR temp16.
    INSERT `msg` INTO TABLE temp16.

    lo_pop = z2ui5_cl_pop_messages=>factory( temp16 ).
    roundtrip_event( io_app   = lo_pop
                     iv_event = `BUTTON_CONTINUE` ).

    cl_abap_unit_assert=>assert_true( popup_destroy_queued( ) ).
    cl_abap_unit_assert=>assert_bound( mo_action->ms_next-o_app_leave ).

  ENDMETHOD.

ENDCLASS.
