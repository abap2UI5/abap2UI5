" ---------------------------------------------------------------------------
" The API contract of z2ui5_if_client as an app sees it: what each method
" answers, what it queues, what it refuses. Where a case here also proves
" the model underneath (a binding path, a cell, a mapper or filter across
" the draft), the systematic coverage is in the structured suites of
" z2ui5_cl_ui5_srv_bind (ltcl_01_path, ltcl_02_cell, ltcl_03_options) and
" z2ui5_cl_ui5_srv_model (ltcl_01_dissolve to ltcl_05_draft); this file
" keeps the call through the client as the app writes it.
" ---------------------------------------------------------------------------
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
    METHODS test_message_box_data     FOR TESTING RAISING cx_static_check.
    METHODS test_message_box_no_data  FOR TESTING RAISING cx_static_check.
    METHODS test_message_toast        FOR TESTING RAISING cx_static_check.
    METHODS test_set_nav_routing      FOR TESTING RAISING cx_static_check.
    METHODS test_set_nav_routing_lower FOR TESTING RAISING cx_static_check.
    METHODS test_set_nav_routing_default FOR TESTING RAISING cx_static_check.
    METHODS test_hash_attach_changed  FOR TESTING RAISING cx_static_check.
    METHODS test_hash_replace         FOR TESTING RAISING cx_static_check.
    METHODS test_hash_set_alias       FOR TESTING RAISING cx_static_check.
    METHODS test_app_state_get_href   FOR TESTING RAISING cx_static_check.
    METHODS test_app_state_href_flp   FOR TESTING RAISING cx_static_check.
    METHODS test_follow_up_action     FOR TESTING RAISING cx_static_check.
    METHODS test_follow_up_action_ev  FOR TESTING RAISING cx_static_check.
    METHODS test_follow_up_action_nav FOR TESTING RAISING cx_static_check.
    METHODS test_follow_up_action_ctrl FOR TESTING RAISING cx_static_check.
    METHODS test_ctrl_global_opt      FOR TESTING RAISING cx_static_check.
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
    METHODS test_omit_initial_decimals FOR TESTING RAISING cx_static_check.
    METHODS test_omit_filters_serial  FOR TESTING RAISING cx_static_check.
    METHODS test_bind_filter_not_serial FOR TESTING RAISING cx_static_check.
    METHODS test_omit_initial_db_save FOR TESTING RAISING cx_static_check.
    METHODS test_bind_tab_cell        FOR TESTING RAISING cx_static_check.
    METHODS test_bind_tab_cell_assign FOR TESTING RAISING cx_static_check.
    METHODS test_event_arg_shorthand  FOR TESTING RAISING cx_static_check.
    METHODS test_event_arg_appends    FOR TESTING RAISING cx_static_check.
    METHODS test_event_arg_empty      FOR TESTING RAISING cx_static_check.
    METHODS test_bind_path_alias      FOR TESTING RAISING cx_static_check.
    METHODS test_get_comp_params_memo FOR TESTING RAISING cx_static_check.
    METHODS test_get_nav_flags_live   FOR TESTING RAISING cx_static_check.
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
    CREATE OBJECT lo_http EXPORTING val = ``.
    CREATE OBJECT mo_action EXPORTING val = lo_http.
    CREATE OBJECT mo_test_app.
    mo_action->mo_app->mo_app = mo_test_app.
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

    DATA li_client TYPE REF TO z2ui5_if_client.

    li_client ?= mo_client.
    li_client->view_display( `<View></View>` ).

    cl_abap_unit_assert=>assert_equals(
        exp = `MAIN|display|<View></View>`
        act = system_actions( ) ).

  ENDMETHOD.

  METHOD test_view_destroy.

    DATA li_client TYPE REF TO z2ui5_if_client.

    li_client ?= mo_client.
    li_client->view_destroy( ).

    cl_abap_unit_assert=>assert_equals( exp = `MAIN|destroy|`
                                        act = system_actions( ) ).

  ENDMETHOD.

  METHOD test_view_model_update.

    " the model is pushed automatically now (z2ui5_cl_ui5_handler=>main_end),
    " so this method is an obsolete NO-OP kept for source compatibility - it
    " must not raise and must not set any slot flag
    DATA li_client TYPE REF TO z2ui5_if_client.

    li_client ?= mo_client.
    li_client->view_model_update( ).

    cl_abap_unit_assert=>assert_initial( mo_action->ms_next-s_action ).

  ENDMETHOD.

  METHOD test_nest_model_update.

    " both nested variants are obsolete NO-OPs too: a nested view owns no
    " model (it inherits MAIN's by propagation) and MAIN is pushed
    " automatically - see test_view_model_update
    DATA li_client TYPE REF TO z2ui5_if_client.

    li_client ?= mo_client.
    li_client->nest_view_model_update( ).
    li_client->nest2_view_model_update( ).

    cl_abap_unit_assert=>assert_initial( mo_action->ms_next-s_action ).

  ENDMETHOD.

  METHOD test_popup_display.

    DATA li_client TYPE REF TO z2ui5_if_client.

    li_client ?= mo_client.
    li_client->popup_display( `<Dialog/>` ).

    cl_abap_unit_assert=>assert_equals(
        exp = `POPUP|display|<Dialog/>`
        act = system_actions( ) ).

  ENDMETHOD.

  METHOD test_popup_destroy.

    DATA li_client TYPE REF TO z2ui5_if_client.

    li_client ?= mo_client.
    li_client->popup_destroy( ).

    cl_abap_unit_assert=>assert_equals(
        exp = `POPUP|destroy|`
        act = system_actions( ) ).

  ENDMETHOD.

  METHOD test_popup_model_update.

    DATA li_client TYPE REF TO z2ui5_if_client.

    li_client ?= mo_client.
    li_client->popup_model_update( ).

    " obsolete NO-OP - main_end( ) queues the model push for every slot itself
    cl_abap_unit_assert=>assert_initial( mo_action->ms_next-s_action ).

  ENDMETHOD.

  METHOD test_popover_display.

    DATA li_client TYPE REF TO z2ui5_if_client.

    li_client ?= mo_client.
    li_client->popover_display( xml   = `<Popover/>`
                                by_id = `btn1` ).

    cl_abap_unit_assert=>assert_equals(
        exp = `POPOVER|display|<Popover/>|{"openById":"btn1"}`
        act = system_actions( ) ).

  ENDMETHOD.

  METHOD test_popover_destroy.

    DATA li_client TYPE REF TO z2ui5_if_client.

    li_client ?= mo_client.
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

    DATA li_client TYPE REF TO z2ui5_if_client.

    li_client ?= mo_client.
    li_client->popover_model_update( ).

    " obsolete NO-OP - main_end( ) queues the model push for every slot itself
    cl_abap_unit_assert=>assert_initial( mo_action->ms_next-s_action ).

  ENDMETHOD.

  METHOD test_nest_view_display.

    DATA li_client TYPE REF TO z2ui5_if_client.

    li_client ?= mo_client.
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

    DATA li_client TYPE REF TO z2ui5_if_client.

    li_client ?= mo_client.
    li_client->nest_view_display( val           = `<NestView/>`
                                  id            = `nest1`
                                  method_insert = `addMidColumnPage` ).
    li_client->nest_view_destroy( ).

    cl_abap_unit_assert=>assert_equals( exp = `NEST|destroy|`
                                        act = system_actions( ) ).

  ENDMETHOD.

  METHOD test_nest2_view_display.

    DATA li_client TYPE REF TO z2ui5_if_client.

    li_client ?= mo_client.
    li_client->nest2_view_display( val           = `<Nest2View/>`
                                   id            = `nest2`
                                   method_insert = `addEndColumnPage` ).

    cl_abap_unit_assert=>assert_equals(
        exp = `NEST2|display|<Nest2View/>|` &&
              `{"id":"nest2","methodInsert":"addEndColumnPage"}`
        act = system_actions( ) ).

  ENDMETHOD.

  METHOD test_nest2_view_destroy.

    DATA li_client TYPE REF TO z2ui5_if_client.

    li_client ?= mo_client.
    li_client->nest2_view_destroy( ).

    cl_abap_unit_assert=>assert_equals( exp = `NEST2|destroy|`
                                        act = system_actions( ) ).

  ENDMETHOD.

  METHOD test_message_box_display.

    DATA li_client TYPE REF TO z2ui5_if_client.
    FIELD-SYMBOLS <temp1> LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp2 LIKE sy-tabix.

    li_client ?= mo_client.
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

    DATA li_client TYPE REF TO z2ui5_if_client.
    FIELD-SYMBOLS <temp3> LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp4 LIKE sy-tabix.

    li_client ?= mo_client.
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

  METHOD test_message_box_data.

    " a business table carries no messages at all - it used to reach the box
    " as one blank line per row. The whole point of the API is that an app
    " hands over what it has without pre-formatting it
    TYPES:
      BEGIN OF ty_s_row,
        carrid TYPE string,
      END OF ty_s_row.
    TYPES temp2 TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.
DATA lt_row TYPE temp2.

    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp5 LIKE lt_row.
    DATA temp6 LIKE LINE OF temp5.
    FIELD-SYMBOLS <temp7> LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp8 LIKE sy-tabix.

    li_client ?= mo_client.

    CLEAR temp5.

    temp6-carrid = `LH`.
    INSERT temp6 INTO TABLE temp5.
    lt_row = temp5.

    li_client->message_box_display( lt_row ).



    temp8 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 1 ASSIGNING <temp7>.
    sy-tabix = temp8.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["MESSAGE_BOX","show","Table with 1 entry",` &&
              `{"details":"<ol><li><ul><li><strong>CARRID</strong>: LH</li></ul></li></ol>",` &&
              `"title":"Information"}]`
        act = <temp7>-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_message_box_no_data.

    " ...and an empty one still queues nothing: an app that shows the result
    " of a call it just made must not get a popup when there was no result
    TYPES:
      BEGIN OF ty_s_row,
        carrid TYPE string,
      END OF ty_s_row.
    TYPES temp3 TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.
DATA lt_row TYPE temp3.

    DATA li_client TYPE REF TO z2ui5_if_client.

    li_client ?= mo_client.

    li_client->message_box_display( lt_row ).

    cl_abap_unit_assert=>assert_initial( mo_action->ms_next-s_action-t_custom ).

  ENDMETHOD.

  METHOD test_message_box_dependent.

    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp9 TYPE string_table.
    FIELD-SYMBOLS <temp11> LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp12 LIKE sy-tabix.

    li_client ?= mo_client.
    " dependentOn and contentWidth are sap.m.MessageBox options, so they are
    " set on the control: the option object of the global call, which is the
    " same object the method below builds for what an ABAP app decides. The
    " object is PARSED on its way to the wire, so its keys arrive sorted -
    " the order an app writes them in carries nothing

    CLEAR temp9.
    INSERT `MESSAGE_BOX` INTO TABLE temp9.
    INSERT `confirm` INTO TABLE temp9.
    INSERT `The quantity exceeds the plan.` INTO TABLE temp9.
    INSERT `{"dependentOn":"myPage","contentWidth":"20rem"}` INTO TABLE temp9.
    li_client->follow_up_action(
        val   = z2ui5_if_client=>cs_event-control_global
        t_arg = temp9 ).



    temp12 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 1 ASSIGNING <temp11>.
    sy-tabix = temp12.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_GLOBAL","MESSAGE_BOX","confirm","The quantity exceeds the plan.",` &&
              `{"contentWidth":"20rem","dependentOn":"myPage"}]`
        act = <temp11>-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_message_toast.

    DATA li_client TYPE REF TO z2ui5_if_client.
    FIELD-SYMBOLS <temp13> LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp14 LIKE sy-tabix.

    li_client ?= mo_client.
    li_client->message_toast_display( `Saved` ).



    temp14 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 1 ASSIGNING <temp13>.
    sy-tabix = temp14.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["MESSAGE_TOAST","show","Saved"]`
        act = <temp13>-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_set_nav_routing.

    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp15 TYPE string_table.
    li_client ?= mo_client.

    " SET_NAV_ROUTING configures the app rather than calling the frontend: it
    " is remembered on the app ( so a later response of this app, and an app
    " that inherits from it, carry it again ) and queues no action of its own

    CLEAR temp15.
    INSERT z2ui5_if_client=>cs_nav_mode-fresh INTO TABLE temp15.
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-set_nav_routing
                                 t_arg = temp15 ).

    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_client=>cs_nav_mode-fresh
                                        act = mo_action->ms_next-s_nav-set_nav_routing ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_client=>cs_nav_mode-fresh
                                        act = mo_action->mo_app->mv_nav_mode ).
    cl_abap_unit_assert=>assert_initial( mo_action->ms_next-s_action-t_custom ).

  ENDMETHOD.

  METHOD test_set_nav_routing_lower.

    " the mode as an app may well write it - lower case - lands upper-cased
    " on both sides, as the constants spell it
    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp17 TYPE string_table.
    li_client ?= mo_client.

    " SET_NAV_ROUTING configures the app rather than calling the frontend: it
    " is remembered on the app ( so a later response of this app, and an app
    " that inherits from it, carry it again ) and queues no action of its own

    CLEAR temp17.
    INSERT `fresh` INTO TABLE temp17.
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-set_nav_routing
                                 t_arg = temp17 ).

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

  METHOD test_hash_attach_changed.

    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp19 TYPE string_table.
    li_client ?= mo_client.

    " registration travels as a nav option, no custom action queued

    CLEAR temp19.
    INSERT `HASH_CHANGED` INTO TABLE temp19.
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-hash_attach_changed
                                 t_arg = temp19 ).

    cl_abap_unit_assert=>assert_equals( exp = `HASH_CHANGED`
                                        act = mo_action->ms_next-s_nav-set_hash_listener ).
    cl_abap_unit_assert=>assert_initial( mo_action->ms_next-s_action-t_custom ).

    " no argument unregisters - a single space, since the frontend reads an
    " EMPTY option as "no change"
    li_client->follow_up_action( z2ui5_if_client=>cs_event-hash_attach_changed ).

    cl_abap_unit_assert=>assert_equals( exp = ` `
                                        act = mo_action->ms_next-s_nav-set_hash_listener ).

  ENDMETHOD.

  METHOD test_hash_replace.

    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp21 TYPE string_table.
    li_client ?= mo_client.

    " the typed method and the constant reach the same nav option
    li_client->hash_replace( `/detail/0/OneColumn` ).

    cl_abap_unit_assert=>assert_equals( exp = `/detail/0/OneColumn`
                                        act = mo_action->ms_next-s_nav-hash_replace ).


    CLEAR temp21.
    INSERT `/other` INTO TABLE temp21.
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-hash_replace
                                 t_arg = temp21 ).

    cl_abap_unit_assert=>assert_equals( exp = `/other`
                                        act = mo_action->ms_next-s_nav-hash_replace ).
    cl_abap_unit_assert=>assert_initial( mo_action->ms_next-s_action-t_custom ).

  ENDMETHOD.

  METHOD test_hash_set_alias.

    DATA li_client TYPE REF TO z2ui5_if_client.
    li_client ?= mo_client.

    " hash_set and the obsolete set_push_state write the same field
    li_client->hash_set( `/Page2` ).

    cl_abap_unit_assert=>assert_equals( exp = `/Page2`
                                        act = mo_action->ms_next-s_nav-set_push_state ).

    li_client->set_push_state( `/Page3` ).

    cl_abap_unit_assert=>assert_equals( exp = `/Page3`
                                        act = mo_action->ms_next-s_nav-set_push_state ).

  ENDMETHOD.

  METHOD test_app_state_get_href.

    DATA li_client TYPE REF TO z2ui5_if_client.
    li_client ?= mo_client.

    " standalone: no shell hash - the app hash carries the state id after
    " exactly one slash, the format the restore path parses
    mo_action->mo_handler->ms_request-s_front-origin   = `https://host:443`.
    mo_action->mo_handler->ms_request-s_front-pathname = `/sap/bc/z2ui5`.
    mo_action->mo_handler->ms_request-s_front-search   = `?sap-client=100`.
    mo_action->mo_handler->ms_request-s_front-hash     = `#/detail/1/OneColumn`.
    mo_action->mo_app->ms_draft-id = `DRAFT1`.

    cl_abap_unit_assert=>assert_equals(
        exp = `https://host:443/sap/bc/z2ui5?sap-client=100#/z2ui5-xapp-state=DRAFT1`
        act = li_client->app_state_get_href( ) ).

  ENDMETHOD.

  METHOD test_app_state_href_flp.

    DATA li_client TYPE REF TO z2ui5_if_client.
    li_client ?= mo_client.

    " inside the FLP the shell hash survives and the state id hangs behind
    " '&/' - exactly the format Router.hrefFor writes, so the recipient
    " lands in this app instead of on the launchpad home page
    mo_action->mo_handler->ms_request-s_front-origin   = `https://flp`.
    mo_action->mo_handler->ms_request-s_front-pathname = `/ui2/flp/FioriLaunchpad.html`.
    mo_action->mo_handler->ms_request-s_front-search   = ``.
    mo_action->mo_handler->ms_request-s_front-hash     = `#Z2UI5App-display?p=1&/old/route`.
    mo_action->mo_app->ms_draft-id = `DRAFT2`.

    cl_abap_unit_assert=>assert_equals(
        exp = `https://flp/ui2/flp/FioriLaunchpad.html#Z2UI5App-display?p=1&/z2ui5-xapp-state=DRAFT2`
        act = li_client->app_state_get_href( ) ).

    " a bare intent hash (opened from the tile, no app part yet) is ALL
    " shell and must survive - dropping it would compose FLP-URL#/state,
    " which the launchpad cannot route back into this app
    mo_action->mo_handler->ms_request-s_front-hash = `#Z2UI5App-display`.
    mo_action->mo_app->ms_draft-id = `DRAFT3`.

    cl_abap_unit_assert=>assert_equals(
        exp = `https://flp/ui2/flp/FioriLaunchpad.html#Z2UI5App-display&/z2ui5-xapp-state=DRAFT3`
        act = li_client->app_state_get_href( ) ).

  ENDMETHOD.

  METHOD test_follow_up_action.

    DATA li_client TYPE REF TO z2ui5_if_client.

    li_client ?= mo_client.
    li_client->follow_up_action( `sap.m.MessageToast.show('test')` ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_action->ms_next-s_action-t_custom ) ).

  ENDMETHOD.

  METHOD test_follow_up_action_ev.

    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp23 TYPE string_table.
    FIELD-SYMBOLS <temp25> LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp26 LIKE sy-tabix.
    FIELD-SYMBOLS <temp27> LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp28 LIKE sy-tabix.
    li_client ?= mo_client.


    CLEAR temp23.
    INSERT `My Title` INTO TABLE temp23.
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-set_title
                                 t_arg = temp23 ).
    li_client->follow_up_action( z2ui5_if_client=>cs_event-location_reload ).

    " framework events travel as pure data - a JSON array serialized in ABAP
    " (get_event_client_ajson), not as an executable eF( ) JS snippet
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( mo_action->ms_next-s_action-t_custom ) ).


    temp26 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 1 ASSIGNING <temp25>.
    sy-tabix = temp26.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `["SET_TITLE","My Title"]`
                                        act = <temp25>-o_json->stringify( ) ).


    temp28 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 2 ASSIGNING <temp27>.
    sy-tabix = temp28.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `["LOCATION_RELOAD"]`
                                        act = <temp27>-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_follow_up_action_nav.

    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp29 TYPE string_table.
    DATA temp31 TYPE string_table.
    FIELD-SYMBOLS <temp33> LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp34 LIKE sy-tabix.
    FIELD-SYMBOLS <temp35> LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp36 LIKE sy-tabix.
    li_client ?= mo_client.

    " a *_nav_container_to event is rerouted to the generic CONTROL_BY_ID call
    " (method `to`, slot as the view) instead of emitting a dedicated event

    CLEAR temp29.
    INSERT `myContainer` INTO TABLE temp29.
    INSERT `myPage` INTO TABLE temp29.
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-nav_container_to
                                 t_arg = temp29 ).

    CLEAR temp31.
    INSERT `popContainer` INTO TABLE temp31.
    INSERT `popPage` INTO TABLE temp31.
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-popup_nav_container_to
                                 t_arg = temp31 ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( mo_action->ms_next-s_action-t_custom ) ).


    temp34 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 1 ASSIGNING <temp33>.
    sy-tabix = temp34.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_BY_ID","myContainer","MAIN","to","myPage"]`
        act = <temp33>-o_json->stringify( ) ).


    temp36 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 2 ASSIGNING <temp35>.
    sy-tabix = temp36.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_BY_ID","popContainer","POPUP","to","popPage"]`
        act = <temp35>-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_follow_up_action_ctrl.

    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp37 TYPE string_table.
    DATA temp39 TYPE string_table.
    DATA temp41 TYPE string_table.
    FIELD-SYMBOLS <temp43> LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp44 LIKE sy-tabix.
    FIELD-SYMBOLS <temp45> LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp46 LIKE sy-tabix.
    FIELD-SYMBOLS <temp47> LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp48 LIKE sy-tabix.
    li_client ?= mo_client.

    " the whitelisted control calls are plain follow-up events - t_arg is
    " positional: control_global = object, method, params; control_by_id =
    " id, method, params (the view is the separate view parameter, default
    " cs_view-main -> empty slot; a concrete view fills the slot)

    CLEAR temp37.
    INSERT `MESSAGE_TOAST` INTO TABLE temp37.
    INSERT `show` INTO TABLE temp37.
    INSERT `Hello` INTO TABLE temp37.
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-control_global
                                 t_arg = temp37 ).

    CLEAR temp39.
    INSERT `demoPanel` INTO TABLE temp39.
    INSERT `setExpanded` INTO TABLE temp39.
    INSERT `X` INTO TABLE temp39.
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-control_by_id
                                 t_arg = temp39 ).

    CLEAR temp41.
    INSERT `demoPanel` INTO TABLE temp41.
    INSERT `setExpanded` INTO TABLE temp41.
    INSERT `X` INTO TABLE temp41.
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-control_by_id
                                 view  = z2ui5_if_client=>cs_view-popover
                                 t_arg = temp41 ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( mo_action->ms_next-s_action-t_custom ) ).
    " the eF( ) form KEEPS its CONTROL_GLOBAL prefix - only the framework's
    " own build_global_call drops the dispatch constant from the wire


    temp44 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 1 ASSIGNING <temp43>.
    sy-tabix = temp44.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_GLOBAL","MESSAGE_TOAST","show","Hello"]`
        act = <temp43>-o_json->stringify( ) ).


    temp46 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 2 ASSIGNING <temp45>.
    sy-tabix = temp46.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_BY_ID","demoPanel","","setExpanded","X"]`
        act = <temp45>-o_json->stringify( ) ).


    temp48 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 3 ASSIGNING <temp47>.
    sy-tabix = temp48.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_BY_ID","demoPanel","POPOVER","setExpanded","X"]`
        act = <temp47>-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_ctrl_global_opt.

    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp49 TYPE string_table.
    DATA temp51 TYPE string_table.
    FIELD-SYMBOLS <temp53> LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp54 LIKE sy-tabix.
    FIELD-SYMBOLS <temp55> LIKE LINE OF mo_action->ms_next-s_action-t_custom.
    DATA temp56 LIKE sy-tabix.
    li_client ?= mo_client.

    " The UI5 options of a toast and of a message box are set on the CONTROL:
    " a t_arg that starts with a brace is embedded as REAL JSON, and the
    " frontend takes an object in last position as the option object of the
    " call ( ControlCall.js, evControlCall ). That is the path the pure
    " pass-through parameters of message_toast_display( ) /
    " message_box_display( ) took when they left those signatures in 2026-09 -
    " so nothing an app could express before is out of reach.

    CLEAR temp49.
    INSERT `MESSAGE_TOAST` INTO TABLE temp49.
    INSERT `show` INTO TABLE temp49.
    INSERT `Saved` INTO TABLE temp49.
    INSERT `{"my":"center center","width":"20em"}` INTO TABLE temp49.
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-control_global
                                 t_arg = temp49 ).

    CLEAR temp51.
    INSERT `MESSAGE_BOX` INTO TABLE temp51.
    INSERT `error` INTO TABLE temp51.
    INSERT `Not saved.` INTO TABLE temp51.
    INSERT `{"contentWidth":"30rem","icon":"WARNING"}` INTO TABLE temp51.
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-control_global
                                 t_arg = temp51 ).

    " the braces are gone from the wire - the option object is a JSON object,
    " not a string that happens to look like one


    temp54 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 1 ASSIGNING <temp53>.
    sy-tabix = temp54.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_GLOBAL","MESSAGE_TOAST","show","Saved",{"my":"center center","width":"20em"}]`
        act = <temp53>-o_json->stringify( ) ).


    temp56 = sy-tabix.
    READ TABLE mo_action->ms_next-s_action-t_custom INDEX 2 ASSIGNING <temp55>.
    sy-tabix = temp56.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_GLOBAL","MESSAGE_BOX","error","Not saved.",{"contentWidth":"30rem","icon":"WARNING"}]`
        act = <temp55>-o_json->stringify( ) ).

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
    DATA li_client TYPE REF TO z2ui5_if_client.

    mo_action->ms_actual-event = `BUTTON_PRESS`.

    li_client ?= mo_client.

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = li_client->check_on_event( `BUTTON_PRESS` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = li_client->check_on_event( `OTHER_EVENT` ) ).

  ENDMETHOD.

  METHOD test_check_on_event_empty.
    DATA li_client TYPE REF TO z2ui5_if_client.

    mo_action->ms_actual-event = ``.

    li_client ?= mo_client.

    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = li_client->check_on_event( ) ).

  ENDMETHOD.

  METHOD test_check_on_navigated.
    DATA li_client TYPE REF TO z2ui5_if_client.

    mo_action->ms_actual-check_on_navigated = abap_true.

    li_client ?= mo_client.

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = li_client->check_on_navigated( ) ).

  ENDMETHOD.

  METHOD test_nav_app_call.

    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA lv_id TYPE string.
    DATA temp57 TYPE REF TO ltcl_test_app.

    li_client ?= mo_client.


    CREATE OBJECT temp57 TYPE ltcl_test_app.
    lv_id = li_client->nav_app_call( temp57 ).

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
    cl_abap_unit_assert=>assert_initial( mo_action->ms_next-s_action-t_custom ).

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

    DATA li_client TYPE REF TO z2ui5_if_client.

    li_client ?= mo_client.

    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = li_client->check_app_prev_stack( ) ).

    mo_action->mo_app->ms_draft-id_prev_app_stack = `PREV_ID`.

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = li_client->check_app_prev_stack( ) ).

  ENDMETHOD.

  METHOD test_set_push_state.

    DATA li_client TYPE REF TO z2ui5_if_client.

    li_client ?= mo_client.
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
    DATA temp58 TYPE string_table.

    li_client ?= mo_client.


    CLEAR temp58.
    INSERT `${AUTHOR}` INTO TABLE temp58.
    cl_abap_unit_assert=>assert_equals(
        exp = li_client->_event( val   = `PRESSED`
                                 t_arg = temp58 )
        act = li_client->_event( val = `PRESSED` arg = `${AUTHOR}` ) ).

  ENDMETHOD.


  METHOD test_event_arg_appends.

    " both parameters supplied: arg lands BEHIND the t_arg rows. Documented
    " composition rather than a guess between two readings - and asserted so
    " it stays that and does not silently become "arg wins"
    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp60 TYPE string_table.
    DATA temp1 TYPE string_table.

    li_client ?= mo_client.


    CLEAR temp60.
    INSERT `first` INTO TABLE temp60.
    INSERT `second` INTO TABLE temp60.

    CLEAR temp1.
    INSERT `first` INTO TABLE temp1.
    cl_abap_unit_assert=>assert_equals(
        exp = li_client->_event( val   = `PRESSED`
                                 t_arg = temp60 )
        act = li_client->_event( val   = `PRESSED`
                                 t_arg = temp1
                                 arg   = `second` ) ).

  ENDMETHOD.


  METHOD test_event_arg_empty.

    " read with IS SUPPLIED, not IS NOT INITIAL: an argument passed as empty
    " on purpose is a filled slot. Were it dropped, every following position
    " would shift - the defect class this wire has produced before
    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp62 TYPE string_table.

    li_client ?= mo_client.


    CLEAR temp62.
    INSERT `` INTO TABLE temp62.
    cl_abap_unit_assert=>assert_equals(
        exp = li_client->_event( val   = `PRESSED`
                                 t_arg = temp62 )
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


  METHOD test_get_comp_params_memo.

    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA ls_get_1 TYPE z2ui5_if_client=>ty_s_get.
    DATA temp64 TYPE z2ui5_if_client=>ty_s_name_value-v.
    DATA temp65 TYPE z2ui5_if_client=>ty_s_name_value.
    DATA temp66 TYPE z2ui5_if_client=>ty_s_name_value-v.
    DATA temp67 TYPE z2ui5_if_client=>ty_s_name_value.
    DATA ls_get_2 TYPE z2ui5_if_client=>ty_s_get.
    li_client ?= mo_client.

    " FLP component data: one array per parameter name, first entry counts
    mo_action->mo_handler->ms_request-s_front-o_comp_data =
        z2ui5_cl_ajson=>parse( `{"startupParameters":{"foo":["bar"],"qty":["7","8"]}}` ).


    ls_get_1 = li_client->get( ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( ls_get_1-t_comp_params ) ).

    CLEAR temp64.

    READ TABLE ls_get_1-t_comp_params INTO temp65 WITH KEY n = `foo`.
    IF sy-subrc = 0.
      temp64 = temp65-v.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `bar`
        act = temp64 ).

    CLEAR temp66.

    READ TABLE ls_get_1-t_comp_params INTO temp67 WITH KEY n = `qty`.
    IF sy-subrc = 0.
      temp66 = temp67-v.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `7`
        act = temp66 ).

    " the first call filled the memo (t_comp_params is immutable for the
    " whole roundtrip, so the node-table walk must not run again) ...
    cl_abap_unit_assert=>assert_true( mo_client->mv_comp_params_set ).
    cl_abap_unit_assert=>assert_equals( exp = ls_get_1-t_comp_params
                                        act = mo_client->mt_comp_params ).

    " ... and the second call answers from it WITHOUT re-walking: with the
    " source dropped, a re-walk would come back empty - the memo must not
    CLEAR mo_action->mo_handler->ms_request-s_front-o_comp_data.

    ls_get_2 = li_client->get( ).

    cl_abap_unit_assert=>assert_equals( exp = ls_get_1-t_comp_params
                                        act = ls_get_2-t_comp_params ).

  ENDMETHOD.


  METHOD test_get_nav_flags_live.

    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA ls_get_1 TYPE z2ui5_if_client=>ty_s_get.
    DATA ls_get_2 TYPE z2ui5_if_client=>ty_s_get.
    li_client ?= mo_client.

    " the memoized slice must not freeze the _s_nav flags of the same
    " structure: they answer for actions queued since the previous get( )

    ls_get_1 = li_client->get( ).
    cl_abap_unit_assert=>assert_false( ls_get_1-_s_nav-check_call ).

    CREATE OBJECT mo_action->ms_next-o_app_call TYPE ltcl_test_app.

    ls_get_2 = li_client->get( ).

    cl_abap_unit_assert=>assert_true( ls_get_2-_s_nav-check_call ).

  ENDMETHOD.


  METHOD test_get_event_arg.
    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp68 TYPE string_table.
    CLEAR temp68.
    INSERT `arg1` INTO TABLE temp68.
    INSERT `arg2` INTO TABLE temp68.
    mo_action->ms_actual-t_event_arg = temp68.

    li_client ?= mo_client.

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
    DATA temp70 TYPE string_table.
    DATA temp3 TYPE REF TO z2ui5_if_ajson_filter.
    DATA li_filter LIKE temp3.
    DATA temp72 TYPE z2ui5_if_ajson_types=>ty_node.
    DATA temp73 TYPE z2ui5_if_ajson_types=>ty_node.
    DATA temp74 TYPE z2ui5_if_ajson_types=>ty_node.
    DATA temp75 TYPE z2ui5_if_ajson_types=>ty_node.
    DATA temp76 TYPE z2ui5_if_ajson_types=>ty_node.
    CLEAR temp70.
    INSERT `MIN` INTO TABLE temp70.
    INSERT `/ROWS/MAX` INTO TABLE temp70.

    CREATE OBJECT temp3 TYPE lcl_initial_paths_filter EXPORTING IT_PATHS = temp70.

    li_filter = temp3.

    " listed + initial -> dropped

    CLEAR temp72.
    temp72-name = `MIN`.
    temp72-type = `num`.
    temp72-value = `0`.
    cl_abap_unit_assert=>assert_equals(
        exp = abap_false
        act = li_filter->keep_node( temp72 ) ).
    " listed by its last path segment as well

    CLEAR temp73.
    temp73-name = `MAX`.
    temp73-type = `str`.
    temp73-value = ``.
    cl_abap_unit_assert=>assert_equals(
        exp = abap_false
        act = li_filter->keep_node( temp73 ) ).
    " listed but filled -> kept

    CLEAR temp74.
    temp74-name = `MIN`.
    temp74-type = `num`.
    temp74-value = `5`.
    cl_abap_unit_assert=>assert_equals(
        exp = abap_true
        act = li_filter->keep_node( temp74 ) ).
    " NOT listed and initial -> kept: this is the boolean that must send false

    CLEAR temp75.
    temp75-name = `ENABLED`.
    temp75-type = `bool`.
    temp75-value = `false`.
    cl_abap_unit_assert=>assert_equals(
        exp = abap_true
        act = li_filter->keep_node( temp75 ) ).
    " an object/array visit always passes, or the row around a dropped field would go

    CLEAR temp76.
    temp76-name = `MIN`.
    temp76-type = `object`.
    cl_abap_unit_assert=>assert_equals(
        exp = abap_true
        act = li_filter->keep_node( is_node  = temp76
                                    iv_visit = z2ui5_if_ajson_filter=>visit_type-open ) ).

  ENDMETHOD.


  METHOD test_omit_initial_decimals.

    " the "price" column the parameter is documented for: an initial
    " p DECIMALS serializes as 0.00 and was kept by a compare against `0`
    TYPES:
      BEGIN OF ty_s_row,
        name   TYPE string,
        price  TYPE p LENGTH 9 DECIMALS 2,
        weight TYPE f,
        count  TYPE i,
      END OF ty_s_row.

    DATA temp77 TYPE ty_s_row.
    DATA ls_row LIKE temp77.
    DATA temp78 TYPE REF TO z2ui5_if_ajson.
    DATA lo_ajson LIKE temp78.
    DATA temp79 TYPE REF TO lcl_empty_filter_keep_rows.
    DATA temp80 TYPE REF TO lcl_empty_filter_keep_rows.
    CLEAR temp77.
    temp77-name = `A`.

    ls_row = temp77.


    temp78 ?= z2ui5_cl_ajson=>create_empty( ).

    lo_ajson = temp78.
    lo_ajson->set( iv_ignore_empty = abap_false
                   iv_path         = `/row`
                   iv_val          = ls_row ).


    CREATE OBJECT temp79 TYPE lcl_empty_filter_keep_rows.
    cl_abap_unit_assert=>assert_equals(
        exp = `{"row":{"name":"A"}}`
        act = lo_ajson->filter( temp79 )->stringify( ) ).

    " a non-zero value in the same spelling survives
    ls_row-price = '0.01'.
    lo_ajson = z2ui5_cl_ajson=>create_empty( ).
    lo_ajson->set( iv_ignore_empty = abap_false
                   iv_path         = `/row`
                   iv_val          = ls_row ).


    CREATE OBJECT temp80 TYPE lcl_empty_filter_keep_rows.
    cl_abap_unit_assert=>assert_equals(
        exp = `{"row":{"name":"A","price":0.01}}`
        act = lo_ajson->filter( temp80 )->stringify( ) ).

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
    DATA temp81 TYPE ty_s_row.
    DATA temp82 TYPE ty_s_row.
    DATA temp83 TYPE REF TO z2ui5_if_ajson.
    DATA lo_ajson LIKE temp83.
    DATA lo_act TYPE REF TO z2ui5_if_ajson.
    DATA temp4 TYPE REF TO lcl_empty_filter_keep_rows.
    DATA temp84 TYPE ty_s_row.
    DATA ls_nest LIKE temp84.
    DATA temp85 TYPE REF TO lcl_empty_filter_keep_rows.
    CLEAR temp81.
    temp81-title = `first`.
    temp81-count = 1.
    APPEND temp81 TO lt_tab.
    APPEND INITIAL LINE TO lt_tab.

    CLEAR temp82.
    temp82-title = `third`.
    temp82-count = 3.
    APPEND temp82 TO lt_tab.


    temp83 ?= z2ui5_cl_ajson=>create_empty( ).

    lo_ajson = temp83.
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

    CLEAR temp84.

    ls_nest = temp84.
    lo_ajson = z2ui5_cl_ajson=>create_empty( ).
    lo_ajson->set( iv_ignore_empty = abap_false
                   iv_path         = `/sub`
                   iv_val          = ls_nest ).

    CREATE OBJECT temp85 TYPE lcl_empty_filter_keep_rows.
    cl_abap_unit_assert=>assert_equals(
        exp = ``
        act = lo_ajson->filter( temp85 )->stringify( ) ).

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
    DATA temp86 TYPE string_table.
    DATA temp88 TYPE REF TO lcl_and_filter.
    DATA temp89 TYPE REF TO ltcl_bad_filter.

    CREATE OBJECT li_omit TYPE lcl_empty_filter_keep_rows.
    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_ui5_util_context=>rtti_check_serializable( li_omit ) ).


    CLEAR temp86.
    INSERT `MIN` INTO TABLE temp86.
    CREATE OBJECT li_paths TYPE lcl_initial_paths_filter EXPORTING IT_PATHS = temp86.
    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_ui5_util_context=>rtti_check_serializable( li_paths ) ).


    CREATE OBJECT temp88 TYPE lcl_and_filter EXPORTING ii_first = li_paths ii_second = li_omit.
    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_ui5_util_context=>rtti_check_serializable(
            temp88 ) ).

    " and the probe class is really refused by the same check - otherwise
    " test_bind_filter_not_serial proves nothing

    CREATE OBJECT temp89 TYPE ltcl_bad_filter.
    cl_abap_unit_assert=>assert_false(
        z2ui5_cl_ui5_util_context=>rtti_check_serializable( temp89 ) ).

  ENDMETHOD.


  METHOD test_bind_filter_not_serial.

    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp90 TYPE REF TO ltcl_bad_filter.
        DATA temp1 TYPE xsdboolean.

    li_client ?= mo_client.

    TRY.

        CREATE OBJECT temp90 TYPE ltcl_bad_filter.
        li_client->_bind( val           = mo_test_app->mv_name
                          custom_filter = temp90 ).
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
    FIELD-SYMBOLS <temp91> TYPE z2ui5_if_ui5_types=>ty_s_attri.

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


    READ TABLE lo_cont_db->mt_attri->* WITH KEY name = `MV_NAME` ASSIGNING <temp91>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.
GET REFERENCE OF <temp91> INTO lr_attri.
    cl_abap_unit_assert=>assert_bound( lr_attri ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lr_attri->bind ).

  ENDMETHOD.


  METHOD test_bind_tab_cell.

    " The CELL form of _bind, exactly as an app writes it: the bound value
    " is the row COMPONENT, the table and the row number travel beside it.
    " ABAP counts rows from 1, the client path from 0.
    "
    " This is the one place the app-facing form is proved, and it is the test
    " that decides whether a downport keeps the row REFERENCE this binding
    " matches on. abaplint lowered `tab[ n ]-comp` to
    " `READ TABLE ... INTO <wa>` - a copy - until 2.120.51
    " (abaplint/abaplint#4276), and this repository patched that lowering back
    " to ASSIGNING until the pin moved. Nothing is patched now, so a failure
    " here on the transpiled suite means the downport regressed upstream, not
    " that the binding changed. The cell logic itself is covered everywhere by
    " ltcl_02_cell in z2ui5_cl_ui5_srv_bind
    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA temp92 TYPE ltcl_test_app=>ty_s_emp.
    DATA temp93 TYPE ltcl_test_app=>ty_s_emp.
    FIELD-SYMBOLS <temp94> LIKE LINE OF mo_test_app->mt_emp.
    DATA temp95 LIKE sy-tabix.
    FIELD-SYMBOLS <temp96> LIKE LINE OF mo_test_app->mt_emp.
    DATA temp97 LIKE sy-tabix.

    li_client ?= mo_client.

    CLEAR temp92.
    temp92-name = `Michael Adams`.
    temp92-job = `Scrum Master`.
    INSERT temp92 INTO TABLE mo_test_app->mt_emp.

    CLEAR temp93.
    temp93-name = `John Miller`.
    temp93-job = `Product Owner`.
    INSERT temp93 INTO TABLE mo_test_app->mt_emp.



    temp95 = sy-tabix.
    READ TABLE mo_test_app->mt_emp INDEX 1 ASSIGNING <temp94>.
    sy-tabix = temp95.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `{/MT_EMP/0/NAME}`
        act = li_client->_bind( val       = <temp94>-name
                                tab       = mo_test_app->mt_emp
                                tab_index = 1 ) ).



    temp97 = sy-tabix.
    READ TABLE mo_test_app->mt_emp INDEX 2 ASSIGNING <temp96>.
    sy-tabix = temp97.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        exp = `{/MT_EMP/1/JOB}`
        act = li_client->_bind( val       = <temp96>-job
                                tab       = mo_test_app->mt_emp
                                tab_index = 2 ) ).

  ENDMETHOD.


  METHOD test_bind_tab_cell_assign.

    " The same cell over an ASSIGNED row - the spelling the doc block on
    " _bind recommends, and the only one that survives a downport: the
    " whole-row table expression keeps its reference through it
    " (READ TABLE ... ASSIGNING), the component-level one does not. So this
    " test runs on every target, including this pipeline
    DATA li_client TYPE REF TO z2ui5_if_client.
    FIELD-SYMBOLS <emp> TYPE ltcl_test_app=>ty_s_emp.
    DATA temp98 TYPE ltcl_test_app=>ty_s_emp.
    DATA temp99 TYPE ltcl_test_app=>ty_s_emp.

    li_client ?= mo_client.

    CLEAR temp98.
    temp98-name = `Michael Adams`.
    temp98-job = `Scrum Master`.
    INSERT temp98 INTO TABLE mo_test_app->mt_emp.

    CLEAR temp99.
    temp99-name = `John Miller`.
    temp99-job = `Product Owner`.
    INSERT temp99 INTO TABLE mo_test_app->mt_emp.

    READ TABLE mo_test_app->mt_emp INDEX 1 ASSIGNING <emp>.
    cl_abap_unit_assert=>assert_equals(
        exp = `{/MT_EMP/0/NAME}`
        act = li_client->_bind( val       = <emp>-name
                                tab       = mo_test_app->mt_emp
                                tab_index = 1 ) ).

    READ TABLE mo_test_app->mt_emp INDEX 2 ASSIGNING <emp>.
    cl_abap_unit_assert=>assert_equals(
        exp = `{/MT_EMP/1/JOB}`
        act = li_client->_bind( val       = <emp>-job
                                tab       = mo_test_app->mt_emp
                                tab_index = 2 ) ).

  ENDMETHOD.


  METHOD test_set_app_state_active.

    DATA li_client TYPE REF TO z2ui5_if_client.

    li_client ?= mo_client.
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
    " a bound SCALAR of a numeric type - the shape whose refusal used to
    " fail the whole roundtrip instead of landing in the trace
    DATA mv_discount TYPE p LENGTH 9 DECIMALS 2.

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
    client->_bind( mv_discount ).

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
    METHODS test_refused_scalar_reported FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test_model_skipped IMPLEMENTATION.

  METHOD setup.

    DATA ls_product TYPE ltcl_app_price_editor=>ty_s_product.

    DATA lo_http TYPE REF TO z2ui5_cl_ui5_handler.
    DATA temp100 TYPE ltcl_app_price_editor=>ty_s_pos.
    CREATE OBJECT lo_http TYPE z2ui5_cl_ui5_handler EXPORTING val = ``.
    CREATE OBJECT mo_action EXPORTING val = lo_http.
    CREATE OBJECT mo_app.

    CLEAR ls_product.
    ls_product-name  = `Notebook`.
    ls_product-price = '1249.00'.

    CLEAR temp100.
    temp100-qty = 1.
    APPEND temp100 TO ls_product-t_pos.
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
    DATA lo_client TYPE REF TO z2ui5_cl_ui5_client.

    CLEAR mo_action->ms_actual.

    IF model IS NOT INITIAL.
      mo_action->ms_actual-t_model_skipped = mo_action->mo_app->model_json_parse( z2ui5_cl_ajson=>parse( model ) ).
    ENDIF.
    mo_action->ms_actual-event = event.


    CREATE OBJECT lo_client TYPE z2ui5_cl_ui5_client EXPORTING action = mo_action.
    mo_app->z2ui5_if_app~main( lo_client ).

  ENDMETHOD.

  METHOD test_accepted_price_silent.
    DATA temp101 TYPE decfloat34.
    DATA temp5 TYPE decfloat34.
    FIELD-SYMBOLS <temp1> LIKE LINE OF mo_app->mt_product.
    DATA temp2 LIKE sy-tabix.

    " the accepted case first - it is what proves the wire is alive, so the
    " refusal below is a conversion failure and not a dead binding
    roundtrip( model = `{"MT_PRODUCT":{"__delta":{"1":{"PRICE":"1250.00"}}}}`
               event = `SAVE` ).


    temp101 = '1250.00'.



    temp2 = sy-tabix.
    READ TABLE mo_app->mt_product INDEX 2 ASSIGNING <temp1>.
    sy-tabix = temp2.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp5 = <temp1>-price.
    cl_abap_unit_assert=>assert_equals( exp = temp101
                                        act = temp5 ).
    cl_abap_unit_assert=>assert_initial( mo_app->mv_message ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = mo_app->mv_saved ).

  ENDMETHOD.

  METHOD test_refused_scalar_reported.
    DATA lt_skipped LIKE mo_action->ms_actual-t_model_skipped.
    FIELD-SYMBOLS <temp102> LIKE LINE OF lt_skipped.
    DATA temp103 LIKE sy-tabix.
    FIELD-SYMBOLS <temp104> LIKE LINE OF lt_skipped.
    DATA temp105 LIKE sy-tabix.
    FIELD-SYMBOLS <temp106> LIKE LINE OF lt_skipped.
    DATA temp107 LIKE sy-tabix.
    DATA temp108 TYPE decfloat34.
    DATA temp6 TYPE decfloat34.

    " `1,250.00` typed into an Input bound to a packed SCALAR: the same
    " refusal a table cell gets - traced with the attribute name, row 0 and
    " the raw value, the old value kept, the roundtrip alive. It used to
    " raise JSON_PARSING_ERROR and end in the fatal overlay
    mo_app->mv_discount = '5.00'.
    roundtrip( model = `{"MV_DISCOUNT":"1,250.00"}`
               event = `SAVE` ).


    lt_skipped = mo_action->ms_actual-t_model_skipped.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_skipped ) ).


    temp103 = sy-tabix.
    READ TABLE lt_skipped INDEX 1 ASSIGNING <temp102>.
    sy-tabix = temp103.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MV_DISCOUNT`
                                        act = <temp102>-name ).


    temp105 = sy-tabix.
    READ TABLE lt_skipped INDEX 1 ASSIGNING <temp104>.
    sy-tabix = temp105.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = <temp104>-row ).


    temp107 = sy-tabix.
    READ TABLE lt_skipped INDEX 1 ASSIGNING <temp106>.
    sy-tabix = temp107.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `1,250.00`
                                        act = <temp106>-value ).

    temp108 = '5.00'.

    temp6 = mo_app->mv_discount.
    cl_abap_unit_assert=>assert_equals( exp = temp108
                                        act = temp6 ).

  ENDMETHOD.

  METHOD test_refused_price_reported.
    DATA temp109 TYPE decfloat34.
    DATA temp7 TYPE decfloat34.
    FIELD-SYMBOLS <temp3> LIKE LINE OF mo_app->mt_product.
    DATA temp4 LIKE sy-tabix.

    " the grouped thousands separator a locale-formatted Input sends
    roundtrip( model = `{"MT_PRODUCT":{"__delta":{"1":{"PRICE":"1,250.00"}}}}`
               event = `SAVE` ).

    " the cell is still skipped and nothing raised - the old value stands

    temp109 = '299.00'.



    temp4 = sy-tabix.
    READ TABLE mo_app->mt_product INDEX 2 ASSIGNING <temp3>.
    sy-tabix = temp4.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp7 = <temp3>-price.
    cl_abap_unit_assert=>assert_equals( exp = temp109
                                        act = temp7 ).

    " ... and the app could say so, which is the whole point. Name, row and
    " field together were enough to reach the row and quote it back
    cl_abap_unit_assert=>assert_equals( exp = `Price of 'Monitor' was not accepted`
                                        act = mo_app->mv_message ).

  ENDMETHOD.

  METHOD test_save_no_longer_lies.
    DATA temp110 TYPE decfloat34.
    DATA temp8 TYPE decfloat34.
    FIELD-SYMBOLS <temp5> LIKE LINE OF mo_app->mt_product.
    DATA temp6 LIKE sy-tabix.
    DATA temp111 TYPE decfloat34.
    DATA temp9 TYPE decfloat34.
    FIELD-SYMBOLS <temp7> LIKE LINE OF mo_app->mt_product.
    DATA temp10 LIKE sy-tabix.

    " one bad cell, one good one, in the same delta and the same Save press
    roundtrip( model = `{"MT_PRODUCT":{"__delta":{"0":{"PRICE":"abc"},"1":{"PRICE":"350.00"}}}}`
               event = `SAVE` ).

    " the good cell landed - the skip did not take the delta down with it

    temp110 = '350.00'.



    temp6 = sy-tabix.
    READ TABLE mo_app->mt_product INDEX 2 ASSIGNING <temp5>.
    sy-tabix = temp6.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp8 = <temp5>-price.
    cl_abap_unit_assert=>assert_equals( exp = temp110
                                        act = temp8 ).

    temp111 = '1249.00'.



    temp10 = sy-tabix.
    READ TABLE mo_app->mt_product INDEX 1 ASSIGNING <temp7>.
    sy-tabix = temp10.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp9 = <temp7>-price.
    cl_abap_unit_assert=>assert_equals( exp = temp111
                                        act = temp9 ).

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
    FIELD-SYMBOLS <temp112> LIKE LINE OF mo_app->mt_product.
    DATA temp113 LIKE sy-tabix.
    FIELD-SYMBOLS <temp10> LIKE LINE OF <temp112>-t_pos.
    DATA temp11 LIKE sy-tabix.

    " a cell of the NESTED table. The trace names the path parent first, and
    " row is the index INSIDE t_pos - which MT_PRODUCT row owns that t_pos is
    " not in the entry, so an app cannot name the product
    roundtrip( model = `{"MT_PRODUCT":{"__delta":{"0":{"T_POS":{"__delta":{"0":{"QTY":"seven"}}}}}}}`
               event = `SAVE` ).



    temp113 = sy-tabix.
    READ TABLE mo_app->mt_product INDEX 1 ASSIGNING <temp112>.
    sy-tabix = temp113.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp11 = sy-tabix.
    READ TABLE <temp112>-t_pos INDEX 1 ASSIGNING <temp10>.
    sy-tabix = temp11.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = <temp10>-qty ).
    cl_abap_unit_assert=>assert_equals( exp = `Quantity in a position row was not accepted`
                                        act = mo_app->mv_message ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = mo_app->mv_saved ).

  ENDMETHOD.

  METHOD test_bind_path_is_not_name.
    FIELD-SYMBOLS <temp114> LIKE LINE OF mo_action->ms_actual-t_model_skipped.
    DATA temp115 LIKE sy-tabix.

    " the two spellings of the same table an app has to hold at once: _bind
    " hands the view a client PATH, the trace names the ABAP ATTRIBUTE, and
    " nothing public converts one into the other - so the app above had to
    " carry `MT_PRODUCT` as a literal
    cl_abap_unit_assert=>assert_equals( exp = `{/MT_PRODUCT}`
                                        act = mo_app->mv_bind_path ).

    roundtrip( model = `{"MT_PRODUCT":{"__delta":{"1":{"PRICE":"1,250.00"}}}}` ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_action->ms_actual-t_model_skipped ) ).


    temp115 = sy-tabix.
    READ TABLE mo_action->ms_actual-t_model_skipped INDEX 1 ASSIGNING <temp114>.
    sy-tabix = temp115.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MT_PRODUCT`
                                        act = <temp114>-name ).

  ENDMETHOD.

ENDCLASS.
