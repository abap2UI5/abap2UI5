CLASS z2ui5_cl_core_action DEFINITION PUBLIC FINAL.

  PUBLIC SECTION.
    DATA mo_http_post TYPE REF TO z2ui5_cl_core_handler.
    DATA mo_app       TYPE REF TO z2ui5_cl_core_app.

    DATA ms_actual    TYPE z2ui5_if_core_types=>ty_s_actual.
    DATA ms_next      TYPE z2ui5_if_core_types=>ty_s_next.

    METHODS factory_system_startup
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_core_action.

    METHODS factory_first_start
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_core_action.

    METHODS factory_by_frontend
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_core_action.

    METHODS factory_stack_leave
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_core_action.

    METHODS factory_stack_call
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_core_action.

    METHODS constructor
      IMPORTING
        val TYPE REF TO z2ui5_cl_core_handler.

  PROTECTED SECTION.
    METHODS prepare_app_stack
      IMPORTING
        val           TYPE z2ui5_if_core_types=>ty_s_next-o_app_leave
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_core_action.

  PRIVATE SECTION.
    METHODS reset_view_update_flags.
ENDCLASS.


CLASS z2ui5_cl_core_action IMPLEMENTATION.

  METHOD constructor.

    mo_http_post = val.
    mo_app = NEW #( ).

  ENDMETHOD.

  METHOD factory_by_frontend.

    result = NEW #( mo_http_post ).

    IF mo_http_post->mo_action->mo_app->mo_app IS BOUND.
      result->mo_app = mo_http_post->mo_action->mo_app.
    ELSE.
      result->mo_app = z2ui5_cl_core_app=>db_load( mo_http_post->ms_request-s_front-id ).
    ENDIF.

    result->mo_app->ms_draft-id      = z2ui5_cl_a2ui5_context=>uuid_get_c32( ).
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

              result->mo_app = z2ui5_cl_core_app=>db_load( mo_http_post->ms_request-s_control-app_start_draft ).
              result->ms_actual-check_on_navigated = abap_true.
              result->ms_next-s_set-set_app_state_active = abap_true.
              result->mo_app->ms_draft-id_prev_app_stack = ``.
              " normalize the chain like factory_by_frontend: id_prev must
              " point at the draft this restore was loaded from, not at
              " whatever id was serialized in a previous session
              result->mo_app->ms_draft-id_prev = mo_http_post->ms_request-s_control-app_start_draft.
              result->mo_app->ms_draft-id = z2ui5_cl_a2ui5_context=>uuid_get_c32( ).
              RETURN.
            CATCH cx_root.
              " expired or invalid bookmark draft - fall through to a fresh
              " app start, but tell the user why the saved state is gone.
              " There is no client object yet at this point in the factory,
              " so the toast is queued as the follow-up action that
              " message_toast_display( ) would have produced.
              INSERT NEW z2ui5_cl_core_srv_event( )->get_event_client_json(
                             val   = z2ui5_if_client=>cs_event-message_toast
                             t_arg = VALUE #(
                                 ( `Bookmarked app state expired or could not be restored - starting with a fresh app` ) ) )
                     INTO TABLE result->ms_next-s_set-s_follow_up_action-custom_js.
          ENDTRY.
        ENDIF.

        result->mo_app->ms_draft-id = z2ui5_cl_a2ui5_context=>uuid_get_c32( ).

        DATA li_app TYPE REF TO z2ui5_if_app.
        CREATE OBJECT li_app TYPE (mo_http_post->ms_request-s_control-app_start).
        result->mo_app->mo_app = li_app.
        li_app->id_draft = result->mo_app->ms_draft-id.

        result->ms_actual-check_on_navigated = abap_true.

      CATCH cx_root INTO DATA(x).
        " a wrong/mistyped app name in the URL lands here (CREATE OBJECT of a
        " non-existent class). Just raise with a readable text - the single
        " top-level catch in z2ui5_cl_http_handler=>_main( ) turns it into a
        " 500 whose body carries this message for the frontend to display.
        " app_start is client-controlled, so strip it down to class-name-safe
        " characters before reflecting it into the error text - a real typo
        " still shows for diagnostics, but a crafted value cannot smuggle
        " markup/script into the response body.
        DATA(lv_app_name) = mo_http_post->ms_request-s_control-app_start.
        REPLACE ALL OCCURRENCES OF REGEX `[^A-Za-z0-9_/]` IN lv_app_name WITH `` ##REGEX_POSIX.
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING
            val      = |The app '{ lv_app_name }' does not exist in the system.|
            previous = x.
    ENDTRY.

  ENDMETHOD.

  METHOD factory_stack_call.

    result = prepare_app_stack( ms_next-o_app_call ).
    result->mo_app->ms_draft-id_prev_app_stack = mo_app->ms_draft-id.

    " forward app navigation - when hash routing is active the frontend pushes a
    " new route history entry for the called app, so the browser Back button
    " returns to the calling app (see View1._updateBrowserHistory)
    result->ms_next-s_set-check_nav_app_call = abap_true.

    " prepare_app_stack( ) just saved the calling app under a NEW draft id -
    " one that includes everything the user changed on the client since the
    " caller last rendered (two-way bound switches, checkboxes, input; they
    " arrive with the event that triggered this navigation). The caller's
    " history entry, however, still carries the draft of that last render, so
    " Back would restore it WITHOUT those changes. Hand the fresh draft to the
    " frontend, which repoints the caller's entry at it before pushing the
    " called app's route. Only the first hop of a request sets this: in a chain
    " A -> B -> C the entry to repoint is A's, the app the user came from.
    IF result->ms_next-s_set-nav_app_call_prev_id IS INITIAL.
      result->ms_next-s_set-nav_app_call_prev_app =
          z2ui5_cl_a2ui5_context=>rtti_get_classname_by_ref( mo_app->mo_app ).
      result->ms_next-s_set-nav_app_call_prev_id  = mo_app->ms_draft-id.
    ENDIF.

  ENDMETHOD.

  METHOD factory_stack_leave.

    result = prepare_app_stack( ms_next-o_app_leave ).

    " a leave is a back-navigation - never inherit a call-hop's route push
    " from the same request ( A -> nav_app_call B -> B leaves again ), else
    " the frontend pushes a new history entry for what is a step back
    CLEAR: result->ms_next-s_set-check_nav_app_call,
           result->ms_next-s_set-nav_app_call_prev_app,
           result->ms_next-s_set-nav_app_call_prev_id.

    DATA(lo_draft) = NEW z2ui5_cl_core_srv_draft( ).

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

    result->mo_app->ms_draft-id          = z2ui5_cl_a2ui5_context=>uuid_get_c32( ).
    result->ms_actual-check_on_navigated = abap_true.
    result->mo_app->mo_app               = z2ui5_cl_app_startup=>factory( ).

    CAST z2ui5_if_app( result->mo_app->mo_app )->id_draft = result->mo_app->ms_draft-id.

  ENDMETHOD.

  METHOD reset_view_update_flags.

    " these three are every slot that owns a model: MAIN holds the root model,
    " popup and popover their own. The nested slots are inserted into the MAIN
    " control tree and inherit its model, so they have no flag to reset
    CLEAR ms_next-s_set-s_view-check_update_model.
    CLEAR ms_next-s_set-s_popup-check_update_model.
    CLEAR ms_next-s_set-s_popover-check_update_model.

  ENDMETHOD.

  METHOD prepare_app_stack.

    mo_app->db_save( ).

    " val is always the ms_next-o_app_leave / ms_next-o_app_call reference
    " itself (see factory_stack_leave / factory_stack_call), so an already
    " assigned draft id is kept as is
    IF val->id_draft IS INITIAL.
      val->id_draft = z2ui5_cl_a2ui5_context=>uuid_get_c32( ).
    ENDIF.

    result = NEW #( mo_http_post ).
    TRY.
        result->mo_app = z2ui5_cl_core_app=>db_load_by_app( val ).
      CATCH cx_root.
        result->mo_app->mo_app = val.
    ENDTRY.

    " routing is inherited by the app being navigated to, unless it already
    " chose a mode of its own - so enabling it once in the entry app is enough
    " for the whole app stack (see z2ui5_cl_core_app=>mv_nav_mode)
    IF result->mo_app->mv_nav_mode IS INITIAL.
      result->mo_app->mv_nav_mode = mo_app->mv_nav_mode.
    ENDIF.

    result->mo_app->ms_draft-id          = val->id_draft.

    result->mo_app->ms_draft-id_prev     = mo_app->ms_draft-id.
    result->mo_app->ms_draft-id_prev_app = mo_app->ms_draft-id.
    result->ms_actual-check_on_navigated = abap_true.
    result->ms_next-s_set                = ms_next-s_set.

    result->reset_view_update_flags( ).

    IF ms_next-next_event IS NOT INITIAL.
      result->ms_actual-event = ms_next-next_event.
    ELSEIF lines( ms_next-s_set-s_follow_up_action-custom_js ) > 0.
      " backward compatibility: derive the next event from a legacy
      " follow_up_action( _event( ) ) snippet ( deprecated mechanism )
      DATA(lv_action) = ms_next-s_set-s_follow_up_action-custom_js[ 1 ].
      SPLIT lv_action AT `.eB(['` INTO DATA(lv_dummy)
            result->ms_actual-event.
      SPLIT result->ms_actual-event AT `']` INTO result->ms_actual-event lv_dummy.
    ENDIF.
    result->ms_actual-r_data = ms_next-r_data.

    " when navigating between apps ( both nav_app_call and nav_app_leave ),
    " start the next app with a clean frontend state - follow-up actions
    " queued by the previous app, messages included, must not leak into the
    " next one.
    CLEAR result->ms_next-s_set-s_follow_up_action.

    " always destroy an open popup/popover on navigation, so an app never has
    " to close them explicitly before nav_app_call / nav_app_leave. If the app
    " that is navigated to renders one itself, its popup_display( ) /
    " popover_display( ) overwrites this destroy request again ( the frontend
    " processes CHECK_DESTROY before the new XML ). Destroying when nothing is
    " open is a no-op.
    result->ms_next-s_set-s_popup   = VALUE #( check_destroy = abap_true ).
    result->ms_next-s_set-s_popover = VALUE #( check_destroy = abap_true ).

  ENDMETHOD.

ENDCLASS.
