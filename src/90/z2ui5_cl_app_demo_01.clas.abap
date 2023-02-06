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

      WHEN 'BTN_BACK'.
        client->controller( )->nav_to_app_called( ).

      WHEN 'BUTTON_POST'.
        "do something
        client->popup( )->message_toast( |{ product } { quantity } ST - GR successful| ).

    ENDCASE.

    client->controller( )->nav_to_view( 'FREESTYLE' ).

  ENDMETHOD.

  METHOD z2ui5_if_app~set_view.


    "inside
    "define selection screen
   view->factory_selscreen_page( name = 'SELSCREEN_IN' event_nav_back_id = 'BTN_BACK' title = 'My ABAP Application - Z2UI5_CL_APP_DEMO_01'
         )->begin_of_block( 'Selection Screen Title'
            )->begin_of_group( 'Stock Information'
                )->label( 'Product'
                )->input( product
                )->label( 'Quantity'
                )->input( quantity
                )->button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST'
      ).




    "all outside
    DATA(lo_view) = z2ui5_cl_control_library=>factory( view->get_context( ) ).
    view->factory_view( name = 'FREESTYLE' parser = lo_view->root ).

    lo_view = lo_view->add_page( ).
    lo_view = lo_view->add_vbox( ).

    DATA(lo_form) = lo_view->add_simple_form( )->add_content( ).
    lo_view = lo_form->add_vbox( ).
    lo_view->add_input( product ).
    lo_view->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST' ).
    lo_view->add_input( product ).
    lo_view->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST' ).

    lo_form = lo_form->parent->parent->add_simple_form( )->add_content( ).
    " lo_view = lo_form->add_vbox( ).
    lo_view = lo_form->add_title( `Title` ).
    lo_view->add_input( product ).
    lo_view->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST' ).
    lo_view->add_input( product ).
    lo_view->add_button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST' ).


    "selscreen outside
    DATA(li_selscreen) = z2ui5_cl_view_selscreen=>create(
         name              = 'SELSCREEN_OUT'
         title             = 'My ABAP Application - Z2UI5_CL_APP_DEMO_01'
         event_nav_back_id = 'BTN_BACK'
         view              = view
       ).

    li_selscreen->begin_of_block( 'Selection Screen Title'
           )->begin_of_group( 'Stock Information'
               )->label( 'Product'
               )->input( product
               )->label( 'Quantity'
               )->input( quantity
               )->button( text = 'Post Goods Receipt' on_press_id = 'BUTTON_POST'
     ).

  ENDMETHOD.

ENDCLASS.
