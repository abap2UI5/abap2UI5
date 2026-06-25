"! Larger abap2UI5 app — main( ) is a dispatcher; logic in on_init / on_event.
"! Add only the methods you actually need. Rename ZCL_MY_APP to your own class,
"! and adjust the style (FINAL, prefixes) to match your project's ABAP standards.
CLASS zcl_my_app DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_row,
        id   TYPE string,
        text TYPE string,
      END OF ty_s_row.
    DATA t_rows TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.

    METHODS on_init.
    METHODS on_event.
    METHODS view_display.
    METHODS data_read.

  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_my_app IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    me->client = client.
    IF client->check_on_init( ).
      on_init( ).
    ELSEIF client->check_on_event( ).
      on_event( ).
    ENDIF.

  ENDMETHOD.


  METHOD on_init.

    data_read( ).
    view_display( ).

  ENDMETHOD.


  METHOD on_event.

    CASE client->get( )-event.
      WHEN `SAVE`.
        client->message_toast_display( `Saved` ).
      WHEN `BACK`.
        client->nav_app_leave( ).
    ENDCASE.

  ENDMETHOD.


  METHOD data_read.

    t_rows = VALUE #(
        ( id = `1` text = `First` )
        ( id = `2` text = `Second` ) ).

  ENDMETHOD.


  METHOD view_display.

    DATA(view) = z2ui5_cl_xml_view=>factory( ).
    DATA(page) = view->shell(
        )->page(
            title          = `My abap2UI5 App`
            navbuttonpress = client->_event_nav_app_leave( )
            shownavbutton  = client->check_app_prev_stack( ) ).

    DATA(tab) = page->table( client->_bind( t_rows ) ).
    tab->columns(
        )->column( )->text( `Id` )->get_parent(
        )->column( )->text( `Text` ).
    tab->items( )->column_list_item(
        )->cells(
            )->text( `{ID}`
            )->text( `{TEXT}` ).

    page->footer( )->overflow_toolbar(
        )->toolbar_spacer(
        )->button(
            text  = `Save`
            press = client->_event( `SAVE` )
            type  = `Emphasized` ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.

ENDCLASS.
