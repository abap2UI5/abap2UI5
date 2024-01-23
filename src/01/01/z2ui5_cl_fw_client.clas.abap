CLASS z2ui5_cl_fw_client DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES z2ui5_if_client.

    DATA mo_handler TYPE REF TO z2ui5_cl_fw_controller.

    METHODS constructor
      IMPORTING
        handler TYPE REF TO z2ui5_cl_fw_controller.

  PROTECTED SECTION.

    METHODS set_arg_string
      IMPORTING
        val           TYPE string_table
      RETURNING
        VALUE(result) TYPE string.
    METHODS bind_tab_cell
      IMPORTING
        iv_name         TYPE string
        i_tab_index     TYPE i
        i_tab           TYPE STANDARD TABLE
        i_val           TYPE data
      RETURNING
        VALUE(r_result) TYPE string.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_fw_client IMPLEMENTATION.


  METHOD bind_tab_cell.

    FIELD-SYMBOLS <ele>  TYPE any.
    FIELD-SYMBOLS <row>  TYPE any.
    DATA lr_ref_in TYPE REF TO data.
    DATA lr_ref TYPE REF TO data.

    ASSIGN i_tab[ i_tab_index ] TO <row>.
    DATA(lt_attri) = z2ui5_cl_util_func=>rtti_get_t_comp_by_data( <row> ).

    LOOP AT lt_attri ASSIGNING FIELD-SYMBOL(<comp>).

      ASSIGN COMPONENT <comp>-name OF STRUCTURE <row> TO <ele>.
      lr_ref_in = REF #( <ele> ).

      lr_ref = REF #( i_val ).
      IF lr_ref = lr_ref_in.
        r_result = `{` && iv_name && '/' && shift_right( CONV string( i_tab_index - 1 ) ) && '/' && <comp>-name && `}`.
        RETURN.
      ENDIF.

    ENDLOOP.

    RAISE EXCEPTION TYPE z2ui5_cx_util_error
      EXPORTING
        val = `BINDING_ERROR - No class attribute for binding found - Please check if the binded values are public attributes of your class`.

  ENDMETHOD.


  METHOD constructor.

    mo_handler = handler.

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


  METHOD z2ui5_if_client~get.

    result = VALUE #(
      event                  = mo_handler->ms_actual-event
      check_launchpad_active = mo_handler->ms_actual-check_launchpad_active
      t_event_arg            = mo_handler->ms_actual-t_event_arg
      s_draft                = CORRESPONDING #( mo_handler->ms_db )
      check_on_navigated     = mo_handler->ms_actual-check_on_navigated
      s_config               = z2ui5_cl_fw_controller=>ss_config ).

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
    IF app->id_draft IS INITIAL.
      app->id_app = z2ui5_cl_util_func=>func_get_uuid_32( ).
    ENDIF.
    result = app->id_app.
  ENDMETHOD.


  METHOD z2ui5_if_client~nav_app_leave.
    mo_handler->ms_next-o_app_leave = app.
    IF app->id_draft IS INITIAL.
      app->id_app = z2ui5_cl_util_func=>func_get_uuid_32( ).
    ENDIF.
    result = app->id_app.
  ENDMETHOD.


  METHOD z2ui5_if_client~nest2_view_destroy.

    mo_handler->ms_next-s_set-s_view_nest2-check_update_model = abap_true.

  ENDMETHOD.


  METHOD z2ui5_if_client~nest2_view_display.

    mo_handler->ms_next-s_set-s_view_nest2-xml = val.
    mo_handler->ms_next-s_set-s_view_nest2-id = id.
    mo_handler->ms_next-s_set-s_view_nest2-method_destroy = method_destroy.
    mo_handler->ms_next-s_set-s_view_nest2-method_insert = method_insert.

  ENDMETHOD.


  METHOD z2ui5_if_client~nest2_view_model_update.

    mo_handler->ms_next-s_set-s_view_nest2-check_update_model = abap_true.

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

    IF tab IS NOT INITIAL.

      DATA(lv_name) = z2ui5_if_client~_bind( val = tab path = abap_true ).
      result = bind_tab_cell(
            iv_name     = lv_name
            i_tab_index = tab_index
            i_tab       = tab
            i_val       = val ).

      RETURN.
    ENDIF.

    DATA(lo_binder) = z2ui5_cl_fw_binding=>factory(
                        app   = mo_handler->ms_db-app
                        attri = mo_handler->ms_db-t_attri
                        check_attri = mo_handler->ms_db-check_attri
                        type  = z2ui5_cl_fw_binding=>cs_bind_type-one_way
                        data  = val
                        pretty_name = pretty_name
                        compress = compress
                      ).

    result = lo_binder->main( ).
    mo_handler->ms_db-t_attri = lo_binder->mt_attri.
    mo_handler->ms_db-check_attri = lo_binder->mv_check_attri.

    IF path = abap_false.
      result = `{` && result && `}`.
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_if_client~_bind_clear.

    mo_handler->ms_db-t_attri[ name = val ]-check_dissolved = abap_false.

    LOOP AT mo_handler->ms_db-t_attri REFERENCE INTO DATA(lr_bind2).
      IF lr_bind2->name CS val && `-`.
        DELETE mo_handler->ms_db-t_attri.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD z2ui5_if_client~clear.

    CASE val.
      WHEN z2ui5_if_client~cs_clear-view.
        CLEAR mo_handler->ms_next-s_set-s_view.
    ENDCASE.

  ENDMETHOD.

  METHOD z2ui5_if_client~_bind_edit.

    IF tab IS NOT INITIAL.

      DATA(lv_name) = z2ui5_if_client~_bind_edit( val = tab path = abap_true pretty_name = pretty_name ).
      result = bind_tab_cell(
            iv_name     = lv_name
            i_tab_index = tab_index
            i_tab       = tab
            i_val       = val ).

      RETURN.
    ENDIF.


    DATA(lo_binder) = z2ui5_cl_fw_binding=>factory(
                        app   = mo_handler->ms_db-app
                        attri = mo_handler->ms_db-t_attri
                        check_attri = mo_handler->ms_db-check_attri
                        type  = z2ui5_cl_fw_binding=>cs_bind_type-two_way
                        data  = val
                        view  = view
                        pretty_name = pretty_name
                        compress = compress
                      ).

    result = lo_binder->main( ).
    mo_handler->ms_db-t_attri = lo_binder->mt_attri.
    mo_handler->ms_db-check_attri = lo_binder->mv_check_attri.

    IF path = abap_false.
      result = `{` && result && `}`.
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_if_client~_bind_local.

    DATA(lo_binder) = z2ui5_cl_fw_binding=>factory(
                        app   = mo_handler->ms_db-app
                        attri = mo_handler->ms_db-t_attri
                        check_attri = mo_handler->ms_db-check_attri
                        type  = z2ui5_cl_fw_binding=>cs_bind_type-one_time
                        data  = val
                        pretty_name = pretty_name
                        compress = compress
                      ).

    result = lo_binder->main( ).
    mo_handler->ms_db-t_attri = lo_binder->mt_attri.
    mo_handler->ms_db-check_attri = lo_binder->mv_check_attri.

    IF path = abap_false.
      result = `{` && result && `}`.
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_if_client~_event.

    result = `onEvent( { 'EVENT' : '` && val && `', 'METHOD' : 'UPDATE' , 'CHECK_VIEW_DESTROY' : ` && z2ui5_cl_util_func=>boolean_abap_2_json( check_view_destroy ) && ` }`.
    result = result && set_arg_string( t_arg ).

  ENDMETHOD.


  METHOD z2ui5_if_client~_event_client.

    result = `onEventFrontend( { 'EVENT' : '` && val && `' }` && set_arg_string( t_arg ).

  ENDMETHOD.
ENDCLASS.
