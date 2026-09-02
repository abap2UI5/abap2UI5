CLASS zcl_tst_popup_app DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_row,
        app   TYPE string,
        class TYPE string,
        descr TYPE string,
      END OF ty_row.

    " the popup app's ONLY bound attribute - the caller's table is nowhere
    " in this app's model, which is the whole point of the fixture
    DATA ms_data_row TYPE ty_row.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
ENDCLASS.


CLASS zcl_tst_popup_app IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    DATA popup  TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA dialog TYPE REF TO z2ui5_cl_ui5_view_builder.

    me->client = client.

    IF client->check_on_init( ) = abap_false.
      RETURN.
    ENDIF.

    " a called app that displays a POPUP and no main view at all - the shape
    " every z2ui5_cl_pop_* has, and the one the reported app uses
    popup = z2ui5_cl_ui5_view_builder=>factory( ).
    dialog = popup->ele( n = `FragmentDefinition` ns = `core`
        )->a( n = `xmlns`      v = `sap.m`
        )->a( n = `xmlns:core` v = `sap.ui.core`
        )->ele( `Dialog`
            )->a( n = `title` v = `Edit` ).

    dialog->tag( `Input`
        )->a( n = `value` v = client->_bind( ms_data_row-class ) ).
    dialog->tag( `Input`
        )->a( n = `value` v = client->_bind( ms_data_row-descr ) ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

ENDCLASS.
