CLASS ltcl_unit_01_json DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.

  PRIVATE SECTION.
    METHODS test_json_attri     FOR TESTING RAISING cx_static_check.
    METHODS test_json_object    FOR TESTING RAISING cx_static_check.
    METHODS test_json_struc     FOR TESTING RAISING cx_static_check.
    METHODS test_json_trans     FOR TESTING RAISING cx_static_check.
    METHODS test_json_trans_gen FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_unit_01_json IMPLEMENTATION.

  METHOD test_json_attri.

    DATA(lo_tree) = NEW z2ui5_lcl_utility_tree_json( ).

    lo_tree->add_attribute( n = `AAA` v = `BBB` ).

    DATA(lv_result) = lo_tree->stringify( ).
    IF `{"AAA":"BBB"}` <> lv_result.
      cl_abap_unit_assert=>fail( 'json tree - wrong stringify attributes' ).
    ENDIF.

  ENDMETHOD.

  METHOD test_json_object.

    DATA(lo_tree) = NEW z2ui5_lcl_utility_tree_json( ).

    lo_tree->add_attribute_object( `CCC`
         )->add_attribute( n = `AAA` v = `BBB` ).

    DATA(lv_result) = lo_tree->stringify( ).
    IF `{"CCC":{"AAA":"BBB"}}` <> lv_result.
      cl_abap_unit_assert=>fail( 'json tree - wrong stringify object attributes' ).
    ENDIF.

  ENDMETHOD.

  METHOD test_json_struc.

    DATA(lo_tree) = NEW z2ui5_lcl_utility_tree_json( ).

    TYPES:
      BEGIN OF ty_s_test,
        comp1 TYPE string,
        comp2 TYPE string,
      END OF ty_s_test.

    DATA(ls_test) = VALUE ty_S_test( comp1 = `AAA` comp2 = `BBB` ).

    lo_tree->add_attribute_object( `CCC`
        )->add_attribute_struc( ls_test ).

    DATA(lv_result) = lo_tree->stringify( ).
    IF `{"CCC":{"COMP1":"AAA","COMP2":"BBB"}}` <> lv_result.
      cl_abap_unit_assert=>fail( 'json tree - wrong stringify structure' ).
    ENDIF.

  ENDMETHOD.

  METHOD test_json_trans.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        selected TYPE abap_bool,
      END OF ty_row.
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    DATA(lt_tab) = VALUE ty_t_tab(
         ( title = 'Test'  value = 'this is a description' selected = abap_true  )
         ( title = 'Test2' value = 'this is a new descr'   selected = abap_false )
     ).

    DATA(lt_tab2) = VALUE ty_t_tab( ).

    DATA(lv_tab) = z2ui5_lcl_utility=>trans_any_2_json( lt_tab ).

    /ui2/cl_json=>deserialize(
      EXPORTING
        json             = lv_tab
      CHANGING
        data             = lt_tab2
    ).

    IF lt_tab <> lt_tab2.
      cl_abap_unit_assert=>fail( msg = 'json serial -  /ui2/cl_json wrong simple table' quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_json_trans_gen.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        selected TYPE abap_bool,
      END OF ty_row.
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    DATA(lt_tab) = VALUE ty_t_tab(
         ( title = 'Test'  value = 'this is a description' selected = abap_true  )
         ( title = 'Test2' value = 'this is a new descr'   selected = abap_false )
     ).

    DATA(lt_tab2) = VALUE ty_t_tab( ).

    DATA(lv_tab) = z2ui5_lcl_utility=>trans_any_2_json( lt_tab ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize(
      EXPORTING
        json             = lv_tab
      CHANGING
        data             = lo_data
    ).

    z2ui5_lcl_utility=>trans_ref_tab_2_tab(
      EXPORTING
        ir_tab_from = lo_data
      IMPORTING
        t_result    = lt_tab2
    ).

    IF lt_tab <> lt_tab2.
      cl_abap_unit_assert=>fail( msg = 'json serial -  /ui2/cl_json wrong generic table' quit = 5 ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_unit_02_app_start DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA product  TYPE string.
    DATA quantity TYPE string.
    DATA check_initialized TYPE abap_bool.

    CLASS-DATA sv_state TYPE string.

  PRIVATE SECTION.
    METHODS test_index_html       FOR TESTING RAISING cx_static_check.
    METHODS test_xml_view         FOR TESTING RAISING cx_static_check.
    METHODS test_id               FOR TESTING RAISING cx_static_check.
    METHODS test_xml_popup        FOR TESTING RAISING cx_static_check.
    METHODS test_bind_one_way     FOR TESTING RAISING cx_static_check.
    METHODS test_bind_two_way     FOR TESTING RAISING cx_static_check.
    METHODS test_message_toast    FOR TESTING RAISING cx_static_check.
    METHODS test_message_box      FOR TESTING RAISING cx_static_check.
    METHODS test_timer            FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_unit_02_app_start IMPLEMENTATION.

  METHOD test_index_html.

    z2ui5_cl_http_handler=>client = VALUE #(
       t_header = VALUE #( ( name = '~path' value = 'dummy' ) )
       ).

    DATA(lv_index_html) = z2ui5_cl_http_handler=>http_get(  ).

    IF lv_index_html IS INITIAL.
      cl_abap_unit_assert=>fail( 'HTTP GET - index html initial' ).
    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      product  = 'tomato'.
      quantity = '500'.

    ENDIF.

    CASE client->get( )-event.
      WHEN 'BUTTON_POST'.
        client->popup_message_toast( |{ product } { quantity } - send to the server| ).
      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack  ) ).
    ENDCASE.

    IF sv_state = 'TEST_MESSAGE_BOX'.
      client->popup_message_box(
        text = 'test message box'
      ).
    ENDIF.

    IF sv_state = 'TEST_MESSAGE_TOAST'.
      client->popup_message_toast(
        text = 'test message toast'
      ).
    ENDIF.

    CASE sv_state.

      WHEN 'TEST_ONE_WAY'.
        client->set_next( VALUE #( xml_main = z2ui5_cl_xml_view=>factory( )->shell(
            )->page(
                    title          = 'abap2UI5 - First Example'
                    navbuttonpress = client->_event( 'BACK' )
                    shownavbutton  = abap_true
                )->simple_form( title = 'Form Title' editable = abap_true
                    )->content( 'form'
                        )->title( 'Input'
                        )->label( 'quantity'
                        )->input( client->_bind_one( quantity )
                        )->label( 'product'
                        )->input(
                            value   = product
                            enabled = abap_false
                        )->button(
                            text  = 'post'
                            press = client->_event( 'BUTTON_POST' )
             )->get_root( )->xml_get( ) ) ).

      WHEN 'TEST_POPUP'.
        client->set_next( VALUE #( xml_popup = z2ui5_cl_xml_view=>factory(
            )->dialog(
                    title          = 'abap2UI5 - First Example'
                )->simple_form( title = 'Form Title' editable = abap_true
                    )->content( 'form'
                        )->title( 'Input'
                        )->label( 'quantity'
                        )->input( client->_bind_one( quantity )
                        )->label( 'product'
                        )->input(
                            value   = product
                            enabled = abap_false
                        )->button(
                            text  = 'post'
                            press = client->_event( 'BUTTON_POST' )
             )->get_root( )->xml_get( ) ) ).

      WHEN 'TEST_TIMER'.
        client->set_next( VALUE #(
           s_timer = VALUE #(
              event_finished = 'TIMER_FINISHED'
              interval_ms    =  `500`
           )
           xml_main = z2ui5_cl_xml_view=>factory( )->shell(
           )->page(
                   title          = 'abap2UI5 - First Example'
                   navbuttonpress = client->_event( 'BACK' )
                   shownavbutton  = abap_true
               )->simple_form( title = 'Form Title' editable = abap_true
                   )->content( 'form'
                       )->title( 'Input'
                       )->label( 'quantity'
                       )->input( client->_bind( quantity )
                       )->label( 'product'
                       )->input(
                           value   = product
                           enabled = abap_false
                       )->button(
                           text  = 'post'
                           press = client->_event( 'BUTTON_POST' )
            )->get_root( )->xml_get( ) ) ).

      WHEN OTHERS.
        client->set_next( VALUE #( xml_main = z2ui5_cl_xml_view=>factory( )->shell(
            )->page(
                    title          = 'abap2UI5 - First Example'
                    navbuttonpress = client->_event( 'BACK' )
                    shownavbutton  = abap_true
                )->simple_form( title = 'Form Title' editable = abap_true
                    )->content( 'form'
                        )->title( 'Input'
                        )->label( 'quantity'
                        )->input( client->_bind( quantity )
                        )->label( 'product'
                        )->input(
                            value   = product
                            enabled = abap_false
                        )->button(
                            text  = 'post'
                            press = client->_event( 'BUTTON_POST' )
             )->get_root( )->xml_get( ) ) ).

    ENDCASE.

  ENDMETHOD.

  METHOD test_xml_view.

    z2ui5_cl_http_handler=>client = VALUE #(
       t_param = VALUE #( ( name = 'app' value = 'LTCL_UNIT_02_APP_START' ) )
       ).

    sv_state = ``.
    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(  ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize(
      EXPORTING
         json            = lv_response
      CHANGING
        data             = lo_data ).

    FIELD-SYMBOLS <val> TYPE any.
    UNASSIGN <val>.
    DATA(lv_assign) = `VVIEW->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    <val> = shift_left( <val> ).
    IF <val>(9) <> `<mvc:View`.
      cl_abap_unit_assert=>fail( msg = 'xml view - intital view wrong' quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_id.

    z2ui5_cl_http_handler=>client = VALUE #(
       t_param = VALUE #( ( name = 'app' value = 'LTCL_UNIT_02_APP_START' ) )
       ).

    sv_state = ``.
    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(  ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize(
      EXPORTING
         json            = lv_response
      CHANGING
        data             = lo_data ).

    FIELD-SYMBOLS <val> TYPE any.
    UNASSIGN <val>.
    DATA(lv_assign) = `OSYSTEM->ID->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    IF <val> IS INITIAL.
      cl_abap_unit_assert=>fail( msg = 'id - initial value is initial' quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_bind_one_way.

    z2ui5_cl_http_handler=>client = VALUE #(
         t_param = VALUE #( ( name = 'app' value = 'LTCL_UNIT_02_APP_START' ) )
         ).

    sv_state = `TEST_ONE_WAY`.
    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(  ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize(
      EXPORTING
         json            = lv_response
      CHANGING
        data             = lo_data ).

    FIELD-SYMBOLS <val> TYPE any.
    UNASSIGN <val>.
    DATA(lv_assign) = `OVIEWMODEL->QUANTITY->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    IF <val> <> `500`.
      cl_abap_unit_assert=>fail( msg = 'data binding - initial set oUpdate wrong' quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_bind_two_way.

    z2ui5_cl_http_handler=>client = VALUE #(
         t_param = VALUE #( ( name = 'app' value = 'LTCL_UNIT_02_APP_START' ) )
         ).

    sv_state = ``.
    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(  ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize(
      EXPORTING
         json            = lv_response
      CHANGING
        data             = lo_data ).

    FIELD-SYMBOLS <val> TYPE any.
    UNASSIGN <val>.
    DATA(lv_assign) = `OVIEWMODEL->OUPDATE->QUANTITY->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    IF <val> <> `500`.
      cl_abap_unit_assert=>fail( msg = 'data binding - initial set oUpdate wrong' quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_message_box.

    z2ui5_cl_http_handler=>client = VALUE #(
       t_param = VALUE #( ( name = 'app' value = 'LTCL_UNIT_02_APP_START' ) )
       ).

    sv_state = `TEST_MESSAGE_BOX`.
    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(  ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize(
      EXPORTING
         json            = lv_response
      CHANGING
        data             = lo_data ).

    FIELD-SYMBOLS <val> TYPE any.

    UNASSIGN <val>.
    DATA(lv_assign) = `OMESSAGE->CONTROL->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    IF <val> <> `MessageBox`.
      cl_abap_unit_assert=>fail( msg = 'message box - control wrong' quit = 5 ).
    ENDIF.

    UNASSIGN <val>.
    lv_assign = `OMESSAGE->TEXT->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    IF <val> <> `test message box`.
      cl_abap_unit_assert=>fail( msg = 'message box - text wrong' quit = 5 ).
    ENDIF.

    UNASSIGN <val>.
    lv_assign = `OMESSAGE->TYPE->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    IF <val> <> `information`.
      cl_abap_unit_assert=>fail( msg = 'message box - type wrong' quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_message_toast.

    z2ui5_cl_http_handler=>client = VALUE #(
         t_param = VALUE #( ( name = 'app' value = 'LTCL_UNIT_02_APP_START' ) )
         ).

    sv_state = `TEST_MESSAGE_TOAST`.
    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(  ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize(
      EXPORTING
         json            = lv_response
      CHANGING
        data             = lo_data ).

    FIELD-SYMBOLS <val> TYPE any.

    UNASSIGN <val>.
    DATA(lv_assign) = `OMESSAGE->CONTROL->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    IF <val> <> `MessageToast`.
      cl_abap_unit_assert=>fail( msg = 'message toast - control wrong' quit = 5 ).
    ENDIF.

    UNASSIGN <val>.
    lv_assign = `OMESSAGE->TEXT->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    IF <val> <> `test message toast`.
      cl_abap_unit_assert=>fail( msg = 'message toast - text wrong' quit = 5 ).
    ENDIF.

    UNASSIGN <val>.
    lv_assign = `OMESSAGE->TYPE->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    IF <val> <> `show`.
      cl_abap_unit_assert=>fail( msg = 'message toast - type wrong' quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_timer.

    z2ui5_cl_http_handler=>client = VALUE #(
        t_param = VALUE #( ( name = 'app' value = 'LTCL_UNIT_02_APP_START' ) )
        ).

    sv_state = `TEST_TIMER`.
    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(  ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize(
      EXPORTING
         json            = lv_response
      CHANGING
        data             = lo_data ).

    FIELD-SYMBOLS <val> TYPE any.

    UNASSIGN <val>.
    DATA(lv_assign) = `OTIMER->EVENT_FINISHED->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    IF <val> <> `TIMER_FINISHED`.
      cl_abap_unit_assert=>fail( msg = 'timer - event wrong' quit = 5 ).
    ENDIF.

    UNASSIGN <val>.
    lv_assign = `OTIMER->INTERVAL_MS->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    IF <val> <> `500`.
      cl_abap_unit_assert=>fail( msg = 'timer - ms wrong' quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_xml_popup.

    z2ui5_cl_http_handler=>client = VALUE #(
       t_param = VALUE #( ( name = 'app' value = 'LTCL_UNIT_02_APP_START' ) )
       ).

    sv_state = `TEST_POPUP`.
    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(  ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize(
      EXPORTING
         json            = lv_response
      CHANGING
        data             = lo_data ).

    FIELD-SYMBOLS <val> TYPE any.
    UNASSIGN <val>.
    DATA(lv_assign) = `VVIEWPOPUP->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    <val> = shift_left( <val> ).
    IF <val>(9) <> `<mvc:View`.
      cl_abap_unit_assert=>fail( msg = 'xml popup - intital popup wrong' quit = 5 ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_unit_03_app_ajax DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA product  TYPE string.
    DATA quantity TYPE string.
    DATA check_initialized TYPE abap_bool.

  PRIVATE SECTION.
    METHODS test_app_change_value FOR TESTING RAISING cx_static_check.
    METHODS test_app_event        FOR TESTING RAISING cx_static_check.

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
        client->popup_message_toast( |{ product } { quantity } - send to the server| ).
      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack  ) ).
    ENDCASE.

    client->set_next( VALUE #( xml_main = z2ui5_cl_xml_view=>factory( )->shell(
        )->page(
                title          = 'abap2UI5 - First Example'
                navbuttonpress = client->_event( 'BACK' )
                shownavbutton  = abap_true
            )->simple_form( title = 'Form Title' editable = abap_true
                )->content( 'form'
                    )->title( 'Input'
                    )->label( 'quantity'
                    )->input( client->_bind( quantity )
                    )->label( 'product'
                    )->input(
                        value   = product
                        enabled = abap_false
                    )->button(
                        text  = 'post'
                        press = client->_event( 'BUTTON_POST' )
         )->get_root( )->xml_get( ) ) ).

  ENDMETHOD.

  METHOD test_app_change_value.

    z2ui5_cl_http_handler=>client = VALUE #(
       t_param = VALUE #( ( name = 'app' value = 'LTCL_UNIT_02_APP_START' ) )
       ).

    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(  ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize(
      EXPORTING
         json            = lv_response
      CHANGING
        data             = lo_data ).

    FIELD-SYMBOLS <val> TYPE any.

    UNASSIGN <val>.
    DATA(lv_assign) = `OSYSTEM->ID->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    IF <val> IS INITIAL.
      cl_abap_unit_assert=>fail( msg = 'id - initial value is initial' quit = 5 ).
    ENDIF.
    DATA(lv_id) = CONV string( <val> ).

    DATA(lv_request) = `{"oUpdate":{"QUANTITY":"600"},"oSystem":{"ID": "` && lv_id && `"` &&  `,"CHECK_DEBUG_ACTIVE":true},"oEvent":{"EVENT":"BUTTON_POST","METHOD":"UPDATE"}}`.
    z2ui5_cl_http_handler=>client = VALUE #( body = lv_request ).
    lv_response = z2ui5_cl_http_handler=>http_post(  ).

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

    z2ui5_cl_http_handler=>client = VALUE #(
       t_param = VALUE #( ( name = 'app' value = 'LTCL_UNIT_02_APP_START' ) )
       ).

    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(  ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize(
      EXPORTING
         json            = lv_response
      CHANGING
        data             = lo_data ).

    FIELD-SYMBOLS <val> TYPE any.

    UNASSIGN <val>.
    DATA(lv_assign) = `OSYSTEM->ID->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    IF <val> IS INITIAL.
      cl_abap_unit_assert=>fail( msg = 'id - initial value is initial' quit = 5 ).
    ENDIF.
    DATA(lv_id) = CONV string( <val> ).

    DATA(lv_request) = `{"oUpdate":{"QUANTITY":"700"},"oSystem":{"ID": "` && lv_id && `"},"oEvent":{"EVENT":"BUTTON_POST","METHOD":"UPDATE"}}`.
    z2ui5_cl_http_handler=>client = VALUE #( body = lv_request ).
    lv_response = z2ui5_cl_http_handler=>http_post(  ).

    clear lo_data.
    /ui2/cl_json=>deserialize(
      EXPORTING
         json            = lv_response
      CHANGING
        data             = lo_data ).

    UNASSIGN <val>.
    lv_assign = `OMESSAGE->TEXT->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    IF <val> <> `tomato 700 - send to the server`.
      cl_abap_unit_assert=>fail( msg = 'message toast - text wrong' quit = 5 ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_unit_04_deep_data DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA check_initialized TYPE abap_bool.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        descr    TYPE string,
        icon     TYPE string,
        info     TYPE string,
        selected TYPE abap_bool,
        checkbox TYPE abap_bool,
      END OF ty_row.

    DATA t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

  PRIVATE SECTION.
    METHODS test_app_deep_data FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_unit_04_deep_data IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    IF check_initialized = abap_false.
      check_initialized = abap_true.

      t_tab = VALUE #(
            ( title = 'Peter'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
            ( title = 'Peter'  info = 'incompleted' descr = 'this is a description' icon = 'sap-icon://account' )
        ).

    ENDIF.

    client->set_next( VALUE #( xml_main = z2ui5_cl_xml_view=>factory( )->shell(
        )->page(
                title          = 'abap2UI5 - First Example'
                navbuttonpress = client->_event( 'BACK' )
                shownavbutton  = abap_true
        )->list(
            headertext      = 'List Ouput'
            items           = client->_bind_one( t_tab )
            mode            = `SingleSelectMaster`
            selectionchange = client->_event( 'SELCHANGE' )
        )->standard_list_item(
            title       = '{TITLE}'
            description = '{DESCR}'
            icon        = '{ICON}'
            info        = '{INFO}'
            press       = client->_event( 'TEST' )
            type        = `Navigation`
            selected    = `{SELECTED}`
         )->get_root( )->xml_get( ) ) ).


  ENDMETHOD.

  METHOD test_app_deep_data.

    z2ui5_cl_http_handler=>client = VALUE #(
       t_param = VALUE #( ( name = 'app' value = 'LTCL_UNIT_04_DEEP_DATA' ) )
       ).

    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(  ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize(
      EXPORTING
         json            = lv_response
      CHANGING
        data             = lo_data ).

    FIELD-SYMBOLS <val> TYPE any.

    UNASSIGN <val>.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    DATA(lv_assign) = `OVIEWMODEL->T_TAB->*`.
    ASSIGN lo_data->(lv_assign) TO <tab>.
    ASSIGN <tab>[ 1 ] TO <row>.

    DATA ls_tab_test TYPE ltcl_unit_04_deep_data=>ty_row.
    ls_tab_test = VALUE #( title = 'Peter'  info = 'completed' descr = 'this is a description' icon = 'sap-icon://account' ).

    lv_assign = `TITLE->*`.
    ASSIGN <row>->(lv_assign) TO <val>.
    IF <val> <> ls_tab_test-title.
      cl_abap_unit_assert=>fail( msg = 'data binding - initial tab data wrong' quit = 5 ).
    ENDIF.

    lv_assign = `INFO->*`.
    ASSIGN <row>->(lv_assign) TO <val>.
    IF <val> <> ls_tab_test-info.
      cl_abap_unit_assert=>fail( msg = 'data binding - initial tab data wrong' quit = 5 ).
    ENDIF.

    lv_assign = `DESCR->*`.
    ASSIGN <row>->(lv_assign) TO <val>.
    IF <val> <> ls_tab_test-descr.
      cl_abap_unit_assert=>fail( msg = 'data binding - initial tab data wrong' quit = 5 ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
