CLASS z2ui5_cl_fw_client DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES z2ui5_if_client.

    DATA mo_handler TYPE REF TO z2ui5_cl_fw_handler.

    METHODS constructor
      IMPORTING
        handler TYPE REF TO z2ui5_cl_fw_handler.
  PROTECTED SECTION.

    METHODS set_arg_string
      IMPORTING
        val           TYPE string_table
      RETURNING
        VALUE(result) TYPE string.

ENDCLASS.



CLASS Z2UI5_CL_FW_CLIENT IMPLEMENTATION.


  METHOD constructor.

    mo_handler = handler.

  ENDMETHOD.


  METHOD z2ui5_if_client~cursor_set.

    mo_handler->ms_next-s_set-s_cursor = VALUE #(
      id             = id
      cursorpos      = cursorpos
      selectionend   = selectionend
      selectionstart = selectionstart ).

  ENDMETHOD.


  METHOD z2ui5_if_client~get.

    result = VALUE #(
      event                  = mo_handler->ms_actual-event
      check_launchpad_active = mo_handler->ms_actual-check_launchpad_active
      t_event_arg            = mo_handler->ms_actual-t_event_arg
      t_scroll_pos           = mo_handler->ms_actual-t_scroll_pos
      t_message_manager      = mo_handler->ms_actual-t_message_manager
      s_draft                = CORRESPONDING #( mo_handler->ms_db )
      check_on_navigated     = mo_handler->ms_actual-check_on_navigated
      s_config               = z2ui5_cl_fw_handler=>ss_config ).

  ENDMETHOD.


  METHOD z2ui5_if_client~get_app.
    result = CAST #( z2ui5_cl_fw_db=>load_app( id )-app ).
  ENDMETHOD.


  METHOD z2ui5_if_client~message_box_display.

    mo_handler->ms_next-s_set-s_msg_box = VALUE #( text = text type = type ).

  ENDMETHOD.


  METHOD z2ui5_if_client~message_toast_display.

    mo_handler->ms_next-s_set-s_msg_toast = VALUE #( text = text ).

  ENDMETHOD.


  METHOD z2ui5_if_client~nav_app_call.
    mo_handler->ms_next-o_app_call = app.
  ENDMETHOD.


  METHOD z2ui5_if_client~nav_app_leave.
    mo_handler->ms_next-o_app_leave = app.
  ENDMETHOD.


  METHOD z2ui5_if_client~nest_view_destroy.

    mo_handler->ms_next-s_set-s_view_nest-check_update_model = abap_true.

  ENDMETHOD.


  METHOD z2ui5_if_client~nest_view_display.

    mo_handler->ms_next-s_set-s_view_nest-xml = val.
    mo_handler->ms_next-s_set-s_view_nest-id = id.
    mo_handler->ms_next-s_set-s_view_nest-method_destroy = method_destroy.
    mo_handler->ms_next-s_set-s_view_nest-method_insert = method_insert.

  ENDMETHOD.


  METHOD z2ui5_if_client~nest_view_model_update.

    mo_handler->ms_next-s_set-s_view_nest-check_update_model = abap_true.

  ENDMETHOD.


  METHOD z2ui5_if_client~popover_destroy.

    mo_handler->ms_next-s_set-s_popover-check_destroy = abap_true.

  ENDMETHOD.


  METHOD z2ui5_if_client~popover_display.

    mo_handler->ms_next-s_set-s_popover-check_destroy = abap_false.
    mo_handler->ms_next-s_set-s_popover-xml = xml.
    mo_handler->ms_next-s_set-s_popover-open_by_id = by_id.

  ENDMETHOD.


  METHOD z2ui5_if_client~popover_model_update.

    mo_handler->ms_next-s_set-s_popover-check_update_model = abap_true.

  ENDMETHOD.


  METHOD z2ui5_if_client~popup_destroy.

    mo_handler->ms_next-s_set-s_popup-check_destroy = abap_true.

  ENDMETHOD.


  METHOD z2ui5_if_client~popup_display.

    mo_handler->ms_next-s_set-s_popup-check_destroy = abap_false.
    mo_handler->ms_next-s_set-s_popup-xml = val.

  ENDMETHOD.


  METHOD z2ui5_if_client~popup_model_update.

    mo_handler->ms_next-s_set-s_popup-check_update_model = abap_true.

  ENDMETHOD.


  METHOD z2ui5_if_client~scroll_position_set.

    mo_handler->ms_next-s_set-t_scroll = val.

  ENDMETHOD.


  METHOD z2ui5_if_client~timer_set.

    mo_handler->ms_next-s_set-s_timer-interval_ms     = interval_ms.
    mo_handler->ms_next-s_set-s_timer-event_finished  = event_finished.

  ENDMETHOD.


  METHOD z2ui5_if_client~url_param_set.

    mo_handler->ms_next-s_set-search = val.
    mo_handler->ms_actual-s_config-search = val.

  ENDMETHOD.


  METHOD z2ui5_if_client~view_destroy.

    mo_handler->ms_next-s_set-s_view-check_destroy = abap_true.

  ENDMETHOD.


  METHOD z2ui5_if_client~view_display.

    mo_handler->ms_next-s_set-s_view-xml = val.

  ENDMETHOD.


  METHOD z2ui5_if_client~view_model_update.

    mo_handler->ms_next-s_set-s_view-check_update_model = abap_true.

  ENDMETHOD.


  METHOD z2ui5_if_client~_bind.

    result = mo_handler->_create_binding( value = val
                                          type  = z2ui5_cl_fw_handler=>cs_bind_type-one_way ).

    IF path = abap_false.
      result = `{` && result && `}`.
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_if_client~_bind_edit.

    result = mo_handler->_create_binding( value = val
                                          type  = z2ui5_cl_fw_handler=>cs_bind_type-two_way ).

    IF path = abap_false.
      result = `{` && result && `}`.
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_if_client~_event.

    result = `onEvent( { 'EVENT' : '` && val && `', 'METHOD' : 'UPDATE' , 'CHECK_VIEW_DESTROY' : ` && z2ui5_cl_fw_utility=>get_json_boolean( check_view_destroy ) && ` }`.
    result = result && set_arg_string( t_arg ).
    
  ENDMETHOD.


  METHOD z2ui5_if_client~_event_client.

    result = `onEventFrontend( { 'EVENT' : '` && val && `' }` && set_arg_string( t_arg ).

  ENDMETHOD.

  METHOD set_arg_string.

    IF val IS NOT INITIAL.

      LOOP AT val REFERENCE INTO DATA(lr_arg).
        DATA(lv_new) = lr_arg->*.
        IF lv_new IS INITIAL.
          CONTINUE.
        ENDIF.
        IF lv_new(1) <> `$` AND lv_new(1) <> `{`.
          lv_new = `"` && lv_new && `"`.
        ENDIF.
        result = result && `, ` && lv_new.
      ENDLOOP.

    ENDIF.

    result = result && `)`.

  ENDMETHOD.

ENDCLASS.
