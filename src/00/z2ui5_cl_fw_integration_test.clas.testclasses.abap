CLASS ltcl_integration_test DEFINITION FINAL FOR TESTING
  DURATION LONG
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.


  PRIVATE SECTION.
    METHODS test_index_html FOR TESTING RAISING cx_static_check.
    METHODS test_xml_view      FOR TESTING RAISING cx_static_check.
    METHODS test_id            FOR TESTING RAISING cx_static_check.
    METHODS test_xml_popup     FOR TESTING RAISING cx_static_check.
    METHODS test_bind_one_way  FOR TESTING RAISING cx_static_check.
    METHODS test_bind_two_way  FOR TESTING RAISING cx_static_check.
    METHODS test_message_toast FOR TESTING RAISING cx_static_check.
    METHODS test_message_box   FOR TESTING RAISING cx_static_check.
    METHODS test_timer         FOR TESTING RAISING cx_static_check.
    METHODS test_landing_page  FOR TESTING RAISING cx_static_check.
    METHODS test_scroll_cursor FOR TESTING RAISING cx_static_check.
    METHODS test_navigate      FOR TESTING RAISING cx_static_check.
    METHODS test_startup_path  FOR TESTING RAISING cx_static_check.

    METHODS test_app_change_value FOR TESTING RAISING cx_static_check.
    METHODS test_app_event        FOR TESTING RAISING cx_static_check.
    METHODS test_app_dump         FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_integration_test IMPLEMENTATION.

  METHOD test_xml_view.

    z2ui5_cl_fw_integration_test=>sv_state = ``.
    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(
        `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_fw_integration_test"}}` ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                               CHANGING  data = lo_data ).

    FIELD-SYMBOLS <val> TYPE any.
    UNASSIGN <val>.
    DATA(lv_assign) = `PARAMS->S_VIEW->XML->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    <val> = shift_left( <val> ).
    IF <val>(9) <> `<mvc:View`.
      cl_abap_unit_assert=>fail( msg  = 'xml view - intital view wrong' ).
    ENDIF.

  ENDMETHOD.

  METHOD test_index_html.

    DATA(lv_index_html) = z2ui5_cl_http_handler=>http_get( ).
    IF lv_index_html IS INITIAL.
      cl_abap_unit_assert=>fail( 'HTTP GET - index html initial' ).
    ENDIF.

  ENDMETHOD.


  METHOD test_id.

    z2ui5_cl_fw_integration_test=>sv_state = ``.
    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(
      `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_fw_integration_test"}}` ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                               CHANGING  data = lo_data ).

    FIELD-SYMBOLS <val> TYPE any.
    UNASSIGN <val>.
    DATA(lv_assign) = `ID->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    IF <val> IS INITIAL.
      cl_abap_unit_assert=>fail( msg  = 'id - initial value is initial'
                                 quit = 5 ).
    ENDIF.
  ENDMETHOD.

  METHOD test_bind_one_way.

    DATA(lo_test) = NEW z2ui5_cl_fw_integration_test( ) ##NEEDED.

    z2ui5_cl_fw_integration_test=>sv_state = `TEST_ONE_WAY`.
    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(
      `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_fw_integration_test"}}` ).


    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                               CHANGING  data = lo_data ).

    FIELD-SYMBOLS <val> TYPE any.
    UNASSIGN <val>.
    DATA(lv_assign) = `OVIEWMODEL->QUANTITY->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    IF <val> <> `500`.
      cl_abap_unit_assert=>fail( msg  = 'data binding - initial set oUpdate wrong'
                                 quit = 5 ).
    ENDIF.
  ENDMETHOD.

  METHOD test_bind_two_way.

    z2ui5_cl_fw_integration_test=>sv_state = ``.
    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(
      `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_fw_integration_test"}}` ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                               CHANGING  data = lo_data ).

    FIELD-SYMBOLS <val> TYPE any.
    UNASSIGN <val>.
    DATA(lv_assign) = `OVIEWMODEL->OUPDATE->QUANTITY->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    IF <val> <> `500`.
      cl_abap_unit_assert=>fail( msg  = 'data binding - initial set oUpdate wrong'
                                 quit = 5 ).
    ENDIF.
  ENDMETHOD.

  METHOD test_message_box.

    z2ui5_cl_fw_integration_test=>sv_state = `TEST_MESSAGE_BOX`.
    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(
      `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_fw_integration_test"}}` ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                               CHANGING  data = lo_data ).

    FIELD-SYMBOLS <val> TYPE any.

    UNASSIGN <val>.
    DATA(lv_assign) = `PARAMS->S_MSG_BOX->TEXT->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    IF <val> <> `test message box`.
      cl_abap_unit_assert=>fail( msg  = 'message box - text wrong'
                                 quit = 5 ).
    ENDIF.

    UNASSIGN <val>.
    lv_assign = `PARAMS->S_MSG_BOX->TYPE->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    IF <val> <> `information`.
      cl_abap_unit_assert=>fail( msg  = 'message box - type wrong'
                                 quit = 5 ).
    ENDIF.
  ENDMETHOD.

  METHOD test_message_toast.

    z2ui5_cl_fw_integration_test=>sv_state = `TEST_MESSAGE_TOAST`.
    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(
      `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_fw_integration_test"}}` ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                               CHANGING  data = lo_data ).

    FIELD-SYMBOLS <val> TYPE any.

    UNASSIGN <val>.
    DATA(lv_assign) = `PARAMS->S_MSG_TOAST->TEXT->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    IF <val> <> `test message toast`.
      cl_abap_unit_assert=>fail( msg  = 'message toast - text wrong'
                                 quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_timer.

    z2ui5_cl_fw_integration_test=>sv_state = `TEST_TIMER`.
    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(
      `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_fw_integration_test"}}` ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                               CHANGING  data = lo_data ).

    FIELD-SYMBOLS <val> TYPE any.

    UNASSIGN <val>.
    DATA(lv_assign) = `PARAMS->S_TIMER->EVENT_FINISHED->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    IF <val> <> `TIMER_FINISHED`.
      cl_abap_unit_assert=>fail( msg  = 'timer - event wrong'
                                 quit = 5 ).
    ENDIF.

    UNASSIGN <val>.
    lv_assign = `PARAMS->S_TIMER->INTERVAL_MS->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    IF <val> <> `500`.
      cl_abap_unit_assert=>fail( msg  = 'timer - ms wrong'
                                 quit = 5 ).
    ENDIF.
  ENDMETHOD.

  METHOD test_xml_popup.

    z2ui5_cl_fw_integration_test=>sv_state = `TEST_POPUP`.
    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(
      `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_fw_integration_test"}}` ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                               CHANGING  data = lo_data ).

    FIELD-SYMBOLS <val> TYPE any.
    UNASSIGN <val>.
    DATA(lv_assign) = `PARAMS->S_POPUP->XML->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    <val> = shift_left( <val> ).
    IF <val>(9) <> `<mvc:View`.
      cl_abap_unit_assert=>fail( msg  = 'xml popup - intital popup wrong'
                                 quit = 5 ).
    ENDIF.
  ENDMETHOD.

  METHOD test_landing_page.

    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(
       `{ "OLOCATION" : { "SEARCH" : ""}}` ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                               CHANGING  data = lo_data ).

    FIELD-SYMBOLS <val> TYPE any.
    UNASSIGN <val>.
    DATA(lv_assign) = `PARAMS->S_VIEW->XML->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    <val> = shift_left( <val> ).
    IF <val> NS `Step 4`.
      cl_abap_unit_assert=>fail( msg  = 'landing page - not started when no app'
                                 quit = 5 ).
    ENDIF.
  ENDMETHOD.

  METHOD test_scroll_cursor.

    z2ui5_cl_fw_integration_test=>sv_state = `TEST_SCROLL_CURSOR`.
    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(
      `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_fw_integration_test"}}` ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                               CHANGING  data = lo_data ).

  ENDMETHOD.

  METHOD test_startup_path.

    z2ui5_cl_fw_integration_test=>sv_state = `TEST_NAVIGATE`.
    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(
      `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_fw_integration_test"}}` ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                               CHANGING  data = lo_data ).

  ENDMETHOD.

  METHOD test_navigate.

    z2ui5_cl_fw_integration_test=>sv_state = `TEST_NAVIGATE`.
    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(
       `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_fw_integration_test"}}` ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                               CHANGING  data = lo_data ).

  ENDMETHOD.


  METHOD test_app_change_value.

    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(  `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_fw_integration_test"}}` ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize(
      EXPORTING
         json            = lv_response
      CHANGING
        data             = lo_data ).

    FIELD-SYMBOLS <val> TYPE any.

    UNASSIGN <val>.
    DATA(lv_assign) = `ID->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    IF <val> IS INITIAL.
      cl_abap_unit_assert=>fail( msg = 'id - initial value is initial' quit = 5 ).
    ENDIF.
    DATA(lv_id) = CONV string( <val> ).

    DATA(lv_request) = `{"oUpdate":{"QUANTITY":"600"},"ID": "` && lv_id && `" ,"ARGUMENTS":[{"EVENT":"BUTTON_POST","METHOD":"UPDATE"}]}`.
    lv_response = z2ui5_cl_http_handler=>http_post( lv_request ).

    CLEAR lo_data.
    /ui2/cl_json=>deserialize(
      EXPORTING
         json            = lv_response
      CHANGING
        data             = lo_data ).

    UNASSIGN <val>.
    lv_assign = `OVIEWMODEL->OUPDATE->QUANTITY->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    IF <val> <> `600`.
      cl_abap_unit_assert=>fail( msg = 'data binding - frontend updated value wrong after roundtrip' quit = 5 ).
    ENDIF.


  ENDMETHOD.

  METHOD test_app_event.

    z2ui5_cl_fw_integration_test=>sv_state = ``.
    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(  `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_fw_integration_test"}}` ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize(
      EXPORTING
         json            = lv_response
      CHANGING
        data             = lo_data ).

    FIELD-SYMBOLS <val> TYPE any.

    UNASSIGN <val>.
    DATA(lv_assign) = `ID->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    cl_abap_unit_assert=>assert_not_initial( <val> ).


    DATA(lv_id) = CONV string( <val> ).
    DATA(lv_request) = `{"oUpdate":{"QUANTITY":"700"},"ID": "` && lv_id && `" ,"ARGUMENTS": [{"EVENT":"BUTTON_POST","METHOD":"UPDATE"}]}`.
    lv_response = z2ui5_cl_http_handler=>http_post( lv_request ).

    CLEAR lo_data.
    /ui2/cl_json=>deserialize(
      EXPORTING
         json            = lv_response
      CHANGING
        data             = lo_data ).

    UNASSIGN <val>.
    lv_assign = `PARAMS->S_MSG_TOAST->TEXT->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    cl_abap_unit_assert=>assert_equals(
        act                  = <val>
        exp                  = `tomato 700 - send to the server` ).

  ENDMETHOD.

  METHOD test_app_dump.

    z2ui5_cl_fw_integration_test=>sv_state = `ERROR`.
    DATA(lv_response) = z2ui5_cl_http_handler=>http_post( `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_fw_integration_test"}}` ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize(
      EXPORTING
         json            = lv_response
      CHANGING
        data             = lo_data ).

    FIELD-SYMBOLS <val> TYPE any.
    DATA lv_text TYPE string.
    UNASSIGN <val>.
    ASSIGN (`LO_DATA->PARAMS->S_VIEW->XML->*`) TO <val>.
*    lv_text = <val>.
*    lv_text = shift_left( lv_text ).
*    IF lv_text NS `An exception with the type CX_SY_ZERODIVIDE was raised`.
*      cl_abap_unit_assert=>fail( msg = 'system app error - not shown by exception' quit = 5 ).
*    ENDIF.

  ENDMETHOD.


ENDCLASS.
