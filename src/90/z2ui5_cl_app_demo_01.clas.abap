CLASS z2ui5_cl_app_demo_01 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA product TYPE string.
    DATA quantity TYPE string.

    DATA check_initialized TYPE abap_bool.

ENDCLASS.

CLASS z2ui5_cl_app_demo_01 IMPLEMENTATION.

  METHOD z2ui5_if_app~on_event.

    "set initial values
    IF check_initialized = abap_false.
      check_initialized = abap_true.

      product = 'tomato'.
      quantity = '500'.
    ENDIF.


    "user event handling
    CASE client->event( )->get_id( ).

      WHEN 'BUTTON_POST'.
        "do something
        client->popup( )->message_toast( |{ product } { quantity } ST - GR successful| ).

    ENDCASE.

  ENDMETHOD.

  METHOD z2ui5_if_app~set_view.

    "define selection screen
    view->factory_selscreen_page( title = 'My ABAP Application - Z2UI5_CL_APP_DEMO_01'
        )->begin_of_block( 'Selection Screen Title'
            )->begin_of_group( 'Stock Information'

                )->label( 'Product'
                )->input( product

                )->label( 'Quantity'
                )->input( quantity

                )->button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST'
       ).

  ENDMETHOD.

ENDCLASS.
