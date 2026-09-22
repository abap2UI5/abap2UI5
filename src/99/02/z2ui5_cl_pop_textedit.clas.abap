CLASS z2ui5_cl_pop_textedit DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        i_stretch_active TYPE abap_bool DEFAULT abap_true
        i_textarea       TYPE string    OPTIONAL
        i_title          TYPE string    DEFAULT `Editor`
        i_check_editable TYPE abap_bool DEFAULT abap_false
          PREFERRED PARAMETER i_textarea
      RETURNING
        VALUE(r_result)  TYPE REF TO z2ui5_cl_pop_textedit.

    DATA mv_stretch_active TYPE abap_bool.
    DATA mv_title          TYPE string.
    DATA mv_check_editable TYPE abap_bool.

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
    DATA client TYPE REF TO z2ui5_if_client.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_textedit IMPLEMENTATION.

  METHOD factory.

    r_result = NEW #( ).
    r_result->mv_stretch_active = i_stretch_active.
    r_result->ms_result-text = i_textarea.
    r_result->mv_title          = i_title.
    r_result->mv_check_editable = i_check_editable.

  ENDMETHOD.

  METHOD display.

    DATA(popup) = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n = `FragmentDefinition` ns = `core`
            )->a( n = `xmlns`      v = `sap.m`
            )->a( n = `xmlns:core` v = `sap.ui.core` ).

    DATA(dialog) = popup->ele( `Dialog`
        )->a( n = `afterClose` v = client->_event( `BUTTON_TEXTAREA_CANCEL` )
        )->a( n = `stretch`    b = mv_stretch_active
        )->a( n = `title`      v = mv_title
        )->a( n = `icon`       v = `sap-icon://edit` ).

    dialog->ele( `content`
        )->tag( `TextArea`
            )->a( n = `growing`  b = abap_true
            )->a( n = `editable` b = mv_check_editable
            )->a( n = `value`    v = client->_bind( ms_result-text ) ).

    dialog->ele( `buttons`
        )->tag( `Button`
            )->a( n = `text`  v = `Cancel`
            )->a( n = `press` v = client->_event( `BUTTON_TEXTAREA_CANCEL` )
        )->tag( `Button`
            )->a( n = `text`  v = `Confirm`
            )->a( n = `press` v = client->_event( `BUTTON_TEXTAREA_CONFIRM` )
            )->a( n = `type`  v = `Emphasized` ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF client->check_on_init( ).
      display( ).
      RETURN.
    ENDIF.

    CASE client->get( )-event.
      WHEN `BUTTON_TEXTAREA_CONFIRM`.
        ms_result-check_confirmed = abap_true.
        client->popup_destroy( ).
        client->nav_app_leave( ).

      WHEN `BUTTON_TEXTAREA_CANCEL`.
        client->popup_destroy( ).
        client->nav_app_leave( ).

    ENDCASE.

  ENDMETHOD.

  METHOD result.
    result = ms_result.
  ENDMETHOD.

ENDCLASS.
