
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

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA(lt_msg) = VALUE bapirettab(
      ( type = `E` id = `MSG1` number = `001` message = `Error occurred` )
      ( type = `I` id = `MSG2` number = `002` message = `Info message` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_messages=>factory( lt_msg ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_pop->mt_msg ) ).

  ENDMETHOD.

  METHOD test_factory_w_cx.

    TRY.
        DATA(lv_val) = 1 / 0 ##NEEDED.
      CATCH cx_root INTO DATA(lx).
    ENDTRY.

    DATA(lo_pop) = z2ui5_cl_pop_messages=>factory( lx ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_not_initial( lo_pop->mt_msg ).

  ENDMETHOD.

  METHOD test_factory_msg_type.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA(lt_msg) = VALUE bapirettab(
      ( type = `E` message = `Error` )
      ( type = `W` message = `Warning` )
      ( type = `S` message = `Success` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_messages=>factory( lt_msg ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lo_pop->mt_msg ) ).
    cl_abap_unit_assert=>assert_not_initial( lo_pop->mt_msg[ 1 ]-type ).

  ENDMETHOD.

  METHOD test_factory_empty_input.

    DATA(lx) = NEW z2ui5_cx_util_error( val = `test` ).
    DATA(lo_pop) = z2ui5_cl_pop_messages=>factory( lx ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_not_initial( lo_pop->mt_msg ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_roundtrip DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_action TYPE REF TO z2ui5_cl_core_action.
    DATA mi_client TYPE REF TO z2ui5_if_client.

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

  METHOD client_create.

    mo_action = NEW #( NEW z2ui5_cl_core_handler( `` ) ).
    mo_action->mo_app->mo_app = io_app.
    mi_client = NEW z2ui5_cl_core_client( mo_action ).

  ENDMETHOD.

  METHOD roundtrip_event.

    client_create( io_app ).
    io_app->check_initialized = abap_true.
    mo_action->ms_actual-event = iv_event.
    io_app->main( mi_client ).

  ENDMETHOD.

  METHOD test_factory_maps_messages.

    DATA(lo_pop) = z2ui5_cl_pop_messages=>factory(
        VALUE string_table( ( `first message` )
                            ( `second message` ) ) ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_pop->mt_msg ) ).
    cl_abap_unit_assert=>assert_equals( exp = `first message`
                                        act = lo_pop->mt_msg[ 1 ]-title ).

  ENDMETHOD.

  METHOD test_init_displays_popup.

    DATA(lo_pop) = z2ui5_cl_pop_messages=>factory( i_messages = VALUE string_table( ( `first message` ) )
                                                   i_title    = `MSG Title` ).
    client_create( lo_pop ).

    lo_pop->z2ui5_if_app~main( mi_client ).

    DATA(lv_xml) = mo_action->ms_next-s_set-s_popup-xml.
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `MSG Title` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `MessageView` ) ).

  ENDMETHOD.

  METHOD test_continue_closes.

    DATA(lo_pop) = z2ui5_cl_pop_messages=>factory( VALUE string_table( ( `msg` ) ) ).
    roundtrip_event( io_app   = lo_pop
                     iv_event = `BUTTON_CONTINUE` ).

    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_destroy ).
    cl_abap_unit_assert=>assert_bound( mo_action->ms_next-o_app_leave ).

  ENDMETHOD.

ENDCLASS.
