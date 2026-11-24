CLASS zcl_tst_timer_set DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA polls TYPE i.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
    METHODS view_display.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_tst_timer_set IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    me->client = client.

    " e2e fixture for client->timer_set( ) (timer-set spec): the poll is
    " DECLARED once, in check_on_init, and the app never arms, stops or
    " re-arms it around a navigation - the framework arms it with the first
    " display, stops it while the popup app has the screen and arms it again
    " when the popup app leaves (z2ui5_cl_ui5_handler=>main_end_timer)
    IF client->check_on_init( ).
      client->timer_set( event    = `POLL`
                         delay_ms = 300
                         no_busy  = abap_true ).
      view_display( ).
      RETURN.
    ENDIF.

    IF client->check_on_navigated( ).
      view_display( ).
      RETURN.
    ENDIF.

    CASE client->get_event( ).
      WHEN `POLL`.
        polls = polls + 1.
      WHEN `POPUP`.
        client->nav_app_call( NEW zcl_tst_popup_app( ) ).
      WHEN `STOP`.
        client->timer_stop( ).
      WHEN `SET`.
        client->timer_set( event    = `POLL`
                           delay_ms = 300
                           no_busy  = abap_true ).
    ENDCASE.

  ENDMETHOD.


  METHOD view_display.
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA page TYPE REF TO z2ui5_cl_ui5_view_builder.

    view = z2ui5_cl_ui5_view_builder=>factory( ).
    page = view->ele( n = `View` ns = `mvc`
        )->a( n = `xmlns`        v = `sap.m`
        )->a( n = `xmlns:mvc`    v = `sap.ui.core.mvc`
        )->a( n = `displayBlock` v = `true`
        )->a( n = `height`       v = `100%`
        )->ele( `Shell`
            )->ele( `Page`
                )->a( n = `title` v = `TIMER_SET` ).

    page->tag( `Text`
        )->a( n = `id`   v = `txtPolls`
        )->a( n = `text` v = client->_bind( polls ) ).
    page->tag( `Button`
        )->a( n = `id`    v = `btnPopup`
        )->a( n = `text`  v = `open the popup app`
        )->a( n = `press` v = client->_event( `POPUP` ) ).
    page->tag( `Button`
        )->a( n = `id`    v = `btnStop`
        )->a( n = `text`  v = `stop`
        )->a( n = `press` v = client->_event( `STOP` ) ).
    page->tag( `Button`
        )->a( n = `id`    v = `btnSet`
        )->a( n = `text`  v = `set`
        )->a( n = `press` v = client->_event( `SET` ) ).

    client->view_display( view->stringify( ) ).
  ENDMETHOD.

ENDCLASS.
