CLASS z2ui5_cl_popup_messages DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_msg,
        type       TYPE string,
        id         TYPE string,
        number     TYPE string,
        message    TYPE string,
        message_v1 TYPE string,
        message_v2 TYPE string,
        message_v3 TYPE string,
        message_v4 TYPE string,
      END OF ty_s_msg.
    TYPES ty_t_msg TYPE STANDARD TABLE OF ty_s_msg.
    DATA mt_msg TYPE ty_t_msg.

    CLASS-METHODS factory
      IMPORTING
        i_messages            TYPE ty_t_msg
        i_title               TYPE string DEFAULT `abap2UI5 - Message Popup`
      RETURNING
        VALUE(r_result)       TYPE REF TO z2ui5_cl_popup_messages.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
    DATA title TYPE string.
    DATA check_initialized TYPE abap_bool.

    METHODS view_display.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_popup_messages IMPLEMENTATION.


  METHOD factory.

    r_result = NEW #( ).
    r_result->mt_msg = i_messages.
    r_result->title = i_title.

  ENDMETHOD.


  METHOD view_display.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( )->dialog(
        title      = title
        afterclose = client->_event( 'BUTTON_CONTINUE' )
            )->table(
*                mode = 'SingleSelectLeft'
                client->_bind_edit( mt_msg )
                )->columns(
                    )->column( )->text( 'Title' )->get_parent(
                    )->column( )->text( 'Color' )->get_parent(
                    )->column( )->text( 'Info' )->get_parent(
                    )->column( )->text( 'Description' )->get_parent(
                )->get_parent(
                )->items( )->column_list_item(
                    )->cells(
                        )->text( '{TYPE}'
                        )->text( '{ID}'
                        )->text( '{NUMBER}'
                        )->text( '{MESSAGE}'
            )->get_parent( )->get_parent( )->get_parent( )->get_parent(
            )->footer( )->overflow_toolbar(
                )->toolbar_spacer(
                )->button(
                    text  = 'continue'
                    press = client->_event( 'BUTTON_CONTINUE' )
                    type  = 'Emphasized' ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    me->client = client.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      view_display( ).
      RETURN.
    ENDIF.

    CASE client->get( )-event.
      WHEN `BUTTON_CONTINUE`.
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).
          WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
