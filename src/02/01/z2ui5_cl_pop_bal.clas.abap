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
    TYPES ty_t_msg TYPE STANDARD TABLE OF ty_s_msg WITH DEFAULT KEY.

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
    DATA temp9 TYPE z2ui5_cl_util=>ty_t_msg.
    DATA temp1 LIKE LINE OF temp9.
    DATA lr_row LIKE REF TO temp1.
      DATA temp10 TYPE ty_s_msg.

    CREATE OBJECT r_result.

    
    temp9 = z2ui5_cl_util=>msg_get_t( i_messages ).
    
    
    LOOP AT temp9 REFERENCE INTO lr_row.
      
      CLEAR temp10.
      temp10-type = z2ui5_cl_util=>ui5_get_msg_type( lr_row->type ).
      temp10-title = lr_row->text.
      temp10-id = lr_row->id.
      temp10-number = lr_row->no.
      temp10-message_v1 = lr_row->v1.
      temp10-message_v2 = lr_row->v2.
      temp10-message_v3 = lr_row->v3.
      temp10-message_v4 = lr_row->v4.
      temp10-message = lr_row->text.
      temp10-subtitle = |{ lr_row->id } { lr_row->no }|.
      temp10-date = z2ui5_cl_util=>time_get_date_by_stampl( lr_row->timestampl ).
      temp10-time = z2ui5_cl_util=>time_get_time_by_stampl( lr_row->timestampl ).
      INSERT temp10 INTO TABLE r_result->mt_msg.
    ENDLOOP.

    r_result->title = i_title.

  ENDMETHOD.

  METHOD view_display.

    DATA popup TYPE REF TO z2ui5_cl_xml_view.
    DATA table TYPE REF TO z2ui5_cl_xml_view.
    popup = z2ui5_cl_xml_view=>factory_popup( ).
    popup = popup->dialog( title             = title
                           contentheight     = `50%`
                           contentwidth      = `50%`
                           verticalscrolling = abap_false
                           afterclose        = client->_event( `BUTTON_CONTINUE` ) ).

    
    table = popup->table( client->_bind( mt_msg ) ).
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
       )->button( text  = `Continue`
                  press = client->_event( `BUTTON_CONTINUE` )
                  type  = `Emphasized` ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF client->check_on_init( ) IS NOT INITIAL.
      view_display( ).
      RETURN.
    ENDIF.

    IF client->check_on_event( `BUTTON_CONTINUE` ) IS NOT INITIAL.
      client->popup_destroy( ).
      client->nav_app_leave( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
