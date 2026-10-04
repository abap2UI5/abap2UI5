CLASS zcl_tst_stack_a DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA input         TYPE string.
    DATA result        TYPE string.
    " abap2ui5lint-disable-next-line unbound-public-attribute -- set by the called app zcl_tst_stack_b
    DATA backend_event TYPE string.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
    METHODS view_display.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_tst_stack_a IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    DATA lo_b TYPE REF TO zcl_tst_stack_b.

    me->client = client.

    " Fixture of the concurrency spec (node/tests/concurrency.spec.js): the
    " app-to-app flow of samples z2ui5_cl_smp_app_024 / _025 cut to what
    " carries data. CALL hands the bound input to a new zcl_tst_stack_b
    " through nav_app_call; its BACK writes into this app on the stack and
    " leaves to it; the return reads the called app through get_app_prev.
    " Every hop moves the value a client sent through the app stack, so a
    " request that sees another request's state answers with that client's
    " value - which is what two interleaved flows did on the Node host.
    IF client->check_on_navigated( ).
      IF backend_event = `RETURN`.
        lo_b ?= client->get_app_prev( ).
        result = lo_b->input.
        CLEAR backend_event.
      ENDIF.
      view_display( ).

    ELSEIF client->check_on_event( `CALL` ).
      CREATE OBJECT lo_b.
      lo_b->input_from_a = input.
      client->nav_app_call( lo_b ).

    ELSEIF client->check_on_event( `CALL_SLOW` ).
      " the same hop with a pause in the middle of the request: WAIT is a
      " real timer in the transpiled runtime, the one statement that hands
      " the event loop back mid-request - as an HTTP call or a host's
      " asynchronous draft store does. The other requests of the spec arrive
      " while this one waits
      WAIT UP TO 1 SECONDS.
      CREATE OBJECT lo_b.
      lo_b->input_from_a = input.
      client->nav_app_call( lo_b ).
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
            )->a( n = `title` v = `STACK A` ).

    page->tag( `Input`
        )->a( n = `value` v = client->_bind( input ) ).
    page->tag( `Text`
        )->a( n = `text` v = client->_bind( result ) ).
    page->tag( `Button`
        )->a( n = `text`  v = `call`
        )->a( n = `press` v = client->_event( `CALL` ) ).
    page->tag( `Button`
        )->a( n = `text`  v = `call, slowly`
        )->a( n = `press` v = client->_event( `CALL_SLOW` ) ).

    client->view_display( view->stringify( ) ).
  ENDMETHOD.

ENDCLASS.
