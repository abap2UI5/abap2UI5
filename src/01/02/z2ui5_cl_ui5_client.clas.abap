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

    " Memo of get( )'s FLP startupParameters slice. The parameters are part
    " of the parsed request, immutable for the whole roundtrip - while get( )
    " is called once per lifecycle question an app asks - so the node-table
    " walk in get( ) runs once and every later call copies the memo. The
    " _s_nav-check_call/check_leave fields of the same structure stay LIVE
    " per call on purpose: they answer for actions the app queued since.
    DATA mt_comp_params     TYPE z2ui5_if_client=>ty_t_name_value.
    DATA mv_comp_params_set TYPE abap_bool.

    METHODS nav_app_set_id
      IMPORTING
        app           TYPE REF TO z2ui5_if_app
      RETURNING
        VALUE(result) TYPE string.

    METHODS get_if_app
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_app.

    " The val (or tab) of a _bind*( ) call as the data reference the bind
    " service works on: the data itself, or a data reference TO it - REF #( ),
    " an attribute TYPE REF TO data. A reference is bound as what it points
    " to, because REF #( val ) of it would hand the model the reference
    " variable, which it refuses (NO DATA REFERENCES FOR BINDING ALLOWED).
    " One place for the four callers, so the whole family takes both forms
    " alike. Unwraps ONE level: a reference to a reference is what the
    " model refuses next, as before
    METHODS val_as_data_ref
      IMPORTING
        val           TYPE data
      RETURNING
        VALUE(result) TYPE REF TO data.

ENDCLASS.


CLASS z2ui5_cl_ui5_client IMPLEMENTATION.


  METHOD constructor.

    mo_action = action.
    mo_srv_bind = NEW #( mo_action->mo_app ).
    mo_srv_event = NEW #( ).
    mo_frontend = NEW #( mo_action ).

  ENDMETHOD.


  METHOD z2ui5_if_client~follow_up_action.

    " The five navigation branches of the CASE below configure how the
    " browser URL has to look after this roundtrip. Router derives ONE
    " outcome from all of them together, so they are collected here and
    " leave as the options of the one NAV section main_end( ) writes -
    " never as actions of their own, which would make the router run
    " several times and fight over the same hash.
    "
    " the WIRED form first: `v = client->follow_up_action( ... )` in a view
    " attribute asks for an event wire and nothing else. The navigation
    " options below are roundtrip actions; wired, they used to set their
    " ms_next fields as a side effect of BUILDING the view and hand the
    " attribute an empty string. (No unit test pins this branch: the NodeJS
    " runtime answers IS SUPPLIED with false for a RETURNING parameter, so a
    " consumed result is not detectable there - on a system it is.)
    IF result IS SUPPLIED.
      result = mo_srv_event->get_event_client( val   = val
                                               view  = view
                                               t_arg = t_arg ).
      RETURN.
    ENDIF.

    DATA(lv_arg) = VALUE string( t_arg[ 1 ] OPTIONAL ).

    CASE val.
      WHEN z2ui5_if_client=>cs_event-hash_routing.
        " the mode is remembered on the app ( z2ui5_cl_ui5_app_cont->mv_nav_mode )
        " and re-sent when the frontend may not still hold it - main_end gates
        " the re-send on the nav_mode_sent latch; an app called via
        " nav_app_call inherits it, and a draft restored later still knows how
        " it was routed
        " upper-cased at the one write point: the frontend upper-cases the
        " mode before it compares, the backend compares it as written
        " against cs_nav_mode (check_nav_app_call, the sticky main_end_save
        " branch) - `keep` used to switch routing on in the browser and
        " leave it off on the server
        lv_arg = to_upper( lv_arg ).
        IF lv_arg IS INITIAL.
          lv_arg = z2ui5_if_client=>cs_nav_mode-keep.
        ENDIF.
        mo_action->ms_next-s_nav-set_nav_routing = lv_arg.
        mo_action->mo_app->mv_nav_mode           = lv_arg.
        RETURN.

      WHEN z2ui5_if_client=>cs_event-hash_set.
        " the wire value is SET_PUSH_STATE, the name this event was renamed
        " from - see the note on cs_event
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

      WHEN z2ui5_if_client=>cs_event-app_state_set_active.
        " an empty argument list switches it ON - a single space is how an
        " app switches it off again, since an empty t_arg cannot say `false`
        mo_action->ms_next-s_nav-set_app_state_active = xsdbool( lv_arg <> ` ` ).
        " and remember it on the app, so main_end can re-assert it on the
        " next response (see z2ui5_cl_ui5_app_cont->mv_app_state_active)
        mo_action->mo_app->mv_app_state_active = mo_action->ms_next-s_nav-set_app_state_active.
        RETURN.

      WHEN z2ui5_if_client=>cs_event-start_timer
          OR z2ui5_if_client=>cs_event-stop_timer.
        " the app takes the one timer slot over itself: the declaration of
        " timer_set( ) goes, and so does the record of what was sent for it -
        " the browser's slot holds this action now, and main_end_timer must
        " neither stop it nor arm the declared one over it. Queued below as
        " ever
        CLEAR: mo_action->mo_app->ms_timer,
               mo_action->mo_app->ms_timer_sent.
    ENDCASE.

    " a frontend event travels as pure data - a JSON array built and escaped
    " entirely in ABAP. There is no code form: a raw JavaScript val is not
    " run, it arrives as an event name the frontend does not know
    mo_frontend->queue_app_event( val   = val
                                  view  = view
                                  t_arg = t_arg ).

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

    " the slice/walk below runs at most ONCE per roundtrip: the component
    " data is part of the parsed request and cannot change until the next
    " one, so the first get( ) fills the memo - including the common
    " memoized-empty case (no FLP, no parameters) - and every later call
    " only copies it
    IF mv_comp_params_set = abap_true.
      result-t_comp_params = mt_comp_params.
      RETURN.
    ENDIF.
    mv_comp_params_set = abap_true.

    TRY.

        " the request carries the data on the page load's first roundtrip;
        " every later one keeps it in the session as a string, parsed here
        " on demand - not in session_merge for a reader that may never come
        " (z2ui5_if_ui5_types=>ty_s_request-s_front-o_comp_data)
        DATA(lo_comp) = mo_action->mo_handler->ms_request-s_front-o_comp_data.
        IF lo_comp IS NOT BOUND
            AND mo_action->mo_app->ms_session-comp_data IS NOT INITIAL.
          lo_comp = z2ui5_cl_ajson=>parse( mo_action->mo_app->ms_session-comp_data ).
        ENDIF.
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
                          v = lr_comp->value ) INTO TABLE mt_comp_params.
        ENDLOOP.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    result-t_comp_params = mt_comp_params.

  ENDMETHOD.


  METHOD z2ui5_if_client~get_start_param.

    " what the seven copies of "url_param_get( s_config-search ), else
    " t_comp_params, else ..." in the apps of one installation did, once:
    " the first source that has the parameter with a value - the order is
    " the one the interface documents
    DATA(lv_name) = z2ui5_cl_ui5_util_context=>c_trim_lower( name ).
    IF lv_name IS INITIAL.
      RETURN.
    ENDIF.
    DATA(ls_get) = z2ui5_if_client~get( ).

    " 1. the URL query - url_param_get_tab unpacks sap-startup-params and
    " lower-cases the names
    result = z2ui5_cl_ui5_util_context=>url_param_get( val = lv_name
                                                       url = ls_get-s_config-search ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    " 2. the launchpad startupParameters, under the tile's own spelling
    LOOP AT ls_get-t_comp_params REFERENCE INTO DATA(lr_param).
      IF z2ui5_cl_ui5_util_context=>c_trim_lower( lr_param->n ) = lv_name
          AND lr_param->v IS NOT INITIAL.
        result = lr_param->v.
        RETURN.
      ENDIF.
    ENDLOOP.

    " 3. the query of the launchpad intent - the shell's part of the hash
    " (`#Object-action?p=v&/app-route`). A raw location hash: a bare
    " intent without the separator is all shell
    DATA(lv_shell) = z2ui5_cl_ui5_handler=>hash_get_shell_part( iv_hash            = ls_get-s_config-hash
                                                               check_bare_is_shell = abap_true ).
    IF lv_shell CS `?`.
      result = z2ui5_cl_ui5_util_context=>url_param_get( val = lv_name
                                                         url = lv_shell ).
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_if_client~get_event.

    result = mo_action->ms_actual-event.

  ENDMETHOD.


  METHOD z2ui5_if_client~get_event_arg.

    result = VALUE #( mo_action->ms_actual-t_event_arg[ v ] OPTIONAL ).

  ENDMETHOD.


  METHOD z2ui5_if_client~get_app.

    " get( )-s_draft-id is the id minted for THIS roundtrip - its draft is
    " written only when the roundtrip ends, so loading it raised
    " NO_DRAFT_ENTRY... for an id the interface lists. It names the running
    " app, which is what it answers now
    IF id IS INITIAL OR id = mo_action->mo_app->ms_draft-id.
      result = get_if_app( ).
    ELSE.
      DATA(lo_app) = z2ui5_cl_ui5_app_cont=>db_load( id ).
      result = CAST #( lo_app->mo_app ).
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_if_client~message_box_display.

    mo_frontend->msg_box( text             = text
                          type             = type
                          title            = title
                          styleclass       = styleclass
                          onclose          = onclose
                          actions          = actions
                          emphasizedaction = emphasizedaction
                          initialfocus     = initialfocus
                          details          = details
                          icon             = icon ).

  ENDMETHOD.


  METHOD z2ui5_if_client~message_toast_display.

    mo_frontend->msg_toast( text     = text
                            duration = duration
                            onclose  = onclose ).

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

    " after nav_app_set_id( ), which raises for an unbound target: a call
    " that does not happen must not replace the tag. Written on the CALLER's
    " container, which the hop saves - see mv_nav_tag there
    mo_action->mo_app->mv_nav_tag = tag.
    mo_action->ms_next-keep_messages = keep_messages.

  ENDMETHOD.


  METHOD z2ui5_if_client~nav_app_leave.

    IF app IS NOT SUPPLIED.
      TRY.
          app = z2ui5_if_client~get_app( mo_action->mo_app->ms_draft-id_prev_app_stack ).
        CATCH cx_root.
          " the caller's hop-time draft was purged by cleanup( ) while THIS
          " app stayed in use (every click refreshes this app's row, never
          " the one saved at the hop, and any cold start sweeps the old
          " rows): the leave used to raise NO_DRAFT_ENTRY out of the whole
          " roundtrip - the fatal overlay for pressing Back. There is
          " nothing to go back to any more, so the stack is dropped, the
          " user is told, and the roundtrip ends on this app the way a root
          " leave does (main_process ends a leave with nothing on the stack)
          CLEAR mo_action->mo_app->ms_draft-id_prev_app_stack.
          z2ui5_if_client~message_toast_display( `Previous app state expired - there is nothing to go back to` ).
          app = get_if_app( ).
      ENDTRY.
    ENDIF.

    mo_action->ms_next-o_app_leave = app.
    mo_action->ms_next-next_event  = event.
    mo_action->ms_next-keep_messages = keep_messages.

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


  METHOD z2ui5_if_client~popover_destroy.

    mo_frontend->slot_destroy( z2ui5_if_client=>cs_view-popover ).

  ENDMETHOD.


  METHOD z2ui5_if_client~popover_display.

    mo_frontend->slot_display( slot       = z2ui5_if_client=>cs_view-popover
                               xml        = xml
                               open_by_id = by_id ).

  ENDMETHOD.


  METHOD z2ui5_if_client~popup_destroy.

    mo_frontend->slot_destroy( z2ui5_if_client=>cs_view-popup ).

  ENDMETHOD.


  METHOD z2ui5_if_client~popup_display.

    mo_frontend->slot_display( slot = z2ui5_if_client=>cs_view-popup
                               xml  = val ).

  ENDMETHOD.


  METHOD z2ui5_if_client~view_destroy.

    mo_frontend->slot_destroy( z2ui5_if_client=>cs_view-main ).

  ENDMETHOD.


  METHOD z2ui5_if_client~view_display.

    " The way back is recognized, not asked for: a roundtrip that returned to
    " its caller through nav_app_leave( ) carries check_nav_back (see
    " z2ui5_cl_ui5_action=>factory_stack_leave), and travels as navBack. It
    " is kept apart from transition_back, the app's OWN way back between its
    " screens: the frontend plays navBack only when the page on screen
    " belongs to another app instance, transition_back always. The browser
    " Back button is the frontend's to recognize (core/Router.js).
    DATA(lv_nav_back) = mo_action->ms_actual-check_nav_back.

    " The app INSTANCE the view belongs to - what that comparison reads. An
    " app that never took the MAIN slot, a popup-as-app (the shape of every
    " built-in popup), leaves its caller's page on screen, and the return
    " from it must not animate that page away from itself. Minted only where
    " a transition is in play, so a plain display sends what it always did.
    DATA(lv_instance) = ``.
    IF transition IS NOT INITIAL OR transition_back = abap_true OR lv_nav_back = abap_true.
      lv_instance = nav_app_set_id( get_if_app( ) ).
    ENDIF.

    mo_frontend->slot_display( slot                          = z2ui5_if_client=>cs_view-main
                               xml                           = val
                               switch_default_model_path     = switch_default_model_path
                               switch_default_model_anno_uri = switch_default_model_anno_uri
                               transition                    = transition
                               transition_back               = transition_back
                               nav_back                      = lv_nav_back
                               app_instance                  = lv_instance ).

  ENDMETHOD.


  METHOD z2ui5_if_client~_bind.

    " omit_initial wires the framework's own ajson filter into the slot the
    " serializer evaluates (z2ui5_cl_ui5_srv_model->main_json_stringify), so
    " an initial field stays ABSENT from the model and the control keeps its
    " own default. No TRY around the construction: the two local classes
    " have no constructor that can raise
    DATA li_filter TYPE REF TO z2ui5_if_ajson_filter.
    IF omit_initial_paths IS NOT INITIAL.
      " scoped: only the listed columns are dropped when initial, so a
      " boolean that must send abap_false survives
      li_filter = NEW lcl_initial_paths_filter( omit_initial_paths ).
    ELSEIF omit_initial = abap_true.
      " NOT the vendored create_empty_filter: that one also drops a table
      " ROW whose fields are all initial, which reindexes the client array
      " against the backend table and corrupts the write-back (whole-table
      " and __delta) - see the local class
      li_filter = NEW lcl_empty_filter_keep_rows( ).
    ENDIF.

    " val and tab take the data or a data reference to it, like window_bind_tab( )
    result = mo_srv_bind->main( val    = val_as_data_ref( val )
                                config = VALUE #(
                                    path_only            = path
                                    custom_filter        = li_filter
                                    tab                  = val_as_data_ref( tab )
                                    tab_index            = tab_index
                                    switch_default_model = switch_default_model
                                    check_json           = json ) ).

  ENDMETHOD.


  METHOD z2ui5_if_client~window_bind_tab.

    " the table itself, or a data reference to it - see val_as_data_ref
    result = mo_srv_bind->main( val    = val_as_data_ref( val )
                                config = VALUE #( window           = nmax( val1 = window
                                                                       val2     = 1 )
                                                  window_total     = nmax( val1 = total
                                                                       val2     = 0 )
                                                  " the attribute the total is - read
                                                  " anew on every response
                                                  window_total_ref = REF #( total )
                                                  window_event     = event ) ).

  ENDMETHOD.


  METHOD val_as_data_ref.

    IF z2ui5_cl_ui5_util_context=>rtti_get_type_kind( val ) <> z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_dref.
      result = z2ui5_cl_ui5_util_context=>conv_get_as_data_ref( val ).
      RETURN.
    ENDIF.

    result ?= val.
    " fail here, with the method's name: describe_by_data_ref on an unbound
    " reference dumps in the model service, far from the _bind( ) that
    " passed it - an attribute TYPE REF TO data that no CREATE DATA has
    " filled yet is the usual way to get here
    IF result IS INITIAL.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING
          val = `BINDING_ERROR - the data reference passed to _bind( ) is initial - create the data or point the reference at an attribute before binding it`.
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_if_client~_bind_path.

    " delegate instead of repeating the _bind( ) call: one behaviour, so the
    " two spellings can never drift apart. Deliberately no further
    " parameters - see the interface.
    result = z2ui5_if_client~_bind( val  = val
                                    path = abap_true ).

  ENDMETHOD.


  METHOD z2ui5_if_client~_event.

    " arg is folded into t_arg HERE, not in the event service: get_event( )
    " then sees exactly the table a caller would have written by hand, so the
    " two spellings cannot produce different wires. IS SUPPLIED rather than
    " IS NOT INITIAL - an argument passed as empty on purpose is a filled
    " slot, and dropping it would shift every following position.
    DATA(lt_arg) = t_arg.
    IF arg IS SUPPLIED.
      INSERT CONV string( arg ) INTO TABLE lt_arg.
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


  METHOD z2ui5_if_client~app_state_set_active.

    " same field the cs_event-app_state_set_active branch of follow_up_action
    " writes - only that path needs the single-space encoding to squeeze
    " `false` through a string argument; a typed abap_bool does not
    mo_action->ms_next-s_nav-set_app_state_active = val.
    " and remember it on the app, so main_end can re-assert it on the next
    " response (see z2ui5_cl_ui5_app_cont->mv_app_state_active)
    mo_action->mo_app->mv_app_state_active = val.

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
    " the link outlives this session: pruning the chain (draft_keep_per_chain)
    " must keep the draft it names. On the app, so it is in the draft this
    " roundtrip writes - which also makes the state differ from the draft
    " the roundtrip continued, so an unchanged timer tick that hands out a
    " link still writes the draft the link names (main_end_reuse)
    mo_action->mo_app->draft_keep( mo_action->mo_app->ms_draft-id ).

    " check_bare_is_shell: s_front-hash is the RAW location hash, so a bare
    " '#So-action' (FLP intent, no app part yet) is all shell - without it
    " the composed link would be FLP-URL#/state, which the launchpad cannot
    " route back into this app
    DATA(lv_shell) = z2ui5_cl_ui5_handler=>hash_get_shell_part(
                         iv_hash             = ls_front-hash
                         check_bare_is_shell = abap_true ).

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

    " switched says "the state at the END of this roundtrip differs from the
    " state at its START", and z2ui5_cl_ui5_http_handler=>set_response calls
    " the server's set_session_stateful only then - while `active` always
    " carries the final state. Two calls in one roundtrip (on, then off)
    " cancel out to abap_false. The start state is the REQUEST's
    " (mv_check_sticky_start), not this container's: it used to be a toggle
    " guarded by the container's own mv_check_sticky, and over a nav hop the
    " called app runs in a fresh container, so app A switching on and app B
    " switching on in the same roundtrip toggled back to abap_false - the
    " session never went stateful, B was still marked sticky, its draft was
    " never saved, and the next click was a NO_DRAFT_ENTRY 500
    mo_action->ms_next-s_stateful-switched = xsdbool( val <> mo_action->mv_check_sticky_start ).

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


  METHOD z2ui5_if_client~check_nav_pending.

    " the same two references get( )-_s_nav reads, asked without building
    " the whole ty_s_get around them
    result = xsdbool( mo_action->ms_next-o_app_call IS NOT INITIAL
                   OR mo_action->ms_next-o_app_leave IS NOT INITIAL ).

  ENDMETHOD.


  METHOD z2ui5_if_client~get_nav_tag.

    " check_nav_back is the one hop that returns to an instance restored
    " from the stack (z2ui5_cl_ui5_action=>factory_stack_leave) - the only
    " roundtrip on which the container's tag answers a call of THIS app. An
    " app that is called again later arrives with check_on_navigated as
    " well, and must not read the tag of a call it made in an earlier life
    IF mo_action->ms_actual-check_nav_back = abap_true.
      result = mo_action->mo_app->mv_nav_tag.
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_if_client~check_on_nav_back.

    " the flag factory_stack_leave sets on the hop that returns to an
    " instance restored from its draft - the same question get_nav_tag( )
    " asks before it answers. A leave to a fresh instance, a call and every
    " start (route restore and app-state bookmark included) leave it unset
    result = mo_action->ms_actual-check_nav_back.

  ENDMETHOD.


  METHOD z2ui5_if_client~timer_set.

    " declared, not sent: main_end_timer of the handler decides at the end
    " of the roundtrip whether the browser needs it - see
    " z2ui5_cl_ui5_app_cont->ms_timer. An empty event or no delay is no timer
    IF event IS INITIAL OR delay_ms <= 0.
      z2ui5_if_client~timer_stop( ).
      RETURN.
    ENDIF.
    mo_action->mo_app->ms_timer = VALUE #( event    = event
                                           delay_ms = delay_ms
                                           no_busy  = no_busy ).

  ENDMETHOD.


  METHOD z2ui5_if_client~timer_stop.

    " the STOP_TIMER goes out with this response only when the browser runs
    " the declared timer (ms_timer_sent) - see main_end_timer
    CLEAR mo_action->mo_app->ms_timer.

  ENDMETHOD.


  METHOD z2ui5_if_client~_event_nav_app_leave.

    result = z2ui5_if_client~_event( z2ui5_if_ui5_types=>cs_event_nav_app_leave ).

  ENDMETHOD.


  METHOD get_if_app.

    result = CAST z2ui5_if_app( mo_action->mo_app->mo_app ).

  ENDMETHOD.

ENDCLASS.
