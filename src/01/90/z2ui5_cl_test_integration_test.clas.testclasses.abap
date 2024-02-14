CLASS ltcl_unit_test DEFINITION FINAL FOR TESTING
        DURATION SHORT
        RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS
      first_test FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.

  METHOD first_test.

*    DATA test TYPE  /ui2/cl_json=>bool ##NEEDED.
*    DATA test_const TYPE string VALUE /ui2/cl_json=>pretty_mode-extended ##NEEDED.

*    DATA text TYPE char10.
*    DATA text2 TYPE text100.
*    DATA text3 TYPE text10.
*    DATA text4 TYPE text10.
*
*    DATA stringtab TYPE stringtab.
*
*    DATA test1 TYPE text1.
*    DATA test2 TYPE text10.
*    DATA test3 TYPE text11.
*    DATA test4 TYPE text12.
*    DATA test5 TYPE text120.
*    DATA test6 TYPE text128.
*    DATA test7 TYPE text132.
*    DATA test8 TYPE text140.

  ENDMETHOD.

ENDCLASS.


*CLASS ltcl_integration_test DEFINITION FINAL FOR TESTING
*  DURATION LONG
*  RISK LEVEL HARMLESS.
*
*  PUBLIC SECTION.
*
*
*  PRIVATE SECTION.
*    METHODS test_index_html FOR TESTING RAISING cx_static_check.
*    METHODS test_xml_view      FOR TESTING RAISING cx_static_check.
*    METHODS test_id            FOR TESTING RAISING cx_static_check.
*    METHODS test_xml_popup     FOR TESTING RAISING cx_static_check.
*    METHODS test_bind_one_way  FOR TESTING RAISING cx_static_check.
*    METHODS test_bind_two_way  FOR TESTING RAISING cx_static_check.
*    METHODS test_message_toast FOR TESTING RAISING cx_static_check.
*    METHODS test_message_box   FOR TESTING RAISING cx_static_check.
*    METHODS test_landing_page  FOR TESTING RAISING cx_static_check.
*    METHODS test_scroll_cursor FOR TESTING RAISING cx_static_check.
*    METHODS test_navigate      FOR TESTING RAISING cx_static_check.
*    METHODS test_startup_path  FOR TESTING RAISING cx_static_check.
*
*    METHODS test_app_dump         FOR TESTING RAISING cx_static_check.
*
*ENDCLASS.
*
*
*CLASS ltcl_integration_test IMPLEMENTATION.
*
*  METHOD test_xml_view.
*    DATA lo_data TYPE REF TO data.
*    FIELD-SYMBOLS <val> TYPE any.
* "test
*    z2ui5_cl_test_integration_test=>sv_state = ``.
*    DATA(lv_response) = z2ui5_cl_fw_http_handler=>http_post(
*        `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_test_integration_test"}}` ).
*
*
*    /ui2/cl_json=>deserialize( EXPORTING json = lv_response
*                               CHANGING  data = lo_data ).
*
*
*    UNASSIGN <val>.
*    DATA(lv_assign) = `PARAMS->S_VIEW->XML->*`.
*    ASSIGN lo_data->(lv_assign) TO <val>.
*    <val> = shift_left( <val> ).
*    IF <val>(9) <> `<mvc:View`.
*      cl_abap_unit_assert=>fail( 'xml view - intital view wrong' ).
*    ENDIF.
*
*  ENDMETHOD.
*
*  METHOD test_index_html.
*
*    DATA(lv_index_html) = z2ui5_cl_fw_http_handler=>http_get( ).
*    IF lv_index_html IS INITIAL.
*      cl_abap_unit_assert=>fail( 'HTTP GET - index html initial' ).
*    ENDIF.
*
*  ENDMETHOD.
*
*
*  METHOD test_id.
*    DATA lo_data TYPE REF TO data.
*    FIELD-SYMBOLS <val> TYPE any.
*
*    z2ui5_cl_test_integration_test=>sv_state = ``.
*    DATA(lv_response) = z2ui5_cl_fw_http_handler=>http_post(
*      `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_test_integration_test"}}` ).
*
*
*    /ui2/cl_json=>deserialize( EXPORTING json = lv_response
*                               CHANGING  data = lo_data ).
*
*
*    UNASSIGN <val>.
*    DATA(lv_assign) = `ID->*`.
*    ASSIGN lo_data->(lv_assign) TO <val>.
*    IF <val> IS INITIAL.
*      cl_abap_unit_assert=>fail( msg  = 'id - initial value is initial'
*                                 quit = 5 ).
*    ENDIF.
*  ENDMETHOD.
*
*  METHOD test_bind_one_way.
*
*    DATA(lo_test) = NEW z2ui5_cl_test_integration_test( ) ##NEEDED.
*    DATA lo_data TYPE REF TO data.
*    FIELD-SYMBOLS <val> TYPE any.
*
*    z2ui5_cl_test_integration_test=>sv_state = `TEST_ONE_WAY`.
*    DATA(lv_response) = z2ui5_cl_fw_http_handler=>http_post(
*      `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_test_integration_test"}}` ).
*
*
*
*    /ui2/cl_json=>deserialize( EXPORTING json = lv_response
*                               CHANGING  data = lo_data ).
*
*
*    UNASSIGN <val>.
*    DATA(lv_assign) = `OVIEWMODEL->QUANTITY->*`.
*    ASSIGN lo_data->(lv_assign) TO <val>.
*    IF <val> <> `500`.
*      cl_abap_unit_assert=>fail( msg  = 'data binding - initial set EDIT wrong'
*                                 quit = 5 ).
*    ENDIF.
*  ENDMETHOD.
*
*  METHOD test_bind_two_way.
*    DATA lo_data TYPE REF TO data.
*    FIELD-SYMBOLS <val> TYPE any.
*
*    z2ui5_cl_test_integration_test=>sv_state = ``.
*    DATA(lv_response) = z2ui5_cl_fw_http_handler=>http_post(
*      `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_test_integration_test"}}` ).
*
*
*    /ui2/cl_json=>deserialize( EXPORTING json = lv_response
*                               CHANGING  data = lo_data ).
*
*
*    UNASSIGN <val>.
*    DATA(lv_assign) = `OVIEWMODEL->EDIT->QUANTITY->*`.
*    ASSIGN lo_data->(lv_assign) TO <val>.
*    IF <val> <> `500`.
*      cl_abap_unit_assert=>fail( msg  = 'data binding - initial set EDIT wrong'
*                                 quit = 5 ).
*    ENDIF.
*  ENDMETHOD.
*
*  METHOD test_message_box.
*    DATA lo_data TYPE REF TO data.
*    FIELD-SYMBOLS <val> TYPE any.
*
*    z2ui5_cl_test_integration_test=>sv_state = `TEST_MESSAGE_BOX`.
*    DATA(lv_response) = z2ui5_cl_fw_http_handler=>http_post(
*      `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_test_integration_test"}}` ).
*
*
*    /ui2/cl_json=>deserialize( EXPORTING json = lv_response
*                               CHANGING  data = lo_data ).
*
*
*
*    UNASSIGN <val>.
*    DATA(lv_assign) = `PARAMS->S_MSG_BOX->TEXT->*`.
*    ASSIGN lo_data->(lv_assign) TO <val>.
*    IF <val> <> `test message box`.
*      cl_abap_unit_assert=>fail( msg  = 'message box - text wrong'
*                                 quit = 5 ).
*    ENDIF.
*
*    UNASSIGN <val>.
*    lv_assign = `PARAMS->S_MSG_BOX->TYPE->*`.
*    ASSIGN lo_data->(lv_assign) TO <val>.
*    IF <val> <> `information`.
*      cl_abap_unit_assert=>fail( msg  = 'message box - type wrong'
*                                 quit = 5 ).
*    ENDIF.
*  ENDMETHOD.
*
*  METHOD test_message_toast.
*    DATA lo_data TYPE REF TO data.
*    FIELD-SYMBOLS <val> TYPE any.
*
*    z2ui5_cl_test_integration_test=>sv_state = `TEST_MESSAGE_TOAST`.
*    DATA(lv_response) = z2ui5_cl_fw_http_handler=>http_post(
*      `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_test_integration_test"}}` ).
*
*
*    /ui2/cl_json=>deserialize( EXPORTING json = lv_response
*                               CHANGING  data = lo_data ).
*
*
*
*    UNASSIGN <val>.
*    DATA(lv_assign) = `PARAMS->S_MSG_TOAST->TEXT->*`.
*    ASSIGN lo_data->(lv_assign) TO <val>.
*    IF <val> <> `test message toast`.
*      cl_abap_unit_assert=>fail( msg  = 'message toast - text wrong'
*                                 quit = 5 ).
*    ENDIF.
*
*  ENDMETHOD.
*
*
*  METHOD test_xml_popup.
*    DATA lo_data TYPE REF TO data.
*    FIELD-SYMBOLS <val> TYPE any.
*
*    z2ui5_cl_test_integration_test=>sv_state = `TEST_POPUP`.
*    DATA(lv_response) = z2ui5_cl_fw_http_handler=>http_post(
*      `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_test_integration_test"}}` ).
*
*
*    /ui2/cl_json=>deserialize( EXPORTING json = lv_response
*                               CHANGING  data = lo_data ).
*
*
*    UNASSIGN <val>.
*    DATA(lv_assign) = `PARAMS->S_POPUP->XML->*`.
*    ASSIGN lo_data->(lv_assign) TO <val>.
*    <val> = shift_left( <val> ).
*    IF <val>(9) <> `<mvc:View`.
*      cl_abap_unit_assert=>fail( msg  = 'xml popup - intital popup wrong'
*                                 quit = 5 ).
*    ENDIF.
*  ENDMETHOD.
*
*  METHOD test_landing_page.
*
*
*  ENDMETHOD.
*
*  METHOD test_scroll_cursor.
*    DATA lo_data TYPE REF TO data.
*
*    z2ui5_cl_test_integration_test=>sv_state = `TEST_SCROLL_CURSOR`.
*    DATA(lv_response) = z2ui5_cl_fw_http_handler=>http_post(
*      `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_test_integration_test"}}` ).
*
*
*    /ui2/cl_json=>deserialize( EXPORTING json = lv_response
*                               CHANGING  data = lo_data ).
*
*  ENDMETHOD.
*
*  METHOD test_startup_path.
*    DATA lo_data TYPE REF TO data.
*
*    z2ui5_cl_test_integration_test=>sv_state = `TEST_NAVIGATE`.
*    DATA(lv_response) = z2ui5_cl_fw_http_handler=>http_post(
*      `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_test_integration_test"}}` ).
*
*
*    /ui2/cl_json=>deserialize( EXPORTING json = lv_response
*                               CHANGING  data = lo_data ).
*
*  ENDMETHOD.
*
*  METHOD test_navigate.
*    DATA lo_data TYPE REF TO data.
*
*    z2ui5_cl_test_integration_test=>sv_state = `TEST_NAVIGATE`.
*    DATA(lv_response) = z2ui5_cl_fw_http_handler=>http_post(
*       `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_test_integration_test"}}` ).
*
*
*    /ui2/cl_json=>deserialize( EXPORTING json = lv_response
*                               CHANGING  data = lo_data ).
*
*  ENDMETHOD.
*
*
*  METHOD test_app_dump.
*
*    DATA lo_data TYPE REF TO data.
*    FIELD-SYMBOLS <val> TYPE any.
*
*    z2ui5_cl_test_integration_test=>sv_state = `ERROR`.
*    DATA(lv_response) = z2ui5_cl_fw_http_handler=>http_post( `{ "OLOCATION" : { "SEARCH" : "app_start=z2ui5_cl_test_integration_test"}}` ).
*
*
*    /ui2/cl_json=>deserialize(
*      EXPORTING
*         json = lv_response
*      CHANGING
*        data  = lo_data ).
*
*    UNASSIGN <val>.
*    ASSIGN (`LO_DATA->PARAMS->S_VIEW->XML->*`) TO <val>.
*    cl_abap_unit_assert=>assert_not_initial( <val> ).
*
*  ENDMETHOD.
*
*
*ENDCLASS.
