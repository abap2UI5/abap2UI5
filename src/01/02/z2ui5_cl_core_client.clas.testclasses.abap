CLASS ltcl_test_app DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mv_name TYPE string ##NEEDED.
ENDCLASS.

CLASS ltcl_test_app IMPLEMENTATION.
  METHOD z2ui5_if_app~main.
  ENDMETHOD.
ENDCLASS.


CLASS ltcl_test_client DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION LONG.

  PRIVATE SECTION.
    DATA mo_client TYPE REF TO z2ui5_cl_core_client.
    DATA mo_action TYPE REF TO z2ui5_cl_core_action.

    METHODS setup.

    METHODS test_instantiation        FOR TESTING RAISING cx_static_check.
    METHODS test_view_display         FOR TESTING RAISING cx_static_check.
    METHODS test_view_destroy         FOR TESTING RAISING cx_static_check.
    METHODS test_view_model_update    FOR TESTING RAISING cx_static_check.
    METHODS test_popup_display        FOR TESTING RAISING cx_static_check.
    METHODS test_popup_destroy        FOR TESTING RAISING cx_static_check.
    METHODS test_popup_model_update   FOR TESTING RAISING cx_static_check.
    METHODS test_popover_display      FOR TESTING RAISING cx_static_check.
    METHODS test_popover_destroy      FOR TESTING RAISING cx_static_check.
    METHODS test_popover_model_update FOR TESTING RAISING cx_static_check.
    METHODS test_nest_view_display    FOR TESTING RAISING cx_static_check.
    METHODS test_nest_view_destroy    FOR TESTING RAISING cx_static_check.
    METHODS test_nest2_view_display   FOR TESTING RAISING cx_static_check.
    METHODS test_nest2_view_destroy   FOR TESTING RAISING cx_static_check.
    METHODS test_message_box_display  FOR TESTING RAISING cx_static_check.
    METHODS test_message_box_type     FOR TESTING RAISING cx_static_check.
    METHODS test_message_toast        FOR TESTING RAISING cx_static_check.
    METHODS test_follow_up_action     FOR TESTING RAISING cx_static_check.
    METHODS test_action               FOR TESTING RAISING cx_static_check.
    METHODS test_action_reject_js     FOR TESTING RAISING cx_static_check.
    METHODS test_action_reject_empty  FOR TESTING RAISING cx_static_check.
    METHODS test_check_on_init        FOR TESTING RAISING cx_static_check.
    METHODS test_check_on_init_done   FOR TESTING RAISING cx_static_check.
    METHODS test_check_on_event       FOR TESTING RAISING cx_static_check.
    METHODS test_check_on_event_empty FOR TESTING RAISING cx_static_check.
    METHODS test_check_on_navigated   FOR TESTING RAISING cx_static_check.
    METHODS test_nav_app_call         FOR TESTING RAISING cx_static_check.
    METHODS test_nav_app_call_id_stable FOR TESTING RAISING cx_static_check.
    METHODS test_nav_app_leave_event  FOR TESTING RAISING cx_static_check.
    METHODS test_nav_app_leave_r_data FOR TESTING RAISING cx_static_check.
    METHODS test_nav_leave_r_data_empty FOR TESTING RAISING cx_static_check.
    METHODS test_nav_leave_r_data_not_sup FOR TESTING RAISING cx_static_check.
    METHODS test_nav_leave_r_data_unbound FOR TESTING RAISING cx_static_check.
    METHODS test_check_app_prev_stack FOR TESTING RAISING cx_static_check.
    METHODS test_set_push_state       FOR TESTING RAISING cx_static_check.
    METHODS test_set_nav_back         FOR TESTING RAISING cx_static_check.
    METHODS test_get_event_arg        FOR TESTING RAISING cx_static_check.
    METHODS test_set_app_state_active FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS z2ui5_cl_core_client DEFINITION LOCAL FRIENDS ltcl_test_client.

CLASS ltcl_test_client IMPLEMENTATION.

  METHOD setup.

    DATA lo_http TYPE REF TO z2ui5_cl_core_handler.
    DATA lo_test_app TYPE REF TO ltcl_test_app.
    lo_http = NEW #( val = `` ).
    mo_action = NEW #( val = lo_http ).
    lo_test_app = NEW #( ).
    lo_test_app->z2ui5_if_app~check_initialized = abap_false.
    mo_action->mo_app->mo_app = lo_test_app.
    mo_client = NEW #( action = mo_action ).

  ENDMETHOD.

  METHOD test_instantiation.

    cl_abap_unit_assert=>assert_bound( mo_client ).
    cl_abap_unit_assert=>assert_bound( mo_client->mo_action ).
    cl_abap_unit_assert=>assert_bound( mo_client->mo_srv_bind ).
    cl_abap_unit_assert=>assert_bound( mo_client->mo_srv_event ).

  ENDMETHOD.

  METHOD test_view_display.

    DATA temp1 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp1.
    temp1 ?= mo_client.

    li_client = temp1.
    li_client->view_display( `<View></View>` ).

    cl_abap_unit_assert=>assert_equals( exp = `<View></View>`
                                        act = mo_action->ms_next-s_set-s_view-xml ).

  ENDMETHOD.

  METHOD test_view_destroy.

    DATA temp2 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp2.
    temp2 ?= mo_client.

    li_client = temp2.
    li_client->view_destroy( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = mo_action->ms_next-s_set-s_view-check_destroy ).

  ENDMETHOD.

  METHOD test_view_model_update.

    DATA temp3 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp3.
    temp3 ?= mo_client.

    li_client = temp3.
    li_client->view_model_update( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = mo_action->ms_next-s_set-s_view-check_update_model ).

  ENDMETHOD.

  METHOD test_popup_display.

    DATA temp4 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp4.
    temp4 ?= mo_client.

    li_client = temp4.
    li_client->popup_display( `<Dialog/>` ).

    cl_abap_unit_assert=>assert_equals( exp = `<Dialog/>`
                                        act = mo_action->ms_next-s_set-s_popup-xml ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = mo_action->ms_next-s_set-s_popup-check_destroy ).

  ENDMETHOD.

  METHOD test_popup_destroy.

    DATA temp5 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp5.
    temp5 ?= mo_client.

    li_client = temp5.
    li_client->popup_destroy( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = mo_action->ms_next-s_set-s_popup-check_destroy ).

  ENDMETHOD.

  METHOD test_popup_model_update.

    DATA temp6 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp6.
    temp6 ?= mo_client.

    li_client = temp6.
    li_client->popup_model_update( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = mo_action->ms_next-s_set-s_popup-check_update_model ).

  ENDMETHOD.

  METHOD test_popover_display.

    DATA temp7 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp7.
    temp7 ?= mo_client.

    li_client = temp7.
    li_client->popover_display( xml   = `<Popover/>`
                                by_id = `btn1` ).

    cl_abap_unit_assert=>assert_equals( exp = `<Popover/>`
                                        act = mo_action->ms_next-s_set-s_popover-xml ).
    cl_abap_unit_assert=>assert_equals( exp = `btn1`
                                        act = mo_action->ms_next-s_set-s_popover-open_by_id ).

  ENDMETHOD.

  METHOD test_popover_destroy.

    DATA temp8 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp8.
    temp8 ?= mo_client.

    li_client = temp8.
    li_client->popover_destroy( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = mo_action->ms_next-s_set-s_popover-check_destroy ).

  ENDMETHOD.

  METHOD test_popover_model_update.

    DATA temp9 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp9.
    temp9 ?= mo_client.

    li_client = temp9.
    li_client->popover_model_update( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = mo_action->ms_next-s_set-s_popover-check_update_model ).

  ENDMETHOD.

  METHOD test_nest_view_display.

    DATA temp10 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp10.
    temp10 ?= mo_client.

    li_client = temp10.
    li_client->nest_view_display( val            = `<NestView/>`
                                  id             = `nest1`
                                  method_insert  = `addMidColumnPage`
                                  method_destroy = `removeMidColumnPage` ).

    cl_abap_unit_assert=>assert_equals( exp = `<NestView/>`
                                        act = mo_action->ms_next-s_set-s_view_nest-xml ).
    cl_abap_unit_assert=>assert_equals( exp = `nest1`
                                        act = mo_action->ms_next-s_set-s_view_nest-id ).
    cl_abap_unit_assert=>assert_equals( exp = `addMidColumnPage`
                                        act = mo_action->ms_next-s_set-s_view_nest-method_insert ).

  ENDMETHOD.

  METHOD test_nest_view_destroy.

    DATA temp11 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp11.
    temp11 ?= mo_client.

    li_client = temp11.
    li_client->nest_view_destroy( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = mo_action->ms_next-s_set-s_view_nest-check_update_model ).

  ENDMETHOD.

  METHOD test_nest2_view_display.

    DATA temp12 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp12.
    temp12 ?= mo_client.

    li_client = temp12.
    li_client->nest2_view_display( val           = `<Nest2View/>`
                                   id            = `nest2`
                                   method_insert = `addEndColumnPage` ).

    cl_abap_unit_assert=>assert_equals( exp = `<Nest2View/>`
                                        act = mo_action->ms_next-s_set-s_view_nest2-xml ).
    cl_abap_unit_assert=>assert_equals( exp = `nest2`
                                        act = mo_action->ms_next-s_set-s_view_nest2-id ).

  ENDMETHOD.

  METHOD test_nest2_view_destroy.

    DATA temp13 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp13.
    temp13 ?= mo_client.

    li_client = temp13.
    li_client->nest2_view_destroy( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = mo_action->ms_next-s_set-s_view_nest2-check_update_model ).

  ENDMETHOD.

  METHOD test_message_box_display.

    DATA temp14 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp14.
    temp14 ?= mo_client.

    li_client = temp14.
    li_client->message_box_display( `Hello World` ).

    cl_abap_unit_assert=>assert_equals( exp = `Hello World`
                                        act = mo_action->ms_next-s_set-s_msg_box-text ).
    cl_abap_unit_assert=>assert_equals( exp = `show`
                                        act = mo_action->ms_next-s_set-s_msg_box-type ).

  ENDMETHOD.

  METHOD test_message_box_type.

    DATA temp15 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp15.
    temp15 ?= mo_client.

    li_client = temp15.
    li_client->message_box_display( text = `Error occurred`
                                    type = `error` ).

    cl_abap_unit_assert=>assert_equals( exp = `Error occurred`
                                        act = mo_action->ms_next-s_set-s_msg_box-text ).
    cl_abap_unit_assert=>assert_equals( exp = `error`
                                        act = mo_action->ms_next-s_set-s_msg_box-type ).

  ENDMETHOD.

  METHOD test_message_toast.

    DATA temp16 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp16.
    temp16 ?= mo_client.

    li_client = temp16.
    li_client->message_toast_display( `Saved` ).

    cl_abap_unit_assert=>assert_equals( exp = `Saved`
                                        act = mo_action->ms_next-s_set-s_msg_toast-text ).

  ENDMETHOD.

  METHOD test_follow_up_action.

    DATA temp17 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp17.
    temp17 ?= mo_client.

    li_client = temp17.
    li_client->follow_up_action( `sap.m.MessageToast.show('test')` ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_action->ms_next-s_set-s_follow_up_action-custom_js ) ).

  ENDMETHOD.

  METHOD test_action.

    DATA li_client TYPE REF TO z2ui5_if_client.
    li_client ?= mo_client.

    li_client->action->gen( val   = z2ui5_if_client=>cs_event-set_title
                            t_arg = VALUE #( ( `My Title` ) ) ).
    li_client->action->gen( z2ui5_if_client=>cs_event-history_back ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( mo_action->ms_next-s_set-s_follow_up_action-custom_js ) ).
    cl_abap_unit_assert=>assert_equals( exp = `.eF('SET_TITLE', 'My Title')`
                                        act = mo_action->ms_next-s_set-s_follow_up_action-custom_js[ 1 ] ).
    cl_abap_unit_assert=>assert_equals( exp = `.eF('HISTORY_BACK')`
                                        act = mo_action->ms_next-s_set-s_follow_up_action-custom_js[ 2 ] ).

  ENDMETHOD.

  METHOD test_action_reject_js.

    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA lv_raised TYPE abap_bool.
    li_client ?= mo_client.

    TRY.
        li_client->action->gen( `EVT'); alert(1);//` ).
      CATCH z2ui5_cx_a2ui5_error.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lv_raised ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = lines( mo_action->ms_next-s_set-s_follow_up_action-custom_js ) ).

  ENDMETHOD.

  METHOD test_action_reject_empty.

    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA lv_raised TYPE abap_bool.
    li_client ?= mo_client.

    TRY.
        li_client->action->gen( `` ).
      CATCH z2ui5_cx_a2ui5_error.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lv_raised ).

  ENDMETHOD.

  METHOD test_check_on_init.

    DATA li_app TYPE REF TO z2ui5_if_app.
    li_app ?= mo_action->mo_app->mo_app.
    li_app->check_initialized = abap_false.

    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = li_app->check_initialized ).

  ENDMETHOD.

  METHOD test_check_on_init_done.

    DATA li_app TYPE REF TO z2ui5_if_app.
    li_app ?= mo_action->mo_app->mo_app.
    li_app->check_initialized = abap_true.

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = li_app->check_initialized ).

  ENDMETHOD.

  METHOD test_check_on_event.
    DATA temp21 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp21.

    mo_action->ms_actual-event = `BUTTON_PRESS`.


    temp21 ?= mo_client.

    li_client = temp21.

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = li_client->check_on_event( `BUTTON_PRESS` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = li_client->check_on_event( `OTHER_EVENT` ) ).

  ENDMETHOD.

  METHOD test_check_on_event_empty.
    DATA temp22 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp22.

    mo_action->ms_actual-event = ``.


    temp22 ?= mo_client.

    li_client = temp22.

    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = li_client->check_on_event( ) ).

  ENDMETHOD.

  METHOD test_check_on_navigated.
    DATA temp23 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp23.

    mo_action->ms_actual-check_on_navigated = abap_true.


    temp23 ?= mo_client.

    li_client = temp23.

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = li_client->check_on_navigated( ) ).

  ENDMETHOD.

  METHOD test_nav_app_call.

    DATA lo_new_app TYPE REF TO ltcl_test_app.
    DATA temp24 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp24.
    DATA lv_id TYPE string.
    lo_new_app = NEW #( ).

    temp24 ?= mo_client.

    li_client = temp24.


    lv_id = li_client->nav_app_call( lo_new_app ).

    cl_abap_unit_assert=>assert_not_initial( lv_id ).
    cl_abap_unit_assert=>assert_bound( mo_action->ms_next-o_app_call ).

  ENDMETHOD.

  METHOD test_nav_app_call_id_stable.

    DATA lo_new_app TYPE REF TO ltcl_test_app.
    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA lv_id_first TYPE string.
    DATA lv_id_second TYPE string.
    lo_new_app = NEW #( ).
    li_client ?= mo_client.

    lv_id_first  = li_client->nav_app_call( lo_new_app ).
    lv_id_second = li_client->nav_app_call( lo_new_app ).

    cl_abap_unit_assert=>assert_not_initial( lv_id_second ).
    cl_abap_unit_assert=>assert_equals( exp = lv_id_first
                                        act = lv_id_second ).
    cl_abap_unit_assert=>assert_equals( exp = lv_id_first
                                        act = lo_new_app->z2ui5_if_app~id_app ).

  ENDMETHOD.

  METHOD test_nav_app_leave_event.

    DATA lo_app TYPE REF TO ltcl_test_app.
    DATA li_client TYPE REF TO z2ui5_if_client.
    lo_app = NEW #( ).
    li_client ?= mo_client.

    li_client->nav_app_leave( app   = lo_app
                              event = `MY_EVENT` ).

    cl_abap_unit_assert=>assert_bound( mo_action->ms_next-o_app_leave ).
    cl_abap_unit_assert=>assert_equals( exp = `MY_EVENT`
                                        act = mo_action->ms_next-next_event ).
    " the dedicated backend event must not emit any client side JS snippet
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = lines( mo_action->ms_next-s_set-s_follow_up_action-custom_js ) ).

  ENDMETHOD.

  METHOD test_nav_app_leave_r_data.

    DATA lo_app TYPE REF TO ltcl_test_app.
    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA lv_data TYPE string VALUE `payload`.
    lo_app = NEW #( ).
    li_client ?= mo_client.

    li_client->nav_app_leave( app    = lo_app
                              event  = `MY_EVENT`
                              r_data = lv_data ).

    cl_abap_unit_assert=>assert_bound( mo_action->ms_next-r_data ).

  ENDMETHOD.

  METHOD test_nav_leave_r_data_empty.

    DATA lo_app TYPE REF TO ltcl_test_app.
    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA lv_data TYPE string.
    FIELD-SYMBOLS <data> TYPE data.
    lo_app = NEW #( ).
    li_client ?= mo_client.

    li_client->nav_app_leave( app    = lo_app
                              event  = `MY_EVENT`
                              r_data = lv_data ).

    " an intentionally empty return value must still reach the previous app (issue #2404)
    cl_abap_unit_assert=>assert_bound( mo_action->ms_next-r_data ).
    ASSIGN mo_action->ms_next-r_data->* TO <data>.
    cl_abap_unit_assert=>assert_initial( <data> ).

  ENDMETHOD.

  METHOD test_nav_leave_r_data_not_sup.

    DATA lo_app TYPE REF TO ltcl_test_app.
    DATA li_client TYPE REF TO z2ui5_if_client.
    lo_app = NEW #( ).
    li_client ?= mo_client.

    li_client->nav_app_leave( app   = lo_app
                              event = `MY_EVENT` ).

    cl_abap_unit_assert=>assert_not_bound( mo_action->ms_next-r_data ).

  ENDMETHOD.

  METHOD test_nav_leave_r_data_unbound.

    DATA lo_app TYPE REF TO ltcl_test_app.
    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA lr_data TYPE REF TO data.
    lo_app = NEW #( ).
    li_client ?= mo_client.

    li_client->nav_app_leave( app    = lo_app
                              event  = `MY_EVENT`
                              r_data = lr_data ).

    " an unbound data reference has no value to copy and must not dump
    cl_abap_unit_assert=>assert_not_bound( mo_action->ms_next-r_data ).

  ENDMETHOD.

  METHOD test_check_app_prev_stack.

    DATA temp25 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp25.
    temp25 ?= mo_client.

    li_client = temp25.

    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = li_client->check_app_prev_stack( ) ).

    mo_action->mo_app->ms_draft-id_prev_app_stack = `PREV_ID`.

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = li_client->check_app_prev_stack( ) ).

  ENDMETHOD.

  METHOD test_set_push_state.

    DATA temp26 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp26.
    temp26 ?= mo_client.

    li_client = temp26.
    li_client->set_push_state( `mystate` ).

    cl_abap_unit_assert=>assert_equals( exp = `mystate`
                                        act = mo_action->ms_next-s_set-set_push_state ).

  ENDMETHOD.

  METHOD test_set_nav_back.

    DATA temp27 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp27.
    temp27 ?= mo_client.

    li_client = temp27.
    li_client->set_nav_back( abap_true ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = mo_action->ms_next-s_set-set_nav_back ).

  ENDMETHOD.

  METHOD test_get_event_arg.

    DATA temp28 TYPE string_table.
    DATA temp30 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp30.
    CLEAR temp28.
    INSERT `arg1` INTO TABLE temp28.
    INSERT `arg2` INTO TABLE temp28.
    mo_action->ms_actual-t_event_arg = temp28.


    temp30 ?= mo_client.

    li_client = temp30.

    cl_abap_unit_assert=>assert_equals( exp = `arg1`
                                        act = li_client->get_event_arg( 1 ) ).
    cl_abap_unit_assert=>assert_equals( exp = `arg2`
                                        act = li_client->get_event_arg( 2 ) ).

  ENDMETHOD.

  METHOD test_set_app_state_active.

    DATA temp31 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp31.
    temp31 ?= mo_client.

    li_client = temp31.
    li_client->set_app_state_active( abap_true ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = mo_action->ms_next-s_set-set_app_state_active ).

  ENDMETHOD.

ENDCLASS.
