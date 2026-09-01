CLASS z2ui5_cl_ui5_client DEFINITION PUBLIC FINAL.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_client.

    DATA mo_action TYPE REF TO z2ui5_cl_ui5_action.

    METHODS constructor
      IMPORTING
        action TYPE REF TO z2ui5_cl_ui5_action.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mo_srv_bind  TYPE REF TO z2ui5_cl_ui5_srv_bind.
    DATA mo_srv_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA mo_frontend  TYPE REF TO z2ui5_cl_ui5_frontend.

    METHODS nav_app_set_id
      IMPORTING
        app           TYPE REF TO z2ui5_if_app
      RETURNING
        VALUE(result) TYPE string.

    METHODS get_if_app
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_app.

ENDCLASS.


CLASS z2ui5_cl_ui5_client IMPLEMENTATION.


  METHOD constructor.

    mo_action = action.
    mo_srv_bind = NEW #( mo_action->mo_app ).
    mo_srv_event = NEW #( ).
    mo_frontend = NEW #( mo_action ).

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
        " the mode is remembered on the app ( z2ui5_cl_ui5_app_cont->mv_nav_mode )
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

      WHEN z2ui5_if_client=>cs_event-hash_set.
        " same value as the obsolete cs_event-set_push_state - one branch
        " serves both spellings
        mo_action->ms_next-s_nav-set_push_state = lv_arg.
        RETURN.

      WHEN z2ui5_if_client=>cs_event-hash_replace.
        " HashChanger#replaceHash: the same write as hash_set, minus the
        " history entry - the router's navTo( ..., true )
        mo_action->ms_next-s_nav-hash_replace = lv_arg.
        RETURN.

      WHEN z2ui5_if_client=>cs_event-hash_attach_changed.
        " app-owned hash routing: the event name registered for hash changes.
        " Empty on the wire means "no change", so an unregister (no t_arg)
        " travels as a single space - the app_state_set_active encoding. Not
        " remembered on the app: the registration dies with an app switch,
        " and an app asserts it in view_display( ), so every render carries it
        mo_action->ms_next-s_nav-set_hash_listener = COND #( WHEN lv_arg IS INITIAL
                                                             THEN ` `
                                                             ELSE lv_arg ).
        RETURN.

      WHEN z2ui5_if_client=>cs_event-set_app_state_active.
        " an empty argument list switches it ON - a single space is how an
        " app switches it off again, since an empty t_arg cannot say `false`
        mo_action->ms_next-s_nav-set_app_state_active = xsdbool( lv_arg <> ` ` ).
        " and remember it on the app, so main_end can re-assert it on the
        " next response (see z2ui5_cl_ui5_app_cont->mv_app_state_active)
        mo_action->mo_app->mv_app_state_active = mo_action->ms_next-s_nav-set_app_state_active.
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
      mo_frontend->queue_app_event( val   = val
                                    view  = view
                                    t_arg = t_arg ).
    ELSE.
      mo_frontend->queue_app_js( val ).
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
                      check_launchpad_active = mo_action->mo_handler->ms_request-s_control-check_launchpad
                      t_event_arg            = mo_action->ms_actual-t_event_arg
                      s_draft                = CORRESPONDING #( mo_action->mo_app->ms_draft )
                      check_on_navigated     = mo_action->ms_actual-check_on_navigated
                      s_config               = CORRESPONDING #( mo_action->mo_handler->ms_request-s_front )
                      s_device               = mo_action->mo_handler->ms_request-s_front-s_device
                      s_focus                = mo_action->mo_handler->ms_request-s_front-s_focus
                      s_scroll               = mo_action->mo_handler->ms_request-s_front-s_scroll
                      s_ui5                  = mo_action->mo_handler->ms_request-s_front-s_ui5
                      r_event_data           = mo_action->ms_actual-r_data
                      t_model_skipped        = mo_action->ms_actual-t_model_skipped
                      _s_nav-check_call      = xsdbool( mo_action->ms_next-o_app_call IS NOT INITIAL )
                      _s_nav-check_leave     = xsdbool( mo_action->ms_next-o_app_leave IS NOT INITIAL ) ).

    TRY.

        DATA(lo_comp) = mo_action->mo_handler->ms_request-s_front-o_comp_data.
        IF lo_comp IS NOT BOUND.
          RETURN.
        ENDIF.
        DATA(lo_params) = lo_comp->slice( `/startupParameters/` ).

        IF lo_params IS NOT BOUND.
          RETURN.
        ENDIF.
        " FLP startupParameters arrive as one ARRAY per parameter name
        " ({"foo":["bar"], ...}), and the names are the launchpad tile's own -
        " unknowable here, so no typed to_abap mapping can collect them. The
        " node table is walked directly instead: the array ELEMENT nodes are
        " the ones whose name is their array index, and `name = '1'` picks
        " each parameter's first value (the FLP convention; further array
        " entries of a multi-value parameter are deliberately dropped). The
        " element's path is `/foo/` - the parameter name between two slashes,
        " which the two shifts below strip off.
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


  METHOD z2ui5_if_client~get_event.

    result = mo_action->ms_actual-event.

  ENDMETHOD.


  METHOD z2ui5_if_client~get_event_arg.

    TRY.
        result = mo_action->ms_actual-t_event_arg[ v ].
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.


  METHOD z2ui5_if_client~get_app.

    IF id IS NOT INITIAL.
      DATA(lo_app) = z2ui5_cl_ui5_app_cont=>db_load( id ).
      result = CAST #( lo_app->mo_app ).
    ELSE.
      result = get_if_app( ).
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_if_client~message_box_display.

    mo_frontend->msg_box( text              = text
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

    mo_frontend->msg_toast( text                     = text
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

    mo_frontend->slot_destroy( z2ui5_if_client=>cs_view-nested2 ).

  ENDMETHOD.


  METHOD z2ui5_if_client~nest2_view_display.

    mo_frontend->slot_display( slot           = z2ui5_if_client=>cs_view-nested2
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

    mo_frontend->slot_destroy( z2ui5_if_client=>cs_view-nested ).

  ENDMETHOD.


  METHOD z2ui5_if_client~nest_view_display.

    mo_frontend->slot_display( slot           = z2ui5_if_client=>cs_view-nested
                               xml            = val
                               id             = id
                               method_insert  = method_insert
                               method_destroy = method_destroy ).

  ENDMETHOD.


  METHOD z2ui5_if_client~nest_view_model_update.

    " deliberately EMPTY - see nest2_view_model_update

  ENDMETHOD.


  METHOD z2ui5_if_client~popover_destroy.

    mo_frontend->slot_destroy( z2ui5_if_client=>cs_view-popover ).

  ENDMETHOD.


  METHOD z2ui5_if_client~popover_display.

    mo_frontend->slot_display( slot       = z2ui5_if_client=>cs_view-popover
                               xml        = xml
                               open_by_id = by_id ).

  ENDMETHOD.


  METHOD z2ui5_if_client~popover_model_update.

    " deliberately EMPTY - see view_model_update. The automatic push reaches
    " every open slot, so an open popover refreshes without this call

  ENDMETHOD.


  METHOD z2ui5_if_client~popup_destroy.

    mo_frontend->slot_destroy( z2ui5_if_client=>cs_view-popup ).

  ENDMETHOD.


  METHOD z2ui5_if_client~popup_display.

    mo_frontend->slot_display( slot = z2ui5_if_client=>cs_view-popup
                               xml  = val ).

  ENDMETHOD.


  METHOD z2ui5_if_client~popup_model_update.

    " deliberately EMPTY - see view_model_update. The automatic push reaches
    " every open slot, so an open popup refreshes without this call

  ENDMETHOD.


  METHOD z2ui5_if_client~view_destroy.

    mo_frontend->slot_destroy( z2ui5_if_client=>cs_view-main ).

  ENDMETHOD.


  METHOD z2ui5_if_client~view_display.

    mo_frontend->slot_display( slot                          = z2ui5_if_client=>cs_view-main
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

    DATA(li_filter) = custom_filter.

    " omit_initial wires ajson's empty filter into the slot the serializer
    " already evaluates (z2ui5_cl_ui5_srv_model->main_json_stringify), so an
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
            " NOT the vendored create_empty_filter: that one also drops a
            " table ROW whose fields are all initial, which reindexes the
            " client array against the backend table and corrupts the
            " write-back (whole-table and __delta) - see the local class
            li_omit = NEW lcl_empty_filter_keep_rows( ).
          ENDIF.
          IF li_filter IS BOUND.
            " NOT the vendored create_and_filter: its class is not
            " serializable and the combined ref ends up in the draft -
            " see the local class
            li_filter = NEW lcl_and_filter( ii_first  = li_filter
                                            ii_second = li_omit ).
          ELSE.
            li_filter = li_omit.
          ENDIF.
        CATCH cx_root.
          " a filter that cannot be built must not kill the roundtrip - the
          " model is then serialized as before (initial fields included)
          li_filter = custom_filter.
      ENDTRY.
    ENDIF.

    result = mo_srv_bind->main( val    = z2ui5_cl_ui5_util_context=>conv_get_as_data_ref( val )
                                config = VALUE #(
                                    path_only            = path
                                    custom_filter        = li_filter
                                    custom_mapper        = custom_mapper
                                    tab                  = z2ui5_cl_ui5_util_context=>conv_get_as_data_ref( tab )
                                    tab_index            = tab_index
                                    switch_default_model = switch_default_model
                                    check_json           = json ) ).

  ENDMETHOD.


  METHOD z2ui5_if_client~_bind_path.

    " delegate instead of repeating the _bind( ) call, same reason as
    " _bind_edit right below: one behaviour, so the two spellings can never
    " drift apart. Deliberately no further parameters - see the interface.
    result = z2ui5_if_client~_bind( val  = val
                                    path = abap_true ).

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

    " arg is folded into t_arg HERE, not in the event service: get_event( )
    " then sees exactly the table a caller would have written by hand, so the
    " two spellings cannot produce different wires. IS SUPPLIED rather than
    " IS NOT INITIAL - an argument passed as empty on purpose is a filled
    " slot, and dropping it would shift every following position.
    DATA(lt_arg) = t_arg.
    IF arg IS SUPPLIED.
      APPEND CONV string( arg ) TO lt_arg.
    ENDIF.

    result = mo_srv_event->get_event( val   = val
                                      t_arg = lt_arg
                                      s_cnt = s_ctrl ).

  ENDMETHOD.


  METHOD z2ui5_if_client~_event_client.

    result = mo_srv_event->get_event_client( val   = val
                                             view  = view
                                             t_arg = t_arg ).

  ENDMETHOD.


  METHOD z2ui5_if_client~hash_set.

    " same field the cs_event-hash_set branch of follow_up_action writes -
    " the typed method just skips the string-argument detour
    mo_action->ms_next-s_nav-set_push_state = val.

  ENDMETHOD.


  METHOD z2ui5_if_client~hash_replace.

    " HashChanger#replaceHash - hash_set minus the history entry
    mo_action->ms_next-s_nav-hash_replace = val.

  ENDMETHOD.


  METHOD z2ui5_if_client~set_push_state.

    " obsolete spelling - delegates to keep exactly one write path
    z2ui5_if_client~hash_set( val ).

  ENDMETHOD.


  METHOD z2ui5_if_client~app_state_set_active.

    " same field the cs_event-app_state_set_active branch of follow_up_action
    " writes - only that path needs the single-space encoding to squeeze
    " `false` through a string argument; a typed abap_bool does not
    mo_action->ms_next-s_nav-set_app_state_active = val.
    " and remember it on the app, so main_end can re-assert it on the next
    " response (see z2ui5_cl_ui5_app_cont->mv_app_state_active)
    mo_action->mo_app->mv_app_state_active = val.

  ENDMETHOD.


  METHOD z2ui5_if_client~set_app_state_active.

    " obsolete spelling - delegates to keep exactly one write path
    z2ui5_if_client~app_state_set_active( val ).

  ENDMETHOD.


  METHOD z2ui5_if_client~app_state_get_href.

    " The absolute link to the CURRENT app state, composed the way the
    " frontend's Router.hrefFor builds it - from the browser's OWN location
    " (origin/pathname/search ride with the requests and are session-merged)
    " plus this roundtrip's draft id. Inside the FLP the shell owns the front
    " of the hash - keeping that shell part is what makes the link land in
    " this app instead of on the launchpad home page. The split itself lives
    " in ONE backend place, next to its app-part half (see
    " z2ui5_cl_ui5_handler=>hash_get_shell_part, which mirrors
    " Router.splitHash) - never re-implement it here.
    DATA(ls_front) = mo_action->mo_handler->ms_request-s_front.
    DATA(lv_state) = |z2ui5-xapp-state={ mo_action->mo_app->ms_draft-id }|.

    DATA(lv_shell) = z2ui5_cl_ui5_handler=>hash_get_shell_part( ls_front-hash ).

    result = COND #( WHEN lv_shell IS INITIAL
                     THEN |{ ls_front-origin }{ ls_front-pathname }{ ls_front-search }#/{ lv_state }|
                     ELSE |{ ls_front-origin }{ ls_front-pathname }{ ls_front-search }#{ lv_shell }&/{ lv_state }| ).

  ENDMETHOD.


  METHOD z2ui5_if_client~set_session_stateful.

    IF mo_action->mo_app->mv_check_sticky = val.
      RETURN.
    ENDIF.
    mo_action->ms_next-s_stateful-active = COND #( WHEN val = abap_true THEN 1 ELSE 0 ).
    mo_action->mo_app->mv_check_sticky = val.

    " a TOGGLE on purpose, not `= abap_true`: switched says "the state at the
    " END of this roundtrip differs from the state at its start". Two calls
    " in one roundtrip (on, then off - the early RETURN above lets only real
    " changes through) cancel out to abap_false, and
    " z2ui5_cl_ui5_http_handler=>set_response then skips its
    " set_session_stateful call entirely - while `active` always carries the
    " final state for the roundtrips where switched stays abap_true
    mo_action->ms_next-s_stateful-switched = xsdbool( mo_action->ms_next-s_stateful-switched = abap_false ).

  ENDMETHOD.


  METHOD z2ui5_if_client~check_app_prev_stack.

    result = xsdbool( mo_action->mo_app->ms_draft-id_prev_app_stack IS NOT INITIAL ).

  ENDMETHOD.


  METHOD z2ui5_if_client~check_on_init.

    result = xsdbool( mo_action->mo_app->mv_check_initialized = abap_false ).

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

    result = CAST z2ui5_if_app( mo_action->mo_app->mo_app ).

  ENDMETHOD.

ENDCLASS.
