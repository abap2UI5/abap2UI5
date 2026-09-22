CLASS z2ui5_cl_pop_to_confirm DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    CONSTANTS:
      BEGIN OF cs_event,
        confirmed TYPE string VALUE `z2ui5_cl_pop_to_confirm_confirmed`,
        canceled  TYPE string VALUE `z2ui5_cl_pop_to_confirm_canceled`,
      END OF cs_event.

    CLASS-METHODS factory
      IMPORTING
        i_question_text       TYPE string
        i_title               TYPE string DEFAULT `Popup To Confirm`
        i_icon                TYPE string DEFAULT `sap-icon://question-mark`
        i_button_text_confirm TYPE string DEFAULT `OK`
        i_button_text_cancel  TYPE string DEFAULT `Cancel`
        i_event_confirm       TYPE string DEFAULT cs_event-confirmed
        i_event_cancel        TYPE string DEFAULT cs_event-canceled
      RETURNING
        VALUE(r_result)       TYPE REF TO z2ui5_cl_pop_to_confirm.

    METHODS result
      RETURNING
        VALUE(result) TYPE abap_bool.

  PROTECTED SECTION.
    DATA client                 TYPE REF TO z2ui5_if_client.

    DATA title                  TYPE string.
    DATA icon                   TYPE string.
    DATA question_text          TYPE string.
    DATA button_text_confirm    TYPE string.
    DATA button_text_cancel     TYPE string.
    DATA check_result_confirmed TYPE abap_bool.
    DATA event_confirm          TYPE string.
    DATA event_canceled         TYPE string.

    METHODS view_display.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_to_confirm IMPLEMENTATION.

  METHOD result.

    result = check_result_confirmed.

  ENDMETHOD.

  METHOD factory.

    r_result = NEW #( ).

    r_result->title               = i_title.
    r_result->icon                = i_icon.
    r_result->question_text       = i_question_text.
    r_result->button_text_confirm = i_button_text_confirm.
    r_result->button_text_cancel  = i_button_text_cancel.
    r_result->event_confirm       = i_event_confirm.
    r_result->event_canceled      = i_event_cancel.

  ENDMETHOD.

  METHOD view_display.

    DATA(popup) = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n = `FragmentDefinition` ns = `core`
            )->a( n = `xmlns`      v = `sap.m`
            )->a( n = `xmlns:core` v = `sap.ui.core` ).

    DATA(dialog) = popup->ele( `Dialog`
        )->a( n = `title`      v = title
        )->a( n = `icon`       v = icon
        )->a( n = `afterClose` v = client->_event( `BUTTON_CANCEL` ) ).

    dialog->ele( `content`
        )->ele( `VBox`
            )->a( n = `class` v = `sapUiMediumMargin`
            )->tag( `Text`
                )->a( n = `text` v = question_text ).

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

    IF client->check_on_init( ).
      view_display( ).
      RETURN.
    ENDIF.

    CASE client->get( )-event.
      WHEN `BUTTON_CONFIRM`.
        check_result_confirmed = abap_true.
        client->popup_destroy( ).
        client->nav_app_leave( app   = client->get_app_prev( )
                               event = event_confirm ).

      WHEN `BUTTON_CANCEL`.
        check_result_confirmed = abap_false.
        client->popup_destroy( ).
        client->nav_app_leave( app   = client->get_app_prev( )
                               event = event_canceled ).
    ENDCASE.

  ENDMETHOD.

ENDCLASS.
