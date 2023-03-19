CLASS z2ui5_cl_app_demo_09 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA:
      BEGIN OF screen,
        color_01 TYPE string,
        color_02 TYPE string,
        color_03 TYPE string,
        city     TYPE string,
        name     TYPE string,
        lastname TYPE string,
        quantity TYPE string,
        unit     TYPE string,
      END OF screen.

    TYPES:
      BEGIN OF s_suggestion_items,
        selkz TYPE abap_bool,
        value TYPE string,
        descr TYPE string,
      END OF s_suggestion_items.
    DATA mt_suggestion TYPE STANDARD TABLE OF s_suggestion_items WITH EMPTY KEY.
    DATA mt_suggestion_sel TYPE STANDARD TABLE OF s_suggestion_items WITH EMPTY KEY.

    TYPES:
      BEGIN OF s_suggestion_items_city,
        value TYPE string,
        descr TYPE string,
      END OF s_suggestion_items_city.
    DATA mt_suggestion_city TYPE STANDARD TABLE OF s_suggestion_items_city WITH EMPTY KEY.

    TYPES:
      BEGIN OF s_employee,
        selkz    TYPE abap_bool,
        city     TYPE string,
        nr       TYPE string,
        name     TYPE string,
        lastname TYPE string,
      END OF s_employee.
    DATA mt_employees_sel TYPE STANDARD TABLE OF s_employee WITH EMPTY KEY.
    DATA mt_employees TYPE STANDARD TABLE OF s_employee WITH EMPTY KEY.


  PROTECTED SECTION.

    METHODS z2ui5_on_rendering
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

    METHODS z2ui5_on_event
      IMPORTING
        client TYPE REF TO z2ui5_if_client.
    METHODS z2ui5_on_init.


  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_09 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.
      WHEN client->cs-lifecycle_method-on_init.
        z2ui5_on_init( ).
      WHEN client->cs-lifecycle_method-on_event.
        z2ui5_on_event( client ).
      WHEN client->cs-lifecycle_method-on_rendering.
        z2ui5_on_rendering( client ).
    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_rendering.

    DATA(view) = client->factory_view( 'MAIN' ).
    DATA(page) = view->page( title = 'abap2UI5 - Value Help Examples' navbuttontap = view->_event( 'BACK' ) ).
    page->header_content( )->link( text = 'Go to Source Code' href = client->get( )-s_request-url_source_code ).

    DATA(grid) = page->grid( 'XL12 L12 M12 S12' )->content( 'l' ).

    DATA(form) = grid->simple_form( 'Input with Value Help' )->content( 'f' ).

    form->label( 'Input with sugestion items'
             )->input(
                    value       = view->_bind( screen-color_01 )
                    placeholder = 'fill in your favorite colour'
                    suggestionitems = view->_bind_one_way( mt_suggestion )
                    showsuggestion = abap_true )->get(
                          )->suggestion_items( )->get(
                                )->list_item( text = '{VALUE}' additionalText = '{DESCR}'  ).

    form->label( 'Input only numbers allowed'
       )->input(
          value       = view->_bind( screen-quantity )
          type        = 'Number'
          placeholder = 'quantity' ).

    form->label( 'Input with F4'
        )->input(
           value       = view->_bind( screen-color_02 )
           placeholder = 'fill in your favorite colour'
           showvaluehelp = abap_true
           valuehelprequest = view->_event( 'POPUP_TABLE_F4' ) ).

    form->label( 'Custom F4 Popup'
       )->input(
          value       = view->_bind( screen-name )
          placeholder = 'name'
          showvaluehelp = abap_true
          valuehelprequest = view->_event( 'POPUP_TABLE_F4_CUSTOM' )
        )->input(
          value       = view->_bind( screen-lastname )
          placeholder = 'lastname'
          showvaluehelp = abap_true
          valuehelprequest = view->_event( 'POPUP_TABLE_F4_CUSTOM' ) ).

    page->footer( )->overflow_toolbar(
         )->toolbar_spacer(
         )->button(
             text  = 'Clear'
             press = view->_event( 'BUTTON_CLEAR' )
             type  = 'Reject'
             enabled = abap_false
             icon  = 'sap-icon://delete'
         )->button(
             text  = 'Send to Server'
             press = view->_event( 'BUTTON_SEND' )
             enabled = abap_false
             type  = 'Success' ).



    view = client->factory_view( 'POPUP_TABLE_F4' ).
    DATA(popup) = view->dialog( title = 'abap2UI5 - F4 Value Help' ).

    DATA(tab) = popup->table(
        mode = 'SingleSelectLeft'
        items = view->_bind( mt_suggestion_sel ) ).

    tab->columns(
        )->column( width = '20rem' )->text( 'Color' )->get_parent(
        )->column( )->text( 'Description' ).

    tab->items( )->column_list_item( selected = '{SELKZ}' )->cells(
        )->text( '{VALUE}'
        )->text( '{DESCR}' ).

    popup->footer( )->overflow_toolbar(
                )->toolbar_spacer(
                )->button(
                    text  = 'continue'
                    press = view->_event( 'POPUP_TABLE_F4_CONTINUE' )
                    type  = 'Emphasized' ).



    view = client->factory_view( 'POPUP_TABLE_F4_CUSTOM' ).
    popup = view->dialog( title = 'abap2UI5 - F4 Value Help' ).

    popup->simple_form(
         )->label( 'Location'
         )->input(
            value = view->_bind( screen-city )
            suggestionitems = view->_bind_one_way( mt_suggestion_city )
            showsuggestion = abap_true
             )->get(
            )->suggestion_items( )->get(
               )->list_item( text = '{VALUE}' additionalText = '{DESCR}'
                )->get_parent(  )->get_parent(
         )->button( text = 'search...' press = view->_event( 'SEARCH' )
       ).

    tab = popup->table(
        headertext = 'Employees'
        mode = 'SingleSelectLeft'
        items = view->_bind( mt_employees_sel ) ).

    tab->columns(
        )->column( width = '10rem' )->text( 'City' )->get_parent(
        )->column( width = '10rem' )->text( 'Nr' )->get_parent(
        )->column( width = '15rem' )->text( 'Name' )->get_parent(
        )->column( width = '30rem' )->text( 'Lastname' )->get_parent( ).

    tab->items( )->column_list_item( selected = '{SELKZ}' )->cells(
        )->text( '{CITY}'
        )->text( '{NR}'
        )->text( '{NAME}'
        )->text( '{LASTNAME}' ).

    popup->footer( )->overflow_toolbar(
                )->toolbar_spacer(
                )->button(
                    text  = 'continue'
                    press = view->_event( 'POPUP_TABLE_F4_CUSTOM_CONTINUE' )
                    type  = 'Emphasized' ).

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE client->get( )-event.

      WHEN 'POPUP_TABLE_F4'.
        mt_suggestion_sel = mt_suggestion.
        client->view_popup( 'POPUP_TABLE_F4' ).

      WHEN 'POPUP_TABLE_F4_CUSTOM'.
        mt_employees_sel = VALUE #( ).
        mt_employees_sel = VALUE #( ).
        client->view_popup( 'POPUP_TABLE_F4_CUSTOM' ).

      WHEN 'SEARCH'.
        mt_employees_sel = mt_employees.
        IF screen-city IS NOT INITIAL.
          DELETE mt_employees_sel WHERE city <> screen-city.
        ENDIF.
        client->view_popup( 'POPUP_TABLE_F4_CUSTOM' ).

      WHEN 'POPUP_TABLE_F4_CUSTOM_CONTINUE'.
        DELETE mt_employees_sel WHERE selkz = abap_false.
        IF lines( mt_employees_sel ) = 1.
          screen-name = mt_employees_sel[ 1 ]-name.
          screen-lastname = mt_employees_sel[ 1 ]-lastname.
          client->popup_message_toast( 'f4 value selected' ).
        ENDIF.

      WHEN 'POPUP_TABLE_F4_CONTINUE'.
        DELETE mt_suggestion_sel WHERE selkz = abap_false.
        IF lines( mt_suggestion_sel ) = 1.
          screen-color_02 = mt_suggestion_sel[ 1 ]-value.
          client->popup_message_toast( 'f4 value selected' ).
        ENDIF.

      WHEN 'BUTTON_SEND'.
        client->popup_message_box( 'success - values send to the server' ).
      WHEN 'BUTTON_CLEAR'.
        CLEAR screen.
        client->popup_message_toast( 'View initialized' ).
      WHEN 'BACK'.
        client->nav_app_leave( client->get( )-id_prev_app_stack ).

    ENDCASE.

    client->view_show( 'MAIN' ).

  ENDMETHOD.


  METHOD z2ui5_on_init.

    mt_suggestion = VALUE #(
        ( descr = 'this is the color Green'  value = 'GREEN' )
        ( descr = 'this is the color Blue'   value = 'BLUE' )
        ( descr = 'this is the color Black'  value = 'BLACK' )
        ( descr = 'this is the color Grey'   value = 'GREY' )
        ( descr = 'this is the color Blue2'  value = 'BLUE2' )
        ( descr = 'this is the color Blue3'  value = 'BLUE3' ) ).

    mt_suggestion_city = VALUE #(
        ( value = 'London' descr = 'London' )
        ( value = 'Paris' descr = 'Paris' )
        ( value = 'Rome' descr = 'Rome' ) ).

    mt_employees = VALUE #(
        ( city = 'London' name = 'Tom'       lastname = 'lastname1' nr = '00001' )
        ( city = 'London' name = 'Tom2'      lastname = 'lastname2' nr = '00002' )
        ( city = 'London' name = 'Tom3'      lastname = 'lastname3' nr = '00003' )
        ( city = 'London' name = 'Tom4'      lastname = 'lastname4' nr = '00004' )
        ( city = 'Rome'   name = 'Michaela1' lastname = 'lastname5' nr = '00005' )
        ( city = 'Rome'   name = 'Michaela2' lastname = 'lastname6' nr = '00006' )
        ( city = 'Rome'   name = 'Michaela3' lastname = 'lastname7' nr = '00007' )
        ( city = 'Rome'   name = 'Michaela4' lastname = 'lastname8' nr = '00008' )
        ( city = 'Paris'  name = 'Hermine1'  lastname = 'lastname9' nr = '00009' )
        ( city = 'Paris'  name = 'Hermine2'  lastname = 'lastname10' nr = '00010' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' )
        ( city = 'Paris'  name = 'Hermine3'  lastname = 'lastname11' nr = '00011' ) ).

  ENDMETHOD.
ENDCLASS.
