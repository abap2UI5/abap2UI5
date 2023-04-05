CLASS z2ui5_cl_app_demo_10 DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_10 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.


    CASE client->get( )-event.
      WHEN 'BACK'.
        client->nav_app_leave( client->get( )-id_prev_app_stack ).
    ENDCASE.

    DATA(page) = z2ui5_cl_xml_view_helper=>factory(
        )->page(
            title           = 'abap2UI5 - Demo Layout'
            navbuttonpress  = client->_event( 'BACK' )
            shownavbutton   = abap_true
             ).

    page->header_content(
      )->button( text = 'button'
      )->text( 'text'
      )->link(
        text = 'link'
        href = 'https://twitter.com/OblomovDev'
      )->link(
        text = 'Source_Code'
        href = client->get( )-url_source_code ).

    page->sub_header(
        )->overflow_toolbar(
            )->button( text = 'button'
            )->text( 'text'
            )->link( text = 'link' href = 'https://twitter.com/OblomovDev'
            )->toolbar_spacer(
            )->text( 'subheader'
            )->toolbar_spacer(
            )->button( text = 'button'
            )->text( 'text'
            )->link( text = 'link' href = 'https://twitter.com/OblomovDev' ).

    DATA(grid) = page->grid( 'L4 M4 S4' )->content( 'l' ).

    grid->simple_form( 'Grid width 33%' )->content( 'f'
       )->button( text = 'button'
       )->text( 'text'
       )->link( text = 'link' href = 'https://twitter.com/OblomovDev' ).

    grid->simple_form( 'Grid width 33%' )->content( 'f'
      )->button( text = 'button'
      )->text( 'text'
      )->link( text = 'link' href = 'https://twitter.com/OblomovDev' ).

    grid->simple_form( 'Grid width 33%' )->content( 'f'
      )->button( text = 'button'
      )->text( 'text'
      )->link( text = 'link' href = 'https://twitter.com/OblomovDev' ).

    grid = page->grid( 'L12 M12 S12' )->content( 'l' ).

    grid->simple_form( 'grid width 100%' )->content( 'f'
      )->button( text = 'button'
      )->text( 'text'
      )->link( text = 'link' href = 'https://twitter.com/OblomovDev' ).

    page->footer(
        )->overflow_toolbar(
            )->button( text = 'button'
            )->text( 'text'
            )->link( text = 'link' href = 'https://twitter.com/OblomovDev'
            )->toolbar_spacer(
            )->text( 'footer'
            )->toolbar_spacer(
            )->text( 'text'
            )->link( text = 'link' href = 'https://twitter.com/OblomovDev'
            )->button( text = 'reject' type = 'Reject'
            )->button( text = 'accept' type = 'Success' ).

    client->set_next( VALUE #( xml_main = page->get_root( )->xml_get( ) ) ).

  ENDMETHOD.
ENDCLASS.
