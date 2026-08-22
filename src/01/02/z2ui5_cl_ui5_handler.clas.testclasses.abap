CLASS ltcl_app_nav_loop DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_app_nav_loop IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    DATA temp1 TYPE REF TO ltcl_app_nav_loop.
    CREATE OBJECT temp1 TYPE ltcl_app_nav_loop.
    client->nav_app_call( temp1 ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_app_noop DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA check_init TYPE abap_bool.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_app_noop IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    " deliberately neither displays nor pushes - the auto-model-update tests
    " need a main( ) that returns without touching the response
    check_init = client->check_on_init( ).
  ENDMETHOD.

ENDCLASS.

CLASS ltcl_app_sticky DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mv_init_log TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_app_sticky IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    DATA temp2 TYPE string.
    " record per roundtrip whether the framework treated it as the init
    " roundtrip - the sticky-latch test asserts the sequence
    IF mv_init_log IS NOT INITIAL.
      mv_init_log = mv_init_log && `|`.
    ENDIF.

    IF client->check_on_init( ) = abap_true.
      temp2 = `INIT`.
    ELSE.
      temp2 = `EVENT`.
    ENDIF.
    mv_init_log = mv_init_log && temp2.
  ENDMETHOD.

ENDCLASS.

CLASS ltcl_test_handler_post DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS load_startup_app       FOR TESTING RAISING cx_static_check.
    METHODS test_dispatch_loop_guard FOR TESTING RAISING cx_static_check.
    METHODS test_request_parse     FOR TESTING RAISING cx_static_check.
    METHODS test_request_origin    FOR TESTING RAISING cx_static_check.
    METHODS test_request_launchpad FOR TESTING RAISING cx_static_check.
    METHODS test_parse_body_with_wrapper    FOR TESTING RAISING cx_static_check.
    METHODS test_parse_body_no_wrapper FOR TESTING RAISING cx_static_check.
    METHODS test_parse_body_model  FOR TESTING RAISING cx_static_check.
    METHODS test_parse_body_model_no_wrap FOR TESTING RAISING cx_static_check.
    METHODS test_parse_body_config FOR TESTING RAISING cx_static_check.
    METHODS test_parse_body_no_config FOR TESTING RAISING cx_static_check.
    METHODS test_parse_body_arg_string FOR TESTING RAISING cx_static_check.
    METHODS test_parse_body_arg_object FOR TESTING RAISING cx_static_check.
    METHODS test_request_app_start FOR TESTING RAISING cx_static_check.
    METHODS test_request_with_id   FOR TESTING RAISING cx_static_check.
    METHODS test_response_json     FOR TESTING RAISING cx_static_check.
    METHODS test_view_update_flag  FOR TESTING RAISING cx_static_check.
    METHODS test_view_update_popup FOR TESTING RAISING cx_static_check.
    METHODS test_view_update_none  FOR TESTING RAISING cx_static_check.
    METHODS test_constructor       FOR TESTING RAISING cx_static_check.
    METHODS test_hash_app_part     FOR TESTING RAISING cx_static_check.
    METHODS test_route_standalone  FOR TESTING RAISING cx_static_check.
    METHODS test_route_launchpad   FOR TESTING RAISING cx_static_check.
    METHODS test_route_no_route    FOR TESTING RAISING cx_static_check.
    METHODS test_app_state_hash    FOR TESTING RAISING cx_static_check.
    METHODS test_nav_mode_resent   FOR TESTING RAISING cx_static_check.
    METHODS test_auto_update_push  FOR TESTING RAISING cx_static_check.
    METHODS test_auto_update_same  FOR TESTING RAISING cx_static_check.
    METHODS test_nested_display_push FOR TESTING RAISING cx_static_check.
    METHODS test_auto_update_snapshot FOR TESTING RAISING cx_static_check.
    METHODS test_session_stored       FOR TESTING RAISING cx_static_check.
    METHODS test_session_location     FOR TESTING RAISING cx_static_check.
    METHODS test_session_launchpad    FOR TESTING RAISING cx_static_check.
    METHODS test_session_from_draft   FOR TESTING RAISING cx_static_check.
    METHODS test_session_new_device   FOR TESTING RAISING cx_static_check.
    METHODS test_response_no_model    FOR TESTING RAISING cx_static_check.
    METHODS test_response_actions_embedded FOR TESTING RAISING cx_static_check.
    METHODS test_system_slot_order    FOR TESTING RAISING cx_static_check.
    METHODS test_system_last_wins     FOR TESTING RAISING cx_static_check.
    METHODS test_system_empty         FOR TESTING RAISING cx_static_check.
    METHODS test_system_destroy_only  FOR TESTING RAISING cx_static_check.

    "! the slots the serialized actions name, in order, deduplicated
    METHODS slot_sequence
      IMPORTING
        val           TYPE REF TO z2ui5_cl_ui5_handler
      RETURNING
        VALUE(result) TYPE string
      RAISING
        z2ui5_cx_ajson_error.

    "! the response's system actions, stringified and pipe-joined - so the
    "! auto-update/nav tests can assert on the queue like on text
    METHODS system_actions_of
      IMPORTING
        val           TYPE REF TO z2ui5_cl_ui5_handler
      RETURNING
        VALUE(result) TYPE string
      RAISING
        z2ui5_cx_ajson_error.
ENDCLASS.

CLASS z2ui5_cl_ui5_handler DEFINITION LOCAL FRIENDS ltcl_test_handler_post.

CLASS ltcl_test_handler_post IMPLEMENTATION.

  METHOD load_startup_app.
    DATA lv_payload TYPE string.
    DATA lo_post TYPE REF TO z2ui5_cl_ui5_handler.
    DATA temp1 TYPE REF TO z2ui5_cl_ui5_app_start.
    DATA lo_startup LIKE temp1.

    lv_payload = `{"value" : { "S_FRONT":{"ORIGIN":"ORIGIN","PATHNAME":"PATHNAME","SEARCH":""}}}`.

    CREATE OBJECT lo_post EXPORTING val = lv_payload.
    lo_post->main_begin( ).

    cl_abap_unit_assert=>assert_bound( lo_post->mo_action ).

    cl_abap_unit_assert=>assert_equals( exp = `ORIGIN`
                                        act = lo_post->ms_request-s_front-origin ).

    cl_abap_unit_assert=>assert_equals( exp = `PATHNAME`
                                        act = lo_post->ms_request-s_front-pathname ).


    temp1 ?= lo_post->mo_action->mo_app->mo_app.

    lo_startup = temp1.

  ENDMETHOD.

  METHOD test_request_parse.

    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.
    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"https://myhost.com","PATHNAME":"/sap/test","SEARCH":"?param=1"}}}`.

    CREATE OBJECT lo_handler EXPORTING val = lv_payload.

    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = `https://myhost.com`
                                        act = ls_request-s_front-origin ).
    cl_abap_unit_assert=>assert_equals( exp = `/sap/test`
                                        act = ls_request-s_front-pathname ).
    cl_abap_unit_assert=>assert_equals( exp = `?param=1`
                                        act = ls_request-s_front-search ).

  ENDMETHOD.

  METHOD test_request_origin.

    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.
    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"https://example.org","PATHNAME":"/app","SEARCH":""}}}`.

    CREATE OBJECT lo_handler EXPORTING val = lv_payload.

    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = `https://example.org`
                                        act = ls_request-s_front-origin ).

  ENDMETHOD.

  METHOD test_request_launchpad.

    " the flag is derived in session_merge from the MERGED location, not in
    " the raw parse - pathname/search only travel on app-start-shaped
    " requests (see test_session_launchpad for the restore cadence)
    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/ui2/flp","SEARCH":"?scenario=LAUNCHPAD"}}}`.

    CREATE OBJECT lo_handler EXPORTING val = lv_payload.
    lo_handler->ms_request = lo_handler->request_json_to_abap( lv_payload ).

    lo_handler->session_merge( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_handler->ms_request-s_control-check_launchpad ).

  ENDMETHOD.

  METHOD test_parse_body_with_wrapper.
    " Standalone scenario: frontend wraps body in {"value": ...}
    " This is the standard case when the app runs outside the Fiori Launchpad.
    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.
    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"https://myhost.com","PATHNAME":"/sap/bc/z2ui5","SEARCH":""}}}`.

    CREATE OBJECT lo_handler EXPORTING val = lv_payload.
    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = `https://myhost.com`
                                        act = ls_request-s_front-origin ).
    cl_abap_unit_assert=>assert_equals( exp = `/sap/bc/z2ui5`
                                        act = ls_request-s_front-pathname ).
  ENDMETHOD.

  METHOD test_parse_body_no_wrapper.
    " Launchpad/Gateway scenario: FLP proxy strips the {"value": ...} envelope
    " before the request reaches the ABAP ICF handler, so the body arrives
    " as a plain object without the value key.
    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.
    lv_payload = `{"S_FRONT":{"ORIGIN":"https://myhost.com","PATHNAME":"/ui2/flp","SEARCH":"?scenario=LAUNCHPAD"}}`.

    CREATE OBJECT lo_handler EXPORTING val = lv_payload.
    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = `https://myhost.com`
                                        act = ls_request-s_front-origin ).

    " the launchpad flag is derived in session_merge from the merged location
    lo_handler->ms_request = ls_request.
    lo_handler->session_merge( ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_handler->ms_request-s_control-check_launchpad ).
  ENDMETHOD.

  METHOD test_parse_body_model.
    " the view model is extracted from the request MODEL container and has to
    " stay reachable under /... for main_json_to_attri
    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.
    lv_payload = `{"value":{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":""},"MODEL":{"NAME":"test-value"}}}`.

    CREATE OBJECT lo_handler EXPORTING val = lv_payload.
    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_bound( ls_request-o_model ).
    cl_abap_unit_assert=>assert_equals( exp = `test-value`
                                        act = ls_request-o_model->get_string( `/NAME` ) ).
  ENDMETHOD.

  METHOD test_parse_body_model_no_wrap.
    " launchpad/gateway scenario: the model extraction also has to work
    " when the value envelope was stripped by the infrastructure
    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.
    lv_payload = `{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":""},"MODEL":{"NAME":"test-value"}}`.

    CREATE OBJECT lo_handler EXPORTING val = lv_payload.
    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_bound( ls_request-o_model ).
    cl_abap_unit_assert=>assert_equals( exp = `test-value`
                                        act = ls_request-o_model->get_string( `/NAME` ) ).
  ENDMETHOD.

  METHOD test_parse_body_config.

    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.
    lv_payload = `{"value":{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":"",` &&
                 `"CONFIG":{"ComponentData":{"startupParameters":{}},` &&
                 `"S_DEVICE":{"SYSTEM":"desktop"},` &&
                 `"S_FOCUS":{"ID":"my-input","SELECTION_START":2,"SELECTION_END":5},` &&
                 `"S_SCROLL":{"MAIN":{"ID":"page","X":0,"Y":150}},` &&
                 `"S_UI5":{"VERSION":"1.120.0","BUILDTIMESTAMP":"20240101","GAV":"com.sap.ui:sdk:1.120.0","THEME":"sap_horizon"}}}}}`.

    CREATE OBJECT lo_handler EXPORTING val = lv_payload.
    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_bound( ls_request-s_front-o_comp_data ).
    cl_abap_unit_assert=>assert_equals( exp = `desktop`
                                        act = ls_request-s_front-s_device-system ).
    cl_abap_unit_assert=>assert_equals( exp = `my-input`
                                        act = ls_request-s_front-s_focus-id ).
    cl_abap_unit_assert=>assert_equals( exp = 150
                                        act = ls_request-s_front-s_scroll-main-y ).
    cl_abap_unit_assert=>assert_equals( exp = `1.120.0`
                                        act = ls_request-s_front-s_ui5-version ).
    cl_abap_unit_assert=>assert_equals( exp = `20240101`
                                        act = ls_request-s_front-s_ui5-build_timestamp ).
    cl_abap_unit_assert=>assert_equals( exp = `sap_horizon`
                                        act = ls_request-s_front-s_ui5-theme ).

  ENDMETHOD.

  METHOD test_parse_body_no_config.
    " a request without CONFIG section has to parse without errors and
    " leave the config fields initial
    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.
    lv_payload = `{"value":{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":""}}}`.

    CREATE OBJECT lo_handler EXPORTING val = lv_payload.
    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_not_bound( ls_request-s_front-o_comp_data ).
    cl_abap_unit_assert=>assert_initial( ls_request-s_front-s_device ).
    cl_abap_unit_assert=>assert_initial( ls_request-s_front-s_ui5 ).

  ENDMETHOD.

  METHOD test_parse_body_arg_string.
    " plain string arguments take the unchanged to_abap path
    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.
    DATA temp3 LIKE LINE OF ls_request-s_front-t_event_arg.
    DATA temp4 LIKE sy-tabix.
    DATA temp5 LIKE LINE OF ls_request-s_front-t_event_arg.
    DATA temp6 LIKE sy-tabix.
    lv_payload = `{"value":{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":"",` &&
                 `"EVENT":"MY_EVENT","T_EVENT_ARG":["first","second"]}}}`.

    CREATE OBJECT lo_handler EXPORTING val = lv_payload.
    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( ls_request-s_front-t_event_arg ) ).


    temp4 = sy-tabix.
    READ TABLE ls_request-s_front-t_event_arg INDEX 1 INTO temp3.
    sy-tabix = temp4.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `first`
                                        act = temp3 ).


    temp6 = sy-tabix.
    READ TABLE ls_request-s_front-t_event_arg INDEX 2 INTO temp5.
    sy-tabix = temp6.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `second`
                                        act = temp5 ).
  ENDMETHOD.

  METHOD test_parse_body_arg_object.
    " object and array arguments arrive as raw JSON from the frontend and
    " have to reach the app as JSON strings, scalar arguments in the same
    " event keep their previous string form
    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.
    DATA temp7 LIKE LINE OF ls_request-s_front-t_event_arg.
    DATA temp8 LIKE sy-tabix.
    DATA temp9 LIKE LINE OF ls_request-s_front-t_event_arg.
    DATA temp10 LIKE sy-tabix.
    DATA temp11 LIKE LINE OF ls_request-s_front-t_event_arg.
    DATA temp12 LIKE sy-tabix.
    DATA temp13 LIKE LINE OF ls_request-s_front-t_event_arg.
    DATA temp14 LIKE sy-tabix.
    DATA temp15 LIKE LINE OF ls_request-s_front-t_event_arg.
    DATA temp16 LIKE sy-tabix.
    lv_payload = `{"value":{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":"",` &&
                 `"EVENT":"MY_EVENT","T_EVENT_ARG":["plain",5,true,{"KEY":"val"},[1,2]]}}}`.

    CREATE OBJECT lo_handler EXPORTING val = lv_payload.
    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = 5
                                        act = lines( ls_request-s_front-t_event_arg ) ).


    temp8 = sy-tabix.
    READ TABLE ls_request-s_front-t_event_arg INDEX 1 INTO temp7.
    sy-tabix = temp8.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `plain`
                                        act = temp7 ).


    temp10 = sy-tabix.
    READ TABLE ls_request-s_front-t_event_arg INDEX 2 INTO temp9.
    sy-tabix = temp10.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `5`
                                        act = temp9 ).


    temp12 = sy-tabix.
    READ TABLE ls_request-s_front-t_event_arg INDEX 3 INTO temp11.
    sy-tabix = temp12.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `X`
                                        act = temp11 ).


    temp14 = sy-tabix.
    READ TABLE ls_request-s_front-t_event_arg INDEX 4 INTO temp13.
    sy-tabix = temp14.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `{"KEY":"val"}`
                                        act = temp13 ).


    temp16 = sy-tabix.
    READ TABLE ls_request-s_front-t_event_arg INDEX 5 INTO temp15.
    sy-tabix = temp16.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `[1,2]`
                                        act = temp15 ).
  ENDMETHOD.

  METHOD test_request_app_start.

    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.
    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":"?app_start=Z2UI5_CL_UI5_APP_HI_WORLD"}}}`.

    CREATE OBJECT lo_handler EXPORTING val = lv_payload.

    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = `Z2UI5_CL_UI5_APP_HI_WORLD`
                                        act = ls_request-s_control-app_start ).

  ENDMETHOD.

  METHOD test_request_with_id.

    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.
    lv_payload = `{"value":{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":""}}}`.

    CREATE OBJECT lo_handler EXPORTING val = lv_payload.

    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = `ABC123`
                                        act = ls_request-s_front-id ).

  ENDMETHOD.

  METHOD test_response_json.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA temp2 TYPE z2ui5_if_ui5_types=>ty_s_response.
    DATA ls_response LIKE temp2.
    DATA lv_json TYPE string.
    DATA temp1 TYPE xsdboolean.
    DATA temp3 TYPE xsdboolean.
    DATA temp4 TYPE xsdboolean.
    DATA temp5 TYPE xsdboolean.
    DATA temp6 TYPE xsdboolean.
    DATA temp7 TYPE xsdboolean.
    CREATE OBJECT lo_handler EXPORTING val = ``.

    CLEAR temp2.
    temp2-s_front-id = `ID123`.
    temp2-s_front-app = `Z2UI5_CL_UI5_APP_HI_WORLD`.
    temp2-model = `{"name":"test"}`.

    ls_response = temp2.


    lv_json = lo_handler->response_abap_to_json( ls_response ).



    temp5 = boolc( lv_json CS `S_FRONT` ).
    temp1 = temp5.
    cl_abap_unit_assert=>assert_true( temp1 ).


    temp6 = boolc( lv_json CS `MODEL` ).
    temp3 = temp6.
    cl_abap_unit_assert=>assert_true( temp3 ).


    temp7 = boolc( lv_json CS `{"name":"test"}` ).
    temp4 = temp7.
    cl_abap_unit_assert=>assert_true( temp4 ).

  ENDMETHOD.

  METHOD test_session_stored.

    " the first roundtrip of a page load carries the block - it is stored on
    " the app, and therefore in its draft
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    CREATE OBJECT lo_handler EXPORTING val = ``.
    lo_handler->ms_request-s_front-s_device-system   = `desktop`.
    lo_handler->ms_request-s_front-s_device-os-name  = `Windows`.
    lo_handler->ms_request-s_front-s_ui5-version     = `1.120.0`.

    lo_handler->session_merge( ).

    cl_abap_unit_assert=>assert_equals( exp = `desktop`
                                        act = lo_handler->mo_action->mo_app->ms_session-s_device-system ).
    cl_abap_unit_assert=>assert_equals( exp = `1.120.0`
                                        act = lo_handler->mo_action->mo_app->ms_session-s_ui5-version ).

  ENDMETHOD.

  METHOD test_session_location.

    " the page location travels with app-start-shaped requests and is stored
    " with the draft; an event roundtrip omits it and reads it back
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    CREATE OBJECT lo_handler EXPORTING val = ``.
    lo_handler->ms_request-s_front-origin   = `https://host`.
    lo_handler->ms_request-s_front-pathname = `/sap/bc/z2ui5`.
    lo_handler->ms_request-s_front-search   = `?app_start=Z_MY_APP`.
    " the real first roundtrip of a page load carries the device/UI5 block
    " TOO - storing that block must not wipe the location just stored
    lo_handler->ms_request-s_front-s_device-system = `desktop`.
    lo_handler->ms_request-s_front-s_ui5-version   = `1.120.0`.

    lo_handler->session_merge( ).

    cl_abap_unit_assert=>assert_equals( exp = `https://host`
                                        act = lo_handler->mo_action->mo_app->ms_session-origin ).

    " ...the follow-up event roundtrip carries none of it
    CLEAR: lo_handler->ms_request-s_front-origin,
           lo_handler->ms_request-s_front-pathname,
           lo_handler->ms_request-s_front-search,
           lo_handler->ms_request-s_front-s_device,
           lo_handler->ms_request-s_front-s_ui5.

    lo_handler->session_merge( ).

    cl_abap_unit_assert=>assert_equals( exp = `https://host`
                                        act = lo_handler->ms_request-s_front-origin ).
    cl_abap_unit_assert=>assert_equals( exp = `/sap/bc/z2ui5`
                                        act = lo_handler->ms_request-s_front-pathname ).
    cl_abap_unit_assert=>assert_equals( exp = `?app_start=Z_MY_APP`
                                        act = lo_handler->ms_request-s_front-search ).

  ENDMETHOD.

  METHOD test_session_launchpad.

    " the launchpad flag is derived from the MERGED location: the FLP start
    " request carries the pathname once, every later event roundtrip omits
    " it and must still read check_launchpad from the draft-restored value
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    CREATE OBJECT lo_handler EXPORTING val = ``.
    lo_handler->ms_request-s_front-origin   = `https://host`.
    lo_handler->ms_request-s_front-pathname = `/sap/bc/ui2/flp`.
    lo_handler->ms_request-s_front-s_device-system = `desktop`.
    lo_handler->ms_request-s_front-s_ui5-version   = `1.120.0`.

    lo_handler->session_merge( ).

    cl_abap_unit_assert=>assert_true( lo_handler->ms_request-s_control-check_launchpad ).

    CLEAR: lo_handler->ms_request-s_front-origin,
           lo_handler->ms_request-s_front-pathname,
           lo_handler->ms_request-s_front-search,
           lo_handler->ms_request-s_front-s_device,
           lo_handler->ms_request-s_front-s_ui5,
           lo_handler->ms_request-s_control.

    lo_handler->session_merge( ).

    cl_abap_unit_assert=>assert_true( lo_handler->ms_request-s_control-check_launchpad ).

  ENDMETHOD.

  METHOD test_session_from_draft.

    " a later roundtrip sends none of it and is answered from the draft - but
    " orientation and resize are NOT session-constant and win from the request
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    CREATE OBJECT lo_handler EXPORTING val = ``.
    CLEAR lo_handler->mo_action->mo_app->ms_session.
    lo_handler->mo_action->mo_app->ms_session-s_ui5-version = `1.120.0`.
    lo_handler->mo_action->mo_app->ms_session-s_device-system = `phone`.
    lo_handler->mo_action->mo_app->ms_session-s_device-os-name = `iOS`.
    lo_handler->mo_action->mo_app->ms_session-s_device-orientation = `portrait`.
    lo_handler->mo_action->mo_app->ms_session-s_device-resize-width = 400.

    lo_handler->ms_request-s_front-s_device-orientation  = `landscape`.
    lo_handler->ms_request-s_front-s_device-resize-width = 900.

    lo_handler->session_merge( ).

    cl_abap_unit_assert=>assert_equals( exp = `phone`
                                        act = lo_handler->ms_request-s_front-s_device-system ).
    cl_abap_unit_assert=>assert_equals( exp = `1.120.0`
                                        act = lo_handler->ms_request-s_front-s_ui5-version ).
    cl_abap_unit_assert=>assert_equals( exp = `landscape`
                                        act = lo_handler->ms_request-s_front-s_device-orientation ).
    cl_abap_unit_assert=>assert_equals( exp = 900
                                        act = lo_handler->ms_request-s_front-s_device-resize-width ).

  ENDMETHOD.

  METHOD test_session_new_device.

    " the same draft reopened from ANOTHER browser: its first roundtrip
    " carries a block again, and that block replaces what the draft held
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    CREATE OBJECT lo_handler EXPORTING val = ``.
    CLEAR lo_handler->mo_action->mo_app->ms_session.
    lo_handler->mo_action->mo_app->ms_session-s_device-system = `phone`.
    lo_handler->mo_action->mo_app->ms_session-s_device-os-name = `iOS`.

    lo_handler->ms_request-s_front-s_device-system  = `desktop`.
    lo_handler->ms_request-s_front-s_device-os-name = `Windows`.

    lo_handler->session_merge( ).

    cl_abap_unit_assert=>assert_equals( exp = `desktop`
                                        act = lo_handler->mo_action->mo_app->ms_session-s_device-system ).
    cl_abap_unit_assert=>assert_equals( exp = `Windows`
                                        act = lo_handler->mo_action->mo_app->ms_session-s_device-os-name ).

  ENDMETHOD.

  METHOD test_response_actions_embedded.

    " the action lists leave as REAL nested JSON arrays, not as escaped
    " strings - and an empty-string positional placeholder inside an action
    " survives, because the queues are written AFTER the no-empty-values
    " filter ran
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_response TYPE z2ui5_if_ui5_types=>ty_s_response.
    DATA temp17 TYPE z2ui5_if_ui5_types=>ty_s_queued_action.
    DATA temp18 TYPE z2ui5_if_ui5_types=>ty_s_queued_action.
    DATA temp19 TYPE z2ui5_if_ui5_types=>ty_s_queued_action.
    DATA lv_json TYPE string.
    DATA temp8 TYPE xsdboolean.
    DATA temp9 TYPE xsdboolean.
    CREATE OBJECT lo_handler EXPORTING val = ``.
    ls_response-s_front-id = `ID123`.

    CLEAR temp17.
    temp17-o_json = z2ui5_cl_ajson=>parse( `["CONTROL_BY_ID","tab","","setHiddenInPopin",{"A":1}]` ).
    INSERT temp17
           INTO TABLE ls_response-s_front-s_action-t_system.

    CLEAR temp18.
    temp18-o_json = z2ui5_cl_ajson=>parse( `["SET_FOCUS","id1"]` ).
    INSERT temp18
           INTO TABLE ls_response-s_front-s_action-t_custom.
    " a legacy raw-JS snippet an app queued keeps riding as a string entry

    CLEAR temp19.
    temp19-js = `eF('SET_FOCUS','id2')`.
    INSERT temp19
           INTO TABLE ls_response-s_front-s_action-t_custom.


    lv_json = lo_handler->response_abap_to_json( ls_response ).


    temp8 = boolc( lv_json CS `"T_SYSTEM":[["CONTROL_BY_ID","tab","","setHiddenInPopin",{"A":1}]]` ).
    cl_abap_unit_assert=>assert_true(
        temp8 ).

    temp9 = boolc( lv_json CS `"T_CUSTOM":[["SET_FOCUS","id1"],"eF('SET_FOCUS','id2')"]` ).
    cl_abap_unit_assert=>assert_true(
        temp9 ).

  ENDMETHOD.

  METHOD test_response_no_model.

    " a round-trip that changed nothing bound sends no MODEL key at all
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_response TYPE z2ui5_if_ui5_types=>ty_s_response.
    DATA lv_json TYPE string.
    DATA temp10 TYPE xsdboolean.
    DATA temp11 TYPE xsdboolean.
    DATA temp12 TYPE xsdboolean.
    CREATE OBJECT lo_handler EXPORTING val = ``.
    ls_response-s_front-id = `ID123`.


    lv_json = lo_handler->response_abap_to_json( ls_response ).


    temp10 = boolc( lv_json CS `MODEL` ).
    cl_abap_unit_assert=>assert_false( temp10 ).

    temp11 = boolc( lv_json CS `S_FRONT` ).
    cl_abap_unit_assert=>assert_true( temp11 ).

    " and an explicitly empty one is treated the same
    ls_response-model = `{}`.
    lv_json = lo_handler->response_abap_to_json( ls_response ).

    temp12 = boolc( lv_json CS `MODEL` ).
    cl_abap_unit_assert=>assert_false( temp12 ).

  ENDMETHOD.

  METHOD test_system_slot_order.

    " The app displays in whatever order suits it - here nested first, main
    " last. The list that leaves goes MAIN, NEST, NEST2, POPUP, POPOVER: a
    " nested view is inserted INTO the main control tree, so it cannot be
    " built before the page it belongs to exists.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp20 TYPE REF TO z2ui5_cl_ui5_frontend.
    CREATE OBJECT lo_handler EXPORTING val = ``.
    CREATE OBJECT li_client TYPE z2ui5_cl_ui5_client EXPORTING ACTION = lo_handler->mo_action.

    li_client->popover_display( xml   = `<Popover/>`
                                by_id = `btn` ).
    li_client->nest2_view_display( val           = `<Nest2/>`
                                   id            = `n2`
                                   method_insert = `addEndColumnPage` ).
    li_client->nest_view_display( val           = `<Nest/>`
                                  id            = `n1`
                                  method_insert = `addMidColumnPage` ).
    li_client->popup_display( `<Dialog/>` ).
    li_client->view_display( `<View/>` ).


    CREATE OBJECT temp20 TYPE z2ui5_cl_ui5_frontend EXPORTING ACTION = lo_handler->mo_action.
    temp20->slots_serialize( ).

    cl_abap_unit_assert=>assert_equals(
        exp = `MAIN|NEST|NEST2|POPUP|POPOVER`
        act = slot_sequence( lo_handler ) ).

  ENDMETHOD.

  METHOD test_system_last_wins.

    " A slot displayed twice is displayed ONCE, with the last XML: the
    " second call drops everything the first queued. No destroy action
    " travels with a display - the frontend tears the slot down implicitly,
    " a display REPLACES the slot.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp21 TYPE REF TO z2ui5_cl_ui5_frontend.
    DATA lt_js LIKE lo_handler->mo_action->ms_next-s_action-t_system.
    DATA temp22 LIKE LINE OF lt_js.
    DATA temp23 LIKE sy-tabix.
    CREATE OBJECT lo_handler EXPORTING val = ``.
    CREATE OBJECT li_client TYPE z2ui5_cl_ui5_client EXPORTING ACTION = lo_handler->mo_action.

    li_client->view_display( `<First/>` ).
    li_client->view_display( `<Second/>` ).


    CREATE OBJECT temp21 TYPE z2ui5_cl_ui5_frontend EXPORTING ACTION = lo_handler->mo_action.
    temp21->slots_serialize( ).


    lt_js = lo_handler->mo_action->ms_next-s_action-t_system.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_js ) ).


    temp23 = sy-tabix.
    READ TABLE lt_js INDEX 1 INTO temp22.
    sy-tabix = temp23.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["VIEW_SLOTS","display","MAIN","<Second/>"]`
        act = temp22-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_system_empty.

    " a roundtrip that touches no slot sends no system action at all
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA temp24 TYPE REF TO z2ui5_cl_ui5_frontend.
    CREATE OBJECT lo_handler EXPORTING val = ``.


    CREATE OBJECT temp24 TYPE z2ui5_cl_ui5_frontend EXPORTING ACTION = lo_handler->mo_action.
    temp24->slots_serialize( ).

    cl_abap_unit_assert=>assert_initial(
        lo_handler->mo_action->ms_next-s_action-t_system ).

  ENDMETHOD.

  METHOD test_system_destroy_only.

    " A bare destroy - popup_destroy( ) without a follow-up display - leaves
    " as exactly ["VIEW_SLOTS","destroy","POPUP"]: three entries, no XML
    " argument and no options object ride along
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp25 TYPE REF TO z2ui5_cl_ui5_frontend.
    DATA lt_js LIKE lo_handler->mo_action->ms_next-s_action-t_system.
    DATA temp26 LIKE LINE OF lt_js.
    DATA temp27 LIKE sy-tabix.
    CREATE OBJECT lo_handler EXPORTING val = ``.
    CREATE OBJECT li_client TYPE z2ui5_cl_ui5_client EXPORTING ACTION = lo_handler->mo_action.

    li_client->popup_destroy( ).


    CREATE OBJECT temp25 TYPE z2ui5_cl_ui5_frontend EXPORTING ACTION = lo_handler->mo_action.
    temp25->slots_serialize( ).


    lt_js = lo_handler->mo_action->ms_next-s_action-t_system.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_js ) ).


    temp27 = sy-tabix.
    READ TABLE lt_js INDEX 1 INTO temp26.
    sy-tabix = temp27.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["VIEW_SLOTS","destroy","POPUP"]`
        act = temp26-o_json->stringify( ) ).

  ENDMETHOD.


  METHOD system_actions_of.

    DATA ls_queued LIKE LINE OF val->ms_response-s_front-s_action-t_system.
      DATA temp28 TYPE string.
    LOOP AT val->ms_response-s_front-s_action-t_system INTO ls_queued.
      IF result IS NOT INITIAL.
        result = result && `|`.
      ENDIF.

      IF ls_queued-o_json IS BOUND.
        temp28 = ls_queued-o_json->stringify( ).
      ELSE.
        temp28 = ls_queued-js.
      ENDIF.
      result = result && temp28.
    ENDLOOP.

  ENDMETHOD.

  METHOD slot_sequence.

    " the slots named by the serialized actions, in order, each one once -
    " so the assertion reads as the sequence and not as a payload dump
    DATA ls_queued LIKE LINE OF val->mo_action->ms_next-s_action-t_system.
      DATA lv_js TYPE string.
      TYPES temp1 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_part TYPE temp1.
      DATA temp29 TYPE string.
      DATA temp30 TYPE string.
      DATA lv_slot TYPE string.
    LOOP AT val->mo_action->ms_next-s_action-t_system INTO ls_queued.

      lv_js = ls_queued-o_json->stringify( ).


      SPLIT lv_js AT `","` INTO TABLE lt_part.

      CLEAR temp29.

      READ TABLE lt_part INTO temp30 INDEX 3.
      IF sy-subrc = 0.
        temp29 = temp30.
      ENDIF.

      lv_slot = replace( val  = temp29
                               sub  = `"]`
                               with = `` ).
      IF result CS lv_slot.
        CONTINUE.
      ENDIF.
      IF result IS NOT INITIAL.
        result = result && `|`.
      ENDIF.
      result = result && lv_slot.
    ENDLOOP.

  ENDMETHOD.

  METHOD test_view_update_flag.

    " every slot displays through a system action, and main_end derives
    " `did this roundtrip ship a view?` (the model has to travel with new
    " XML) from exactly those collected calls - no separate flag to keep in
    " sync, no slot of the response read back
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp13 TYPE xsdboolean.
    DATA temp1 LIKE sy-subrc.
    CREATE OBJECT lo_handler EXPORTING val = ``.

    CREATE OBJECT li_client TYPE z2ui5_cl_ui5_client EXPORTING ACTION = lo_handler->mo_action.
    li_client->view_display( `<View/>` ).



    READ TABLE lo_handler->mo_action->ms_next-t_action_front WITH KEY method = `display` TRANSPORTING NO FIELDS.
    temp1 = sy-subrc.
    temp13 = boolc( temp1 = 0 ).
    cl_abap_unit_assert=>assert_true(
        temp13 ).

  ENDMETHOD.

  METHOD test_view_update_popup.

    " the same holds whichever slot was displayed...
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp14 TYPE xsdboolean.
    DATA temp2 LIKE sy-subrc.
    DATA temp15 TYPE xsdboolean.
    DATA temp3 LIKE sy-subrc.
    CREATE OBJECT lo_handler EXPORTING val = ``.

    CREATE OBJECT li_client TYPE z2ui5_cl_ui5_client EXPORTING ACTION = lo_handler->mo_action.
    li_client->popup_display( `<Dialog/>` ).



    READ TABLE lo_handler->mo_action->ms_next-t_action_front WITH KEY method = `display` TRANSPORTING NO FIELDS.
    temp2 = sy-subrc.
    temp14 = boolc( temp2 = 0 ).
    cl_abap_unit_assert=>assert_true(
        temp14 ).

    " ...and a display a later destroy voided counts as NO view, so the
    " model is not sent for a dialog that never reaches the browser
    li_client->popup_destroy( ).



    READ TABLE lo_handler->mo_action->ms_next-t_action_front WITH KEY method = `display` TRANSPORTING NO FIELDS.
    temp3 = sy-subrc.
    temp15 = boolc( temp3 = 0 ).
    cl_abap_unit_assert=>assert_false(
        temp15 ).

  ENDMETHOD.

  METHOD test_view_update_none.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA temp16 TYPE xsdboolean.
    DATA temp4 LIKE sy-subrc.
    CREATE OBJECT lo_handler EXPORTING val = ``.



    READ TABLE lo_handler->mo_action->ms_next-t_action_front WITH KEY method = `display` TRANSPORTING NO FIELDS.
    temp4 = sy-subrc.
    temp16 = boolc( temp4 = 0 ).
    cl_abap_unit_assert=>assert_false(
        temp16 ).

  ENDMETHOD.

  METHOD test_dispatch_loop_guard.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_loop_app TYPE REF TO ltcl_app_nav_loop.
    DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.

    " an app that calls nav_app_call unconditionally in main( ) must not
    " loop the dispatch forever - the handler raises once the limit is hit
    CREATE OBJECT lo_handler EXPORTING val = ``.
    lo_handler->mv_dispatch_limit = 5.
    CREATE OBJECT lo_loop_app.
    lo_handler->mo_action->mo_app->mo_app = lo_loop_app.
    " db_save asserts a draft id, normally set by the action factories
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).

    TRY.
        lo_handler->main_loop( ).
        cl_abap_unit_assert=>fail( `dispatch loop guard did not raise` ).
      CATCH z2ui5_cx_ui5_util_error INTO lx.
        cl_abap_unit_assert=>assert_char_cp( act = lx->get_text( )
                                             exp = `*nav_app_call*` ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_constructor.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    CREATE OBJECT lo_handler EXPORTING val = `test payload`.

    cl_abap_unit_assert=>assert_equals( exp = `test payload`
                                        act = lo_handler->mv_request_json ).
    cl_abap_unit_assert=>assert_bound( lo_handler->mo_action ).

  ENDMETHOD.

  METHOD test_hash_app_part.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    CREATE OBJECT lo_handler EXPORTING val = ``.

    " standalone - the whole hash belongs to the app
    cl_abap_unit_assert=>assert_equals( exp = `/app/ZCL_X/D1`
                                        act = lo_handler->hash_get_app_part( `#/app/ZCL_X/D1` ) ).

    " launchpad - the shell owns everything before '&/'
    cl_abap_unit_assert=>assert_equals( exp = `app/ZCL_X/D1`
                                        act = lo_handler->hash_get_app_part( `#Z2UI5-display&/app/ZCL_X/D1` ) ).

    " ... including a shell hash that carries its own parameters
    cl_abap_unit_assert=>assert_equals( exp = `app/ZCL_X`
                                        act = lo_handler->hash_get_app_part( `#Z2UI5-display?a=b&c=d&/app/ZCL_X` ) ).

    " an app hash containing '&/' must not be split
    cl_abap_unit_assert=>assert_equals( exp = `/app/ZCL_X/D1?next=&/y`
                                        act = lo_handler->hash_get_app_part( `#/app/ZCL_X/D1?next=&/y` ) ).

    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = lo_handler->hash_get_app_part( `` ) ).

  ENDMETHOD.

  METHOD test_route_standalone.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    CREATE OBJECT lo_handler EXPORTING val = ``.

    cl_abap_unit_assert=>assert_equals( exp = `ZCL_X`
                                        act = lo_handler->request_app_start_route( `#/app/ZCL_X/D1` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `D1`
                                        act = lo_handler->request_app_start_route_draft( `#/app/ZCL_X/D1` ) ).

    " class-only route (routing mode FRESH) carries no draft
    cl_abap_unit_assert=>assert_equals( exp = `ZCL_X`
                                        act = lo_handler->request_app_start_route( `#/app/ZCL_X` ) ).
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = lo_handler->request_app_start_route_draft( `#/app/ZCL_X` ) ).

    " the double-slash form the UI5 HashChanger wrote before navTo stripped
    " its slash (hasher prepends one of its own) - lives on in bookmarks and
    " browser history entries, and Back/Forward sends exactly this
    cl_abap_unit_assert=>assert_equals( exp = `ZCL_X`
                                        act = lo_handler->request_app_start_route( `#//app/ZCL_X/D1` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `D1`
                                        act = lo_handler->request_app_start_route_draft( `#//app/ZCL_X/D1` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `ZCL_X`
                                        act = lo_handler->request_app_start_route( `#//app/ZCL_X` ) ).

  ENDMETHOD.

  METHOD test_route_launchpad.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    CREATE OBJECT lo_handler EXPORTING val = ``.

    " the same routes, but reached through the launchpad shell hash - the
    " browser Back button inside the FLP sends exactly this
    cl_abap_unit_assert=>assert_equals(
        exp = `ZCL_X`
        act = lo_handler->request_app_start_route( `#Z2UI5-display&/app/ZCL_X/D1` ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = `D1`
        act = lo_handler->request_app_start_route_draft( `#Z2UI5-display&/app/ZCL_X/D1` ) ).

    " our slash-prefixed routes appended verbatim by older shells
    cl_abap_unit_assert=>assert_equals(
        exp = `ZCL_X`
        act = lo_handler->request_app_start_route( `#Z2UI5-display&//app/ZCL_X/D1` ) ).

  ENDMETHOD.

  METHOD test_route_no_route.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    CREATE OBJECT lo_handler EXPORTING val = ``.

    " no hash at all (normal boot), an app-owned hash, a bare shell hash and
    " an 'app/' occurring mid-hash must all resolve to "no route", so the
    " '?app_start=' query keeps winning
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = lo_handler->request_app_start_route( `` ) ).
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = lo_handler->request_app_start_route( `#/head/pos/42` ) ).
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = lo_handler->request_app_start_route( `#Z2UI5-display` ) ).
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = lo_handler->request_app_start_route( `#/head/app/ZCL_X` ) ).

  ENDMETHOD.

  METHOD test_app_state_hash.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    CREATE OBJECT lo_handler EXPORTING val = ``.

    " the app-state link format, standalone and inside the launchpad
    cl_abap_unit_assert=>assert_equals(
        exp = `ABC123`
        act = lo_handler->request_app_start_draft( `#/z2ui5-xapp-state=ABC123` ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = `ABC123`
        act = lo_handler->request_app_start_draft( `#Z2UI5-display&/z2ui5-xapp-state=ABC123` ) ).

    " the double-slash form older HashChanger-written live URLs carry
    cl_abap_unit_assert=>assert_equals(
        exp = `ABC123`
        act = lo_handler->request_app_start_draft( `#//z2ui5-xapp-state=ABC123` ) ).

  ENDMETHOD.

  METHOD test_auto_update_push.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA temp17 TYPE xsdboolean.

    " the snapshot differs from the model after main( ) - the model is sent
    " exactly as an explicit view_model_update( ) would send it, with no app
    " opt-in of any kind: automatic model update is always on
    CREATE OBJECT lo_handler EXPORTING val = ``.
    CREATE OBJECT lo_handler->mo_action->mo_app->mo_app TYPE ltcl_app_noop.
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    lo_handler->mv_model_before_taken = abap_true.
    lo_handler->mv_model_before       = `<other model state>`.

    lo_handler->main_end( ).

    " the MODEL key itself IS the push - no updateModel action travels,
    " the frontend pushes into every open slot when a model arrived

    temp17 = boolc( system_actions_of( lo_handler ) CS `updateModel` ).
    cl_abap_unit_assert=>assert_equals(
        exp = abap_false
        act = temp17 ).
    cl_abap_unit_assert=>assert_equals( exp = lo_handler->mo_action->mo_app->model_json_stringify( )
                                        act = lo_handler->ms_response-model ).

  ENDMETHOD.


  METHOD test_auto_update_same.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA temp18 TYPE xsdboolean.

    " main( ) changed nothing - the response stays `{}` and no update flag is
    " set, so an idle event round-trip carries no model payload as before
    CREATE OBJECT lo_handler EXPORTING val = ``.
    CREATE OBJECT lo_handler->mo_action->mo_app->mo_app TYPE ltcl_app_noop.
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    lo_handler->mv_model_before_taken = abap_true.
    lo_handler->mv_model_before       = lo_handler->mo_action->mo_app->model_json_stringify( ).

    lo_handler->main_end( ).

    cl_abap_unit_assert=>assert_equals( exp = `{}`
                                        act = lo_handler->ms_response-model ).
    " an unchanged model asks for no push at all

    temp18 = boolc( system_actions_of( lo_handler ) CS `updateModel` ).
    cl_abap_unit_assert=>assert_equals(
        exp = abap_false
        act = temp18 ).

  ENDMETHOD.


  METHOD test_nested_display_push.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp19 TYPE xsdboolean.

    " a roundtrip that re-displays a NESTED view without its MAIN view must
    " carry the model: the nested view inherits the MAIN model by UI5
    " propagation, so without the push it would bind against the data of the
    " previous roundtrip (three-column samples 098/104)
    CREATE OBJECT lo_handler EXPORTING val = ``.
    CREATE OBJECT lo_handler->mo_action->mo_app->mo_app TYPE ltcl_app_noop.
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    CREATE OBJECT li_client TYPE z2ui5_cl_ui5_client EXPORTING ACTION = lo_handler->mo_action.
    li_client->nest_view_display( val           = `<Nest/>`
                                  id            = `col`
                                  method_insert = `addMidColumnPage` ).

    lo_handler->main_end( ).

    " the model travels with the response - its presence IS the push, the
    " frontend runs it after the displays (View1)
    cl_abap_unit_assert=>assert_equals(
        exp = lo_handler->mo_action->mo_app->model_json_stringify( )
        act = lo_handler->ms_response-model ).

    temp19 = boolc( system_actions_of( lo_handler ) CS `updateModel` ).
    cl_abap_unit_assert=>assert_equals(
        exp = abap_false
        act = temp19 ).

  ENDMETHOD.


  METHOD test_auto_update_snapshot.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.

    " main_process always takes the before-main snapshot - there is no app
    " flag to consult any more
    CREATE OBJECT lo_handler EXPORTING val = ``.
    CREATE OBJECT lo_handler->mo_action->mo_app->mo_app TYPE ltcl_app_noop.
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).

    lo_handler->main_process( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_handler->mv_model_before_taken ).

  ENDMETHOD.


  METHOD test_nav_mode_resent.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_app TYPE REF TO ltcl_app_nav_loop.
    DATA temp20 TYPE xsdboolean.
    DATA temp21 TYPE xsdboolean.

    " An app configures routing ONCE. main_end therefore re-sends the mode the
    " app carries whenever the roundtrip did not set one itself, so a later
    " render of the same app stays routed without queueing set_nav_routing
    " again - and an app that never opted in keeps sending nothing.
    CREATE OBJECT lo_handler EXPORTING val = ``.
    CREATE OBJECT lo_app.
    lo_handler->mo_action->mo_app->mo_app      = lo_app.
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    lo_handler->mo_action->mo_app->mv_nav_mode = z2ui5_if_client=>cs_nav_mode-keep.

    lo_handler->main_end( ).

    " the mode reaches the frontend as the ROUTER/sync option, not as a
    " response field of its own
    cl_abap_unit_assert=>assert_char_cp(
        exp = `*"setNavRouting":"KEEP"*`
        act = system_actions_of( lo_handler ) ).

    " a follow-up EVENT roundtrip of the same app repeats no mode - the
    " frontend keeps it in session state, so re-sending it would re-queue
    " the ROUTER action for a constant on every roundtrip
    lo_handler->ms_request-s_front-id = `SOME_DRAFT`.
    CLEAR lo_handler->mo_action->ms_next.
    lo_handler->main_end( ).


    temp20 = boolc( system_actions_of( lo_handler ) CS `setNavRouting` ).
    cl_abap_unit_assert=>assert_equals(
        exp = abap_false
        act = temp20 ).

    CREATE OBJECT lo_handler EXPORTING val = ``.
    CREATE OBJECT lo_handler->mo_action->mo_app->mo_app TYPE ltcl_app_nav_loop.
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).

    lo_handler->main_end( ).


    temp21 = boolc( system_actions_of( lo_handler ) CS `setNavRouting` ).
    cl_abap_unit_assert=>assert_equals(
        exp = abap_false
        act = temp21 ).

  ENDMETHOD.

ENDCLASS.
