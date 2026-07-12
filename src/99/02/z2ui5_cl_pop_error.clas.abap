CLASS z2ui5_cl_pop_error DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        x_root          TYPE REF TO cx_root
        i_title         TYPE string DEFAULT `Error`
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_pop_error.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
    DATA error  TYPE REF TO cx_root.
    DATA title  TYPE string.

    METHODS view_display.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_error IMPLEMENTATION.

  METHOD factory.

    r_result = NEW #( ).
    r_result->error = x_root.
    r_result->title = i_title.

  ENDMETHOD.

  METHOD view_display.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( )->dialog( title      = title
                                                               afterclose = client->_event( `BUTTON_CONFIRM` )
              )->content(
                  )->vbox( `sapUiMediumMargin`
                      )->text( error->get_text( )
              )->get_parent( )->get_parent(
              )->buttons(
                  )->button( text  = `OK`
                             press = client->_event( `BUTTON_CONFIRM` )
                             type  = `Emphasized` ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF client->check_on_init( ).
      view_display( ).
      RETURN.
    ENDIF.

    IF client->check_on_event( `BUTTON_CONFIRM` ).
      client->popup_destroy( ).
      client->nav_app_leave( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
