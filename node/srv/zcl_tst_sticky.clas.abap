CLASS zcl_tst_sticky DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA hits TYPE i.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
    METHODS view_display.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_tst_sticky IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    me->client = client.

    " Fixture of the stateful-session spec (node/tests/sessions.spec.js): an
    " app that switches the stateful session on at its first start and
    " counts its events in the instance the session keeps. STOP switches the
    " session off again. Any other client must never be answered by it - on
    " an SAP system the session is the browser's roll area, in a Node
    " process the host keeps one per sap-contextid (node/srv/host.mjs)
    IF client->check_on_init( ).
      client->set_session_stateful( ).
      view_display( ).

    ELSEIF client->check_on_navigated( ).
      view_display( ).

    ELSEIF client->check_on_event( `HIT` ).
      hits = hits + 1.

    ELSEIF client->check_on_event( `STOP` ).
      client->set_session_stateful( abap_false ).
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
            )->a( n = `title` v = `STICKY` ).

    page->tag( `Text`
        )->a( n = `text` v = client->_bind( hits ) ).
    page->tag( `Button`
        )->a( n = `text`  v = `hit`
        )->a( n = `press` v = client->_event( `HIT` ) ).
    page->tag( `Button`
        )->a( n = `text`  v = `stop`
        )->a( n = `press` v = client->_event( `STOP` ) ).

    client->view_display( view->stringify( ) ).
  ENDMETHOD.

ENDCLASS.
