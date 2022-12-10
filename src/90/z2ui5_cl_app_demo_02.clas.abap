CLASS z2ui5_cl_app_demo_02 DEFINITION PUBLIC.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA:
      BEGIN OF ms_screen,
        check_initialized TYPE abap_bool,
        check_is_active   TYPE abap_bool,
        plant             TYPE string,
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
      ms_screen-check_initialized = abap_true.

      ms_screen-combo_key = 'AB'.
      ms_screen-check_is_active = abap_true.

    ENDIF.


    CASE client->event( )->get_id( ).

      WHEN 'BUTTON_HOME'.
        " client->controller( )->exit_to_home( ).

      WHEN 'BUTTON_RESTART'.
        " client->controller( )->nav_to_app( NEW zzcl_app_demo1( ) ).

      WHEN 'BUTTON_ERROR'.
        DATA(dummy) = 1 / 0.

    ENDCASE.


  ENDMETHOD.

  METHOD z2ui5_if_app~set_view.


    DATA(lo_screen) = view->factory_selscreen( title = 'App Title - Demo UI5 Controls' ).
    DATA(lo_block) = lo_screen->begin_of_block( 'Selection Screen Title' ).



    DATA(lo_group) = lo_block->begin_of_group( 'Input' ).

    lo_group->label( 'Input with value help' ).
    lo_group->input(
        value       = ms_screen-plant
        placeholder = 'fill in plant'
        suggestion_items = VALUE #(
            ( descr = 'Bitburg' value = '030' )
            ( descr = 'Hamburg' value = '050' )
          ) ).



    lo_group = lo_block->begin_of_group( 'Eingabe mit Auswahl' ).

    lo_group->label( 'Checkbox' ).
    lo_group->checkbox(
        selected = ms_screen-check_is_active
        text     = 'das ist eine checkbox'
    ).

    lo_group->label( 'Combobox' ).
    lo_group->combobox(
        selectedkey = ms_screen-combo_key
        t_item      = VALUE #(
                ( key = 'AH' text = 'green' )
                ( key = 'AB' text = 'blue' )
                ( key = 'LL' text = 'red' )
                ( key = 'TT' text = 'gray' )
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
        t_prop         = VALUE #( ( `AAAAAAA` ) ( `BBBBBBBB` ) )
    ).



    lo_group = lo_block->begin_of_group( 'Zeitangaben' ).

    lo_group->label( 'Datum' ).
    lo_group->date_picker( ms_screen-date ).

    lo_group->label( 'Datum u Zeit' ).
    lo_group->date_time_picker( ms_screen-date_time ).

    lo_group->label( 'Zeit von/bis' ).
    lo_group->time_picker( ms_screen-time_start ).
    lo_group->time_picker( ms_screen-time_end ).



    lo_group = lo_block->begin_of_group( 'Interaktion' ).

    lo_group->label( 'Popups' ).
    lo_group->button( text = 'Message Box Anzeigen'   on_press_id = 'BUTTON_HOME'   ).
    lo_group->button( text = 'Message Toast Anzeigen' on_press_id = 'BUTTON_RESTART' ).

    lo_group->label( 'System' ).
    lo_group->button( text = 'Exit'     on_press_id = 'BUTTON_HOME'   ).
    lo_group->button( text = 'Neustart' on_press_id = 'BUTTON_HOME'   ).
    lo_group->button( text = 'Fehler'   on_press_id = 'BUTTON_ERROR'   ).

    lo_group->label( 'Neue App Aufrufen' ).
    lo_group->button( text = 'App & Screen wechseln' on_press_id = 'BUTTON_NEW'   ).




  ENDMETHOD.
ENDCLASS.
