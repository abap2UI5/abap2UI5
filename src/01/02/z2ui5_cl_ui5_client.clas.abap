CLASS z2ui5_cl_ui5_client DEFINITION PUBLIC FINAL.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_client.

    DATA mo_action TYPE REF TO z2ui5_cl_ui5_action.

    METHODS constructor
      IMPORTING
        action TYPE REF TO z2ui5_cl_ui5_action.

    DATA mo_srv_bind  TYPE REF TO z2ui5_cl_ui5_srv_bind.
    DATA mo_srv_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA mo_action_front   TYPE REF TO z2ui5_cl_ui5_frontend.

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


CLASS z2ui5_cl_ui5_client IMPLEMENTATION.


  METHOD constructor.

    mo_action = action.
    CREATE OBJECT mo_srv_bind EXPORTING APP = mo_action->mo_app.
    CREATE OBJECT mo_srv_event.
    CREATE OBJECT mo_action_front EXPORTING ACTION = mo_action.

  ENDMETHOD.


  METHOD z2ui5_if_client~follow_up_action.

    " These three configure how the browser URL has to look after this
    " roundtrip. Router derives ONE outcome from all of them together, so they
    " are collected here and leave as options of the single ROUTER/sync call
    " main_end( ) queues - never as actions of their own, which would make the
    " router run several times and fight over the same hash.
    DATA temp54 TYPE string.
    DATA temp55 TYPE string.
    DATA lv_arg LIKE temp54.
        DATA temp1 TYPE xsdboolean.
    CLEAR temp54.

    READ TABLE t_arg INTO temp55 INDEX 1.
    IF sy-subrc = 0.
      temp54 = temp55.
    ENDIF.

    lv_arg = temp54.

    CASE val.
      WHEN z2ui5_if_client=>cs_event-set_nav_routing.
        " the mode is remembered on the app ( z2ui5_cl_ui5_app=>mv_nav_mode )
        " and re-sent when the frontend may not still hold it - main_end gates
        " the re-send on the nav_mode_sent latch; an app called via
        " nav_app_call inherits it, and a draft restored later still knows how
        " it was routed
        IF lv_arg IS INITIAL.
          lv_arg = z2ui5_if_client=>cs_nav_mode-keep.
        ENDIF.
        mo_action->ms_next-s_nav-set_nav_routing = lv_arg.
        mo_action->mo_app->mv_nav_mode           = lv_arg.
        RETURN.

      WHEN z2ui5_if_client=>cs_event-set_push_state.
        mo_action->ms_next-s_nav-set_push_state = lv_arg.
        RETURN.

      WHEN z2ui5_if_client=>cs_event-set_app_state_active.
        " an empty argument list switches it ON - a single space is how an
        " app switches it off again, since an empty t_arg cannot say `false`

        temp1 = boolc( lv_arg <> ` ` ).
        mo_action->ms_next-s_nav-set_app_state_active = temp1.
        RETURN.
    ENDCASE.


    IF result IS SUPPLIED.

      result = mo_srv_event->get_event_client( val   = val
                                               view  = view
                                               t_arg = t_arg ).
      RETURN.
    ENDIF.


    IF val IS NOT INITIAL
        AND val CO `ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_`.
      " a framework event travels as pure data - a JSON array built and
      " escaped entirely in ABAP; only a raw JS expression passed by the app
      " keeps the code form (the legacy formats, a STRING entry of the list)
      mo_action_front->queue_app_event( val   = val
                                        view  = view
                                        t_arg = t_arg ).
    ELSE.
      mo_action_front->queue_app_js( val ).
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_if_client~check_on_event.
      DATA temp2 TYPE xsdboolean.
      DATA temp3 TYPE xsdboolean.

    IF val IS NOT INITIAL.

      temp2 = boolc( mo_action->ms_actual-event = val ).
      result = temp2.
    ELSE.

      temp3 = boolc( mo_action->ms_actual-event IS NOT INITIAL ).
      result = temp3.
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_if_client~get.
    DATA temp4 TYPE xsdboolean.
    DATA temp5 TYPE xsdboolean.
        DATA lo_comp LIKE mo_action->mo_http_post->ms_request-s_front-o_comp_data.
        DATA lo_params TYPE REF TO z2ui5_if_ajson.
        DATA temp56 LIKE LINE OF lo_params->mt_json_tree.
        DATA lr_comp LIKE REF TO temp56.
          DATA temp57 TYPE z2ui5_if_types=>ty_s_name_value.

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

    temp4 = boolc( mo_action->ms_next-o_app_call IS NOT INITIAL ).
    result-_s_nav-check_call = temp4.

    temp5 = boolc( mo_action->ms_next-o_app_leave IS NOT INITIAL ).
    result-_s_nav-check_leave = temp5.

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


          CLEAR temp57.
          temp57-n = shift_left( val = shift_right( val = lr_comp->path sub = `/` ) sub = `/` ).
          temp57-v = lr_comp->value.
          INSERT temp57 INTO TABLE result-t_comp_params.
        ENDLOOP.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.


  METHOD z2ui5_if_client~get_event.

    result = mo_action->ms_actual-event.

  ENDMETHOD.


  METHOD z2ui5_if_client~get_event_arg.
        DATA temp58 LIKE LINE OF mo_action->ms_actual-t_event_arg.
        DATA temp59 LIKE sy-tabix.

    TRY.


        temp59 = sy-tabix.
        READ TABLE mo_action->ms_actual-t_event_arg INDEX v INTO temp58.
        sy-tabix = temp59.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        result = temp58.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.


  METHOD z2ui5_if_client~get_app.
      DATA lo_app TYPE REF TO z2ui5_cl_ui5_app_cont.
      DATA temp60 TYPE REF TO z2ui5_if_app.

    IF id IS NOT INITIAL.

      lo_app = z2ui5_cl_ui5_app_cont=>db_load( id ).

      temp60 ?= lo_app->mo_app.
      result = temp60.
    ELSE.
      result = get_if_app( ).
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_if_client~message_box_display.

    mo_action_front->msg_box( text              = text
                              type              = type
                              title             = title
                              styleclass        = styleclass
                              onclose           = onclose
                              actions           = actions
                              emphasizedaction  = emphasizedaction
                              initialfocus      = initialfocus
                              textdirection     = textdirection
                              icon              = icon
                              details           = details
                              closeonnavigation = closeonnavigation
                              dependenton       = dependenton
                              contentwidth      = contentwidth ).

  ENDMETHOD.


  METHOD z2ui5_if_client~message_toast_display.

    mo_action_front->msg_toast( text                     = text
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
                                class                    = class ).

  ENDMETHOD.


  METHOD nav_app_set_id.

    IF app IS NOT BOUND.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING
          val = `NAV_APP_TARGET_NOT_BOUND - the app passed to nav_app_call/nav_app_leave is not bound`.
    ENDIF.

    IF app->id_app IS INITIAL.
      app->id_app = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
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
      mo_action->ms_next-r_data = z2ui5_cl_ui5_util_context=>conv_copy_ref_data( r_data ).
    ENDIF.

    result = nav_app_set_id( app ).

  ENDMETHOD.


  METHOD z2ui5_if_client~nest2_view_destroy.

    mo_action_front->slot_destroy( z2ui5_if_client=>cs_view-nested2 ).

  ENDMETHOD.


  METHOD z2ui5_if_client~nest2_view_display.

    mo_action_front->slot_display( slot = z2ui5_if_client=>cs_view-nested2
                  xml                   = val
                  id                    = id
                  method_insert         = method_insert
                  method_destroy        = method_destroy ).

  ENDMETHOD.


  METHOD z2ui5_if_client~nest2_view_model_update.

    " deliberately EMPTY - see view_model_update. A nested view owns no model
    " anyway: it inherits the MAIN view's by UI5 model propagation, so the
    " automatic push of the root model already covers it

  ENDMETHOD.


  METHOD z2ui5_if_client~nest_view_destroy.

    mo_action_front->slot_destroy( z2ui5_if_client=>cs_view-nested ).

  ENDMETHOD.


  METHOD z2ui5_if_client~nest_view_display.

    mo_action_front->slot_display( slot = z2ui5_if_client=>cs_view-nested
                  xml                   = val
                  id                    = id
                  method_insert         = method_insert
                  method_destroy        = method_destroy ).

  ENDMETHOD.


  METHOD z2ui5_if_client~nest_view_model_update.

    " deliberately EMPTY - see nest2_view_model_update

  ENDMETHOD.


  METHOD z2ui5_if_client~popover_destroy.

    mo_action_front->slot_destroy( z2ui5_if_client=>cs_view-popover ).

  ENDMETHOD.


  METHOD z2ui5_if_client~popover_display.

    mo_action_front->slot_display( slot = z2ui5_if_client=>cs_view-popover
                  xml                   = xml
                  open_by_id            = by_id ).

  ENDMETHOD.


  METHOD z2ui5_if_client~popover_model_update.

    " deliberately EMPTY - see view_model_update. The automatic push reaches
    " every open slot, so an open popover refreshes without this call

  ENDMETHOD.


  METHOD z2ui5_if_client~popup_destroy.

    mo_action_front->slot_destroy( z2ui5_if_client=>cs_view-popup ).

  ENDMETHOD.


  METHOD z2ui5_if_client~popup_display.

    mo_action_front->slot_display( slot = z2ui5_if_client=>cs_view-popup
                  xml                   = val ).

  ENDMETHOD.


  METHOD z2ui5_if_client~popup_model_update.

    " deliberately EMPTY - see view_model_update. The automatic push reaches
    " every open slot, so an open popup refreshes without this call

  ENDMETHOD.


  METHOD z2ui5_if_client~view_destroy.

    mo_action_front->slot_destroy( z2ui5_if_client=>cs_view-main ).

  ENDMETHOD.


  METHOD z2ui5_if_client~view_display.

    mo_action_front->slot_display( slot         = z2ui5_if_client=>cs_view-main
                  xml                           = val
                  switch_default_model_path     = switch_default_model_path
                  switch_default_model_anno_uri = switch_default_model_anno_uri ).

  ENDMETHOD.


  METHOD z2ui5_if_client~view_model_update.

    " deliberately EMPTY - the handler queues the model push itself: on
    " every view roundtrip, and otherwise whenever main( ) changed the model
    " (z2ui5_cl_ui5_handler=>main_end). The push names no slot; every open
    " model-owning slot picks it up. The method stays in the interface so
    " existing apps keep compiling and their calls keep being harmless

  ENDMETHOD.


  METHOD z2ui5_if_client~_bind.

    DATA li_filter LIKE custom_filter.
          DATA li_omit TYPE REF TO z2ui5_if_ajson_filter.
            DATA temp61 TYPE z2ui5_if_ajson_filter=>ty_filter_tab.
    DATA temp63 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    li_filter = custom_filter.

    " omit_initial wires ajson's empty filter into the slot the serializer
    " already evaluates (z2ui5_cl_ui5_srv_model->main_json_stringify), so an
    " initial field stays ABSENT from the model and the control keeps its own
    " default. A caller-supplied filter is kept: both have to pass.
    IF omit_initial = abap_true OR omit_initial_paths IS NOT INITIAL.
      TRY.

          IF omit_initial_paths IS NOT INITIAL.
            " scoped: only the listed columns are dropped when initial, so a
            " boolean that must send abap_false survives
            CREATE OBJECT li_omit TYPE lcl_initial_paths_filter EXPORTING IT_PATHS = omit_initial_paths.
          ELSE.
            " NOT the vendored create_empty_filter: that one also drops a
            " table ROW whose fields are all initial, which reindexes the
            " client array against the backend table and corrupts the
            " write-back (whole-table and __delta) - see the local class
            CREATE OBJECT li_omit TYPE lcl_empty_filter_keep_rows.
          ENDIF.
          IF li_filter IS BOUND.

            CLEAR temp61.
            INSERT li_filter INTO TABLE temp61.
            INSERT li_omit INTO TABLE temp61.
            li_filter = z2ui5_cl_ajson_filter_lib=>create_and_filter(
                            temp61 ).
          ELSE.
            li_filter = li_omit.
          ENDIF.
        CATCH cx_root.
          " a filter that cannot be built must not kill the roundtrip - the
          " model is then serialized as before (initial fields included)
          li_filter = custom_filter.
      ENDTRY.
    ENDIF.


    CLEAR temp63.
    temp63-path_only = path.
    temp63-custom_filter = li_filter.
    temp63-custom_mapper = custom_mapper.
    temp63-tab = z2ui5_cl_ui5_util_context=>conv_get_as_data_ref( tab ).
    temp63-tab_index = tab_index.
    temp63-switch_default_model = switch_default_model.
    temp63-check_json = json.
    result = mo_srv_bind->main( val    = z2ui5_cl_ui5_util_context=>conv_get_as_data_ref( val )
                                config = temp63 ).

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

  ENDMETHOD.


  METHOD z2ui5_if_client~_event_client.

    result = mo_srv_event->get_event_client( val   = val
                                             view  = view
                                             t_arg = t_arg ).

  ENDMETHOD.


  METHOD z2ui5_if_client~set_push_state.

    " same field the cs_event-set_push_state branch of follow_up_action
    " writes - the typed method just skips the string-argument detour
    mo_action->ms_next-s_nav-set_push_state = val.

  ENDMETHOD.


  METHOD z2ui5_if_client~set_app_state_active.

    " same field the cs_event-set_app_state_active branch of follow_up_action
    " writes - only that path needs the single-space encoding to squeeze
    " `false` through a string argument; a typed abap_bool does not
    mo_action->ms_next-s_nav-set_app_state_active = val.

  ENDMETHOD.


  METHOD z2ui5_if_client~set_session_stateful.
    DATA temp64 TYPE z2ui5_if_ui5_types=>ty_s_http_res-s_stateful-active.
    DATA temp6 TYPE xsdboolean.

    IF mo_action->mo_app->mv_check_sticky = val.
      RETURN.
    ENDIF.

    IF val = abap_true.
      temp64 = 1.
    ELSE.
      temp64 = 0.
    ENDIF.
    mo_action->ms_next-s_stateful-active = temp64.
    mo_action->mo_app->mv_check_sticky = val.


    temp6 = boolc( mo_action->ms_next-s_stateful-switched = abap_false ).
    mo_action->ms_next-s_stateful-switched = temp6.

  ENDMETHOD.


  METHOD z2ui5_if_client~check_app_prev_stack.

    DATA temp7 TYPE xsdboolean.
    temp7 = boolc( mo_action->mo_app->ms_draft-id_prev_app_stack IS NOT INITIAL ).
    result = temp7.

  ENDMETHOD.


  METHOD z2ui5_if_client~check_on_init.

    DATA temp8 TYPE xsdboolean.
    temp8 = boolc( mo_action->mo_app->mv_check_initialized = abap_false ).
    result = temp8.

  ENDMETHOD.


  METHOD z2ui5_if_client~check_on_navigated.

    result = mo_action->ms_actual-check_on_navigated.

  ENDMETHOD.


  METHOD z2ui5_if_client~get_app_prev.

    result = z2ui5_if_client~get_app( mo_action->mo_app->ms_draft-id_prev_app ).

  ENDMETHOD.


  METHOD z2ui5_if_client~_event_nav_app_leave.

    result = z2ui5_if_client~_event( z2ui5_if_ui5_types=>cs_event_nav_app_leave ).

  ENDMETHOD.


  METHOD get_if_app.

    DATA temp65 TYPE REF TO z2ui5_if_app.
    temp65 ?= mo_action->mo_app->mo_app.
    result = temp65.

  ENDMETHOD.

ENDCLASS.
