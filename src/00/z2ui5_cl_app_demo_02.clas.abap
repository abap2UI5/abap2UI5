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

  PROTECTED SECTION.

    METHODS z2ui5_on_rendering
      IMPORTING
        client TYPE REF TO z2ui5_if_client.
    METHODS z2ui5_on_event
      IMPORTING
        client TYPE REF TO z2ui5_if_client.
    METHODS z2ui5_on_init
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_02 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_init.
        z2ui5_on_init( client ).

      WHEN client->cs-lifecycle_method-on_event.
        z2ui5_on_event( client ).

      WHEN client->cs-lifecycle_method-on_rendering.
        z2ui5_on_rendering( client ).

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_rendering.

    DATA(view) = client->factory_view( ).
    DATA(page) = view->page( title = 'Example - ZZ2UI5_CL_APP_DEMO_02' nav_button_tap = view->_event_display_id( client->get( )-id_prev_app ) ).

    DATA(grid) = page->grid( 'L6 M12 S12' )->content( 'l' ).

    grid->simple_form('Input' )->content( 'f'
        )->label( 'Input with value help'
        )->input(
            value       = view->_bind( screen-colour )
            placeholder = 'fill in your favorite colour'
            suggestion_items = view->_bind_one_way( mt_suggestion ) )->get(
            )->suggestion_items( )->get(
                )->list_item( text = '{VALUE}' additional_text = '{DESCR}' ).


    grid->simple_form('Time Inputs' )->content( 'f'
        )->label( 'Date'
        )->date_picker( view->_bind( screen-date )

        )->label( 'Date and Time'
        )->date_time_picker( view->_bind( screen-date_time )

        )->label( 'Time Begin/End'
        )->time_picker( view->_bind( screen-time_start )
        )->time_picker( view->_bind( screen-time_end ) ).


    page->grid( default_span  = 'L12 M12 S12' )->content( 'l'
       )->simple_form('Input with select options' )->content( 'f'

    )->label( 'Checkbox'
    )->checkbox(
         selected = view->_bind( screen-check_is_active )
         text     = 'this is a checkbox'
         enabled  = abap_true

    )->label( 'Combobox'
    )->combobox(
         selectedkey = view->_bind( screen-combo_key )
         items      = view->_bind_one_way( VALUE ty_t_combo(
             ( key = 'BLUE'  text = 'green' )
             ( key = 'GREEN' text = 'blue'  )
             ( key = 'BLACK' text = 'red'   )
             ( key = 'GRAY'  text = 'gray'  ) )
         ) )->get( )->item( key = '{KEY}' text = '{TEXT}'
        )->get_parent( )->get_parent(

    )->label( 'Segmented Button'
    )->segmented_button( view->_bind( screen-segment_key ) )->get(
        )->items( )->get(
             )->segmented_button_item( key = 'BLUE'  icon = 'sap-icon://accept'       text = 'blue'
             )->segmented_button_item( key = 'GREEN' icon = 'sap-icon://add-favorite' text = 'green'
             )->segmented_button_item( key = 'BLACK' icon = 'sap-icon://attachment'   text = 'black'
       )->get_parent( )->get_parent(

    )->label( 'Switch disabled'
    )->switch( enabled = abap_false    customtexton = 'A' customtextoff = 'B'
    )->label( 'Switch accept/reject'
    )->switch( state = screen-check_switch_01 customtexton = 'on'  customtextoff = 'off' type = 'AcceptReject'
    )->label( 'Switch normal'
    )->switch( state = screen-check_switch_02 customtexton = 'YES' customtextoff = 'NO' ).


    page->footer( )->overflow_toolbar(
         )->link(
             text = 'Go to Source Code'
             href = client->get( )-s_request-url_source_code
         )->toolbar_spacer(
         )->button(
             text  = 'Clear'
             press = view->_event( 'BUTTON_CLEAR' )
             type  = 'Reject'
             icon  = 'sap-icon://delete'
         )->button(
             text  = 'Send to Server'
             press = view->_event( 'BUTTON_SEND' )
             type  = 'Success' ).

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE client->get( )-event.

      WHEN 'BUTTON_SEND'.
        client->display_message_box( 'Values were send to the server successfully').
      WHEN 'BUTTON_CLEAR'.
        CLEAR screen.
        client->display_message_toast( 'View initialized' ).

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_init.

    screen = VALUE #(
          check_is_active   = abap_true
          colour            = 'BLUE'
          combo_key         = 'GRAY'
          segment_key       = 'GREEN'
          date              = '07.12.22'
          date_time         = '23.12.2022, 19:27:20'
          time_start        = '05:24:00'
          time_end          = '17:23:57'
     ).

    mt_suggestion = VALUE #(
               ( descr = 'Green'  value = 'GREEN' )
               ( descr = 'Blue'   value = 'BLUE' )
               ( descr = 'Black'  value = 'BLACK' )
               ( descr = 'Grey'   value = 'GREY' )
               ( descr = 'Blue2'  value = 'BLUE2' )
               ( descr = 'Blue3'  value = 'BLUE3' ) ).

  ENDMETHOD.
ENDCLASS.
