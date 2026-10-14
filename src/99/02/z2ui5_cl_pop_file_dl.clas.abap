CLASS z2ui5_cl_pop_file_dl DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        i_text                TYPE string DEFAULT `Choose the file to download:`
        i_title               TYPE string DEFAULT `File Download`
        i_button_text_confirm TYPE string DEFAULT `Download`
        i_button_text_cancel  TYPE string DEFAULT `Cancel`
        i_file                TYPE string
        i_type                TYPE string DEFAULT `data:text/csv;base64,`
        i_name                TYPE string OPTIONAL
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
    DATA question_text       TYPE string.
    DATA button_text_confirm TYPE string.
    DATA button_text_cancel  TYPE string.

    METHODS view_display.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_file_dl IMPLEMENTATION.

  METHOD factory.

    DATA lv_size_kb TYPE p LENGTH 8 DECIMALS 2.
    DATA temp4 TYPE string.

    CREATE OBJECT r_result.
    r_result->title               = i_title.

    r_result->question_text       = i_text.
    r_result->button_text_confirm = i_button_text_confirm.
    r_result->button_text_cancel  = i_button_text_cancel.
    r_result->mv_type             = i_type.
    r_result->mv_name             = i_name.
    r_result->mv_value            = i_file.
    " packed target avoids the integer division that displayed 0 for small
    " files, condense drops the trailing sign blank of the conversion
    lv_size_kb                    = strlen( i_file ) / 1000.

    temp4 = lv_size_kb.
    r_result->mv_size             = condense( temp4 ).

  ENDMETHOD.

  METHOD result.

    result = check_confirmed.

  ENDMETHOD.

  METHOD view_display.

    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA dialog TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA popup TYPE REF TO z2ui5_cl_ui5_view_builder.
      DATA lv_csv_x TYPE xstring.
      DATA lv_base64 TYPE string.
    view = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n = `FragmentDefinition` ns = `core`
            )->a( n = `xmlns`       v = `sap.m`
            )->a( n = `xmlns:core`  v = `sap.ui.core`
            )->a( n = `xmlns:html`  v = `http://www.w3.org/1999/xhtml`
            )->a( n = `xmlns:z2ui5` v = `z2ui5.cc` ).


    dialog = view->ele( `Dialog`
        )->a( n = `title`      v = title
        )->a( n = `afterClose` v = client->_event( `BUTTON_CANCEL` ) ).


    popup = dialog->ele( `content` ).

    IF mv_check_download = abap_true.

      lv_csv_x = z2ui5_cl_ui5_util_context=>conv_get_xstring_by_string( mv_value ).

      lv_base64 = z2ui5_cl_ui5_util_context=>conv_encode_x_base64( lv_csv_x ).

      " the hidden iframe IS the download: the browser fetches the data URI
      " and the Timer below reports back once it has
      popup->tag( n = `iframe` ns = `html`
          )->a( n = `src`    v = mv_type && lv_base64
          )->a( n = `hidden` v = `hidden` ).

      popup->tag( n = `Timer` ns = `z2ui5`
          )->a( n = `finished` v = client->_event( `CALLBACK_DOWNLOAD` ) ).
    ENDIF.

    popup->ele( `VBox`
        )->a( n = `class` v = `sapUiMediumMargin`
        )->tag( `Label`
            )->a( n = `text` v = `Name`
        )->tag( `Input`
            )->a( n = `value`   v = mv_name
            )->a( n = `enabled` b = abap_false
        )->tag( `Label`
            )->a( n = `text` v = `Type`
        )->tag( `Input`
            )->a( n = `value`   v = mv_type
            )->a( n = `enabled` b = abap_false
        )->tag( `Label`
            )->a( n = `text` v = `Size`
        )->tag( `Input`
            )->a( n = `value`   v = mv_size
            )->a( n = `enabled` b = abap_false ).

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

    me->client = client.

    IF client->check_on_init( ) IS NOT INITIAL.
      view_display( ).
      RETURN.
    ENDIF.

    CASE client->get( )-event.

      WHEN `CALLBACK_DOWNLOAD`.
        check_confirmed = abap_true.
        client->popup_destroy( ).
        client->nav_app_leave( ).

      WHEN `BUTTON_CONFIRM`.
        mv_check_download = abap_true.
        view_display( ).

      WHEN `BUTTON_CANCEL`.
        client->popup_destroy( ).
        client->nav_app_leave( ).
    ENDCASE.

  ENDMETHOD.

ENDCLASS.
