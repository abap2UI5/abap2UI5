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
    DATA mo_client TYPE REF TO z2ui5_cl_ui5_client.
    DATA mo_action TYPE REF TO z2ui5_cl_ui5_action.

    METHODS setup.

    "! The collected view-lifecycle calls, joined as slot|method|xml[|options].
    "! They are asserted as a SEQUENCE: the order they leave in, and which of
    "! them survive a second call for the same slot, is the whole contract.
    METHODS system_actions
      RETURNING
        VALUE(result) TYPE string
      RAISING
        z2ui5_cx_ajson_error.

    METHODS test_instantiation        FOR TESTING RAISING cx_static_check.
    METHODS test_view_display         FOR TESTING RAISING cx_static_check.
    METHODS test_view_destroy         FOR TESTING RAISING cx_static_check.
    METHODS test_view_model_update    FOR TESTING RAISING cx_static_check.
    METHODS test_nest_model_update    FOR TESTING RAISING cx_static_check.
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
    METHODS test_message_box_dependent FOR TESTING RAISING cx_static_check.
    METHODS test_message_box_type     FOR TESTING RAISING cx_static_check.
    METHODS test_message_toast        FOR TESTING RAISING cx_static_check.
    METHODS test_set_nav_routing      FOR TESTING RAISING cx_static_check.
    METHODS test_set_nav_routing_default FOR TESTING RAISING cx_static_check.
    METHODS test_follow_up_action     FOR TESTING RAISING cx_static_check.
    METHODS test_follow_up_action_ev  FOR TESTING RAISING cx_static_check.
    METHODS test_follow_up_action_nav FOR TESTING RAISING cx_static_check.
    METHODS test_follow_up_action_ctrl FOR TESTING RAISING cx_static_check.
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
    METHODS test_get_event            FOR TESTING RAISING cx_static_check.
    METHODS test_get_event_arg        FOR TESTING RAISING cx_static_check.
    METHODS test_set_app_state_active FOR TESTING RAISING cx_static_check.
    METHODS test_omit_initial_paths   FOR TESTING RAISING cx_static_check.
    METHODS test_omit_initial_keeps_rows FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS z2ui5_cl_ui5_client DEFINITION LOCAL FRIENDS ltcl_test_client.

CLASS ltcl_test_client IMPLEMENTATION.

  METHOD system_actions.

    DATA ls_action LIKE LINE OF mo_action->ms_next-t_action_front.
    LOOP AT mo_action->ms_next-t_action_front INTO ls_action.
      IF result IS NOT INITIAL.
        result = result && `|`.
      ENDIF.
      result = result && |{ ls_action-slot }\|{ ls_action-method }\|{ ls_action-xml }|.
      IF ls_action-options IS BOUND AND ls_action-options->is_empty( ) = abap_false.
        result = result && |\|{ ls_action-options->stringify( ) }|.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD setup.

    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_test_app TYPE REF TO ltcl_test_app.
    CREATE OBJECT lo_http EXPORTING val = ``.
    CREATE OBJECT mo_action EXPORTING val = lo_http.
    CREATE OBJECT lo_test_app.
    mo_action->mo_app->mo_app = lo_test_app.
    mo_action->mo_app->mv_check_initialized = abap_false.
    CREATE OBJECT mo_client EXPORTING action = mo_action.

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

    cl_abap_unit_assert=>assert_equals(
        exp = `MAIN|display|<View></View>`
        act = system_actions( ) ).

  ENDMETHOD.

  METHOD test_view_destroy.

    DATA temp2 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp2.
    temp2 ?= mo_client.

    li_client = temp2.
    li_client->view_destroy( ).

    cl_abap_unit_assert=>assert_equals( exp = `MAIN|destroy|`
                                        act = system_actions( ) ).

  ENDMETHOD.

  METHOD test_view_model_update.

    " the model is pushed automatically now (z2ui5_cl_ui5_handler=>main_end),
    " so this method is an obsolete NO-OP kept for source compatibility - it
    " must not raise and must not set any slot flag
    DATA temp3 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp3.
    temp3 ?= mo_client.

    li_client = temp3.
    li_client->view_model_update( ).

    cl_abap_unit_assert=>assert_initial( mo_action->ms_next-s_action ).

  ENDMETHOD.

  METHOD test_nest_model_update.

    " both nested variants are obsolete NO-OPs too: a nested view owns no
    " model (it inherits MAIN's by propagation) and MAIN is pushed
    " automatically - see test_view_model_update
    DATA temp4 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp4.
    temp4 ?= mo_client.

    li_client = temp4.
    li_client->nest_view_model_update( ).
    li_client->nest2_view_model_update( ).

    cl_abap_unit_assert=>assert_initial( mo_action->ms_next-s_action ).

  ENDMETHOD.

  METHOD test_popup_display.

    DATA temp4 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp4.
    temp4 ?= mo_client.

    li_client = temp4.
    li_client->popup_display( `<Dialog/>` ).

    cl_abap_unit_assert=>assert_equals(
        exp = `POPUP|display|<Dialog/>`
        act = system_actions( ) ).

  ENDMETHOD.

  METHOD test_popup_destroy.

    DATA temp5 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp5.
    temp5 ?= mo_client.

    li_client = temp5.
    li_client->popup_destroy( ).

    cl_abap_unit_assert=>assert_equals(
        exp = `POPUP|destroy|`
        act = system_actions( ) ).

  ENDMETHOD.

  METHOD test_popup_model_update.

    DATA temp6 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp6.
    temp6 ?= mo_client.

    li_client = temp6.
    li_client->popup_model_update( ).

    " obsolete NO-OP - main_end( ) queues the model push for every slot itself
    cl_abap_unit_assert=>assert_initial( mo_action->ms_next-s_action ).

  ENDMETHOD.

  METHOD test_popover_display.

    DATA temp7 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp7.
    temp7 ?= mo_client.

    li_client = temp7.
    li_client->popover_display( xml   = `<Popover/>`
                                by_id = `btn1` ).

    cl_abap_unit_assert=>assert_equals(
        exp = `POPOVER|display|<Popover/>|{"openById":"btn1"}`
        act = system_actions( ) ).

  ENDMETHOD.

  METHOD test_popover_destroy.

    DATA temp8 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp8.
    temp8 ?= mo_client.

    li_client = temp8.
    li_client->popover_display( xml   = `<Popover/>`
                                by_id = `btn1` ).
    li_client->popover_destroy( ).

    " the destroy replaces the display queued before it - the frontend
    " receives one teardown and no build at all, never a build it would have
    " to undo again
    cl_abap_unit_assert=>assert_equals(
        exp = `POPOVER|destroy|`
        act = system_actions( ) ).

  ENDMETHOD.

  METHOD test_popover_model_update.

    DATA temp9 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp9.
    temp9 ?= mo_client.

    li_client = temp9.
    li_client->popover_model_update( ).

    " obsolete NO-OP - main_end( ) queues the model push for every slot itself
    cl_abap_unit_assert=>assert_initial( mo_action->ms_next-s_action ).

  ENDMETHOD.

  METHOD test_nest_view_display.

    DATA temp10 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp10.
    temp10 ?= mo_client.

    li_client = temp10.
    li_client->nest_view_destroy( ).
    li_client->nest_view_display( val            = `<NestView/>`
                                  id             = `nest1`
                                  method_insert  = `addMidColumnPage`
                                  method_destroy = `removeMidColumnPage` ).

    " display after destroy: the display replaces it - the frontend tears
    " the slot down implicitly, so ONE display action is the whole sequence
    cl_abap_unit_assert=>assert_equals(
        exp = `NEST|display|<NestView/>|` &&
              `{"id":"nest1","methodDestroy":"removeMidColumnPage","methodInsert":"addMidColumnPage"}`
        act = system_actions( ) ).

  ENDMETHOD.

  METHOD test_nest_view_destroy.

    DATA temp11 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp11.
    temp11 ?= mo_client.

    li_client = temp11.
    li_client->nest_view_display( val           = `<NestView/>`
                                  id            = `nest1`
                                  method_insert = `addMidColumnPage` ).
    li_client->nest_view_destroy( ).

    cl_abap_unit_assert=>assert_equals( exp = `NEST|destroy|`
                                        act = system_actions( ) ).

  ENDMETHOD.

  METHOD test_nest2_view_display.

    DATA temp12 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp12.
    temp12 ?= mo_client.

    li_client = temp12.
    li_client->nest2_view_display( val           = `<Nest2View/>`
                                   id            = `nest2`
                                   method_insert = `addEndColumnPage` ).

    cl_abap_unit_assert=>assert_equals(
        exp = `NEST2|display|<Nest2View/>|` &&
              `{"id":"nest2","methodInsert":"addEndColumnPage"}`
        act = system_actions( ) ).

  ENDMETHOD.

  METHOD test_nest2_view_destroy.

    DATA temp13 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp13.
    temp13 ?= mo_client.

    li_client = temp13.
    li_client->nest2_view_destroy( ).

    cl_abap_unit_assert=>assert_equals( exp = `NEST2|destroy|`
                                        act = system_actions( ) ).

  ENDMETHOD.

  METHOD test_message_box_display.

    DATA temp14 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp14.
    DATA temp1 LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp2 LIKE sy-tabix.
    temp14 ?= mo_client.

    li_client = temp14.
    li_client->message_box_display( `Hello World` ).



    temp2 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 1 INTO temp1.
    sy-tabix = temp2.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["MESSAGE_BOX","show","Hello World",{"title":"Information"}]`
        act = temp1-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_message_box_type.

    DATA temp15 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp15.
    DATA temp3 LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp4 LIKE sy-tabix.
    temp15 ?= mo_client.

    li_client = temp15.
    li_client->message_box_display( text = `Error occurred`
                                    type = `error` ).



    temp4 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 1 INTO temp3.
    sy-tabix = temp4.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["MESSAGE_BOX","error","Error occurred"]`
        act = temp3-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_message_box_dependent.

    DATA temp15b TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp15b.
    DATA temp5 LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp6 LIKE sy-tabix.
    temp15b ?= mo_client.

    li_client = temp15b.
    li_client->message_box_display( text         = `The quantity exceeds the plan.`
                                    type         = `confirm`
                                    dependenton  = `myPage`
                                    contentwidth = `20rem` ).



    temp6 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 1 INTO temp5.
    sy-tabix = temp6.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["MESSAGE_BOX","confirm","The quantity exceeds the plan.",` &&
              `{"contentWidth":"20rem","dependentOn":"myPage"}]`
        act = temp5-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_message_toast.

    DATA temp16 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp16.
    DATA temp7 LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp8 LIKE sy-tabix.
    temp16 ?= mo_client.

    li_client = temp16.
    li_client->message_toast_display( `Saved` ).



    temp8 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 1 INTO temp7.
    sy-tabix = temp8.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["MESSAGE_TOAST","show","Saved"]`
        act = temp7-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_set_nav_routing.

    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp9 TYPE string_table.
    li_client ?= mo_client.

    " SET_NAV_ROUTING configures the app rather than calling the frontend: it
    " is remembered on the app ( so a later response of this app, and an app
    " that inherits from it, carry it again ) and queues no action of its own

    CLEAR temp9.
    INSERT z2ui5_if_client=>cs_nav_mode-fresh INTO TABLE temp9.
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-set_nav_routing
                                 t_arg = temp9 ).

    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_client=>cs_nav_mode-fresh
                                        act = mo_action->ms_next-s_nav-set_nav_routing ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_client=>cs_nav_mode-fresh
                                        act = mo_action->mo_app->mv_nav_mode ).
    cl_abap_unit_assert=>assert_initial( mo_action->ms_next-s_action-t_custom ).

  ENDMETHOD.

  METHOD test_set_nav_routing_default.

    DATA li_client TYPE REF TO z2ui5_if_client.
    li_client ?= mo_client.

    " an empty argument list means keep
    li_client->follow_up_action( z2ui5_if_client=>cs_event-set_nav_routing ).

    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_client=>cs_nav_mode-keep
                                        act = mo_action->mo_app->mv_nav_mode ).

  ENDMETHOD.

  METHOD test_follow_up_action.

    DATA temp17 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp17.
    temp17 ?= mo_client.

    li_client = temp17.
    li_client->follow_up_action( `sap.m.MessageToast.show('test')` ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_action->ms_next-s_action-t_custom ) ).

  ENDMETHOD.

  METHOD test_follow_up_action_ev.

    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp11 TYPE string_table.
    DATA temp13 LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp14 LIKE sy-tabix.
    DATA temp15 LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp16 LIKE sy-tabix.
    li_client ?= mo_client.


    CLEAR temp11.
    INSERT `My Title` INTO TABLE temp11.
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-set_title
                                 t_arg = temp11 ).
    li_client->follow_up_action( z2ui5_if_client=>cs_event-location_reload ).

    " framework events travel as pure data - a JSON array serialized in ABAP
    " (get_event_client_ajson), not as an executable eF( ) JS snippet
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( mo_action->ms_next-s_action-t_custom ) ).


    temp14 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 1 INTO temp13.
    sy-tabix = temp14.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `["SET_TITLE","My Title"]`
                                        act = temp13-o_json->stringify( ) ).


    temp16 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 2 INTO temp15.
    sy-tabix = temp16.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `["LOCATION_RELOAD"]`
                                        act = temp15-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_follow_up_action_nav.

    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp17 TYPE string_table.
    DATA temp19 TYPE string_table.
    DATA temp21 LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp22 LIKE sy-tabix.
    DATA temp23 LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp24 LIKE sy-tabix.
    li_client ?= mo_client.

    " a *_nav_container_to event is rerouted to the generic CONTROL_BY_ID call
    " (method `to`, slot as the view) instead of emitting a dedicated event

    CLEAR temp17.
    INSERT `myContainer` INTO TABLE temp17.
    INSERT `myPage` INTO TABLE temp17.
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-nav_container_to
                                 t_arg = temp17 ).

    CLEAR temp19.
    INSERT `popContainer` INTO TABLE temp19.
    INSERT `popPage` INTO TABLE temp19.
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-popup_nav_container_to
                                 t_arg = temp19 ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( mo_action->ms_next-s_action-t_custom ) ).


    temp22 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 1 INTO temp21.
    sy-tabix = temp22.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_BY_ID","myContainer","MAIN","to","myPage"]`
        act = temp21-o_json->stringify( ) ).


    temp24 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 2 INTO temp23.
    sy-tabix = temp24.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_BY_ID","popContainer","POPUP","to","popPage"]`
        act = temp23-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_follow_up_action_ctrl.

    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp25 TYPE string_table.
    DATA temp27 TYPE string_table.
    DATA temp29 TYPE string_table.
    DATA temp31 LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp32 LIKE sy-tabix.
    DATA temp33 LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp34 LIKE sy-tabix.
    DATA temp35 LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp36 LIKE sy-tabix.
    li_client ?= mo_client.

    " the whitelisted control calls are plain follow-up events - t_arg is
    " positional: control_global = object, method, params; control_by_id =
    " id, method, params (the view is the separate view parameter, default
    " cs_view-main -> empty slot; a concrete view fills the slot)

    CLEAR temp25.
    INSERT `MESSAGE_TOAST` INTO TABLE temp25.
    INSERT `show` INTO TABLE temp25.
    INSERT `Hello` INTO TABLE temp25.
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-control_global
                                 t_arg = temp25 ).

    CLEAR temp27.
    INSERT `demoPanel` INTO TABLE temp27.
    INSERT `setExpanded` INTO TABLE temp27.
    INSERT `X` INTO TABLE temp27.
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-control_by_id
                                 t_arg = temp27 ).

    CLEAR temp29.
    INSERT `demoPanel` INTO TABLE temp29.
    INSERT `setExpanded` INTO TABLE temp29.
    INSERT `X` INTO TABLE temp29.
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-control_by_id
                                 view  = z2ui5_if_client=>cs_view-popover
                                 t_arg = temp29 ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( mo_action->ms_next-s_action-t_custom ) ).
    " the eF( ) form KEEPS its CONTROL_GLOBAL prefix - only the framework's
    " own build_global_call drops the dispatch constant from the wire


    temp32 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 1 INTO temp31.
    sy-tabix = temp32.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_GLOBAL","MESSAGE_TOAST","show","Hello"]`
        act = temp31-o_json->stringify( ) ).


    temp34 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 2 INTO temp33.
    sy-tabix = temp34.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_BY_ID","demoPanel","","setExpanded","X"]`
        act = temp33-o_json->stringify( ) ).


    temp36 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 3 INTO temp35.
    sy-tabix = temp36.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_BY_ID","demoPanel","POPOVER","setExpanded","X"]`
        act = temp35-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_check_on_init.

    mo_action->mo_app->mv_check_initialized = abap_false.

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = mo_client->z2ui5_if_client~check_on_init( ) ).

  ENDMETHOD.

  METHOD test_check_on_init_done.

    mo_action->mo_app->mv_check_initialized = abap_true.

    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = mo_client->z2ui5_if_client~check_on_init( ) ).

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
    CREATE OBJECT lo_new_app.

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
    CREATE OBJECT lo_new_app.
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
    CREATE OBJECT lo_app.
    li_client ?= mo_client.

    li_client->nav_app_leave( app   = lo_app
                              event = `MY_EVENT` ).

    cl_abap_unit_assert=>assert_bound( mo_action->ms_next-o_app_leave ).
    cl_abap_unit_assert=>assert_equals( exp = `MY_EVENT`
                                        act = mo_action->ms_next-next_event ).
    " the dedicated backend event must not emit any client side JS snippet
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = lines( mo_action->ms_next-s_action-t_custom ) ).

  ENDMETHOD.

  METHOD test_nav_app_leave_r_data.

    DATA lo_app TYPE REF TO ltcl_test_app.
    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA lv_data TYPE string VALUE `payload`.
    CREATE OBJECT lo_app.
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
    CREATE OBJECT lo_app.
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
    CREATE OBJECT lo_app.
    li_client ?= mo_client.

    li_client->nav_app_leave( app   = lo_app
                              event = `MY_EVENT` ).

    cl_abap_unit_assert=>assert_not_bound( mo_action->ms_next-r_data ).

  ENDMETHOD.

  METHOD test_nav_leave_r_data_unbound.

    DATA lo_app TYPE REF TO ltcl_test_app.
    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA lr_data TYPE REF TO data.
    CREATE OBJECT lo_app.
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
                                        act = mo_action->ms_next-s_nav-set_push_state ).

  ENDMETHOD.


  METHOD test_get_event.

    DATA li_client TYPE REF TO z2ui5_if_client.

    mo_action->ms_actual-event = `BUTTON_PRESS`.

    li_client ?= mo_client.

    cl_abap_unit_assert=>assert_equals( exp = `BUTTON_PRESS`
                                        act = li_client->get_event( ) ).

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

  METHOD test_omit_initial_paths.

    " the filter behind _bind( omit_initial_paths ): only a LISTED column is
    " dropped when initial, so an abap_false that must reach the client (itself
    " initial) survives as long as its column is not listed. That is the whole
    " reason the scoped form exists next to the blanket omit_initial.
    DATA temp37 TYPE string_table.
    DATA temp1 TYPE REF TO z2ui5_if_ajson_filter.
    DATA li_filter LIKE temp1.
    DATA temp39 TYPE z2ui5_if_ajson_types=>ty_node.
    DATA temp40 TYPE z2ui5_if_ajson_types=>ty_node.
    DATA temp41 TYPE z2ui5_if_ajson_types=>ty_node.
    DATA temp42 TYPE z2ui5_if_ajson_types=>ty_node.
    DATA temp43 TYPE z2ui5_if_ajson_types=>ty_node.
    CLEAR temp37.
    INSERT `MIN` INTO TABLE temp37.
    INSERT `/ROWS/MAX` INTO TABLE temp37.

    CREATE OBJECT temp1 TYPE lcl_initial_paths_filter EXPORTING IT_PATHS = temp37.

    li_filter = temp1.

    " listed + initial -> dropped

    CLEAR temp39.
    temp39-name = `MIN`.
    temp39-type = `num`.
    temp39-value = `0`.
    cl_abap_unit_assert=>assert_equals(
        exp = abap_false
        act = li_filter->keep_node( temp39 ) ).
    " listed by its last path segment as well

    CLEAR temp40.
    temp40-name = `MAX`.
    temp40-type = `str`.
    temp40-value = ``.
    cl_abap_unit_assert=>assert_equals(
        exp = abap_false
        act = li_filter->keep_node( temp40 ) ).
    " listed but filled -> kept

    CLEAR temp41.
    temp41-name = `MIN`.
    temp41-type = `num`.
    temp41-value = `5`.
    cl_abap_unit_assert=>assert_equals(
        exp = abap_true
        act = li_filter->keep_node( temp41 ) ).
    " NOT listed and initial -> kept: this is the boolean that must send false

    CLEAR temp42.
    temp42-name = `ENABLED`.
    temp42-type = `bool`.
    temp42-value = `false`.
    cl_abap_unit_assert=>assert_equals(
        exp = abap_true
        act = li_filter->keep_node( temp42 ) ).
    " an object/array visit always passes, or the row around a dropped field would go

    CLEAR temp43.
    temp43-name = `MIN`.
    temp43-type = `object`.
    cl_abap_unit_assert=>assert_equals(
        exp = abap_true
        act = li_filter->keep_node( is_node  = temp43
                                    iv_visit = z2ui5_if_ajson_filter=>visit_type-open ) ).

  ENDMETHOD.


  METHOD test_omit_initial_keeps_rows.

    " the filter behind _bind( omit_initial = abap_true ): initial FIELDS are
    " omitted, but a table ROW that is entirely initial must survive as {} -
    " the vendored empty filter dropped it, so the client array had fewer
    " entries than the backend table and every row behind the gap was
    " shifted: whole-table write-back deleted the row from backend state and
    " a __delta row index (0-based client position, applied against the FULL
    " backend table) landed the edit one row too early
    TYPES:
      BEGIN OF ty_s_row,
        title TYPE string,
        count TYPE i,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

    " built statement by statement: the downport rewrites a VALUE table
    " constructor into INSERTs from one shared work area without clearing it
    " between rows, so an inline `( )` row would arrive as a copy of its
    " predecessor instead of an all-initial line
    DATA lt_tab TYPE ty_t_row.
    DATA temp44 TYPE ty_s_row.
    DATA temp45 TYPE ty_s_row.
    DATA temp46 TYPE REF TO z2ui5_if_ajson.
    DATA lo_ajson LIKE temp46.
    DATA lo_act TYPE REF TO z2ui5_if_ajson.
    DATA temp2 TYPE REF TO lcl_empty_filter_keep_rows.
    DATA temp47 TYPE ty_s_row.
    DATA ls_nest LIKE temp47.
    DATA temp48 TYPE REF TO z2ui5_if_ajson.
    DATA temp49 TYPE REF TO lcl_empty_filter_keep_rows.
    CLEAR temp44.
    temp44-title = `first`.
    temp44-count = 1.
    APPEND temp44 TO lt_tab.
    APPEND INITIAL LINE TO lt_tab.

    CLEAR temp45.
    temp45-title = `third`.
    temp45-count = 3.
    APPEND temp45 TO lt_tab.


    temp46 ?= z2ui5_cl_ajson=>create_empty( ).

    lo_ajson = temp46.
    lo_ajson->set( iv_ignore_empty = abap_false
                   iv_path         = `/`
                   iv_val          = lt_tab ).


    CREATE OBJECT temp2 TYPE lcl_empty_filter_keep_rows.
    lo_act = lo_ajson->filter( temp2 ).

    " THREE entries - the all-initial middle row stays as an empty object,
    " its initial fields (and only those) are omitted
    cl_abap_unit_assert=>assert_equals(
        exp = `[{"count":1,"title":"first"},{},{"count":3,"title":"third"}]`
        act = lo_act->stringify( ) ).

    " the same shape as a struct MEMBER (not an array element) keeps the old
    " empty-filter behavior: an all-initial sub-structure vanishes entirely,
    " taking the then-empty root with it - stringify of the empty tree is ``

    CLEAR temp47.

    ls_nest = temp47.

    temp48 ?= z2ui5_cl_ajson=>create_empty( ).
    lo_ajson = temp48.
    lo_ajson->set( iv_ignore_empty = abap_false
                   iv_path         = `/sub`
                   iv_val          = ls_nest ).

    CREATE OBJECT temp49 TYPE lcl_empty_filter_keep_rows.
    cl_abap_unit_assert=>assert_equals(
        exp = ``
        act = lo_ajson->filter( temp49 )->stringify( ) ).

  ENDMETHOD.


  METHOD test_set_app_state_active.

    DATA temp31 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp31.
    temp31 ?= mo_client.

    li_client = temp31.
    li_client->set_app_state_active( abap_true ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = mo_action->ms_next-s_nav-set_app_state_active ).

  ENDMETHOD.

ENDCLASS.
