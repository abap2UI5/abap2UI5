CLASS ltcl_test_app DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mv_value TYPE string ##NEEDED.
ENDCLASS.

CLASS ltcl_test_app IMPLEMENTATION.
  METHOD z2ui5_if_app~main.
  ENDMETHOD.
ENDCLASS.


CLASS ltcl_test_app2 DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
ENDCLASS.

CLASS ltcl_test_app2 IMPLEMENTATION.
  METHOD z2ui5_if_app~main.
  ENDMETHOD.
ENDCLASS.


CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_instantiation      FOR TESTING RAISING cx_static_check.
    METHODS test_system_startup     FOR TESTING RAISING cx_static_check.
    METHODS test_first_start        FOR TESTING RAISING cx_static_check.
    METHODS test_first_start_error  FOR TESTING RAISING cx_static_check.
    METHODS test_first_start_not_an_app FOR TESTING RAISING cx_static_check.
    METHODS test_first_start_draft_gone FOR TESTING RAISING cx_static_check.
    METHODS test_app_start_safe      FOR TESTING RAISING cx_static_check.
    METHODS test_factory_by_frontend FOR TESTING RAISING cx_static_check.
    METHODS test_stack_call         FOR TESTING RAISING cx_static_check.
    METHODS test_stack_call_cross_class FOR TESTING RAISING cx_static_check.
    METHODS test_stack_leave        FOR TESTING RAISING cx_static_check.
    METHODS test_stack_leave_cross_class FOR TESTING RAISING cx_static_check.
    METHODS test_stack_leave_fresh_target FOR TESTING RAISING cx_static_check.
    METHODS test_stack_leave_own_stack FOR TESTING RAISING cx_static_check.
    METHODS test_first_start_stateless FOR TESTING RAISING cx_static_check.
    METHODS test_first_start_route_state FOR TESTING RAISING cx_static_check.
    METHODS test_nav_mode_inherited FOR TESTING RAISING cx_static_check.
    METHODS test_nav_mode_own_wins  FOR TESTING RAISING cx_static_check.
    METHODS test_hop_clears_routing_req FOR TESTING RAISING cx_static_check.
    METHODS test_stateful_across_hop FOR TESTING RAISING cx_static_check.
    METHODS test_stateful_cancels_out FOR TESTING RAISING cx_static_check.
    METHODS test_stateful_start_sticky FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS z2ui5_cl_ui5_action DEFINITION LOCAL FRIENDS ltcl_test.

CLASS ltcl_test IMPLEMENTATION.

  METHOD test_instantiation.

    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    lo_http = NEW #( val = `` ).

    lo_action = NEW #( val = lo_http ).

    cl_abap_unit_assert=>assert_bound( lo_action ).
    cl_abap_unit_assert=>assert_bound( lo_action->mo_handler ).
    cl_abap_unit_assert=>assert_bound( lo_action->mo_app ).

  ENDMETHOD.

  METHOD test_system_startup.
    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.

    lo_http = NEW #( val = `` ).

    lo_action = NEW #( val = lo_http ).


    lo_result = lo_action->factory_system_startup( ).

    cl_abap_unit_assert=>assert_bound( lo_result ).
    cl_abap_unit_assert=>assert_bound( lo_result->mo_app->mo_app ).
    cl_abap_unit_assert=>assert_not_initial( lo_result->mo_app->ms_draft-id ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_result->ms_actual-check_on_navigated ).

  ENDMETHOD.

  METHOD test_first_start.
    DATA lv_payload TYPE string.
    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.

    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":"?app_start=Z2UI5_CL_UI5_APP_HI_WORLD"}}}`.

    lo_http = NEW #( val = lv_payload ).
    lo_http->ms_request = lo_http->request_json_to_abap( lv_payload ).


    lo_action = NEW #( val = lo_http ).

    lo_result = lo_action->factory_first_start( ).

    cl_abap_unit_assert=>assert_bound( lo_result->mo_app->mo_app ).
    cl_abap_unit_assert=>assert_not_initial( lo_result->mo_app->ms_draft-id ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_result->ms_actual-check_on_navigated ).

  ENDMETHOD.

  METHOD test_app_start_safe.

    " class-name-safe characters survive, everything else - markup, quotes,
    " blanks - is stripped, so the value can be quoted in an error body
    cl_abap_unit_assert=>assert_equals(
      exp = `Z2UI5_CL_UI5_APP_HI_WORLD`
      act = z2ui5_cl_ui5_action=>app_start_safe( `Z2UI5_CL_UI5_APP_HI_WORLD` ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = `/ns/zcl_appscriptalert1/script`
      act = z2ui5_cl_ui5_action=>app_start_safe( `/ns/zcl_app<script>alert(1)</script>` ) ).
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_action=>app_start_safe( `` ) ).

  ENDMETHOD.

  METHOD test_first_start_draft_gone.

    DATA lv_payload TYPE string.
    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.

    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":"?app_start=Z2UI5_CL_UI5_APP_HI_WORLD"}}}`.

    lo_http = NEW #( val = lv_payload ).
    lo_http->ms_request = lo_http->request_json_to_abap( lv_payload ).
    lo_http->ms_request-s_control-app_start_draft = `THIS_DRAFT_DOES_NOT_EXIST`.

    lo_action = NEW #( val = lo_http ).

    lo_result = lo_action->factory_first_start( ).

    " the expired bookmark draft must not block the fresh app start...
    cl_abap_unit_assert=>assert_bound( lo_result->mo_app->mo_app ).
    " ...and the user is told why the saved state is gone, as the follow-up
    " action message_toast_display( ) would have queued
    cl_abap_unit_assert=>assert_equals(
        exp = 1
        act = lines( lo_result->ms_next-s_action-t_custom ) ).
    cl_abap_unit_assert=>assert_char_cp(
        exp = `["MESSAGE_TOAST","show","Bookmarked app state expired*`
        act = lo_result->ms_next-s_action-t_custom[ 1 ]-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_first_start_error.

    DATA lv_payload TYPE string.
    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":"?app_start=NONEXISTENT_CLASS"}}}`.

    lo_http = NEW #( val = lv_payload ).
    lo_http->ms_request = lo_http->request_json_to_abap( lv_payload ).


    lo_action = NEW #( val = lo_http ).

    TRY.
        lo_action->factory_first_start( ).
        cl_abap_unit_assert=>fail( `Expected exception for nonexistent class` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx.

        cl_abap_unit_assert=>assert_true( xsdbool( lx->get_text( ) CS `NONEXISTENT_CLASS` ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_first_start_not_an_app.

    " a class that exists but does not implement z2ui5_if_app is refused
    " from its descriptor, before CREATE OBJECT - and the message says so
    " rather than claiming the class does not exist
    DATA lv_payload TYPE string.
    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":"?app_start=Z2UI5_CL_UI5_UTIL_CONTEXT"}}}`.

    lo_http = NEW #( val = lv_payload ).
    lo_http->ms_request = lo_http->request_json_to_abap( lv_payload ).
    lo_action = NEW #( val = lo_http ).

    TRY.
        lo_action->factory_first_start( ).
        cl_abap_unit_assert=>fail( `Expected exception for a class that is not an app` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx.
        cl_abap_unit_assert=>assert_true( xsdbool( lx->get_text( ) CS `Z2UI5_CL_UI5_UTIL_CONTEXT` ) ).
        cl_abap_unit_assert=>assert_true( xsdbool( lx->get_text( ) CS `does not implement z2ui5_if_app` ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_factory_by_frontend.
    DATA lv_payload TYPE string.
    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.

    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":""}}}`.

    lo_http = NEW #( val = lv_payload ).
    lo_http->ms_request = lo_http->request_json_to_abap( lv_payload ).


    lo_action = NEW #( val = lo_http ).
    lo_action->mo_app->mo_app = NEW ltcl_test_app( ).
    lo_action->mo_app->ms_draft-id = `OLD_DRAFT_ID`.
    lo_http->mo_action = lo_action.

    lo_http->ms_request-s_front-id = `OLD_DRAFT_ID`.
    lo_http->ms_request-s_front-event = `MY_EVENT`.


    lo_result = lo_action->factory_by_frontend( ).

    cl_abap_unit_assert=>assert_bound( lo_result->mo_app->mo_app ).
    cl_abap_unit_assert=>assert_not_initial( lo_result->mo_app->ms_draft-id ).
    cl_abap_unit_assert=>assert_equals( exp = `OLD_DRAFT_ID`
                                        act = lo_result->mo_app->ms_draft-id_prev ).
    cl_abap_unit_assert=>assert_equals( exp = `MY_EVENT`
                                        act = lo_result->ms_actual-event ).

  ENDMETHOD.

  METHOD test_stack_call.
    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_chained TYPE REF TO z2ui5_cl_ui5_action.

    lo_http = NEW #( val = `` ).

    lo_action = NEW #( val = lo_http ).
    lo_action->mo_app->mo_app = NEW ltcl_test_app( ).
    lo_action->mo_app->ms_draft-id = `CURRENT_DRAFT`.


    " routing active for the caller - the called app inherits the mode, and
    " only then does the ROUTER intent travel at all
    lo_action->mo_app->mv_nav_mode = z2ui5_if_client=>cs_nav_mode-keep.

    lo_action->ms_next-o_app_call = NEW ltcl_test_app( ).

    " frontend actions queued by the calling app - messages travel as
    " follow-up actions too and must not leak into the newly called app...
    INSERT VALUE #( o_json = z2ui5_cl_ajson=>parse( `["SOME_ACTION"]` ) ) INTO TABLE lo_action->ms_next-s_action-t_custom.
    INSERT VALUE #( o_json = z2ui5_cl_ajson=>parse( `["SOME_SYSTEM_ACTION"]` ) ) INTO TABLE lo_action->ms_next-s_action-t_system.


    lo_result = lo_action->factory_stack_call( ).

    cl_abap_unit_assert=>assert_bound( lo_result ).
    cl_abap_unit_assert=>assert_equals( exp = `CURRENT_DRAFT`
                                        act = lo_result->mo_app->ms_draft-id_prev_app_stack ).

    " everything the calling app queued is gone. The popup/popover teardown
    " is queued ONLY for this hop to ANOTHER INSTANCE OF THE SAME CLASS -
    " the frontend cannot see that switch, every cross-class switch tears
    " the standalone slots down implicitly (View1). Queued BEFORE the app
    " runs, so a popup_display( ) of its own lands after it and wins
    cl_abap_unit_assert=>assert_initial( lo_result->ms_next-s_action-t_custom ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_result->ms_next-t_action_front ) ).
    cl_abap_unit_assert=>assert_equals( exp = `POPUP|destroy`
                                        act = |{ lo_result->ms_next-t_action_front[ 1 ]-slot }\|| &&
                                              |{ lo_result->ms_next-t_action_front[ 1 ]-method }| ).
    cl_abap_unit_assert=>assert_equals( exp = `POPOVER|destroy`
                                        act = |{ lo_result->ms_next-t_action_front[ 2 ]-slot }\|| &&
                                              |{ lo_result->ms_next-t_action_front[ 2 ]-method }| ).

    " the frontend is told to push a route entry for the called app, and where
    " the CALLING app was just saved - it repoints the caller's history entry at
    " that draft, so Back restores the state the user left it in, not the one it
    " was last rendered with
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_result->ms_next-s_nav-check_nav_app_call ).
    cl_abap_unit_assert=>assert_equals( exp = `CURRENT_DRAFT`
                                        act = lo_result->ms_next-s_nav-nav_app_call_prev_id ).
    cl_abap_unit_assert=>assert_not_initial( lo_result->ms_next-s_nav-nav_app_call_prev_app ).

    " a chained call ( A -> B -> C ) keeps the FIRST caller - that is the entry
    " the browser is standing on, i.e. the app the user navigated away from
    lo_result->ms_next-o_app_call  = NEW ltcl_test_app( ).
    lo_result->mo_app->ms_draft-id = `SECOND_DRAFT`.

    lo_chained = lo_result->factory_stack_call( ).

    cl_abap_unit_assert=>assert_equals( exp = `CURRENT_DRAFT`
                                        act = lo_chained->ms_next-s_nav-nav_app_call_prev_id ).

  ENDMETHOD.

  METHOD test_nav_mode_inherited.
    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_called TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_own TYPE REF TO z2ui5_cl_ui5_action.

    " an app enables routing once ( check_on_init ); every app it navigates to
    " inherits the mode, so a whole app stack is routed after a single opt-in
    lo_http = NEW #( val = `` ).

    lo_action = NEW #( val = lo_http ).
    lo_action->mo_app->mo_app       = NEW ltcl_test_app( ).
    lo_action->mo_app->ms_draft-id  = `CURRENT_DRAFT`.
    lo_action->mo_app->mv_nav_mode  = z2ui5_if_client=>cs_nav_mode-keep.
    lo_action->ms_next-o_app_call   = NEW ltcl_test_app( ).

    lo_called = lo_action->factory_stack_call( ).

    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_client=>cs_nav_mode-keep
                                        act = lo_called->mo_app->mv_nav_mode ).

    " an app that never enabled routing passes nothing on - the called app
    " stays unrouted, so the opt-in really is an opt-in
    lo_own = NEW #( val = lo_http ).
    lo_own->mo_app->mo_app      = NEW ltcl_test_app( ).
    lo_own->mo_app->ms_draft-id = `PLAIN_DRAFT`.
    lo_own->ms_next-o_app_call  = NEW ltcl_test_app( ).

    lo_called = lo_own->factory_stack_call( ).

    cl_abap_unit_assert=>assert_initial( lo_called->mo_app->mv_nav_mode ).

  ENDMETHOD.

  METHOD test_stateful_across_hop.
    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_called TYPE REF TO z2ui5_cl_ui5_action.

    " app A switches the session stateful and calls B in the same roundtrip,
    " and B (the "stateful app" template) switches it on as well. The end
    " state differs from the start state, so the response must carry the
    " switch - B runs in a FRESH container, and a per-container toggle used
    " to flip back to abap_false here (then B was sticky without a stateful
    " session: no draft saved, next click NO_DRAFT_ENTRY)
    lo_http = NEW #( val = `` ).
    lo_action = NEW #( val = lo_http ).
    lo_action->mo_app->mo_app      = NEW ltcl_test_app( ).
    lo_action->mo_app->ms_draft-id = `CURRENT_DRAFT`.

    NEW z2ui5_cl_ui5_client( action = lo_action )->z2ui5_if_client~set_session_stateful( abap_true ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_action->ms_next-s_stateful-switched ).

    lo_action->ms_next-o_app_call = NEW ltcl_test_app( ).
    lo_called = lo_action->factory_stack_call( ).

    NEW z2ui5_cl_ui5_client( action = lo_called )->z2ui5_if_client~set_session_stateful( abap_true ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_called->ms_next-s_stateful-switched ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lo_called->ms_next-s_stateful-active ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_called->mo_app->mv_check_sticky ).

  ENDMETHOD.

  METHOD test_stateful_cancels_out.
    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_client TYPE REF TO z2ui5_cl_ui5_client.

    " on, then off in one roundtrip: the end state equals the start state,
    " so nothing is switched and the server call is skipped
    lo_http = NEW #( val = `` ).
    lo_action = NEW #( val = lo_http ).
    lo_action->mo_app->mo_app = NEW ltcl_test_app( ).
    lo_client = NEW #( action = lo_action ).

    lo_client->z2ui5_if_client~set_session_stateful( abap_true ).
    lo_client->z2ui5_if_client~set_session_stateful( abap_false ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lo_action->ms_next-s_stateful-switched ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = lo_action->ms_next-s_stateful-active ).

  ENDMETHOD.

  METHOD test_stateful_start_sticky.
    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_client TYPE REF TO z2ui5_cl_ui5_client.

    " a request that began in a stateful session (the sticky handler's
    " container): switching off is a change, switching back on is not
    lo_http = NEW #( val = `` ).
    lo_action = NEW #( val = lo_http ).
    lo_action->mo_app->mo_app          = NEW ltcl_test_app( ).
    lo_action->mo_app->mv_check_sticky = abap_true.
    lo_action->mv_check_sticky_start   = abap_true.
    lo_client = NEW #( action = lo_action ).

    lo_client->z2ui5_if_client~set_session_stateful( abap_false ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_action->ms_next-s_stateful-switched ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = lo_action->ms_next-s_stateful-active ).

    lo_client->z2ui5_if_client~set_session_stateful( abap_true ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lo_action->ms_next-s_stateful-switched ).

  ENDMETHOD.

  METHOD test_nav_mode_own_wins.

    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_target TYPE REF TO ltcl_test_app.
    DATA lo_target_core TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_called TYPE REF TO z2ui5_cl_ui5_action.

    " the mode is only INHERITED where the called app has none of its own
    " (prepare_app_stack) - an app that already chose a mode keeps it, so a
    " routed caller cannot silently re-route an app that opted for FRESH
    lo_target = NEW #( ).
    lo_target_core = NEW #( ).
    lo_target_core->mo_app = lo_target.
    lo_target_core->ms_draft-id = `NAV_MODE_OWN_TARGET`.
    lo_target_core->mv_nav_mode = z2ui5_if_client=>cs_nav_mode-fresh.
    lo_target_core->db_save( ).

    lo_http = NEW #( val = `` ).
    lo_action = NEW #( val = lo_http ).
    lo_action->mo_app->mo_app      = NEW ltcl_test_app( ).
    lo_action->mo_app->ms_draft-id = `NAV_MODE_OWN_CALLER`.
    lo_action->mo_app->mv_nav_mode = z2ui5_if_client=>cs_nav_mode-keep.
    lo_action->ms_next-o_app_call  = lo_target.

    lo_called = lo_action->factory_stack_call( ).

    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_client=>cs_nav_mode-fresh
                                        act = lo_called->mo_app->mv_nav_mode ).

  ENDMETHOD.

  METHOD test_hop_clears_routing_req.

    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_called TYPE REF TO z2ui5_cl_ui5_action.

    " a caller that sets its own routing mode in the same roundtrip as the
    " hop must not leak the explicit set_nav_routing request into the called
    " app's response - main_end recomputes the mode to send from the CALLED
    " app's mv_nav_mode (prepare_app_stack CLEARs exactly this one field) ...
    lo_http = NEW #( val = `` ).
    lo_action = NEW #( val = lo_http ).
    lo_action->mo_app->mo_app      = NEW ltcl_test_app( ).
    lo_action->mo_app->ms_draft-id = `ROUTING_REQ_DRAFT`.

    lo_action->ms_next-s_nav-set_nav_routing = z2ui5_if_client=>cs_nav_mode-keep.
    lo_action->ms_next-s_nav-set_push_state  = `/caller-state`.
    lo_action->ms_next-o_app_call            = NEW ltcl_test_app( ).

    lo_called = lo_action->factory_stack_call( ).

    cl_abap_unit_assert=>assert_initial( lo_called->ms_next-s_nav-set_nav_routing ).

    " ... while the REST of the nav intent does carry over with the hop
    cl_abap_unit_assert=>assert_equals( exp = `/caller-state`
                                        act = lo_called->ms_next-s_nav-set_push_state ).

  ENDMETHOD.

  METHOD test_stack_call_cross_class.

    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.

    lo_http = NEW #( val = `` ).
    lo_action = NEW #( val = lo_http ).
    lo_action->mo_app->mo_app = NEW ltcl_test_app( ).
    lo_action->mo_app->ms_draft-id = `CURRENT_DRAFT`.

    " the leaving app tears its own view down and navigates to a DIFFERENT
    " class - the destroy must survive the hop (the called app may render
    " no MAIN view of its own), the display must not, and no popup/popover
    " teardown is queued (the frontend sees the class switch and tears the
    " standalone slots down implicitly)
    lo_action->ms_next-t_action_front = VALUE #(
        ( slot = z2ui5_if_client=>cs_view-main method = z2ui5_if_ui5_types=>cs_slot_action-destroy )
        ( slot   = z2ui5_if_client=>cs_view-nested
          method = z2ui5_if_ui5_types=>cs_slot_action-display
          xml    = `<Nest/>` ) ).
    lo_action->ms_next-o_app_call = NEW ltcl_test_app2( ).

    lo_result = lo_action->factory_stack_call( ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_result->ms_next-t_action_front ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MAIN|destroy`
                                        act = |{ lo_result->ms_next-t_action_front[ 1 ]-slot }\|| &&
                                              |{ lo_result->ms_next-t_action_front[ 1 ]-method }| ).

    " no routing mode anywhere - a plain nav carries no ROUTER intent
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lo_result->ms_next-s_nav-check_nav_app_call ).

  ENDMETHOD.

  METHOD test_stack_leave.
    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.

    lo_http = NEW #( val = `` ).

    lo_action = NEW #( val = lo_http ).
    lo_action->mo_app->mo_app = NEW ltcl_test_app( ).
    lo_action->mo_app->ms_draft-id = `CURRENT_DRAFT`.


    lo_action->ms_next-o_app_leave = NEW ltcl_test_app( ).

    " frontend actions queued by the leaving app - messages travel as
    " follow-up actions too and must not leak into the app that is
    " navigated back to...
    INSERT VALUE #( o_json = z2ui5_cl_ajson=>parse( `["SOME_ACTION"]` ) ) INTO TABLE lo_action->ms_next-s_action-t_custom.
    INSERT VALUE #( o_json = z2ui5_cl_ajson=>parse( `["SOME_SYSTEM_ACTION"]` ) ) INTO TABLE lo_action->ms_next-s_action-t_system.


    lo_result = lo_action->factory_stack_leave( ).

    cl_abap_unit_assert=>assert_bound( lo_result ).

    " leave behaves like call
    cl_abap_unit_assert=>assert_initial( lo_result->ms_next-s_action-t_custom ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_result->ms_next-t_action_front ) ).
    cl_abap_unit_assert=>assert_equals( exp = `POPUP|destroy`
                                        act = |{ lo_result->ms_next-t_action_front[ 1 ]-slot }\|| &&
                                              |{ lo_result->ms_next-t_action_front[ 1 ]-method }| ).
    cl_abap_unit_assert=>assert_equals( exp = `POPOVER|destroy`
                                        act = |{ lo_result->ms_next-t_action_front[ 2 ]-slot }\|| &&
                                              |{ lo_result->ms_next-t_action_front[ 2 ]-method }| ).

  ENDMETHOD.

  METHOD test_stack_leave_cross_class.

    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.

    lo_http = NEW #( val = `` ).

    lo_action = NEW #( val = lo_http ).
    lo_action->mo_app->mo_app = NEW ltcl_test_app( ).
    lo_action->mo_app->ms_draft-id = `CURRENT_DRAFT`.

    " back-navigation to a DIFFERENT class - the response names another app,
    " so the frontend tears the standalone slots down by itself (View1) and
    " nothing about them travels. The back-navigation event does not queue a
    " teardown of its own either (z2ui5_cl_ui5_handler=>main_process): every
    " app switch ends up here, and this is the only place that knows whether
    " the frontend can see it
    lo_action->ms_next-o_app_leave = NEW ltcl_test_app2( ).

    lo_result = lo_action->factory_stack_leave( ).

    cl_abap_unit_assert=>assert_initial( lo_result->ms_next-t_action_front ).

  ENDMETHOD.

  METHOD test_stack_leave_fresh_target.

    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.

    lo_http = NEW #( val = `` ).

    lo_action = NEW #( val = lo_http ).
    lo_action->mo_app->mo_app = NEW ltcl_test_app( ).
    lo_action->mo_app->ms_draft-id                = `LEAVE_FRESH_CURRENT`.
    lo_action->mo_app->ms_draft-id_prev_app_stack = `LEAVE_FRESH_ANCESTOR`.

    " the leave target was never persisted (a fresh app instance) - no draft
    " exists for its id, so instead of popping a level it takes over the
    " current app's position in the stack
    lo_action->ms_next-o_app_leave = NEW ltcl_test_app( ).

    lo_result = lo_action->factory_stack_leave( ).

    cl_abap_unit_assert=>assert_equals( exp = `LEAVE_FRESH_ANCESTOR`
                                        act = lo_result->mo_app->ms_draft-id_prev_app_stack ).
    " the ordinary draft chain still points at the app that was left
    cl_abap_unit_assert=>assert_equals( exp = `LEAVE_FRESH_CURRENT`
                                        act = lo_result->mo_app->ms_draft-id_prev ).

  ENDMETHOD.

  METHOD test_stack_leave_own_stack.

    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_target TYPE REF TO ltcl_test_app.
    DATA lo_target_core TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.

    " a persisted leave target comes back with the stack position ITS draft
    " carries - never with the current app's ancestor written over it. That
    " pop was the same value for a leave to the direct caller and the wrong
    " one for a leave two levels up (the list got a back button that led
    " to its own older draft), and it raised for a purged ancestor row
    lo_target = NEW #( ).
    lo_target_core = NEW #( ).
    lo_target_core->mo_app = lo_target.
    lo_target_core->ms_draft-id = `LEAVE_TARGET_DRAFT`.
    lo_target_core->ms_draft-id_prev_app_stack = `TARGET_OWN_ANCESTOR`.
    lo_target_core->db_save( ).

    " a leave two levels up: the current app's ancestor is NOT the target
    lo_http = NEW #( val = `` ).
    lo_action = NEW #( val = lo_http ).
    lo_action->mo_app->mo_app = NEW ltcl_test_app( ).
    lo_action->mo_app->ms_draft-id = `LEAVE_GONE_CURRENT`.
    lo_action->mo_app->ms_draft-id_prev_app_stack = `LEAVE_MIDDLE_APP_DRAFT`.
    lo_action->ms_next-o_app_leave = lo_target.

    lo_result = lo_action->factory_stack_leave( ).

    cl_abap_unit_assert=>assert_equals( exp = `TARGET_OWN_ANCESTOR`
                                        act = lo_result->mo_app->ms_draft-id_prev_app_stack ).

    " ...and the ancestor row purged by cleanup( ) changes nothing: no read
    " of it is needed any more, so nothing can raise
    lo_action = NEW #( val = lo_http ).
    lo_action->mo_app->mo_app = NEW ltcl_test_app( ).
    lo_action->mo_app->ms_draft-id                = `LEAVE_GONE_CURRENT2`.
    lo_action->mo_app->ms_draft-id_prev_app_stack = `LEAVE_PURGED_ANCESTOR`.
    lo_action->ms_next-o_app_leave = lo_target.

    lo_result = lo_action->factory_stack_leave( ).

    cl_abap_unit_assert=>assert_equals( exp = `TARGET_OWN_ANCESTOR`
                                        act = lo_result->mo_app->ms_draft-id_prev_app_stack ).

  ENDMETHOD.

  METHOD test_first_start_stateless.

    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_saved TYPE REF TO z2ui5_cl_ui5_app_cont.

    " a draft saved by a sticky app, restored into a request that is NOT in
    " a stateful session (F5, a bookmark, a new tab): the persisted flag is
    " dropped, so the app's next set_session_stateful( abap_true ) really
    " switches - it used to be a no-op against a flag that said "already"
    lo_saved = NEW #( ).
    lo_saved->mo_app = NEW ltcl_test_app( ).
    lo_saved->ms_draft-id = `STICKY_DRAFT_STATELESS`.
    lo_saved->mv_check_sticky = abap_true.
    lo_saved->db_save( ).

    lo_http = NEW #( val = `` ).
    lo_http->ms_request-s_control-app_start_draft = `STICKY_DRAFT_STATELESS`.
    lo_action = NEW #( val = lo_http ).

    lo_result = lo_action->factory_first_start( ).

    cl_abap_unit_assert=>assert_false( lo_result->mo_app->mv_check_sticky ).
    cl_abap_unit_assert=>assert_false( lo_result->mv_check_sticky_start ).

    " ...and kept in the stateful session it was saved in
    lo_saved = NEW #( ).
    lo_saved->mo_app = NEW ltcl_test_app( ).
    lo_saved->ms_draft-id = `STICKY_DRAFT_STATEFUL`.
    lo_saved->mv_check_sticky = abap_true.
    lo_saved->db_save( ).

    lo_http = NEW #( val = `` ).
    lo_http->mv_session_sticky = abap_true.
    lo_http->ms_request-s_control-app_start_draft = `STICKY_DRAFT_STATEFUL`.
    lo_action = NEW #( val = lo_http ).

    lo_result = lo_action->factory_first_start( ).

    cl_abap_unit_assert=>assert_true( lo_result->mo_app->mv_check_sticky ).
    cl_abap_unit_assert=>assert_true( lo_result->mv_check_sticky_start ).

  ENDMETHOD.

  METHOD test_first_start_route_state.

    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_saved TYPE REF TO z2ui5_cl_ui5_app_cont.

    " a ROUTE restore (#/app/<CLASS>/<id> - Back, Forward, reload) carries
    " a draft but is not the app-state opt-in: it must not switch the
    " app-state hash on (every response re-asserted it, and an app that
    " turned routing off got a hash it never asked for)
    lo_saved = NEW #( ).
    lo_saved->mo_app = NEW ltcl_test_app( ).
    lo_saved->ms_draft-id = `ROUTE_RESTORE_DRAFT`.
    lo_saved->db_save( ).

    lo_http = NEW #( val = `` ).
    lo_http->ms_request-s_control-app_start_draft = `ROUTE_RESTORE_DRAFT`.
    lo_action = NEW #( val = lo_http ).

    lo_result = lo_action->factory_first_start( ).

    cl_abap_unit_assert=>assert_false( lo_result->ms_next-s_nav-set_app_state_active ).
    cl_abap_unit_assert=>assert_false( lo_result->mo_app->mv_app_state_active ).

    " an app-state bookmark (#/z2ui5-xapp-state=<id>) is that opt-in
    lo_saved = NEW #( ).
    lo_saved->mo_app = NEW ltcl_test_app( ).
    lo_saved->ms_draft-id = `STATE_RESTORE_DRAFT`.
    lo_saved->db_save( ).

    lo_http = NEW #( val = `` ).
    lo_http->ms_request-s_control-app_start_draft = `STATE_RESTORE_DRAFT`.
    lo_http->ms_request-s_control-check_app_state = abap_true.
    lo_action = NEW #( val = lo_http ).

    lo_result = lo_action->factory_first_start( ).

    cl_abap_unit_assert=>assert_true( lo_result->ms_next-s_nav-set_app_state_active ).
    cl_abap_unit_assert=>assert_true( lo_result->mo_app->mv_app_state_active ).

  ENDMETHOD.

ENDCLASS.
