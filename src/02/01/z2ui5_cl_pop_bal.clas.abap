CLASS z2ui5_cl_pop_bal DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_msg,
        type       TYPE string,
        id         TYPE string,
        title      TYPE string,
        subtitle   TYPE string,
        number     TYPE string,
        time       TYPE string,
        date       TYPE string,
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
        i_title         TYPE string DEFAULT `abap2UI5 - Business Application Log`
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_pop_bal.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
    DATA title  TYPE string.

    METHODS view_display.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_bal IMPLEMENTATION.

  METHOD factory.

    r_result = NEW #( ).

    LOOP AT z2ui5_cl_util=>msg_get_t( i_messages ) REFERENCE INTO DATA(lr_row).
      INSERT VALUE ty_s_msg(
        type       = z2ui5_cl_util=>ui5_get_msg_type( lr_row->type )
        title      = lr_row->text
        id         = lr_row->id
        number     = lr_row->no
        message_v1 = lr_row->v1
        message_v2 = lr_row->v2
        message_v3 = lr_row->v3
        message_v4 = lr_row->v4
        message    = lr_row->text
        subtitle   = |{ lr_row->id } { lr_row->no }|
        date       = z2ui5_cl_util=>time_get_date_by_stampl( lr_row->timestampl )
        time       = z2ui5_cl_util=>time_get_time_by_stampl( lr_row->timestampl )
        ) INTO TABLE r_result->mt_msg.
    ENDLOOP.

    r_result->title = i_title.

  ENDMETHOD.

  METHOD view_display.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( ).
    popup = popup->dialog( title             = title
                           contentheight     = `50%`
                           contentwidth      = `50%`
                           verticalscrolling = abap_false
                           afterclose        = client->_event( `BUTTON_CONTINUE` ) ).

    DATA(table) = popup->table( client->_bind( mt_msg ) ).
    table->columns(
         )->column( )->text( `Date` )->get_parent(
         )->column( )->text( `Time` )->get_parent(
         )->column( )->text( `Type` )->get_parent(
         )->column( )->text( `ID` )->get_parent(
         )->column( )->text( `No` )->get_parent(
         )->column( )->text( `Message` ).

    table->items( )->column_list_item( )->cells(
       )->text( `{DATE}`
       )->text( `{TIME}`
       )->text( `{TYPE}`
       )->text( `{ID}`
       )->text( `{NUMBER}`
       )->text( `{MESSAGE}` ).

    popup->buttons(
       )->button( text  = `continue`
                  press = client->_event( `BUTTON_CONTINUE` )
                  type  = `Emphasized` ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF client->check_on_init( ).
      view_display( ).
      RETURN.
    ENDIF.

    IF client->check_on_event( `BUTTON_CONTINUE` ).
      client->popup_destroy( ).
      client->nav_app_leave( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
