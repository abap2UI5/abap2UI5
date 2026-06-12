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

    DATA mt_msg       TYPE ty_t_msg.
    DATA mt_msg_bal   TYPE z2ui5_cl_util=>ty_t_msg.
    DATA mv_object    TYPE string.
    DATA mv_subobject TYPE string.
    DATA mv_extnumber TYPE string.
    DATA mv_check_save TYPE abap_bool.

    CLASS-METHODS factory
      IMPORTING
        i_messages      TYPE any
        i_title         TYPE string DEFAULT `abap2UI5 - Business Application Log`
        i_object        TYPE clike OPTIONAL
        i_subobject     TYPE clike OPTIONAL
        i_extnumber     TYPE clike OPTIONAL
        i_check_save    TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_pop_bal.

    CLASS-METHODS factory_by_db
      IMPORTING
        i_object        TYPE clike
        i_subobject     TYPE clike OPTIONAL
        i_extnumber     TYPE clike OPTIONAL
        i_title         TYPE string DEFAULT `abap2UI5 - Business Application Log`
        i_check_save    TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_pop_bal.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
    DATA title  TYPE string.

    METHODS view_display.
    METHODS on_event_save.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_bal IMPLEMENTATION.

  METHOD factory.

    r_result = NEW #( ).

    r_result->mt_msg_bal = z2ui5_cl_util=>msg_get_t( i_messages ).

    LOOP AT r_result->mt_msg_bal REFERENCE INTO DATA(lr_row).
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

    r_result->title         = i_title.
    r_result->mv_object     = i_object.
    r_result->mv_subobject  = i_subobject.
    r_result->mv_extnumber  = i_extnumber.
    r_result->mv_check_save = i_check_save.

  ENDMETHOD.

  METHOD factory_by_db.

    r_result = factory( i_messages   = z2ui5_cl_util=>bal_read( object    = i_object
                                                                subobject = i_subobject
                                                                id        = i_extnumber )
                        i_title      = i_title
                        i_object     = i_object
                        i_subobject  = i_subobject
                        i_extnumber  = i_extnumber
                        i_check_save = i_check_save ).

  ENDMETHOD.

  METHOD view_display.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( ).
    popup = popup->dialog( title             = title
                           contentheight     = `50%`
                           contentwidth      = `50%`
                           verticalscrolling = abap_false
                           afterclose        = client->_event( `BUTTON_CONTINUE` ) ).

    IF mv_check_save = abap_true.
      popup->overflow_toolbar(
          )->label( `Object`
          )->input( value = client->_bind_edit( mv_object )
                    width = `10rem`
          )->label( `Subobject`
          )->input( value = client->_bind_edit( mv_subobject )
                    width = `10rem`
          )->label( `External Number`
          )->input( value = client->_bind_edit( mv_extnumber )
                    width = `10rem` ).
    ENDIF.

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

    DATA(buttons) = popup->buttons( ).
    IF mv_check_save = abap_true.
      buttons->button( text  = `Save`
                       press = client->_event( `BUTTON_SAVE` ) ).
    ENDIF.
    buttons->button( text  = `Continue`
                     press = client->_event( `BUTTON_CONTINUE` )
                     type  = `Emphasized` ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD on_event_save.

    IF mv_object IS INITIAL.
      client->message_box_display( text = `Enter an object before saving the log`
                                   type = `error` ).
      RETURN.
    ENDIF.

    TRY.
        z2ui5_cl_util=>bal_create( object    = mv_object
                                   subobject = mv_subobject
                                   id        = mv_extnumber
                                   t_log     = mt_msg_bal ).
        client->message_toast_display( `Business Application Log saved` ).
      CATCH cx_root INTO DATA(x).
        client->message_box_display( text = x->get_text( )
                                     type = `error` ).
    ENDTRY.

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF client->check_on_init( ).
      view_display( ).
      RETURN.
    ENDIF.

    IF client->check_on_event( `BUTTON_SAVE` ).
      on_event_save( ).
      RETURN.
    ENDIF.

    IF client->check_on_event( `BUTTON_CONTINUE` ).
      client->popup_destroy( ).
      client->nav_app_leave( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
