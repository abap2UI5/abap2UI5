CLASS zz2ui5_cl_app_demo_02 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES zz2ui5_if_app.

    DATA product TYPE string.
    DATA quantity TYPE string.



ENDCLASS.

CLASS zz2ui5_cl_app_demo_02 IMPLEMENTATION.


  METHOD zz2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->lifecycle_method-on_init.
        "set initial values
        product = 'tomato'.
        quantity = '500'.

      "  client->display_view( check_no_rerender = ABAp_true ).
        client->display_popup( 'POPUP' ).

      WHEN client->lifecycle_method-on_event.

        "user event handling
        CASE client->get( )-event_id.

          WHEN 'BTN_BACK'.
            client->nav_to_app( client->get_app_called( ) ).

          WHEN 'BUTTON_POST'.
            "do something
            client->display_message_toast( |{ product } { quantity } ST - GR successful| ).

        ENDCASE.





      WHEN client->lifecycle_method-on_rendering.

        DATA(lo_view) = client->factory_view( 'FREESTYLE' ).

        DATA(lo_page) = lo_view->add_page(
                   title             = 'zweite app title'
                   event_nav_back_id = COND #(  WHEN client->get( )-check_call_satck = abap_true THEN 'BTN_BACK' )
               ).

        lo_page->add_header_content( )->add_overflow_toolbar(
            )->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST'
            )->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST'
            )->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST'
        ).

        lo_page = lo_page->add_content( ).

        DATA(lo_grid) = lo_page->add_grid( )->add_content( 'l' ).

        DATA(lo_form) = lo_grid->add_simple_form( )->add_content( 'f' ).
        lo_form = lo_form->add_vbox( ).
        lo_form->add_input( product ).
        lo_form->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST' ).
        lo_form->add_input( product ).
        lo_form->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST' ).

        lo_form = lo_grid->add_simple_form( title = 'test' )->add_content( 'f' ).
        lo_form->add_title( 'new title' ).
        lo_form = lo_form->add_vbox( ).
        lo_form->add_label( 'label' ).
        lo_form->add_input( product ).
        lo_form->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST' ).
        lo_form->add_label( 'label' ).
        lo_form->add_input( product ).
        lo_form->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST' ).

        lo_page->parent->add_footer( )->add_overflow_toolbar(
             )->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST'
             )->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST'
             )->add_toolbar_spacer(
              )->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST'
             )->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST'
             ).


        DATA(lo_popup) = client->factory_view( 'POPUP' ).
        lo_popup->add_dialog(
             title  = 'Popup Title'
        ).
        lo_popup->add_input( product
           )->add_button(  text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST'
           )->add_input( product
           )->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST' ).


    ENDCASE.

  ENDMETHOD.

ENDCLASS.
