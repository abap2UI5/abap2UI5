CLASS z2ui5_cl_pop_bal DEFINITION
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
        time       TYPE string,
        date       TYPE string,
        message    TYPE string,
        message_v1 TYPE string,
        message_v2 TYPE string,
        message_v3 TYPE string,
        message_v4 TYPE string,
        group      TYPE string,
      END OF ty_s_msg.
    TYPES ty_t_msg TYPE STANDARD TABLE OF ty_s_msg WITH DEFAULT KEY.

    DATA mt_msg TYPE ty_t_msg.

    CLASS-METHODS factory
      IMPORTING
        i_messages      TYPE any
        i_title         TYPE string DEFAULT `abap2UI5 - Business Application Log`
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_pop_bal.

  PROTECTED SECTION.
    DATA client            TYPE REF TO z2ui5_if_client.
    DATA title             TYPE string.
    DATA check_initialized TYPE abap_bool.

    METHODS view_display.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_bal IMPLEMENTATION.
  METHOD factory.
    DATA lt_msg TYPE z2ui5_cl_util=>ty_t_msg.
    DATA temp1 LIKE LINE OF lt_msg.
    DATA lr_row LIKE REF TO temp1.
      DATA temp2 TYPE ty_s_msg.
      DATA ls_row LIKE temp2.

    CREATE OBJECT r_result.

    "read log infos
    "handle
    "..

    "read messages..
    
    lt_msg = z2ui5_cl_util=>msg_get_t( i_messages ).
    
    
    LOOP AT lt_msg REFERENCE INTO lr_row.

      
      CLEAR temp2.
      
      ls_row = temp2.
      ls_row-type       = z2ui5_cl_util=>ui5_get_msg_type( lr_row->type ).
      ls_row-title      = lr_row->text.
      ls_row-id         = lr_row->id.
      ls_row-number     = lr_row->no.
      ls_row-message_v1 = lr_row->v1.
      ls_row-message_v2 = lr_row->v2.
      ls_row-message_v3 = lr_row->v3.
      ls_row-message_v4 = lr_row->v4.
      ls_row-message    = lr_row->text.
      ls_row-subtitle   = |{ lr_row->id } { lr_row->no }|.
      ls_row-date       = z2ui5_cl_util=>time_get_date_by_stampl( lr_row->timestampl ).
      ls_row-time       = z2ui5_cl_util=>time_get_time_by_stampl( lr_row->timestampl ).
*      lr_row->group = `001`.

      INSERT ls_row INTO TABLE r_result->mt_msg.
    ENDLOOP.

    r_result->title = i_title.

  ENDMETHOD.

  METHOD view_display.

    DATA popup TYPE REF TO z2ui5_cl_xml_view.
    DATA table TYPE REF TO z2ui5_cl_xml_view.
    popup = z2ui5_cl_xml_view=>factory_popup( ).
    popup = popup->dialog( title             = `Business Application Log`
                           contentheight     = '50%'
                           contentwidth      = '50%'
                           verticalscrolling = abap_false
                           afterclose        = client->_event( 'BUTTON_CONTINUE' ) ).

    
    table = popup->table( client->_bind( mt_msg ) ).
    table->columns(
         )->column( )->text( 'Date' )->get_parent(
         )->column( )->text( 'Time' )->get_parent(
         )->column( )->text( 'Type' )->get_parent(
         )->column( )->text( 'ID' )->get_parent(
         )->column( )->text( 'No' )->get_parent(
         )->column( )->text( 'Message' ).

    table->items( )->column_list_item( )->cells(
       )->text( '{DATE}'
       )->text( '{TIME}'
       )->text( '{TYPE}'
       )->text( '{ID}'
       )->text( '{NUMBER}'
       )->text( '{MESSAGE}'
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
