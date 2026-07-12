CLASS z2ui5_cl_pop_file_ul DEFINITION PUBLIC.

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
    DATA question_text       TYPE string.
    DATA button_text_confirm TYPE string.
    DATA button_text_cancel  TYPE string.

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
                                                               afterclose = client->_event( `BUTTON_CANCEL` )
              )->content(
                  )->vbox( `sapUiMediumMargin`
                  )->label( question_text
                  )->_z2ui5( )->file_uploader( value       = client->_bind_edit( mv_value )
                                               path        = client->_bind_edit( mv_path )
                                               placeholder = `filepath here...`
                                               upload      = client->_event( `UPLOAD` )
              )->get_parent( )->get_parent(
              )->buttons(
                  )->button( text  = button_text_cancel
                             press = client->_event( `BUTTON_CANCEL` )
                  )->button( text    = button_text_confirm
                             press   = client->_event( `BUTTON_CONFIRM` )
                             enabled = client->_bind( check_confirm_enabled )
                             type    = `Emphasized` ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF client->check_on_init( ).
      view_display( ).
      RETURN.
    ENDIF.

    DATA(lv_event) = client->get( )-event.
    CASE lv_event.

      WHEN `UPLOAD`.

        DATA(lv_data) = z2ui5_cl_a2ui5_context=>conv_get_xstring_by_data_uri( mv_value ).
        ms_result-value = z2ui5_cl_a2ui5_context=>conv_get_string_by_xstring( lv_data ).
        check_confirm_enabled = abap_true.

        CLEAR mv_value.
        CLEAR mv_path.
        client->popup_model_update( ).

      WHEN `BUTTON_CONFIRM` OR `BUTTON_CANCEL`.
        ms_result-check_confirmed = xsdbool( lv_event = `BUTTON_CONFIRM` ).
        client->popup_destroy( ).
        client->nav_app_leave( ).
    ENDCASE.

  ENDMETHOD.

ENDCLASS.
