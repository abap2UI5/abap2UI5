CLASS z2ui5_cl_popup_to_confirm DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        i_question_text       TYPE string
        i_title               TYPE string DEFAULT `Popup To Confirm`
        i_icon                TYPE string DEFAULT 'sap-icon://question-mark'
        i_button_text_confirm TYPE string DEFAULT `OK`
        i_button_text_cancel  TYPE string DEFAULT `Cancel`
      RETURNING
        VALUE(r_result)       TYPE REF TO z2ui5_cl_popup_to_confirm.

    METHODS result
      RETURNING
        VALUE(result) TYPE abap_bool.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.

    DATA title TYPE string.
    DATA icon TYPE string.
    DATA question_text TYPE string.
    DATA button_text_confirm TYPE string.
    DATA button_text_cancel TYPE string.
    DATA check_initialized TYPE abap_bool.
    DATA check_result_confirmed TYPE abap_bool.
    METHODS view_display.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_popup_to_confirm IMPLEMENTATION.


  METHOD result.

    result = check_result_confirmed.

  ENDMETHOD.


  METHOD factory.

    r_result = NEW #( ).

    r_result->title = i_title.
    r_result->icon = i_icon.
    r_result->question_text = i_question_text.
    r_result->button_text_confirm = i_button_text_confirm.
    r_result->button_text_cancel = i_button_text_cancel.

  ENDMETHOD.


  METHOD view_display.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( )->dialog(
                  title       = title
                  icon        = icon
                   afterclose = client->_event( 'BUTTON_CANCEL' )
              )->content(
                  )->vbox( 'sapUiMediumMargin'
                      )->text( question_text
              )->get_parent( )->get_parent(
              )->footer( )->overflow_toolbar(
                  )->toolbar_spacer(
                  )->button(
                      text  = button_text_cancel
                      press = client->_event( 'BUTTON_CANCEL' )
                  )->button(
                      text  = button_text_confirm
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
        check_result_confirmed = abap_true.
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).
      WHEN `BUTTON_CANCEL`.
        check_result_confirmed = abap_false.
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
