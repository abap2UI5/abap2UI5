CLASS z2ui5_cl_popup_input_date DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
    data mt_tab type string.
    METHODS display.

  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_POPUP_INPUT_DATE IMPLEMENTATION.


  METHOD display.

 DATA(popup) = Z2UI5_cl_xml_view=>factory_popup( client )->dialog( 'abap2UI5 - Popup to select entry'
           )->table(
               mode = 'SingleSelectLeft'
               items = client->_bind_edit( mt_tab )
               )->columns(
                   )->column( )->text( 'Title' )->get_parent(
                   )->column( )->text( 'Color' )->get_parent(
                   )->column( )->text( 'Info' )->get_parent(
                   )->column( )->text( 'Description' )->get_parent(
               )->get_parent(
               )->items( )->column_list_item( selected = '{SELKZ}'
                   )->cells(
                       )->text( '{TITLE}'
                       )->text( '{VALUE}'
                       )->text( '{INFO}'
                       )->text( '{DESCR}'
           )->get_parent( )->get_parent( )->get_parent( )->get_parent(
           )->footer( )->overflow_toolbar(
               )->toolbar_spacer(
               )->button(
                   text  = 'continue'
                   press = client->_event( 'POPUP_TABLE_CONTINUE' )
                   type  = 'Emphasized' ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

  ENDMETHOD.
ENDCLASS.
