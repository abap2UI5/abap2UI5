CLASS z2ui5_cl_fw_client DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES z2ui5_if_client.

    DATA mo_app TYPE REF TO z2ui5_cl_fw_app.

    METHODS constructor
      IMPORTING
        flow TYPE REF TO z2ui5_cl_fw_app.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_fw_client IMPLEMENTATION.


  METHOD constructor.

    mo_app = flow.

  ENDMETHOD.


  METHOD z2ui5_if_client~clear.

    CASE val.
      WHEN z2ui5_if_client=>cs_clear-view.
        CLEAR mo_app->ms_next-s_set-s_view.
    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_if_client~get.

    result = VALUE #(
      event                  = mo_app->ms_actual-event
      check_launchpad_active = mo_app->mo_http_post->ms_request-s_control-check_launchpad
      t_event_arg            = mo_app->ms_actual-t_event_arg
      s_draft                = CORRESPONDING #( mo_app->ms_draft )
      check_on_navigated     = mo_app->ms_actual-check_on_navigated
      s_config               = VALUE #(
        origin = mo_app->mo_http_post->ms_request-s_frontend-origin
        pathname = mo_app->mo_http_post->ms_request-s_frontend-pathname
        search = mo_app->mo_http_post->ms_request-s_frontend-search
        t_startup_params = mo_app->mo_http_post->ms_request-s_frontend-t_startup_params
        )
    ).

  ENDMETHOD.


  METHOD z2ui5_if_client~get_app.
    IF id IS NOT INITIAL.
      result = CAST #( z2ui5_cl_fw_hlp_db=>load_app( id )-app ).
    ELSE.
      result = CAST #( mo_app->mo_model->mo_app ).
    ENDIF.
  ENDMETHOD.


  METHOD z2ui5_if_client~message_box_display.

    mo_app->ms_next-s_set-s_msg_box = VALUE #( text = text type = type ).

  ENDMETHOD.


  METHOD z2ui5_if_client~message_toast_display.

    mo_app->ms_next-s_set-s_msg_toast = VALUE #( text = text ).

  ENDMETHOD.


  METHOD z2ui5_if_client~nav_app_call.
    mo_app->ms_next-o_app_call = app.
    IF app->id_draft IS INITIAL.
      app->id_app = z2ui5_cl_util_func=>uuid_get_c32( ).
    ENDIF.
    result = app->id_app.
  ENDMETHOD.


  METHOD z2ui5_if_client~nav_app_leave.
    mo_app->ms_next-o_app_leave = app.
    IF app->id_draft IS INITIAL.
      app->id_app = z2ui5_cl_util_func=>uuid_get_c32( ).
    ENDIF.
    result = app->id_app.
  ENDMETHOD.


  METHOD z2ui5_if_client~nest2_view_destroy.

    mo_app->ms_next-s_set-s_view_nest2-check_update_model = abap_true.

  ENDMETHOD.


  METHOD z2ui5_if_client~nest2_view_display.

    mo_app->ms_next-s_set-s_view_nest2-xml = val.
    mo_app->ms_next-s_set-s_view_nest2-id = id.
    mo_app->ms_next-s_set-s_view_nest2-method_destroy = method_destroy.
    mo_app->ms_next-s_set-s_view_nest2-method_insert = method_insert.

  ENDMETHOD.


  METHOD z2ui5_if_client~nest2_view_model_update.

    mo_app->ms_next-s_set-s_view_nest2-check_update_model = abap_true.

  ENDMETHOD.


  METHOD z2ui5_if_client~nest_view_destroy.

    mo_app->ms_next-s_set-s_view_nest-check_update_model = abap_true.

  ENDMETHOD.


  METHOD z2ui5_if_client~nest_view_display.

    mo_app->ms_next-s_set-s_view_nest-xml = val.
    mo_app->ms_next-s_set-s_view_nest-id = id.
    mo_app->ms_next-s_set-s_view_nest-method_destroy = method_destroy.
    mo_app->ms_next-s_set-s_view_nest-method_insert = method_insert.

  ENDMETHOD.


  METHOD z2ui5_if_client~nest_view_model_update.

    mo_app->ms_next-s_set-s_view_nest-check_update_model = abap_true.

  ENDMETHOD.


  METHOD z2ui5_if_client~popover_destroy.

    mo_app->ms_next-s_set-s_popover-check_destroy = abap_true.

  ENDMETHOD.


  METHOD z2ui5_if_client~popover_display.

    mo_app->ms_next-s_set-s_popover-check_destroy = abap_false.
    mo_app->ms_next-s_set-s_popover-xml = xml.
    mo_app->ms_next-s_set-s_popover-open_by_id = by_id.

  ENDMETHOD.


  METHOD z2ui5_if_client~popover_model_update.

    mo_app->ms_next-s_set-s_popover-check_update_model = abap_true.

  ENDMETHOD.


  METHOD z2ui5_if_client~popup_destroy.

    mo_app->ms_next-s_set-s_popup = VALUE #( check_destroy = abap_true ).

  ENDMETHOD.


  METHOD z2ui5_if_client~popup_display.

    mo_app->ms_next-s_set-s_popup-check_destroy = abap_false.
    mo_app->ms_next-s_set-s_popup-xml = val.

  ENDMETHOD.


  METHOD z2ui5_if_client~popup_model_update.

    mo_app->ms_next-s_set-s_popup-check_update_model = abap_true.

  ENDMETHOD.


  METHOD z2ui5_if_client~view_destroy.

    mo_app->ms_next-s_set-s_view-check_destroy = abap_true.

  ENDMETHOD.


  METHOD z2ui5_if_client~view_display.

    mo_app->ms_next-s_set-s_view-xml = val.

  ENDMETHOD.


  METHOD z2ui5_if_client~view_model_update.

    mo_app->ms_next-s_set-s_view-check_update_model = abap_true.

  ENDMETHOD.


  METHOD z2ui5_if_client~_bind.

    IF tab IS NOT INITIAL.

      DATA(lv_name) = z2ui5_if_client~_bind( val  = tab path = abap_true ).

      result = z2ui5_cl_util_func=>bind_tab_cell(
            iv_name     = lv_name
            i_tab_index = tab_index
            i_tab       = tab
            i_val       = val ).

      RETURN.
    ENDIF.

    DATA(lo_bind) = NEW z2ui5_cl_fw_hlp_binder( mo_app->mo_model ).
    result = lo_bind->bind2(
      val    = val
      type   = z2ui5_if_fw_types=>cs_bind_type-one_way
      config = VALUE #(
         custom_filter = custom_filter
         custom_mapper = custom_mapper
     ) ).

  ENDMETHOD.


  METHOD z2ui5_if_client~_bind_clear.

*    cntrl->ms_draft-t_attri[ name = val ]-check_dissolved = abap_false.
*
*    LOOP AT cntrl->ms_draft-t_attri REFERENCE INTO DATA(lr_bind2).
*      IF lr_bind2->name CS val && `-`.
*        DELETE cntrl->ms_draft-t_attri.
*      ENDIF.
*    ENDLOOP.

  ENDMETHOD.


  METHOD z2ui5_if_client~_bind_edit.

    IF tab IS NOT INITIAL.

      DATA(lv_name) = z2ui5_if_client~_bind( val  = tab path = abap_true ).

      result = z2ui5_cl_util_func=>bind_tab_cell(
            iv_name     = lv_name
            i_tab_index = tab_index
            i_tab       = tab
            i_val       = val ).

      RETURN.
    ENDIF.

    DATA(lo_bind) = NEW z2ui5_cl_fw_hlp_binder( mo_app->mo_model ).
    result = lo_bind->bind2(
      val    = val
      type   = z2ui5_if_fw_types=>cs_bind_type-two_way
      config = VALUE #(
         custom_filter = custom_filter
         custom_filter_back = custom_filter_back
         custom_mapper = custom_mapper
         custom_mapper_back = custom_mapper_back
     ) ).

  ENDMETHOD.


  METHOD z2ui5_if_client~_bind_local.

*    DATA(lo_binder) = z2ui5_cl_fw_binding=>factory(
**                app2 = mo_flow
**                        app         = mo_flow->ms_db-app
**                        attri       = mo_flow->ms_db-t_attri
*                          data        = val
*                          s_attri = VALUE #(
*                        type        = z2ui5_if_fw_types=>cs_bind_type-one_time
*                        custom_mapper  = custom_mapper
*                        custom_filter   = custom_filter
*                       ) ).
*
*    result = lo_binder->main( ).
*    mo_flow->ms_db-t_attri = mo_flow->mo_dissolver->mt_attri.
**    mo_app->ms_db-check_attri = abap_false.
*
*    IF path = abap_false.
*      result = `{` && result && `}`.
*    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_if_client~_event.

    result = `onEvent(  { 'EVENT' : '` && val && `', 'METHOD' : 'UPDATE' , 'CHECK_VIEW_DESTROY' : ` && z2ui5_cl_util_func=>boolean_abap_2_json( check_view_destroy ) && ` }`.
    result = result && z2ui5_cl_util_func=>ui5_set_arg_string( t_arg ).

  ENDMETHOD.


  METHOD z2ui5_if_client~_event_client.

    result = `onEventFrontend( { 'EVENT' : '` && val && `' }` && z2ui5_cl_util_func=>ui5_set_arg_string( t_arg ).

  ENDMETHOD.
ENDCLASS.
