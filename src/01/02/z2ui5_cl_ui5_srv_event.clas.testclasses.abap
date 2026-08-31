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
    lo_event = NEW #( ).

    lv_event = lo_event->get_event( `POST` ).

    cl_abap_unit_assert=>assert_equals( exp = `.eB(['POST'])`
                                        act = lv_event ).

  ENDMETHOD.

  METHOD event_client.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA lv_event TYPE string.
    lo_event = NEW #( ).

    lv_event = lo_event->get_event_client( z2ui5_if_client=>cs_event-set_focus ).

    cl_abap_unit_assert=>assert_equals( exp = `.eF('SET_FOCUS')`
                                        act = lv_event ).

  ENDMETHOD.

  METHOD event_nav_container.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    lo_event = NEW #( ).

    " a *_nav_container_to client event is remapped to the generic
    " CONTROL_BY_ID call (container, slot, `to`, target) - this covers both the
    " follow_up_action and the XML-bound _event_client path, since both format
    " through get_event_client
    cl_abap_unit_assert=>assert_equals(
        exp = `.eF('CONTROL_BY_ID', 'myContainer', 'MAIN', 'to', 'myPage')`
        act = lo_event->get_event_client( val   = z2ui5_if_client=>cs_event-nav_container_to
                                          t_arg = VALUE #( ( `myContainer` ) ( `myPage` ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
        exp = `.eF('CONTROL_BY_ID', 'nestCon', 'NEST', 'to', 'nestPage')`
        act = lo_event->get_event_client( val   = z2ui5_if_client=>cs_event-nest_nav_container_to
                                          t_arg = VALUE #( ( `nestCon` ) ( `nestPage` ) ) ) ).

  ENDMETHOD.

  METHOD event_popup_close.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    lo_event = NEW #( ).

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
    lo_event = NEW #( ).

    CLEAR temp1.
    INSERT `arg1` INTO TABLE temp1.

    lv_event = lo_event->get_event( val         = `MY_EVT`
                                          t_arg = temp1 ).


    temp2 = xsdbool( lv_event CS `MY_EVT` ).
    cl_abap_unit_assert=>assert_true( temp2 ).

    temp3 = xsdbool( lv_event CS `'arg1'` ).
    cl_abap_unit_assert=>assert_true( temp3 ).

  ENDMETHOD.

  METHOD event_multi_args.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA temp3 TYPE string_table.
    DATA lv_event TYPE string.
    DATA temp4 TYPE xsdboolean.
    DATA temp5 TYPE xsdboolean.
    DATA temp6 TYPE xsdboolean.
    lo_event = NEW #( ).

    CLEAR temp3.
    INSERT `a1` INTO TABLE temp3.
    INSERT `a2` INTO TABLE temp3.
    INSERT `a3` INTO TABLE temp3.

    lv_event = lo_event->get_event( val         = `EVT`
                                          t_arg = temp3 ).


    temp4 = xsdbool( lv_event CS `'a1'` ).
    cl_abap_unit_assert=>assert_true( temp4 ).

    temp5 = xsdbool( lv_event CS `'a2'` ).
    cl_abap_unit_assert=>assert_true( temp5 ).

    temp6 = xsdbool( lv_event CS `'a3'` ).
    cl_abap_unit_assert=>assert_true( temp6 ).

  ENDMETHOD.

  METHOD event_dollar_arg.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA temp5 TYPE string_table.
    DATA lv_event TYPE string.
    DATA temp7 TYPE xsdboolean.
    DATA temp8 TYPE xsdboolean.
    lo_event = NEW #( ).

    CLEAR temp5.
    INSERT `$event` INTO TABLE temp5.

    lv_event = lo_event->get_event( val         = `EVT`
                                          t_arg = temp5 ).


    temp7 = xsdbool( lv_event CS `$event` ).
    cl_abap_unit_assert=>assert_true( temp7 ).

    temp8 = xsdbool( lv_event CS `'$event'` ).
    cl_abap_unit_assert=>assert_false( temp8 ).

  ENDMETHOD.

  METHOD event_binding_arg.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA temp7 TYPE string_table.
    DATA lv_event TYPE string.
    DATA temp9 TYPE xsdboolean.
    DATA temp10 TYPE xsdboolean.
    lo_event = NEW #( ).

    CLEAR temp7.
    INSERT `{/MY_PATH}` INTO TABLE temp7.

    lv_event = lo_event->get_event( val         = `EVT`
                                          t_arg = temp7 ).


    temp9 = xsdbool( lv_event CS `{/MY_PATH}` ).
    cl_abap_unit_assert=>assert_true( temp9 ).

    temp10 = xsdbool( lv_event CS `'{/MY_PATH}'` ).
    cl_abap_unit_assert=>assert_false( temp10 ).

  ENDMETHOD.

  METHOD event_empty_arg.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA temp9 TYPE string_table.
    DATA lv_event TYPE string.
    DATA temp11 TYPE xsdboolean.
    lo_event = NEW #( ).

    CLEAR temp9.
    INSERT `` INTO TABLE temp9.
    INSERT `real` INTO TABLE temp9.

    lv_event = lo_event->get_event( val         = `EVT`
                                          t_arg = temp9 ).


    temp11 = xsdbool( lv_event CS `'real'` ).
    cl_abap_unit_assert=>assert_true( temp11 ).

  ENDMETHOD.

  METHOD event_empty_middle_arg.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    lo_event = NEW #( ).

    " for control_by_id the view is injected as the empty slot at position 2
    " (default cs_view-main), so an empty argument BETWEEN filled ones keeps
    " its position - dropping it would shift every following argument into the
    " wrong slot (a CONTROL_BY_ID action without a view lost its method name
    " this way, live find in beta samples 448/449)
    cl_abap_unit_assert=>assert_equals(
        exp = `.eF('CONTROL_BY_ID', 'demoPanel', '', 'setExpanded', 'X')`
        act = lo_event->get_event_client( val   = z2ui5_if_client=>cs_event-control_by_id
                                          t_arg = VALUE #( ( `demoPanel` ) ( `setExpanded` ) ( `X` ) ) ) ).

  ENDMETHOD.

  METHOD event_trailing_empty_arg.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    lo_event = NEW #( ).

    " trailing empties still disappear - an ABAP false boolean param
    " serializes to `` and simply ends the argument list, while the injected
    " main-view empty slot at position 2 stays
    cl_abap_unit_assert=>assert_equals(
        exp = `.eF('CONTROL_BY_ID', 'demoPanel', '', 'setExpanded')`
        act = lo_event->get_event_client( val   = z2ui5_if_client=>cs_event-control_by_id
                                          t_arg = VALUE #( ( `demoPanel` ) ( `setExpanded` ) ( `` ) ) ) ).

  ENDMETHOD.

  METHOD event_view_param.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    lo_event = NEW #( ).

    " a concrete view is injected as the (filled) slot at position 2, scoping
    " the id lookup to that view slot on the frontend
    cl_abap_unit_assert=>assert_equals(
        exp = `.eF('CONTROL_BY_ID', 'demoPanel', 'POPOVER', 'setExpanded', 'X')`
        act = lo_event->get_event_client( val   = z2ui5_if_client=>cs_event-control_by_id
                                          view  = z2ui5_if_client=>cs_view-popover
                                          t_arg = VALUE #( ( `demoPanel` ) ( `setExpanded` ) ( `X` ) ) ) ).

    " the default view (cs_view-main) maps to the empty slot, preserving the
    " unchanged cross-view resolveById default
    cl_abap_unit_assert=>assert_equals(
        exp = `.eF('CONTROL_BY_ID', 'demoPanel', '', 'setExpanded', 'X')`
        act = lo_event->get_event_client( val   = z2ui5_if_client=>cs_event-control_by_id
                                          view  = z2ui5_if_client=>cs_view-main
                                          t_arg = VALUE #( ( `demoPanel` ) ( `setExpanded` ) ( `X` ) ) ) ).

  ENDMETHOD.

  METHOD event_multi_req.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA temp11 TYPE z2ui5_if_client=>ty_s_event_control.
    DATA lv_event TYPE string.
    DATA temp12 TYPE xsdboolean.
    lo_event = NEW #( ).

    CLEAR temp11.
    temp11-check_allow_multi_req = abap_true.

    lv_event = lo_event->get_event( val         = `EVT`
                                          s_cnt = temp11 ).


    temp12 = xsdbool( lv_event CS `false,true` ).
    cl_abap_unit_assert=>assert_true( temp12 ).

  ENDMETHOD.

  METHOD event_prevent_default.

    DATA lo_event TYPE REF TO z2ui5_cl_ui5_srv_event.
    DATA ls_ctrl TYPE z2ui5_if_client=>ty_s_event_control.
    lo_event = NEW #( ).

    CLEAR ls_ctrl.
    ls_ctrl-check_prevent_default = abap_true.

    " the event is bound to .eBP and receives the UI5 event object, which the
    " frontend needs to cancel the control's built-in default before the
    " roundtrip - everything after it is the unchanged .eB payload
    cl_abap_unit_assert=>assert_equals(
        exp = `.eBP($event,true,['ITEM_PRESS'])`
        act = lo_event->get_event( val   = `ITEM_PRESS`
                                   s_cnt = ls_ctrl ) ).

    cl_abap_unit_assert=>assert_equals(
        exp = `.eBP($event,true,['ITEM_PRESS'], $event.oSource.sId)`
        act = lo_event->get_event( val   = `ITEM_PRESS`
                                   t_arg = VALUE #( ( `$event.oSource.sId` ) )
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
    DATA ls_ctrl TYPE z2ui5_if_client=>ty_s_event_control.
    lo_event = NEW #( ).

    CLEAR ls_ctrl.
    ls_ctrl-prevent_default_expr = `${$parameters>/column}.getId().indexOf('COL_DATE') >= 0`.

    " the expression takes the place of the constant `true`, so the veto is
    " decided per firing - one wire protects one column and lets the rest
    " through. The payload after it is unchanged
    cl_abap_unit_assert=>assert_equals(
        exp = `.eBP($event,${$parameters>/column}.getId().indexOf('COL_DATE') >= 0,['COLUMN_RESIZE'], ${$parameters>/width})`
        act = lo_event->get_event( val   = `COLUMN_RESIZE`
                                   t_arg = VALUE #( ( `${$parameters>/width}` ) )
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
    lo_event = NEW #( ).

    CLEAR temp12.
    INSERT `param1` INTO TABLE temp12.

    lv_event = lo_event->get_event_client( val         = `CLOSE`
                                                 t_arg = temp12 ).


    temp13 = xsdbool( lv_event CS `CLOSE` ).
    cl_abap_unit_assert=>assert_true( temp13 ).

    temp14 = xsdbool( lv_event CS `'param1'` ).
    cl_abap_unit_assert=>assert_true( temp14 ).

  ENDMETHOD.

  METHOD event_quote_escaped.

    " an embedded ' must be escaped to \' so it cannot close the '...' wrapper
    DATA(lo_event) = NEW z2ui5_cl_ui5_srv_event( ).
    DATA(lt_arg) = VALUE string_table( ( `Value changed to '{0}'` ) ).

    DATA(lv_event) = lo_event->get_event( val   = `EVT`
                                          t_arg = lt_arg ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_event CS `'Value changed to \'{0}\''` ) ).

  ENDMETHOD.

  METHOD event_backslash_escaped.

    " a backslash must be escaped to \\ FIRST, so a value ending in '\' or
    " containing "\'" cannot break out of the '...' wrapper and inject JS.
    " Regression for: arg `\',alert(1),'` used to emit `'\\',alert(1),\''`,
    " closing the string early and evaluating alert(1) as an argument.
    DATA(lo_event) = NEW z2ui5_cl_ui5_srv_event( ).
    DATA(lt_arg) = VALUE string_table( ( `\',alert(1),'` ) ).

    DATA(lv_event) = lo_event->get_event( val   = `EVT`
                                          t_arg = lt_arg ).

    " the backslash is doubled and the quotes escaped, so the whole payload
    " stays inside one string literal - no bare alert(1) leaks out
    cl_abap_unit_assert=>assert_true( xsdbool( lv_event CS `'\\\',alert(1),\''` ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( lv_event CS `',alert(1),'` ) ).

  ENDMETHOD.

  METHOD event_lone_cr_escaped.

    " a standalone CR (not part of CR+LF) is a JS line terminator like LF -
    " it must be escaped too, or the emitted '...' literal is a syntax error
    DATA(lo_event) = NEW z2ui5_cl_ui5_srv_event( ).
    DATA(lv_cr) = substring( val = z2ui5_cl_ui5_util_context=>cv_char_util_cr_lf
                             off = 0
                             len = 1 ).
    DATA(lt_arg) = VALUE string_table( ( |before{ lv_cr }after| ) ).

    DATA(lv_event) = lo_event->get_event( val   = `EVT`
                                          t_arg = lt_arg ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_event CS `'before\rafter'` ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( lv_event CS lv_cr ) ).

  ENDMETHOD.

  METHOD event_placeholder_quoted.

    " a value-first placeholder ({0}...) and a conditional placeholder
    " ({0?a:b}...) are plain strings, so both are quoted (not emitted raw)
    DATA(lo_event) = NEW z2ui5_cl_ui5_srv_event( ).

    DATA(lv_plain) = lo_event->get_event( val   = `EVT`
                                          t_arg = VALUE #( ( `{0} Pressed` ) ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_plain CS `'{0} Pressed'` ) ).

    DATA(lv_cond) = lo_event->get_event( val   = `EVT`
                                         t_arg = VALUE #( ( `{0?Pressed:Unpressed}` ) ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_cond CS `'{0?Pressed:Unpressed}'` ) ).

  ENDMETHOD.

  METHOD json_basic.

    " the structured follow-up form: a JSON array ["EVENT", ...args] built
    " and escaped entirely in ABAP - data, not an executable eF( ) snippet
    DATA(lo_event) = NEW z2ui5_cl_ui5_srv_event( ).

    cl_abap_unit_assert=>assert_equals(
        exp = `["SET_TITLE","My Title"]`
        act = lo_event->get_event_client_json( val   = z2ui5_if_client=>cs_event-set_title
                                               t_arg = VALUE #( ( `My Title` ) ) ) ).

  ENDMETHOD.

  METHOD json_no_args.

    DATA(lo_event) = NEW z2ui5_cl_ui5_srv_event( ).

    cl_abap_unit_assert=>assert_equals(
        exp = `["LOCATION_RELOAD"]`
        act = lo_event->get_event_client_json( z2ui5_if_client=>cs_event-location_reload ) ).

  ENDMETHOD.

  METHOD json_nav_container.

    " the *_nav_container_to remap to the generic CONTROL_BY_ID call is shared
    " with the JS path via map_client_event
    DATA(lo_event) = NEW z2ui5_cl_ui5_srv_event( ).

    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_BY_ID","myContainer","MAIN","to","myPage"]`
        act = lo_event->get_event_client_json( val   = z2ui5_if_client=>cs_event-nav_container_to
                                               t_arg = VALUE #( ( `myContainer` ) ( `myPage` ) ) ) ).

  ENDMETHOD.

  METHOD json_view_param.

    DATA(lo_event) = NEW z2ui5_cl_ui5_srv_event( ).

    " a concrete view fills the slot at position 2, the default main view
    " keeps it empty (cross-view resolveById on the frontend)
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_BY_ID","demoPanel","POPOVER","setExpanded","X"]`
        act = lo_event->get_event_client_json( val   = z2ui5_if_client=>cs_event-control_by_id
                                               view  = z2ui5_if_client=>cs_view-popover
                                               t_arg = VALUE #( ( `demoPanel` ) ( `setExpanded` ) ( `X` ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_BY_ID","demoPanel","","setExpanded","X"]`
        act = lo_event->get_event_client_json( val   = z2ui5_if_client=>cs_event-control_by_id
                                               t_arg = VALUE #( ( `demoPanel` ) ( `setExpanded` ) ( `X` ) ) ) ).

  ENDMETHOD.

  METHOD json_empty_args.

    DATA(lo_event) = NEW z2ui5_cl_ui5_srv_event( ).

    " an empty argument between filled ones keeps its position, trailing
    " empties are dropped - same contract as the JS form (get_t_arg)
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_BY_ID","demoPanel","","setExpanded"]`
        act = lo_event->get_event_client_json( val   = z2ui5_if_client=>cs_event-control_by_id
                                               t_arg = VALUE #( ( `demoPanel` ) ( `setExpanded` ) ( `` ) ) ) ).

  ENDMETHOD.

  METHOD json_object_arg.

    DATA(lo_event) = NEW z2ui5_cl_ui5_srv_event( ).

    " a JSON object argument (e.g. the STORE_DATA payload) is embedded as
    " real JSON, so the frontend receives a ready-to-use object after one
    " JSON.parse of the whole array
    cl_abap_unit_assert=>assert_equals(
        exp = `["STORE_DATA",{"KEY":"K1"}]`
        act = lo_event->get_event_client_json( val   = z2ui5_if_client=>cs_event-store_data
                                               t_arg = VALUE #( ( `{"KEY":"K1"}` ) ) ) ).

  ENDMETHOD.

  METHOD json_placeholder_stays_string.

    DATA(lo_event) = NEW z2ui5_cl_ui5_srv_event( ).

    " a message-template placeholder only looks like JSON - it fails the
    " parse and stays a plain string, like the frontend fallback produced
    cl_abap_unit_assert=>assert_equals(
        exp = `["CONTROL_GLOBAL","MESSAGE_TOAST","show","{0} Pressed"]`
        act = lo_event->get_event_client_json( val   = z2ui5_if_client=>cs_event-control_global
                                               t_arg = VALUE #( ( `MESSAGE_TOAST` ) ( `show` ) ( `{0} Pressed` ) ) ) ).

  ENDMETHOD.

  METHOD json_escaping.

    DATA(lo_event) = NEW z2ui5_cl_ui5_srv_event( ).

    " quotes and backslashes in an argument are JSON-escaped by the ABAP
    " serializer - no hand-written escaping, no JS string literal to break
    " out of (the injection surface of the old eF( ) form)
    cl_abap_unit_assert=>assert_equals(
        exp = `["CLIPBOARD_COPY","he said \"hi\" \\ bye"]`
        act = lo_event->get_event_client_json( val   = z2ui5_if_client=>cs_event-clipboard_copy
                                               t_arg = VALUE #( ( `he said "hi" \ bye` ) ) ) ).

  ENDMETHOD.

ENDCLASS.
