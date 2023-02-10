CLASS zz2ui5_cl_app_demo_05 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES zz2ui5_if_app.
    CLASS-METHODS create
      IMPORTING
        i_text TYPE string
        i_text_long TYPE string
        i_type TYPE string
      RETURNING
        value(r_result) TYPE REF TO zz2ui5_cl_app_demo_05.



    DATA mv_text TYPE string.
    data mv_text_long type string.
    data type type string.

ENDCLASS.

CLASS zz2ui5_cl_app_demo_05 IMPLEMENTATION.

  METHOD create.

    r_result = NEW #( ).

    r_result->mv_text = i_text.
    r_result->mv_text_long = i_text_long.
    r_result->type = i_type.

  ENDMETHOD.



  METHOD zz2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.


      WHEN client->lifecycle_method-on_init.
        client->display_view( 'POPUP_BAL' ).



      WHEN client->lifecycle_method-on_event.
        CASE client->get( )-event_id.

          WHEN 'BUTTON_BACK'.
            client->nav_to_app( client->get_app_called( ) ).

        ENDCASE.



      WHEN client->lifecycle_method-on_rendering.

        client->factory_view( 'POPUP_BAL' )->add_message_page(
            text = mv_text
            description = mv_text_long
            )->add_buttons(
          )->add_button(
                text = 'Back'
                on_press_id = 'BUTTON_BACK'
        "  )->add_button(
        "        text = 'Neustart'
        "           on_press_id = 'RESTART'
          ).


    ENDCASE.

  ENDMETHOD.

ENDCLASS.
