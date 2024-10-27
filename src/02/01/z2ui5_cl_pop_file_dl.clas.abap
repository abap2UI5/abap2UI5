CLASS z2ui5_cl_pop_file_dl DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        i_text                TYPE string DEFAULT `Choose the file to upload:`
        i_title               TYPE string DEFAULT `File Download`
        i_button_text_confirm TYPE string DEFAULT `OK`
        i_button_text_cancel  TYPE string DEFAULT `Cancel`
        i_file                TYPE string
        i_type                TYPE string DEFAULT `data:text/csv;base64,`
      RETURNING
        VALUE(r_result)       TYPE REF TO z2ui5_cl_pop_file_dl.

    DATA mv_name           TYPE string.
    DATA mv_type           TYPE string.
    DATA mv_size           TYPE string.
    DATA mv_value          TYPE string.
    DATA mv_check_download TYPE abap_bool.

    METHODS result
      RETURNING
        VALUE(result) TYPE abap_bool.

  PROTECTED SECTION.
    DATA check_confirmed     TYPE abap_bool.
    DATA client              TYPE REF TO z2ui5_if_client.
    DATA title               TYPE string.
    DATA icon                TYPE string.
    DATA question_text       TYPE string.
    DATA button_text_confirm TYPE string.
    DATA button_text_cancel  TYPE string.
    DATA check_initialized   TYPE abap_bool.

    METHODS view_display.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_file_dl IMPLEMENTATION.
  METHOD factory.

    r_result = NEW #( ).
    r_result->title               = i_title.

    r_result->question_text       = i_text.
    r_result->button_text_confirm = i_button_text_confirm.
    r_result->button_text_cancel  = i_button_text_cancel.
    r_result->mv_type             = i_type.
    r_result->mv_value            = i_file.
    r_result->mv_size             = strlen( i_file ) / 1000.

  ENDMETHOD.

  METHOD result.

    result = check_confirmed.

  ENDMETHOD.

  METHOD view_display.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( )->dialog( title      = title
                                                               icon       = icon
                                                               afterclose = client->_event( 'BUTTON_CANCEL' )
              )->content( ).

    IF mv_check_download = abap_true.
      DATA(lv_csv_x) = z2ui5_cl_util=>conv_get_xstring_by_string( mv_value ).
      DATA(lv_base64) = z2ui5_cl_util=>conv_encode_x_base64( lv_csv_x ).
      popup->_generic( ns     = `html`
                       name   = `iframe`
                       t_prop = VALUE #( ( n = `src` v = mv_type && lv_base64 )
                                         ( n = `hidden` v = `hidden` ) ) ).

      popup->_z2ui5( )->timer( client->_event( `CALLBACK_DOWNLOAD` ) ).

    ENDIF.

    popup->vbox( 'sapUiMediumMargin'
      )->label( `Name`
      )->input( value   = mv_name
                enabled = abap_false
      )->label( `Type`
      )->input( value   = mv_type
                enabled = abap_false
      )->label( `Size`
      )->input( value   = mv_size
                enabled = abap_false
      )->get_parent( )->get_parent(
      )->buttons(
      )->button( text  = button_text_cancel
                 press = client->_event( 'BUTTON_CANCEL' )
      )->button( text  = `Download`
                 press = client->_event( 'BUTTON_CONFIRM' )
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

      WHEN `CALLBACK_DOWNLOAD`.
        check_confirmed = abap_true.
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN `BUTTON_CONFIRM`.
        mv_check_download = abap_true.
        view_display( ).

      WHEN `BUTTON_CANCEL`.
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
