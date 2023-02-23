CLASS z2ui5_cl_app_demo_05 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA:
      BEGIN OF screen,
        check_initialized TYPE abap_bool,
        check_is_active   TYPE abap_bool,
        colour            TYPE string,
        combo_key         TYPE string,
        segment_key       TYPE string,
        date              TYPE string,
        date_time         TYPE string,
        time_start        TYPE string,
        time_end          TYPE string,
        check_switch_01   TYPE abap_bool VALUE abap_false,
        check_switch_02   TYPE abap_bool VALUE abap_false,
        progress_value    TYPE string VALUE '3',
        step_val_01       TYPE string VALUE '4',
        step_val_02       TYPE string VALUE '10',
        text_area         TYPE string,
      END OF screen.

PROTECTED SECTION.
PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_05 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_init.

        screen = VALUE #(
           check_initialized = abap_true
           check_is_active   = abap_true
           colour            = 'BLUE'
           combo_key         = 'GRAY'
           segment_key       = 'GREEN'
           date              = '07.12.22'
           date_time         = '23.12.2022, 19:27:20'
           time_start        = '05:24:00'
           time_end          = '17:23:57'  ).


      WHEN client->cs-lifecycle_method-on_event.

        "user event handling
        CASE client->get( )-event.

          WHEN 'BUTTON_BACK'.
            client->nav_to_app( client->get_app_previous( ) ).

          WHEN 'BUTTON_ROUNDTRIP'.
            DATA(lv_dummy) = 'user pressed a button, your custom implementation can be called here'.

          WHEN 'BUTTON_MSG_BOX'.
            client->display_message_box(
              text = 'this is a message box with a custom text'
              type = 'success' ).

        ENDCASE.


      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( ).
        DATA(page) = view->page( title = 'App Title - Header' nav_button_tap = view->_event_display_id( client->get( )-id_prev_app ) ).

        page->message_strip( text = 'this is a success message strip' type = 'Success' ).

        DATA(grid) = page->grid( 'L6 M12 S12' )->content( 'l' ).

        grid->simple_form('More Controls' )->content( 'f'
             )->label( 'ProgressIndicator'
             )->progress_indicator( percent_value = screen-progress_value display_value = '0,44GB of 32GB used' show_value = abap_true state = 'Success'

             )->label( 'StepInput'
             )->step_input( value = view->_bind( screen-step_val_01 ) step = '2'  min = '0' max = '20'
             )->step_input( value = view->_bind( screen-step_val_02 ) step = '10' min = '0' max = '100'

             )->label( 'Text Area'
             )->text_area( value = view->_bind( screen-text_area ) height = '100px' ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
