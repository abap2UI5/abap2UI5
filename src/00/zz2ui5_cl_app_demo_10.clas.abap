CLASS zz2ui5_cl_app_demo_10 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.
    CLASS-METHODS factory
      IMPORTING
        i_app           TYPE REF TO z2ui5_if_app
        i_name_attri    TYPE string
      RETURNING
        VALUE(r_result) TYPE REF TO zz2ui5_cl_app_demo_10.


    DATA mo_app TYPE REF TO z2ui5_if_app.
    DATA mv_name_attri TYPE string.


ENDCLASS.

CLASS zz2ui5_cl_app_demo_10 IMPLEMENTATION.

  METHOD factory.

    r_result = NEW #( ).

    r_result->mo_app = i_app.
    r_result->mv_name_attri = i_name_attri.

  ENDMETHOD.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

*
*      WHEN client->lifecycle_method-on_init.
*        client->display_view( 'POPUP_BAL' ).
*
*
*
*      WHEN client->lifecycle_method-on_event.
*        CASE client->get( )-event_id.
*
*          WHEN 'BUTTON_BACK'.
*            client->nav_to_app( client->get_app_called( ) ).
*
*        ENDCASE.
*
*
*
      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( ).

        DATA(page) = view->page(
             title          = 'header title'
             nav_button_tap = view->_event_display_id( client->get( )-id_prev_app )
                     ).

        page->header_content(
          )->button( text = 'button'
            )->text( 'text'
            )->link( text = 'link' href = 'https://twitter.com/OblomovDev'
        ).

        page->sub_header( )->overflow_toolbar(
            )->button( text = 'button'
            )->text( 'text'
            )->link( text = 'link' href = 'https://twitter.com/OblomovDev'
            )->toolbar_spacer(
            )->text( 'subheader'
            )->toolbar_spacer(
            )->button( text = 'button'
            )->text( 'text'
            )->link( text = 'link' href = 'https://twitter.com/OblomovDev'
         ).


        DATA(lo_grid) = page->grid( default_span  = 'L4 M4 S4'  )->content( 'l' ).
        lo_grid->simple_form(  'Grid width 33%' )->content( 'f'
           )->button( text = 'button'
           )->text( 'text'
           )->link( text = 'link' href = 'https://twitter.com/OblomovDev' ).

        lo_grid->simple_form(  'Grid width 33%' )->content( 'f'
          )->button( text = 'button'
          )->text( 'text'
          )->link( text = 'link' href = 'https://twitter.com/OblomovDev' ).

        lo_grid->simple_form(  'Grid width 33%' )->content( 'f'
          )->button( text = 'button'
          )->text( 'text'
          )->link( text = 'link' href = 'https://twitter.com/OblomovDev' ).


        lo_grid = page->grid( default_span  = 'L12 M12 S12' )->content( 'l' ).

        lo_grid->simple_form(  'grid width 100%' )->content( 'f'
          )->button( text = 'button'
          )->text( 'text'
          )->link( text = 'link' href = 'https://twitter.com/OblomovDev' ).


        page->footer( )->overflow_toolbar( )->button( text = 'button'
           )->text( 'text'
           )->link( text = 'link' href = 'https://twitter.com/OblomovDev'
           )->toolbar_spacer(
           )->text( 'footer'
           )->toolbar_spacer(
           )->text( 'text'
           )->link( text = 'link' href = 'https://twitter.com/OblomovDev'
           )->button( text = 'reject' type = client->cs-button-type-reject
           )->button( text = 'accept' type = client->cs-button-type-success
        ).

    ENDCASE.

  ENDMETHOD.

ENDCLASS.
