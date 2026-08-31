CLASS ltcl_test_app DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mv_name TYPE string ##NEEDED.

    TYPES:
      BEGIN OF ty_s_emp,
        name TYPE string,
        job  TYPE string,
      END OF ty_s_emp.
    TYPES temp1_f9908b1ee3 TYPE STANDARD TABLE OF ty_s_emp WITH DEFAULT KEY.
DATA mt_emp TYPE temp1_f9908b1ee3 ##NEEDED.
ENDCLASS.

CLASS ltcl_test_app IMPLEMENTATION.
  METHOD z2ui5_if_app~main.
  ENDMETHOD.
ENDCLASS.


" deliberately WITHOUT if_serializable_object - the probe for
" check_raise_new, which must refuse it at bind time (a bound filter is
" serialized into the draft with mt_attri, and the transpiler does not
" enforce serializability, so bind time is the only place the suite can
" prove the refusal)
CLASS ltcl_bad_filter DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_ajson_filter.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_bad_filter IMPLEMENTATION.
  METHOD z2ui5_if_ajson_filter~keep_node.
    rv_keep = abap_true.
  ENDMETHOD.
ENDCLASS.


CLASS ltcl_test_client DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION LONG.

  PRIVATE SECTION.
    DATA mo_client TYPE REF TO z2ui5_cl_ui5_client.
    DATA mo_action TYPE REF TO z2ui5_cl_ui5_action.
    " typed handle on the app instance - _bind( ) resolves its argument as an
    " ATTRIBUTE of the running app, so a local variable cannot stand in
    DATA mo_test_app TYPE REF TO ltcl_test_app.

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
    METHODS test_omit_filters_serial  FOR TESTING RAISING cx_static_check.
    METHODS test_bind_filter_not_serial FOR TESTING RAISING cx_static_check.
    METHODS test_omit_initial_db_save FOR TESTING RAISING cx_static_check.
    METHODS test_bind_tab_cell        FOR TESTING RAISING cx_static_check.
    METHODS test_bind_tab_cell_assign FOR TESTING RAISING cx_static_check.
    METHODS test_event_arg_shorthand  FOR TESTING RAISING cx_static_check.
    METHODS test_event_arg_appends    FOR TESTING RAISING cx_static_check.
    METHODS test_event_arg_empty      FOR TESTING RAISING cx_static_check.
    METHODS test_bind_path_alias      FOR TESTING RAISING cx_static_check.
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
    mo_test_app = lo_test_app.
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
    FIELD-SYMBOLS <temp1> LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp2 LIKE sy-tabix.
    temp14 ?= mo_client.

    li_client = temp14.
    li_client->message_box_display( `Hello World` ).



    temp2 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 1 ASSIGNING <temp1>.
    sy-tabix = temp2.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["MESSAGE_BOX","show","Hello World",{"title":"Information"}]`
        act = <temp1>-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_message_box_type.

    DATA temp15 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp15.
    FIELD-SYMBOLS <temp3> LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp4 LIKE sy-tabix.
    temp15 ?= mo_client.

    li_client = temp15.
    li_client->message_box_display( text = `Error occurred`
                                    type = `error` ).



    temp4 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 1 ASSIGNING <temp3>.
    sy-tabix = temp4.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["MESSAGE_BOX","error","Error occurred"]`
        act = <temp3>-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_message_box_dependent.

    DATA temp15b TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp15b.
    FIELD-SYMBOLS <temp5> LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp6 LIKE sy-tabix.
    temp15b ?= mo_client.

    li_client = temp15b.
    li_client->message_box_display( text         = `The quantity exceeds the plan.`
                                    type         = `confirm`
                                    dependenton  = `myPage`
                                    contentwidth = `20rem` ).



    temp6 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 1 ASSIGNING <temp5>.
    sy-tabix = temp6.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["MESSAGE_BOX","confirm","The quantity exceeds the plan.",` &&
              `{"contentWidth":"20rem","dependentOn":"myPage"}]`
        act = <temp5>-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_message_toast.

    DATA temp16 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp16.
    FIELD-SYMBOLS <temp7> LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp8 LIKE sy-tabix.
    temp16 ?= mo_client.

    li_client = temp16.
    li_client->message_toast_display( `Saved` ).



    temp8 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 1 ASSIGNING <temp7>.
    sy-tabix = temp8.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["MESSAGE_TOAST","show","Saved"]`
        act = <temp7>-o_json->stringify( ) ).

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
    FIELD-SYMBOLS <temp13> LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp14 LIKE sy-tabix.
    FIELD-SYMBOLS <temp15> LIKE LINE OF mo_action->ms_next-s_action-t_custom.
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
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 1 ASSIGNING <temp13>.
    sy-tabix = temp14.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `["SET_TITLE","My Title"]`
                                        act = <temp13>-o_json->stringify( ) ).


    temp16 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 2 ASSIGNING <temp15>.
    sy-tabix = temp16.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `["LOCATION_RELOAD"]`
                                        act = <temp15>-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_follow_up_action_nav.

    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp17 TYPE string_table.
    DATA temp19 TYPE string_table.
    FIELD-SYMBOLS <temp21> LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp22 LIKE sy-tabix.
    FIELD-SYMBOLS <temp23> LIKE LINE OF mo_action->ms_next-s_action-t_custom.
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
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 1 ASSIGNING <temp21>.
    sy-tabix = temp22.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_BY_ID","myContainer","MAIN","to","myPage"]`
        act = <temp21>-o_json->stringify( ) ).


    temp24 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 2 ASSIGNING <temp23>.
    sy-tabix = temp24.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_BY_ID","popContainer","POPUP","to","popPage"]`
        act = <temp23>-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_follow_up_action_ctrl.

    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp25 TYPE string_table.
    DATA temp27 TYPE string_table.
    DATA temp29 TYPE string_table.
    FIELD-SYMBOLS <temp31> LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp32 LIKE sy-tabix.
    FIELD-SYMBOLS <temp33> LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp34 LIKE sy-tabix.
    FIELD-SYMBOLS <temp35> LIKE LINE OF mo_action->ms_next-s_action-t_custom.
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
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 1 ASSIGNING <temp31>.
    sy-tabix = temp32.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_GLOBAL","MESSAGE_TOAST","show","Hello"]`
        act = <temp31>-o_json->stringify( ) ).


    temp34 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 2 ASSIGNING <temp33>.
    sy-tabix = temp34.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_BY_ID","demoPanel","","setExpanded","X"]`
        act = <temp33>-o_json->stringify( ) ).


    temp36 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 3 ASSIGNING <temp35>.
    sy-tabix = temp36.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_BY_ID","demoPanel","POPOVER","setExpanded","X"]`
        act = <temp35>-o_json->stringify( ) ).

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


  METHOD test_event_arg_shorthand.

    " the whole contract of arg: the shorthand and the hand-written table
    " constructor produce the SAME wire, so nothing downstream - the handler,
    " get_event_arg( ), the linter rules that read these wires - can tell
    " which spelling an app used
    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp37 TYPE string_table.

    li_client ?= mo_client.


    CLEAR temp37.
    INSERT `${AUTHOR}` INTO TABLE temp37.
    cl_abap_unit_assert=>assert_equals(
        exp = li_client->_event( val   = `PRESSED`
                                 t_arg = temp37 )
        act = li_client->_event( val = `PRESSED` arg = `${AUTHOR}` ) ).

  ENDMETHOD.


  METHOD test_event_arg_appends.

    " both parameters supplied: arg lands BEHIND the t_arg rows. Documented
    " composition rather than a guess between two readings - and asserted so
    " it stays that and does not silently become "arg wins"
    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp39 TYPE string_table.
    DATA temp1 TYPE string_table.

    li_client ?= mo_client.


    CLEAR temp39.
    INSERT `first` INTO TABLE temp39.
    INSERT `second` INTO TABLE temp39.

    CLEAR temp1.
    INSERT `first` INTO TABLE temp1.
    cl_abap_unit_assert=>assert_equals(
        exp = li_client->_event( val   = `PRESSED`
                                 t_arg = temp39 )
        act = li_client->_event( val   = `PRESSED`
                                 t_arg = temp1
                                 arg   = `second` ) ).

  ENDMETHOD.


  METHOD test_event_arg_empty.

    " read with IS SUPPLIED, not IS NOT INITIAL: an argument passed as empty
    " on purpose is a filled slot. Were it dropped, every following position
    " would shift - the defect class this wire has produced before
    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp41 TYPE string_table.

    li_client ?= mo_client.


    CLEAR temp41.
    INSERT `` INTO TABLE temp41.
    cl_abap_unit_assert=>assert_equals(
        exp = li_client->_event( val   = `PRESSED`
                                 t_arg = temp41 )
        act = li_client->_event( val = `PRESSED` arg = `` ) ).

    " and the parameter left out is not the same as passed empty
    cl_abap_unit_assert=>assert_differs(
        exp = li_client->_event( `PRESSED` )
        act = li_client->_event( val = `PRESSED` arg = `` ) ).

  ENDMETHOD.


  METHOD test_bind_path_alias.

    " _bind_path( ) is _bind( path = abap_true ) and nothing else
    DATA li_client TYPE REF TO z2ui5_if_client.

    li_client ?= mo_client.

    cl_abap_unit_assert=>assert_equals(
        exp = li_client->_bind( val  = mo_test_app->mv_name
                                path = abap_true )
        act = li_client->_bind_path( mo_test_app->mv_name ) ).

    " and it really is the PATH, not the value - otherwise the assertion
    " above would also hold for two calls that both return the wrong thing
    cl_abap_unit_assert=>assert_equals(
        exp = `/MV_NAME`
        act = li_client->_bind_path( mo_test_app->mv_name ) ).

    " the braces are exactly the difference the flag makes - the value form
    " of the same attribute wraps the path, the path form hands it over bare
    cl_abap_unit_assert=>assert_equals(
        exp = `{/MV_NAME}`
        act = li_client->_bind( mo_test_app->mv_name ) ).

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
    DATA temp43 TYPE string_table.
    DATA temp3 TYPE REF TO z2ui5_if_ajson_filter.
    DATA li_filter LIKE temp3.
    DATA temp45 TYPE z2ui5_if_ajson_types=>ty_node.
    DATA temp46 TYPE z2ui5_if_ajson_types=>ty_node.
    DATA temp47 TYPE z2ui5_if_ajson_types=>ty_node.
    DATA temp48 TYPE z2ui5_if_ajson_types=>ty_node.
    DATA temp49 TYPE z2ui5_if_ajson_types=>ty_node.
    CLEAR temp43.
    INSERT `MIN` INTO TABLE temp43.
    INSERT `/ROWS/MAX` INTO TABLE temp43.

    CREATE OBJECT temp3 TYPE lcl_initial_paths_filter EXPORTING IT_PATHS = temp43.

    li_filter = temp3.

    " listed + initial -> dropped

    CLEAR temp45.
    temp45-name = `MIN`.
    temp45-type = `num`.
    temp45-value = `0`.
    cl_abap_unit_assert=>assert_equals(
        exp = abap_false
        act = li_filter->keep_node( temp45 ) ).
    " listed by its last path segment as well

    CLEAR temp46.
    temp46-name = `MAX`.
    temp46-type = `str`.
    temp46-value = ``.
    cl_abap_unit_assert=>assert_equals(
        exp = abap_false
        act = li_filter->keep_node( temp46 ) ).
    " listed but filled -> kept

    CLEAR temp47.
    temp47-name = `MIN`.
    temp47-type = `num`.
    temp47-value = `5`.
    cl_abap_unit_assert=>assert_equals(
        exp = abap_true
        act = li_filter->keep_node( temp47 ) ).
    " NOT listed and initial -> kept: this is the boolean that must send false

    CLEAR temp48.
    temp48-name = `ENABLED`.
    temp48-type = `bool`.
    temp48-value = `false`.
    cl_abap_unit_assert=>assert_equals(
        exp = abap_true
        act = li_filter->keep_node( temp48 ) ).
    " an object/array visit always passes, or the row around a dropped field would go

    CLEAR temp49.
    temp49-name = `MIN`.
    temp49-type = `object`.
    cl_abap_unit_assert=>assert_equals(
        exp = abap_true
        act = li_filter->keep_node( is_node  = temp49
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
    DATA temp50 TYPE ty_s_row.
    DATA temp51 TYPE ty_s_row.
    DATA temp52 TYPE REF TO z2ui5_if_ajson.
    DATA lo_ajson LIKE temp52.
    DATA lo_act TYPE REF TO z2ui5_if_ajson.
    DATA temp4 TYPE REF TO lcl_empty_filter_keep_rows.
    DATA temp53 TYPE ty_s_row.
    DATA ls_nest LIKE temp53.
    DATA temp54 TYPE REF TO z2ui5_if_ajson.
    DATA temp55 TYPE REF TO lcl_empty_filter_keep_rows.
    CLEAR temp50.
    temp50-title = `first`.
    temp50-count = 1.
    APPEND temp50 TO lt_tab.
    APPEND INITIAL LINE TO lt_tab.

    CLEAR temp51.
    temp51-title = `third`.
    temp51-count = 3.
    APPEND temp51 TO lt_tab.


    temp52 ?= z2ui5_cl_ajson=>create_empty( ).

    lo_ajson = temp52.
    lo_ajson->set( iv_ignore_empty = abap_false
                   iv_path         = `/`
                   iv_val          = lt_tab ).


    CREATE OBJECT temp4 TYPE lcl_empty_filter_keep_rows.
    lo_act = lo_ajson->filter( temp4 ).

    " THREE entries - the all-initial middle row stays as an empty object,
    " its initial fields (and only those) are omitted
    cl_abap_unit_assert=>assert_equals(
        exp = `[{"count":1,"title":"first"},{},{"count":3,"title":"third"}]`
        act = lo_act->stringify( ) ).

    " the same shape as a struct MEMBER (not an array element) keeps the old
    " empty-filter behavior: an all-initial sub-structure vanishes entirely,
    " taking the then-empty root with it - stringify of the empty tree is ``

    CLEAR temp53.

    ls_nest = temp53.

    temp54 ?= z2ui5_cl_ajson=>create_empty( ).
    lo_ajson = temp54.
    lo_ajson->set( iv_ignore_empty = abap_false
                   iv_path         = `/sub`
                   iv_val          = ls_nest ).

    CREATE OBJECT temp55 TYPE lcl_empty_filter_keep_rows.
    cl_abap_unit_assert=>assert_equals(
        exp = ``
        act = lo_ajson->filter( temp55 )->stringify( ) ).

  ENDMETHOD.


  METHOD test_omit_filters_serial.

    " every filter the framework itself hands into a binding is serialized
    " into the draft with mt_attri, so all three local classes have to pass
    " the same contract check that check_raise_new applies to a caller's
    " filter. CALL TRANSFORMATION under the transpiler does not enforce
    " if_serializable_object, so this check IS what the suite can prove -
    " a real system enforces it at db_save
    DATA li_omit TYPE REF TO z2ui5_if_ajson_filter.
    DATA li_paths TYPE REF TO z2ui5_if_ajson_filter.
    DATA temp56 TYPE string_table.
    DATA temp58 TYPE REF TO lcl_and_filter.
    DATA temp59 TYPE REF TO ltcl_bad_filter.

    CREATE OBJECT li_omit TYPE lcl_empty_filter_keep_rows.
    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_ui5_util_context=>rtti_check_serializable( li_omit ) ).


    CLEAR temp56.
    INSERT `MIN` INTO TABLE temp56.
    CREATE OBJECT li_paths TYPE lcl_initial_paths_filter EXPORTING IT_PATHS = temp56.
    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_ui5_util_context=>rtti_check_serializable( li_paths ) ).


    CREATE OBJECT temp58 TYPE lcl_and_filter EXPORTING ii_first = li_paths ii_second = li_omit.
    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_ui5_util_context=>rtti_check_serializable(
            temp58 ) ).

    " and the probe class is really refused by the same check - otherwise
    " test_bind_filter_not_serial proves nothing

    CREATE OBJECT temp59 TYPE ltcl_bad_filter.
    cl_abap_unit_assert=>assert_false(
        z2ui5_cl_ui5_util_context=>rtti_check_serializable( temp59 ) ).

  ENDMETHOD.


  METHOD test_bind_filter_not_serial.

    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA lo_app TYPE REF TO ltcl_test_app.
    DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp60 TYPE REF TO ltcl_bad_filter.
        DATA temp1 TYPE xsdboolean.

    li_client ?= mo_client.
    lo_app ?= mo_action->mo_app->mo_app.

    TRY.

        CREATE OBJECT temp60 TYPE ltcl_bad_filter.
        li_client->_bind( val           = lo_app->mv_name
                          custom_filter = temp60 ).
        cl_abap_unit_assert=>fail(
            `a non-serializable custom_filter must be refused at bind time - serialized into the draft it fails only at db_save on a real system` ).
      CATCH z2ui5_cx_ui5_util_error INTO lx.

        temp1 = boolc( lx->get_text( ) CS `serializable` ).
        cl_abap_unit_assert=>assert_true( temp1 ).
    ENDTRY.

  ENDMETHOD.


  METHOD test_omit_initial_db_save.

    " _bind( omit_initial ) -> db_save -> db_load: the filter object rides
    " on mt_attri into the draft (main_attri_db_save_srtti clears only DATA
    " references), so the cycle only survives with serializable filter
    " classes. Under the transpiler the serializer does not enforce that -
    " what this proves everywhere is that the cycle keeps the app state and
    " the binding metadata intact with the filter in place
    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA lo_app TYPE REF TO ltcl_test_app.
    DATA lo_cont TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_cont_db TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_app_db TYPE REF TO ltcl_test_app.
    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    FIELD-SYMBOLS <temp61> TYPE z2ui5_if_ui5_types=>ty_s_attri.

    li_client ?= mo_client.
    lo_cont = mo_action->mo_app.
    lo_app ?= lo_cont->mo_app.
    lo_app->mv_name = `kept across the draft`.

    li_client->_bind( val          = lo_app->mv_name
                      omit_initial = abap_true ).

    lo_cont->ms_draft-id = `TEST_OMIT_INITIAL_DRAFT`.
    lo_cont->db_save( ).
    z2ui5_cl_ui5_app_cont=>db_load_buffer_clear( ).

    lo_cont_db = z2ui5_cl_ui5_app_cont=>db_load( `TEST_OMIT_INITIAL_DRAFT` ).
    lo_app_db ?= lo_cont_db->mo_app.

    cl_abap_unit_assert=>assert_equals( exp = `kept across the draft`
                                        act = lo_app_db->mv_name ).

    " the binding metadata came back with the draft


    READ TABLE lo_cont_db->mt_attri->* WITH KEY name = `MV_NAME` ASSIGNING <temp61>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.
GET REFERENCE OF <temp61> INTO lr_attri.
    cl_abap_unit_assert=>assert_bound( lr_attri ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lr_attri->bind ).

  ENDMETHOD.


  METHOD test_bind_tab_cell.

    " The CELL form of _bind, exactly as an app writes it: the bound value
    " is the row COMPONENT, the table and the row number travel beside it.
    " ABAP counts rows from 1, the client path from 0.
    "
    " This is the one place the app-facing form is proved, and it is also the
    " CANARY for node/setup/patch-abaplint-downport.mjs. Stock abaplint lowers
    " `tab[ n ]-comp` to `READ TABLE ... INTO <wa>` - a copy, so the reference
    " this binding matches on never arrives and the cell is refused. The patch
    " makes the outline ASSIGNING, which is what the WRITE path of the same
    " rule already emits; this test is green in the transpiled suite only
    " because the patch is applied. If it starts failing, look at the patch
    " before looking at the binding. The cell logic itself is covered
    " everywhere by ltcl_test_main_cell in z2ui5_cl_ui5_srv_bind
    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA lo_app TYPE REF TO ltcl_test_app.
    DATA temp62 TYPE ltcl_test_app=>ty_s_emp.
    DATA temp63 TYPE ltcl_test_app=>ty_s_emp.
    FIELD-SYMBOLS <temp64> LIKE LINE OF lo_app->mt_emp.
    DATA temp65 LIKE sy-tabix.
    FIELD-SYMBOLS <temp66> LIKE LINE OF lo_app->mt_emp.
    DATA temp67 LIKE sy-tabix.

    li_client ?= mo_client.
    lo_app ?= mo_action->mo_app->mo_app.

    CLEAR temp62.
    temp62-name = `Michael Adams`.
    temp62-job = `Scrum Master`.
    INSERT temp62 INTO TABLE lo_app->mt_emp.

    CLEAR temp63.
    temp63-name = `John Miller`.
    temp63-job = `Product Owner`.
    INSERT temp63 INTO TABLE lo_app->mt_emp.



    temp65 = sy-tabix.
    READ TABLE lo_app->mt_emp INDEX 1 ASSIGNING <temp64>.
    sy-tabix = temp65.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `{/MT_EMP/0/NAME}`
        act = li_client->_bind( val       = <temp64>-name
                                tab       = lo_app->mt_emp
                                tab_index = 1 ) ).



    temp67 = sy-tabix.
    READ TABLE lo_app->mt_emp INDEX 2 ASSIGNING <temp66>.
    sy-tabix = temp67.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `{/MT_EMP/1/JOB}`
        act = li_client->_bind( val       = <temp66>-job
                                tab       = lo_app->mt_emp
                                tab_index = 2 ) ).

  ENDMETHOD.


  METHOD test_bind_tab_cell_assign.

    " The same cell over an ASSIGNED row - the spelling the doc block on
    " _bind recommends, and the only one that survives a downport: the
    " whole-row table expression keeps its reference through it
    " (READ TABLE ... ASSIGNING), the component-level one does not. So this
    " test runs on every target, including this pipeline
    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA lo_app TYPE REF TO ltcl_test_app.
    FIELD-SYMBOLS <emp> TYPE ltcl_test_app=>ty_s_emp.
    DATA temp68 TYPE ltcl_test_app=>ty_s_emp.
    DATA temp69 TYPE ltcl_test_app=>ty_s_emp.

    li_client ?= mo_client.
    lo_app ?= mo_action->mo_app->mo_app.

    CLEAR temp68.
    temp68-name = `Michael Adams`.
    temp68-job = `Scrum Master`.
    INSERT temp68 INTO TABLE lo_app->mt_emp.

    CLEAR temp69.
    temp69-name = `John Miller`.
    temp69-job = `Product Owner`.
    INSERT temp69 INTO TABLE lo_app->mt_emp.

    READ TABLE lo_app->mt_emp INDEX 1 ASSIGNING <emp>.
    cl_abap_unit_assert=>assert_equals(
        exp = `{/MT_EMP/0/NAME}`
        act = li_client->_bind( val       = <emp>-name
                                tab       = lo_app->mt_emp
                                tab_index = 1 ) ).

    READ TABLE lo_app->mt_emp INDEX 2 ASSIGNING <emp>.
    cl_abap_unit_assert=>assert_equals(
        exp = `{/MT_EMP/1/JOB}`
        act = li_client->_bind( val       = <emp>-job
                                tab       = lo_app->mt_emp
                                tab_index = 2 ) ).

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


"------------------------------------------------------------------------
" The first CONSUMER of client->get( )-t_model_skipped
"
" The five tests on z2ui5_cl_ui5_srv_model reach into the model service and
" read mt_skipped there. Nothing exercised the way OUT - app_cont's
" model_json_parse, the action that carries the list for this roundtrip, and
" get( ), which is the only thing an app ever sees. So this drives the whole
" wire with an app that reacts to the trace the way an app has to.
"------------------------------------------------------------------------
CLASS ltcl_app_price_editor DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_pos,
        qty TYPE i,
      END OF ty_s_pos.
    TYPES ty_t_pos TYPE STANDARD TABLE OF ty_s_pos WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_product,
        name  TYPE string,
        price TYPE p LENGTH 9 DECIMALS 2,
        t_pos TYPE ty_t_pos,
      END OF ty_s_product.
    TYPES ty_t_product TYPE STANDARD TABLE OF ty_s_product WITH DEFAULT KEY.

    DATA mt_product TYPE ty_t_product.

    " what the user is told - empty exactly when the write-back was complete
    DATA mv_message TYPE string.
    " the Save handler's verdict. Before the trace existed it could only ever
    " be abap_true, over discarded input included
    DATA mv_saved   TYPE abap_bool.
    " the binding path _bind gave the view. Kept because it is NOT the
    " spelling the trace uses - see test_bind_path_is_not_name
    DATA mv_bind_path TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
    "! `PRICE` -> `Price`. The trace names the ABAP COMPONENT, so an app that
    "! wants to name the field to a user owns this mapping itself - there is
    "! nothing in the entry a label could be derived from.
    METHODS label_of
      IMPORTING
        field         TYPE string
      RETURNING
        VALUE(result) TYPE string.

    METHODS message_add
      IMPORTING
        val TYPE string.
ENDCLASS.

CLASS ltcl_app_price_editor IMPLEMENTATION.

  METHOD label_of.

    CASE field.
      WHEN `PRICE`.
        result = `Price`.
      WHEN `QTY`.
        result = `Quantity`.
      WHEN OTHERS.
        result = field.
    ENDCASE.

  ENDMETHOD.

  METHOD message_add.

    IF mv_message IS NOT INITIAL.
      mv_message = mv_message && `; `.
    ENDIF.
    mv_message = mv_message && val.

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

    DATA ls_row TYPE ty_s_product.

    DATA ls_get TYPE z2ui5_if_client=>ty_s_get.
    DATA ls_skip LIKE LINE OF ls_get-t_model_skipped.
      DATA temp2 TYPE xsdboolean.
    ls_get = client->get( ).

    " Read UNCONDITIONALLY, before any event branch. The delta travels with
    " whatever roundtrip follows the edit, and that is not necessarily the
    " Save press - an app that only looks inside its Save branch misses the
    " refusal on every other button.
    CLEAR mv_message.

    LOOP AT ls_get-t_model_skipped INTO ls_skip.

      IF ls_skip-name = `MT_PRODUCT`.
        " the row index is an ABAP table index, so the app's own READ TABLE
        " reaches the same row with no translation
        READ TABLE mt_product INDEX ls_skip-row INTO ls_row.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        message_add( |{ label_of( ls_skip-field ) } of '{ ls_row-name }' was not accepted| ).
        CONTINUE.
      ENDIF.

      IF ls_skip-name = `MT_PRODUCT-T_POS`.
        " a NESTED table: row is the index inside T_POS, and the entry says
        " nothing about which MT_PRODUCT row owns that T_POS - so this is the
        " best an app can do
        message_add( |{ label_of( ls_skip-field ) } in a position row was not accepted| ).
        CONTINUE.
      ENDIF.

    ENDLOOP.

    IF ls_get-event = `SAVE`.

      temp2 = boolc( mv_message IS INITIAL ).
      mv_saved = temp2.
    ENDIF.

    mv_bind_path = client->_bind_edit( mt_product ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_model_skipped DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_app    TYPE REF TO ltcl_app_price_editor.
    DATA mo_action TYPE REF TO z2ui5_cl_ui5_action.

    METHODS setup RAISING z2ui5_cx_ajson_error.

    "! One roundtrip, assembled the way z2ui5_cl_ui5_action=>factory_by_frontend
    "! assembles it: apply the incoming client model, carry what it could not
    "! apply on the action, then let the app run against a client over it.
    METHODS roundtrip
      IMPORTING
        model TYPE string OPTIONAL
        event TYPE string OPTIONAL
      RAISING
        z2ui5_cx_ajson_error.

    METHODS test_accepted_price_silent  FOR TESTING RAISING cx_static_check.
    METHODS test_refused_price_reported FOR TESTING RAISING cx_static_check.
    METHODS test_save_no_longer_lies    FOR TESTING RAISING cx_static_check.
    METHODS test_trace_is_per_roundtrip FOR TESTING RAISING cx_static_check.
    METHODS test_nested_row_unresolved  FOR TESTING RAISING cx_static_check.
    METHODS test_bind_path_is_not_name  FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test_model_skipped IMPLEMENTATION.

  METHOD setup.

    DATA ls_product TYPE ltcl_app_price_editor=>ty_s_product.

    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA temp70 TYPE ltcl_app_price_editor=>ty_s_pos.
    CREATE OBJECT lo_http TYPE z2ui5_cl_ui5_handler EXPORTING val = ``.
    CREATE OBJECT mo_action EXPORTING val = lo_http.
    CREATE OBJECT mo_app.

    CLEAR ls_product.
    ls_product-name  = `Notebook`.
    ls_product-price = '1249.00'.

    CLEAR temp70.
    temp70-qty = 1.
    APPEND temp70 TO ls_product-t_pos.
    APPEND ls_product TO mo_app->mt_product.

    CLEAR ls_product.
    ls_product-name  = `Monitor`.
    ls_product-price = '299.00'.
    APPEND ls_product TO mo_app->mt_product.

    mo_action->mo_app->mo_app = mo_app.

    " the init roundtrip - it is what BINDS mt_product, and nothing can be
    " written back before that happened
    roundtrip( ).

  ENDMETHOD.

  METHOD roundtrip.
      DATA temp71 TYPE REF TO z2ui5_if_ajson.
    DATA lo_client TYPE REF TO z2ui5_cl_ui5_client.

    CLEAR mo_action->ms_actual.

    IF model IS NOT INITIAL.

      temp71 ?= z2ui5_cl_ajson=>parse( model ).
      mo_action->ms_actual-t_model_skipped = mo_action->mo_app->model_json_parse(
                                                 temp71 ).
    ENDIF.
    mo_action->ms_actual-event = event.


    CREATE OBJECT lo_client TYPE z2ui5_cl_ui5_client EXPORTING action = mo_action.
    mo_app->z2ui5_if_app~main( lo_client ).

  ENDMETHOD.

  METHOD test_accepted_price_silent.
    DATA temp72 TYPE decfloat34.
    DATA temp5 TYPE decfloat34.
    FIELD-SYMBOLS <temp1> LIKE LINE OF mo_app->mt_product.
    DATA temp2 LIKE sy-tabix.

    " the accepted case first - it is what proves the wire is alive, so the
    " refusal below is a conversion failure and not a dead binding
    roundtrip( model = `{"MT_PRODUCT":{"__delta":{"1":{"PRICE":"1250.00"}}}}`
               event = `SAVE` ).


    temp72 = '1250.00'.



    temp2 = sy-tabix.
    READ TABLE mo_app->mt_product INDEX 2 ASSIGNING <temp1>.
    sy-tabix = temp2.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp5 = <temp1>-price.
    cl_abap_unit_assert=>assert_equals( exp = temp72
                                        act = temp5 ).
    cl_abap_unit_assert=>assert_initial( mo_app->mv_message ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = mo_app->mv_saved ).

  ENDMETHOD.

  METHOD test_refused_price_reported.
    DATA temp73 TYPE decfloat34.
    DATA temp6 TYPE decfloat34.
    FIELD-SYMBOLS <temp3> LIKE LINE OF mo_app->mt_product.
    DATA temp4 LIKE sy-tabix.

    " the grouped thousands separator a locale-formatted Input sends
    roundtrip( model = `{"MT_PRODUCT":{"__delta":{"1":{"PRICE":"1,250.00"}}}}`
               event = `SAVE` ).

    " the cell is still skipped and nothing raised - the old value stands

    temp73 = '299.00'.



    temp4 = sy-tabix.
    READ TABLE mo_app->mt_product INDEX 2 ASSIGNING <temp3>.
    sy-tabix = temp4.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp6 = <temp3>-price.
    cl_abap_unit_assert=>assert_equals( exp = temp73
                                        act = temp6 ).

    " ... and the app could say so, which is the whole point. Name, row and
    " field together were enough to reach the row and quote it back
    cl_abap_unit_assert=>assert_equals( exp = `Price of 'Monitor' was not accepted`
                                        act = mo_app->mv_message ).

  ENDMETHOD.

  METHOD test_save_no_longer_lies.
    DATA temp74 TYPE decfloat34.
    DATA temp7 TYPE decfloat34.
    FIELD-SYMBOLS <temp5> LIKE LINE OF mo_app->mt_product.
    DATA temp6 LIKE sy-tabix.
    DATA temp75 TYPE decfloat34.
    DATA temp8 TYPE decfloat34.
    FIELD-SYMBOLS <temp7> LIKE LINE OF mo_app->mt_product.
    DATA temp9 LIKE sy-tabix.

    " one bad cell, one good one, in the same delta and the same Save press
    roundtrip( model = `{"MT_PRODUCT":{"__delta":{"0":{"PRICE":"abc"},"1":{"PRICE":"350.00"}}}}`
               event = `SAVE` ).

    " the good cell landed - the skip did not take the delta down with it

    temp74 = '350.00'.



    temp6 = sy-tabix.
    READ TABLE mo_app->mt_product INDEX 2 ASSIGNING <temp5>.
    sy-tabix = temp6.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp7 = <temp5>-price.
    cl_abap_unit_assert=>assert_equals( exp = temp74
                                        act = temp7 ).

    temp75 = '1249.00'.



    temp9 = sy-tabix.
    READ TABLE mo_app->mt_product INDEX 1 ASSIGNING <temp7>.
    sy-tabix = temp9.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp8 = <temp7>-price.
    cl_abap_unit_assert=>assert_equals( exp = temp75
                                        act = temp8 ).

    " and Save reports failure over the discarded cell instead of success
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = mo_app->mv_saved ).
    cl_abap_unit_assert=>assert_equals( exp = `Price of 'Notebook' was not accepted`
                                        act = mo_app->mv_message ).

  ENDMETHOD.

  METHOD test_trace_is_per_roundtrip.

    roundtrip( model = `{"MT_PRODUCT":{"__delta":{"1":{"PRICE":"1,250.00"}}}}`
               event = `SAVE` ).
    cl_abap_unit_assert=>assert_equals( exp = `Price of 'Monitor' was not accepted`
                                        act = mo_app->mv_message ).

    " the NEXT roundtrip must not be told about the previous one's refusal -
    " the list describes this request and nothing else
    roundtrip( event = `SAVE` ).
    cl_abap_unit_assert=>assert_initial( mo_app->mv_message ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = mo_app->mv_saved ).

  ENDMETHOD.

  METHOD test_nested_row_unresolved.
    FIELD-SYMBOLS <temp76> LIKE LINE OF mo_app->mt_product.
    DATA temp77 LIKE sy-tabix.
    FIELD-SYMBOLS <temp9> LIKE LINE OF <temp76>-t_pos.
    DATA temp10 LIKE sy-tabix.

    " a cell of the NESTED table. The trace names the path parent first, and
    " row is the index INSIDE t_pos - which MT_PRODUCT row owns that t_pos is
    " not in the entry, so an app cannot name the product
    roundtrip( model = `{"MT_PRODUCT":{"__delta":{"0":{"T_POS":{"__delta":{"0":{"QTY":"seven"}}}}}}}`
               event = `SAVE` ).



    temp77 = sy-tabix.
    READ TABLE mo_app->mt_product INDEX 1 ASSIGNING <temp76>.
    sy-tabix = temp77.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp10 = sy-tabix.
    READ TABLE <temp76>-t_pos INDEX 1 ASSIGNING <temp9>.
    sy-tabix = temp10.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = <temp9>-qty ).
    cl_abap_unit_assert=>assert_equals( exp = `Quantity in a position row was not accepted`
                                        act = mo_app->mv_message ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = mo_app->mv_saved ).

  ENDMETHOD.

  METHOD test_bind_path_is_not_name.
    FIELD-SYMBOLS <temp78> LIKE LINE OF mo_action->ms_actual-t_model_skipped.
    DATA temp79 LIKE sy-tabix.

    " the two spellings of the same table an app has to hold at once: _bind
    " hands the view a client PATH, the trace names the ABAP ATTRIBUTE, and
    " nothing public converts one into the other - so the app above had to
    " carry `MT_PRODUCT` as a literal
    cl_abap_unit_assert=>assert_equals( exp = `{/MT_PRODUCT}`
                                        act = mo_app->mv_bind_path ).

    roundtrip( model = `{"MT_PRODUCT":{"__delta":{"1":{"PRICE":"1,250.00"}}}}` ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_action->ms_actual-t_model_skipped ) ).


    temp79 = sy-tabix.
    READ TABLE mo_action->ms_actual-t_model_skipped INDEX 1 ASSIGNING <temp78>.
    sy-tabix = temp79.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MT_PRODUCT`
                                        act = <temp78>-name ).

  ENDMETHOD.

ENDCLASS.
