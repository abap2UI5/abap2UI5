CLASS z2ui5_cl_popup_textedit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        i_stretch_active TYPE abap_bool DEFAULT abap_true
        i_textarea       TYPE string OPTIONAL
          PREFERRED PARAMETER i_textarea
      RETURNING
        VALUE(r_result)  TYPE REF TO z2ui5_cl_popup_textedit.

    DATA client TYPE REF TO z2ui5_if_client.
    DATA mv_stretch_active TYPE abap_bool.
    DATA check_initialized TYPE abap_bool.
    TYPES:
      BEGIN OF ty_s_result,
        text            TYPE string,
        check_confirmed TYPE abap_bool,
      END OF ty_s_result.
    DATA ms_result TYPE ty_s_result.

    METHODS display.

    METHODS result
      RETURNING
        VALUE(result) TYPE ty_s_result.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_popup_textedit IMPLEMENTATION.

  METHOD factory.

    r_result = NEW #( ).
    r_result->mv_stretch_active = i_stretch_active.
    r_result->ms_result-text = i_textarea.

  ENDMETHOD.

  METHOD display.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( )->dialog(
              afterclose = client->_event( 'BUTTON_TEXTAREA_CANCEL' )
              stretch    = mv_stretch_active
              title      = 'Title'
              icon       = 'sap-icon://edit'
          )->content(
              )->text_area(
*                  height = '100%'
                  width = '100%'
                  value = client->_bind_edit( ms_result-text )
          )->get_parent(
          )->footer( )->overflow_toolbar(
              )->toolbar_spacer(
              )->button(
                  text  = 'Cancel'
                  press = client->_event( 'BUTTON_TEXTAREA_CANCEL' )
              )->button(
                  text  = 'Confirm'
                  press = client->_event( 'BUTTON_TEXTAREA_CONFIRM' )
                  type  = 'Emphasized' ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    me->client = client.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      display( ).
      RETURN.
    ENDIF.

    CASE client->get( )-event.
      WHEN `BUTTON_TEXTAREA_CONFIRM`.
        ms_result-check_confirmed = abap_true.
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN `BUTTON_TEXTAREA_CANCEL`.
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

    ENDCASE.

  ENDMETHOD.

  METHOD result.
    result = ms_result.
  ENDMETHOD.

ENDCLASS.
