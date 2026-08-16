CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION LONG.

  PUBLIC SECTION.
    METHODS event             FOR TESTING.
    METHODS event_client     FOR TESTING.
    METHODS event_with_args   FOR TESTING.
    METHODS event_multi_args  FOR TESTING.
    METHODS event_dollar_arg  FOR TESTING.
    METHODS event_binding_arg FOR TESTING.
    METHODS event_empty_arg   FOR TESTING.
    METHODS event_empty_middle_arg FOR TESTING.
    METHODS event_trailing_empty_arg FOR TESTING.
    METHODS event_view_param FOR TESTING.
    METHODS event_multi_req   FOR TESTING.
    METHODS event_prevent_default FOR TESTING.
    METHODS event_prevent_default_expr FOR TESTING.
    METHODS event_client_args FOR TESTING.
    METHODS event_nav_container FOR TESTING.
    METHODS event_popup_close   FOR TESTING.
    METHODS event_quote_escaped FOR TESTING.
    METHODS event_backslash_escaped FOR TESTING.
    METHODS event_lone_cr_escaped FOR TESTING.
    METHODS event_placeholder_quoted FOR TESTING.
    METHODS json_basic FOR TESTING.
    METHODS json_no_args FOR TESTING.
    METHODS json_nav_container FOR TESTING.
    METHODS json_view_param FOR TESTING.
    METHODS json_empty_args FOR TESTING.
    METHODS json_object_arg FOR TESTING.
    METHODS json_placeholder_stays_string FOR TESTING.
    METHODS json_escaping FOR TESTING.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.
  METHOD event.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA lv_event TYPE string.
    CREATE OBJECT lo_event.

    lv_event = lo_event->get_event( `POST` ).

    cl_abap_unit_assert=>assert_equals( exp = `.eB(['POST'])`
                                        act = lv_event ).

  ENDMETHOD.

  METHOD event_client.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA lv_event TYPE string.
    CREATE OBJECT lo_event.

    lv_event = lo_event->get_event_client( z2ui5_if_client=>cs_event-set_focus ).

    cl_abap_unit_assert=>assert_equals( exp = `.eF('SET_FOCUS')`
                                        act = lv_event ).

  ENDMETHOD.

  METHOD event_nav_container.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA temp1 TYPE string_table.
    DATA temp3 TYPE string_table.
    CREATE OBJECT lo_event.

    " a *_nav_container_to client event is remapped to the generic
    " CONTROL_BY_ID call (container, slot, `to`, target) - this covers both the
    " follow_up_action and the XML-bound _event_client path, since both format
    " through get_event_client

    CLEAR temp1.
    INSERT `myContainer` INTO TABLE temp1.
    INSERT `myPage` INTO TABLE temp1.
    cl_abap_unit_assert=>assert_equals(
        exp = `.eF('CONTROL_BY_ID', 'myContainer', 'MAIN', 'to', 'myPage')`
        act = lo_event->get_event_client( val   = z2ui5_if_client=>cs_event-nav_container_to
                                          t_arg = temp1 ) ).


    CLEAR temp3.
    INSERT `nestCon` INTO TABLE temp3.
    INSERT `nestPage` INTO TABLE temp3.
    cl_abap_unit_assert=>assert_equals(
        exp = `.eF('CONTROL_BY_ID', 'nestCon', 'NEST', 'to', 'nestPage')`
        act = lo_event->get_event_client( val   = z2ui5_if_client=>cs_event-nest_nav_container_to
                                          t_arg = temp3 ) ).

  ENDMETHOD.

  METHOD event_popup_close.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    CREATE OBJECT lo_event.

    " closing a popup IS tearing its slot down, so the two close events are
    " formatted as the same VIEW_SLOTS call the framework queues for a
    " popup_destroy( ) - one teardown path, not a second handler beside it
    cl_abap_unit_assert=>assert_equals(
        exp = `.eF('CONTROL_GLOBAL', 'VIEW_SLOTS', 'destroy', 'POPUP')`
        act = lo_event->get_event_client( z2ui5_if_client=>cs_event-popup_close ) ).

    cl_abap_unit_assert=>assert_equals(
        exp = `.eF('CONTROL_GLOBAL', 'VIEW_SLOTS', 'destroy', 'POPOVER')`
        act = lo_event->get_event_client( z2ui5_if_client=>cs_event-popover_close ) ).

    " the follow-up action path formats the same call as pure data
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_GLOBAL","VIEW_SLOTS","destroy","POPUP"]`
        act = lo_event->get_event_client_json( z2ui5_if_client=>cs_event-popup_close ) ).

  ENDMETHOD.

  METHOD event_with_args.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA temp1 TYPE string_table.
    DATA lv_event TYPE string.
    DATA temp2 TYPE xsdboolean.
    DATA temp3 TYPE xsdboolean.
    DATA temp4 TYPE xsdboolean.
    DATA temp5 TYPE xsdboolean.
    CREATE OBJECT lo_event.

    CLEAR temp1.
    INSERT `arg1` INTO TABLE temp1.

    lv_event = lo_event->get_event( val         = `MY_EVT`
                                          t_arg = temp1 ).



    temp4 = boolc( lv_event CS `MY_EVT` ).
    temp2 = temp4.
    cl_abap_unit_assert=>assert_true( temp2 ).


    temp5 = boolc( lv_event CS `'arg1'` ).
    temp3 = temp5.
    cl_abap_unit_assert=>assert_true( temp3 ).

  ENDMETHOD.

  METHOD event_multi_args.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA temp3 TYPE string_table.
    DATA lv_event TYPE string.
    DATA temp4 TYPE xsdboolean.
    DATA temp5 TYPE xsdboolean.
    DATA temp6 TYPE xsdboolean.
    DATA temp7 TYPE xsdboolean.
    DATA temp8 TYPE xsdboolean.
    DATA temp9 TYPE xsdboolean.
    CREATE OBJECT lo_event.

    CLEAR temp3.
    INSERT `a1` INTO TABLE temp3.
    INSERT `a2` INTO TABLE temp3.
    INSERT `a3` INTO TABLE temp3.

    lv_event = lo_event->get_event( val         = `EVT`
                                          t_arg = temp3 ).



    temp7 = boolc( lv_event CS `'a1'` ).
    temp4 = temp7.
    cl_abap_unit_assert=>assert_true( temp4 ).


    temp8 = boolc( lv_event CS `'a2'` ).
    temp5 = temp8.
    cl_abap_unit_assert=>assert_true( temp5 ).


    temp9 = boolc( lv_event CS `'a3'` ).
    temp6 = temp9.
    cl_abap_unit_assert=>assert_true( temp6 ).

  ENDMETHOD.

  METHOD event_dollar_arg.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA temp5 TYPE string_table.
    DATA lv_event TYPE string.
    DATA temp7 TYPE xsdboolean.
    DATA temp8 TYPE xsdboolean.
    DATA temp10 TYPE xsdboolean.
    DATA temp11 TYPE xsdboolean.
    CREATE OBJECT lo_event.

    CLEAR temp5.
    INSERT `$event` INTO TABLE temp5.

    lv_event = lo_event->get_event( val         = `EVT`
                                          t_arg = temp5 ).



    temp10 = boolc( lv_event CS `$event` ).
    temp7 = temp10.
    cl_abap_unit_assert=>assert_true( temp7 ).


    temp11 = boolc( lv_event CS `'$event'` ).
    temp8 = temp11.
    cl_abap_unit_assert=>assert_false( temp8 ).

  ENDMETHOD.

  METHOD event_binding_arg.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA temp7 TYPE string_table.
    DATA lv_event TYPE string.
    DATA temp9 TYPE xsdboolean.
    DATA temp10 TYPE xsdboolean.
    DATA temp12 TYPE xsdboolean.
    DATA temp13 TYPE xsdboolean.
    CREATE OBJECT lo_event.

    CLEAR temp7.
    INSERT `{/MY_PATH}` INTO TABLE temp7.

    lv_event = lo_event->get_event( val         = `EVT`
                                          t_arg = temp7 ).



    temp12 = boolc( lv_event CS `{/MY_PATH}` ).
    temp9 = temp12.
    cl_abap_unit_assert=>assert_true( temp9 ).


    temp13 = boolc( lv_event CS `'{/MY_PATH}'` ).
    temp10 = temp13.
    cl_abap_unit_assert=>assert_false( temp10 ).

  ENDMETHOD.

  METHOD event_empty_arg.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA temp9 TYPE string_table.
    DATA lv_event TYPE string.
    DATA temp11 TYPE xsdboolean.
    DATA temp14 TYPE xsdboolean.
    CREATE OBJECT lo_event.

    CLEAR temp9.
    INSERT `` INTO TABLE temp9.
    INSERT `real` INTO TABLE temp9.

    lv_event = lo_event->get_event( val         = `EVT`
                                          t_arg = temp9 ).



    temp14 = boolc( lv_event CS `'real'` ).
    temp11 = temp14.
    cl_abap_unit_assert=>assert_true( temp11 ).

  ENDMETHOD.

  METHOD event_empty_middle_arg.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA temp5 TYPE string_table.
    CREATE OBJECT lo_event.

    " for control_by_id the view is injected as the empty slot at position 2
    " (default cs_view-main), so an empty argument BETWEEN filled ones keeps
    " its position - dropping it would shift every following argument into the
    " wrong slot (a CONTROL_BY_ID action without a view lost its method name
    " this way, live find in beta samples 448/449)

    CLEAR temp5.
    INSERT `demoPanel` INTO TABLE temp5.
    INSERT `setExpanded` INTO TABLE temp5.
    INSERT `X` INTO TABLE temp5.
    cl_abap_unit_assert=>assert_equals(
        exp = `.eF('CONTROL_BY_ID', 'demoPanel', '', 'setExpanded', 'X')`
        act = lo_event->get_event_client( val   = z2ui5_if_client=>cs_event-control_by_id
                                          t_arg = temp5 ) ).

  ENDMETHOD.

  METHOD event_trailing_empty_arg.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA temp7 TYPE string_table.
    CREATE OBJECT lo_event.

    " trailing empties still disappear - an ABAP false boolean param
    " serializes to `` and simply ends the argument list, while the injected
    " main-view empty slot at position 2 stays

    CLEAR temp7.
    INSERT `demoPanel` INTO TABLE temp7.
    INSERT `setExpanded` INTO TABLE temp7.
    INSERT `` INTO TABLE temp7.
    cl_abap_unit_assert=>assert_equals(
        exp = `.eF('CONTROL_BY_ID', 'demoPanel', '', 'setExpanded')`
        act = lo_event->get_event_client( val   = z2ui5_if_client=>cs_event-control_by_id
                                          t_arg = temp7 ) ).

  ENDMETHOD.

  METHOD event_view_param.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA temp9 TYPE string_table.
    DATA temp11 TYPE string_table.
    CREATE OBJECT lo_event.

    " a concrete view is injected as the (filled) slot at position 2, scoping
    " the id lookup to that view slot on the frontend

    CLEAR temp9.
    INSERT `demoPanel` INTO TABLE temp9.
    INSERT `setExpanded` INTO TABLE temp9.
    INSERT `X` INTO TABLE temp9.
    cl_abap_unit_assert=>assert_equals(
        exp = `.eF('CONTROL_BY_ID', 'demoPanel', 'POPOVER', 'setExpanded', 'X')`
        act = lo_event->get_event_client( val   = z2ui5_if_client=>cs_event-control_by_id
                                          view  = z2ui5_if_client=>cs_view-popover
                                          t_arg = temp9 ) ).

    " the default view (cs_view-main) maps to the empty slot, preserving the
    " unchanged cross-view resolveById default

    CLEAR temp11.
    INSERT `demoPanel` INTO TABLE temp11.
    INSERT `setExpanded` INTO TABLE temp11.
    INSERT `X` INTO TABLE temp11.
    cl_abap_unit_assert=>assert_equals(
        exp = `.eF('CONTROL_BY_ID', 'demoPanel', '', 'setExpanded', 'X')`
        act = lo_event->get_event_client( val   = z2ui5_if_client=>cs_event-control_by_id
                                          view  = z2ui5_if_client=>cs_view-main
                                          t_arg = temp11 ) ).

  ENDMETHOD.

  METHOD event_multi_req.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA temp11 TYPE z2ui5_if_types=>ty_s_event_control.
    DATA lv_event TYPE string.
    DATA temp12 TYPE xsdboolean.
    DATA temp15 TYPE xsdboolean.
    CREATE OBJECT lo_event.

    CLEAR temp11.
    temp11-check_allow_multi_req = abap_true.

    lv_event = lo_event->get_event( val         = `EVT`
                                          s_cnt = temp11 ).



    temp15 = boolc( lv_event CS `false,true` ).
    temp12 = temp15.
    cl_abap_unit_assert=>assert_true( temp12 ).

  ENDMETHOD.

  METHOD event_prevent_default.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA ls_ctrl TYPE z2ui5_if_types=>ty_s_event_control.
    DATA temp13 TYPE string_table.
    CREATE OBJECT lo_event.

    CLEAR ls_ctrl.
    ls_ctrl-check_prevent_default = abap_true.

    " the event is bound to .eBP and receives the UI5 event object, which the
    " frontend needs to cancel the control's built-in default before the
    " roundtrip - everything after it is the unchanged .eB payload
    cl_abap_unit_assert=>assert_equals(
        exp = `.eBP($event,true,['ITEM_PRESS'])`
        act = lo_event->get_event( val   = `ITEM_PRESS`
                                   s_cnt = ls_ctrl ) ).


    CLEAR temp13.
    INSERT `$event.oSource.sId` INTO TABLE temp13.
    cl_abap_unit_assert=>assert_equals(
        exp = `.eBP($event,true,['ITEM_PRESS'], $event.oSource.sId)`
        act = lo_event->get_event( val   = `ITEM_PRESS`
                                   t_arg = temp13
                                   s_cnt = ls_ctrl ) ).

    " both flags together stay independent
    ls_ctrl-check_allow_multi_req = abap_true.
    cl_abap_unit_assert=>assert_equals(
        exp = `.eBP($event,true,['ITEM_PRESS',false,true])`
        act = lo_event->get_event( val   = `ITEM_PRESS`
                                   s_cnt = ls_ctrl ) ).

    " unchanged without the flag
    CLEAR ls_ctrl.
    cl_abap_unit_assert=>assert_equals(
        exp = `.eB(['ITEM_PRESS'])`
        act = lo_event->get_event( val   = `ITEM_PRESS`
                                   s_cnt = ls_ctrl ) ).

  ENDMETHOD.

  METHOD event_prevent_default_expr.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA ls_ctrl TYPE z2ui5_if_types=>ty_s_event_control.
    DATA temp15 TYPE string_table.
    CREATE OBJECT lo_event.

    CLEAR ls_ctrl.
    ls_ctrl-prevent_default_expr = `${$parameters>/column}.getId().indexOf('COL_DATE') >= 0`.

    " the expression takes the place of the constant `true`, so the veto is
    " decided per firing - one wire protects one column and lets the rest
    " through. The payload after it is unchanged

    CLEAR temp15.
    INSERT `${$parameters>/width}` INTO TABLE temp15.
    cl_abap_unit_assert=>assert_equals(
        exp = `.eBP($event,${$parameters>/column}.getId().indexOf('COL_DATE') >= 0,['COLUMN_RESIZE'], ${$parameters>/width})`
        act = lo_event->get_event( val   = `COLUMN_RESIZE`
                                   t_arg = temp15
                                   s_cnt = ls_ctrl ) ).

    " the expression wins over the flag when both are set
    ls_ctrl-check_prevent_default = abap_true.
    cl_abap_unit_assert=>assert_equals(
        exp = `.eBP($event,${$parameters>/column}.getId().indexOf('COL_DATE') >= 0,['COLUMN_RESIZE'])`
        act = lo_event->get_event( val   = `COLUMN_RESIZE`
                                   s_cnt = ls_ctrl ) ).

    " and it combines with the multi-request flag like the plain form
    CLEAR ls_ctrl.
    ls_ctrl-prevent_default_expr  = `${$parameters>/on}`.
    ls_ctrl-check_allow_multi_req = abap_true.
    cl_abap_unit_assert=>assert_equals(
        exp = `.eBP($event,${$parameters>/on},['COLUMN_RESIZE',false,true])`
        act = lo_event->get_event( val   = `COLUMN_RESIZE`
                                   s_cnt = ls_ctrl ) ).

  ENDMETHOD.

  METHOD event_client_args.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA temp12 TYPE string_table.
    DATA lv_event TYPE string.
    DATA temp13 TYPE xsdboolean.
    DATA temp14 TYPE xsdboolean.
    DATA temp16 TYPE xsdboolean.
    DATA temp17 TYPE xsdboolean.
    CREATE OBJECT lo_event.

    CLEAR temp12.
    INSERT `param1` INTO TABLE temp12.

    lv_event = lo_event->get_event_client( val         = `CLOSE`
                                                 t_arg = temp12 ).



    temp16 = boolc( lv_event CS `CLOSE` ).
    temp13 = temp16.
    cl_abap_unit_assert=>assert_true( temp13 ).


    temp17 = boolc( lv_event CS `'param1'` ).
    temp14 = temp17.
    cl_abap_unit_assert=>assert_true( temp14 ).

  ENDMETHOD.

  METHOD event_quote_escaped.

    " an embedded ' must be escaped to \' so it cannot close the '...' wrapper
    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA temp17 TYPE string_table.
    DATA lt_arg LIKE temp17.
    DATA lv_event TYPE string.
    DATA temp18 TYPE xsdboolean.
    CREATE OBJECT lo_event TYPE z2ui5_cl_ui5_srv_event.

    CLEAR temp17.
    INSERT `Value changed to '{0}'` INTO TABLE temp17.

    lt_arg = temp17.


    lv_event = lo_event->get_event( val   = `EVT`
                                          t_arg = lt_arg ).


    temp18 = boolc( lv_event CS `'Value changed to \'{0}\''` ).
    cl_abap_unit_assert=>assert_true( temp18 ).

  ENDMETHOD.

  METHOD event_backslash_escaped.

    " a backslash must be escaped to \\ FIRST, so a value ending in '\' or
    " containing "\'" cannot break out of the '...' wrapper and inject JS.
    " Regression for: arg `\',alert(1),'` used to emit `'\\',alert(1),\''`,
    " closing the string early and evaluating alert(1) as an argument.
    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA temp19 TYPE string_table.
    DATA lt_arg LIKE temp19.
    DATA lv_event TYPE string.
    DATA temp20 TYPE xsdboolean.
    DATA temp21 TYPE xsdboolean.
    CREATE OBJECT lo_event TYPE z2ui5_cl_ui5_srv_event.

    CLEAR temp19.
    INSERT `\',alert(1),'` INTO TABLE temp19.

    lt_arg = temp19.


    lv_event = lo_event->get_event( val   = `EVT`
                                          t_arg = lt_arg ).

    " the backslash is doubled and the quotes escaped, so the whole payload
    " stays inside one string literal - no bare alert(1) leaks out

    temp20 = boolc( lv_event CS `'\\\',alert(1),\''` ).
    cl_abap_unit_assert=>assert_true( temp20 ).

    temp21 = boolc( lv_event CS `',alert(1),'` ).
    cl_abap_unit_assert=>assert_false( temp21 ).

  ENDMETHOD.

  METHOD event_lone_cr_escaped.

    " a standalone CR (not part of CR+LF) is a JS line terminator like LF -
    " it must be escaped too, or the emitted '...' literal is a syntax error
    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA lv_cr TYPE string.
    DATA temp21 TYPE string_table.
    DATA temp1 LIKE LINE OF temp21.
    DATA lt_arg LIKE temp21.
    DATA lv_event TYPE string.
    DATA temp22 TYPE xsdboolean.
    DATA temp23 TYPE xsdboolean.
    CREATE OBJECT lo_event TYPE z2ui5_cl_ui5_srv_event.

    lv_cr = substring( val = z2ui5_cl_ui5_util_context=>cv_char_util_cr_lf
                             off = 0
                             len = 1 ).

    CLEAR temp21.

    temp1 = |before{ lv_cr }after|.
    INSERT temp1 INTO TABLE temp21.

    lt_arg = temp21.


    lv_event = lo_event->get_event( val   = `EVT`
                                          t_arg = lt_arg ).


    temp22 = boolc( lv_event CS `'before\rafter'` ).
    cl_abap_unit_assert=>assert_true( temp22 ).

    temp23 = boolc( lv_event CS lv_cr ).
    cl_abap_unit_assert=>assert_false( temp23 ).

  ENDMETHOD.

  METHOD event_placeholder_quoted.

    " a value-first placeholder ({0}...) and a conditional placeholder
    " ({0?a:b}...) are plain strings, so both are quoted (not emitted raw)
    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA temp23 TYPE string_table.
    DATA lv_plain TYPE string.
    DATA temp24 TYPE xsdboolean.
    DATA temp25 TYPE string_table.
    DATA lv_cond TYPE string.
    DATA temp26 TYPE xsdboolean.
    CREATE OBJECT lo_event TYPE z2ui5_cl_ui5_srv_event.


    CLEAR temp23.
    INSERT `{0} Pressed` INTO TABLE temp23.

    lv_plain = lo_event->get_event( val   = `EVT`
                                          t_arg = temp23 ).

    temp24 = boolc( lv_plain CS `'{0} Pressed'` ).
    cl_abap_unit_assert=>assert_true( temp24 ).


    CLEAR temp25.
    INSERT `{0?Pressed:Unpressed}` INTO TABLE temp25.

    lv_cond = lo_event->get_event( val   = `EVT`
                                         t_arg = temp25 ).

    temp26 = boolc( lv_cond CS `'{0?Pressed:Unpressed}'` ).
    cl_abap_unit_assert=>assert_true( temp26 ).

  ENDMETHOD.

  METHOD json_basic.

    " the structured follow-up form: a JSON array ["EVENT", ...args] built
    " and escaped entirely in ABAP - data, not an executable eF( ) snippet
    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA temp27 TYPE string_table.
    CREATE OBJECT lo_event TYPE z2ui5_cl_ui5_srv_event.


    CLEAR temp27.
    INSERT `My Title` INTO TABLE temp27.
    cl_abap_unit_assert=>assert_equals(
        exp = `["SET_TITLE","My Title"]`
        act = lo_event->get_event_client_json( val   = z2ui5_if_client=>cs_event-set_title
                                               t_arg = temp27 ) ).

  ENDMETHOD.

  METHOD json_no_args.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    CREATE OBJECT lo_event TYPE z2ui5_cl_ui5_srv_event.

    cl_abap_unit_assert=>assert_equals(
        exp = `["LOCATION_RELOAD"]`
        act = lo_event->get_event_client_json( z2ui5_if_client=>cs_event-location_reload ) ).

  ENDMETHOD.

  METHOD json_nav_container.

    " the *_nav_container_to remap to the generic CONTROL_BY_ID call is shared
    " with the JS path via map_client_event
    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA temp29 TYPE string_table.
    CREATE OBJECT lo_event TYPE z2ui5_cl_ui5_srv_event.


    CLEAR temp29.
    INSERT `myContainer` INTO TABLE temp29.
    INSERT `myPage` INTO TABLE temp29.
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_BY_ID","myContainer","MAIN","to","myPage"]`
        act = lo_event->get_event_client_json( val   = z2ui5_if_client=>cs_event-nav_container_to
                                               t_arg = temp29 ) ).

  ENDMETHOD.

  METHOD json_view_param.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA temp31 TYPE string_table.
    DATA temp33 TYPE string_table.
    CREATE OBJECT lo_event TYPE z2ui5_cl_ui5_srv_event.

    " a concrete view fills the slot at position 2, the default main view
    " keeps it empty (cross-view resolveById on the frontend)

    CLEAR temp31.
    INSERT `demoPanel` INTO TABLE temp31.
    INSERT `setExpanded` INTO TABLE temp31.
    INSERT `X` INTO TABLE temp31.
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_BY_ID","demoPanel","POPOVER","setExpanded","X"]`
        act = lo_event->get_event_client_json( val   = z2ui5_if_client=>cs_event-control_by_id
                                               view  = z2ui5_if_client=>cs_view-popover
                                               t_arg = temp31 ) ).


    CLEAR temp33.
    INSERT `demoPanel` INTO TABLE temp33.
    INSERT `setExpanded` INTO TABLE temp33.
    INSERT `X` INTO TABLE temp33.
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_BY_ID","demoPanel","","setExpanded","X"]`
        act = lo_event->get_event_client_json( val   = z2ui5_if_client=>cs_event-control_by_id
                                               t_arg = temp33 ) ).

  ENDMETHOD.

  METHOD json_empty_args.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA temp35 TYPE string_table.
    CREATE OBJECT lo_event TYPE z2ui5_cl_ui5_srv_event.

    " an empty argument between filled ones keeps its position, trailing
    " empties are dropped - same contract as the JS form (get_t_arg)

    CLEAR temp35.
    INSERT `demoPanel` INTO TABLE temp35.
    INSERT `setExpanded` INTO TABLE temp35.
    INSERT `` INTO TABLE temp35.
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_BY_ID","demoPanel","","setExpanded"]`
        act = lo_event->get_event_client_json( val   = z2ui5_if_client=>cs_event-control_by_id
                                               t_arg = temp35 ) ).

  ENDMETHOD.

  METHOD json_object_arg.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA temp37 TYPE string_table.
    CREATE OBJECT lo_event TYPE z2ui5_cl_ui5_srv_event.

    " a JSON object argument (e.g. the STORE_DATA payload) is embedded as
    " real JSON, so the frontend receives a ready-to-use object after one
    " JSON.parse of the whole array

    CLEAR temp37.
    INSERT `{"KEY":"K1"}` INTO TABLE temp37.
    cl_abap_unit_assert=>assert_equals(
        exp = `["STORE_DATA",{"KEY":"K1"}]`
        act = lo_event->get_event_client_json( val   = z2ui5_if_client=>cs_event-store_data
                                               t_arg = temp37 ) ).

  ENDMETHOD.

  METHOD json_placeholder_stays_string.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA temp39 TYPE string_table.
    CREATE OBJECT lo_event TYPE z2ui5_cl_ui5_srv_event.

    " a message-template placeholder only looks like JSON - it fails the
    " parse and stays a plain string, like the frontend fallback produced

    CLEAR temp39.
    INSERT `MESSAGE_TOAST` INTO TABLE temp39.
    INSERT `show` INTO TABLE temp39.
    INSERT `{0} Pressed` INTO TABLE temp39.
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_GLOBAL","MESSAGE_TOAST","show","{0} Pressed"]`
        act = lo_event->get_event_client_json( val   = z2ui5_if_client=>cs_event-control_global
                                               t_arg = temp39 ) ).

  ENDMETHOD.

  METHOD json_escaping.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA temp41 TYPE string_table.
    CREATE OBJECT lo_event TYPE z2ui5_cl_ui5_srv_event.

    " quotes and backslashes in an argument are JSON-escaped by the ABAP
    " serializer - no hand-written escaping, no JS string literal to break
    " out of (the injection surface of the old eF( ) form)

    CLEAR temp41.
    INSERT `he said "hi" \ bye` INTO TABLE temp41.
    cl_abap_unit_assert=>assert_equals(
        exp = `["CLIPBOARD_COPY","he said \"hi\" \\ bye"]`
        act = lo_event->get_event_client_json( val   = z2ui5_if_client=>cs_event-clipboard_copy
                                               t_arg = temp41 ) ).

  ENDMETHOD.

ENDCLASS.
