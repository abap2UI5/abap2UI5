CLASS ltcl_unit_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA product  TYPE string.
    DATA quantity TYPE string.
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
    METHODS test_json_attri  FOR TESTING RAISING cx_static_check.
    METHODS test_json_object FOR TESTING RAISING cx_static_check.
    METHODS test_index_html  FOR TESTING RAISING cx_static_check.
    METHODS test_app         FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.

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

      t_tab = VALUE #(
            ( title = 'Peter'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
            ( title = 'Peter'  info = 'incompleted' descr = 'this is a description' icon = 'sap-icon://account' )
        ).

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
        )->get_parent( )->get_parent(
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

  METHOD test_app.

    z2ui5_cl_http_handler=>client = VALUE #(
       t_param = VALUE #( ( name = 'app' value = 'LTCL_UNIT_TEST' ) )
       ).

    DATA(lv_response) = z2ui5_cl_http_handler=>http_post(  ).

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize(
      EXPORTING
         json            = lv_response
      CHANGING
        data             = lo_data ).

    DATA lv_assign TYPE string.
    FIELD-SYMBOLS <val> TYPE any.

    UNASSIGN <val>.
    lv_assign = `OVIEWMODEL->OUPDATE->QUANTITY->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    IF <val> <> `500`.
      cl_abap_unit_assert=>fail( msg = 'data binding - initial set oUpdate wrong' quit = 5 ).
    ENDIF.

    UNASSIGN <val>.
    lv_assign = `VVIEW->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    <val> = shift_left( <val> ).
    IF <val>(9) <> `<mvc:View`.
      cl_abap_unit_assert=>fail( msg = 'xml view - intital view wrong' quit = 5 ).
    ENDIF.

    UNASSIGN <val>.
    lv_assign = `OSYSTEM->ID->*`.
    ASSIGN lo_data->(lv_assign) TO <val>.
    IF <val> IS INITIAL.
      cl_abap_unit_assert=>fail( msg = 'id - initial value is initial' quit = 5 ).
    ENDIF.
    DATA(lv_id) = CONV string( <val> ).

    UNASSIGN <val>.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    lv_assign = `OVIEWMODEL->T_TAB->*`.
    ASSIGN lo_data->(lv_assign) TO <tab>.
    ASSIGN <tab>[ 1 ] TO <row>.

    DATA ls_tab_test TYPE ltcl_unit_test=>ty_row.
    ls_tab_test = VALUE #( title = 'Peter'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' ).

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

ENDCLASS.
