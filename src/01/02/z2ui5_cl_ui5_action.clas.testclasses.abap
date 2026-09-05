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
    METHODS test_stateful_across_hop FOR TESTING RAISING cx_static_check.
    METHODS test_stateful_cancels_out FOR TESTING RAISING cx_static_check.
    METHODS test_stateful_start_sticky FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS z2ui5_cl_ui5_action DEFINITION LOCAL FRIENDS ltcl_test.

CLASS ltcl_test IMPLEMENTATION.

  METHOD test_instantiation.

    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    CREATE OBJECT lo_http EXPORTING val = ``.

    CREATE OBJECT lo_action EXPORTING val = lo_http.

    cl_abap_unit_assert=>assert_bound( lo_action ).
    cl_abap_unit_assert=>assert_bound( lo_action->mo_handler ).
    cl_abap_unit_assert=>assert_bound( lo_action->mo_app ).

  ENDMETHOD.

  METHOD test_system_startup.
    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.

    CREATE OBJECT lo_http EXPORTING val = ``.

    CREATE OBJECT lo_action EXPORTING val = lo_http.


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

    CREATE OBJECT lo_http EXPORTING val = lv_payload.
    lo_http->ms_request = lo_http->request_json_to_abap( lv_payload ).


    CREATE OBJECT lo_action EXPORTING val = lo_http.

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
    FIELD-SYMBOLS <temp1> LIKE LINE OF lo_result->ms_next-s_action-t_custom.
    DATA temp2 LIKE sy-tabix.

    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":"?app_start=Z2UI5_CL_UI5_APP_HI_WORLD"}}}`.

    CREATE OBJECT lo_http EXPORTING val = lv_payload.
    lo_http->ms_request = lo_http->request_json_to_abap( lv_payload ).
    lo_http->ms_request-s_control-app_start_draft = `THIS_DRAFT_DOES_NOT_EXIST`.

    CREATE OBJECT lo_action EXPORTING val = lo_http.

    lo_result = lo_action->factory_first_start( ).

    " the expired bookmark draft must not block the fresh app start...
    cl_abap_unit_assert=>assert_bound( lo_result->mo_app->mo_app ).
    " ...and the user is told why the saved state is gone, as the follow-up
    " action message_toast_display( ) would have queued
    cl_abap_unit_assert=>assert_equals(
        exp = 1
        act = lines( lo_result->ms_next-s_action-t_custom ) ).


    temp2 = sy-tabix.
    READ TABLE lo_result->ms_next-s_action-t_custom INDEX 1 ASSIGNING <temp1>.
    sy-tabix = temp2.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_char_cp(
        exp = `["MESSAGE_TOAST","show","Bookmarked app state expired*`
        act = <temp1>-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_first_start_error.

    DATA lv_payload TYPE string.
    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
    DATA temp1 TYPE xsdboolean.
        DATA temp2 TYPE xsdboolean.
    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":"?app_start=NONEXISTENT_CLASS"}}}`.

    CREATE OBJECT lo_http EXPORTING val = lv_payload.
    lo_http->ms_request = lo_http->request_json_to_abap( lv_payload ).


    CREATE OBJECT lo_action EXPORTING val = lo_http.

    TRY.
        lo_action->factory_first_start( ).
        cl_abap_unit_assert=>fail( `Expected exception for nonexistent class` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx.


        temp2 = boolc( lx->get_text( ) CS `NONEXISTENT_CLASS` ).
        temp1 = temp2.
        cl_abap_unit_assert=>assert_true( temp1 ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_factory_by_frontend.
    DATA lv_payload TYPE string.
    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.

    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":""}}}`.

    CREATE OBJECT lo_http EXPORTING val = lv_payload.
    lo_http->ms_request = lo_http->request_json_to_abap( lv_payload ).


    CREATE OBJECT lo_action EXPORTING val = lo_http.
    CREATE OBJECT lo_action->mo_app->mo_app TYPE ltcl_test_app.
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
    DATA temp3 TYPE z2ui5_if_ui5_types=>ty_s_queued_action.
    DATA temp4 TYPE z2ui5_if_ui5_types=>ty_s_queued_action.
    FIELD-SYMBOLS <temp5> LIKE LINE OF lo_result->ms_next-t_action_front.
    DATA temp6 LIKE sy-tabix.
    FIELD-SYMBOLS <temp1> LIKE LINE OF lo_result->ms_next-t_action_front.
    DATA temp2 LIKE sy-tabix.
    FIELD-SYMBOLS <temp7> LIKE LINE OF lo_result->ms_next-t_action_front.
    DATA temp8 LIKE sy-tabix.
    FIELD-SYMBOLS <temp3> LIKE LINE OF lo_result->ms_next-t_action_front.
    DATA temp5 LIKE sy-tabix.

    CREATE OBJECT lo_http EXPORTING val = ``.

    CREATE OBJECT lo_action EXPORTING val = lo_http.
    CREATE OBJECT lo_action->mo_app->mo_app TYPE ltcl_test_app.
    lo_action->mo_app->ms_draft-id = `CURRENT_DRAFT`.


    " routing active for the caller - the called app inherits the mode, and
    " only then does the ROUTER intent travel at all
    lo_action->mo_app->mv_nav_mode = z2ui5_if_client=>cs_nav_mode-keep.

    CREATE OBJECT lo_new_app.
    lo_action->ms_next-o_app_call = lo_new_app.

    " frontend actions queued by the calling app - messages travel as
    " follow-up actions too and must not leak into the newly called app...

    CLEAR temp3.
    temp3-js = `some_js`.
    INSERT temp3 INTO TABLE lo_action->ms_next-s_action-t_custom.

    CLEAR temp4.
    temp4-js = `some_system_js`.
    INSERT temp4 INTO TABLE lo_action->ms_next-s_action-t_system.


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


    temp6 = sy-tabix.
    READ TABLE lo_result->ms_next-t_action_front INDEX 1 ASSIGNING <temp5>.
    sy-tabix = temp6.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp2 = sy-tabix.
    READ TABLE lo_result->ms_next-t_action_front INDEX 1 ASSIGNING <temp1>.
    sy-tabix = temp2.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `POPUP|destroy`
                                        act = |{ <temp5>-slot }\|| &&
                                              |{ <temp1>-method }| ).


    temp8 = sy-tabix.
    READ TABLE lo_result->ms_next-t_action_front INDEX 2 ASSIGNING <temp7>.
    sy-tabix = temp8.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp5 = sy-tabix.
    READ TABLE lo_result->ms_next-t_action_front INDEX 2 ASSIGNING <temp3>.
    sy-tabix = temp5.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `POPOVER|destroy`
                                        act = |{ <temp7>-slot }\|| &&
                                              |{ <temp3>-method }| ).

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
    CREATE OBJECT lo_result->ms_next-o_app_call TYPE ltcl_test_app.
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
    CREATE OBJECT lo_http EXPORTING val = ``.

    CREATE OBJECT lo_action EXPORTING val = lo_http.
    CREATE OBJECT lo_action->mo_app->mo_app TYPE ltcl_test_app.
    lo_action->mo_app->ms_draft-id  = `CURRENT_DRAFT`.
    lo_action->mo_app->mv_nav_mode  = z2ui5_if_client=>cs_nav_mode-keep.
    CREATE OBJECT lo_action->ms_next-o_app_call TYPE ltcl_test_app.

    lo_called = lo_action->factory_stack_call( ).

    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_client=>cs_nav_mode-keep
                                        act = lo_called->mo_app->mv_nav_mode ).

    " an app that never enabled routing passes nothing on - the called app
    " stays unrouted, so the opt-in really is an opt-in
    CREATE OBJECT lo_own EXPORTING val = lo_http.
    CREATE OBJECT lo_own->mo_app->mo_app TYPE ltcl_test_app.
    lo_own->mo_app->ms_draft-id = `PLAIN_DRAFT`.
    CREATE OBJECT lo_own->ms_next-o_app_call TYPE ltcl_test_app.

    lo_called = lo_own->factory_stack_call( ).

    cl_abap_unit_assert=>assert_initial( lo_called->mo_app->mv_nav_mode ).

  ENDMETHOD.

  METHOD test_stateful_across_hop.
    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_called TYPE REF TO z2ui5_cl_ui5_action.
    DATA temp9 TYPE REF TO z2ui5_cl_ui5_client.
    DATA temp10 TYPE REF TO z2ui5_cl_ui5_client.

    " app A switches the session stateful and calls B in the same roundtrip,
    " and B (the "stateful app" template) switches it on as well. The end
    " state differs from the start state, so the response must carry the
    " switch - B runs in a FRESH container, and a per-container toggle used
    " to flip back to abap_false here (then B was sticky without a stateful
    " session: no draft saved, next click NO_DRAFT_ENTRY)
    CREATE OBJECT lo_http EXPORTING val = ``.
    CREATE OBJECT lo_action EXPORTING val = lo_http.
    CREATE OBJECT lo_action->mo_app->mo_app TYPE ltcl_test_app.
    lo_action->mo_app->ms_draft-id = `CURRENT_DRAFT`.


    CREATE OBJECT temp9 TYPE z2ui5_cl_ui5_client EXPORTING action = lo_action.
    temp9->z2ui5_if_client~set_session_stateful( abap_true ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_action->ms_next-s_stateful-switched ).

    CREATE OBJECT lo_action->ms_next-o_app_call TYPE ltcl_test_app.
    lo_called = lo_action->factory_stack_call( ).


    CREATE OBJECT temp10 TYPE z2ui5_cl_ui5_client EXPORTING action = lo_called.
    temp10->z2ui5_if_client~set_session_stateful( abap_true ).

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
    CREATE OBJECT lo_http EXPORTING val = ``.
    CREATE OBJECT lo_action EXPORTING val = lo_http.
    CREATE OBJECT lo_action->mo_app->mo_app TYPE ltcl_test_app.
    CREATE OBJECT lo_client EXPORTING action = lo_action.

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
    CREATE OBJECT lo_http EXPORTING val = ``.
    CREATE OBJECT lo_action EXPORTING val = lo_http.
    CREATE OBJECT lo_action->mo_app->mo_app TYPE ltcl_test_app.
    lo_action->mo_app->mv_check_sticky = abap_true.
    lo_action->mv_check_sticky_start   = abap_true.
    CREATE OBJECT lo_client EXPORTING action = lo_action.

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
    CREATE OBJECT lo_target.
    CREATE OBJECT lo_target_core.
    lo_target_core->mo_app = lo_target.
    lo_target_core->ms_draft-id = `NAV_MODE_OWN_TARGET`.
    lo_target_core->mv_nav_mode = z2ui5_if_client=>cs_nav_mode-fresh.
    lo_target_core->db_save( ).

    CREATE OBJECT lo_http EXPORTING val = ``.
    CREATE OBJECT lo_action EXPORTING val = lo_http.
    CREATE OBJECT lo_action->mo_app->mo_app TYPE ltcl_test_app.
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
    CREATE OBJECT lo_http EXPORTING val = ``.
    CREATE OBJECT lo_action EXPORTING val = lo_http.
    CREATE OBJECT lo_action->mo_app->mo_app TYPE ltcl_test_app.
    lo_action->mo_app->ms_draft-id = `ROUTING_REQ_DRAFT`.

    lo_action->ms_next-s_nav-set_nav_routing = z2ui5_if_client=>cs_nav_mode-keep.
    lo_action->ms_next-s_nav-set_push_state  = `/caller-state`.
    CREATE OBJECT lo_action->ms_next-o_app_call TYPE ltcl_test_app.

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
    DATA temp11 TYPE z2ui5_if_ui5_types=>ty_t_system_action.
    DATA temp12 LIKE LINE OF temp11.
    FIELD-SYMBOLS <temp13> LIKE LINE OF lo_result->ms_next-t_action_front.
    DATA temp14 LIKE sy-tabix.
    FIELD-SYMBOLS <temp6> LIKE LINE OF lo_result->ms_next-t_action_front.
    DATA temp7 LIKE sy-tabix.

    CREATE OBJECT lo_http EXPORTING val = ``.
    CREATE OBJECT lo_action EXPORTING val = lo_http.
    CREATE OBJECT lo_action->mo_app->mo_app TYPE ltcl_test_app.
    lo_action->mo_app->ms_draft-id = `CURRENT_DRAFT`.

    " the leaving app tears its own view down and navigates to a DIFFERENT
    " class - the destroy must survive the hop (the called app may render
    " no MAIN view of its own), the display must not, and no popup/popover
    " teardown is queued (the frontend sees the class switch and tears the
    " standalone slots down implicitly)

    CLEAR temp11.

    temp12-slot = z2ui5_if_client=>cs_view-main.
    temp12-method = z2ui5_if_ui5_types=>cs_slot_action-destroy.
    INSERT temp12 INTO TABLE temp11.
    temp12-slot = z2ui5_if_client=>cs_view-nested.
    temp12-method = z2ui5_if_ui5_types=>cs_slot_action-display.
    temp12-xml = `<Nest/>`.
    INSERT temp12 INTO TABLE temp11.
    lo_action->ms_next-t_action_front = temp11.
    CREATE OBJECT lo_action->ms_next-o_app_call TYPE ltcl_test_app2.

    lo_result = lo_action->factory_stack_call( ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_result->ms_next-t_action_front ) ).


    temp14 = sy-tabix.
    READ TABLE lo_result->ms_next-t_action_front INDEX 1 ASSIGNING <temp13>.
    sy-tabix = temp14.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp7 = sy-tabix.
    READ TABLE lo_result->ms_next-t_action_front INDEX 1 ASSIGNING <temp6>.
    sy-tabix = temp7.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MAIN|destroy`
                                        act = |{ <temp13>-slot }\|| &&
                                              |{ <temp6>-method }| ).

    " no routing mode anywhere - a plain nav carries no ROUTER intent
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lo_result->ms_next-s_nav-check_nav_app_call ).

  ENDMETHOD.

  METHOD test_stack_leave.
    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_prev_app TYPE REF TO ltcl_test_app.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.
    DATA temp15 TYPE z2ui5_if_ui5_types=>ty_s_queued_action.
    DATA temp16 TYPE z2ui5_if_ui5_types=>ty_s_queued_action.
    FIELD-SYMBOLS <temp17> LIKE LINE OF lo_result->ms_next-t_action_front.
    DATA temp18 LIKE sy-tabix.
    FIELD-SYMBOLS <temp8> LIKE LINE OF lo_result->ms_next-t_action_front.
    DATA temp9 LIKE sy-tabix.
    FIELD-SYMBOLS <temp19> LIKE LINE OF lo_result->ms_next-t_action_front.
    DATA temp20 LIKE sy-tabix.
    FIELD-SYMBOLS <temp10> LIKE LINE OF lo_result->ms_next-t_action_front.
    DATA temp11 LIKE sy-tabix.

    CREATE OBJECT lo_http EXPORTING val = ``.

    CREATE OBJECT lo_action EXPORTING val = lo_http.
    CREATE OBJECT lo_action->mo_app->mo_app TYPE ltcl_test_app.
    lo_action->mo_app->ms_draft-id = `CURRENT_DRAFT`.


    CREATE OBJECT lo_prev_app.
    lo_action->ms_next-o_app_leave = lo_prev_app.

    " frontend actions queued by the leaving app - messages travel as
    " follow-up actions too and must not leak into the app that is
    " navigated back to...

    CLEAR temp15.
    temp15-js = `some_js`.
    INSERT temp15 INTO TABLE lo_action->ms_next-s_action-t_custom.

    CLEAR temp16.
    temp16-js = `some_system_js`.
    INSERT temp16 INTO TABLE lo_action->ms_next-s_action-t_system.


    lo_result = lo_action->factory_stack_leave( ).

    cl_abap_unit_assert=>assert_bound( lo_result ).

    " leave behaves like call
    cl_abap_unit_assert=>assert_initial( lo_result->ms_next-s_action-t_custom ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_result->ms_next-t_action_front ) ).


    temp18 = sy-tabix.
    READ TABLE lo_result->ms_next-t_action_front INDEX 1 ASSIGNING <temp17>.
    sy-tabix = temp18.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp9 = sy-tabix.
    READ TABLE lo_result->ms_next-t_action_front INDEX 1 ASSIGNING <temp8>.
    sy-tabix = temp9.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `POPUP|destroy`
                                        act = |{ <temp17>-slot }\|| &&
                                              |{ <temp8>-method }| ).


    temp20 = sy-tabix.
    READ TABLE lo_result->ms_next-t_action_front INDEX 2 ASSIGNING <temp19>.
    sy-tabix = temp20.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp11 = sy-tabix.
    READ TABLE lo_result->ms_next-t_action_front INDEX 2 ASSIGNING <temp10>.
    sy-tabix = temp11.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `POPOVER|destroy`
                                        act = |{ <temp19>-slot }\|| &&
                                              |{ <temp10>-method }| ).

  ENDMETHOD.

  METHOD test_stack_leave_cross_class.

    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.

    CREATE OBJECT lo_http EXPORTING val = ``.

    CREATE OBJECT lo_action EXPORTING val = lo_http.
    CREATE OBJECT lo_action->mo_app->mo_app TYPE ltcl_test_app.
    lo_action->mo_app->ms_draft-id = `CURRENT_DRAFT`.

    " back-navigation to a DIFFERENT class - the response names another app,
    " so the frontend tears the standalone slots down by itself (View1) and
    " nothing about them travels. The back-navigation event does not queue a
    " teardown of its own either (z2ui5_cl_ui5_handler=>main_process): every
    " app switch ends up here, and this is the only place that knows whether
    " the frontend can see it
    CREATE OBJECT lo_action->ms_next-o_app_leave TYPE ltcl_test_app2.

    lo_result = lo_action->factory_stack_leave( ).

    cl_abap_unit_assert=>assert_initial( lo_result->ms_next-t_action_front ).

  ENDMETHOD.

  METHOD test_stack_leave_fresh_target.

    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.

    CREATE OBJECT lo_http EXPORTING val = ``.

    CREATE OBJECT lo_action EXPORTING val = lo_http.
    CREATE OBJECT lo_action->mo_app->mo_app TYPE ltcl_test_app.
    lo_action->mo_app->ms_draft-id                = `LEAVE_FRESH_CURRENT`.
    lo_action->mo_app->ms_draft-id_prev_app_stack = `LEAVE_FRESH_ANCESTOR`.

    " the leave target was never persisted (a fresh app instance) - no draft
    " exists for its id, so instead of popping a level it takes over the
    " current app's position in the stack
    CREATE OBJECT lo_action->ms_next-o_app_leave TYPE ltcl_test_app.

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
    DATA temp21 TYPE z2ui5_cl_ui5_srv_draft=>ty_s_draft.
    DATA temp12 TYPE REF TO z2ui5_cl_ui5_srv_draft.

    " persist the leave target, so the fresh-target takeover is NOT taken
    " and the stack-pop path runs
    CREATE OBJECT lo_target.
    CREATE OBJECT lo_target_core.
    lo_target_core->mo_app = lo_target.
    lo_target_core->ms_draft-id = `LEAVE_TARGET_DRAFT`.
    lo_target_core->db_save( ).

    CREATE OBJECT lo_http EXPORTING val = ``.
    CREATE OBJECT lo_action EXPORTING val = lo_http.
    CREATE OBJECT lo_action->mo_app->mo_app TYPE ltcl_test_app.
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

    CLEAR temp21.
    temp21-id = `LEAVE_ANCESTOR_DRAFT`.
    temp21-id_prev_app_stack = `LEAVE_GRANDPARENT`.

    CREATE OBJECT temp12 TYPE z2ui5_cl_ui5_srv_draft.
    temp12->create(
        draft     = temp21
        model_xml = `<dummy/>` ).

    CREATE OBJECT lo_action EXPORTING val = lo_http.
    CREATE OBJECT lo_action->mo_app->mo_app TYPE ltcl_test_app.
    lo_action->mo_app->ms_draft-id                = `LEAVE_GONE_CURRENT2`.
    lo_action->mo_app->ms_draft-id_prev_app_stack = `LEAVE_ANCESTOR_DRAFT`.
    lo_action->ms_next-o_app_leave = lo_target.

    lo_pop = lo_action->factory_stack_leave( ).

    cl_abap_unit_assert=>assert_equals( exp = `LEAVE_GRANDPARENT`
                                        act = lo_pop->mo_app->ms_draft-id_prev_app_stack ).

  ENDMETHOD.

ENDCLASS.
