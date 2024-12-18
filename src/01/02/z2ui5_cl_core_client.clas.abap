CLASS z2ui5_cl_core_client DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_client.

    DATA mo_action TYPE REF TO z2ui5_cl_core_action.

    METHODS constructor
      IMPORTING
        action TYPE REF TO z2ui5_cl_core_action.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_core_client IMPLEMENTATION.

  METHOD constructor.

    mo_action = action.

  ENDMETHOD.

  METHOD z2ui5_if_client~follow_up_action.

*    mo_action->ms_next-s_set-s_follow_up_action-custom_js = val.
    INSERT val INTO TABLE mo_action->ms_next-s_set-s_follow_up_action-custom_js.

  ENDMETHOD.

  METHOD z2ui5_if_client~get.

    result = VALUE #( event                  = mo_action->ms_actual-event
                      check_launchpad_active = mo_action->mo_http_post->ms_request-s_control-check_launchpad
                      t_event_arg            = mo_action->ms_actual-t_event_arg
                      s_draft                = CORRESPONDING #( mo_action->mo_app->ms_draft )
                      check_on_navigated     = mo_action->ms_actual-check_on_navigated
                      s_config               = CORRESPONDING #( mo_action->mo_http_post->ms_request-s_front )
                      r_event_data           = mo_action->ms_actual-r_data
      ).

    TRY.
        DATA(lo_params) = mo_action->mo_http_post->ms_request-s_front-o_comp_data->slice( `/startupParameters/` ).
        IF lo_params IS NOT BOUND.
          RETURN.
        ENDIF.
        LOOP AT lo_params->mt_json_tree
             REFERENCE INTO DATA(lr_comp)
             WHERE name = `1`.

          INSERT VALUE #( n = shift_left( val = shift_right( val = lr_comp->path
                                                             sub = `/` )
                                          sub = `/` )
                          v = lr_comp->value ) INTO TABLE result-t_comp_params.
        ENDLOOP.
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

  METHOD z2ui5_if_client~get_event_arg.

    TRY.
        result = mo_action->ms_actual-t_event_arg[ v ].
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

  METHOD z2ui5_if_client~get_app.

    IF id IS NOT INITIAL.
      DATA(lo_app) = z2ui5_cl_core_app=>db_load( id ).
      result = CAST #( lo_app->mo_app ).
    ELSE.
      result = CAST #( mo_action->mo_app->mo_app ).
    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_client~message_box_display.

    IF z2ui5_cl_util=>rtti_check_clike( text ) = abap_false.
      DATA(lt_msg) = z2ui5_cl_util=>msg_get( text ).
      IF lines( lt_msg ) = 1.
        DATA(lv_text) = lt_msg[ 1 ]-text.

        DATA(lv_type) = z2ui5_cl_util=>ui5_get_msg_type( lt_msg[ 1 ]-type ).
        lv_type = to_lower( lv_type ).
        DATA(lv_title) = SWITCH #( lt_msg[ 1 ]-type
                                   WHEN 'E' THEN `Error`
                                   WHEN 'S' THEN `Success`
                                   WHEN `W` THEN `Warning`
                                   ELSE          `Information` ).

      ELSEIF lines( lt_msg ) > 1.
        lv_text = | { lines( lt_msg ) } Messages found: |.
        DATA(lv_details) = `<ul>`.
        LOOP AT lt_msg REFERENCE INTO DATA(lr_msg).
          lv_details = |{ lv_details }<li>{ lr_msg->text }</li>|.
        ENDLOOP.
        lv_details = |{ lv_details }</ul>|.
        IF title IS INITIAL.
          lv_title = SWITCH #( lt_msg[ 1 ]-type
                               WHEN 'E' THEN `Error`
                               WHEN 'S' THEN `Success`
                               WHEN `W` THEN `Warning`
                               ELSE          `Information` ).
        ENDIF.
        lv_type = z2ui5_cl_util=>ui5_get_msg_type( lt_msg[ 1 ]-type ).
      ELSE.
        RETURN.
      ENDIF.
    ELSE.
      lv_text = text.
      lv_type = type.
      lv_title = title.
      lv_details = details.

      IF lv_type = 'information'.
        lv_type = 'show'.
        IF lv_title IS INITIAL.
          lv_title = 'Information'.
        ENDIF.
      ENDIF.
    ENDIF.

    IF lv_type = ''.
      lv_type = 'show'.
    ENDIF.

    mo_action->ms_next-s_set-s_msg_box = VALUE #( text              = lv_text
                                                  type              = lv_type
                                                  title             = lv_title
                                                  styleclass        = styleclass
                                                  onclose           = onclose
                                                  actions           = actions
                                                  emphasizedaction  = emphasizedaction
                                                  initialfocus      = initialfocus
                                                  textdirection     = textdirection
                                                  icon              = icon
                                                  details           = lv_details
                                                  closeonnavigation = closeonnavigation
                                               ).

  ENDMETHOD.

  METHOD z2ui5_if_client~message_toast_display.

    mo_action->ms_next-s_set-s_msg_toast = VALUE #( text                     = text
                                                    duration                 = duration
                                                    width                    = width
                                                    my                       = my
                                                    at                       = at
                                                    of                       = of
                                                    offset                   = offset
                                                    collision                = collision
                                                    onclose                  = onclose
                                                    autoclose                = autoclose
                                                    animationtimingfunction  = animationtimingfunction
                                                    animationduration        = animationduration
                                                    closeonbrowsernavigation = closeonbrowsernavigation
                                                    class                    = class
                                                  ).

  ENDMETHOD.

  METHOD z2ui5_if_client~nav_app_call.

    IF app IS NOT BOUND.
      z2ui5_cl_util=>x_raise( `NAV_APP_LEAVE_TO_INITIAL_APP_ERROR` ).
    ENDIF.

    mo_action->ms_next-o_app_call = app.

    IF app->id_app IS INITIAL.
      app->id_app = z2ui5_cl_util=>uuid_get_c32( ).
    ENDIF.
    result = app->id_app.
  ENDMETHOD.

  METHOD z2ui5_if_client~nav_app_leave.

    IF app IS NOT SUPPLIED.
      app = z2ui5_if_client~get_app( z2ui5_if_client~get( )-s_draft-id_prev_app_stack ).
    ENDIF.

    IF app IS NOT BOUND.
      z2ui5_cl_util=>x_raise( `NAV_APP_LEAVE_TO_INITIAL_APP_ERROR` ).
    ENDIF.

    mo_action->ms_next-o_app_leave = app.

    IF app->id_app IS INITIAL.
      app->id_app = z2ui5_cl_util=>uuid_get_c32( ).
    ENDIF.
    result = app->id_app.

  ENDMETHOD.

  METHOD z2ui5_if_client~nest2_view_destroy.

    mo_action->ms_next-s_set-s_view_nest2-check_update_model = abap_true.

  ENDMETHOD.

  METHOD z2ui5_if_client~nest2_view_display.

    mo_action->ms_next-s_set-s_view_nest2-xml            = val.
    mo_action->ms_next-s_set-s_view_nest2-id             = id.
    mo_action->ms_next-s_set-s_view_nest2-method_destroy = method_destroy.
    mo_action->ms_next-s_set-s_view_nest2-method_insert  = method_insert.

  ENDMETHOD.

  METHOD z2ui5_if_client~nest2_view_model_update.

    mo_action->ms_next-s_set-s_view_nest2-check_update_model = abap_true.

  ENDMETHOD.

  METHOD z2ui5_if_client~nest_view_destroy.

    mo_action->ms_next-s_set-s_view_nest-check_update_model = abap_true.

  ENDMETHOD.

  METHOD z2ui5_if_client~nest_view_display.

    mo_action->ms_next-s_set-s_view_nest-xml            = val.
    mo_action->ms_next-s_set-s_view_nest-id             = id.
    mo_action->ms_next-s_set-s_view_nest-method_destroy = method_destroy.
    mo_action->ms_next-s_set-s_view_nest-method_insert  = method_insert.

  ENDMETHOD.

  METHOD z2ui5_if_client~nest_view_model_update.

    mo_action->ms_next-s_set-s_view_nest-check_update_model = abap_true.

  ENDMETHOD.

  METHOD z2ui5_if_client~popover_destroy.

    mo_action->ms_next-s_set-s_popover-check_destroy = abap_true.

  ENDMETHOD.

  METHOD z2ui5_if_client~popover_display.

    mo_action->ms_next-s_set-s_popover-check_destroy = abap_false.
    mo_action->ms_next-s_set-s_popover-xml           = xml.
    mo_action->ms_next-s_set-s_popover-open_by_id    = by_id.

  ENDMETHOD.

  METHOD z2ui5_if_client~popover_model_update.

    mo_action->ms_next-s_set-s_popover-check_update_model = abap_true.

  ENDMETHOD.

  METHOD z2ui5_if_client~popup_destroy.

    mo_action->ms_next-s_set-s_popup = VALUE #( check_destroy = abap_true ).

  ENDMETHOD.

  METHOD z2ui5_if_client~popup_display.

    mo_action->ms_next-s_set-s_popup-check_destroy = abap_false.
    mo_action->ms_next-s_set-s_popup-xml           = val.

  ENDMETHOD.

  METHOD z2ui5_if_client~popup_model_update.

    mo_action->ms_next-s_set-s_popup-check_update_model = abap_true.

  ENDMETHOD.

  METHOD z2ui5_if_client~view_destroy.

    mo_action->ms_next-s_set-s_view-check_destroy = abap_true.

  ENDMETHOD.

  METHOD z2ui5_if_client~view_display.

    mo_action->ms_next-s_set-s_view-xml = val.
    mo_action->ms_next-s_set-s_view-switchDefaultModelAnnoURI = switch_default_model_anno_uri.
    mo_action->ms_next-s_set-s_view-switch_default_model_path = switch_default_model_path.

  ENDMETHOD.

  METHOD z2ui5_if_client~view_model_update.

    mo_action->ms_next-s_set-s_view-check_update_model = abap_true.

  ENDMETHOD.

  METHOD z2ui5_if_client~_bind.

    DATA(lo_bind) = NEW z2ui5_cl_core_srv_bind( mo_action->mo_app ).
    result = lo_bind->main( val    = z2ui5_cl_util=>conv_get_as_data_ref( val )
                            type   = z2ui5_if_core_types=>cs_bind_type-one_way
                            config = VALUE #( path_only     = path
                                              custom_filter = custom_filter
                                              custom_mapper = custom_mapper
                                              tab           = z2ui5_cl_util=>conv_get_as_data_ref( tab )
                                              tab_index     = tab_index
                                              switch_default_model = switch_Default_Model ) ).


  ENDMETHOD.

  METHOD z2ui5_if_client~_bind_edit.

    DATA(lo_bind) = NEW z2ui5_cl_core_srv_bind( mo_action->mo_app ).
    result = lo_bind->main( val    = z2ui5_cl_util=>conv_get_as_data_ref( val )
                            type   = z2ui5_if_core_types=>cs_bind_type-two_way
                            config = VALUE #( path_only          = path
                                              custom_filter      = custom_filter
                                              custom_filter_back = custom_filter_back
                                              custom_mapper      = custom_mapper
                                              custom_mapper_back = custom_mapper_back
                                              tab                = z2ui5_cl_util=>conv_get_as_data_ref( tab )
                                              tab_index          = tab_index
                                              switch_default_model = switch_Default_Model ) ).

  ENDMETHOD.

  METHOD z2ui5_if_client~_bind_local.

    DATA(lo_bind) = NEW z2ui5_cl_core_srv_bind( mo_action->mo_app ).
    result = lo_bind->main_local( val    = val
                                  config = VALUE #( path_only     = path
                                                    custom_mapper = custom_mapper
                                                    custom_filter = custom_filter
                                                    switch_default_model = switch_Default_Model ) ).

  ENDMETHOD.

  METHOD z2ui5_if_client~_event.

    DATA(lo_ui5) = NEW z2ui5_cl_core_srv_event( ).
    result = lo_ui5->get_event( val   = val
                                t_arg = t_arg
                                s_cnt = s_ctrl ).

    IF r_data IS NOT INITIAL.
      CREATE DATA mo_action->ms_next-r_data LIKE r_data.
      mo_action->ms_next-r_data = z2ui5_cl_util=>conv_copy_ref_data( r_data ).
    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_client~_event_client.

    DATA(lo_ui5) = NEW z2ui5_cl_core_srv_event( ).
    result = lo_ui5->get_event_client( val   = val
                                       t_arg = t_arg ).

  ENDMETHOD.

  METHOD z2ui5_if_client~set_nav_back.

    mo_action->ms_next-s_set-set_nav_back = val.

  ENDMETHOD.

  METHOD z2ui5_if_client~set_push_state.

    mo_action->ms_next-s_set-set_push_state = val.

  ENDMETHOD.


  METHOD z2ui5_if_client~set_app_state_active.

    mo_action->ms_next-s_set-set_app_state_active = val.

  ENDMETHOD.

  METHOD z2ui5_if_client~set_session_stateful.

    DATA(lv_check_sticky) = CAST z2ui5_if_app( mo_action->mo_app->mo_app )->check_sticky.
    IF lv_check_sticky = abap_true AND val = abap_true.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `STATEFUL_ALREADY_ACTIVATED_ERROR`.
    ENDIF.
    IF val = abap_true.
      mo_action->ms_next-s_set-s_stateful-active = 1.
      CAST z2ui5_if_app( mo_action->mo_app->mo_app )->check_sticky = abap_true.
    ELSE.
      mo_action->ms_next-s_set-s_stateful-active = 0.
      CAST z2ui5_if_app( mo_action->mo_app->mo_app )->check_sticky = abap_false.
    ENDIF.
    mo_action->ms_next-s_set-s_stateful-switched = abap_true.

  ENDMETHOD.

  METHOD z2ui5_if_client~check_app_prev_stack.

    DATA(ls_get) = z2ui5_if_client~get( ).
    result = xsdbool( ls_get-s_draft-id_prev_app_stack IS NOT INITIAL ).

  ENDMETHOD.

  METHOD z2ui5_if_client~check_on_init.

    result = xsdbool( CAST z2ui5_if_app(  mo_action->mo_app->mo_app )->check_initialized = abap_false ).

  ENDMETHOD.

  METHOD z2ui5_if_client~check_on_navigated.

    DATA(ls_get) = z2ui5_if_client~get( ).
    result = ls_get-check_on_navigated.

  ENDMETHOD.

  METHOD z2ui5_if_client~get_app_prev.

    DATA(ls_get) = z2ui5_if_client~get( ).
    result = z2ui5_if_client~get_app( ls_get-s_draft-id_prev_app ).

  ENDMETHOD.

ENDCLASS.
