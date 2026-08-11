CLASS z2ui5_cl_core_client DEFINITION PUBLIC FINAL.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_client.

    DATA mo_action TYPE REF TO z2ui5_cl_core_action.

    METHODS constructor
      IMPORTING
        action TYPE REF TO z2ui5_cl_core_action.

    DATA mo_srv_bind  TYPE REF TO z2ui5_cl_core_srv_bind.
    DATA mo_srv_event TYPE REF TO z2ui5_cl_core_srv_event.
    DATA mo_action_front   TYPE REF TO z2ui5_cl_core_action_front.

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
    mo_srv_bind = NEW #( mo_action->mo_app ).
    mo_srv_event = NEW #( ).
    mo_action_front = NEW #( mo_action ).

  ENDMETHOD.


  METHOD z2ui5_if_client~follow_up_action.

    " These three configure how the browser URL has to look after this
    " roundtrip. Router derives ONE outcome from all of them together, so they
    " are collected here and leave as options of the single ROUTER/sync call
    " main_end( ) queues - never as actions of their own, which would make the
    " router run several times and fight over the same hash.
    DATA(lv_arg) = VALUE string( t_arg[ 1 ] OPTIONAL ).

    CASE val.
      WHEN z2ui5_if_client=>cs_event-set_nav_routing.
        " the mode is remembered on the app as well, so every later response
        " of this app carries it again ( z2ui5_cl_core_app=>mv_nav_mode ), an
        " app called via nav_app_call inherits it, and a draft restored later
        " still knows how it was routed
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
        mo_action->ms_next-s_nav-set_app_state_active = xsdbool( lv_arg <> ` ` ).
        RETURN.
    ENDCASE.


    IF result IS SUPPLIED.

      result = mo_srv_event->get_event_client( val   = val
                                               view  = view
                                               t_arg = t_arg ).
      RETURN.
    ENDIF.


    DATA(lv_js) = val.

    IF val IS NOT INITIAL
        AND val CO `ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_`.
      " a framework event travels as pure data - a JSON array serialized and
      " escaped entirely in ABAP (get_event_client_json); only a raw JS
      " expression passed by the app keeps the code form
      lv_js = mo_srv_event->get_event_client_json( val   = val
                                                   view  = view
                                                   t_arg = t_arg ).
    ENDIF.

    INSERT lv_js INTO TABLE mo_action->ms_next-s_set-s_action-t_custom.

  ENDMETHOD.


  METHOD z2ui5_if_client~check_on_event.

    IF val IS NOT INITIAL.
      result = xsdbool( mo_action->ms_actual-event = val ).
    ELSE.
      result = xsdbool( mo_action->ms_actual-event IS NOT INITIAL ).
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_if_client~get.

    result = VALUE #( event                  = mo_action->ms_actual-event
                      check_launchpad_active = mo_action->mo_http_post->ms_request-s_control-check_launchpad
                      t_event_arg            = mo_action->ms_actual-t_event_arg
                      s_draft                = CORRESPONDING #( mo_action->mo_app->ms_draft )
                      check_on_navigated     = mo_action->ms_actual-check_on_navigated
                      s_config               = CORRESPONDING #( mo_action->mo_http_post->ms_request-s_front )
                      s_device               = mo_action->mo_http_post->ms_request-s_front-s_device
                      s_focus                = mo_action->mo_http_post->ms_request-s_front-s_focus
                      s_scroll               = mo_action->mo_http_post->ms_request-s_front-s_scroll
                      s_ui5                  = mo_action->mo_http_post->ms_request-s_front-s_ui5
                      r_event_data           = mo_action->ms_actual-r_data
                      _s_nav-check_call      = xsdbool( mo_action->ms_next-o_app_call IS NOT INITIAL )
                      _s_nav-check_leave     = xsdbool( mo_action->ms_next-o_app_leave IS NOT INITIAL ) ).

    TRY.

        DATA(lo_comp) = mo_action->mo_http_post->ms_request-s_front-o_comp_data.
        IF lo_comp IS NOT BOUND.
          RETURN.
        ENDIF.
        DATA(lo_params) = lo_comp->slice( `/startupParameters/` ).

        IF lo_params IS NOT BOUND.
          RETURN.
        ENDIF.
        LOOP AT lo_params->mt_json_tree                 "#EC CI_SORTSEQ
             REFERENCE INTO DATA(lr_comp)
             WHERE name = `1`.

          INSERT VALUE #( n = shift_left( val = shift_right( val = lr_comp->path
                                                             sub = `/` )
                                          sub = `/` )
                          v = lr_comp->value ) INTO TABLE result-t_comp_params.
        ENDLOOP.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.


  METHOD z2ui5_if_client~get_event_arg.

    TRY.
        result = mo_action->ms_actual-t_event_arg[ v ].
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.


  METHOD z2ui5_if_client~get_app.

    IF id IS NOT INITIAL.
      DATA(lo_app) = z2ui5_cl_core_app=>db_load( id ).
      result = CAST #( lo_app->mo_app ).
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

    mo_action_front->slot_destroy( z2ui5_cl_core_action_front=>cs_slot-nest2 ).

  ENDMETHOD.


  METHOD z2ui5_if_client~nest2_view_display.

    mo_action_front->slot_display( slot = z2ui5_cl_core_action_front=>cs_slot-nest2
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

    mo_action_front->slot_destroy( z2ui5_cl_core_action_front=>cs_slot-nest ).

  ENDMETHOD.


  METHOD z2ui5_if_client~nest_view_display.

    mo_action_front->slot_display( slot = z2ui5_cl_core_action_front=>cs_slot-nest
                  xml                   = val
                  id                    = id
                  method_insert         = method_insert
                  method_destroy        = method_destroy ).

  ENDMETHOD.


  METHOD z2ui5_if_client~nest_view_model_update.

    " deliberately EMPTY - see nest2_view_model_update

  ENDMETHOD.


  METHOD z2ui5_if_client~popover_destroy.

    mo_action_front->slot_destroy( z2ui5_cl_core_action_front=>cs_slot-popover ).

  ENDMETHOD.


  METHOD z2ui5_if_client~popover_display.

    mo_action_front->slot_display( slot = z2ui5_cl_core_action_front=>cs_slot-popover
                  xml                   = xml
                  open_by_id            = by_id ).

  ENDMETHOD.


  METHOD z2ui5_if_client~popover_model_update.

    " deliberately EMPTY - see view_model_update. The automatic push flags
    " the POPOVER slot too, so an open popover refreshes without this call

  ENDMETHOD.


  METHOD z2ui5_if_client~popup_destroy.

    mo_action_front->slot_destroy( z2ui5_cl_core_action_front=>cs_slot-popup ).

  ENDMETHOD.


  METHOD z2ui5_if_client~popup_display.

    mo_action_front->slot_display( slot = z2ui5_cl_core_action_front=>cs_slot-popup
                  xml                   = val ).

  ENDMETHOD.


  METHOD z2ui5_if_client~popup_model_update.

    " deliberately EMPTY - see view_model_update. The automatic push flags
    " the POPUP slot too, so an open popup refreshes without this call

  ENDMETHOD.


  METHOD z2ui5_if_client~view_destroy.

    mo_action_front->slot_destroy( z2ui5_cl_core_action_front=>cs_slot-main ).

  ENDMETHOD.


  METHOD z2ui5_if_client~view_display.

    mo_action_front->slot_display( slot         = z2ui5_cl_core_action_front=>cs_slot-main
                  xml                           = val
                  switch_default_model_path     = switch_default_model_path
                  switch_default_model_anno_uri = switch_default_model_anno_uri ).

  ENDMETHOD.


  METHOD z2ui5_if_client~view_model_update.

    " deliberately EMPTY - the handler pushes the model by itself whenever
    " main( ) changed it (z2ui5_cl_core_handler=>main_end compares the model
    " before and after main( ) and flags every model-owning slot). The method
    " stays in the interface so existing apps keep compiling and their calls
    " keep being harmless; there is nothing left for it to do

  ENDMETHOD.


  METHOD z2ui5_if_client~_bind.

    DATA(li_filter) = custom_filter.

    " omit_initial wires ajson's empty filter into the slot the serializer
    " already evaluates (z2ui5_cl_core_srv_model->main_json_stringify), so an
    " initial field stays ABSENT from the model and the control keeps its own
    " default. A caller-supplied filter is kept: both have to pass.
    IF omit_initial = abap_true OR omit_initial_paths IS NOT INITIAL.
      TRY.
          DATA li_omit TYPE REF TO z2ui5_if_ajson_filter.
          IF omit_initial_paths IS NOT INITIAL.
            " scoped: only the listed columns are dropped when initial, so a
            " boolean that must send abap_false survives
            li_omit = NEW lcl_initial_paths_filter( omit_initial_paths ).
          ELSE.
            li_omit = z2ui5_cl_ajson_filter_lib=>create_empty_filter( ).
          ENDIF.
          IF li_filter IS BOUND.
            li_filter = z2ui5_cl_ajson_filter_lib=>create_and_filter(
                            VALUE #( ( li_filter ) ( li_omit ) ) ).
          ELSE.
            li_filter = li_omit.
          ENDIF.
        CATCH cx_root.
          " a filter that cannot be built must not kill the roundtrip - the
          " model is then serialized as before (initial fields included)
          li_filter = custom_filter.
      ENDTRY.
    ENDIF.

    result = mo_srv_bind->main( val    = z2ui5_cl_a2ui5_context=>conv_get_as_data_ref( val )
                                config = VALUE #(
                                    path_only            = path
                                    custom_filter        = li_filter
                                    custom_mapper        = custom_mapper
                                    tab                  = z2ui5_cl_a2ui5_context=>conv_get_as_data_ref( tab )
                                    tab_index            = tab_index
                                    switch_default_model = switch_default_model
                                    check_json           = json ) ).

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

    z2ui5_if_client~follow_up_action( val   = z2ui5_if_client=>cs_event-set_push_state
                                      t_arg = VALUE #( ( val ) ) ).

  ENDMETHOD.


  METHOD z2ui5_if_client~set_app_state_active.

    z2ui5_if_client~follow_up_action(
        val   = z2ui5_if_client=>cs_event-set_app_state_active
        t_arg = VALUE #( ( COND string( WHEN val = abap_true THEN abap_true ELSE ` ` ) ) ) ).

  ENDMETHOD.


  METHOD z2ui5_if_client~set_session_stateful.

    DATA(li_app) = get_if_app( ).
    IF li_app->check_sticky = val.
      RETURN.
    ENDIF.
    mo_action->ms_next-s_stateful-active = COND #( WHEN val = abap_true THEN 1 ELSE 0 ).
    li_app->check_sticky = val.

    mo_action->ms_next-s_stateful-switched = xsdbool( mo_action->ms_next-s_stateful-switched = abap_false ).

  ENDMETHOD.


  METHOD z2ui5_if_client~check_app_prev_stack.

    result = xsdbool( mo_action->mo_app->ms_draft-id_prev_app_stack IS NOT INITIAL ).

  ENDMETHOD.


  METHOD z2ui5_if_client~check_on_init.

    " keep the interface access on a typed variable - reading the attribute
    " directly on the method-call chain breaks in the abaplint transpiler
    " runtime (plain property access misses the interface attribute alias)
    DATA(li_app) = get_if_app( ).
    result = xsdbool( li_app->check_initialized = abap_false ).

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

    result = CAST z2ui5_if_app( mo_action->mo_app->mo_app ).

  ENDMETHOD.

ENDCLASS.
