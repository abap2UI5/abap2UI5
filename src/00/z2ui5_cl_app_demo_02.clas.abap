CLASS z2ui5_cl_app_demo_02 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA:
      BEGIN OF screen,
        check_is_active TYPE abap_bool,
        colour          TYPE string,
        combo_key       TYPE string,
        segment_key     TYPE string,
        date            TYPE string,
        date_time       TYPE string,
        time_start      TYPE string,
        time_end        TYPE string,
        check_switch_01 TYPE abap_bool VALUE abap_false,
        check_switch_02 TYPE abap_bool VALUE abap_false,
      END OF screen.

    TYPES:
      BEGIN OF s_suggestion_items,
        value TYPE string,
        descr TYPE string,
      END OF s_suggestion_items.

    TYPES:
      BEGIN OF s_combobox,
        key  TYPE string,
        text TYPE string,
      END OF s_combobox.

    TYPES ty_t_combo TYPE STANDARD TABLE OF s_combobox WITH EMPTY KEY.

    DATA mt_suggestion TYPE STANDARD TABLE OF s_suggestion_items WITH EMPTY KEY.

    DATA check_initialized TYPE abap_bool.

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



CLASS Z2UI5_CL_APP_DEMO_02 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      z2ui5_on_init( ).
    ENDIF.
    z2ui5_on_event( client ).

    z2ui5_on_rendering( client ).

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE client->get( )-event.

      WHEN 'BUTTON_SEND'.
        client->popup_message_box( 'success - values send to the server' ).
      WHEN 'BUTTON_CLEAR'.
        CLEAR screen.
        client->popup_message_toast( 'View initialized' ).
      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack ) ).

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_init.

    screen = VALUE #(
        check_is_active = abap_true
        colour          = 'BLUE'
        combo_key       = 'GRAY'
        segment_key     = 'GREEN'
        date            = '07.12.22'
        date_time       = '23.12.2022, 19:27:20'
        time_start      = '05:24:00'
        time_end        = '17:23:57').

    mt_suggestion = VALUE #(
        ( descr = 'Green'  value = 'GREEN' )
        ( descr = 'Blue'   value = 'BLUE' )
        ( descr = 'Black'  value = 'BLACK' )
        ( descr = 'Grey'   value = 'GREY' )
        ( descr = 'Blue2'  value = 'BLUE2' )
        ( descr = 'Blue3'  value = 'BLUE3' ) ).

  ENDMETHOD.


  METHOD z2ui5_on_rendering.

    DATA(page) = Z2UI5_CL_XML_VIEW=>factory( )->shell(
         )->page(
            title          = 'abap2UI5 - Selection-Screen Example'
            navbuttonpress = client->_event( 'BACK' )
              shownavbutton = abap_true
            )->header_content(
                )->link( text = 'Demo'    target = '_blank'    href = `https://twitter.com/OblomovDev/status/1628701535222865922`
                )->link( text = 'Source_Code'  target = '_blank' href = Z2UI5_CL_XML_VIEW=>hlp_get_source_code_url( app = me get = client->get( ) )
            )->get_parent( ).

    DATA(grid) = page->grid( 'L6 M12 S12'
        )->content( 'layout' ).

    grid->simple_form( 'Input'
        )->content( 'form'
            )->label( 'Input with value help'
            )->input(
                    value           = client->_bind( screen-colour )
                    placeholder     = 'fill in your favorite colour'
                    suggestionitems = client->_bind_one( mt_suggestion )
                    showsuggestion  = abap_true )->get(
                )->suggestion_items( )->get(
                    )->list_item(
                        text = '{VALUE}'
                        additionaltext = '{DESCR}' ).

    grid->simple_form( 'Time Inputs'
        )->content( 'form'
            )->label( 'Date'
            )->date_picker( client->_bind( screen-date )
            )->label( 'Date and Time'
            )->date_time_picker( client->_bind( screen-date_time )
            )->label( 'Time Begin/End'
            )->time_picker( client->_bind( screen-time_start )
            )->time_picker( client->_bind( screen-time_end ) ).


    DATA(form) = grid->get_parent( )->get_parent( )->grid( 'L12 M12 S12'
        )->content( 'layout'
            )->simple_form( 'Input with select options'
                )->content( 'form' ).

    form->label( 'Checkbox'
        )->checkbox(
            selected = client->_bind( screen-check_is_active )
            text     = 'this is a checkbox'
            enabled  = abap_true

        )->label( 'Combobox'
        )->combobox(
            selectedkey = client->_bind( screen-combo_key )
            items       = client->_bind_one( VALUE ty_t_combo(
                    ( key = 'BLUE'  text = 'green' )
                    ( key = 'GREEN' text = 'blue' )
                    ( key = 'BLACK' text = 'red' )
                    ( key = 'GRAY'  text = 'gray' ) ) )
                )->item(
                    key = '{KEY}'
                    text = '{TEXT}'
        )->get_parent( )->get_parent(

        )->label( 'Segmented Button'
        )->segmented_button( client->_bind( screen-segment_key )
            )->items(
                )->segmented_button_item(
                    key = 'BLUE'
                    icon = 'sap-icon://accept'
                    text = 'blue'
                )->segmented_button_item(
                    key = 'GREEN'
                    icon = 'sap-icon://add-favorite'
                    text = 'green'
                )->segmented_button_item(
                    key = 'BLACK'
                    icon = 'sap-icon://attachment'
                    text = 'black'
       )->get_parent( )->get_parent(

       )->label( 'Switch disabled'
       )->switch(
            enabled       = abap_false
            customtexton  = 'A'
            customtextoff = 'B'
       )->label( 'Switch accept/reject'
       )->switch(
            state         = client->_bind( screen-check_switch_01 )
            customtexton  = 'on'
            customtextoff = 'off'
            type = 'AcceptReject'
       )->label( 'Switch normal'
       )->switch(
            state         = client->_bind( screen-check_switch_02 )
            customtexton  = 'YES'
            customtextoff = 'NO' ).

    page->footer( )->overflow_toolbar(
         )->toolbar_spacer(
         )->button(
             text  = 'Clear'
             press = client->_event( 'BUTTON_CLEAR' )
             type  = 'Reject'
             icon  = 'sap-icon://delete'
         )->button(
             text  = 'Send to Server'
             press = client->_event( 'BUTTON_SEND' )
             type  = 'Success' ).

    client->set_next( value #( xml_main = page->get_root(  )->xml_get( ) ) ).




























    client->set_next( value #( xml_main = page->get_root(  )->xml_get( ) ) ).

  ENDMETHOD.
ENDCLASS.
