CLASS z2ui5_cl_pop_pdf DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        i_title               TYPE string DEFAULT `PDF Viewer`
        i_button_text_confirm TYPE string DEFAULT `OK`
        i_button_text_cancel  TYPE string DEFAULT `Cancel`
        i_pdf                 TYPE string
      RETURNING
        VALUE(r_result)       TYPE REF TO z2ui5_cl_pop_pdf.

    TYPES:
      BEGIN OF ty_s_result,
        text            TYPE string,
        check_confirmed TYPE abap_bool,
      END OF ty_s_result.

    DATA ms_result TYPE ty_s_result.

    DATA mv_pdf    TYPE string.

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
    DATA check_result_confirmed TYPE abap_bool.

    METHODS view_display.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_pdf IMPLEMENTATION.
  METHOD factory.

    r_result = NEW #( ).
    r_result->title               = i_title.
    r_result->button_text_confirm = i_button_text_confirm.
    r_result->button_text_cancel  = i_button_text_cancel.
    r_result->mv_pdf              = i_pdf.

  ENDMETHOD.

  METHOD result.

    result = ms_result.

  ENDMETHOD.

  METHOD view_display.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( )->dialog( title      = title
                                                               icon       = icon
                                                               stretch    = abap_true
                                                               afterclose = client->_event( 'BUTTON_CANCEL' )
              )->content(
                  )->vbox( 'sapUiMediumMargin'
                  )->label( question_text
                  )->_generic( ns     = `html`
                               name   = `iframe`
                               t_prop = VALUE #( ( n = `src`    v = mv_pdf )
                                                 ( n = `height` v = `800px` )
                                                 ( n = `width`  v = `99%` )
                           )
              )->get_parent( )->get_parent( )->get_parent(
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
