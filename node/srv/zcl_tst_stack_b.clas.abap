CLASS zcl_tst_stack_b DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA input        TYPE string.
    DATA input_from_a TYPE string.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
    METHODS view_display.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_tst_stack_b IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    DATA lo_a TYPE REF TO zcl_tst_stack_a.

    me->client = client.

    " the called app of zcl_tst_stack_a - see the comment there
    IF client->check_on_navigated( ).
      view_display( ).

    ELSEIF client->check_on_event( `BACK` ).
      lo_a ?= client->get_app( client->get( )-s_draft-id_prev_app_stack ).
      lo_a->backend_event = `RETURN`.
      client->nav_app_leave( lo_a ).
    ENDIF.

  ENDMETHOD.


  METHOD view_display.
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA page TYPE REF TO z2ui5_cl_ui5_view_builder.

    view = z2ui5_cl_ui5_view_builder=>factory( ).
    page = view->ele( n = `View` ns = `mvc`
        )->a( n = `xmlns`        v = `sap.m`
        )->a( n = `xmlns:mvc`    v = `sap.ui.core.mvc`
        )->ele( `Page`
            )->a( n = `title` v = `STACK B` ).

    page->tag( `Text`
        )->a( n = `text` v = client->_bind( input_from_a ) ).
    page->tag( `Input`
        )->a( n = `value` v = client->_bind( input ) ).
    page->tag( `Button`
        )->a( n = `text`  v = `back`
        )->a( n = `press` v = client->_event( `BACK` ) ).

    client->view_display( view->stringify( ) ).
  ENDMETHOD.

ENDCLASS.
