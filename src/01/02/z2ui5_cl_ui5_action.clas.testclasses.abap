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
    METHODS test_first_start_draft_gone FOR TESTING RAISING cx_static_check.
    METHODS test_factory_by_frontend FOR TESTING RAISING cx_static_check.
    METHODS test_stack_call         FOR TESTING RAISING cx_static_check.
    METHODS test_stack_call_cross_class FOR TESTING RAISING cx_static_check.
    METHODS test_stack_leave        FOR TESTING RAISING cx_static_check.
    METHODS test_stack_leave_cross_class FOR TESTING RAISING cx_static_check.
    METHODS test_stack_leave_fresh_target FOR TESTING RAISING cx_static_check.
    METHODS test_stack_leave_ancestor_gone FOR TESTING RAISING cx_static_check.
    METHODS test_nav_mode_inherited FOR TESTING RAISING cx_static_check.
    METHODS test_nav_mode_own_wins  FOR TESTING RAISING cx_static_check.
    METHODS test_hop_clears_routing_req FOR TESTING RAISING cx_static_check.
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
    DATA temp1 TYPE xsdboolean.
    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":"?app_start=NONEXISTENT_CLASS"}}}`.

    lo_http = NEW #( val = lv_payload ).
    lo_http->ms_request = lo_http->request_json_to_abap( lv_payload ).


    lo_action = NEW #( val = lo_http ).

    TRY.
        lo_action->factory_first_start( ).
        cl_abap_unit_assert=>fail( `Expected exception for nonexistent class` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx.

        temp1 = xsdbool( lx->get_text( ) CS `NONEXISTENT_CLASS` ).
        cl_abap_unit_assert=>assert_true( temp1 ).
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
    DATA lo_new_app TYPE REF TO ltcl_test_app.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_chained TYPE REF TO z2ui5_cl_ui5_action.

    lo_http = NEW #( val = `` ).

    lo_action = NEW #( val = lo_http ).
    lo_action->mo_app->mo_app = NEW ltcl_test_app( ).
    lo_action->mo_app->ms_draft-id = `CURRENT_DRAFT`.


    " routing active for the caller - the called app inherits the mode, and
    " only then does the ROUTER intent travel at all
    lo_action->mo_app->mv_nav_mode = z2ui5_if_client=>cs_nav_mode-keep.

    lo_new_app = NEW #( ).
    lo_action->ms_next-o_app_call = lo_new_app.

    " frontend actions queued by the calling app - messages travel as
    " follow-up actions too and must not leak into the newly called app...
    INSERT VALUE #( js = `some_js` ) INTO TABLE lo_action->ms_next-s_action-t_custom.
    INSERT VALUE #( js = `some_system_js` ) INTO TABLE lo_action->ms_next-s_action-t_system.


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
    DATA lo_prev_app TYPE REF TO ltcl_test_app.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.

    lo_http = NEW #( val = `` ).

    lo_action = NEW #( val = lo_http ).
    lo_action->mo_app->mo_app = NEW ltcl_test_app( ).
    lo_action->mo_app->ms_draft-id = `CURRENT_DRAFT`.


    lo_prev_app = NEW #( ).
    lo_action->ms_next-o_app_leave = lo_prev_app.

    " frontend actions queued by the leaving app - messages travel as
    " follow-up actions too and must not leak into the app that is
    " navigated back to...
    INSERT VALUE #( js = `some_js` ) INTO TABLE lo_action->ms_next-s_action-t_custom.
    INSERT VALUE #( js = `some_system_js` ) INTO TABLE lo_action->ms_next-s_action-t_system.


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

  METHOD test_stack_leave_ancestor_gone.

    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_target TYPE REF TO ltcl_test_app.
    DATA lo_target_core TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_pop TYPE REF TO z2ui5_cl_ui5_action.

    " persist the leave target, so the fresh-target takeover is NOT taken
    " and the stack-pop path runs
    lo_target = NEW #( ).
    lo_target_core = NEW #( ).
    lo_target_core->mo_app = lo_target.
    lo_target_core->ms_draft-id = `LEAVE_TARGET_DRAFT`.
    lo_target_core->db_save( ).

    lo_http = NEW #( val = `` ).
    lo_action = NEW #( val = lo_http ).
    lo_action->mo_app->mo_app = NEW ltcl_test_app( ).
    lo_action->mo_app->ms_draft-id = `LEAVE_GONE_CURRENT`.
    " the ancestor stack draft was purged (cleanup( ) in a long-lived
    " session) while the leave target still exists - the guard must skip
    " the pop instead of raising NO_DRAFT_ENTRY in read_info
    lo_action->mo_app->ms_draft-id_prev_app_stack = `LEAVE_PURGED_ANCESTOR`.
    lo_action->ms_next-o_app_leave = lo_target.

    lo_result = lo_action->factory_stack_leave( ).

    " back-navigation survived, and the stale ancestor id neither raised
    " nor took the target's stack position over
    cl_abap_unit_assert=>assert_initial( lo_result->mo_app->ms_draft-id_prev_app_stack ).

    " counter-check: with the ancestor draft present the same leave pops one
    " level - the target's stack position becomes the ancestor's ancestor
    NEW z2ui5_cl_ui5_srv_draft( )->create(
        draft     = VALUE #( id                = `LEAVE_ANCESTOR_DRAFT`
                             id_prev_app_stack = `LEAVE_GRANDPARENT` )
        model_xml = `<dummy/>` ).

    lo_action = NEW #( val = lo_http ).
    lo_action->mo_app->mo_app = NEW ltcl_test_app( ).
    lo_action->mo_app->ms_draft-id                = `LEAVE_GONE_CURRENT2`.
    lo_action->mo_app->ms_draft-id_prev_app_stack = `LEAVE_ANCESTOR_DRAFT`.
    lo_action->ms_next-o_app_leave = lo_target.

    lo_pop = lo_action->factory_stack_leave( ).

    cl_abap_unit_assert=>assert_equals( exp = `LEAVE_GRANDPARENT`
                                        act = lo_pop->mo_app->ms_draft-id_prev_app_stack ).

  ENDMETHOD.

ENDCLASS.
