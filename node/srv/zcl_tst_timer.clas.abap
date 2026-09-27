CLASS zcl_tst_timer DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA ticks TYPE i.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
    METHODS view_display.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_tst_timer IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    me->client = client.

    " e2e fixture for START_TIMER's optional third argument, the tick's
    " check_no_busy (timer-no-busy spec). Each ARM_* press arms ONE tick,
    " with or without the flag, and the tick counts itself into a bound
    " text. The spec holds the TICK roundtrip back past UI5's one-second
    " busy delay and asks the global busy indicator whether it opened: the
    " flagged tick leaves it down, the plain one raises it as it always did
    " (see evStartTimer in app/webapp/core/actions/ViewOps.js). The flag
    " is an ABAP boolean spelled as it travels, `X` - the way t_arg carries
    " every boolean (binding_call's sort flags, a control_by_id setter).
    " check_on_init( ) implies check_on_navigated( ), so one arm displays.
    IF client->check_on_navigated( ).
      view_display( ).

    ELSEIF client->check_on_event( `ARM_SILENT` ).
      client->follow_up_action( val   = client->cs_event-start_timer
                                t_arg = VALUE #( ( `TICK` ) ( `50` ) ( `X` ) ) ).

    ELSEIF client->check_on_event( `ARM_PLAIN` ).
      client->follow_up_action( val   = client->cs_event-start_timer
                                t_arg = VALUE #( ( `TICK` ) ( `50` ) ) ).

    ELSEIF client->check_on_event( `TICK` ).
      ticks = ticks + 1.
    ENDIF.

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
                )->a( n = `title` v = `START_TIMER NO BUSY` ).

    page->tag( `Text`
        )->a( n = `id`   v = `txtTicks`
        )->a( n = `text` v = client->_bind( ticks ) ).
    page->tag( `Button`
        )->a( n = `id`    v = `btnArmSilent`
        )->a( n = `text`  v = `arm a no-busy tick`
        )->a( n = `press` v = client->_event( `ARM_SILENT` ) ).
    page->tag( `Button`
        )->a( n = `id`    v = `btnArmPlain`
        )->a( n = `text`  v = `arm a plain tick`
        )->a( n = `press` v = client->_event( `ARM_PLAIN` ) ).

    client->view_display( view->stringify( ) ).
  ENDMETHOD.

ENDCLASS.
