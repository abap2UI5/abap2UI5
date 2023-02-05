CLASS z2ui5_cl_app_demo_09 DEFINITION PUBLIC.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA progress_value TYPE string VALUE '3'.

    DATA step_val_01 TYPE string VALUE '4'.
    DATA step_val_02 TYPE string VALUE '10'.

    DATA check_switch_01 TYPE abap_bool VALUE abap_false.
    DATA check_switch_02 TYPE abap_bool VALUE abap_false.

    DATA text_area TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS z2ui5_cl_app_demo_09 IMPLEMENTATION.


  METHOD z2ui5_if_app~on_event.

    CASE client->event( )->get_id( ).

      WHEN 'BTN_BACK'.
        client->controller( )->nav_to_app_called( ).

      WHEN 'POST'.
        "check the client data here...
        "do something...
        client->popup( )->message_box(
          text = 'Success! Data was send to the server...'
          type = client->cs-message_box-type-success ).

    ENDCASE.

  ENDMETHOD.

  METHOD z2ui5_if_app~set_view.

    view->factory_selscreen_page( event_nav_back_id = 'BTN_BACK' title = 'App Title - Z2UI5_CL_APP_DEMO_10'
        )->message_strip( text = 'this is a success message strip' type = view->cs-message_strip-type-success

        )->begin_of_block( 'Some new UI5 Controls...'
            )->begin_of_group( '...ready to use in pure ABAP'

               )->label( 'ProgressIndicator'
               )->progress_indicator( percent_value = progress_value display_value = '0,44GB of 32GB used' show_value = abap_true state = view->cs-progress_indicator-state-success

               )->label( 'StepInput'
               )->step_input( value = step_val_01 step = '2' min = '0' max = '20'
               )->step_input( value = step_val_02 step = '10' min = '0' max = '100'

               )->label( 'Switch disabled'
               )->switch( enabled = abap_false customtexton = 'A'  customtextoff = 'B'
               )->label( 'Switch accept/reject'
               )->switch( state = check_switch_01 customtexton = 'on'  customtextoff = 'off' type = z2ui5_if_view=>cs-switch-type-accept_reject
               )->label( 'Switch normal'
               )->switch( state = check_switch_02 customtexton = 'YES'  customtextoff = 'NO'

               )->label( 'Text Area'
               )->text_area( text_area

               )->label( 'Button'
               )->button( text = 'send data to server' on_press_id = 'POST' ).

  ENDMETHOD.
ENDCLASS.
