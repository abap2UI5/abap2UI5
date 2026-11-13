CLASS z2ui5_cl_pop_pdf DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        i_title               TYPE string DEFAULT `PDF Viewer`
        i_button_text_confirm TYPE string DEFAULT `OK`
        i_button_text_cancel  TYPE string DEFAULT `Cancel`
        i_pdf                 TYPE string
        i_label               TYPE string OPTIONAL
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
    DATA client              TYPE REF TO z2ui5_if_client.
    DATA title               TYPE string.
    DATA question_text       TYPE string.
    DATA button_text_confirm TYPE string.
    DATA button_text_cancel  TYPE string.

    METHODS view_display.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_pdf IMPLEMENTATION.

  METHOD factory.

    CREATE OBJECT r_result.
    r_result->title               = i_title.
    r_result->question_text       = i_label.
    r_result->button_text_confirm = i_button_text_confirm.
    r_result->button_text_cancel  = i_button_text_cancel.
    r_result->mv_pdf              = i_pdf.

  ENDMETHOD.

  METHOD result.

    result = ms_result.

  ENDMETHOD.

  METHOD view_display.

    DATA popup TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA dialog TYPE REF TO z2ui5_cl_ui5_view_builder.
    popup = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n = `FragmentDefinition` ns = `core`
            )->a( n = `xmlns`      v = `sap.m`
            )->a( n = `xmlns:core` v = `sap.ui.core`
            )->a( n = `xmlns:html` v = `http://www.w3.org/1999/xhtml` ).


    dialog = popup->ele( `Dialog`
        )->a( n = `title`      v = title
        )->a( n = `stretch`    b = abap_true
        )->a( n = `afterClose` v = client->_event( `BUTTON_CANCEL` ) ).

    dialog->ele( `content`
        )->ele( `VBox`
            )->a( n = `class` v = `sapUiMediumMargin`
            )->tag( `Label`
                )->a( n = `text` v = question_text
            )->tag( n = `iframe` ns = `html`
                )->a( n = `src`    v = mv_pdf
                )->a( n = `height` v = `800px`
                )->a( n = `width`  v = `99%` ).

    dialog->ele( `buttons`
        )->tag( `Button`
            )->a( n = `text`  v = button_text_cancel
            )->a( n = `press` v = client->_event( `BUTTON_CANCEL` )
        )->tag( `Button`
            )->a( n = `text`  v = button_text_confirm
            )->a( n = `press` v = client->_event( `BUTTON_CONFIRM` )
            )->a( n = `type`  v = `Emphasized` ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.
    DATA lv_event TYPE z2ui5_if_client=>ty_s_get-event.
        DATA temp1 TYPE xsdboolean.

    me->client = client.

    IF client->check_on_init( ) IS NOT INITIAL.
      view_display( ).
      RETURN.
    ENDIF.


    lv_event = client->get( )-event.
    CASE lv_event.

      WHEN `BUTTON_CONFIRM` OR `BUTTON_CANCEL`.

        temp1 = boolc( lv_event = `BUTTON_CONFIRM` ).
        ms_result-check_confirmed = temp1.
        client->popup_destroy( ).
        client->nav_app_leave( ).
    ENDCASE.

  ENDMETHOD.

ENDCLASS.
