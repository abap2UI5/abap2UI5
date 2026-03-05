CLASS ltcl_test_app DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mv_value TYPE string ##NEEDED.
ENDCLASS.

CLASS ltcl_test_app IMPLEMENTATION.
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
    METHODS test_factory_by_frntend FOR TESTING RAISING cx_static_check.
    METHODS test_reset_view_flags   FOR TESTING RAISING cx_static_check.
    METHODS test_stack_call         FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS z2ui5_cl_core_action DEFINITION LOCAL FRIENDS ltcl_test.

CLASS ltcl_test IMPLEMENTATION.

  METHOD test_instantiation.

    DATA lo_http TYPE REF TO z2ui5_cl_core_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_core_action.
    CREATE OBJECT lo_http TYPE z2ui5_cl_core_handler EXPORTING val = ``.

    CREATE OBJECT lo_action TYPE z2ui5_cl_core_action EXPORTING val = lo_http.

    cl_abap_unit_assert=>assert_bound( lo_action ).
    cl_abap_unit_assert=>assert_bound( lo_action->mo_http_post ).
    cl_abap_unit_assert=>assert_bound( lo_action->mo_app ).

  ENDMETHOD.

  METHOD test_system_startup.
    DATA lo_http TYPE REF TO z2ui5_cl_core_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_core_action.
    DATA lo_result TYPE REF TO z2ui5_cl_core_action.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.


    CREATE OBJECT lo_http TYPE z2ui5_cl_core_handler EXPORTING val = ``.

    CREATE OBJECT lo_action TYPE z2ui5_cl_core_action EXPORTING val = lo_http.


    lo_result = lo_action->factory_system_startup( ).

    cl_abap_unit_assert=>assert_bound( lo_result ).
    cl_abap_unit_assert=>assert_bound( lo_result->mo_app->mo_app ).
    cl_abap_unit_assert=>assert_not_initial( lo_result->mo_app->ms_draft-id ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_result->ms_actual-check_on_navigated ).

  ENDMETHOD.

  METHOD test_first_start.
    DATA lv_payload TYPE string.
    DATA lo_http TYPE REF TO z2ui5_cl_core_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_core_action.
    DATA lo_result TYPE REF TO z2ui5_cl_core_action.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.


    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":"?app_start=Z2UI5_CL_APP_HELLO_WORLD"}}}`.

    CREATE OBJECT lo_http TYPE z2ui5_cl_core_handler EXPORTING val = lv_payload.
    lo_http->ms_request = lo_http->request_json_to_abap( lv_payload ).


    CREATE OBJECT lo_action TYPE z2ui5_cl_core_action EXPORTING val = lo_http.

    lo_result = lo_action->factory_first_start( ).

    cl_abap_unit_assert=>assert_bound( lo_result->mo_app->mo_app ).
    cl_abap_unit_assert=>assert_not_initial( lo_result->mo_app->ms_draft-id ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_result->ms_actual-check_on_navigated ).

  ENDMETHOD.

  METHOD test_first_start_error.

    DATA lv_payload TYPE string.
    DATA lo_http TYPE REF TO z2ui5_cl_core_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_core_action.
    DATA lx TYPE REF TO z2ui5_cx_util_error.
    DATA temp1 TYPE xsdboolean.
    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":"?app_start=NONEXISTENT_CLASS"}}}`.

    CREATE OBJECT lo_http TYPE z2ui5_cl_core_handler EXPORTING val = lv_payload.
    lo_http->ms_request = lo_http->request_json_to_abap( lv_payload ).


    CREATE OBJECT lo_action TYPE z2ui5_cl_core_action EXPORTING val = lo_http.

    TRY.
        lo_action->factory_first_start( ).
        cl_abap_unit_assert=>fail( `Expected exception for nonexistent class` ).

      CATCH z2ui5_cx_util_error INTO lx.

        temp1 = boolc( lx->get_text( ) CS `NONEXISTENT_CLASS` ).
        cl_abap_unit_assert=>assert_true( temp1 ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_factory_by_frntend.
    DATA lv_payload TYPE string.
    DATA lo_http TYPE REF TO z2ui5_cl_core_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_core_action.
    DATA lo_result TYPE REF TO z2ui5_cl_core_action.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.


    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":""}}}`.

    CREATE OBJECT lo_http TYPE z2ui5_cl_core_handler EXPORTING val = lv_payload.
    lo_http->ms_request = lo_http->request_json_to_abap( lv_payload ).


    CREATE OBJECT lo_action TYPE z2ui5_cl_core_action EXPORTING val = lo_http.
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

  METHOD test_reset_view_flags.

    DATA lo_http TYPE REF TO z2ui5_cl_core_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_core_action.
    CREATE OBJECT lo_http TYPE z2ui5_cl_core_handler EXPORTING val = ``.

    CREATE OBJECT lo_action TYPE z2ui5_cl_core_action EXPORTING val = lo_http.

    lo_action->ms_next-s_set-s_view-check_update_model      = abap_true.
    lo_action->ms_next-s_set-s_view_nest-check_update_model  = abap_true.
    lo_action->ms_next-s_set-s_view_nest2-check_update_model = abap_true.
    lo_action->ms_next-s_set-s_popup-check_update_model      = abap_true.
    lo_action->ms_next-s_set-s_popover-check_update_model    = abap_true.

    lo_action->reset_view_update_flags( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lo_action->ms_next-s_set-s_view-check_update_model ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lo_action->ms_next-s_set-s_view_nest-check_update_model ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lo_action->ms_next-s_set-s_view_nest2-check_update_model ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lo_action->ms_next-s_set-s_popup-check_update_model ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lo_action->ms_next-s_set-s_popover-check_update_model ).

  ENDMETHOD.

  METHOD test_stack_call.
    DATA lo_http TYPE REF TO z2ui5_cl_core_handler.
    DATA lo_action TYPE REF TO z2ui5_cl_core_action.
    DATA lo_new_app TYPE REF TO ltcl_test_app.
    DATA lo_result TYPE REF TO z2ui5_cl_core_action.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.


    CREATE OBJECT lo_http TYPE z2ui5_cl_core_handler EXPORTING val = ``.

    CREATE OBJECT lo_action TYPE z2ui5_cl_core_action EXPORTING val = lo_http.
    CREATE OBJECT lo_action->mo_app->mo_app TYPE ltcl_test_app.
    lo_action->mo_app->ms_draft-id = `CURRENT_DRAFT`.


    CREATE OBJECT lo_new_app TYPE ltcl_test_app.
    lo_action->ms_next-o_app_call = lo_new_app.


    lo_result = lo_action->factory_stack_call( ).

    cl_abap_unit_assert=>assert_bound( lo_result ).
    cl_abap_unit_assert=>assert_equals( exp = `CURRENT_DRAFT`
                                        act = lo_result->mo_app->ms_draft-id_prev_app_stack ).

  ENDMETHOD.

ENDCLASS.
