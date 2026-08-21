CLASS z2ui5_cl_ui5_action DEFINITION PUBLIC FINAL.

  PUBLIC SECTION.
    DATA mo_http_post TYPE REF TO z2ui5_cl_ui5_handler.
    DATA mo_app       TYPE REF TO z2ui5_cl_ui5_app_cont.

    DATA ms_actual    TYPE z2ui5_if_ui5_types=>ty_s_actual.
    DATA ms_next      TYPE z2ui5_if_ui5_types=>ty_s_next.

    METHODS factory_system_startup
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_action.

    METHODS factory_first_start
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_action.

    METHODS factory_by_frontend
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_action.

    METHODS factory_stack_leave
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_action.

    METHODS factory_stack_call
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_action.

    METHODS constructor
      IMPORTING
        val TYPE REF TO z2ui5_cl_ui5_handler.

  PROTECTED SECTION.
    METHODS prepare_app_stack
      IMPORTING
        val           TYPE z2ui5_if_ui5_types=>ty_s_next-o_app_leave
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_action.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_ui5_action IMPLEMENTATION.

  METHOD constructor.

    mo_http_post = val.
    mo_app = NEW #( ).

  ENDMETHOD.

  METHOD factory_by_frontend.

    result = NEW #( mo_http_post ).

    IF mo_http_post->mo_action->mo_app->mo_app IS BOUND.
      result->mo_app = mo_http_post->mo_action->mo_app.
    ELSE.
      result->mo_app = z2ui5_cl_ui5_app_cont=>db_load( mo_http_post->ms_request-s_front-id ).
    ENDIF.

    result->mo_app->ms_draft-id      = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    result->mo_app->ms_draft-id_prev = mo_http_post->ms_request-s_front-id.

    IF mo_http_post->ms_request-o_model->is_empty( ) = abap_false.
      result->mo_app->model_json_parse( mo_http_post->ms_request-o_model ).
    ENDIF.

    result->ms_actual-event       = mo_http_post->ms_request-s_front-event.
    result->ms_actual-t_event_arg = mo_http_post->ms_request-s_front-t_event_arg.

  ENDMETHOD.

  METHOD factory_first_start.

    TRY.
        result = NEW #( mo_http_post ).

        IF mo_http_post->ms_request-s_control-app_start_draft IS NOT INITIAL.
          TRY.

              result->mo_app = z2ui5_cl_ui5_app_cont=>db_load( mo_http_post->ms_request-s_control-app_start_draft ).
              result->ms_actual-check_on_navigated = abap_true.
              result->ms_next-s_nav-set_app_state_active = abap_true.
              result->mo_app->ms_draft-id_prev_app_stack = ``.
              " normalize the chain like factory_by_frontend: id_prev must
              " point at the draft this restore was loaded from, not at
              " whatever id was serialized in a previous session
              result->mo_app->ms_draft-id_prev = mo_http_post->ms_request-s_control-app_start_draft.
              result->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
              RETURN.
            CATCH cx_root.
              " expired or invalid bookmark draft - fall through to a fresh
              " app start, but tell the user why the saved state is gone.
              " There is no client object yet at this point in the factory,
              " so the toast is queued directly through the action builder
              " message_toast_display( ) delegates to.
              NEW z2ui5_cl_ui5_frontend( result )->msg_toast(
                  `Bookmarked app state expired or could not be restored - starting with a fresh app` ).
          ENDTRY.
        ENDIF.

        result->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).

        DATA li_app TYPE REF TO z2ui5_if_app.
        CREATE OBJECT li_app TYPE (mo_http_post->ms_request-s_control-app_start).
        result->mo_app->mo_app = li_app.
        li_app->id_draft = result->mo_app->ms_draft-id.

        result->ms_actual-check_on_navigated = abap_true.

      CATCH cx_root INTO DATA(x).
        " a wrong/mistyped app name in the URL lands here (CREATE OBJECT of a
        " non-existent class). Just raise with a readable text - the single
        " top-level catch in z2ui5_cl_ui5_http_handler=>_main( ) turns it into a
        " 500 whose body carries this message for the frontend to display.
        " app_start is client-controlled, so strip it down to class-name-safe
        " characters before reflecting it into the error text - a real typo
        " still shows for diagnostics, but a crafted value cannot smuggle
        " markup/script into the response body.
        DATA(lv_app_name) = mo_http_post->ms_request-s_control-app_start.
        REPLACE ALL OCCURRENCES OF REGEX `[^A-Za-z0-9_/]` IN lv_app_name WITH `` ##REGEX_POSIX.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING
            val      = |The app '{ lv_app_name }' does not exist in the system.|
            previous = x.
    ENDTRY.

  ENDMETHOD.

  METHOD factory_stack_call.

    result = prepare_app_stack( ms_next-o_app_call ).
    result->mo_app->ms_draft-id_prev_app_stack = mo_app->ms_draft-id.

    " Forward app navigation is ROUTER intent only when hash routing is
    " active for the app being navigated to (its own mode, or the caller's
    " inherited one - see prepare_app_stack). Without routing the frontend
    " router reads none of these fields, so a plain nav_app_call sends no
    " ROUTER action at all.
    IF result->mo_app->mv_nav_mode = z2ui5_if_client=>cs_nav_mode-keep
        OR result->mo_app->mv_nav_mode = z2ui5_if_client=>cs_nav_mode-fresh.
      " the frontend pushes a new route history entry for the called app, so
      " the browser Back button returns to the calling app (Router.sync)
      result->ms_next-s_nav-check_nav_app_call = abap_true.

      " prepare_app_stack( ) just saved the calling app under a NEW draft id -
      " one that includes everything the user changed on the client since the
      " caller last rendered (bound switches, checkboxes, input; they
      " arrive with the event that triggered this navigation). The caller's
      " history entry, however, still carries the draft of that last render,
      " so Back would restore it WITHOUT those changes. Hand the fresh draft
      " to the frontend, which repoints the caller's entry at it before
      " pushing the called app's route. Only the first hop of a request sets
      " this: in a chain A -> B -> C the entry to repoint is A's, the app the
      " user came from.
      IF result->ms_next-s_nav-nav_app_call_prev_id IS INITIAL.
        result->ms_next-s_nav-nav_app_call_prev_app =
            z2ui5_cl_ui5_util_context=>rtti_get_classname_by_ref( mo_app->mo_app ).
        result->ms_next-s_nav-nav_app_call_prev_id  = mo_app->ms_draft-id.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD factory_stack_leave.

    result = prepare_app_stack( ms_next-o_app_leave ).

    " a leave is a back-navigation - never inherit a call-hop's route push
    " from the same request ( A -> nav_app_call B -> B leaves again ), else
    " the frontend pushes a new history entry for what is a step back
    CLEAR: result->ms_next-s_nav-check_nav_app_call,
           result->ms_next-s_nav-nav_app_call_prev_app,
           result->ms_next-s_nav-nav_app_call_prev_id.

    DATA(lo_draft) = NEW z2ui5_cl_ui5_srv_draft( ).

    " the leave target was never persisted (a fresh app instance) - it takes
    " over the current app's position in the stack
    IF lo_draft->check_exists( ms_next-o_app_leave->id_draft ) = abap_false.
      result->mo_app->ms_draft-id_prev_app_stack = mo_app->ms_draft-id_prev_app_stack.
      RETURN.
    ENDIF.

    " a known app is returned to: pop one level off the stack. Guard the
    " ancestor stack draft with check_exists too - in a long-lived session the
    " ancestor may have been purged by cleanup( ) while the leave target still
    " exists, and read_info would raise NO_DRAFT_ENTRY and break back-navigation
    IF mo_app->ms_draft-id_prev_app_stack IS NOT INITIAL
        AND lo_draft->check_exists( mo_app->ms_draft-id_prev_app_stack ) = abap_true.
      DATA(ls_draft) = lo_draft->read_info( mo_app->ms_draft-id_prev_app_stack ).
      result->mo_app->ms_draft-id_prev_app_stack = ls_draft-id_prev_app_stack.
    ENDIF.

  ENDMETHOD.

  METHOD factory_system_startup.

    result = NEW #( mo_http_post ).

    result->mo_app->ms_draft-id          = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    result->ms_actual-check_on_navigated = abap_true.
    result->mo_app->mo_app               = z2ui5_cl_ui5_app_start=>factory( ).

    CAST z2ui5_if_app( result->mo_app->mo_app )->id_draft = result->mo_app->ms_draft-id.

  ENDMETHOD.

  METHOD prepare_app_stack.

    mo_app->db_save( ).

    " val is always the ms_next-o_app_leave / ms_next-o_app_call reference
    " itself (see factory_stack_leave / factory_stack_call), so an already
    " assigned draft id is kept as is
    IF val->id_draft IS INITIAL.
      val->id_draft = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    ENDIF.

    result = NEW #( mo_http_post ).
    TRY.
        result->mo_app = z2ui5_cl_ui5_app_cont=>db_load_by_app( val ).
      CATCH cx_root.
        result->mo_app->mo_app = val.
    ENDTRY.

    " The browser told us about itself once, for this PAGE session - the
    " freshest copy always sits on the app running right now, so it is
    " copied UNCONDITIONALLY: a loaded draft's own session may predate a
    " rotation/resize the current app already absorbed (the frontend will
    " not re-send an unchanged value). nav_mode_sent rides along harmlessly
    " - the hop sets check_on_navigated, so main_end re-sends the mode and
    " overwrites it anyway.
    result->mo_app->ms_session = mo_app->ms_session.

    " routing is inherited by the app being navigated to, unless it already
    " chose a mode of its own - so enabling it once in the entry app is enough
    " for the whole app stack (see z2ui5_cl_ui5_app=>mv_nav_mode)
    IF result->mo_app->mv_nav_mode IS INITIAL.
      result->mo_app->mv_nav_mode = mo_app->mv_nav_mode.
    ENDIF.

    result->mo_app->ms_draft-id          = val->id_draft.

    result->mo_app->ms_draft-id_prev     = mo_app->ms_draft-id.
    result->mo_app->ms_draft-id_prev_app = mo_app->ms_draft-id.
    result->ms_actual-check_on_navigated = abap_true.
    " Everything the leaving app queued for the frontend goes with it - it
    " describes a screen that is being replaced, so NONE of ms_next-s_action
    " and ms_next-t_action_front carries over; the called app starts with an
    " empty queue by construction (a fresh action instance). What DOES carry
    " over is the navigation intent and the stateful switch: the routing mode
    " belongs to the app being navigated to, and the nav_app_call_prev_*
    " guard ( only the FIRST hop of a request records the caller ) can only
    " hold if the earlier hop's value is still here.
    result->ms_next-s_nav      = ms_next-s_nav.
    " ... except the explicit routing-mode request: that one belongs to the
    " app that queued it. main_end recomputes the mode to send from the
    " CALLED app's mv_nav_mode (check_on_navigated forces the re-send), so a
    " caller that set its own mode in the same roundtrip as the hop must not
    " leak it into the called app's response
    CLEAR result->ms_next-s_nav-set_nav_routing.
    result->ms_next-s_stateful = ms_next-s_stateful.

    IF ms_next-next_event IS NOT INITIAL.
      result->ms_actual-event = ms_next-next_event.
    ELSE.
      " backward compatibility: derive the next event from a legacy
      " follow_up_action( _event( ) ) snippet ( deprecated mechanism ). Only
      " a raw-JS entry can carry one, and it is not necessarily the FIRST
      " queued action - a toast or box queued before it sits in the same
      " table - so take the first entry that looks like the snippet.
      LOOP AT ms_next-s_action-t_custom REFERENCE INTO DATA(lr_action) "#EC CI_SORTSEQ
           WHERE js IS NOT INITIAL.
        IF lr_action->js NS `.eB(['`.
          CONTINUE.
        ENDIF.
        SPLIT lr_action->js AT `.eB(['` INTO DATA(lv_dummy)
              result->ms_actual-event.
        SPLIT result->ms_actual-event AT `']` INTO result->ms_actual-event lv_dummy.
        EXIT.
      ENDLOOP.
    ENDIF.
    result->ms_actual-r_data = ms_next-r_data.

    " The leaving app's DESTROYS carry over: a view_destroy( ) before a
    " nav_app_call states an intent about the NEXT screen too - without it
    " the old view would survive a switch to an app that renders no MAIN
    " view of its own (a popup-as-app). Its DISPLAYS do not: they describe
    " the screen being replaced. The called app's own displays still win
    " over a carried destroy through slot_reset( ).
    result->ms_next-t_action_front = VALUE #(
        FOR ls_front IN ms_next-t_action_front
        WHERE ( method = z2ui5_if_ui5_types=>cs_slot_action-destroy )
        ( ls_front ) ).

    " The two standalone slots (POPUP/POPOVER) die on every app switch - they
    " live OUTSIDE the MAIN control tree, so they do not fall with the page
    " the new app renders. The FRONTEND does that implicitly whenever the
    " response's APP differs from the one before (View1), so no action has
    " to travel for it. The one switch the frontend cannot see is a hop to
    " ANOTHER INSTANCE OF THE SAME CLASS - only then the teardown is queued
    " here, before the called app runs its main( ), so its own
    " popup_display( ) still replaces the destroy through slot_reset( ).
    " Both directions pass through here (call and leave alike), so this is
    " the ONE place that decides it - a back-navigation must not queue a
    " teardown of its own on top, or every cross-class Back would carry two
    " destroy actions for slots the frontend had already torn down.
    IF mo_app->mo_app IS BOUND
        AND z2ui5_cl_ui5_util_context=>rtti_get_classname_by_ref( val )
          = z2ui5_cl_ui5_util_context=>rtti_get_classname_by_ref( mo_app->mo_app ).
      DELETE result->ms_next-t_action_front
             WHERE slot = z2ui5_if_client=>cs_view-popup
                OR slot = z2ui5_if_client=>cs_view-popover.
      INSERT VALUE #( slot   = z2ui5_if_client=>cs_view-popup
                      method = z2ui5_if_ui5_types=>cs_slot_action-destroy )
             INTO TABLE result->ms_next-t_action_front.
      INSERT VALUE #( slot   = z2ui5_if_client=>cs_view-popover
                      method = z2ui5_if_ui5_types=>cs_slot_action-destroy )
             INTO TABLE result->ms_next-t_action_front.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
