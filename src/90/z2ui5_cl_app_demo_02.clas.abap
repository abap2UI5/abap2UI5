CLASS z2ui5_cl_app_demo_02 DEFINITION PUBLIC.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA:
      BEGIN OF ms_screen,
        check_initialized TYPE abap_bool,
        check_is_active   TYPE abap_bool,
        colour            TYPE string,
        combo_key         TYPE string,
        segment_key       TYPE string,
        radio_index       TYPE i,
        date              TYPE string,
        date_time         TYPE string,
        time_start        TYPE string,
        time_end          TYPE string,
      END OF ms_screen.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS z2ui5_cl_app_demo_02 IMPLEMENTATION.
  METHOD z2ui5_if_app~on_event.


    IF ms_screen-check_initialized = abap_false.

      "set initial values
      ms_screen = VALUE #(
        check_initialized = abap_true
        check_is_active   = abap_true
        colour             = 'BLUE'
        combo_key         = 'GRAY'
        segment_key       = 'GREEN'
        radio_index       = '1'
        date              = '07.12.22'
        date_time         = '23.12.2022, 19:27:20'
        time_start        = '05:24:00'
        time_end          = '17:23:57'
      ).

    ENDIF.


    "user handling
    CASE client->event( )->get_id( ).

      WHEN 'BUTTON_ROUNDTRIP'.
        DATA(lv_dummy) = 'user pressed a button, your custom implementation can be called here'.

      WHEN 'BUTTON_MSG_BOX'.
        client->popup( )->message_box(
          text = 'this is a message box with a custom text'
          type = client->cs-message_box-type-success
        ).

      WHEN 'BUTTON_MSG_TOAST'.
        client->popup( )->message_toast( 'this is a message toast with a custom text' ).

      WHEN 'BUTTON_RESTART'.
        client->controller( )->nav_to_app( NEW z2ui5_cl_app_demo_02( ) ).

      WHEN 'BUTTON_ERROR'.
        DATA(dummy) = 1 / 0.

      WHEN 'BUTTON_CHANGE_APP'.
        client->controller( )->nav_to_app( NEW z2ui5_cl_app_demo_01( ) ).

    ENDCASE.


  ENDMETHOD.

  METHOD z2ui5_if_app~set_view.


    DATA(lo_screen) = view->factory_selscreen_page( title = 'abap2ui5 demo - App Title' ).
    DATA(lo_block) = lo_screen->begin_of_block( 'Selection Screen Title' ).



    DATA(lo_group) = lo_block->begin_of_group( 'Input' ).

    lo_group->label( 'Input with value help' ).
    lo_group->input(
        value       = ms_screen-colour
        placeholder = 'fill in your favorite colour'
        suggestion_items = VALUE #(
            ( descr = 'Green'  value = 'GREEN' )
            ( descr = 'Blue'   value = 'BLUE' )
            ( descr = 'Black'  value = 'BLACK' )
            ( descr = 'Grey'   value = 'GREY' )
            ( descr = 'Blue2'  value = 'BLUE2' )
            ( descr = 'Blue3'  value = 'BLUE3' )
          ) ).



    lo_group = lo_block->begin_of_group( 'Input with select options' ).

    lo_group->label( 'Checkbox' ).
    lo_group->checkbox(
        selected = ms_screen-check_is_active
        text     = 'this is a checkbox'
    ).

    lo_group->label( 'Combobox' ).
    lo_group->combobox(
        selectedkey = ms_screen-combo_key
        t_item      = VALUE #(
                ( key = 'BLUE'  text = 'green' )
                ( key = 'GREEN' text = 'blue' )
                ( key = 'BLACK' text = 'red' )
                ( key = 'GRAY'  text = 'gray' )
          ) ).

    lo_group->label( 'Segmented Button' ).
    lo_group->segmented_button(
        selected_key = ms_screen-segment_key
        t_button     = VALUE #(
            ( key = 'BLUE'  icon = 'sap-icon://accept'       text = 'blue' )
            ( key = 'GREEN' icon = 'sap-icon://add-favorite' text = 'green' )
            ( key = 'BLACK' icon = 'sap-icon://attachment'   text = 'black' )
        ) ).

    lo_group->label( 'Radiobutton' ).
    lo_group->radiobutton_group(
        selected_index = ms_screen-radio_index
        t_prop         = VALUE #( ( `Option A` ) ( `Option B` ) )
    ).



    lo_group = lo_block->begin_of_group( 'Time Inputs' ).

    lo_group->label( 'Date' ).
    lo_group->date_picker( ms_screen-date ).

    lo_group->label( 'Date and Time' ).
    lo_group->date_time_picker( ms_screen-date_time ).

    lo_group->label( 'Time Begin/End' ).
    lo_group->time_picker( ms_screen-time_start ).
    lo_group->time_picker( ms_screen-time_end ).



    lo_group = lo_block->begin_of_group( 'User Interaction' ).

    lo_group->label( 'Roundtrip' ).
    lo_group->button( text = 'Client/Server Interaction' on_press_id = 'BUTTON_ROUNDTRIP'   ).

    lo_group->label( 'Popups' ).
    lo_group->button( text = 'Display Message Box'   on_press_id = 'BUTTON_MSG_BOX'   ).
    lo_group->button( text = 'Display Message Toast' on_press_id = 'BUTTON_MSG_TOAST' ).

    lo_group->label( 'System' ).
    lo_group->button( text = 'Restart' on_press_id = 'BUTTON_RESTART'   ).
    lo_group->button( text = 'Error'   on_press_id = 'BUTTON_ERROR'   ).

    lo_group->label( 'Call new app' ).
    lo_group->button( text = 'App & Screen change' on_press_id = 'BUTTON_CHANGE_APP'   ).



  ENDMETHOD.
ENDCLASS.
