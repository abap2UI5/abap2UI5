CLASS z2ui5_cl_pop_input_val DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        !text               TYPE string DEFAULT `Enter New Value`
        val                 TYPE string OPTIONAL
        !title              TYPE string DEFAULT `Popup Input Value`
        button_text_confirm TYPE string DEFAULT `OK`
        button_text_cancel  TYPE string DEFAULT `Cancel`
          PREFERRED PARAMETER val
      RETURNING
        VALUE(r_result)     TYPE REF TO z2ui5_cl_pop_input_val.

    TYPES:
      BEGIN OF ty_s_result,
        value           TYPE string,
        check_confirmed TYPE abap_bool,
      END OF ty_s_result.

    DATA ms_result TYPE ty_s_result.

    METHODS result
      RETURNING
        VALUE(result) TYPE ty_s_result.

  PROTECTED SECTION.
    DATA client                 TYPE REF TO z2ui5_if_client.
    DATA title                  TYPE string.
    DATA icon                   TYPE string.
    DATA question_text          TYPE string.
    DATA button_text_confirm    TYPE string.
    DATA button_text_cancel     TYPE string.
    DATA check_initialized      TYPE abap_bool.

    METHODS view_display.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_input_val IMPLEMENTATION.
  METHOD factory.

    r_result = NEW #( ).
    r_result->title               = title.

    r_result->question_text       = text.
    r_result->button_text_confirm = button_text_confirm.
    r_result->button_text_cancel  = button_text_cancel.
    r_result->ms_result-value = val.

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
                  )->input( value  = client->_bind_edit( ms_result-value )
                            submit = client->_event( 'BUTTON_CONFIRM' )
              )->get_parent( )->get_parent(
              )->buttons(
                  )->button( text  = button_text_cancel
                             press = client->_event( 'BUTTON_CANCEL' )
                  )->button( text  = button_text_confirm
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
      WHEN `BUTTON_CONFIRM`.
        ms_result-check_confirmed = abap_true.
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).
      WHEN `BUTTON_CANCEL`.
        ms_result-check_confirmed = abap_false.
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
