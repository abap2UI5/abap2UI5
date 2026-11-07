CLASS z2ui5_cl_pop_error DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        x_root          TYPE REF TO cx_root
        i_title         TYPE string DEFAULT `Error`
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_pop_error.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
    DATA error  TYPE REF TO cx_root.
    DATA title  TYPE string.

    METHODS view_display.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_error IMPLEMENTATION.

  METHOD factory.

    CREATE OBJECT r_result.
    r_result->error = x_root.
    r_result->title = i_title.

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
        )->a( n = `afterClose` v = client->_event( `BUTTON_CONFIRM` ) ).

    dialog->ele( `content`
        )->ele( `VBox`
            )->a( n = `class` v = `sapUiMediumMargin`
            )->tag( `Text`
                )->a( n = `text` v = error->get_text( ) ).

    dialog->ele( `buttons`
        )->tag( `Button`
            )->a( n = `text`  v = `OK`
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
