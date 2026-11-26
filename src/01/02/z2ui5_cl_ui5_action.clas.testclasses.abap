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


" a serializer that cannot restore anything - the stand-in for a draft that
" is there and is broken (a layout the app class no longer has, a type that
" is gone). A seam rather than a garbled row: what garbled XML does is the
" parser's business and differs between a kernel and the transpiled runtime
CLASS ltcl_broken_serializer DEFINITION FINAL FOR TESTING.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_ui5_serializer.
ENDCLASS.

CLASS ltcl_broken_serializer IMPLEMENTATION.

  METHOD z2ui5_if_ui5_serializer~stringify.
    result = `<draft/>`.
  ENDMETHOD.

  METHOD z2ui5_if_ui5_serializer~parse.
    RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
      EXPORTING val = `TEST_RESTORE_ERROR - the draft could not be restored`.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_instantiation      FOR TESTING RAISING cx_static_check.
    METHODS test_system_startup     FOR TESTING RAISING cx_static_check.
    METHODS test_first_start        FOR TESTING RAISING cx_static_check.
    METHODS test_first_start_no_app_start FOR TESTING RAISING cx_static_check.
    METHODS test_first_start_error  FOR TESTING RAISING cx_static_check.
    METHODS test_first_start_not_an_app FOR TESTING RAISING cx_static_check.
    METHODS test_first_start_draft_gone FOR TESTING RAISING cx_static_check.
    METHODS test_first_start_draft_broken FOR TESTING RAISING cx_static_check.
    METHODS test_app_start_safe      FOR TESTING RAISING cx_static_check.
    METHODS test_factory_by_frontend FOR TESTING RAISING cx_static_check.
    METHODS test_stack_call         FOR TESTING RAISING cx_static_check.
    METHODS test_stack_call_popup_open FOR TESTING RAISING cx_static_check.
    METHODS test_stack_call_cross_class FOR TESTING RAISING cx_static_check.
    METHODS test_stack_leave        FOR TESTING RAISING cx_static_check.
    " nav_app_leave/nav_app_call( keep_messages = abap_true ): the toasts
    " and boxes the leaving app queued follow it, nothing else does
    METHODS test_leave_keeps_messages FOR TESTING RAISING cx_static_check.
    METHODS test_call_keeps_messages FOR TESTING RAISING cx_static_check.
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

  METHOD test_first_start_draft_broken.

    DATA lv_payload TYPE string.
    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.

    " a draft that exists and is the user's, but cannot be restored, is not
    " an expired bookmark: the error goes out with its chain instead of a
    " toast and a fresh app that hide what broke
    DATA lv_id TYPE string.
    DATA temp3 TYPE z2ui5_if_ui5_draft_store=>ty_s_draft.
    DATA temp4 TYPE REF TO ltcl_broken_serializer.
        DATA temp5 TYPE REF TO z2ui5_if_ui5_serializer.
        DATA lx TYPE REF TO cx_root.
        DATA temp6 TYPE REF TO z2ui5_if_ui5_serializer.
    lv_id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).

    CLEAR temp3.
    temp3-id = lv_id.
    z2ui5_cl_ui5_srv_draft=>get_instance( )->create( draft     = temp3
                                                     model_xml = `<draft/>` ).

    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":"?app_start=Z2UI5_CL_UI5_APP_HI_WORLD"}}}`.
    CREATE OBJECT lo_http EXPORTING val = lv_payload.
    lo_http->ms_request = lo_http->request_json_to_abap( lv_payload ).
    lo_http->ms_request-s_control-app_start_draft = lv_id.
    CREATE OBJECT lo_action EXPORTING val = lo_http.


    CREATE OBJECT temp4 TYPE ltcl_broken_serializer.
    z2ui5_cl_ui5_app_cont=>set_serializer( temp4 ).
    TRY.
        lo_action->factory_first_start( ).

        CLEAR temp5.
        z2ui5_cl_ui5_app_cont=>set_serializer( temp5 ).
        cl_abap_unit_assert=>fail( `a broken draft was swallowed as an expired one` ).

      CATCH cx_root INTO lx.

        CLEAR temp6.
        z2ui5_cl_ui5_app_cont=>set_serializer( temp6 ).
        cl_abap_unit_assert=>assert_char_cp( exp = `*TEST_RESTORE_ERROR*`
                                             act = lx->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_first_start_no_app_start.

    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_start TYPE REF TO z2ui5_cl_ui5_app_start.

    " an app-state bookmark whose URL carries no ?app_start= (the session
    " reached its app by navigation) and whose draft is gone: the start
    " page, with the toast - not an APP_START_ERROR for an empty name
    CREATE OBJECT lo_http EXPORTING val = ``.
    lo_http->ms_request-s_control-app_start_draft = `THIS_DRAFT_DOES_NOT_EXIST`.
    lo_http->ms_request-s_control-check_app_state = abap_true.
    CREATE OBJECT lo_action EXPORTING val = lo_http.

    lo_result = lo_action->factory_first_start( ).


    TRY.
        lo_start ?= lo_result->mo_app->mo_app.
      CATCH cx_sy_move_cast_error.
        cl_abap_unit_assert=>fail( `not the start page` ).
    ENDTRY.
    cl_abap_unit_assert=>assert_bound( lo_start ).
    cl_abap_unit_assert=>assert_equals(
        exp = 1
        act = lines( lo_result->ms_next-s_action-t_custom ) ).

  ENDMETHOD.

  METHOD test_first_start_error.

    DATA lv_payload TYPE string.
    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp1 TYPE xsdboolean.
    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":"?app_start=NONEXISTENT_CLASS"}}}`.

    CREATE OBJECT lo_http EXPORTING val = lv_payload.
    lo_http->ms_request = lo_http->request_json_to_abap( lv_payload ).


    CREATE OBJECT lo_action EXPORTING val = lo_http.

    TRY.
        lo_action->factory_first_start( ).
        cl_abap_unit_assert=>fail( `Expected exception for nonexistent class` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx.


        temp1 = boolc( lx->get_text( ) CS `NONEXISTENT_CLASS` ).
        cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp1 ).
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
        DATA temp2 TYPE xsdboolean.
        DATA temp3 TYPE xsdboolean.
    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":"?app_start=Z2UI5_CL_UI5_UTIL_CONTEXT"}}}`.

    CREATE OBJECT lo_http EXPORTING val = lv_payload.
    lo_http->ms_request = lo_http->request_json_to_abap( lv_payload ).
    CREATE OBJECT lo_action EXPORTING val = lo_http.

    TRY.
        lo_action->factory_first_start( ).
        cl_abap_unit_assert=>fail( `Expected exception for a class that is not an app` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx.

        temp2 = boolc( lx->get_text( ) CS `Z2UI5_CL_UI5_UTIL_CONTEXT` ).
        cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp2 ).

        temp3 = boolc( lx->get_text( ) CS `does not implement z2ui5_if_app` ).
        cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp3 ).
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
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_chained TYPE REF TO z2ui5_cl_ui5_action.
    DATA temp7 TYPE z2ui5_if_ui5_types=>ty_s_queued_action.
    FIELD-SYMBOLS <temp8> LIKE LINE OF lo_result->ms_next-t_action_front.
    DATA temp9 LIKE sy-tabix.
    FIELD-SYMBOLS <temp1> LIKE LINE OF lo_result->ms_next-t_action_front.
    DATA temp2 LIKE sy-tabix.
    FIELD-SYMBOLS <temp10> LIKE LINE OF lo_result->ms_next-t_action_front.
    DATA temp11 LIKE sy-tabix.
    FIELD-SYMBOLS <temp3> LIKE LINE OF lo_result->ms_next-t_action_front.
    DATA temp4 LIKE sy-tabix.

    CREATE OBJECT lo_http EXPORTING val = ``.

    CREATE OBJECT lo_action EXPORTING val = lo_http.
    CREATE OBJECT lo_action->mo_app->mo_app TYPE ltcl_test_app.
    lo_action->mo_app->ms_draft-id = `CURRENT_DRAFT`.


    " routing active for the caller - the called app inherits the mode, and
    " only then does the NAV intent travel at all
    lo_action->mo_app->mv_nav_mode = z2ui5_if_client=>cs_nav_mode-keep.

    CREATE OBJECT lo_action->ms_next-o_app_call TYPE ltcl_test_app.

    " frontend actions queued by the calling app - messages travel as
    " follow-up actions too and must not leak into the newly called app...

    CLEAR temp7.
    temp7-o_json = z2ui5_cl_ajson=>parse( `["SOME_ACTION"]` ).
    INSERT temp7 INTO TABLE lo_action->ms_next-s_action-t_custom.


    lo_result = lo_action->factory_stack_call( ).

    cl_abap_unit_assert=>assert_bound( lo_result ).
    cl_abap_unit_assert=>assert_equals( exp = `CURRENT_DRAFT`
                                        act = lo_result->mo_app->ms_draft-id_prev_app_stack ).

    " everything the calling app queued is gone. The popup/popover teardown
    " is queued for EVERY hop - the backend is the side that knows one
    " happened - and BEFORE the app runs, so a popup_display( ) of its own
    " lands after it and wins
    cl_abap_unit_assert=>assert_initial( lo_result->ms_next-s_action-t_custom ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_result->ms_next-t_action_front ) ).


    temp9 = sy-tabix.
    READ TABLE lo_result->ms_next-t_action_front INDEX 1 ASSIGNING <temp8>.
    sy-tabix = temp9.
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
                                        act = |{ <temp8>-slot }\|| &&
                                              |{ <temp1>-method }| ).


    temp11 = sy-tabix.
    READ TABLE lo_result->ms_next-t_action_front INDEX 2 ASSIGNING <temp10>.
    sy-tabix = temp11.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp4 = sy-tabix.
    READ TABLE lo_result->ms_next-t_action_front INDEX 2 ASSIGNING <temp3>.
    sy-tabix = temp4.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `POPOVER|destroy`
                                        act = |{ <temp10>-slot }\|| &&
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
    DATA temp12 TYPE REF TO z2ui5_cl_ui5_client.
    DATA temp13 TYPE REF TO z2ui5_cl_ui5_client.

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


    CREATE OBJECT temp12 TYPE z2ui5_cl_ui5_client EXPORTING action = lo_action.
    temp12->z2ui5_if_client~set_session_stateful( abap_true ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_action->ms_next-s_stateful-switched ).

    CREATE OBJECT lo_action->ms_next-o_app_call TYPE ltcl_test_app.
    lo_called = lo_action->factory_stack_call( ).


    CREATE OBJECT temp13 TYPE z2ui5_cl_ui5_client EXPORTING action = lo_called.
    temp13->z2ui5_if_client~set_session_stateful( abap_true ).

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

  METHOD test_stack_call_popup_open.

    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.
    DATA temp14 TYPE z2ui5_if_ui5_types=>ty_t_system_action.
    DATA temp15 LIKE LINE OF temp14.
    DATA lv_actions TYPE string.
    DATA ls_front LIKE LINE OF lo_result->ms_next-t_action_front.
    DATA temp16 TYPE REF TO z2ui5_cl_ui5_frontend.

    CREATE OBJECT lo_http EXPORTING val = ``.
    CREATE OBJECT lo_action EXPORTING val = lo_http.
    CREATE OBJECT lo_action->mo_app->mo_app TYPE ltcl_test_app.
    lo_action->mo_app->ms_draft-id = `CURRENT_DRAFT`.

    " the leaving app opened a popup in this roundtrip and closed its
    " popover, then calls another instance of its OWN class: the display
    " describes the screen being replaced and is dropped, the carried
    " popover destroy and the hop's own teardown are merged - the frontend
    " receives at most one entry per slot (z2ui5_cl_ui5_frontend=>slot_reset)

    CLEAR temp14.

    CLEAR temp15.
    temp15-slot = z2ui5_if_client=>cs_view-popup.
    temp15-method = z2ui5_if_ui5_types=>cs_slot_action-display.
    temp15-xml = `<Dialog/>`.
    INSERT temp15 INTO TABLE temp14.
    CLEAR temp15.
    temp15-slot = z2ui5_if_client=>cs_view-popover.
    temp15-method = z2ui5_if_ui5_types=>cs_slot_action-destroy.
    INSERT temp15 INTO TABLE temp14.
    CLEAR temp15.
    temp15-slot = z2ui5_if_client=>cs_view-main.
    temp15-method = z2ui5_if_ui5_types=>cs_slot_action-destroy.
    INSERT temp15 INTO TABLE temp14.
    lo_action->ms_next-t_action_front = temp14.
    CREATE OBJECT lo_action->ms_next-o_app_call TYPE ltcl_test_app.

    lo_result = lo_action->factory_stack_call( ).


    lv_actions = ``.

    LOOP AT lo_result->ms_next-t_action_front INTO ls_front.
      lv_actions = |{ lv_actions }{ ls_front-slot }\|{ ls_front-method };|.
    ENDLOOP.
    cl_abap_unit_assert=>assert_equals( exp = `MAIN|destroy;POPUP|destroy;POPOVER|destroy;`
                                        act = lv_actions ).

    " the called app opens a popup of its own - it replaces the queued
    " teardown instead of standing next to it

    CREATE OBJECT temp16 TYPE z2ui5_cl_ui5_frontend EXPORTING ACTION = lo_result.
    temp16->slot_display( slot = z2ui5_if_client=>cs_view-popup
                                                          xml  = `<Dialog id="next"/>` ).
    lv_actions = ``.
    LOOP AT lo_result->ms_next-t_action_front INTO ls_front.
      lv_actions = |{ lv_actions }{ ls_front-slot }\|{ ls_front-method };|.
    ENDLOOP.
    cl_abap_unit_assert=>assert_equals( exp = `MAIN|destroy;POPOVER|destroy;POPUP|display;`
                                        act = lv_actions ).

  ENDMETHOD.

  METHOD test_stack_call_cross_class.

    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.
    DATA temp17 TYPE z2ui5_if_ui5_types=>ty_t_system_action.
    DATA temp18 LIKE LINE OF temp17.
    DATA lv_actions TYPE string.
    DATA ls_front LIKE LINE OF lo_result->ms_next-t_action_front.

    CREATE OBJECT lo_http EXPORTING val = ``.
    CREATE OBJECT lo_action EXPORTING val = lo_http.
    CREATE OBJECT lo_action->mo_app->mo_app TYPE ltcl_test_app.
    lo_action->mo_app->ms_draft-id = `CURRENT_DRAFT`.

    " the leaving app tears its own view down and navigates to a DIFFERENT
    " class - the destroy must survive the hop (the called app may render
    " no MAIN view of its own), the display must not, and the popup/popover
    " teardown is queued as for every hop (the class does not matter - the
    " frontend no longer infers a teardown from it)

    CLEAR temp17.

    CLEAR temp18.
    temp18-slot = z2ui5_if_client=>cs_view-main.
    temp18-method = z2ui5_if_ui5_types=>cs_slot_action-destroy.
    INSERT temp18 INTO TABLE temp17.
    CLEAR temp18.
    temp18-slot = z2ui5_if_client=>cs_view-nested.
    temp18-method = z2ui5_if_ui5_types=>cs_slot_action-display.
    temp18-xml = `<Nest/>`.
    INSERT temp18 INTO TABLE temp17.
    lo_action->ms_next-t_action_front = temp17.
    CREATE OBJECT lo_action->ms_next-o_app_call TYPE ltcl_test_app2.

    lo_result = lo_action->factory_stack_call( ).


    lv_actions = ``.

    LOOP AT lo_result->ms_next-t_action_front INTO ls_front.
      lv_actions = |{ lv_actions }{ ls_front-slot }\|{ ls_front-method };|.
    ENDLOOP.
    cl_abap_unit_assert=>assert_equals( exp = `MAIN|destroy;POPUP|destroy;POPOVER|destroy;`
                                        act = lv_actions ).

    " no routing mode anywhere - a plain nav carries no NAV intent
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lo_result->ms_next-s_nav-check_nav_app_call ).

  ENDMETHOD.

  METHOD test_leave_keeps_messages.

    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA temp1 TYPE REF TO z2ui5_cl_ui5_handler.
    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp19 TYPE z2ui5_if_ui5_types=>ty_s_queued_action.
    DATA temp20 TYPE string_table.
    DATA temp22 TYPE REF TO ltcl_test_app.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.
    FIELD-SYMBOLS <temp23> LIKE LINE OF lo_result->ms_next-s_action-t_custom.
    DATA temp24 LIKE sy-tabix.
    FIELD-SYMBOLS <temp25> LIKE LINE OF lo_result->ms_next-s_action-t_custom.
    DATA temp26 LIKE sy-tabix.
    DATA temp4 TYPE xsdboolean.
    FIELD-SYMBOLS <temp27> LIKE LINE OF lo_result->ms_next-s_action-t_custom.
    DATA temp28 LIKE sy-tabix.
    DATA temp5 TYPE xsdboolean.
    CREATE OBJECT temp1 TYPE z2ui5_cl_ui5_handler EXPORTING val = ``.
    CREATE OBJECT lo_action TYPE z2ui5_cl_ui5_action EXPORTING val = temp1.
    CREATE OBJECT lo_action->mo_app->mo_app TYPE ltcl_test_app.
    lo_action->mo_app->ms_draft-id = `CURRENT_DRAFT`.

    CREATE OBJECT li_client TYPE z2ui5_cl_ui5_client EXPORTING action = lo_action.

    " a message of each kind, and an action that names the old screen
    li_client->message_toast_display( `Saved.` ).

    CLEAR temp19.
    temp19-o_json = z2ui5_cl_ajson=>parse( `["SET_FOCUS","input1"]` ).
    INSERT temp19
           INTO TABLE lo_action->ms_next-s_action-t_custom.
    li_client->message_box_display( text = `Check the quantity.`
                                    type = `warning` ).

    CLEAR temp20.
    INSERT `MESSAGE_TOAST` INTO TABLE temp20.
    INSERT `show` INTO TABLE temp20.
    INSERT `Also kept.` INTO TABLE temp20.
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-control_global
                                 t_arg = temp20 ).

    CREATE OBJECT temp22 TYPE ltcl_test_app.
    li_client->nav_app_leave( app           = temp22
                              keep_messages = abap_true ).


    lo_result = lo_action->factory_stack_leave( ).

    " the three messages in the order they were queued - the focus is gone
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lo_result->ms_next-s_action-t_custom ) ).


    temp24 = sy-tabix.
    READ TABLE lo_result->ms_next-s_action-t_custom INDEX 1 ASSIGNING <temp23>.
    sy-tabix = temp24.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["MESSAGE_TOAST","show","Saved."]`
        act = <temp23>-o_json->stringify( ) ).


    temp26 = sy-tabix.
    READ TABLE lo_result->ms_next-s_action-t_custom INDEX 2 ASSIGNING <temp25>.
    sy-tabix = temp26.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.

    temp4 = boolc( <temp25>-o_json->stringify( ) CS `["MESSAGE_BOX","warning","Check the quantity."` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp4 ).


    temp28 = sy-tabix.
    READ TABLE lo_result->ms_next-s_action-t_custom INDEX 3 ASSIGNING <temp27>.
    sy-tabix = temp28.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.

    temp5 = boolc( <temp27>-o_json->stringify( ) CS `"MESSAGE_TOAST","show","Also kept."` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp5 ).
    " the flag belongs to the hop - the target starts without it
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = lo_result->ms_next-keep_messages ).

  ENDMETHOD.

  METHOD test_call_keeps_messages.

    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA temp2 TYPE REF TO z2ui5_cl_ui5_handler.
    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp29 TYPE REF TO ltcl_test_app.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.
    FIELD-SYMBOLS <temp30> LIKE LINE OF lo_result->ms_next-s_action-t_custom.
    DATA temp31 LIKE sy-tabix.
    DATA temp5 TYPE REF TO z2ui5_cl_ui5_handler.
    DATA temp32 TYPE REF TO ltcl_test_app.
    CREATE OBJECT temp2 TYPE z2ui5_cl_ui5_handler EXPORTING val = ``.
    CREATE OBJECT lo_action TYPE z2ui5_cl_ui5_action EXPORTING val = temp2.
    CREATE OBJECT lo_action->mo_app->mo_app TYPE ltcl_test_app.
    lo_action->mo_app->ms_draft-id = `CURRENT_DRAFT`.

    CREATE OBJECT li_client TYPE z2ui5_cl_ui5_client EXPORTING action = lo_action.

    li_client->message_toast_display( `Order created.` ).

    CREATE OBJECT temp29 TYPE ltcl_test_app.
    li_client->nav_app_call( app           = temp29
                             keep_messages = abap_true ).

    lo_result = lo_action->factory_stack_call( ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_result->ms_next-s_action-t_custom ) ).


    temp31 = sy-tabix.
    READ TABLE lo_result->ms_next-s_action-t_custom INDEX 1 ASSIGNING <temp30>.
    sy-tabix = temp31.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["MESSAGE_TOAST","show","Order created."]`
        act = <temp30>-o_json->stringify( ) ).

    " without the flag the default stands: dropped with the screen

    CREATE OBJECT temp5 TYPE z2ui5_cl_ui5_handler EXPORTING val = ``.
    CREATE OBJECT lo_action TYPE z2ui5_cl_ui5_action EXPORTING val = temp5.
    CREATE OBJECT lo_action->mo_app->mo_app TYPE ltcl_test_app.
    lo_action->mo_app->ms_draft-id = `CURRENT_DRAFT_2`.
    CREATE OBJECT li_client TYPE z2ui5_cl_ui5_client EXPORTING action = lo_action.
    li_client->message_toast_display( `Order created.` ).

    CREATE OBJECT temp32 TYPE ltcl_test_app.
    li_client->nav_app_call( temp32 ).
    lo_result = lo_action->factory_stack_call( ).
    cl_abap_unit_assert=>assert_initial( lo_result->ms_next-s_action-t_custom ).

  ENDMETHOD.

  METHOD test_stack_leave.
    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.
    DATA temp33 TYPE z2ui5_if_ui5_types=>ty_s_queued_action.
    FIELD-SYMBOLS <temp34> LIKE LINE OF lo_result->ms_next-t_action_front.
    DATA temp35 LIKE sy-tabix.
    FIELD-SYMBOLS <temp6> LIKE LINE OF lo_result->ms_next-t_action_front.
    DATA temp7 LIKE sy-tabix.
    FIELD-SYMBOLS <temp36> LIKE LINE OF lo_result->ms_next-t_action_front.
    DATA temp37 LIKE sy-tabix.
    FIELD-SYMBOLS <temp8> LIKE LINE OF lo_result->ms_next-t_action_front.
    DATA temp9 LIKE sy-tabix.

    CREATE OBJECT lo_http EXPORTING val = ``.

    CREATE OBJECT lo_action EXPORTING val = lo_http.
    CREATE OBJECT lo_action->mo_app->mo_app TYPE ltcl_test_app.
    lo_action->mo_app->ms_draft-id = `CURRENT_DRAFT`.


    CREATE OBJECT lo_action->ms_next-o_app_leave TYPE ltcl_test_app.

    " frontend actions queued by the leaving app - messages travel as
    " follow-up actions too and must not leak into the app that is
    " navigated back to...

    CLEAR temp33.
    temp33-o_json = z2ui5_cl_ajson=>parse( `["SOME_ACTION"]` ).
    INSERT temp33 INTO TABLE lo_action->ms_next-s_action-t_custom.


    lo_result = lo_action->factory_stack_leave( ).

    cl_abap_unit_assert=>assert_bound( lo_result ).

    " leave behaves like call
    cl_abap_unit_assert=>assert_initial( lo_result->ms_next-s_action-t_custom ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_result->ms_next-t_action_front ) ).


    temp35 = sy-tabix.
    READ TABLE lo_result->ms_next-t_action_front INDEX 1 ASSIGNING <temp34>.
    sy-tabix = temp35.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp7 = sy-tabix.
    READ TABLE lo_result->ms_next-t_action_front INDEX 1 ASSIGNING <temp6>.
    sy-tabix = temp7.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `POPUP|destroy`
                                        act = |{ <temp34>-slot }\|| &&
                                              |{ <temp6>-method }| ).


    temp37 = sy-tabix.
    READ TABLE lo_result->ms_next-t_action_front INDEX 2 ASSIGNING <temp36>.
    sy-tabix = temp37.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp9 = sy-tabix.
    READ TABLE lo_result->ms_next-t_action_front INDEX 2 ASSIGNING <temp8>.
    sy-tabix = temp9.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `POPOVER|destroy`
                                        act = |{ <temp36>-slot }\|| &&
                                              |{ <temp8>-method }| ).

  ENDMETHOD.

  METHOD test_stack_leave_cross_class.

    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA lo_result TYPE REF TO z2ui5_cl_ui5_action.

    CREATE OBJECT lo_http EXPORTING val = ``.

    CREATE OBJECT lo_action EXPORTING val = lo_http.
    CREATE OBJECT lo_action->mo_app->mo_app TYPE ltcl_test_app.
    lo_action->mo_app->ms_draft-id = `CURRENT_DRAFT`.

    " back-navigation to a DIFFERENT class - the teardown of the standalone
    " slots travels as for every hop. The back-navigation event queues none
    " of its own (z2ui5_cl_ui5_handler=>main_process): every app switch ends
    " up in prepare_app_stack, the one place that queues it
    CREATE OBJECT lo_action->ms_next-o_app_leave TYPE ltcl_test_app2.

    lo_result = lo_action->factory_stack_leave( ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_result->ms_next-t_action_front ) ).

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
    CREATE OBJECT lo_target.
    CREATE OBJECT lo_target_core.
    lo_target_core->mo_app = lo_target.
    lo_target_core->ms_draft-id = `LEAVE_TARGET_DRAFT`.
    lo_target_core->ms_draft-id_prev_app_stack = `TARGET_OWN_ANCESTOR`.
    lo_target_core->db_save( ).

    " a leave two levels up: the current app's ancestor is NOT the target
    CREATE OBJECT lo_http EXPORTING val = ``.
    CREATE OBJECT lo_action EXPORTING val = lo_http.
    CREATE OBJECT lo_action->mo_app->mo_app TYPE ltcl_test_app.
    lo_action->mo_app->ms_draft-id = `LEAVE_GONE_CURRENT`.
    lo_action->mo_app->ms_draft-id_prev_app_stack = `LEAVE_MIDDLE_APP_DRAFT`.
    lo_action->ms_next-o_app_leave = lo_target.

    lo_result = lo_action->factory_stack_leave( ).

    cl_abap_unit_assert=>assert_equals( exp = `TARGET_OWN_ANCESTOR`
                                        act = lo_result->mo_app->ms_draft-id_prev_app_stack ).

    " ...and the ancestor row purged by cleanup( ) changes nothing: no read
    " of it is needed any more, so nothing can raise
    CREATE OBJECT lo_action EXPORTING val = lo_http.
    CREATE OBJECT lo_action->mo_app->mo_app TYPE ltcl_test_app.
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
    CREATE OBJECT lo_saved.
    CREATE OBJECT lo_saved->mo_app TYPE ltcl_test_app.
    lo_saved->ms_draft-id = `STICKY_DRAFT_STATELESS`.
    lo_saved->mv_check_sticky = abap_true.
    lo_saved->db_save( ).

    CREATE OBJECT lo_http EXPORTING val = ``.
    lo_http->ms_request-s_control-app_start_draft = `STICKY_DRAFT_STATELESS`.
    CREATE OBJECT lo_action EXPORTING val = lo_http.

    lo_result = lo_action->factory_first_start( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = lo_result->mo_app->mv_check_sticky ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = lo_result->mv_check_sticky_start ).

    " ...and kept in the stateful session it was saved in
    CREATE OBJECT lo_saved.
    CREATE OBJECT lo_saved->mo_app TYPE ltcl_test_app.
    lo_saved->ms_draft-id = `STICKY_DRAFT_STATEFUL`.
    lo_saved->mv_check_sticky = abap_true.
    lo_saved->db_save( ).

    CREATE OBJECT lo_http EXPORTING val = ``.
    lo_http->mv_session_sticky = abap_true.
    lo_http->ms_request-s_control-app_start_draft = `STICKY_DRAFT_STATEFUL`.
    CREATE OBJECT lo_action EXPORTING val = lo_http.

    lo_result = lo_action->factory_first_start( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = lo_result->mo_app->mv_check_sticky ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = lo_result->mv_check_sticky_start ).

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
    CREATE OBJECT lo_saved.
    CREATE OBJECT lo_saved->mo_app TYPE ltcl_test_app.
    lo_saved->ms_draft-id = `ROUTE_RESTORE_DRAFT`.
    lo_saved->db_save( ).

    CREATE OBJECT lo_http EXPORTING val = ``.
    lo_http->ms_request-s_control-app_start_draft = `ROUTE_RESTORE_DRAFT`.
    CREATE OBJECT lo_action EXPORTING val = lo_http.

    lo_result = lo_action->factory_first_start( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false act = lo_result->ms_next-s_nav-set_app_state_active ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = lo_result->mo_app->mv_app_state_active ).
    " a browser Back/Forward under KEEP routing restores like a start: the
    " app is on screen again, but no called app returned to it
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = lo_result->ms_actual-check_on_navigated ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = lo_result->ms_actual-check_nav_back ).

    " an app-state bookmark (#/z2ui5-xapp-state=<id>) is that opt-in
    CREATE OBJECT lo_saved.
    CREATE OBJECT lo_saved->mo_app TYPE ltcl_test_app.
    lo_saved->ms_draft-id = `STATE_RESTORE_DRAFT`.
    " the stack and caller of the session the bookmark was made in
    lo_saved->ms_draft-id_prev_app       = `DEAD_SESSION_CALLER`.
    lo_saved->ms_draft-id_prev_app_stack = `DEAD_SESSION_STACK`.
    lo_saved->db_save( ).

    CREATE OBJECT lo_http EXPORTING val = ``.
    lo_http->ms_request-s_control-app_start_draft = `STATE_RESTORE_DRAFT`.
    lo_http->ms_request-s_control-check_app_state = abap_true.
    CREATE OBJECT lo_action EXPORTING val = lo_http.

    lo_result = lo_action->factory_first_start( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = lo_result->ms_next-s_nav-set_app_state_active ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = lo_result->mo_app->mv_app_state_active ).
    " ... and it is a root of THIS session: neither the stack nor the
    " caller of the dead session survive (get_app_prev would otherwise
    " follow an expired draft into a 500)
    cl_abap_unit_assert=>assert_initial( lo_result->mo_app->ms_draft-id_prev_app_stack ).
    cl_abap_unit_assert=>assert_initial( lo_result->mo_app->ms_draft-id_prev_app ).
    " ... and no return from a called app (check_on_nav_back( ))
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = lo_result->ms_actual-check_nav_back ).

  ENDMETHOD.

ENDCLASS.
