CLASS z2ui5_cl_core_client DEFINITION PUBLIC FINAL.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_client.

    DATA mo_action TYPE REF TO z2ui5_cl_core_action.

    METHODS constructor
      IMPORTING
        action TYPE REF TO z2ui5_cl_core_action.

    DATA mo_srv_bind  TYPE REF TO z2ui5_cl_core_srv_bind.
    DATA mo_srv_event TYPE REF TO z2ui5_cl_core_srv_event.
    DATA mo_srv_msg   TYPE REF TO z2ui5_cl_core_srv_msg.

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

    "! The view slots, spelled as the frontend's ViewSlots module knows them.
    CONSTANTS:
      BEGIN OF cs_slot,
        main    TYPE string VALUE `MAIN`,
        nest    TYPE string VALUE `NEST`,
        nest2   TYPE string VALUE `NEST2`,
        popup   TYPE string VALUE `POPUP`,
        popover TYPE string VALUE `POPOVER`,
      END OF cs_slot.

    METHODS slot_destroy
      IMPORTING
        slot TYPE clike.

    "! Drop everything queued for a slot so far - see the method body.
    METHODS slot_reset
      IMPORTING
        slot TYPE clike.

    METHODS slot_display
      IMPORTING
        slot                          TYPE clike
        xml                           TYPE clike
        id                            TYPE clike OPTIONAL
        method_insert                 TYPE clike OPTIONAL
        method_destroy                TYPE clike OPTIONAL
        open_by_id                    TYPE clike OPTIONAL
        switch_default_model_path     TYPE clike OPTIONAL
        switch_default_model_anno_uri TYPE clike OPTIONAL.

    METHODS set_opt
      IMPORTING
        json TYPE REF TO z2ui5_if_ajson
        name TYPE string
        val  TYPE clike
      RAISING
        z2ui5_cx_ajson_error.

ENDCLASS.


CLASS z2ui5_cl_core_client IMPLEMENTATION.


  METHOD constructor.

    mo_action = action.
    mo_srv_bind = NEW #( mo_action->mo_app ).
    mo_srv_event = NEW #( ).
    mo_srv_msg = NEW #( ).

  ENDMETHOD.


  METHOD z2ui5_if_client~follow_up_action.

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

    INSERT lv_js INTO TABLE mo_action->ms_next-s_set-s_follow_up_action-custom_js.

  ENDMETHOD.


  METHOD slot_destroy.

    " every slot tears down through the one ViewSlots.destroy( key ) the
    " frontend already had - the five *_destroy( ) methods differ in nothing
    " but the key they name
    slot_reset( slot ).
    INSERT VALUE #( slot   = slot
                    method = `destroy` )
           INTO TABLE mo_action->ms_next-t_system.

  ENDMETHOD.


  METHOD slot_reset.

    " Everything queued for this slot so far is void: whatever it was, the
    " call being queued now decides the slot's state. That is what made the
    " old slot STRUCT behave the way it did - a second popup_display( )
    " overwrote the first, a destroy after a display wiped it - only here it
    " is explicit, so the frontend receives one destroy and at most one
    " display per slot and needs no such rule of its own.
    DELETE mo_action->ms_next-t_system WHERE slot = slot.

  ENDMETHOD.


  METHOD slot_display.

    " A display always tears the slot down first - stated as its own action
    " rather than left to the frontend, so the list the frontend gets is the
    " complete sequence and it only has to run it.
    slot_reset( slot ).
    INSERT VALUE #( slot   = slot
                    method = `destroy` )
           INTO TABLE mo_action->ms_next-t_system.

    TRY.
        " The options carry what is specific to a slot - the popover's
        " anchor, a nested view's insert/destroy methods, the MAIN view's
        " model switch. An option the caller left alone is absent, never
        " sent as an empty value.
        DATA(li_opt) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ) ).
        set_opt( json = li_opt
                 name = `id`
                 val  = id ).
        set_opt( json = li_opt
                 name = `methodInsert`
                 val  = method_insert ).
        set_opt( json = li_opt
                 name = `methodDestroy`
                 val  = method_destroy ).
        set_opt( json = li_opt
                 name = `openById`
                 val  = open_by_id ).
        set_opt( json = li_opt
                 name = `switchDefaultModelPath`
                 val  = switch_default_model_path ).
        set_opt( json = li_opt
                 name = `switchDefaultModelAnnoUri`
                 val  = switch_default_model_anno_uri ).

        INSERT VALUE #( slot    = slot
                        method  = `display`
                        xml     = xml
                        options = li_opt->stringify( ) )
               INTO TABLE mo_action->ms_next-t_system.

      CATCH z2ui5_cx_ajson_error INTO DATA(lx_json).
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING
            val = |SLOT_DISPLAY_OPTIONS_INVALID - { lx_json->get_text( ) }|.
    ENDTRY.

    " new XML in any slot needs the model with it - recorded here rather than
    " re-derived from the response, see ty_s_next-check_view_shipped
    mo_action->ms_next-check_view_shipped = abap_true.

  ENDMETHOD.


  METHOD set_opt.

    IF val IS NOT INITIAL.
      json->set_string( iv_path = |/{ name }|
                        iv_val  = val ).
    ENDIF.

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

    DATA(lt_arg) = mo_srv_msg->get_box_arg( text              = text
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

    " a message table the formatter found nothing worth showing in
    IF lt_arg IS NOT INITIAL.
      z2ui5_if_client~follow_up_action( val   = z2ui5_if_client=>cs_event-control_global
                                        t_arg = lt_arg ).
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_if_client~message_toast_display.

    z2ui5_if_client~follow_up_action(
        val   = z2ui5_if_client=>cs_event-control_global
        t_arg = mo_srv_msg->get_toast_arg( text                     = text
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
                                           class                    = class ) ).

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

    slot_destroy( cs_slot-nest2 ).

  ENDMETHOD.


  METHOD z2ui5_if_client~nest2_view_display.

    slot_display( slot           = cs_slot-nest2
                  xml            = val
                  id             = id
                  method_insert  = method_insert
                  method_destroy = method_destroy ).

  ENDMETHOD.


  METHOD z2ui5_if_client~nest2_view_model_update.

    " deliberately EMPTY - see view_model_update. A nested view owns no model
    " anyway: it inherits the MAIN view's by UI5 model propagation, so the
    " automatic push of the root model already covers it

  ENDMETHOD.


  METHOD z2ui5_if_client~nest_view_destroy.

    slot_destroy( cs_slot-nest ).

  ENDMETHOD.


  METHOD z2ui5_if_client~nest_view_display.

    slot_display( slot           = cs_slot-nest
                  xml            = val
                  id             = id
                  method_insert  = method_insert
                  method_destroy = method_destroy ).

  ENDMETHOD.


  METHOD z2ui5_if_client~nest_view_model_update.

    " deliberately EMPTY - see nest2_view_model_update

  ENDMETHOD.


  METHOD z2ui5_if_client~popover_destroy.

    slot_destroy( cs_slot-popover ).

  ENDMETHOD.


  METHOD z2ui5_if_client~popover_display.

    slot_display( slot       = cs_slot-popover
                  xml        = xml
                  open_by_id = by_id ).

  ENDMETHOD.


  METHOD z2ui5_if_client~popover_model_update.

    " deliberately EMPTY - see view_model_update. The automatic push flags
    " the POPOVER slot too, so an open popover refreshes without this call

  ENDMETHOD.


  METHOD z2ui5_if_client~popup_destroy.

    slot_destroy( cs_slot-popup ).

  ENDMETHOD.


  METHOD z2ui5_if_client~popup_display.

    slot_display( slot = cs_slot-popup
                  xml  = val ).

  ENDMETHOD.


  METHOD z2ui5_if_client~popup_model_update.

    " deliberately EMPTY - see view_model_update. The automatic push flags
    " the POPUP slot too, so an open popup refreshes without this call

  ENDMETHOD.


  METHOD z2ui5_if_client~view_destroy.

    slot_destroy( cs_slot-main ).

  ENDMETHOD.


  METHOD z2ui5_if_client~view_display.

    slot_display( slot                          = cs_slot-main
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

    DATA(li_app) = get_if_app( ).
    IF li_app->check_sticky = val.
      RETURN.
    ENDIF.
    mo_action->ms_next-s_set-s_stateful-active = COND #( WHEN val = abap_true THEN 1 ELSE 0 ).
    li_app->check_sticky = val.

    mo_action->ms_next-s_set-s_stateful-switched = xsdbool( mo_action->ms_next-s_set-s_stateful-switched = abap_false ).

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
