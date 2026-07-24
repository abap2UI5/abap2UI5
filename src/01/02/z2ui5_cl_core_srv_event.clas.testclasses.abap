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
    METHODS event_client_args FOR TESTING.
    METHODS event_nav_container FOR TESTING.
    METHODS event_quote_escaped FOR TESTING.
    METHODS event_placeholder_quoted FOR TESTING.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.
  METHOD event.

    DATA lo_event TYPE REF TO z2ui5_cl_core_srv_event.
    DATA lv_event TYPE string.
    CREATE OBJECT lo_event.

    lv_event = lo_event->get_event( `POST` ).

    cl_abap_unit_assert=>assert_equals( exp = `.eB(['POST'])`
                                        act = lv_event ).

  ENDMETHOD.

  METHOD event_client.

    DATA lo_event TYPE REF TO z2ui5_cl_core_srv_event.
    DATA lv_event TYPE string.
    CREATE OBJECT lo_event.

    lv_event = lo_event->get_event_client( z2ui5_if_client=>cs_event-popover_close ).

    cl_abap_unit_assert=>assert_equals( exp = `.eF('POPOVER_CLOSE')`
                                        act = lv_event ).

  ENDMETHOD.

  METHOD event_nav_container.

    DATA lo_event TYPE REF TO z2ui5_cl_core_srv_event.
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

  METHOD event_with_args.

    DATA lo_event TYPE REF TO z2ui5_cl_core_srv_event.
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

    DATA lo_event TYPE REF TO z2ui5_cl_core_srv_event.
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

    DATA lo_event TYPE REF TO z2ui5_cl_core_srv_event.
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

    DATA lo_event TYPE REF TO z2ui5_cl_core_srv_event.
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

    DATA lo_event TYPE REF TO z2ui5_cl_core_srv_event.
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

    DATA lo_event TYPE REF TO z2ui5_cl_core_srv_event.
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

    DATA lo_event TYPE REF TO z2ui5_cl_core_srv_event.
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

    DATA lo_event TYPE REF TO z2ui5_cl_core_srv_event.
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

    DATA lo_event TYPE REF TO z2ui5_cl_core_srv_event.
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

  METHOD event_client_args.

    DATA lo_event TYPE REF TO z2ui5_cl_core_srv_event.
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
    DATA lo_event TYPE REF TO z2ui5_cl_core_srv_event.
    DATA temp13 TYPE string_table.
    DATA lt_arg LIKE temp13.
    DATA lv_event TYPE string.
    DATA temp18 TYPE xsdboolean.
    CREATE OBJECT lo_event TYPE z2ui5_cl_core_srv_event.

    CLEAR temp13.
    INSERT `Value changed to '{0}'` INTO TABLE temp13.

    lt_arg = temp13.


    lv_event = lo_event->get_event( val   = `EVT`
                                          t_arg = lt_arg ).


    temp18 = boolc( lv_event CS `'Value changed to \'{0}\''` ).
    cl_abap_unit_assert=>assert_true( temp18 ).

  ENDMETHOD.

  METHOD event_placeholder_quoted.

    " a value-first placeholder ({0}...) and a conditional placeholder
    " ({0?a:b}...) are plain strings, so both are quoted (not emitted raw)
    DATA lo_event TYPE REF TO z2ui5_cl_core_srv_event.
    DATA temp15 TYPE string_table.
    DATA lv_plain TYPE string.
    DATA temp19 TYPE xsdboolean.
    DATA temp17 TYPE string_table.
    DATA lv_cond TYPE string.
    DATA temp20 TYPE xsdboolean.
    CREATE OBJECT lo_event TYPE z2ui5_cl_core_srv_event.


    CLEAR temp15.
    INSERT `{0} Pressed` INTO TABLE temp15.

    lv_plain = lo_event->get_event( val   = `EVT`
                                          t_arg = temp15 ).

    temp19 = boolc( lv_plain CS `'{0} Pressed'` ).
    cl_abap_unit_assert=>assert_true( temp19 ).


    CLEAR temp17.
    INSERT `{0?Pressed:Unpressed}` INTO TABLE temp17.

    lv_cond = lo_event->get_event( val   = `EVT`
                                         t_arg = temp17 ).

    temp20 = boolc( lv_cond CS `'{0?Pressed:Unpressed}'` ).
    cl_abap_unit_assert=>assert_true( temp20 ).

  ENDMETHOD.

ENDCLASS.
