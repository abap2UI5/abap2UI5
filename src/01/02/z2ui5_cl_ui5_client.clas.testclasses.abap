CLASS ltcl_test_app DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mv_name TYPE string ##NEEDED.

    TYPES:
      BEGIN OF ty_s_emp,
        name TYPE string,
        job  TYPE string,
      END OF ty_s_emp.
    DATA mt_emp TYPE STANDARD TABLE OF ty_s_emp WITH EMPTY KEY ##NEEDED.
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
    METHODS test_hash_attach_changed  FOR TESTING RAISING cx_static_check.
    METHODS test_hash_replace         FOR TESTING RAISING cx_static_check.
    METHODS test_hash_set_alias       FOR TESTING RAISING cx_static_check.
    METHODS test_app_state_get_href   FOR TESTING RAISING cx_static_check.
    METHODS test_app_state_href_flp   FOR TESTING RAISING cx_static_check.
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

    LOOP AT mo_action->ms_next-t_action_front INTO DATA(ls_action).
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
    lo_http = NEW #( val = `` ).
    mo_action = NEW #( val = lo_http ).
    lo_test_app = NEW #( ).
    mo_test_app = lo_test_app.
    mo_action->mo_app->mo_app = lo_test_app.
    mo_action->mo_app->mv_check_initialized = abap_false.
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
    temp14 ?= mo_client.

    li_client = temp14.
    li_client->message_box_display( `Hello World` ).

    cl_abap_unit_assert=>assert_equals(
        exp = `["MESSAGE_BOX","show","Hello World",{"title":"Information"}]`
        act = mo_action->ms_next-s_action-t_custom[ 1 ]-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_message_box_type.

    DATA temp15 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp15.
    temp15 ?= mo_client.

    li_client = temp15.
    li_client->message_box_display( text = `Error occurred`
                                    type = `error` ).

    cl_abap_unit_assert=>assert_equals(
        exp = `["MESSAGE_BOX","error","Error occurred"]`
        act = mo_action->ms_next-s_action-t_custom[ 1 ]-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_message_box_dependent.

    DATA temp15b TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp15b.
    temp15b ?= mo_client.

    li_client = temp15b.
    li_client->message_box_display( text         = `The quantity exceeds the plan.`
                                    type         = `confirm`
                                    dependenton  = `myPage`
                                    contentwidth = `20rem` ).

    cl_abap_unit_assert=>assert_equals(
        exp = `["MESSAGE_BOX","confirm","The quantity exceeds the plan.",` &&
              `{"contentWidth":"20rem","dependentOn":"myPage"}]`
        act = mo_action->ms_next-s_action-t_custom[ 1 ]-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_message_toast.

    DATA temp16 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp16.
    temp16 ?= mo_client.

    li_client = temp16.
    li_client->message_toast_display( `Saved` ).

    cl_abap_unit_assert=>assert_equals(
        exp = `["MESSAGE_TOAST","show","Saved"]`
        act = mo_action->ms_next-s_action-t_custom[ 1 ]-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_set_nav_routing.

    DATA li_client TYPE REF TO z2ui5_if_client.
    li_client ?= mo_client.

    " SET_NAV_ROUTING configures the app rather than calling the frontend: it
    " is remembered on the app ( so a later response of this app, and an app
    " that inherits from it, carry it again ) and queues no action of its own
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-set_nav_routing
                                 t_arg = VALUE #( ( z2ui5_if_client=>cs_nav_mode-fresh ) ) ).

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
    li_client ?= mo_client.

    " registration travels as a nav option, no custom action queued
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-hash_attach_changed
                                 t_arg = VALUE #( ( `HASH_CHANGED` ) ) ).

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
    li_client ?= mo_client.

    " the typed method and the constant reach the same nav option
    li_client->hash_replace( `/detail/0/OneColumn` ).

    cl_abap_unit_assert=>assert_equals( exp = `/detail/0/OneColumn`
                                        act = mo_action->ms_next-s_nav-hash_replace ).

    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-hash_replace
                                 t_arg = VALUE #( ( `/other` ) ) ).

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
    li_client ?= mo_client.

    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-set_title
                                 t_arg = VALUE #( ( `My Title` ) ) ).
    li_client->follow_up_action( z2ui5_if_client=>cs_event-location_reload ).

    " framework events travel as pure data - a JSON array serialized in ABAP
    " (get_event_client_ajson), not as an executable eF( ) JS snippet
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( mo_action->ms_next-s_action-t_custom ) ).
    cl_abap_unit_assert=>assert_equals( exp = `["SET_TITLE","My Title"]`
                                        act = mo_action->ms_next-s_action-t_custom[ 1 ]-o_json->stringify( ) ).
    cl_abap_unit_assert=>assert_equals( exp = `["LOCATION_RELOAD"]`
                                        act = mo_action->ms_next-s_action-t_custom[ 2 ]-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_follow_up_action_nav.

    DATA li_client TYPE REF TO z2ui5_if_client.
    li_client ?= mo_client.

    " a *_nav_container_to event is rerouted to the generic CONTROL_BY_ID call
    " (method `to`, slot as the view) instead of emitting a dedicated event
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-nav_container_to
                                 t_arg = VALUE #( ( `myContainer` ) ( `myPage` ) ) ).
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-popup_nav_container_to
                                 t_arg = VALUE #( ( `popContainer` ) ( `popPage` ) ) ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( mo_action->ms_next-s_action-t_custom ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_BY_ID","myContainer","MAIN","to","myPage"]`
        act = mo_action->ms_next-s_action-t_custom[ 1 ]-o_json->stringify( ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_BY_ID","popContainer","POPUP","to","popPage"]`
        act = mo_action->ms_next-s_action-t_custom[ 2 ]-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_follow_up_action_ctrl.

    DATA li_client TYPE REF TO z2ui5_if_client.
    li_client ?= mo_client.

    " the whitelisted control calls are plain follow-up events - t_arg is
    " positional: control_global = object, method, params; control_by_id =
    " id, method, params (the view is the separate view parameter, default
    " cs_view-main -> empty slot; a concrete view fills the slot)
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-control_global
                                 t_arg = VALUE #( ( `MESSAGE_TOAST` ) ( `show` ) ( `Hello` ) ) ).
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-control_by_id
                                 t_arg = VALUE #( ( `demoPanel` ) ( `setExpanded` ) ( `X` ) ) ).
    li_client->follow_up_action( val   = z2ui5_if_client=>cs_event-control_by_id
                                 view  = z2ui5_if_client=>cs_view-popover
                                 t_arg = VALUE #( ( `demoPanel` ) ( `setExpanded` ) ( `X` ) ) ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( mo_action->ms_next-s_action-t_custom ) ).
    " the eF( ) form KEEPS its CONTROL_GLOBAL prefix - only the framework's
    " own build_global_call drops the dispatch constant from the wire
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_GLOBAL","MESSAGE_TOAST","show","Hello"]`
        act = mo_action->ms_next-s_action-t_custom[ 1 ]-o_json->stringify( ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_BY_ID","demoPanel","","setExpanded","X"]`
        act = mo_action->ms_next-s_action-t_custom[ 2 ]-o_json->stringify( ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_BY_ID","demoPanel","POPOVER","setExpanded","X"]`
        act = mo_action->ms_next-s_action-t_custom[ 3 ]-o_json->stringify( ) ).

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
                                        act = lines( mo_action->ms_next-s_action-t_custom ) ).

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

    li_client ?= mo_client.

    cl_abap_unit_assert=>assert_equals(
        exp = li_client->_event( val   = `PRESSED`
                                 t_arg = VALUE #( ( `${AUTHOR}` ) ) )
        act = li_client->_event( val = `PRESSED` arg = `${AUTHOR}` ) ).

  ENDMETHOD.


  METHOD test_event_arg_appends.

    " both parameters supplied: arg lands BEHIND the t_arg rows. Documented
    " composition rather than a guess between two readings - and asserted so
    " it stays that and does not silently become "arg wins"
    DATA li_client TYPE REF TO z2ui5_if_client.

    li_client ?= mo_client.

    cl_abap_unit_assert=>assert_equals(
        exp = li_client->_event( val   = `PRESSED`
                                 t_arg = VALUE #( ( `first` ) ( `second` ) ) )
        act = li_client->_event( val   = `PRESSED`
                                 t_arg = VALUE #( ( `first` ) )
                                 arg   = `second` ) ).

  ENDMETHOD.


  METHOD test_event_arg_empty.

    " read with IS SUPPLIED, not IS NOT INITIAL: an argument passed as empty
    " on purpose is a filled slot. Were it dropped, every following position
    " would shift - the defect class this wire has produced before
    DATA li_client TYPE REF TO z2ui5_if_client.

    li_client ?= mo_client.

    cl_abap_unit_assert=>assert_equals(
        exp = li_client->_event( val   = `PRESSED`
                                 t_arg = VALUE #( ( `` ) ) )
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
    DATA(li_filter) = CAST z2ui5_if_ajson_filter(
        NEW lcl_initial_paths_filter( VALUE #( ( `MIN` ) ( `/ROWS/MAX` ) ) ) ).

    " listed + initial -> dropped
    cl_abap_unit_assert=>assert_equals(
        exp = abap_false
        act = li_filter->keep_node( VALUE #( name = `MIN` type = `num` value = `0` ) ) ).
    " listed by its last path segment as well
    cl_abap_unit_assert=>assert_equals(
        exp = abap_false
        act = li_filter->keep_node( VALUE #( name = `MAX` type = `str` value = `` ) ) ).
    " listed but filled -> kept
    cl_abap_unit_assert=>assert_equals(
        exp = abap_true
        act = li_filter->keep_node( VALUE #( name = `MIN` type = `num` value = `5` ) ) ).
    " NOT listed and initial -> kept: this is the boolean that must send false
    cl_abap_unit_assert=>assert_equals(
        exp = abap_true
        act = li_filter->keep_node( VALUE #( name = `ENABLED` type = `bool` value = `false` ) ) ).
    " an object/array visit always passes, or the row around a dropped field would go
    cl_abap_unit_assert=>assert_equals(
        exp = abap_true
        act = li_filter->keep_node( is_node  = VALUE #( name = `MIN` type = `object` )
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
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.

    " built statement by statement: the downport rewrites a VALUE table
    " constructor into INSERTs from one shared work area without clearing it
    " between rows, so an inline `( )` row would arrive as a copy of its
    " predecessor instead of an all-initial line
    DATA lt_tab TYPE ty_t_row.
    APPEND VALUE #( title = `first`
                    count = 1 ) TO lt_tab.
    APPEND INITIAL LINE TO lt_tab.
    APPEND VALUE #( title = `third`
                    count = 3 ) TO lt_tab.

    DATA(lo_ajson) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ) ).
    lo_ajson->set( iv_ignore_empty = abap_false
                   iv_path         = `/`
                   iv_val          = lt_tab ).
    DATA(lo_act) = lo_ajson->filter( NEW lcl_empty_filter_keep_rows( ) ).

    " THREE entries - the all-initial middle row stays as an empty object,
    " its initial fields (and only those) are omitted
    cl_abap_unit_assert=>assert_equals(
        exp = `[{"count":1,"title":"first"},{},{"count":3,"title":"third"}]`
        act = lo_act->stringify( ) ).

    " the same shape as a struct MEMBER (not an array element) keeps the old
    " empty-filter behavior: an all-initial sub-structure vanishes entirely,
    " taking the then-empty root with it - stringify of the empty tree is ``
    DATA(ls_nest) = VALUE ty_s_row( ).
    lo_ajson = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ) ).
    lo_ajson->set( iv_ignore_empty = abap_false
                   iv_path         = `/sub`
                   iv_val          = ls_nest ).
    cl_abap_unit_assert=>assert_equals(
        exp = ``
        act = lo_ajson->filter( NEW lcl_empty_filter_keep_rows( ) )->stringify( ) ).

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

    li_omit = NEW lcl_empty_filter_keep_rows( ).
    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_ui5_util_context=>rtti_check_serializable( li_omit ) ).

    li_paths = NEW lcl_initial_paths_filter( VALUE #( ( `MIN` ) ) ).
    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_ui5_util_context=>rtti_check_serializable( li_paths ) ).

    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_ui5_util_context=>rtti_check_serializable(
            NEW lcl_and_filter( ii_first  = li_paths
                                ii_second = li_omit ) ) ).

    " and the probe class is really refused by the same check - otherwise
    " test_bind_filter_not_serial proves nothing
    cl_abap_unit_assert=>assert_false(
        z2ui5_cl_ui5_util_context=>rtti_check_serializable( NEW ltcl_bad_filter( ) ) ).

  ENDMETHOD.


  METHOD test_bind_filter_not_serial.

    DATA li_client TYPE REF TO z2ui5_if_client.
    DATA lo_app TYPE REF TO ltcl_test_app.
    DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.

    li_client ?= mo_client.
    lo_app ?= mo_action->mo_app->mo_app.

    TRY.
        li_client->_bind( val           = lo_app->mv_name
                          custom_filter = NEW ltcl_bad_filter( ) ).
        cl_abap_unit_assert=>fail(
            `a non-serializable custom_filter must be refused at bind time - serialized into the draft it fails only at db_save on a real system` ).
      CATCH z2ui5_cx_ui5_util_error INTO lx.
        cl_abap_unit_assert=>assert_true( xsdbool( lx->get_text( ) CS `serializable` ) ).
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
    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    lr_attri = REF #( lo_cont_db->mt_attri->*[ name = `MV_NAME` ] OPTIONAL ).
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

    li_client ?= mo_client.
    lo_app ?= mo_action->mo_app->mo_app.
    INSERT VALUE #( name = `Michael Adams`
                    job  = `Scrum Master` ) INTO TABLE lo_app->mt_emp.
    INSERT VALUE #( name = `John Miller`
                    job  = `Product Owner` ) INTO TABLE lo_app->mt_emp.

    cl_abap_unit_assert=>assert_equals(
        exp = `{/MT_EMP/0/NAME}`
        act = li_client->_bind( val       = lo_app->mt_emp[ 1 ]-name
                                tab       = lo_app->mt_emp
                                tab_index = 1 ) ).

    cl_abap_unit_assert=>assert_equals(
        exp = `{/MT_EMP/1/JOB}`
        act = li_client->_bind( val       = lo_app->mt_emp[ 2 ]-job
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

    li_client ?= mo_client.
    lo_app ?= mo_action->mo_app->mo_app.
    INSERT VALUE #( name = `Michael Adams`
                    job  = `Scrum Master` ) INTO TABLE lo_app->mt_emp.
    INSERT VALUE #( name = `John Miller`
                    job  = `Product Owner` ) INTO TABLE lo_app->mt_emp.

    ASSIGN lo_app->mt_emp[ 1 ] TO <emp>.
    cl_abap_unit_assert=>assert_equals(
        exp = `{/MT_EMP/0/NAME}`
        act = li_client->_bind( val       = <emp>-name
                                tab       = lo_app->mt_emp
                                tab_index = 1 ) ).

    ASSIGN lo_app->mt_emp[ 2 ] TO <emp>.
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
    TYPES ty_t_pos TYPE STANDARD TABLE OF ty_s_pos WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_product,
        name  TYPE string,
        price TYPE p LENGTH 9 DECIMALS 2,
        t_pos TYPE ty_t_pos,
      END OF ty_s_product.
    TYPES ty_t_product TYPE STANDARD TABLE OF ty_s_product WITH EMPTY KEY.

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

    DATA(ls_get) = client->get( ).

    " Read UNCONDITIONALLY, before any event branch. The delta travels with
    " whatever roundtrip follows the edit, and that is not necessarily the
    " Save press - an app that only looks inside its Save branch misses the
    " refusal on every other button.
    CLEAR mv_message.
    LOOP AT ls_get-t_model_skipped INTO DATA(ls_skip).

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
      mv_saved = xsdbool( mv_message IS INITIAL ).
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

    DATA(lo_http) = NEW z2ui5_cl_ui5_handler( val = `` ).
    mo_action = NEW #( val = lo_http ).
    mo_app = NEW #( ).

    CLEAR ls_product.
    ls_product-name  = `Notebook`.
    ls_product-price = '1249.00'.
    APPEND VALUE #( qty = 1 ) TO ls_product-t_pos.
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

    CLEAR mo_action->ms_actual.

    IF model IS NOT INITIAL.
      mo_action->ms_actual-t_model_skipped = mo_action->mo_app->model_json_parse(
                                                 CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse( model ) ) ).
    ENDIF.
    mo_action->ms_actual-event = event.

    DATA(lo_client) = NEW z2ui5_cl_ui5_client( action = mo_action ).
    mo_app->z2ui5_if_app~main( lo_client ).

  ENDMETHOD.

  METHOD test_accepted_price_silent.

    " the accepted case first - it is what proves the wire is alive, so the
    " refusal below is a conversion failure and not a dead binding
    roundtrip( model = `{"MT_PRODUCT":{"__delta":{"1":{"PRICE":"1250.00"}}}}`
               event = `SAVE` ).

    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( '1250.00' )
                                        act = CONV decfloat34( mo_app->mt_product[ 2 ]-price ) ).
    cl_abap_unit_assert=>assert_initial( mo_app->mv_message ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = mo_app->mv_saved ).

  ENDMETHOD.

  METHOD test_refused_price_reported.

    " the grouped thousands separator a locale-formatted Input sends
    roundtrip( model = `{"MT_PRODUCT":{"__delta":{"1":{"PRICE":"1,250.00"}}}}`
               event = `SAVE` ).

    " the cell is still skipped and nothing raised - the old value stands
    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( '299.00' )
                                        act = CONV decfloat34( mo_app->mt_product[ 2 ]-price ) ).

    " ... and the app could say so, which is the whole point. Name, row and
    " field together were enough to reach the row and quote it back
    cl_abap_unit_assert=>assert_equals( exp = `Price of 'Monitor' was not accepted`
                                        act = mo_app->mv_message ).

  ENDMETHOD.

  METHOD test_save_no_longer_lies.

    " one bad cell, one good one, in the same delta and the same Save press
    roundtrip( model = `{"MT_PRODUCT":{"__delta":{"0":{"PRICE":"abc"},"1":{"PRICE":"350.00"}}}}`
               event = `SAVE` ).

    " the good cell landed - the skip did not take the delta down with it
    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( '350.00' )
                                        act = CONV decfloat34( mo_app->mt_product[ 2 ]-price ) ).
    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( '1249.00' )
                                        act = CONV decfloat34( mo_app->mt_product[ 1 ]-price ) ).

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

    " a cell of the NESTED table. The trace names the path parent first, and
    " row is the index INSIDE t_pos - which MT_PRODUCT row owns that t_pos is
    " not in the entry, so an app cannot name the product
    roundtrip( model = `{"MT_PRODUCT":{"__delta":{"0":{"T_POS":{"__delta":{"0":{"QTY":"seven"}}}}}}}`
               event = `SAVE` ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = mo_app->mt_product[ 1 ]-t_pos[ 1 ]-qty ).
    cl_abap_unit_assert=>assert_equals( exp = `Quantity in a position row was not accepted`
                                        act = mo_app->mv_message ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = mo_app->mv_saved ).

  ENDMETHOD.

  METHOD test_bind_path_is_not_name.

    " the two spellings of the same table an app has to hold at once: _bind
    " hands the view a client PATH, the trace names the ABAP ATTRIBUTE, and
    " nothing public converts one into the other - so the app above had to
    " carry `MT_PRODUCT` as a literal
    cl_abap_unit_assert=>assert_equals( exp = `{/MT_PRODUCT}`
                                        act = mo_app->mv_bind_path ).

    roundtrip( model = `{"MT_PRODUCT":{"__delta":{"1":{"PRICE":"1,250.00"}}}}` ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_action->ms_actual-t_model_skipped ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MT_PRODUCT`
                                        act = mo_action->ms_actual-t_model_skipped[ 1 ]-name ).

  ENDMETHOD.

ENDCLASS.
