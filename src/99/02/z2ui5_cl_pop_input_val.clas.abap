CLASS z2ui5_cl_pop_input_val DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        text                TYPE string DEFAULT `Enter New Value`
        val                 TYPE string OPTIONAL
        title               TYPE string DEFAULT `Popup Input Value`
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
    DATA client              TYPE REF TO z2ui5_if_client.
    DATA title               TYPE string.
    DATA question_text       TYPE string.
    DATA button_text_confirm TYPE string.
    DATA button_text_cancel  TYPE string.

    METHODS view_display.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_input_val IMPLEMENTATION.

  METHOD factory.

    CREATE OBJECT r_result.
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

    DATA popup TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA dialog TYPE REF TO z2ui5_cl_ui5_view_builder.
    popup = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n = `FragmentDefinition` ns = `core`
            )->a( n = `xmlns`      v = `sap.m`
            )->a( n = `xmlns:core` v = `sap.ui.core` ).


    dialog = popup->ele( `Dialog`
        )->a( n = `title`      v = title
        )->a( n = `afterClose` v = client->_event( `BUTTON_CANCEL` ) ).

    dialog->ele( `content`
        )->ele( `VBox`
            )->a( n = `class` v = `sapUiMediumMargin`
            )->tag( `Label`
                )->a( n = `text` v = question_text
            )->tag( `Input`
                )->a( n = `value`  v = client->_bind( ms_result-value )
                )->a( n = `submit` v = client->_event( `BUTTON_CONFIRM` ) ).

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
