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

    DATA lv_js LIKE val.
    lv_js = val.

    IF val IS NOT INITIAL
        AND val CO `ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_`.
      " a framework event travels as pure data - a JSON array serialized and
      " escaped entirely in ABAP (get_event_client_json); only a raw JS
      " expression passed by the app keeps the code form
      lv_js = mo_srv_event->get_event_client_json( val   = val
                                                   view  = view
                                                   t_arg = t_arg ).
    ENDIF.

    INSERT lv_js INTO TABLE mo_action->ms_next-s_set-s_follow_up_action-custom_js.

  ENDMETHOD.


  METHOD z2ui5_if_client~check_on_event.
      DATA temp1 TYPE xsdboolean.
      DATA temp2 TYPE xsdboolean.

    IF val IS NOT INITIAL.

      temp1 = boolc( mo_action->ms_actual-event = val ).
      result = temp1.
    ELSE.

      temp2 = boolc( mo_action->ms_actual-event IS NOT INITIAL ).
      result = temp2.
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_if_client~get.
    DATA temp3 TYPE xsdboolean.
    DATA temp4 TYPE xsdboolean.
        DATA lo_comp LIKE mo_action->mo_http_post->ms_request-s_front-o_comp_data.
        DATA lo_params TYPE REF TO z2ui5_if_ajson.
        DATA temp38 LIKE LINE OF lo_params->mt_json_tree.
        DATA lr_comp LIKE REF TO temp38.
          DATA temp39 TYPE z2ui5_if_types=>ty_s_name_value.

    CLEAR result.
    result-event = mo_action->ms_actual-event.
    result-check_launchpad_active = mo_action->mo_http_post->ms_request-s_control-check_launchpad.
    result-t_event_arg = mo_action->ms_actual-t_event_arg.
    MOVE-CORRESPONDING mo_action->mo_app->ms_draft TO result-s_draft.
    result-check_on_navigated = mo_action->ms_actual-check_on_navigated.
    MOVE-CORRESPONDING mo_action->mo_http_post->ms_request-s_front TO result-s_config.
    result-s_device = mo_action->mo_http_post->ms_request-s_front-s_device.
    result-s_focus = mo_action->mo_http_post->ms_request-s_front-s_focus.
    result-s_scroll = mo_action->mo_http_post->ms_request-s_front-s_scroll.
    result-s_ui5 = mo_action->mo_http_post->ms_request-s_front-s_ui5.
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


          CLEAR temp39.
          temp39-n = shift_left( val = shift_right( val = lr_comp->path sub = `/` ) sub = `/` ).
          temp39-v = lr_comp->value.
          INSERT temp39 INTO TABLE result-t_comp_params.
        ENDLOOP.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.


  METHOD z2ui5_if_client~get_event_arg.
        DATA temp40 LIKE LINE OF mo_action->ms_actual-t_event_arg.
        DATA temp41 LIKE sy-tabix.

    TRY.


        temp41 = sy-tabix.
        READ TABLE mo_action->ms_actual-t_event_arg INDEX v INTO temp40.
        sy-tabix = temp41.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        result = temp40.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.


  METHOD z2ui5_if_client~get_app.
      DATA lo_app TYPE REF TO z2ui5_cl_core_app.
      DATA temp42 TYPE REF TO z2ui5_if_app.

    IF id IS NOT INITIAL.

      lo_app = z2ui5_cl_core_app=>db_load( id ).

      temp42 ?= lo_app->mo_app.
      result = temp42.
    ELSE.
      result = get_if_app( ).
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_if_client~message_box_display.

    DATA lv_text    TYPE string.
    DATA lv_type    TYPE string.
    DATA lv_title   TYPE string.
    DATA lv_details TYPE string.
      DATA ls_msg_box TYPE z2ui5_cl_a2ui5_context=>ty_s_msg_box.
      DATA temp43 TYPE string.

    IF z2ui5_cl_a2ui5_context=>rtti_check_clike( text ) = abap_false.

      ls_msg_box = z2ui5_cl_a2ui5_context=>ui5_msg_box_format( text ).
      IF ls_msg_box-skip = abap_true.
        RETURN.
      ENDIF.
      lv_text    = ls_msg_box-text.
      lv_type    = ls_msg_box-type.

      IF title IS NOT INITIAL.
        temp43 = title.
      ELSE.
        temp43 = ls_msg_box-title.
      ENDIF.
      lv_title   = temp43.
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

    IF lv_type IS INITIAL.
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
    mo_action->ms_next-s_set-s_msg_box-dependenton = dependenton.
    mo_action->ms_next-s_set-s_msg_box-contentwidth = contentwidth.

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

    IF app IS NOT BOUND.
      RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
        EXPORTING
          val = `NAV_APP_TARGET_NOT_BOUND - the app passed to nav_app_call/nav_app_leave is not bound`.
    ENDIF.

    IF app->id_app IS INITIAL.
      app->id_app = z2ui5_cl_a2ui5_context=>uuid_get_c32( ).
    ENDIF.
    result = app->id_app.

  ENDMETHOD.


  METHOD z2ui5_if_client~nav_app_call.

    mo_action->ms_next-o_app_call = app.
    result = nav_app_set_id( app ).

  ENDMETHOD.


  METHOD z2ui5_if_client~nav_app_leave.

    IF app IS NOT SUPPLIED.
      app = z2ui5_if_client~get_app( mo_action->mo_app->ms_draft-id_prev_app_stack ).
    ENDIF.

    mo_action->ms_next-o_app_leave = app.
    mo_action->ms_next-next_event  = event.

    " IS SUPPLIED (not IS NOT INITIAL) so an intentionally empty return
    " value still reaches the previous app (https://github.com/abap2UI5/abap2UI5/issues/2404)
    IF r_data IS SUPPLIED.
      mo_action->ms_next-r_data = z2ui5_cl_a2ui5_context=>conv_copy_ref_data( r_data ).
    ENDIF.

    result = nav_app_set_id( app ).

  ENDMETHOD.


  METHOD z2ui5_if_client~nest2_view_destroy.

    " see popover_destroy for why the whole slot is wiped instead of setting a flag
    CLEAR mo_action->ms_next-s_set-s_view_nest2.
    mo_action->ms_next-s_set-s_view_nest2-check_destroy = abap_true.

  ENDMETHOD.


  METHOD z2ui5_if_client~nest2_view_display.

    mo_action->ms_next-s_set-s_view_nest2-check_destroy  = abap_false.
    mo_action->ms_next-s_set-s_view_nest2-xml            = val.
    mo_action->ms_next-s_set-s_view_nest2-id             = id.
    mo_action->ms_next-s_set-s_view_nest2-method_destroy = method_destroy.
    mo_action->ms_next-s_set-s_view_nest2-method_insert  = method_insert.

  ENDMETHOD.


  METHOD z2ui5_if_client~nest2_view_model_update.

    " a nested view owns no model - it inherits the MAIN view's by UI5 model
    " propagation, so refreshing "the nest2 model" means refreshing the root
    " model. Delegating also removes the old trap: the former nest2-only flag
    " was skipped by the frontend whenever no nested view happened to be open
    z2ui5_if_client~view_model_update( ).

  ENDMETHOD.


  METHOD z2ui5_if_client~nest_view_destroy.

    " see popover_destroy for why the whole slot is wiped instead of setting a flag
    CLEAR mo_action->ms_next-s_set-s_view_nest.
    mo_action->ms_next-s_set-s_view_nest-check_destroy = abap_true.

  ENDMETHOD.


  METHOD z2ui5_if_client~nest_view_display.

    mo_action->ms_next-s_set-s_view_nest-check_destroy  = abap_false.
    mo_action->ms_next-s_set-s_view_nest-xml            = val.
    mo_action->ms_next-s_set-s_view_nest-id             = id.
    mo_action->ms_next-s_set-s_view_nest-method_destroy = method_destroy.
    mo_action->ms_next-s_set-s_view_nest-method_insert  = method_insert.

  ENDMETHOD.


  METHOD z2ui5_if_client~nest_view_model_update.

    " see nest2_view_model_update - one root model, so this is view_model_update
    z2ui5_if_client~view_model_update( ).

  ENDMETHOD.


  METHOD z2ui5_if_client~popover_destroy.

    " wipe the whole slot (like popup_destroy) - a plain flag would leave the
    " xml of a popover_display( ) from the same roundtrip in place and the
    " frontend would destroy and then re-open the popover
    CLEAR mo_action->ms_next-s_set-s_popover.
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

    " like popup_display/popover_display: displaying cancels a destroy
    " queued earlier in the same roundtrip
    mo_action->ms_next-s_set-s_view-check_destroy = abap_false.
    mo_action->ms_next-s_set-s_view-xml = val.
    mo_action->ms_next-s_set-s_view-switchdefaultmodelannouri = switch_default_model_anno_uri.
    mo_action->ms_next-s_set-s_view-switch_default_model_path = switch_default_model_path.

  ENDMETHOD.


  METHOD z2ui5_if_client~view_model_update.

    mo_action->ms_next-s_set-s_view-check_update_model = abap_true.

  ENDMETHOD.


  METHOD z2ui5_if_client~_bind.

    DATA li_filter LIKE custom_filter.
          DATA li_omit TYPE REF TO z2ui5_if_ajson_filter.
            DATA temp44 TYPE z2ui5_if_ajson_filter=>ty_filter_tab.
    DATA temp46 TYPE z2ui5_if_core_types=>ty_s_bind_config.
    li_filter = custom_filter.

    " omit_initial wires ajson's empty filter into the slot the serializer
    " already evaluates (z2ui5_cl_core_srv_model->main_json_stringify), so an
    " initial field stays ABSENT from the model and the control keeps its own
    " default. A caller-supplied filter is kept: both have to pass.
    IF omit_initial = abap_true OR omit_initial_paths IS NOT INITIAL.
      TRY.

          IF omit_initial_paths IS NOT INITIAL.
            " scoped: only the listed columns are dropped when initial, so a
            " boolean that must send abap_false survives
            CREATE OBJECT li_omit TYPE lcl_initial_paths_filter EXPORTING IT_PATHS = omit_initial_paths.
          ELSE.
            li_omit = z2ui5_cl_ajson_filter_lib=>create_empty_filter( ).
          ENDIF.
          IF li_filter IS BOUND.

            CLEAR temp44.
            INSERT li_filter INTO TABLE temp44.
            INSERT li_omit INTO TABLE temp44.
            li_filter = z2ui5_cl_ajson_filter_lib=>create_and_filter(
                            temp44 ).
          ELSE.
            li_filter = li_omit.
          ENDIF.
        CATCH cx_root.
          " a filter that cannot be built must not kill the roundtrip - the
          " model is then serialized as before (initial fields included)
          li_filter = custom_filter.
      ENDTRY.
    ENDIF.


    CLEAR temp46.
    temp46-path_only = path.
    temp46-custom_filter = li_filter.
    temp46-custom_mapper = custom_mapper.
    temp46-tab = z2ui5_cl_a2ui5_context=>conv_get_as_data_ref( tab ).
    temp46-tab_index = tab_index.
    temp46-switch_default_model = switch_default_model.
    result = mo_srv_bind->main( val    = z2ui5_cl_a2ui5_context=>conv_get_as_data_ref( val )
                                config = temp46 ).

  ENDMETHOD.


  METHOD z2ui5_if_client~_bind_edit.

    " compatibility alias of _bind - delegate instead of repeating the call so
    " both can never drift apart. custom_mapper_back / custom_filter_back exist
    " only on this signature and are deliberately no longer evaluated (_bind
    " has no counterpart for them).
    result = z2ui5_if_client~_bind( val                  = val
                                    path                 = path
                                    view                 = view
                                    custom_mapper        = custom_mapper
                                    custom_filter        = custom_filter
                                    tab                  = tab
                                    tab_index            = tab_index
                                    switch_default_model = switch_default_model ).

  ENDMETHOD.


  METHOD z2ui5_if_client~_event.

    result = mo_srv_event->get_event( val   = val
                                      t_arg = t_arg
                                      s_cnt = s_ctrl ).

    IF r_data IS NOT INITIAL.
      mo_action->ms_next-r_data = z2ui5_cl_a2ui5_context=>conv_copy_ref_data( r_data ).
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_if_client~_event_client.

    result = mo_srv_event->get_event_client( val   = val
                                             view  = view
                                             t_arg = t_arg ).

  ENDMETHOD.


  METHOD z2ui5_if_client~set_nav_back.

    mo_action->ms_next-s_set-set_nav_back = val.

  ENDMETHOD.


  METHOD z2ui5_if_client~set_push_state.

    mo_action->ms_next-s_set-set_push_state = val.

  ENDMETHOD.


  METHOD z2ui5_if_client~set_nav_routing.

    mo_action->ms_next-s_set-set_nav_routing = mode.
    " remember the mode on the app so every later response of this app carries
    " it again - see z2ui5_cl_core_app=>mv_nav_mode
    mo_action->mo_app->mv_nav_mode = mode.

  ENDMETHOD.


  METHOD z2ui5_if_client~set_app_state_active.

    mo_action->ms_next-s_set-set_app_state_active = val.

  ENDMETHOD.


  METHOD z2ui5_if_client~set_session_stateful.

    DATA li_app TYPE REF TO z2ui5_if_app.
    DATA temp47 TYPE z2ui5_if_core_types=>ty_s_http_res-s_stateful-active.
    DATA temp5 TYPE xsdboolean.
    li_app = get_if_app( ).
    IF li_app->check_sticky = val.
      RETURN.
    ENDIF.

    IF val = abap_true.
      temp47 = 1.
    ELSE.
      temp47 = 0.
    ENDIF.
    mo_action->ms_next-s_set-s_stateful-active = temp47.
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

    " keep the interface access on a typed variable - reading the attribute
    " directly on the method-call chain breaks in the abaplint transpiler
    " runtime (plain property access misses the interface attribute alias)
    DATA li_app TYPE REF TO z2ui5_if_app.
    DATA temp7 TYPE xsdboolean.
    li_app = get_if_app( ).

    temp7 = boolc( li_app->check_initialized = abap_false ).
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

    DATA temp48 TYPE REF TO z2ui5_if_app.
    temp48 ?= mo_action->mo_app->mo_app.
    result = temp48.

  ENDMETHOD.

ENDCLASS.
