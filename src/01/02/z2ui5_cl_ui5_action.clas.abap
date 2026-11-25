CLASS z2ui5_cl_ui5_action DEFINITION PUBLIC FINAL.

  PUBLIC SECTION.
    DATA mo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA mo_app     TYPE REF TO z2ui5_cl_ui5_app_cont.

    DATA ms_actual  TYPE z2ui5_if_ui5_types=>ty_s_actual.
    DATA ms_next    TYPE z2ui5_if_ui5_types=>ty_s_next.
    " the sticky state the REQUEST started in - what set_session_stateful
    " compares the end state against. It is a property of the request, not
    " of an app container: a nav hop builds a fresh container (mv_check_sticky
    " abap_false) while the ICF session is still whatever it was, so the
    " value is taken from the container the request began with and carried
    " through prepare_app_stack like the switch itself
    DATA mv_check_sticky_start TYPE abap_bool.
    " the draft this action continues, as factory_by_frontend read it -
    " what an unchanged timer tick answers with instead of a new one
    " (z2ui5_cl_ui5_handler=>main_end_reuse). Empty on every other factory:
    " a hop, a start and a sticky session never reuse a draft
    DATA ms_loaded TYPE z2ui5_cl_ui5_app_cont=>ty_s_buffer.

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

    " the requested app class as it may be quoted in an error text - one
    " strip for every place that reflects the client value (here and in
    " z2ui5_cl_ui5_handler=>request_context_info), so the two cannot drift
    CLASS-METHODS app_start_safe
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
    METHODS prepare_app_stack
      IMPORTING
        val           TYPE z2ui5_if_ui5_types=>ty_s_next-o_app_leave
        check_call    TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_action.

  PRIVATE SECTION.

    " whether a draft id is this app's own or one below it on the app stack
    " (see factory_stack_call)
    METHODS check_draft_on_stack
      IMPORTING
        id            TYPE string
      RETURNING
        VALUE(result) TYPE abap_bool.

    " the app instance for a first start - the client-named class, checked
    " to be an app before it is created (the reasoning is on the method)
    METHODS app_create
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_app.

    "! the queued actions of this roundtrip that show a message - a
    "! MESSAGE_TOAST or MESSAGE_BOX call, as message_toast_display( ) and
    "! message_box_display( ) queue it or as follow_up_action( cs_event-
    "! control_global ) does - in the order they were queued
    METHODS messages_queued
      RETURNING
        VALUE(result) TYPE z2ui5_if_ui5_types=>ty_t_queued_action.

    " set by prepare_app_stack on the action it builds: whether the target
    " came out of a persisted draft. Read by factory_stack_leave right
    " after, which used to ask the database a third time for the same fact
    DATA mv_stack_loaded TYPE abap_bool.
ENDCLASS.


CLASS z2ui5_cl_ui5_action IMPLEMENTATION.

  METHOD constructor.

    mo_handler = val.
    mo_app = NEW #( ).

  ENDMETHOD.

  METHOD factory_by_frontend.

    result = NEW #( mo_handler ).

    IF mo_handler->mo_action->mo_app->mo_app IS BOUND.
      result->mo_app = mo_handler->mo_action->mo_app.
    ELSE.
      result->mo_app = z2ui5_cl_ui5_app_cont=>db_load( mo_handler->ms_request-s_front-id ).
      " the draft's sticky flag holds only in the stateful session it was
      " saved in - see mv_session_sticky on the handler
      IF mo_handler->mv_session_sticky = abap_false.
        CLEAR result->mo_app->mv_check_sticky.
      ENDIF.
      result->ms_loaded = z2ui5_cl_ui5_app_cont=>db_load_buffered( mo_handler->ms_request-s_front-id ).
    ENDIF.

    result->mo_app->ms_draft-id      = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    result->mo_app->ms_draft-id_prev = mo_handler->ms_request-s_front-id.
    result->mv_check_sticky_start    = result->mo_app->mv_check_sticky.

    " a request that carries a MODEL node names its path; one whose tree IS
    " the model (the shape the tests hand in) names none and is read from
    " the root - only a tree that is empty either way has nothing to apply
    IF mo_handler->ms_request-model_path IS NOT INITIAL
        OR mo_handler->ms_request-o_model->is_empty( ) = abap_false.
      " what the delta could not convert travels on the action, not on the
      " app: it describes THIS roundtrip, and the app object is what gets
      " serialized into the draft
      result->ms_actual-t_model_skipped = result->mo_app->model_json_parse(
                                              io_model = mo_handler->ms_request-o_model
                                              iv_path  = mo_handler->ms_request-model_path ).
    ENDIF.

    result->ms_actual-event       = mo_handler->ms_request-s_front-event.
    result->ms_actual-t_event_arg = mo_handler->ms_request-s_front-t_event_arg.

  ENDMETHOD.

  METHOD factory_first_start.

    result = NEW #( mo_handler ).

    " An app start is an app switch as well when the page already runs one -
    " Back/Forward restoring a route, a hash edited by hand - and the
    " frontend no longer takes the standalone slots down by itself (see
    " prepare_app_stack). On a page that has just loaded the two teardowns
    " find nothing; an app that opens a popup in its first main( ) replaces
    " the teardown through slot_reset( ).
    DATA(lo_frontend) = NEW z2ui5_cl_ui5_frontend( result ).
    lo_frontend->slot_destroy( z2ui5_if_client=>cs_view-popup ).
    lo_frontend->slot_destroy( z2ui5_if_client=>cs_view-popover ).

    IF mo_handler->ms_request-s_control-app_start_draft IS NOT INITIAL.
      TRY.

          result->mo_app = z2ui5_cl_ui5_app_cont=>db_load( mo_handler->ms_request-s_control-app_start_draft ).
          " the draft's sticky flag holds only in the stateful session
          " it was saved in - see mv_session_sticky on the handler
          IF mo_handler->mv_session_sticky = abap_false.
            CLEAR result->mo_app->mv_check_sticky.
          ENDIF.
          result->mv_check_sticky_start = result->mo_app->mv_check_sticky.
          result->ms_actual-check_on_navigated = abap_true.
          " only an app-state bookmark (#/z2ui5-xapp-state=<id>) turns
          " the app-state hash on; a ROUTE restore (#/app/<CLASS>/<id>,
          " the router's own Back/Forward and reload) carries a draft as
          " well but is not that opt-in - flagged as one, every later
          " response re-asserted setAppStateActive, and an app that
          " switched routing off got an app-state hash it never asked for
          IF mo_handler->ms_request-s_control-check_app_state = abap_true.
            result->ms_next-s_nav-set_app_state_active = abap_true.
            " on the app as well, not only on this request: ms_next is
            " cleared per roundtrip, so a flag set only here survived one
            " response and the next event wiped the app-state hash the
            " bookmark was made of (see mv_app_state_active)
            result->mo_app->mv_app_state_active = abap_true.
          ENDIF.
          " the restored app is a ROOT of this session: the stack and the
          " caller it had in the session the bookmark was made in are gone
          " with that session. Clearing only the stack left get_app_prev( )
          " following a hop-time draft of the dead session - a raw
          " NO_DRAFT_ENTRY 500 once it had expired
          result->mo_app->ms_draft-id_prev_app_stack = ``.
          result->mo_app->ms_draft-id_prev_app       = ``.
          " normalize the chain like factory_by_frontend: id_prev must
          " point at the draft this restore was loaded from, not at
          " whatever id was serialized in a previous session
          result->mo_app->ms_draft-id_prev = mo_handler->ms_request-s_control-app_start_draft.
          result->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
          " the restored draft is what the bookmark, the shared link or the
          " browser history entry names - pruning this session's chain
          " (draft_keep_per_chain) must stop there, not delete it
          result->mo_app->draft_keep( mo_handler->ms_request-s_control-app_start_draft ).
          RETURN.
        CATCH cx_root INTO DATA(lx_restore).
          " A draft that is there, is the user's and still could not be
          " restored is a broken restore, not an expired bookmark: an
          " attribute the view reads came back unparseable
          " (APP_STATE_RESTORE_ERROR, raised loudly by design in
          " z2ui5_cl_ui5_srv_model), a type the draft names is gone, the app
          " class changed its layout. Swallowed here it read as "expired" -
          " no attribute name, no source position, and the monitor saw a
          " successful roundtrip. The question is asked only on the failure
          " path, so a restore that works costs no extra read
          " Raised as the framework's own cx_no_check with the cause as
          " previous: this method declares nothing, and a static or dynamic
          " check class re-raised as it is would reach the top-level handler
          " as CX_SY_NO_HANDLER on a kernel
          IF z2ui5_cl_ui5_srv_draft=>get_instance( )->check_exists(
                 mo_handler->ms_request-s_control-app_start_draft ) = abap_true.
            RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
              EXPORTING
                val      = |APP_STATE_RESTORE_ERROR - the bookmarked draft { mo_handler->ms_request-s_control-app_start_draft } exists but could not be restored|
                previous = lx_restore.
          ENDIF.
          " expired, cleaned up or another user's draft - fall through to a
          " fresh app start, but tell the user why the saved state is gone.
          " There is no client object yet at this point in the factory,
          " so the toast is queued directly through the action builder
          " message_toast_display( ) delegates to.
          lo_frontend->msg_toast(
              `Bookmarked app state expired or could not be restored - starting with a fresh app` ).
      ENDTRY.
    ENDIF.

    result->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).

    " a bookmark without ?app_start= whose draft is gone names no app to
    " start fresh - it lands where a request without one lands, on the
    " start page (factory_system_startup), with the toast above
    " ... or, under the test harness, the instance its test prepared (see
    " mo_app_start on the handler)
    DATA li_app TYPE REF TO z2ui5_if_app.
    IF mo_handler->mo_app_start IS BOUND.
      li_app = mo_handler->mo_app_start.
    ELSEIF mo_handler->ms_request-s_control-app_start IS INITIAL.
      li_app = z2ui5_cl_ui5_app_start=>factory( ).
    ELSE.
      li_app = app_create( ).
    ENDIF.
    result->mo_app->mo_app = li_app.
    li_app->id_draft = result->mo_app->ms_draft-id.

    result->ms_actual-check_on_navigated = abap_true.

  ENDMETHOD.

  METHOD app_create.

    DATA(lv_app_start) = mo_handler->ms_request-s_control-app_start.

    " asked BEFORE the CREATE OBJECT, not answered by it. The name is
    " client-controlled (URL parameter, hash route, launchpad startup
    " parameter) and the only thing CREATE OBJECT ... TYPE (name) checks is
    " that the class fits the typed reference - it checks that on the loaded
    " class, so whether the class pool of an arbitrary class on the system
    " is loaded and its class constructor run before the refusal is kernel
    " behaviour the framework should not have to lean on. The descriptor
    " lookup loads and instantiates nothing. It is also the honest message:
    " a class that exists but is no app used to be reported as "does not
    " exist in the system". Either way the raise goes up through the CATCH
    " in z2ui5_cl_ui5_handler=>main( ), which annotates it with the request
    " context, to the top-level catch in z2ui5_cl_ui5_http_handler=>_main( ),
    " which turns the chain into a 500 whose body carries the text for the
    " frontend to display.
    " The interface is named through a typed reference, never a literal: a
    " namespace rename rewrites the reference but left the literal behind,
    " and a renamed installation then refused every app it was asked to
    " start (.github/scripts/rename-literal-gate.mjs)
    DATA li_app_type TYPE REF TO z2ui5_if_app.
    DATA(lv_app_intf) = z2ui5_cl_ui5_util_context=>rtti_get_ref_type_name( li_app_type ).
    IF z2ui5_cl_ui5_util_context=>rtti_check_class_impl_intf( class = lv_app_start
                                                              intf  = lv_app_intf ) = abap_false.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING
          val = |The app '{ app_start_safe( lv_app_start ) }' | &&
                |does not exist in the system or does not implement { to_lower( lv_app_intf ) }.|.
    ENDIF.

    TRY.
        CREATE OBJECT result TYPE (lv_app_start).

      CATCH cx_root INTO DATA(x).
        " the class exists and is an app, and still could not be created -
        " abstract, CREATE PRIVATE, a constructor that raised. It used to be
        " reported as "does not exist" too, which sent whoever read the 500
        " to check a class name that was right all along
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING
            val      = |APP_START_ERROR - the app '{ app_start_safe( lv_app_start ) }' could not be started.|
            previous = x.
    ENDTRY.

  ENDMETHOD.

  METHOD factory_stack_call.

    result = prepare_app_stack( val        = ms_next-o_app_call
                                check_call = abap_true ).
    result->mo_app->ms_draft-id_prev_app_stack = mo_app->ms_draft-id.

    " Forward app navigation is ROUTER intent only when hash routing is
    " active for the app being navigated to (its own mode, or the caller's
    " inherited one - see prepare_app_stack). Without routing the frontend
    " router reads none of these fields, so a plain nav_app_call sends no
    " NAV section at all.
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

    " the leave target was never persisted (a fresh app instance) - it takes
    " over the current app's position in the stack. Whether it was is what
    " prepare_app_stack just found out: its load fails closed for exactly
    " the cases check_exists( ) answered false for (no row, a foreign
    " owner), so the SELECT that used to sit here was the third read of the
    " same key per hop
    IF result->mv_stack_loaded = abap_false.
      result->mo_app->ms_draft-id_prev_app_stack = mo_app->ms_draft-id_prev_app_stack.
      RETURN.
    ENDIF.

    " a known app is returned to: prepare_app_stack restored it from its
    " hop-time draft, and that draft carries the target's OWN stack position
    " (ms_draft is serialized with the container). A pop used to stand here
    " that read the CURRENT app's ancestor row and wrote ITS stack over the
    " target's - the same value for a leave to the direct caller, and the
    " wrong one for a leave two levels up (nav_app_leave( client->get_app(
    " id ) ) from a wizard back to the list): the list then showed a back
    " button that led to its own older draft. Nothing is left to do, and the
    " purged-ancestor case the pop had to guard against went with it

    " ... except to say which way the screen moves: this is the one hop that
    " goes BACK, so the target's view_display( ) plays the page being left
    " out in reverse (the fresh-instance case above returned already - it
    " replaces the current app, a forward move)
    result->ms_actual-check_nav_back = abap_true.

  ENDMETHOD.

  METHOD app_start_safe.

    " app_start is client-controlled and reflected into the error text:
    " stripped to class-name-safe characters, so a real typo still shows for
    " diagnostics while a crafted value cannot smuggle markup/script into
    " the response body
    result = z2ui5_cl_ui5_util_context=>c_filter_chars(
        val     = val
        allowed = `ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_/` ).

  ENDMETHOD.

  METHOD factory_system_startup.

    result = NEW #( mo_handler ).

    result->mo_app->ms_draft-id          = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    result->ms_actual-check_on_navigated = abap_true.
    result->mo_app->mo_app               = z2ui5_cl_ui5_app_start=>factory( ).

    CAST z2ui5_if_app( result->mo_app->mo_app )->id_draft = result->mo_app->ms_draft-id.

  ENDMETHOD.

  METHOD messages_queued.

    LOOP AT ms_next-s_action-t_custom REFERENCE INTO DATA(lr_action).
      TRY.
          " ["MESSAGE_TOAST","show",...] as the client's own methods queue
          " it, ["CONTROL_GLOBAL","MESSAGE_BOX",...] as follow_up_action
          DATA(lv_name) = lr_action->o_json->get_string( `/1` ).
          IF lv_name = z2ui5_if_client=>cs_event-control_global.
            lv_name = lr_action->o_json->get_string( `/2` ).
          ENDIF.
        CATCH cx_root.
          CONTINUE.
      ENDTRY.
      IF lv_name = z2ui5_if_ui5_types=>cs_global_target-message_toast
          OR lv_name = z2ui5_if_ui5_types=>cs_global_target-message_box.
        INSERT lr_action->* INTO TABLE result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD check_draft_on_stack.

    IF id = mo_app->ms_draft-id.
      result = abap_true.
      RETURN.
    ENDIF.

    " bounded like any walk of a chain that a broken draft could close
    DATA(lv_next) = mo_app->ms_draft-id_prev_app_stack.
    DATA(lv_count) = 0.
    WHILE lv_next IS NOT INITIAL AND lv_count < 50.
      IF lv_next = id.
        result = abap_true.
        RETURN.
      ENDIF.
      lv_count = lv_count + 1.
      TRY.
          " the id chain only: a db_load( ) parsed every ancestor's whole
          " state (asXML, attribute load, buffer insert) to read one field
          lv_next = z2ui5_cl_ui5_srv_draft=>get_instance( )->read_info( lv_next )-id_prev_app_stack.
        CATCH cx_root.
          " an expired link ends the stack the way Back would find it
          RETURN.
      ENDTRY.
    ENDWHILE.

  ENDMETHOD.

  METHOD prepare_app_stack.

    " The leaving app's declarative timer (client->timer_set) ends with the
    " hop: the draft saved here says it no longer runs, so the roundtrip that
    " brings the app back arms it again (z2ui5_cl_ui5_handler=>
    " main_end_timer), and the response of the app navigated to stops it
    " unless that app declares one of its own (check_timer_end, carried
    " across every hop of the request)
    DATA(lv_timer_end) = xsdbool( ms_next-check_timer_end = abap_true
                                  OR mo_app->ms_timer_sent IS NOT INITIAL ).
    CLEAR mo_app->ms_timer_sent.

    mo_app->db_save( ).

    " A CALLED instance whose draft is the caller's own or one below it on
    " the stack - nav_app_call( me ), or a callee calling its caller back
    " instead of leaving - becomes a NEW stack entry. Reusing its id made
    " that draft's stack point at itself or round in a circle: the row was
    " overwritten in place, and Back and check_app_prev_stack( ) never
    " reached the root again. After the save on purpose: for a call of
    " itself the instance IS the caller's, and the save writes the caller's
    " id back onto it
    IF check_call = abap_true AND val->id_draft IS NOT INITIAL
        AND check_draft_on_stack( val->id_draft ) = abap_true.
      CLEAR val->id_draft.
    ENDIF.

    " val is always the ms_next-o_app_leave / ms_next-o_app_call reference
    " itself (see factory_stack_leave / factory_stack_call), so an already
    " assigned draft id is kept as is. An id minted HERE has no draft behind
    " it: the load below used to run for it anyway - a guaranteed miss that
    " ended in a NO_DRAFT_ENTRY exception on every nav_app_call of a fresh
    " app, caught two lines further down
    DATA(lv_minted) = abap_false.
    IF val->id_draft IS INITIAL.
      val->id_draft = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
      lv_minted = abap_true.
    ENDIF.

    result = NEW #( mo_handler ).
    IF lv_minted = abap_true.
      result->mo_app->mo_app = val.
    ELSE.
      " a persisted target is restored against the live instance. The
      " fallback keeps an id whose draft is gone (purged by cleanup( ), a
      " session that outlived it) running as a fresh instance, as before
      TRY.
          result->mo_app = z2ui5_cl_ui5_app_cont=>db_load_by_app( val ).
          result->mv_stack_loaded = abap_true.
        CATCH cx_root.
          result->mo_app->mo_app = val.
      ENDTRY.
    ENDIF.

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
    " for the whole app stack (see z2ui5_cl_ui5_app_cont->mv_nav_mode)
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
    result->mv_check_sticky_start = mv_check_sticky_start.
    result->ms_next-check_timer_end = lv_timer_end.
    " nav_app_call( me ) puts the SAME instance into a new container: the
    " declaration belongs to the instance's screen, so it goes along (and is
    " armed again, check_on_navigated) - a declaration is otherwise the
    " container's own, restored with its draft
    IF lv_minted = abap_true AND result->mo_app->mo_app = mo_app->mo_app.
      result->mo_app->ms_timer = mo_app->ms_timer.
    ENDIF.

    " ... unless the app asked to keep its MESSAGES (nav_app_call/
    " nav_app_leave with keep_messages): a "Saved." toast or an error box
    " queued right before the hop is about the work just done, not about
    " the screen being replaced, and it is shown after the target renders -
    " the frontend runs ACTIONS last, once the views of the response are in
    " the DOM (View1._processAfterRendering). They go ahead of whatever the
    " target queues itself, in the order they were queued. Only the
    " messages: a focus, a scroll or a control call names a control of
    " the old screen. Per hop - a target that navigates on keeps them only
    " if it asks again
    IF ms_next-keep_messages = abap_true.
      result->ms_next-s_action-t_custom = messages_queued( ).
    ENDIF.

    result->ms_actual-event  = ms_next-next_event.
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
    " the new app renders. The backend says so, on every hop: it is the one
    " side that knows a hop happened - another instance of the SAME class
    " looks like the same app from the browser. Queued before the called app
    " runs its main( ), so its own popup_display( ) still replaces the
    " teardown through slot_reset( ). Both directions pass through here (call
    " and leave alike), so this is the ONE place that decides it.
    " Until protocol 3 the frontend took the two slots down itself whenever
    " a response named another class, and this method covered only the hop
    " it could not see.
    DATA(lo_frontend) = NEW z2ui5_cl_ui5_frontend( result ).
    lo_frontend->slot_destroy( z2ui5_if_client=>cs_view-popup ).
    lo_frontend->slot_destroy( z2ui5_if_client=>cs_view-popover ).

  ENDMETHOD.

ENDCLASS.
