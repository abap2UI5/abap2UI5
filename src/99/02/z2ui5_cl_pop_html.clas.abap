CLASS z2ui5_cl_pop_html DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        i_html          TYPE string
        i_title         TYPE string DEFAULT `HTML View`
        i_icon          TYPE string DEFAULT `sap-icon://hint`
        i_button_text   TYPE string DEFAULT `OK`
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_pop_html.

  PROTECTED SECTION.
    DATA client              TYPE REF TO z2ui5_if_client.
    DATA title               TYPE string.
    DATA icon                TYPE string.
    DATA html                TYPE string.
    DATA button_text_confirm TYPE string.

    METHODS view_display.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_html IMPLEMENTATION.

  METHOD factory.

    CREATE OBJECT r_result.
    r_result->title               = i_title.
    r_result->icon                = i_icon.
    r_result->html                = i_html.
    r_result->button_text_confirm = i_button_text.

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
        )->a( n = `icon`       v = icon
        )->a( n = `afterClose` v = client->_event( `BUTTON_CONFIRM` ) ).

    dialog->ele( `content`
        )->ele( `VBox`
            )->a( n = `class` v = `sapUiMediumMargin`
            )->tag( n = `HTML` ns = `core`
                )->a( n = `content` v = html ).

    dialog->ele( `buttons`
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

    IF client->check_on_event( `BUTTON_CONFIRM` ) IS NOT INITIAL.
      client->popup_destroy( ).
      client->nav_app_leave( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
