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

    TRY.
        
        lo_params = mo_action->mo_http_post->ms_request-s_front-o_comp_data->slice( `/startupParameters/` ).
        IF lo_params IS NOT BOUND.
          RETURN.
        ENDIF.
        
        
        LOOP AT lo_params->mt_json_tree
             REFERENCE INTO lr_comp
             WHERE name = `1`.

          
          CLEAR temp2.
          temp2-n = shift_left( val = shift_right( val = lr_comp->path sub = `/` ) sub = `/` ).
          temp2-v = lr_comp->value.
          INSERT temp2 INTO TABLE result-t_comp_params.
        ENDLOOP.
      CATCH cx_root.
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
      CATCH cx_root.
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
      DATA lt_msg TYPE z2ui5_cl_util=>ty_t_msg.
        DATA lv_text TYPE z2ui5_cl_util=>ty_s_msg-text.
        DATA temp1 LIKE LINE OF lt_msg.
        DATA temp2 LIKE sy-tabix.
        DATA lv_type TYPE string.
        DATA temp3 LIKE LINE OF lt_msg.
        DATA temp4 LIKE sy-tabix.
        DATA temp7 TYPE string.
        DATA temp5 LIKE LINE OF lt_msg.
        DATA temp6 LIKE sy-tabix.
        DATA lv_title LIKE temp7.
        DATA lv_details TYPE string.
        DATA temp8 LIKE LINE OF lt_msg.
        DATA lr_msg LIKE REF TO temp8.
          DATA temp9 TYPE string.
          DATA temp12 LIKE LINE OF lt_msg.
          DATA temp13 LIKE sy-tabix.
        DATA temp10 LIKE LINE OF lt_msg.
        DATA temp11 LIKE sy-tabix.

    IF z2ui5_cl_util=>rtti_check_clike( text ) = abap_false.
      
      lt_msg = z2ui5_cl_util=>msg_get_t( text ).
      IF lines( lt_msg ) = 1.
        
        
        
        temp2 = sy-tabix.
        READ TABLE lt_msg INDEX 1 INTO temp1.
        sy-tabix = temp2.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        lv_text = temp1-text.

        
        
        
        temp4 = sy-tabix.
        READ TABLE lt_msg INDEX 1 INTO temp3.
        sy-tabix = temp4.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        lv_type = z2ui5_cl_util=>ui5_get_msg_type( temp3-type ).
        lv_type = to_lower( lv_type ).
        
        
        
        temp6 = sy-tabix.
        READ TABLE lt_msg INDEX 1 INTO temp5.
        sy-tabix = temp6.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        CASE temp5-type.
          WHEN 'E'.
            temp7 = `Error`.
          WHEN 'S'.
            temp7 = `Success`.
          WHEN `W`.
            temp7 = `Warning`.
          WHEN OTHERS.
            temp7 = `Information`.
        ENDCASE.
        
        lv_title = temp7.

      ELSEIF lines( lt_msg ) > 1.
        lv_text = | { lines( lt_msg ) } Messages found: |.
        
        lv_details = `<ul>`.
        
        
        LOOP AT lt_msg REFERENCE INTO lr_msg.
          lv_details = |{ lv_details }<li>{ lr_msg->text }</li>|.
        ENDLOOP.
        lv_details = |{ lv_details }</ul>|.
        IF title IS INITIAL.
          
          
          
          temp13 = sy-tabix.
          READ TABLE lt_msg INDEX 1 INTO temp12.
          sy-tabix = temp13.
          IF sy-subrc <> 0.
            ASSERT 1 = 0.
          ENDIF.
          CASE temp12-type.
            WHEN 'E'.
              temp9 = `Error`.
            WHEN 'S'.
              temp9 = `Success`.
            WHEN `W`.
              temp9 = `Warning`.
            WHEN OTHERS.
              temp9 = `Information`.
          ENDCASE.
          lv_title = temp9.
        ENDIF.
        
        
        temp11 = sy-tabix.
        READ TABLE lt_msg INDEX 1 INTO temp10.
        sy-tabix = temp11.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        lv_type = z2ui5_cl_util=>ui5_get_msg_type( temp10-type ).
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

  METHOD z2ui5_if_client~nav_app_call.

    IF app IS NOT BOUND.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `NAV_APP_LEAVE_TO_INITIAL_APP_ERROR`.
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
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `NAV_APP_LEAVE_TO_INITIAL_APP_ERROR`.
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

    DATA lo_bind TYPE REF TO z2ui5_cl_core_srv_bind.
    DATA temp12 TYPE z2ui5_if_core_types=>ty_s_bind_config.
    CREATE OBJECT lo_bind TYPE z2ui5_cl_core_srv_bind EXPORTING APP = mo_action->mo_app.
    
    CLEAR temp12.
    temp12-path_only = path.
    temp12-custom_filter = custom_filter.
    temp12-custom_mapper = custom_mapper.
    temp12-tab = z2ui5_cl_util=>conv_get_as_data_ref( tab ).
    temp12-tab_index = tab_index.
    temp12-switch_default_model = switch_default_model.
    result = lo_bind->main( val    = z2ui5_cl_util=>conv_get_as_data_ref( val )
                            type   = z2ui5_if_core_types=>cs_bind_type-one_way
                            config = temp12 ).


  ENDMETHOD.

  METHOD z2ui5_if_client~_bind_edit.

    DATA lo_bind TYPE REF TO z2ui5_cl_core_srv_bind.
    DATA temp13 TYPE z2ui5_if_core_types=>ty_s_bind_config.
    CREATE OBJECT lo_bind TYPE z2ui5_cl_core_srv_bind EXPORTING APP = mo_action->mo_app.
    
    CLEAR temp13.
    temp13-path_only = path.
    temp13-custom_filter = custom_filter.
    temp13-custom_filter_back = custom_filter_back.
    temp13-custom_mapper = custom_mapper.
    temp13-custom_mapper_back = custom_mapper_back.
    temp13-tab = z2ui5_cl_util=>conv_get_as_data_ref( tab ).
    temp13-tab_index = tab_index.
    temp13-switch_default_model = switch_default_model.
    result = lo_bind->main( val    = z2ui5_cl_util=>conv_get_as_data_ref( val )
                            type   = z2ui5_if_core_types=>cs_bind_type-two_way
                            config = temp13 ).

  ENDMETHOD.

  METHOD z2ui5_if_client~_bind_local.

    DATA lo_bind TYPE REF TO z2ui5_cl_core_srv_bind.
    DATA temp14 TYPE z2ui5_if_core_types=>ty_s_bind_config.
    CREATE OBJECT lo_bind TYPE z2ui5_cl_core_srv_bind EXPORTING APP = mo_action->mo_app.
    
    CLEAR temp14.
    temp14-path_only = path.
    temp14-custom_mapper = custom_mapper.
    temp14-custom_filter = custom_filter.
    temp14-switch_default_model = switch_default_model.
    result = lo_bind->main_local( val    = val
                                  config = temp14 ).

  ENDMETHOD.

  METHOD z2ui5_if_client~_event.

    DATA lo_ui5 TYPE REF TO z2ui5_cl_core_srv_event.
    CREATE OBJECT lo_ui5 TYPE z2ui5_cl_core_srv_event.
    result = lo_ui5->get_event( val   = val
                                t_arg = t_arg
                                s_cnt = s_ctrl ).

    IF r_data IS NOT INITIAL.
      CREATE DATA mo_action->ms_next-r_data LIKE r_data.
      mo_action->ms_next-r_data = z2ui5_cl_util=>conv_copy_ref_data( r_data ).
    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_client~_event_client.

    DATA lo_ui5 TYPE REF TO z2ui5_cl_core_srv_event.
    CREATE OBJECT lo_ui5 TYPE z2ui5_cl_core_srv_event.
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

    DATA temp15 TYPE REF TO z2ui5_if_app.
    DATA lv_check_sticky LIKE temp15->check_sticky.
      DATA temp16 TYPE REF TO z2ui5_if_app.
      DATA temp17 TYPE REF TO z2ui5_if_app.
    temp15 ?= mo_action->mo_app->mo_app.
    
    lv_check_sticky = temp15->check_sticky.
    IF lv_check_sticky = abap_true AND val = abap_true.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `STATEFUL_ALREADY_ACTIVATED_ERROR`.
    ENDIF.
    IF val = abap_true.
      mo_action->ms_next-s_set-s_stateful-active = 1.
      
      temp16 ?= mo_action->mo_app->mo_app.
      temp16->check_sticky = abap_true.
    ELSE.
      mo_action->ms_next-s_set-s_stateful-active = 0.
      
      temp17 ?= mo_action->mo_app->mo_app.
      temp17->check_sticky = abap_false.
    ENDIF.
    mo_action->ms_next-s_set-s_stateful-switched = abap_true.

  ENDMETHOD.

  METHOD z2ui5_if_client~check_app_prev_stack.

    DATA ls_get TYPE z2ui5_if_types=>ty_s_get.
    DATA temp1 TYPE xsdboolean.
    ls_get = z2ui5_if_client~get( ).
    
    temp1 = boolc( ls_get-s_draft-id_prev_app_stack IS NOT INITIAL ).
    result = temp1.

  ENDMETHOD.

  METHOD z2ui5_if_client~check_on_init.

    DATA temp18 TYPE REF TO z2ui5_if_app.
    DATA temp2 TYPE xsdboolean.
    temp18 ?= mo_action->mo_app->mo_app.
    
    temp2 = boolc( temp18->check_initialized = abap_false ).
    result = temp2.

  ENDMETHOD.

  METHOD z2ui5_if_client~check_on_navigated.

    DATA ls_get TYPE z2ui5_if_types=>ty_s_get.
    ls_get = z2ui5_if_client~get( ).
    result = ls_get-check_on_navigated.

  ENDMETHOD.

  METHOD z2ui5_if_client~get_app_prev.

    DATA ls_get TYPE z2ui5_if_types=>ty_s_get.
    ls_get = z2ui5_if_client~get( ).
    result = z2ui5_if_client~get_app( ls_get-s_draft-id_prev_app ).

  ENDMETHOD.

ENDCLASS.
