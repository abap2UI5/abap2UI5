CLASS z2ui5_cl_pop_messages DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_msg,
        type       TYPE string,
        id         TYPE string,
        title      TYPE string,
        subtitle   TYPE string,
        number     TYPE string,
        message    TYPE string,
        message_v1 TYPE string,
        message_v2 TYPE string,
        message_v3 TYPE string,
        message_v4 TYPE string,
        group      TYPE string,
      END OF ty_s_msg.
    TYPES ty_t_msg TYPE STANDARD TABLE OF ty_s_msg WITH EMPTY KEY.

    DATA mt_msg TYPE ty_t_msg.

    CLASS-METHODS factory
      IMPORTING
        i_messages      TYPE any
        i_title         TYPE string DEFAULT `abap2UI5 - Message Popup`
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_pop_messages.

  PROTECTED SECTION.
    DATA client            TYPE REF TO z2ui5_if_client.
    DATA title             TYPE string.
    DATA check_initialized TYPE abap_bool.

    METHODS view_display.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_messages IMPLEMENTATION.
  METHOD factory.

    r_result = NEW #( ).
    DATA(lt_msg) = z2ui5_cl_util=>msg_get( i_messages ).

    LOOP AT lt_msg REFERENCE INTO DATA(lr_row).

      DATA(ls_row) = VALUE ty_s_msg( ).
      ls_row-type     = z2ui5_cl_util=>ui5_get_msg_type( lr_row->type ).
      ls_row-title    = lr_row->text.
*      lr_row->title = `title`.
*      lr_row->message = `message`.
      ls_row-subtitle = |{ lr_row->id } { lr_row->no }|.
*      lr_row->group = `001`.

      INSERT ls_row INTO TABLE r_result->mt_msg.
    ENDLOOP.

    r_result->title = i_title.

  ENDMETHOD.

  METHOD view_display.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( ).
    popup = popup->dialog( title             = `Messages`
                           contentheight     = '50%'
                           contentwidth      = '50%'
                           verticalScrolling = abap_false
                           afterclose        = client->_event( 'BUTTON_CONTINUE' )
         ).

    popup->message_view( items = client->_bind( mt_msg  )
*                         groupitems = abap_true
        )->message_item( type     = `{TYPE}`
                         title    = `{TITLE}`
                         subtitle = `{SUBTITLE}`
*                         description = `{MESSAGE}`
*                         groupname = `{GROUP}`
            ).

    popup->buttons(
       )->button( text  = 'continue'
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
        client->nav_app_leave( ).
      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
