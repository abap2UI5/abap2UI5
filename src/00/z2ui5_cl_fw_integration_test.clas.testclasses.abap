CLASS ltcl_unit_02_app_start DEFINITION FINAL FOR TESTING
  DURATION SHORT
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

ENDCLASS.


CLASS ltcl_unit_02_app_start IMPLEMENTATION.

  METHOD test_xml_view.

    z2ui5_cl_fw_integration_test=>sv_state = ``.
    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(
        body = `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_fw_integration_test"}}`
    ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                               CHANGING  data = lo_data ).

    FIELD-SYMBOLS <val> TYPE any.
    UNASSIGN <val>.
    DATA(lv_assign) = `PARAMS->S_VIEW->XML->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    <val> = shift_left( <val> ).
    IF <val>(9) <> `<mvc:View`.
      cl_abap_unit_assert=>fail( msg  = 'xml view - intital view wrong'
                                 quit = 5 ).
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
      body = `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_fw_integration_test"}}`
    ).

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


    DATA(lo_test) = NEW z2ui5_cl_fw_integration_test( ).
*    DATA(lv_classname) = z2ui5_cl_fw_utility=>get_classname_by_ref( lo_test ).


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
ENDCLASS.


CLASS ltcl_unit_03_app_ajax DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA product           TYPE string.
    DATA quantity          TYPE string.
    DATA check_initialized TYPE abap_bool.

    CLASS-DATA sv_state TYPE string.

  PRIVATE SECTION.
    METHODS test_app_change_value FOR TESTING RAISING cx_static_check.
    METHODS test_app_event        FOR TESTING RAISING cx_static_check.
    METHODS test_app_dump         FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_unit_03_app_ajax IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    IF check_initialized = abap_false.
      check_initialized = abap_true.
      product  = 'tomato'.
      quantity = '500'.

    ENDIF.

    CASE client->get( )-event.
      WHEN 'BUTTON_POST'.
        client->message_toast_display( |{ product } { quantity } - send to the server| ).
      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).
    ENDCASE.

    IF sv_state = 'ERROR'.
      z2ui5_cl_fw_utility=>raise( `exception test` ).
    ENDIF.

    client->view_display( z2ui5_cl_xml_view=>factory( client )->shell(
        )->page( title          = 'abap2UI5 - First Example'
                 navbuttonpress = client->_event( 'BACK' )
                 shownavbutton  = abap_true
            )->simple_form( title    = 'Form Title'
                            editable = abap_true
                )->content( 'form'
                    )->title( 'Input'
                    )->label( 'quantity'
                    )->input( client->_bind( quantity )
                    )->label( 'product'
                    )->input( value   = product
                              enabled = abap_false
                    )->button( text  = 'post'
                               press = client->_event( 'BUTTON_POST' )
         )->get_root( )->xml_get( ) ).

  ENDMETHOD.

  METHOD test_app_change_value.

*    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(
*       `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_fw_integration_test"}}` ).
*
*    DATA lo_data TYPE REF TO data.
*    /ui2/cl_json=>deserialize( EXPORTING json = lv_response
*                               CHANGING  data = lo_data ).
*
*    FIELD-SYMBOLS <val> TYPE any.
*
*    UNASSIGN <val>.
*    DATA(lv_assign) = `ID->*`.
*    ASSIGN lo_data->(lv_assign) TO <val>.
*    IF <val> IS INITIAL.
*      cl_abap_unit_assert=>fail( msg  = 'id - initial value is initial'
*                                 quit = 5 ).
*    ENDIF.
*    DATA(lv_id) = CONV string( <val> ).
*
*    DATA(lv_request) = `{"oUpdate":{"QUANTITY":"600"},"ID": "` && lv_id && `" ,"ARGUMENTS":[{"EVENT":"BUTTON_POST","METHOD":"UPDATE"}] }`.
*    lv_response = z2ui5_cl_http_handler=>http_post(
*          lv_request ).
*
*    CLEAR lo_data.
*    /ui2/cl_json=>deserialize( EXPORTING json = lv_response
*                               CHANGING  data = lo_data ).
*
*    UNASSIGN <val>.
*    lv_assign = `OVIEWMODEL->OUPDATE->QUANTITY->*`.
*    ASSIGN lo_data->(lv_assign) TO <val>.
*    IF <val> <> `600`.
*      cl_abap_unit_assert=>fail( msg  = 'data binding - frontend updated value wrong after roundtrip'
*                                 quit = 5 ).
*    ENDIF.
  ENDMETHOD.

  METHOD test_app_event.


  ENDMETHOD.

  METHOD test_app_dump.


  ENDMETHOD.

ENDCLASS.
