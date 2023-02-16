CLASS zz2ui5_cl_app_demo_10 DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.


ENDCLASS.

CLASS zz2ui5_cl_app_demo_10 IMPLEMENTATION.

  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_init.
        "implement init actions here...


      WHEN client->cs-lifecycle_method-on_event.

        CASE client->get( )-event.

          WHEN '...'.
            "implement event handling here...

        ENDCASE.


      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( ).

        DATA(page) = view->page(
             title          = 'header title'
             nav_button_tap = view->_event_display_id( client->get( )-id_prev_app ) ).

        page->header_content( )->get(
          )->button( text = 'button'
          )->text( 'text'
          )->link( text = 'link' href = 'https://twitter.com/OblomovDev' ).

        page->sub_header( )->get( )->overflow_toolbar( )->get(
            )->button( text = 'button'
            )->text( 'text'
            )->link( text = 'link' href = 'https://twitter.com/OblomovDev'
            )->toolbar_spacer(
            )->text( 'subheader'
            )->toolbar_spacer(
            )->button( text = 'button'
            )->text( 'text'
            )->link( text = 'link' href = 'https://twitter.com/OblomovDev' ).


        DATA(grid) = page->grid( default_span  = 'L4 M4 S4'  )->get( )->content( 'l' )->get( ).
        grid->simple_form(  'Grid width 33%' )->get( )->content( 'f' )->get(
           )->button( text = 'button'
           )->text( 'text'
           )->link( text = 'link' href = 'https://twitter.com/OblomovDev' ).

        grid->simple_form(  'Grid width 33%' )->get( )->content( 'f' )->get(
          )->button( text = 'button'
          )->text( 'text'
          )->link( text = 'link' href = 'https://twitter.com/OblomovDev' ).

        grid->simple_form(  'Grid width 33%' )->get( )->content( 'f' )->get(
          )->button( text = 'button'
          )->text( 'text'
          )->link( text = 'link' href = 'https://twitter.com/OblomovDev' ).


        grid = page->grid( default_span  = 'L12 M12 S12' )->get( )->content( 'l' )->get( ).

        grid->simple_form(  'grid width 100%' )->get( )->content( 'f' )->get(
          )->button( text = 'button'
          )->text( 'text'
          )->link( text = 'link' href = 'https://twitter.com/OblomovDev' ).


        page->footer( )->get( )->overflow_toolbar( )->get(
           )->button( text = 'button'
           )->text( 'text'
           )->link( text = 'link' href = 'https://twitter.com/OblomovDev'
           )->toolbar_spacer(
           )->text( 'footer'
           )->toolbar_spacer(
           )->text( 'text'
           )->link( text = 'link' href = 'https://twitter.com/OblomovDev'
           )->button( text = 'reject' type = client->cs-button-type-reject
           )->button( text = 'accept' type = client->cs-button-type-success ).

    ENDCASE.

  ENDMETHOD.

ENDCLASS.
