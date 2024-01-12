CLASS z2ui5_cl_popup_textedit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA client TYPE REF TO z2ui5_if_client.
    DATA mv_stretch_active TYPE string.
    DATA mv_textarea TYPE string.
    METHODS display.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_popup_textedit IMPLEMENTATION.

  METHOD display.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( client )->dialog(
              stretch = mv_stretch_active
              title = 'Title'
              icon = 'sap-icon://edit'
          )->content(
              )->text_area(
                  height = '100%'
                  width  = '100%'
                  value  = client->_bind_edit( mv_textarea )
          )->get_parent(
          )->footer( )->overflow_toolbar(
              )->toolbar_spacer(
              )->button(
                  text  = 'Cancel'
                  press = client->_event( 'BUTTON_TEXTAREA_CANCEL' )
              )->button(
                  text  = 'Confirm'
                  press = client->_event( 'BUTTON_TEXTAREA_CONFIRM' )
                  type  = 'Emphasized' ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

  ENDMETHOD.

ENDCLASS.
