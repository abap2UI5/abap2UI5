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

    IF client->check_on_event( ).
      CASE client->get_event( ).
        WHEN `UPPER`.
          " an event that changes the model and displays NOTHING: the
          " framework pushes the changed model by itself, and that push
          " belongs to this app's popup alone
          ms_data_row-descr = to_upper( ms_data_row-descr ).
        WHEN `NEXT`.
          " a popup opening a popup: the chain hands over to another
          " instance of this class (the caller's table is two hops away now)
          DATA lo_next TYPE REF TO zcl_tst_popup_app.
          CREATE OBJECT lo_next.
          lo_next->ms_data_row = VALUE #( app   = `CHAIN`
                                          class = `CHAIN`
                                          descr = `second popup` ).
          client->nav_app_call( lo_next ).
        WHEN `CLOSE`.
          client->popup_destroy( ).
          client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).
      ENDCASE.
      RETURN.
    ENDIF.

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

    dialog->ele( `buttons`
        )->tag( `Button`
            )->a( n = `text`  v = `Upper`
            )->a( n = `press` v = client->_event( `UPPER` )
        )->tag( `Button`
            )->a( n = `text`  v = `Next`
            )->a( n = `press` v = client->_event( `NEXT` )
        )->tag( `Button`
            )->a( n = `text`  v = `Close`
            )->a( n = `press` v = client->_event( `CLOSE` ) ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

ENDCLASS.
