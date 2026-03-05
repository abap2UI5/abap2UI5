CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION LONG.

  PUBLIC SECTION.
    METHODS event             FOR TESTING.
    METHODS event_backend     FOR TESTING.
    METHODS event_with_args   FOR TESTING.
    METHODS event_multi_args  FOR TESTING.
    METHODS event_dollar_arg  FOR TESTING.
    METHODS event_binding_arg FOR TESTING.
    METHODS event_empty_arg   FOR TESTING.
    METHODS event_multi_req   FOR TESTING.
    METHODS event_client_args FOR TESTING.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.
  METHOD event.

    DATA lo_event TYPE REF TO z2ui5_cl_core_srv_event.
    DATA lv_event TYPE string.
    CREATE OBJECT lo_event TYPE z2ui5_cl_core_srv_event.

    lv_event = lo_event->get_event( `POST` ).

    cl_abap_unit_assert=>assert_equals( exp = `.eB(['POST'])`
                                        act = lv_event ).

  ENDMETHOD.

  METHOD event_backend.

    DATA lo_event TYPE REF TO z2ui5_cl_core_srv_event.
    DATA lv_event TYPE string.
    CREATE OBJECT lo_event TYPE z2ui5_cl_core_srv_event.

    lv_event = lo_event->get_event_client( z2ui5_if_client=>cs_event-popover_close ).

    cl_abap_unit_assert=>assert_equals( exp = `.eF('POPOVER_CLOSE')`
                                        act = lv_event ).

  ENDMETHOD.

  METHOD event_with_args.

    DATA lo_event TYPE REF TO z2ui5_cl_core_srv_event.
    DATA temp1 TYPE string_table.
    DATA lv_event TYPE string.
    DATA temp2 TYPE xsdboolean.
    DATA temp3 TYPE xsdboolean.
    CREATE OBJECT lo_event TYPE z2ui5_cl_core_srv_event.

    CLEAR temp1.
    INSERT `arg1` INTO TABLE temp1.

    lv_event = lo_event->get_event( val         = `MY_EVT`
                                          t_arg = temp1 ).


    temp2 = boolc( lv_event CS `MY_EVT` ).
    cl_abap_unit_assert=>assert_true( temp2 ).

    temp3 = boolc( lv_event CS `'arg1'` ).
    cl_abap_unit_assert=>assert_true( temp3 ).

  ENDMETHOD.

  METHOD event_multi_args.

    DATA lo_event TYPE REF TO z2ui5_cl_core_srv_event.
    DATA temp3 TYPE string_table.
    DATA lv_event TYPE string.
    DATA temp4 TYPE xsdboolean.
    DATA temp5 TYPE xsdboolean.
    DATA temp6 TYPE xsdboolean.
    CREATE OBJECT lo_event TYPE z2ui5_cl_core_srv_event.

    CLEAR temp3.
    INSERT `a1` INTO TABLE temp3.
    INSERT `a2` INTO TABLE temp3.
    INSERT `a3` INTO TABLE temp3.

    lv_event = lo_event->get_event( val         = `EVT`
                                          t_arg = temp3 ).


    temp4 = boolc( lv_event CS `'a1'` ).
    cl_abap_unit_assert=>assert_true( temp4 ).

    temp5 = boolc( lv_event CS `'a2'` ).
    cl_abap_unit_assert=>assert_true( temp5 ).

    temp6 = boolc( lv_event CS `'a3'` ).
    cl_abap_unit_assert=>assert_true( temp6 ).

  ENDMETHOD.

  METHOD event_dollar_arg.

    DATA lo_event TYPE REF TO z2ui5_cl_core_srv_event.
    DATA temp5 TYPE string_table.
    DATA lv_event TYPE string.
    DATA temp7 TYPE xsdboolean.
    DATA temp8 TYPE xsdboolean.
    CREATE OBJECT lo_event TYPE z2ui5_cl_core_srv_event.

    CLEAR temp5.
    INSERT `$event` INTO TABLE temp5.

    lv_event = lo_event->get_event( val         = `EVT`
                                          t_arg = temp5 ).


    temp7 = boolc( lv_event CS `$event` ).
    cl_abap_unit_assert=>assert_true( temp7 ).

    temp8 = boolc( lv_event CS `'$event'` ).
    cl_abap_unit_assert=>assert_false( temp8 ).

  ENDMETHOD.

  METHOD event_binding_arg.

    DATA lo_event TYPE REF TO z2ui5_cl_core_srv_event.
    DATA temp7 TYPE string_table.
    DATA lv_event TYPE string.
    DATA temp9 TYPE xsdboolean.
    DATA temp10 TYPE xsdboolean.
    CREATE OBJECT lo_event TYPE z2ui5_cl_core_srv_event.

    CLEAR temp7.
    INSERT `{/MY_PATH}` INTO TABLE temp7.

    lv_event = lo_event->get_event( val         = `EVT`
                                          t_arg = temp7 ).


    temp9 = boolc( lv_event CS `{/MY_PATH}` ).
    cl_abap_unit_assert=>assert_true( temp9 ).

    temp10 = boolc( lv_event CS `'{/MY_PATH}'` ).
    cl_abap_unit_assert=>assert_false( temp10 ).

  ENDMETHOD.

  METHOD event_empty_arg.

    DATA lo_event TYPE REF TO z2ui5_cl_core_srv_event.
    DATA temp9 TYPE string_table.
    DATA lv_event TYPE string.
    DATA temp11 TYPE xsdboolean.
    CREATE OBJECT lo_event TYPE z2ui5_cl_core_srv_event.

    CLEAR temp9.
    INSERT `` INTO TABLE temp9.
    INSERT `real` INTO TABLE temp9.

    lv_event = lo_event->get_event( val         = `EVT`
                                          t_arg = temp9 ).


    temp11 = boolc( lv_event CS `'real'` ).
    cl_abap_unit_assert=>assert_true( temp11 ).

  ENDMETHOD.

  METHOD event_multi_req.

    DATA lo_event TYPE REF TO z2ui5_cl_core_srv_event.
    DATA temp11 TYPE z2ui5_if_types=>ty_s_event_control.
    DATA lv_event TYPE string.
    DATA temp12 TYPE xsdboolean.
    CREATE OBJECT lo_event TYPE z2ui5_cl_core_srv_event.

    CLEAR temp11.
    temp11-check_allow_multi_req = abap_true.

    lv_event = lo_event->get_event( val         = `EVT`
                                          s_cnt = temp11 ).


    temp12 = boolc( lv_event CS `false,true` ).
    cl_abap_unit_assert=>assert_true( temp12 ).

  ENDMETHOD.

  METHOD event_client_args.

    DATA lo_event TYPE REF TO z2ui5_cl_core_srv_event.
    DATA temp12 TYPE string_table.
    DATA lv_event TYPE string.
    DATA temp13 TYPE xsdboolean.
    DATA temp14 TYPE xsdboolean.
    CREATE OBJECT lo_event TYPE z2ui5_cl_core_srv_event.

    CLEAR temp12.
    INSERT `param1` INTO TABLE temp12.

    lv_event = lo_event->get_event_client( val         = `CLOSE`
                                                 t_arg = temp12 ).


    temp13 = boolc( lv_event CS `CLOSE` ).
    cl_abap_unit_assert=>assert_true( temp13 ).

    temp14 = boolc( lv_event CS `'param1'` ).
    cl_abap_unit_assert=>assert_true( temp14 ).

  ENDMETHOD.

ENDCLASS.
