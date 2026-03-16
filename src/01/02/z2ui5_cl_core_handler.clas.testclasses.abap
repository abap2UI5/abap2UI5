CLASS ltcl_test_handler_post DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS load_startup_app       FOR TESTING RAISING cx_static_check.
    METHODS test_request_parse     FOR TESTING RAISING cx_static_check.
    METHODS test_request_origin    FOR TESTING RAISING cx_static_check.
    METHODS test_request_launchpad FOR TESTING RAISING cx_static_check.
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

  METHOD test_constructor.

    DATA lo_handler TYPE REF TO z2ui5_cl_core_handler.
    CREATE OBJECT lo_handler EXPORTING val = `test payload`.

    cl_abap_unit_assert=>assert_equals( exp = `test payload`
                                        act = lo_handler->mv_request_json ).
    cl_abap_unit_assert=>assert_bound( lo_handler->mo_action ).

  ENDMETHOD.

ENDCLASS.
