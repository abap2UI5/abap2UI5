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
ENDCLASS.

CLASS z2ui5_cl_core_handler DEFINITION LOCAL FRIENDS ltcl_test_handler_post.

CLASS ltcl_test_handler_post IMPLEMENTATION.

  METHOD load_startup_app.
    DATA lv_payload TYPE string.
    DATA lo_post TYPE REF TO z2ui5_cl_core_handler.
    DATA temp1 TYPE REF TO z2ui5_cl_app_startup.
    DATA lo_startup LIKE temp1.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.


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
    DATA lo_handler TYPE REF TO z2ui5_cl_core_handler.
    DATA ls_request TYPE z2ui5_if_core_types=>ty_s_request.
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
    DATA lo_handler TYPE REF TO z2ui5_cl_core_handler.
    DATA ls_request TYPE z2ui5_if_core_types=>ty_s_request.
    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"https://example.org","PATHNAME":"/app","SEARCH":""}}}`.

    CREATE OBJECT lo_handler EXPORTING val = lv_payload.

    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = `https://example.org`
                                        act = ls_request-s_front-origin ).

  ENDMETHOD.

  METHOD test_request_launchpad.

    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_core_handler.
    DATA ls_request TYPE z2ui5_if_core_types=>ty_s_request.
    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/ui2/flp","SEARCH":"?scenario=LAUNCHPAD"}}}`.

    CREATE OBJECT lo_handler EXPORTING val = lv_payload.

    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = ls_request-s_control-check_launchpad ).

  ENDMETHOD.

  METHOD test_parse_body_with_wrapper.
    " Standalone scenario: frontend wraps body in {"value": ...}
    " This is the standard case when the app runs outside the Fiori Launchpad.
    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_core_handler.
    DATA ls_request TYPE z2ui5_if_core_types=>ty_s_request.
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
    DATA lo_handler TYPE REF TO z2ui5_cl_core_handler.
    DATA ls_request TYPE z2ui5_if_core_types=>ty_s_request.
    lv_payload = `{"S_FRONT":{"ORIGIN":"https://myhost.com","PATHNAME":"/ui2/flp","SEARCH":"?scenario=LAUNCHPAD"}}`.

    CREATE OBJECT lo_handler EXPORTING val = lv_payload.
    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = `https://myhost.com`
                                        act = ls_request-s_front-origin ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = ls_request-s_control-check_launchpad ).
  ENDMETHOD.

  METHOD test_parse_body_model.
    " the view model is extracted from the request MODEL container and has to
    " stay reachable under /... for main_json_to_attri
    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_core_handler.
    DATA ls_request TYPE z2ui5_if_core_types=>ty_s_request.
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
    DATA lo_handler TYPE REF TO z2ui5_cl_core_handler.
    DATA ls_request TYPE z2ui5_if_core_types=>ty_s_request.
    lv_payload = `{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":""},"MODEL":{"NAME":"test-value"}}`.

    CREATE OBJECT lo_handler EXPORTING val = lv_payload.
    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_bound( ls_request-o_model ).
    cl_abap_unit_assert=>assert_equals( exp = `test-value`
                                        act = ls_request-o_model->get_string( `/NAME` ) ).
  ENDMETHOD.

  METHOD test_parse_body_config.

    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_core_handler.
    DATA ls_request TYPE z2ui5_if_core_types=>ty_s_request.
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
    DATA lo_handler TYPE REF TO z2ui5_cl_core_handler.
    DATA ls_request TYPE z2ui5_if_core_types=>ty_s_request.
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
    DATA lo_handler TYPE REF TO z2ui5_cl_core_handler.
    DATA ls_request TYPE z2ui5_if_core_types=>ty_s_request.
    DATA temp2 LIKE LINE OF ls_request-s_front-t_event_arg.
    DATA temp3 LIKE sy-tabix.
    DATA temp4 LIKE LINE OF ls_request-s_front-t_event_arg.
    DATA temp5 LIKE sy-tabix.
    lv_payload = `{"value":{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":"",` &&
                 `"EVENT":"MY_EVENT","T_EVENT_ARG":["first","second"]}}}`.

    CREATE OBJECT lo_handler EXPORTING val = lv_payload.
    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( ls_request-s_front-t_event_arg ) ).


    temp3 = sy-tabix.
    READ TABLE ls_request-s_front-t_event_arg INDEX 1 INTO temp2.
    sy-tabix = temp3.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `first`
                                        act = temp2 ).


    temp5 = sy-tabix.
    READ TABLE ls_request-s_front-t_event_arg INDEX 2 INTO temp4.
    sy-tabix = temp5.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `second`
                                        act = temp4 ).
  ENDMETHOD.

  METHOD test_parse_body_arg_object.
    " object and array arguments arrive as raw JSON from the frontend and
    " have to reach the app as JSON strings, scalar arguments in the same
    " event keep their previous string form
    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_core_handler.
    DATA ls_request TYPE z2ui5_if_core_types=>ty_s_request.
    DATA temp6 LIKE LINE OF ls_request-s_front-t_event_arg.
    DATA temp7 LIKE sy-tabix.
    DATA temp8 LIKE LINE OF ls_request-s_front-t_event_arg.
    DATA temp9 LIKE sy-tabix.
    DATA temp10 LIKE LINE OF ls_request-s_front-t_event_arg.
    DATA temp11 LIKE sy-tabix.
    DATA temp12 LIKE LINE OF ls_request-s_front-t_event_arg.
    DATA temp13 LIKE sy-tabix.
    DATA temp14 LIKE LINE OF ls_request-s_front-t_event_arg.
    DATA temp15 LIKE sy-tabix.
    lv_payload = `{"value":{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":"",` &&
                 `"EVENT":"MY_EVENT","T_EVENT_ARG":["plain",5,true,{"KEY":"val"},[1,2]]}}}`.

    CREATE OBJECT lo_handler EXPORTING val = lv_payload.
    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = 5
                                        act = lines( ls_request-s_front-t_event_arg ) ).


    temp7 = sy-tabix.
    READ TABLE ls_request-s_front-t_event_arg INDEX 1 INTO temp6.
    sy-tabix = temp7.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `plain`
                                        act = temp6 ).


    temp9 = sy-tabix.
    READ TABLE ls_request-s_front-t_event_arg INDEX 2 INTO temp8.
    sy-tabix = temp9.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `5`
                                        act = temp8 ).


    temp11 = sy-tabix.
    READ TABLE ls_request-s_front-t_event_arg INDEX 3 INTO temp10.
    sy-tabix = temp11.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `X`
                                        act = temp10 ).


    temp13 = sy-tabix.
    READ TABLE ls_request-s_front-t_event_arg INDEX 4 INTO temp12.
    sy-tabix = temp13.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `{"KEY":"val"}`
                                        act = temp12 ).


    temp15 = sy-tabix.
    READ TABLE ls_request-s_front-t_event_arg INDEX 5 INTO temp14.
    sy-tabix = temp15.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `[1,2]`
                                        act = temp14 ).
  ENDMETHOD.

  METHOD test_request_app_start.

    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_core_handler.
    DATA ls_request TYPE z2ui5_if_core_types=>ty_s_request.
    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":"?app_start=Z2UI5_CL_APP_HELLO_WORLD"}}}`.

    CREATE OBJECT lo_handler EXPORTING val = lv_payload.

    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = `Z2UI5_CL_APP_HELLO_WORLD`
                                        act = ls_request-s_control-app_start ).

  ENDMETHOD.

  METHOD test_request_with_id.

    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_core_handler.
    DATA ls_request TYPE z2ui5_if_core_types=>ty_s_request.
    lv_payload = `{"value":{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":""}}}`.

    CREATE OBJECT lo_handler EXPORTING val = lv_payload.

    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = `ABC123`
                                        act = ls_request-s_front-id ).

  ENDMETHOD.

  METHOD test_response_json.

    DATA lo_handler TYPE REF TO z2ui5_cl_core_handler.
    DATA temp2 TYPE z2ui5_if_core_types=>ty_s_response.
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
    temp2-s_front-app = `Z2UI5_CL_APP_HELLO_WORLD`.
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

  METHOD test_view_update_flag.

    DATA lo_handler TYPE REF TO z2ui5_cl_core_handler.
    CREATE OBJECT lo_handler EXPORTING val = ``.
    lo_handler->ms_response-s_front-params-s_view-xml = `<View/>`.

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_handler->check_view_update_needed( ) ).

  ENDMETHOD.

  METHOD test_view_update_popup.

    DATA lo_handler TYPE REF TO z2ui5_cl_core_handler.
    CREATE OBJECT lo_handler EXPORTING val = ``.
    lo_handler->ms_response-s_front-params-s_popup-check_update_model = abap_true.

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_handler->check_view_update_needed( ) ).

  ENDMETHOD.

  METHOD test_view_update_none.

    DATA lo_handler TYPE REF TO z2ui5_cl_core_handler.
    CREATE OBJECT lo_handler EXPORTING val = ``.

    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lo_handler->check_view_update_needed( ) ).

  ENDMETHOD.

  METHOD test_dispatch_loop_guard.

    DATA lo_handler TYPE REF TO z2ui5_cl_core_handler.
    DATA lo_loop_app TYPE REF TO ltcl_app_nav_loop.
    DATA lx TYPE REF TO z2ui5_cx_a2ui5_error.

    " an app that calls nav_app_call unconditionally in main( ) must not
    " loop the dispatch forever - the handler raises once the limit is hit
    CREATE OBJECT lo_handler EXPORTING val = ``.
    lo_handler->mv_dispatch_limit = 5.
    CREATE OBJECT lo_loop_app.
    lo_handler->mo_action->mo_app->mo_app = lo_loop_app.
    " db_save asserts a draft id, normally set by the action factories
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_a2ui5_context=>uuid_get_c32( ).

    TRY.
        lo_handler->main_loop( ).
        cl_abap_unit_assert=>fail( `dispatch loop guard did not raise` ).
      CATCH z2ui5_cx_a2ui5_error INTO lx.
        cl_abap_unit_assert=>assert_char_cp( act = lx->get_text( )
                                             exp = `*nav_app_call*` ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_constructor.

    DATA lo_handler TYPE REF TO z2ui5_cl_core_handler.
    CREATE OBJECT lo_handler EXPORTING val = `test payload`.

    cl_abap_unit_assert=>assert_equals( exp = `test payload`
                                        act = lo_handler->mv_request_json ).
    cl_abap_unit_assert=>assert_bound( lo_handler->mo_action ).

  ENDMETHOD.

ENDCLASS.
