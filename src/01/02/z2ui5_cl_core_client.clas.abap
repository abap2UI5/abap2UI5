CLASS z2ui5_cl_core_client DEFINITION PUBLIC FINAL.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_client.

    DATA mo_action TYPE REF TO z2ui5_cl_core_action.

    METHODS constructor
      IMPORTING
        action TYPE REF TO z2ui5_cl_core_action.

    DATA mo_srv_bind  TYPE REF TO z2ui5_cl_core_srv_bind.
    DATA mo_srv_event TYPE REF TO z2ui5_cl_core_srv_event.

    METHODS nav_app_set_id
      IMPORTING
        app           TYPE REF TO z2ui5_if_app
      RETURNING
        VALUE(result) TYPE string.

    METHODS get_if_app
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_app.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_core_client IMPLEMENTATION.

  METHOD constructor.

    mo_action = action.
    CREATE OBJECT mo_srv_bind EXPORTING APP = mo_action->mo_app.
    CREATE OBJECT mo_srv_event.

  ENDMETHOD.

  METHOD z2ui5_if_client~follow_up_action.

    INSERT val INTO TABLE mo_action->ms_next-s_set-s_follow_up_action-custom_js.

  ENDMETHOD.

  METHOD z2ui5_if_client~check_on_event.
      DATA temp1 TYPE xsdboolean.
      DATA temp2 TYPE xsdboolean.

    IF val IS NOT INITIAL.
      
      temp1 = boolc( z2ui5_if_client~get( )-event = val ).
      result = temp1.
    ELSE.
      
      temp2 = boolc( z2ui5_if_client~get( )-event <> `` ).
      result = temp2.
    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_client~get.
    DATA temp3 TYPE xsdboolean.
    DATA temp4 TYPE xsdboolean.
        DATA lo_comp LIKE mo_action->mo_http_post->ms_request-s_front-o_comp_data.
        DATA lo_params TYPE REF TO z2ui5_if_ajson.
        DATA temp1 LIKE LINE OF lo_params->mt_json_tree.
        DATA lr_comp LIKE REF TO temp1.
          DATA temp2 TYPE z2ui5_if_types=>ty_s_name_value.

    CLEAR result.
    result-event = mo_action->ms_actual-event.
    result-check_launchpad_active = mo_action->mo_http_post->ms_request-s_control-check_launchpad.
    result-t_event_arg = mo_action->ms_actual-t_event_arg.
    MOVE-CORRESPONDING mo_action->mo_app->ms_draft TO result-s_draft.
    result-check_on_navigated = mo_action->ms_actual-check_on_navigated.
    MOVE-CORRESPONDING mo_action->mo_http_post->ms_request-s_front TO result-s_config.
    result-r_event_data = mo_action->ms_actual-r_data.
    
    temp3 = boolc( mo_action->ms_next-o_app_call IS NOT INITIAL ).
    result-_s_nav-check_call = temp3.
    
    temp4 = boolc( mo_action->ms_next-o_app_leave IS NOT INITIAL ).
    result-_s_nav-check_leave = temp4.

    TRY.

        
        lo_comp = mo_action->mo_http_post->ms_request-s_front-o_comp_data.
        IF lo_comp IS NOT BOUND.
          RETURN.
        ENDIF.
        
        lo_params = lo_comp->slice( `/startupParameters/` ).

        IF lo_params IS NOT BOUND.
          RETURN.
        ENDIF.
        
        
        LOOP AT lo_params->mt_json_tree                 "#EC CI_SORTSEQ
             REFERENCE INTO lr_comp
             WHERE name = `1`.

          
          CLEAR temp2.
          temp2-n = shift_left( val = shift_right( val = lr_comp->path sub = `/` ) sub = `/` ).
          temp2-v = lr_comp->value.
          INSERT temp2 INTO TABLE result-t_comp_params.
        ENDLOOP.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD z2ui5_if_client~get_event_arg.
        DATA temp3 LIKE LINE OF mo_action->ms_actual-t_event_arg.
        DATA temp4 LIKE sy-tabix.

    TRY.
        
        
        temp4 = sy-tabix.
        READ TABLE mo_action->ms_actual-t_event_arg INDEX v INTO temp3.
        sy-tabix = temp4.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        result = temp3.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD z2ui5_if_client~get_app.
      DATA lo_app TYPE REF TO z2ui5_cl_core_app.
      DATA temp5 TYPE REF TO z2ui5_if_app.
      DATA temp6 TYPE REF TO z2ui5_if_app.

    IF id IS NOT INITIAL.
      
      lo_app = z2ui5_cl_core_app=>db_load( id ).
      
      temp5 ?= lo_app->mo_app.
      result = temp5.
    ELSE.
      
      temp6 ?= mo_action->mo_app->mo_app.
      result = temp6.
    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_client~message_box_display.

    DATA lv_text    TYPE string.
    DATA lv_type    TYPE string.
    DATA lv_title   TYPE string.
    DATA lv_details TYPE string.
      DATA ls_msg_box TYPE z2ui5_cl_util=>ty_s_msg_box.
      DATA temp7 TYPE string.

    IF z2ui5_cl_util=>rtti_check_clike( text ) = abap_false.
      
      ls_msg_box = z2ui5_cl_util=>ui5_msg_box_format( text ).
      IF ls_msg_box-skip = abap_true.
        RETURN.
      ENDIF.
      lv_text    = ls_msg_box-text.
      lv_type    = ls_msg_box-type.
      
      IF title IS NOT INITIAL.
        temp7 = title.
      ELSE.
        temp7 = ls_msg_box-title.
      ENDIF.
      lv_title   = temp7.
      lv_details = ls_msg_box-details.
    ELSE.
      lv_text = text.
      lv_type = type.
      lv_title = title.
      lv_details = details.

      IF lv_type = `information`.
        lv_type = `show`.
        IF lv_title IS INITIAL.
          lv_title = `Information`.
        ENDIF.
      ENDIF.
    ENDIF.

    IF lv_type = ``.
      lv_type = `show`.
    ENDIF.

    CLEAR mo_action->ms_next-s_set-s_msg_box.
    mo_action->ms_next-s_set-s_msg_box-text = lv_text.
    mo_action->ms_next-s_set-s_msg_box-type = lv_type.
    mo_action->ms_next-s_set-s_msg_box-title = lv_title.
    mo_action->ms_next-s_set-s_msg_box-styleclass = styleclass.
    mo_action->ms_next-s_set-s_msg_box-onclose = onclose.
    mo_action->ms_next-s_set-s_msg_box-actions = actions.
    mo_action->ms_next-s_set-s_msg_box-emphasizedaction = emphasizedaction.
    mo_action->ms_next-s_set-s_msg_box-initialfocus = initialfocus.
    mo_action->ms_next-s_set-s_msg_box-textdirection = textdirection.
    mo_action->ms_next-s_set-s_msg_box-icon = icon.
    mo_action->ms_next-s_set-s_msg_box-details = lv_details.
    mo_action->ms_next-s_set-s_msg_box-closeonnavigation = closeonnavigation.

  ENDMETHOD.

  METHOD z2ui5_if_client~message_toast_display.

    CLEAR mo_action->ms_next-s_set-s_msg_toast.
    mo_action->ms_next-s_set-s_msg_toast-text = text.
    mo_action->ms_next-s_set-s_msg_toast-duration = duration.
    mo_action->ms_next-s_set-s_msg_toast-width = width.
    mo_action->ms_next-s_set-s_msg_toast-my = my.
    mo_action->ms_next-s_set-s_msg_toast-at = at.
    mo_action->ms_next-s_set-s_msg_toast-of = of.
    mo_action->ms_next-s_set-s_msg_toast-offset = offset.
    mo_action->ms_next-s_set-s_msg_toast-collision = collision.
    mo_action->ms_next-s_set-s_msg_toast-onclose = onclose.
    mo_action->ms_next-s_set-s_msg_toast-autoclose = autoclose.
    mo_action->ms_next-s_set-s_msg_toast-animationtimingfunction = animationtimingfunction.
    mo_action->ms_next-s_set-s_msg_toast-animationduration = animationduration.
    mo_action->ms_next-s_set-s_msg_toast-closeonbrowsernavigation = closeonbrowsernavigation.
    mo_action->ms_next-s_set-s_msg_toast-class = class.

  ENDMETHOD.

  METHOD nav_app_set_id.
    DATA temp8 TYPE string.

    IF app IS NOT BOUND.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `NAV_APP_LEAVE_TO_INITIAL_APP_ERROR`.
    ENDIF.

    
    IF app->id_app IS INITIAL.
      temp8 = z2ui5_cl_util=>uuid_get_c32( ).
    ELSE.
      CLEAR temp8.
    ENDIF.
    app->id_app = temp8.
    result = app->id_app.

  ENDMETHOD.

  METHOD z2ui5_if_client~nav_app_call.

    mo_action->ms_next-o_app_call = app.
    result = nav_app_set_id( app ).

  ENDMETHOD.

  METHOD z2ui5_if_client~nav_app_leave.

    IF app IS NOT SUPPLIED.
      app = z2ui5_if_client~get_app( z2ui5_if_client~get( )-s_draft-id_prev_app_stack ).
    ENDIF.

    mo_action->ms_next-o_app_leave = app.
    result = nav_app_set_id( app ).

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

    CLEAR mo_action->ms_next-s_set-s_popup.
    mo_action->ms_next-s_set-s_popup-check_destroy = abap_true.

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
    mo_action->ms_next-s_set-s_view-switchdefaultmodelannouri = switch_default_model_anno_uri.
    mo_action->ms_next-s_set-s_view-switch_default_model_path = switch_default_model_path.

  ENDMETHOD.

  METHOD z2ui5_if_client~view_model_update.

    mo_action->ms_next-s_set-s_view-check_update_model = abap_true.

  ENDMETHOD.

  METHOD z2ui5_if_client~_bind.

    DATA temp9 TYPE z2ui5_if_core_types=>ty_s_bind_config.
    CLEAR temp9.
    temp9-path_only = path.
    temp9-custom_filter = custom_filter.
    temp9-custom_mapper = custom_mapper.
    temp9-tab = z2ui5_cl_util=>conv_get_as_data_ref( tab ).
    temp9-tab_index = tab_index.
    temp9-switch_default_model = switch_default_model.
    result = mo_srv_bind->main( val = z2ui5_cl_util=>conv_get_as_data_ref( val )
                            type    = z2ui5_if_core_types=>cs_bind_type-one_way
                            config  = temp9 ).

  ENDMETHOD.

  METHOD z2ui5_if_client~_bind_edit.

    DATA temp10 TYPE z2ui5_if_core_types=>ty_s_bind_config.
    CLEAR temp10.
    temp10-path_only = path.
    temp10-custom_filter = custom_filter.
    temp10-custom_filter_back = custom_filter_back.
    temp10-custom_mapper = custom_mapper.
    temp10-custom_mapper_back = custom_mapper_back.
    temp10-tab = z2ui5_cl_util=>conv_get_as_data_ref( tab ).
    temp10-tab_index = tab_index.
    temp10-switch_default_model = switch_default_model.
    result = mo_srv_bind->main( val = z2ui5_cl_util=>conv_get_as_data_ref( val )
                            type    = z2ui5_if_core_types=>cs_bind_type-two_way
                            config  = temp10 ).

  ENDMETHOD.

  METHOD z2ui5_if_client~_event.

    result = mo_srv_event->get_event( val = val
                                t_arg     = t_arg
                                s_cnt     = s_ctrl ).

    IF r_data IS NOT INITIAL.
      CREATE DATA mo_action->ms_next-r_data LIKE r_data.
      mo_action->ms_next-r_data = z2ui5_cl_util=>conv_copy_ref_data( r_data ).
    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_client~_event_client.

    result = mo_srv_event->get_event_client( val = val
                                       t_arg     = t_arg ).

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

    DATA li_app TYPE REF TO z2ui5_if_app.
    DATA temp11 TYPE z2ui5_if_core_types=>ty_s_http_res-s_stateful-active.
    DATA temp5 TYPE xsdboolean.
    li_app = get_if_app( ).
    IF li_app->check_sticky = val.
      RETURN.
    ENDIF.
    
    IF val = abap_true.
      temp11 = 1.
    ELSE.
      temp11 = 0.
    ENDIF.
    mo_action->ms_next-s_set-s_stateful-active = temp11.
    li_app->check_sticky = val.

    
    temp5 = boolc( mo_action->ms_next-s_set-s_stateful-switched = abap_false ).
    mo_action->ms_next-s_set-s_stateful-switched = temp5.

  ENDMETHOD.

  METHOD z2ui5_if_client~check_app_prev_stack.

    DATA temp6 TYPE xsdboolean.
    temp6 = boolc( mo_action->mo_app->ms_draft-id_prev_app_stack IS NOT INITIAL ).
    result = temp6.

  ENDMETHOD.

  METHOD z2ui5_if_client~check_on_init.

    DATA temp7 TYPE xsdboolean.
    temp7 = boolc( get_if_app( )->check_initialized = abap_false ).
    result = temp7.

  ENDMETHOD.

  METHOD z2ui5_if_client~check_on_navigated.

    result = mo_action->ms_actual-check_on_navigated.

  ENDMETHOD.

  METHOD z2ui5_if_client~get_app_prev.

    result = z2ui5_if_client~get_app( mo_action->mo_app->ms_draft-id_prev_app ).

  ENDMETHOD.

  METHOD z2ui5_if_client~_event_nav_app_leave.

    result = z2ui5_if_client~_event( z2ui5_if_core_types=>cs_event_nav_app_leave ).

  ENDMETHOD.

  METHOD get_if_app.

    DATA temp12 TYPE REF TO z2ui5_if_app.
    temp12 ?= mo_action->mo_app->mo_app.
    result = temp12.

  ENDMETHOD.

ENDCLASS.
