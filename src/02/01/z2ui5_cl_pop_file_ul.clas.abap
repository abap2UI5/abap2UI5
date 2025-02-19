CLASS z2ui5_cl_pop_file_ul DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        i_text                TYPE string DEFAULT `Choose the file to upload:`
        i_title               TYPE string DEFAULT `File Upload`
        i_button_text_confirm TYPE string DEFAULT `OK`
        i_button_text_cancel  TYPE string DEFAULT `Cancel`
        i_path                TYPE string OPTIONAL
      RETURNING
        VALUE(r_result)       TYPE REF TO z2ui5_cl_pop_file_ul.

    TYPES:
      BEGIN OF ty_s_result,
        value           TYPE string,
        check_confirmed TYPE abap_bool,
      END OF ty_s_result.

    DATA ms_result             TYPE ty_s_result.
    DATA mv_path               TYPE string.
    DATA mv_value              TYPE string.
    DATA check_confirm_enabled TYPE abap_bool.

    METHODS result
      RETURNING
        VALUE(result) TYPE ty_s_result.

  PROTECTED SECTION.
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


CLASS z2ui5_cl_pop_file_ul IMPLEMENTATION.
  METHOD factory.

    r_result = NEW #( ).
    r_result->title               = i_title.

    r_result->question_text       = i_text.
    r_result->button_text_confirm = i_button_text_confirm.
    r_result->button_text_cancel  = i_button_text_cancel.
    r_result->mv_path             = i_path.

  ENDMETHOD.

  METHOD result.

    result = ms_result.

  ENDMETHOD.

  METHOD view_display.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( )->dialog( title      = title
                                                               icon       = icon
                                                               afterclose = client->_event( 'BUTTON_CANCEL' )
              )->content(
                  )->vbox( 'sapUiMediumMargin'
                  )->label( question_text
                  )->_z2ui5( )->file_uploader( value       = client->_bind_edit( mv_value )
                                               path        = client->_bind_edit( mv_path )
                                               placeholder = 'filepath here...'
                                               upload      = client->_event( 'UPLOAD' )
              )->get_parent( )->get_parent(
              )->buttons(
                  )->button( text  = button_text_cancel
                             press = client->_event( 'BUTTON_CANCEL' )
                  )->button( text    = button_text_confirm
                             press   = client->_event( 'BUTTON_CONFIRM' )
                             enabled = client->_bind( check_confirm_enabled )
                             type    = 'Emphasized' ).

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

      WHEN `UPLOAD`.

        SPLIT mv_value AT `;` INTO DATA(lv_dummy) DATA(lv_data).
        SPLIT lv_data AT `,` INTO lv_dummy lv_data.

        DATA(lv_data2) = z2ui5_cl_util=>conv_decode_x_base64( lv_data ).
        ms_result-value = z2ui5_cl_util=>conv_get_string_by_xstring( lv_data2 ).
        check_confirm_enabled = abap_true.

        CLEAR mv_value.
        CLEAR mv_path.
        client->popup_model_update( ).

      WHEN `BUTTON_CONFIRM`.
        ms_result-check_confirmed = abap_true.
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).
      WHEN `BUTTON_CANCEL`.
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
